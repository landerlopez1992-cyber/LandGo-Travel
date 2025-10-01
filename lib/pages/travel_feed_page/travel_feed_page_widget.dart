import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'travel_feed_page_model.dart';
export 'travel_feed_page_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  // Variables para el modal de crear post
  bool _isCreatingPost = false;

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
    super.dispose();
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
      
      // Obtener posts con información del usuario
      final postsResponse = await Supabase.instance.client
          .from('travel_posts')
          .select('''
            *,
            profiles!travel_posts_user_id_fkey(
              full_name,
              avatar_url,
              first_name,
              last_name
            )
          ''')
          .order('created_at', ascending: false);
      
      List<Map<String, dynamic>> posts = List<Map<String, dynamic>>.from(postsResponse);
      
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
    if (_postController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some text or an image to your post'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    // Activar estado de carga
    if (mounted) {
      setState(() {
        _isCreatingPost = true;
      });
    }

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
      if (_selectedImage != null) {
        print('📤 DEBUG: Subiendo imagen a Supabase Storage...');
        
        final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        // Subir archivo a Supabase Storage
        final uploadResponse = await Supabase.instance.client.storage
            .from('travel-images')
            .upload(fileName, _selectedImage!);
        
        print('📤 DEBUG: Upload response: $uploadResponse');
        
        if (uploadResponse.isNotEmpty) {
          // Obtener URL pública de la imagen
          imageUrl = Supabase.instance.client.storage
              .from('travel-images')
              .getPublicUrl(fileName);
          
          print('✅ DEBUG: Imagen subida exitosamente: $imageUrl');
        } else {
          print('❌ DEBUG: Error subiendo imagen');
          throw Exception('Failed to upload image');
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
      } catch (insertError) {
        print('❌ DEBUG: Error insertando post: $insertError');
        print('❌ DEBUG: Error type: ${insertError.runtimeType}');
        print('❌ DEBUG: Error details: ${insertError.toString()}');
        throw insertError; // Re-lanzar el error para que se maneje arriba
      }

      // Limpiar formulario
      _postController.clear();
      _selectedImage = null;
      
      // Recargar posts
      await _loadPosts();
      
      if (mounted) {
        setState(() {
          _isCreatingPost = false;
        });
        
        // Cerrar modal
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
      
    } catch (e) {
      print('❌ Error creating post: $e');
      if (mounted) {
        setState(() {
          _isCreatingPost = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating post: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  /// ✅ SELECCIONAR IMAGEN
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('❌ Error picking image: $e');
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
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                  : Padding(
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
                    
                    // Image preview
                    if (_selectedImage != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: FFButtonWidget(
                            onPressed: _isCreatingPost ? null : _pickImage,
                            text: 'Add Photo',
                            icon: _isCreatingPost 
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white70,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                            options: FFButtonOptions(
                              height: 48,
                              color: _isCreatingPost 
                                  ? const Color(0xFF2C2C2C)
                                  : const Color(0xFF37474F),
                              textStyle: GoogleFonts.outfit(
                                color: _isCreatingPost ? Colors.white70 : Colors.white,
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
                            onPressed: _isCreatingPost ? null : _createPost,
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
                              color: _isCreatingPost 
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
          ],
        ),
      ),
    );
  }

  /// ✅ CONSTRUIR TARJETA DE POST
  Widget _buildPostCard(Map<String, dynamic> post) {
    final user = post['profiles'];
    final userName = user?['full_name'] ?? user?['first_name'] ?? 'Usuario';
    final userAvatar = user?['avatar_url'];
    final content = post['content'] ?? '';
    final imageUrl = post['image_url'];
    final createdAt = post['created_at']?.toString() ?? '';
    
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
                  ],
                ),
              ),
              
              // Botón de opciones
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () {},
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
              IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.comment_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.share,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () {},
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
