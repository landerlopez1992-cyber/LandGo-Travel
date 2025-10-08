import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'travel_feed_page_model.dart';
export 'travel_feed_page_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';

class TravelFeedPageWidget extends StatefulWidget {
  const TravelFeedPageWidget({super.key});

  static const String routeName = 'TravelFeedPage';
  static const String routePath = '/travelFeedPage';

  @override
  State<TravelFeedPageWidget> createState() => _TravelFeedPageWidgetState();
}

class _TravelFeedPageWidgetState extends State<TravelFeedPageWidget> {
  late TravelFeedPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Variables de estado
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _subcommentController = TextEditingController();
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // Para web
  final ImagePicker _picker = ImagePicker();
  
  // Variables para el modal de crear post
  bool _isCreatingPost = false;
  bool _isLoadingImage = false; // 🔄 Indicador de carga de imagen
  
  // Variables para etiquetado de usuarios
  final TextEditingController _tagSearchController = TextEditingController();
  List<Map<String, dynamic>> _tagSearchResults = [];
  List<Map<String, dynamic>> _selectedTags = [];
  bool _isSearchingTags = false;
  
  // Cache para evitar múltiples llamadas a la base de datos
  final Map<String, Future<List<Map<String, dynamic>>>> _commentsCache = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TravelFeedPageModel());
    _loadPosts();
  }

  @override
  void dispose() {
    _model.dispose();
    _postController.dispose();
    _commentController.dispose();
    _subcommentController.dispose();
    _tagSearchController.dispose();
    super.dispose();
  }

  /// 🔍 BÚSQUEDA DE USUARIOS EN TIEMPO REAL PARA ETIQUETAR
  void _onTagSearchChanged() async {
    final query = _tagSearchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _tagSearchResults = [];
        _isSearchingTags = false;
      });
      return;
    }

    setState(() {
      _isSearchingTags = true;
    });

    try {
      // Obtener ID del usuario actual
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      
      // Buscar en la tabla profiles por nombre completo, email o teléfono
      // EXCLUIR al usuario actual de los resultados
      final response = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name, email, phone, avatar_url, first_name, last_name')
          .or('full_name.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%,first_name.ilike.%$query%,last_name.ilike.%$query%')
          .neq('id', currentUserId ?? '')
          .limit(10);

      setState(() {
        _tagSearchResults = List<Map<String, dynamic>>.from(response);
        _isSearchingTags = false;
      });
    } catch (e) {
      print('Error searching users for tags: $e');
      setState(() {
        _tagSearchResults = [];
        _isSearchingTags = false;
      });
    }
  }

  /// ➕ AGREGAR USUARIO A ETIQUETAS
  void _addTag(Map<String, dynamic> user) {
    // Verificar si ya está etiquetado
    if (!_selectedTags.any((tag) => tag['id'] == user['id'])) {
      setState(() {
        _selectedTags.add(user);
      });
      _tagSearchController.clear();
      _tagSearchResults = [];
    }
  }

  /// ➖ REMOVER USUARIO DE ETIQUETAS
  void _removeTag(Map<String, dynamic> user) {
    setState(() {
      _selectedTags.removeWhere((tag) => tag['id'] == user['id']);
    });
  }

  /// 🏷️ GENERAR TEXTO DE ETIQUETAS PARA MOSTRAR EN POST
  String _generateTagsText(List<dynamic> taggedUsers) {
    if (taggedUsers.isEmpty) return '';
    
    // Filtrar usuarios con nombres válidos
    final validUsers = taggedUsers.where((user) => 
      user['full_name'] != null && 
      user['full_name'].toString().trim().isNotEmpty
    ).toList();
    
    if (validUsers.isEmpty) return '';
    
    if (validUsers.length == 1) {
      return '${validUsers[0]['full_name']} está en esta experiencia';
    } else if (validUsers.length == 2) {
      return '${validUsers[0]['full_name']} está junto a ${validUsers[1]['full_name']}';
    } else {
      final firstUser = validUsers[0]['full_name'];
      final secondUser = validUsers[1]['full_name'];
      final remainingCount = validUsers.length - 2;
      return '$firstUser está junto a $secondUser y $remainingCount personas más';
    }
  }

  /// ✅ CARGAR POSTS DESDE SUPABASE
  Future<void> _loadPosts() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = '';
        });
      }
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        if (mounted) {
          setState(() {
            _posts = [];
            _isLoading = false;
            _errorMessage = 'No user logged in';
          });
        }
        return;
      }
      
      print('🔍 DEBUG: Loading travel feed posts...');
      
      // Obtener posts con información del usuario, likes, comentarios y etiquetas
      final postsResponse = await Supabase.instance.client
          .from('travel_posts')
          .select('''
            *,
            profiles!travel_posts_user_id_fkey(
              full_name,
              avatar_url,
              first_name,
              last_name
            ),
            travel_post_likes(
              id,
              user_id,
              created_at
            ),
            travel_post_comments(
              id,
              user_id,
              content,
              created_at
            ),
            travel_post_tags(
              id,
              tagged_user_id
            )
          ''')
          .order('created_at', ascending: false);
      
      List<Map<String, dynamic>> posts = List<Map<String, dynamic>>.from(postsResponse);
      
      // Procesar posts para agregar información de likes, comentarios y etiquetas
      for (var post in posts) {
        final likes = post['travel_post_likes'] as List<dynamic>? ?? [];
        final comments = post['travel_post_comments'] as List<dynamic>? ?? [];
        final tags = post['travel_post_tags'] as List<dynamic>? ?? [];
        
        post['likes_count'] = likes.length;
        post['user_liked'] = likes.any((like) => like['user_id'] == user.id);
        post['comments_count'] = comments.length;
        
        // Procesar etiquetas - cargar nombres por separado
        final taggedUserIds = tags.map((tag) => tag['tagged_user_id']).toList();
        List<Map<String, dynamic>> taggedUsers = [];
        
        if (taggedUserIds.isNotEmpty) {
          try {
            final profilesResponse = await Supabase.instance.client
                .from('profiles')
                .select('id, full_name, first_name, last_name, avatar_url')
                .inFilter('id', taggedUserIds);
            
            taggedUsers = List<Map<String, dynamic>>.from(profilesResponse);
          } catch (e) {
            print('Error loading tagged user profiles: $e');
            // Fallback: crear usuarios con solo ID
            taggedUsers = taggedUserIds.map((id) => {
              'id': id,
              'full_name': 'Usuario',
              'first_name': '',
              'last_name': '',
              'avatar_url': null
            }).toList();
          }
        }
        
        post['tagged_users'] = taggedUsers;
      }
      
      print('✅ Travel Feed Posts: ${posts.length}');
      
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
      
    } catch (e) {
      print('❌ Error loading travel feed: $e');
      if (mounted) {
        setState(() {
          _posts = [];
          _isLoading = false;
          _errorMessage = 'Error loading posts: $e';
        });
      }
    }
  }

  /// ✅ CREAR NUEVO POST
  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty && _selectedImage == null && _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some text or an image to your post'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    // 🎯 Mostrar modal de carga hermoso
    _showUploadingModal();

    // Activar estado de carga
    if (mounted) {
      setState(() {
        _isCreatingPost = true;
      });
    }

    // ⏱️ Esperar mínimo 3 segundos para disfrutar la animación
    final uploadStartTime = DateTime.now();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _isCreatingPost = false;
          });
        }
        return;
      }

      print('🔄 DEBUG: Iniciando creación de post...');
      print('📝 Content: ${_postController.text.trim()}');
      print('🖼️ Has image: ${_selectedImage != null}');

      // Subir imagen si existe
      String? imageUrl;
      if (_selectedImage != null || _selectedImageBytes != null) {
        print('📤 DEBUG: Subiendo imagen a Supabase Storage...');
        
        final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        try {
          // Subir archivo a Supabase Storage (compatible con web y móvil)
          if (kIsWeb && _selectedImageBytes != null) {
            // Para web: usar bytes con estructura de carpetas
            final folderPath = 'public/$fileName'; // Carpeta public para acceso directo
            await Supabase.instance.client.storage
            .from('travel-images')
                .uploadBinary(folderPath, _selectedImageBytes!);
        
            // Obtener URL pública de la imagen
          imageUrl = Supabase.instance.client.storage
              .from('travel-images')
                .getPublicUrl(folderPath);
          } else if (_selectedImage != null) {
            // Para móvil: usar File con estructura de carpetas
            final folderPath = 'public/$fileName'; // Carpeta public para acceso directo
            await Supabase.instance.client.storage
                .from('travel-images')
                .upload(folderPath, _selectedImage!);
            
            // Obtener URL pública de la imagen
            imageUrl = Supabase.instance.client.storage
                .from('travel-images')
                .getPublicUrl(folderPath);
          }
          
          print('✅ DEBUG: Imagen subida exitosamente: $imageUrl');
        } catch (uploadError) {
          print('❌ DEBUG: Error subiendo imagen: $uploadError');
          throw Exception('Failed to upload image: $uploadError');
        }
      }

      print('💾 DEBUG: Creando post en base de datos...');
      print('👤 DEBUG: User ID: ${user.id}');
      print('🔐 DEBUG: Auth UID: ${Supabase.instance.client.auth.currentUser?.id}');

      // Crear post en la base de datos
      final postData = {
            'user_id': user.id,
            'content': _postController.text.trim(),
            'image_url': imageUrl,
            'location': null, // Opcional: agregar ubicación
            'tags': [], // Opcional: agregar tags
      };
      
      print('📊 DEBUG: Post data: $postData');
      
      try {
        final insertResponse = await Supabase.instance.client
            .from('travel_posts')
            .insert(postData)
            .select();
        
        print('✅ DEBUG: Post creado exitosamente: $insertResponse');
        
        // Guardar etiquetas si hay usuarios seleccionados
        if (_selectedTags.isNotEmpty && insertResponse.isNotEmpty) {
          final postId = insertResponse[0]['id'];
          print('🏷️ DEBUG: Guardando ${_selectedTags.length} etiquetas para post $postId');
          
          for (final tag in _selectedTags) {
            await Supabase.instance.client
                .from('travel_post_tags')
                .insert({
                  'post_id': postId,
                  'tagged_user_id': tag['id']
                });
          }
          
          print('✅ DEBUG: Etiquetas guardadas exitosamente');
        }
      } catch (insertError) {
        print('❌ DEBUG: Error insertando post: $insertError');
        print('❌ DEBUG: Error type: ${insertError.runtimeType}');
        print('❌ DEBUG: Error details: ${insertError.toString()}');
        throw insertError; // Re-lanzar el error para que se maneje arriba
      }

      // Limpiar formulario
      _postController.clear();
      _selectedImage = null;
      _selectedImageBytes = null;
      _selectedTags.clear();
      _tagSearchController.clear();
      _tagSearchResults.clear();
      
      // Recargar posts
      await _loadPosts();
      
      // ⏱️ Asegurar que el modal dure mínimo 3 segundos
      final uploadDuration = DateTime.now().difference(uploadStartTime);
      final minDuration = const Duration(seconds: 3);
      if (uploadDuration < minDuration) {
        await Future.delayed(minDuration - uploadDuration);
      }
      
      if (mounted) {
        setState(() {
          _isCreatingPost = false;
        });
        
        // Cerrar modal de carga
        Navigator.of(context).pop();
        
        // Cerrar modal de crear post
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Experiencia compartida exitosamente!'),
            backgroundColor: Color(0xFF4DD0E1),
            duration: Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      print('❌ Error creating post: $e');
      if (mounted) {
        setState(() {
          _isCreatingPost = false;
        });
        
        // Cerrar modal de carga
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al compartir: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// 🎨 MODAL DE CARGA HERMOSO DURANTE UPLOAD
  void _showUploadingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DD0E1).withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🌍 Icono animado de avión/globo
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return Transform.rotate(
                        angle: value * 2 * 3.14159,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4DD0E1),
                                const Color(0xFF4DD0E1).withValues(alpha: 0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.flight_takeoff,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      // Reiniciar animación
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // ✨ Texto principal
                  Text(
                    '✨ Compartiendo tu experiencia',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 🎯 Texto secundario
                  Text(
                    'inolvidable...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF4DD0E1),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 🔄 Indicador de progreso elegante
                  SizedBox(
                    width: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(seconds: 2),
                        builder: (context, double value, child) {
                          return LinearProgressIndicator(
                            value: null, // Indeterminado
                            minHeight: 6,
                            backgroundColor: const Color(0xFF2C2C2C),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF4DD0E1),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 💬 Mensaje adicional
                  Text(
                    '🌎 Subiendo a la comunidad LandGo Travel',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🗑️ ELIMINAR POST CON CONFIRMACIÓN
  Future<void> _deletePost(String postId) async {
    // Mostrar modal de confirmación
    final confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;

    // Mostrar modal de carga al eliminar
    _showDeletingModal();

    try {
      // Esperar 2 segundos para mostrar la animación
      await Future.delayed(const Duration(seconds: 2));

      // Eliminar post de la base de datos
      await Supabase.instance.client
          .from('travel_posts')
          .delete()
          .eq('id', postId);

      // Cerrar modal de carga
      Navigator.of(context).pop();

      // Recargar posts
      await _loadPosts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Post eliminado exitosamente'),
            backgroundColor: Color(0xFFDC2626),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error deleting post: $e');
      
      // Cerrar modal de carga
      Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al eliminar: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// ✏️ EDITAR POST
  Future<void> _editPost(Map<String, dynamic> post) async {
    try {
      // Mostrar indicador de carga antes de procesar datos
      setState(() {
        _isLoading = true;
      });
      
      // Configurar el modal con los datos del post existente
      _postController.text = post['content'] ?? '';
      
      // Cargar etiquetas existentes
      _selectedTags.clear();
      if (post['tagged_users'] != null && (post['tagged_users'] as List).isNotEmpty) {
        _selectedTags.addAll(post['tagged_users']);
      }
      
      // TODO: Cargar imagen existente si tiene
      _selectedImage = null;
      _selectedImageBytes = null;
      
      // Pequeña pausa para asegurar que los datos se cargaron correctamente
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Ocultar indicador de carga
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
      // Mostrar modal de edición
      _showEditPostModal(post['id']);
    } catch (e) {
      // Manejo de errores
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// ✏️ MODAL DE EDICIÓN DE POST
  void _showEditPostModal(String postId) {
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '✏️ Editar Post',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                
                const Divider(color: Colors.white24),
                
                // Content - SCROLLABLE
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                      children: [
                        // Text input
                        Container(
                          height: 120, // Altura fija en lugar de Expanded
                          child: TextField(
                            controller: _postController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: '¿Qué quieres compartir?',
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF2C2C2C),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 🏷️ SECCIÓN DE ETIQUETADO DE USUARIOS EN EDITAR
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header de etiquetado
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person_add,
                                      color: Color(0xFF4DD0E1),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Tag Friends',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (_selectedTags.isNotEmpty)
                                      Text(
                                        '${_selectedTags.length}',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF4DD0E1),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // Campo de búsqueda
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: TextField(
                                  controller: _tagSearchController,
                                  onChanged: (value) {
                                    setModalState(() {});
                                    _onTagSearchChanged();
                                  },
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search users to tag...',
                                    hintStyle: GoogleFonts.outfit(
                                      color: Colors.white54,
                                      fontSize: 14,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Color(0xFF4DD0E1),
                                      size: 20,
                                    ),
                                    suffixIcon: _isSearchingTags
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF4DD0E1),
                                            ),
                                          )
                                        : null,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Colors.white24),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Colors.white24),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFF4DD0E1)),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF1A1A1A),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ),
                              
                              // Resultados de búsqueda
                              if (_tagSearchResults.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  constraints: const BoxConstraints(maxHeight: 150),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _tagSearchResults.length,
                                    itemBuilder: (context, index) {
                                      final user = _tagSearchResults[index];
                                      return ListTile(
                                        dense: true,
                                        leading: CircleAvatar(
                                          radius: 16,
                                          backgroundColor: const Color(0xFF4DD0E1),
                                          backgroundImage: user['avatar_url'] != null
                                              ? NetworkImage(user['avatar_url'])
                                              : null,
                                          child: user['avatar_url'] == null
                                              ? Text(
                                                  (user['full_name'] ?? 'U')[0].toUpperCase(),
                                                  style: GoogleFonts.outfit(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        title: Text(
                                          user['full_name'] ?? 'Usuario',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Text(
                                          user['email'] ?? '',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        trailing: const Icon(
                                          Icons.add_circle_outline,
                                          color: Color(0xFF4DD0E1),
                                          size: 20,
                                        ),
                                        onTap: () {
                                          setModalState(() {
                                            _addTag(user);
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                              
                              // Usuarios etiquetados
                              if (_selectedTags.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _selectedTags.map((user) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4DD0E1),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              user['full_name'] ?? 'Usuario',
                                              style: GoogleFonts.outfit(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () {
                                                setModalState(() {
                                                  _removeTag(user);
                                                });
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.black,
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Image preview (if editing existing image)
                        if (_selectedImage != null || _selectedImageBytes != null)
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: kIsWeb && _selectedImageBytes != null
                                  ? Image.memory(
                                      _selectedImageBytes!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: const Color(0xFF2C2C2C),
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.white70,
                                              size: 48,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : _selectedImage != null
                                      ? Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: const Color(0xFF2C2C2C),
                                          child: const Center(
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.white70,
                                              size: 48,
                                            ),
                                          ),
                                        ),
                            ),
                          ),
                        
                        const SizedBox(height: 16),
                        
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: FFButtonWidget(
                                onPressed: (_isCreatingPost || _isLoadingImage) ? null : () => _pickImage(setModalState),
                                text: _isLoadingImage 
                                    ? 'Loading...' 
                                    : ((_selectedImage != null || _selectedImageBytes != null) ? 'Change Photo' : 'Add Photo'),
                                icon: (_isCreatingPost || _isLoadingImage)
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white70,
                                        ),
                                      )
                                    : Icon(
                                        (_selectedImage != null || _selectedImageBytes != null) ? Icons.swap_horiz : Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                options: FFButtonOptions(
                                  height: 48,
                                  color: (_isCreatingPost || _isLoadingImage)
                                      ? const Color(0xFF2C2C2C)
                                      : ((_selectedImage != null || _selectedImageBytes != null)
                                          ? const Color(0xFF4DD0E1) 
                                          : const Color(0xFF37474F)),
                                  textStyle: GoogleFonts.outfit(
                                    color: (_isCreatingPost || _isLoadingImage) ? Colors.white70 : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FFButtonWidget(
                                onPressed: (_isCreatingPost || _isLoadingImage) ? null : () => _updatePost(postId),
                                text: _isCreatingPost ? 'Guardando...' : 'Guardar',
                                icon: _isCreatingPost 
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                                options: FFButtonOptions(
                                  height: 48,
                                  color: (_isCreatingPost || _isLoadingImage)
                                      ? const Color(0xFF4DD0E1).withValues(alpha: 0.7)
                                      : const Color(0xFF4DD0E1),
                                  textStyle: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    } catch (e) {
      print('Error al mostrar modal de edición: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir el editor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 💾 ACTUALIZAR POST EXISTENTE
  Future<void> _updatePost(String postId) async {
    if (_postController.text.trim().isEmpty && _selectedImage == null && _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some text or an image to your post'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    // Mostrar modal de carga específico para guardar
    _showSavingModal();

    // Activar estado de carga
    if (mounted) {
      setState(() {
        _isCreatingPost = true;
      });
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Subir nueva imagen si existe
      String? imageUrl;
      if (_selectedImage != null || _selectedImageBytes != null) {
        final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        if (kIsWeb && _selectedImageBytes != null) {
          final folderPath = 'public/$fileName';
          await Supabase.instance.client.storage
              .from('travel-images')
              .uploadBinary(folderPath, _selectedImageBytes!);
          
          imageUrl = Supabase.instance.client.storage
              .from('travel-images')
              .getPublicUrl(folderPath);
        } else if (_selectedImage != null) {
          final folderPath = 'public/$fileName';
          await Supabase.instance.client.storage
              .from('travel-images')
              .upload(folderPath, _selectedImage!);
          
          imageUrl = Supabase.instance.client.storage
              .from('travel-images')
              .getPublicUrl(folderPath);
        }
      }

      // Actualizar post en la base de datos
      final updateData = {
        'content': _postController.text.trim(),
        if (imageUrl != null) 'image_url': imageUrl,
      };
      
      await Supabase.instance.client
          .from('travel_posts')
          .update(updateData)
          .eq('id', postId);

      // Actualizar etiquetas si hay cambios
      if (_selectedTags.isNotEmpty) {
        // Eliminar etiquetas existentes
        await Supabase.instance.client
            .from('travel_post_tags')
            .delete()
            .eq('post_id', postId);
        
        // Agregar nuevas etiquetas
        for (final tag in _selectedTags) {
          await Supabase.instance.client
              .from('travel_post_tags')
              .insert({
                'post_id': postId,
                'tagged_user_id': tag['id']
              });
        }
      } else {
        // Si no hay etiquetas seleccionadas, eliminar todas las existentes
        await Supabase.instance.client
            .from('travel_post_tags')
            .delete()
            .eq('post_id', postId);
      }

      // Limpiar formulario
      _postController.clear();
      _selectedImage = null;
      _selectedImageBytes = null;
      _selectedTags.clear();
      _tagSearchController.clear();
      _tagSearchResults.clear();
      
      // Recargar posts
      await _loadPosts();
      
      if (mounted) {
        setState(() {
          _isCreatingPost = false;
        });
        
        // Cerrar modal de carga
        Navigator.of(context).pop();
        
        // Cerrar modal de edición
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Post actualizado exitosamente!'),
            backgroundColor: Color(0xFF4DD0E1),
            duration: Duration(seconds: 3),
          ),
        );
      }
      
    } catch (e) {
      print('❌ Error updating post: $e');
      if (mounted) {
        setState(() {
          _isCreatingPost = false;
        });
        
        // Cerrar modal de carga
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al actualizar: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// ❓ MODAL DE CONFIRMACIÓN PARA ELIMINAR
  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Color(0xFFDC2626),
              width: 2,
            ),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFDC2626),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '¿Eliminar post?',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Esta acción no se puede deshacer. El post será eliminado permanentemente.',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Eliminar',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// 💾 MODAL DE CARGA AL GUARDAR EDICIÓN
  void _showSavingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DD0E1).withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 💾 Icono animado de guardado
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return Transform.rotate(
                        angle: value * 2 * 3.14159,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4DD0E1),
                                const Color(0xFF4DD0E1).withValues(alpha: 0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.save_alt,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      // Reiniciar animación
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 💾 Texto principal
                  Text(
                    '💾 Guardando tu experiencia',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 🎯 Texto secundario
                  Text(
                    'actualizada...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF4DD0E1),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 🔄 Indicador de progreso elegante
                  SizedBox(
                    width: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: null, // Indeterminado
                        minHeight: 6,
                        backgroundColor: Color(0xFF2C2C2C),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4DD0E1),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 💬 Mensaje adicional
                  Text(
                    '🌎 Actualizando en la comunidad LandGo Travel',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🗑️ MODAL DE CARGA AL ELIMINAR (Diseño LandGo Travel)
  void _showDeletingModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DD0E1).withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🗑️ Icono animado de eliminación con diseño turquesa
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4DD0E1),
                                const Color(0xFF4DD0E1).withValues(alpha: 0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 🗑️ Texto principal
                  Text(
                    '🗑️ Eliminando post...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // ⏱️ Texto secundario
                  Text(
                    'Por favor espera...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF4DD0E1),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 🔄 Indicador de progreso con diseño turquesa
                  SizedBox(
                    width: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        minHeight: 6,
                        backgroundColor: Color(0xFF2C2C2C),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4DD0E1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 💬 MOSTRAR MODAL DE COMENTARIOS CON LISTA
  void _showCommentsModal(Map<String, dynamic> post) {
    final postId = post['id']?.toString();
    if (postId == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          // Función para recargar comentarios en el modal
          Future<void> refreshComments() async {
            setModalState(() {});
          }
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollController) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '💬 Comentarios (${post['comments_count'] ?? 0})',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                
                const Divider(color: Colors.white24),
                
                // Lista de comentarios - SCROLLABLE
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    // Usar cacheado para evitar múltiples llamadas
                    future: _commentsCache[postId] ?? (_commentsCache[postId] = _loadComments(postId)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4DD0E1),
                          ),
                        );
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error al cargar comentarios: ${snapshot.error}',
                            style: GoogleFonts.outfit(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }
                      
                      final comments = snapshot.data ?? [];
                      
                      if (comments.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                size: 64,
                                color: Colors.white54,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay comentarios aún',
                                style: GoogleFonts.outfit(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '¡Sé el primero en comentar!',
                                style: GoogleFonts.outfit(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return _buildCommentItem(comment, postId, refreshComments);
                        },
                      );
                    },
                  ),
                ),
                
                const Divider(color: Colors.white24),
                
                // Input para escribir comentario - SIEMPRE VISIBLE
                SafeArea(
                  child: Container(
                    color: const Color(0xFF1A1A1A),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            maxLines: 2,
                            maxLength: 500,
                            textAlignVertical: TextAlignVertical.top,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Escribe tu comentario...',
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              counterStyle: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            controller: _commentController,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Botones
                        Row(
                          children: [
                            Expanded(
                              child: FFButtonWidget(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _commentController.clear();
                                },
                                text: 'Cancelar',
                                options: FFButtonOptions(
                                  height: 44,
                                  color: const Color(0xFF37474F),
                                  textStyle: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FFButtonWidget(
                                onPressed: _commentController.text.trim().isEmpty 
                                    ? null 
                                    : () => _postComment(postId, post['profiles']['full_name'] ?? 'Usuario'),
                                text: 'Comentar',
                                options: FFButtonOptions(
                                  height: 44,
                                  color: _commentController.text.trim().isEmpty
                                      ? const Color(0xFF4DD0E1).withValues(alpha: 0.7)
                                      : const Color(0xFF4DD0E1),
                                  textStyle: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ],
                  ),
                ),
              );
            },
          );
        },
      ),
    ).then((_) {
      // Limpiar el caché de comentarios cuando se cierra el modal
      _commentsCache.remove(postId);
    });
  }

  /// 📝 CARGAR COMENTARIOS DE UN POST
  Future<List<Map<String, dynamic>>> _loadComments(String postId) async {
    try {
      // Agregamos un pequeño retraso para evitar congelamientos
      await Future.delayed(const Duration(milliseconds: 200));
      
      final currentUser = Supabase.instance.client.auth.currentUser;
      
      final response = await Supabase.instance.client
          .from('travel_post_comments')
          .select('''
            id,
            user_id,
            content,
            created_at,
            profiles!travel_post_comments_user_id_fkey(
              full_name,
              avatar_url
            )
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      // Procesar comentarios para agregar datos de likes
      List<Map<String, dynamic>> processedComments = [];
      
      for (var comment in response) {
        final commentId = comment['id'];
        
        // Cargar likes para este comentario
        final likesResponse = await Supabase.instance.client
            .from('travel_comment_likes')
            .select('user_id')
            .eq('comment_id', commentId);
        
        final likesCount = likesResponse.length;
        final userLiked = currentUser != null && 
            likesResponse.any((like) => like['user_id'] == currentUser.id);
        
        // Agregar datos de likes al comentario
        comment['likes_count'] = likesCount;
        comment['user_liked'] = userLiked;
        
        processedComments.add(comment);
      }

      return processedComments;
    } catch (e) {
      print('❌ Error loading comments: $e');
      return [];
    }
  }

  /// 📝 CARGAR RESPUESTAS (SUBCOMENTARIOS) DE UN COMENTARIO
  Future<List<Map<String, dynamic>>> _loadReplies(String commentId) async {
    try {
      // 1) Cargar replies sin joins (para evitar errores de relación)
      final repliesResponse = await Supabase.instance.client
          .from('travel_comment_replies')
          .select('id, content, created_at, user_id')
          .eq('comment_id', commentId)
          .order('created_at', ascending: true);

      final List<Map<String, dynamic>> replies =
          List<Map<String, dynamic>>.from(repliesResponse);

      if (replies.isEmpty) return replies;

      // 2) Obtener perfiles para los user_id involucrados
      final userIds = replies
          .map((r) => r['user_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      Map<String, Map<String, dynamic>> userIdToProfile = {};
      if (userIds.isNotEmpty) {
        try {
          final profilesResponse = await Supabase.instance.client
              .from('profiles')
              .select('id, full_name, avatar_url')
              .inFilter('id', userIds);

          final profilesList =
              List<Map<String, dynamic>>.from(profilesResponse);
          for (final p in profilesList) {
            final pid = p['id'];
            if (pid != null) {
              userIdToProfile[pid] = p;
            }
          }
        } catch (e) {
          // Si falla la carga de perfiles, continuamos sin romper la UI
          print('⚠️ Error loading reply profiles: $e');
        }
      }

      // 3) Adjuntar perfiles a cada reply para la UI
      for (final reply in replies) {
        final uid = reply['user_id'];
        reply['profiles'] = userIdToProfile[uid] ?? {
          'full_name': 'Usuario',
          'avatar_url': null,
        };
      }

      return replies;
    } catch (e) {
      print('❌ Error loading replies: $e');
      return [];
    }
  }

  /// 🏗️ CONSTRUIR ITEM DE COMENTARIO
  Widget _buildCommentItem(Map<String, dynamic> comment, String postId, VoidCallback refreshCallback) {
    final profile = comment['profiles'] ?? {};
    final userName = profile['full_name'] ?? 'Usuario';
    final avatarUrl = profile['avatar_url'];
    final content = comment['content'] ?? '';
    final createdAt = comment['created_at']?.toString() ?? '';
    final commentId = comment['id']?.toString() ?? '';
    final userId = comment['user_id']?.toString() ?? '';
    
    // Datos de likes del comentario
    final likesCount = comment['likes_count'] ?? 0;
    final userLiked = comment['user_liked'] ?? false;
    
    // Verificar si es el usuario actual
    final currentUser = Supabase.instance.client.auth.currentUser;
    final isCurrentUser = currentUser?.id == userId;
    
    // Formatear fecha
    String formattedDate = '';
    if (createdAt.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAt);
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inMinutes < 1) {
          formattedDate = 'Ahora';
        } else if (difference.inMinutes < 60) {
          formattedDate = '${difference.inMinutes}m';
        } else if (difference.inHours < 24) {
          formattedDate = '${difference.inHours}h';
        } else if (difference.inDays < 7) {
          formattedDate = '${difference.inDays}d';
        } else {
          formattedDate = '${date.day}/${date.month}/${date.year}';
        }
      } catch (e) {
        formattedDate = '';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4DD0E1).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del comentario
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF4DD0E1),
                backgroundImage: avatarUrl != null 
                    ? NetworkImage(avatarUrl) 
                    : null,
                child: avatarUrl == null 
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // Nombre y fecha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (formattedDate.isNotEmpty)
                      Text(
                        formattedDate,
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Menú de opciones (solo para el usuario actual)
              if (isCurrentUser)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white70,
                    size: 20,
                  ),
                  color: const Color(0xFF2C2C2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editComment(comment, postId, refreshCallback);
                    } else if (value == 'delete') {
                      _deleteComment(commentId, postId, refreshCallback);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit,
                            color: Color(0xFF4DD0E1),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Editar',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete,
                            color: Color(0xFFDC2626),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Eliminar',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Contenido del comentario
          Text(
            content,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Acciones del comentario (like y comentar)
          Row(
            children: [
              // Botón de Me Gusta
              GestureDetector(
                onTap: () => _toggleCommentLike(commentId, userLiked, postId, refreshCallback),
                child: Row(
                  children: [
                    Icon(
                      userLiked ? Icons.favorite : Icons.favorite_border,
                      color: userLiked ? const Color(0xFF4DD0E1) : Colors.white70,
                      size: 18,
                    ),
                    if (likesCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '$likesCount',
                        style: GoogleFonts.outfit(
                          color: userLiked ? const Color(0xFF4DD0E1) : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Botón de Comentar (Subcomentario)
              GestureDetector(
                onTap: () => _showSubcommentModal(comment, postId, refreshCallback),
                child: Row(
                  children: [
                    const Icon(
                      Icons.reply,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Comentar',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        
          const SizedBox(height: 8),

          // Lista de subcomentarios (respuestas)
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _loadReplies(commentId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }
              if (snapshot.hasError) {
                return const SizedBox.shrink();
              }
              final replies = snapshot.data ?? [];
              if (replies.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(top: 4, left: 36),
                child: Column(
                  children: replies.map((reply) {
                    final rProfile = reply['profiles'] ?? {};
                    final rName = rProfile['full_name'] ?? 'Usuario';
                    final rAvatar = rProfile['avatar_url'];
                    final rContent = reply['content'] ?? '';
                    final rCreatedAt = reply['created_at']?.toString() ?? '';

                    String rDate = '';
                    if (rCreatedAt.isNotEmpty) {
                      try {
                        final d = DateTime.parse(rCreatedAt);
                        final diff = DateTime.now().difference(d);
                        if (diff.inMinutes < 1) {
                          rDate = 'Ahora';
                        } else if (diff.inMinutes < 60) {
                          rDate = '${diff.inMinutes}m';
                        } else if (diff.inHours < 24) {
                          rDate = '${diff.inHours}h';
                        } else if (diff.inDays < 7) {
                          rDate = '${diff.inDays}d';
                        } else {
                          rDate = '${d.day}/${d.month}/${d.year}';
                        }
                      } catch (_) {}
                    }

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF4DD0E1).withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0xFF4DD0E1),
                            backgroundImage: rAvatar != null ? NetworkImage(rAvatar) : null,
                            child: rAvatar == null
                                ? Text(
                                    rName.isNotEmpty ? rName[0].toUpperCase() : 'U',
                                    style: GoogleFonts.outfit(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rName,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (rDate.isNotEmpty)
                                      Text(
                                        rDate,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white54,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  rContent,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// ❤️ TOGGLE LIKE DE COMENTARIO
  Future<void> _toggleCommentLike(String commentId, bool currentLiked, String postId, [VoidCallback? refreshCallback]) async {
    try {
      print('🔄 Toggle comment like - CommentId: $commentId, CurrentLiked: $currentLiked');
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ Usuario no autenticado');
        return;
      }

      // 🎯 ACTUALIZACIÓN OPTIMISTA - Actualizar caché primero
      if (_commentsCache.containsKey(postId)) {
        final cachedFuture = _commentsCache[postId];
        if (cachedFuture != null) {
          final comments = await cachedFuture;
          final commentIndex = comments.indexWhere((c) => c['id'] == commentId);
          if (commentIndex != -1) {
            comments[commentIndex]['user_liked'] = !currentLiked;
            comments[commentIndex]['likes_count'] = (currentLiked) 
              ? (comments[commentIndex]['likes_count'] ?? 1) - 1 
              : (comments[commentIndex]['likes_count'] ?? 0) + 1;
            
            // Actualizar el caché con los nuevos datos
            _commentsCache[postId] = Future.value(comments);
            
            // Refrescar UI inmediatamente
            if (refreshCallback != null) {
              refreshCallback();
            }
          }
        }
      }

      if (currentLiked) {
        // Quitar like
        await Supabase.instance.client
            .from('travel_comment_likes')
            .delete()
            .eq('comment_id', commentId)
            .eq('user_id', user.id);
        print('❤️ Like removido del comentario $commentId');
      } else {
        // Agregar like
        await Supabase.instance.client
            .from('travel_comment_likes')
            .insert({
              'comment_id': commentId,
              'user_id': user.id,
            });
        print('❤️ Like agregado al comentario $commentId');
      }
      
      print('✅ Like de comentario actualizado exitosamente');
      
    } catch (e) {
      print('❌ Error toggling comment like: $e');
      
      // 🔄 REVERTIR cambios en caso de error
      if (_commentsCache.containsKey(postId)) {
        final cachedFuture = _commentsCache[postId];
        if (cachedFuture != null) {
          final comments = await cachedFuture;
          final commentIndex = comments.indexWhere((c) => c['id'] == commentId);
          if (commentIndex != -1) {
            comments[commentIndex]['user_liked'] = currentLiked;
            comments[commentIndex]['likes_count'] = (currentLiked) 
              ? (comments[commentIndex]['likes_count'] ?? 0) + 1 
              : (comments[commentIndex]['likes_count'] ?? 1) - 1;
            
            _commentsCache[postId] = Future.value(comments);
            
            if (refreshCallback != null) {
              refreshCallback();
            }
          }
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar like: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// ✏️ EDITAR COMENTARIO
  void _editComment(Map<String, dynamic> comment, String postId, [VoidCallback? refreshCallback]) {
    final commentId = comment['id']?.toString();
    final currentContent = comment['content'] ?? '';
    
    if (commentId == null) return;

    // Crear controlador temporal para el modal
    final editController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DD0E1).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(
                        Icons.edit,
                        color: Color(0xFF4DD0E1),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Editar Comentario',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Campo de texto
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: editController,
                      maxLines: 3,
                      maxLength: 500,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Edita tu comentario...',
                        hintStyle: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        counterStyle: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () => Navigator.of(context).pop(),
                          text: 'Cancelar',
                          options: FFButtonOptions(
                            height: 48,
                            color: const Color(0xFF37474F),
                            textStyle: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: editController.text.trim().isEmpty 
                              ? null 
                              : () => _updateComment(commentId, editController.text.trim(), postId, refreshCallback),
                          text: 'Guardar',
                          options: FFButtonOptions(
                            height: 48,
                            color: editController.text.trim().isEmpty
                                ? const Color(0xFF4DD0E1).withValues(alpha: 0.7)
                                : const Color(0xFF4DD0E1),
                            textStyle: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🗑️ ELIMINAR COMENTARIO
  void _deleteComment(String commentId, String postId, [VoidCallback? refreshCallback]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.delete_forever,
              color: Color(0xFF4DD0E1),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Eliminar Comentario',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar este comentario? Esta acción no se puede deshacer.',
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.outfit(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _confirmDeleteComment(commentId, postId, refreshCallback);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DD0E1),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Eliminar',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ CONFIRMAR ELIMINACIÓN DE COMENTARIO
  Future<void> _confirmDeleteComment(String commentId, String postId, [VoidCallback? refreshCallback]) async {
    try {
      // Mostrar modal de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4DD0E1).withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono animado
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0.5, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4DD0E1),
                              const Color(0xFF4DD0E1).withValues(alpha: 0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_forever,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  '🗑️ Eliminando comentario...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Por favor espera...',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Barra de progreso
                Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF4DD0E1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Esperar 2 segundos
      await Future.delayed(const Duration(seconds: 2));

      // Eliminar comentario
      await Supabase.instance.client
          .from('travel_post_comments')
          .delete()
          .eq('id', commentId);

      // Cerrar modal de carga
      if (mounted) Navigator.of(context).pop();

      // Limpiar caché para forzar recarga de comentarios
      _commentsCache.remove(postId);
      
      // Actualizar contador de comentarios en el post
      final postIndex = _posts.indexWhere((p) => p['id'] == postId);
      if (postIndex != -1) {
        final currentCount = _posts[postIndex]['comments_count'] ?? 0;
        _posts[postIndex]['comments_count'] = currentCount > 0 ? currentCount - 1 : 0;
        setState(() {});
      }
      
      // Refrescar modal de comentarios si está abierto
      if (refreshCallback != null) {
        refreshCallback();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Comentario eliminado exitosamente'),
            backgroundColor: const Color(0xFF4DD0E1),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      print('❌ Error deleting comment: $e');
      
      // Cerrar modal de carga si está abierto
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar comentario: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 💾 ACTUALIZAR COMENTARIO
  Future<void> _updateComment(String commentId, String newContent, String postId, [VoidCallback? refreshCallback]) async {
    try {
      // Mostrar modal de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4DD0E1).withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono animado
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0.5, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4DD0E1),
                              const Color(0xFF4DD0E1).withValues(alpha: 0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.save_alt,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  '💾 Guardando comentario...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Por favor espera...',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Barra de progreso
                Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF4DD0E1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Esperar 2 segundos
      await Future.delayed(const Duration(seconds: 2));

      // Actualizar comentario
      await Supabase.instance.client
          .from('travel_post_comments')
          .update({'content': newContent})
          .eq('id', commentId);

      // Cerrar modales
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar modal de carga
        Navigator.of(context).pop(); // Cerrar modal de edición
      }

      // Limpiar caché para forzar recarga de comentarios
      _commentsCache.remove(postId);
      
      // Refrescar modal de comentarios si está abierto
      if (refreshCallback != null) {
        refreshCallback();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Comentario actualizado exitosamente'),
            backgroundColor: const Color(0xFF4DD0E1),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      print('❌ Error updating comment: $e');
      
      // Cerrar modales si están abiertos
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar modal de carga
        Navigator.of(context).pop(); // Cerrar modal de edición
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar comentario: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 💬 MOSTRAR MODAL DE SUBCOMENTARIO
  void _showSubcommentModal(Map<String, dynamic> comment, String postId, [VoidCallback? refreshCallback]) {
    final commentId = comment['id']?.toString();
    final profile = comment['profiles'] ?? {};
    final userName = profile['full_name'] ?? 'Usuario';
    
    if (commentId == null) return;

    // Usar controlador separado para subcomentarios
    _subcommentController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DD0E1).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(
                        Icons.reply,
                        color: Color(0xFF4DD0E1),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Responder a $userName',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Comentario original (preview)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF4DD0E1).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      comment['content'] ?? '',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Campo de texto
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _subcommentController,
                      maxLines: 3,
                      maxLength: 500,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Escribe tu respuesta...',
                        hintStyle: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        counterStyle: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () => Navigator.of(context).pop(),
                          text: 'Cancelar',
                          options: FFButtonOptions(
                            height: 48,
                            color: const Color(0xFF37474F),
                            textStyle: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: _subcommentController.text.trim().isEmpty 
                              ? null 
                              : () => _postSubcomment(postId, commentId, _subcommentController.text.trim(), userName, refreshCallback),
                          text: 'Responder',
                          options: FFButtonOptions(
                            height: 48,
                            color: _subcommentController.text.trim().isEmpty
                                ? const Color(0xFF4DD0E1).withValues(alpha: 0.7)
                                : const Color(0xFF4DD0E1),
                            textStyle: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 📝 PUBLICAR SUBCOMENTARIO
  Future<void> _postSubcomment(String postId, String commentId, String content, String originalUserName, [VoidCallback? refreshCallback]) async {
    try {
      // Mostrar modal de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4DD0E1).withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícono animado
                TweenAnimationBuilder<double>(
                  duration: const Duration(seconds: 2),
                  tween: Tween(begin: 0.5, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4DD0E1),
                              const Color(0xFF4DD0E1).withValues(alpha: 0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.reply,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  '💬 Respondiendo a $originalUserName...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Por favor espera...',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Barra de progreso
                Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF4DD0E1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Esperar 2 segundos
      await Future.delayed(const Duration(seconds: 2));

      // Publicar subcomentario
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      await Supabase.instance.client
          .from('travel_comment_replies')
          .insert({
            'comment_id': commentId,
            'user_id': user.id,
            'content': content,
          });

      // Cerrar modales
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar modal de carga
        Navigator.of(context).pop(); // Cerrar modal de subcomentario
      }

      // Recargar posts para actualizar
      await _loadPosts();
      
      // Refrescar modal de comentarios si está abierto
      if (refreshCallback != null) {
        refreshCallback();
      }

      // Limpiar el campo del subcomentario para evitar que quede texto previo
      _subcommentController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Respuesta publicada exitosamente'),
            backgroundColor: const Color(0xFF4DD0E1),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      print('❌ Error posting subcomment: $e');
      
      // Cerrar modales si están abiertos
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar modal de carga
        Navigator.of(context).pop(); // Cerrar modal de subcomentario
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar respuesta: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// 💬 MODAL DE CARGA AL COMENTAR
  void _showCommentingModal(String postOwnerName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4DD0E1).withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 💬 Icono animado de comentario
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return Transform.rotate(
                        angle: value * 2 * 3.14159,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4DD0E1),
                                const Color(0xFF4DD0E1).withValues(alpha: 0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chat_bubble,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      // Reiniciar animación
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 💬 Texto principal
                  Text(
                    '💬 Comentando la experiencia',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 🎯 Texto secundario
                  Text(
                    'de $postOwnerName...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF4DD0E1),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 🔄 Indicador de progreso elegante
                  SizedBox(
                    width: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: null, // Indeterminado
                        minHeight: 6,
                        backgroundColor: Color(0xFF2C2C2C),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4DD0E1),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 💬 Mensaje adicional
                  Text(
                    '🌎 Compartiendo tu opinión en LandGo Travel',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 💬 CREAR COMENTARIO
  Future<void> _postComment(String postId, String postOwnerName) async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe un comentario'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    // Mostrar modal de carga
    _showCommentingModal(postOwnerName);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Esperar 2 segundos para mostrar la animación
      await Future.delayed(const Duration(seconds: 2));

      // Crear comentario en la base de datos
      await Supabase.instance.client
          .from('travel_post_comments')
          .insert({
            'post_id': postId,
            'user_id': user.id,
            'content': _commentController.text.trim(),
          });

      // Limpiar input
      _commentController.clear();

      // Cerrar modal de carga
      Navigator.of(context).pop();

      // Cerrar modal de comentarios
      Navigator.of(context).pop();

      // Recargar posts para actualizar contadores
      await _loadPosts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Comentario publicado exitosamente!'),
            backgroundColor: Color(0xFF4DD0E1),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      print('❌ Error posting comment: $e');
      
      // Cerrar modal de carga
      Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al comentar: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// ❤️ MANEJAR ME GUSTA (LIKE/UNLIKE)
  Future<void> _toggleLike(String postId, bool currentLiked) async {
    try {
      print('🔄 Iniciando toggle like - PostId: $postId, CurrentLiked: $currentLiked');
      
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ Usuario no autenticado');
        return;
      }

      print('✅ Usuario autenticado: ${user.id}');

      // 🎯 ACTUALIZACIÓN OPTIMISTA - Actualizar UI primero
      setState(() {
        final postIndex = _posts.indexWhere((p) => p['id'] == postId);
        if (postIndex != -1) {
          _posts[postIndex]['user_liked'] = !currentLiked;
          _posts[postIndex]['likes_count'] = (currentLiked) 
            ? (_posts[postIndex]['likes_count'] ?? 1) - 1 
            : (_posts[postIndex]['likes_count'] ?? 0) + 1;
        }
      });

      if (currentLiked) {
        // Quitar like
        print('🗑️ Removiendo like...');
        await Supabase.instance.client
            .from('travel_post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', user.id);
        print('❤️ Like removido del post $postId');
      } else {
        // Agregar like
        print('➕ Agregando like...');
        await Supabase.instance.client
            .from('travel_post_likes')
            .insert({
              'post_id': postId,
              'user_id': user.id,
            });
        print('❤️ Like agregado al post $postId');
      }

      print('✅ Like actualizado exitosamente sin recargar posts');
      
    } catch (e) {
      print('❌ Error toggling like: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      
      // 🔄 REVERTIR cambios en caso de error
      setState(() {
        final postIndex = _posts.indexWhere((p) => p['id'] == postId);
        if (postIndex != -1) {
          _posts[postIndex]['user_liked'] = currentLiked;
          _posts[postIndex]['likes_count'] = (currentLiked) 
            ? (_posts[postIndex]['likes_count'] ?? 0) + 1 
            : (_posts[postIndex]['likes_count'] ?? 1) - 1;
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar me gusta: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// ✅ SELECCIONAR IMAGEN CON INDICADOR DE CARGA (Compatible Web y Móvil)
  Future<void> _pickImage([StateSetter? setModalState]) async {
    try {
      print('📸 DEBUG: Abriendo selector de imagen...');
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        print('📸 DEBUG: Imagen seleccionada: ${image.path}');
        
        // 🔄 Función helper para actualizar ambos estados
        void updateState(VoidCallback fn) {
          if (mounted) {
            setState(fn);
            setModalState?.call(fn);
          }
        }
        
        // 🔄 Activar indicador de carga
        updateState(() {
          _isLoadingImage = true;
          _selectedImage = null; // Limpiar imagen anterior
          _selectedImageBytes = null;
        });
        
        print('🔄 DEBUG: Indicador de carga activado');
        
        // 📸 Cargar la imagen según la plataforma
        if (kIsWeb) {
          // Para web: cargar como bytes
          final bytes = await image.readAsBytes();
          print('✅ DEBUG: Bytes cargados, tamaño: ${bytes.length}');
          
          // ⏱️ Simular tiempo de procesamiento realista
          await Future.delayed(const Duration(milliseconds: 800));
          
          updateState(() {
            _selectedImageBytes = bytes;
          });
          
          print('✅ DEBUG: Imagen asignada a _selectedImageBytes');
          
          // ⏱️ Tiempo adicional para mostrar que la imagen está lista
          await Future.delayed(const Duration(milliseconds: 300));
          
          updateState(() {
            _isLoadingImage = false;
          });
          
          print('✅ DEBUG: Imagen cargada como bytes para web - Loading finalizado');
        } else {
          // Para móvil: cargar como File
          final file = File(image.path);
          
          // ⏱️ Simular tiempo de procesamiento realista
          await Future.delayed(const Duration(milliseconds: 800));
          
          updateState(() {
            _selectedImage = file;
          });
          
          print('✅ DEBUG: Imagen asignada a _selectedImage');
          
          // ⏱️ Tiempo adicional para mostrar que la imagen está lista
          await Future.delayed(const Duration(milliseconds: 300));
          
          updateState(() {
            _isLoadingImage = false;
          });
          
          print('✅ DEBUG: Imagen cargada como File para móvil - Loading finalizado');
        }
        
        print('✅ DEBUG: Imagen cargada y mostrada en el modal');
      } else {
        print('❌ DEBUG: No se seleccionó ninguna imagen');
        if (mounted) {
        setState(() {
            _isLoadingImage = false;
          });
          setModalState?.call(() {
            _isLoadingImage = false;
        });
        }
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
        setModalState?.call(() {
          _isLoadingImage = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF000000), // FONDO NEGRO LANDGO
        appBar: AppBar(
          backgroundColor: const Color(0xFF000000),
          automaticallyImplyLeading: false,
          leading: null,
          title: null,
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF000000), // NEGRO LANDGO
                  Color(0xFF1A1A1A), // NEGRO SUAVE
                ],
              ),
            ),
            child: Column(
              children: [
                // Header personalizado
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          context.pop();
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Travel Feed',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Color(0xFF4DD0E1),
                          size: 24,
                        ),
                        onPressed: _loadPosts,
                      ),
                    ],
                  ),
                ),
                
                // Contenido principal
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4DD0E1),
                          ),
                        )
                      : _errorMessage.isNotEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  FFButtonWidget(
                                    onPressed: _loadPosts,
                                    text: 'Retry',
                                    options: FFButtonOptions(
                                      height: 40,
                                      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                      color: const Color(0xFF4DD0E1),
                                      textStyle: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      elevation: 3,
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _posts.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.travel_explore,
                                        color: Colors.white70,
                                        size: 64,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No posts yet',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Be the first to share your travel experience!',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _loadPosts,
                                  color: const Color(0xFF4DD0E1),
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _posts.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final post = _posts[index];
                                      return _buildPostCard(post);
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreatePostModal(),
          backgroundColor: const Color(0xFF4DD0E1),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  /// ✅ MOSTRAR MODAL PARA CREAR POST
  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Share Your Experience',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            const Divider(color: Colors.white24),
            
            // Content
            Expanded(
              child: _isCreatingPost 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFF4DD0E1),
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Creating your post...',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please wait while we upload your content',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Text input
                    TextField(
                      controller: _postController,
                      maxLines: 4,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Share your travel experience...',
                        hintStyle: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4DD0E1)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2C2C2C),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 🏷️ SECCIÓN DE ETIQUETADO DE USUARIOS
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header de etiquetado
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_add,
                                  color: Color(0xFF4DD0E1),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tag Friends',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                if (_selectedTags.isNotEmpty)
                                  Text(
                                    '${_selectedTags.length}',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF4DD0E1),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          // Campo de búsqueda
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _tagSearchController,
                              onChanged: (value) {
                                setModalState(() {});
                                _onTagSearchChanged();
                              },
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search users to tag...',
                                hintStyle: GoogleFonts.outfit(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF4DD0E1),
                                  size: 20,
                                ),
                                suffixIcon: _isSearchingTags
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF4DD0E1),
                                        ),
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.white24),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF4DD0E1)),
                                ),
                                filled: true,
                                fillColor: const Color(0xFF1A1A1A),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          
                          // Resultados de búsqueda
                          if (_tagSearchResults.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 150),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _tagSearchResults.length,
                                itemBuilder: (context, index) {
                                  final user = _tagSearchResults[index];
                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: const Color(0xFF4DD0E1),
                                      backgroundImage: user['avatar_url'] != null
                                          ? NetworkImage(user['avatar_url'])
                                          : null,
                                      child: user['avatar_url'] == null
                                          ? Text(
                                              (user['full_name'] ?? 'U')[0].toUpperCase(),
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                    title: Text(
                                      user['full_name'] ?? 'Usuario',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      user['email'] ?? '',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.add_circle_outline,
                                      color: Color(0xFF4DD0E1),
                                      size: 20,
                                    ),
                                    onTap: () {
                                      setModalState(() {
                                        _addTag(user);
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                          
                          // Usuarios etiquetados
                          if (_selectedTags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedTags.map((user) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4DD0E1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          user['full_name'] ?? 'Usuario',
                                          style: GoogleFonts.outfit(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () {
                                            setModalState(() {
                                              _removeTag(user);
                                            });
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.black,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 🔄 INDICADOR DE CARGA DE IMAGEN
                    if (_isLoadingImage) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFF2C2C2C),
                          border: Border.all(
                            color: const Color(0xFF4DD0E1),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Indicador de carga circular con animación
                            const SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                strokeWidth: 5,
                                color: Color(0xFF4DD0E1),
                                backgroundColor: Colors.white24,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Texto de carga principal
                            Text(
                              '🔄 Loading Image...',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Texto de carga secundario
                            Text(
                              'Processing your photo\nPlease wait...',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            
                            // Barra de progreso animada
                            Container(
                              width: 180,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const LinearProgressIndicator(
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Image preview - MOSTRAR CUANDO ESTÉ CARGADA
                    if (!_isLoadingImage && (_selectedImage != null || _selectedImageBytes != null)) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4DD0E1),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                              // Imagen de fondo (compatible web y móvil)
                              Positioned.fill(
                                child: kIsWeb
                                    ? (_selectedImageBytes != null
                                        ? Image.memory(
                                            _selectedImageBytes!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: const Color(0xFF2C2C2C),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 48,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: const Color(0xFF2C2C2C),
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.white70,
                                                size: 48,
                                              ),
                                            ),
                                          ))
                                    : (_selectedImage != null
                                        ? Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: const Color(0xFF2C2C2C),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 48,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: const Color(0xFF2C2C2C),
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.white70,
                                                size: 48,
                                              ),
                                            ),
                                          )),
                              ),
                              
                              // Overlay con información
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.image,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Imagen seleccionada',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Botón para eliminar imagen
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _selectedImage = null;
                                    _selectedImageBytes = null;
                                  });
                                  setState(() {
                                    _selectedImage = null;
                                    _selectedImageBytes = null;
                                  });
                                  print('🗑️ DEBUG: Imagen eliminada del preview');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Mensaje de confirmación
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4DD0E1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF4DD0E1),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Imagen lista para subir. Presiona "Post" para publicar.',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF4DD0E1),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: (_isCreatingPost || _isLoadingImage) ? null : () => _pickImage(setModalState),
                            text: _isLoadingImage 
                                ? 'Loading...' 
                                : ((_selectedImage != null || _selectedImageBytes != null) ? 'Change Photo' : 'Add Photo'),
                            icon: (_isCreatingPost || _isLoadingImage)
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white70,
                                    ),
                                  )
                                : Icon(
                                    (_selectedImage != null || _selectedImageBytes != null) ? Icons.swap_horiz : Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            options: FFButtonOptions(
                              height: 48,
                              color: (_isCreatingPost || _isLoadingImage)
                                  ? const Color(0xFF2C2C2C)
                                  : ((_selectedImage != null || _selectedImageBytes != null)
                                      ? const Color(0xFF4DD0E1) 
                                      : const Color(0xFF37474F)),
                              textStyle: GoogleFonts.outfit(
                                color: (_isCreatingPost || _isLoadingImage) ? Colors.white70 : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              borderSide: const BorderSide(
                                color: Colors.white24,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: (_isCreatingPost || _isLoadingImage) ? null : _createPost,
                            text: _isCreatingPost ? 'Posting...' : 'Post',
                            icon: _isCreatingPost 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                            options: FFButtonOptions(
                              height: 48,
                              color: (_isCreatingPost || _isLoadingImage)
                                  ? const Color(0xFF4DD0E1).withValues(alpha: 0.7)
                                  : const Color(0xFF4DD0E1),
                              textStyle: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
            ),
          ],
        ),
          );
        },
      ),
    );
  }

  /// 📤 COMPARTIR POST
  Future<void> _sharePost(Map<String, dynamic> post) async {
    try {
      final userName = post['profiles']?['full_name'] ?? 'Un viajero';
      final postContent = post['content'] ?? '';
      final taggedUsers = post['tagged_users'] as List<dynamic>? ?? [];
      
      // Construir texto de etiquetas si existen
      String tagsText = '';
      if (taggedUsers.isNotEmpty) {
        final validTags = taggedUsers.where((user) => 
          user != null && 
          user is Map && 
          user['full_name'] != null && 
          user['full_name'].toString().isNotEmpty
        ).toList();
        
        if (validTags.isNotEmpty) {
          if (validTags.length == 1) {
            tagsText = '\n📍 Con: ${validTags[0]['full_name']}';
          } else if (validTags.length == 2) {
            tagsText = '\n📍 Con: ${validTags[0]['full_name']} y ${validTags[1]['full_name']}';
          } else {
            tagsText = '\n📍 Con: ${validTags[0]['full_name']}, ${validTags[1]['full_name']} y ${validTags.length - 2} personas más';
          }
        }
      }
      
      // Texto promocional atractivo en inglés
      final shareText = '''
✈️ Discover this amazing travel experience shared by $userName!

$postContent$tagsText

━━━━━━━━━━━━━━━━━━━━━━
🌍 Ready for your next adventure?

With LandGo Travel, your travel dreams come true:
✅ Flights to the best destinations
✅ Luxury hotels at incredible prices
✅ Unique and unforgettable experiences
✅ Points and rewards system
🔥 UP TO 70% OFF on flights, hotels & more!

💎 Join our community of travelers and start exploring the world with us.

📱 Download the app or visit:
👉 www.landgotravel.com

🎁 Exclusive member benefits & discounts await you!

#LandGoTravel #TravelWithUs #UniqueExperiences #YourNextAdventure #TravelDeals #70PercentOff
''';

      await Share.share(
        shareText,
        subject: '✈️ Amazing Travel Experience - LandGo Travel',
      );
      
      print('✅ Post compartido exitosamente');
      
    } catch (e) {
      print('❌ Error compartiendo post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// ✅ CONSTRUIR TARJETA DE POST
  Widget _buildPostCard(Map<String, dynamic> post) {
    final user = post['profiles'];
    final userName = user?['full_name'] ?? user?['first_name'] ?? 'Usuario';
    final userAvatar = user?['avatar_url'];
    final content = post['content'] ?? '';
    final imageUrl = post['image_url'];
    final createdAt = post['created_at']?.toString() ?? '';
    
    // Datos de likes y comentarios
    final likesCount = post['likes_count'] ?? 0;
    final userLiked = post['user_liked'] ?? false;
    final commentsCount = post['comments_count'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF37474F).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del post
          Row(
            children: [
              // Avatar del usuario
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF4DD0E1),
                backgroundImage: userAvatar != null 
                    ? NetworkImage(userAvatar)
                    : null,
                child: userAvatar == null 
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(createdAt),
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    // 🏷️ Etiquetas de usuarios - DESPUÉS DEL NOMBRE
                    if (post['tagged_users'] != null && (post['tagged_users'] as List).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _generateTagsText(post['tagged_users']),
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF4DD0E1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // ⚙️ Menú de opciones (solo para posts del usuario actual)
              Builder(
                builder: (context) {
                  final currentUser = Supabase.instance.client.auth.currentUser;
                  final isOwner = currentUser != null && post['user_id'] == currentUser.id;
                  
                  if (!isOwner) {
                    return const SizedBox.shrink(); // No mostrar si no es el dueño
                  }
                  
                  return PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white70,
                  size: 20,
                ),
                    color: const Color(0xFF2C2C2C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editPost(post);
                      } else if (value == 'delete') {
                        _deletePost(post['id']);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.edit,
                              color: Color(0xFF4DD0E1),
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Editar',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete,
                              color: Color(0xFFDC2626),
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Eliminar',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFDC2626),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Contenido del post
          if (content.isNotEmpty)
            Text(
              content,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          
          // Imagen del post
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Acciones del post
          Row(
            children: [
              // ❤️ Botón de Me Gusta con contador
          Row(
            children: [
              IconButton(
                    icon: Icon(
                      userLiked ? Icons.favorite : Icons.favorite_border,
                      color: userLiked ? const Color(0xFF4DD0E1) : Colors.white70,
                      size: 24,
                    ),
                    onPressed: () {
                      try {
                        final postId = post['id']?.toString();
                        if (postId != null && postId.isNotEmpty) {
                          _toggleLike(postId, userLiked);
                        } else {
                          print('❌ Post ID inválido: ${post['id']}');
                        }
                      } catch (e) {
                        print('❌ Error en botón like: $e');
                      }
                    },
                  ),
                  if (likesCount > 0)
                    Text(
                      '$likesCount',
                      style: GoogleFonts.outfit(
                        color: userLiked ? const Color(0xFF4DD0E1) : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              
              // 💬 Botón de Comentarios con contador
              Row(
                children: [
              IconButton(
                icon: const Icon(
                  Icons.comment_outlined,
                  color: Colors.white70,
                      size: 24,
                    ),
                    onPressed: () => _showCommentsModal(post),
                  ),
                  if (commentsCount > 0)
                    Text(
                      '$commentsCount',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.share,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () => _sharePost(post),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.bookmark_border,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ FORMATEAR FECHA
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }
}
