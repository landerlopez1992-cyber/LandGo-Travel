import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import '/components/login_required_modal.dart';
import '/backend/supabase/supabase.dart';
import 'my_profile_page_model.dart';
export 'my_profile_page_model.dart';

class MyProfilePageWidget extends StatefulWidget {
  const MyProfilePageWidget({super.key});

  static const String routeName = 'MyProfilePage';
  static const String routePath = '/myProfilePage';

  @override
  State<MyProfilePageWidget> createState() => _MyProfilePageWidgetState();
}

class _MyProfilePageWidgetState extends State<MyProfilePageWidget> {
  late MyProfilePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Variables para datos del usuario
  String _userName = 'User Name';
  String _userEmail = 'user@example.com';
  String? _userAvatarUrl;
  
  // Variables para datos financieros
  double _accountBalance = 0.0;
  int _points = 0;
  double _cashback = 0.0;
  bool _isLoadingFinancialData = false;
  
  // Variables para modo de edición
  bool _isEditMode = false;
  bool _hasChanges = false;
  String _tempFullName = '';
  String _tempEmail = '';
  String _tempPhone = '';
  String _tempDateOfBirth = '';
  String _tempMembership = '';
  
  // Valores reales del usuario para comparación
  String _realPhone = '+1 (555) 123-4567';
  String _realDateOfBirth = 'January 15, 1990';
  String _realMembership = 'Premium Member';
  
  // Variables para carga de imagen
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;
  bool _isSavingChanges = false; // NUEVO: Estado de carga para guardar cambios
  
  // Variables para selector de país
  String _selectedCountryCode = '+1';
  String _selectedCountryName = 'United States';
  
  // Variables para verificación de email
  bool _isEmailVerificationRequired = false;
  String _pendingChanges = ''; // JSON string de los cambios pendientes

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyProfilePageModel());
    _loadUserData();
    _loadFinancialData();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }


  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Método para cargar datos del usuario desde Supabase
  Future<void> _loadUserData() async {
    try {
      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser != null) {
        print('Current user ID: ${currentUser.id}');
        print('Current user email: ${currentUser.email}');
        
        // Usuario logueado
        
        // Primero verificar si existe el perfil
        final existingProfile = await SupaFlow.client
            .from('profiles')
            .select('id, full_name, email, avatar_url, phone, date_of_birth, membership_type')
            .eq('id', currentUser.id)
            .maybeSingle();
            
        print('Existing profile: $existingProfile');
        
        // Si no existe el perfil, crearlo
        if (existingProfile == null) {
          print('Creating new profile for user');
          await SupaFlow.client
              .from('profiles')
              .insert({
                'id': currentUser.id,
                'email': currentUser.email,
                'full_name': 'Juan José Pérez', // Nombre completo por defecto
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              });
        } else if (existingProfile['full_name'] == null || 
                   existingProfile['full_name'] == '' || 
                   existingProfile['full_name'] == 'User Name') {
          // Si existe pero no tiene nombre completo, actualizarlo
          print('Updating existing profile with full name');
          await SupaFlow.client
              .from('profiles')
              .update({
                'full_name': 'Juan José Pérez',
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', currentUser.id);
        }
        
        // Obtener datos del usuario desde la tabla profiles
        final response = await SupaFlow.client
            .from('profiles')
            .select('full_name, email, avatar_url, phone, date_of_birth, membership_type')
            .eq('id', currentUser.id)
            .single();
            
        print('Profile data from Supabase: $response');

        setState(() {
          // Usar full_name si existe y no está vacío, sino usar email como nombre
          final fullName = response['full_name'];
          print('Full name from database: "$fullName"');
          
          if (fullName != null && fullName.isNotEmpty && fullName.trim() != '') {
            _userName = fullName;
            print('Using full_name: $_userName');
          } else {
            // Si no hay full_name, usar el email como nombre
            final email = currentUser.email ?? 'user@example.com';
            _userName = email.split('@')[0]; // Tomar la parte antes del @
            print('Using email part as name: $_userName');
          }
          
          _userEmail = response['email'] ?? currentUser.email ?? 'user@example.com';
          _userAvatarUrl = response['avatar_url'];
          
          // Cargar teléfono real del usuario
          final phoneFromDB = response['phone'];
          if (phoneFromDB != null && phoneFromDB.isNotEmpty && phoneFromDB.trim() != '') {
            _realPhone = phoneFromDB;
            print('Phone from database: $_realPhone');
          } else {
            _realPhone = '+1 (555) 123-4567'; // Valor por defecto
            print('Using default phone: $_realPhone');
          }
          
          // Cargar fecha de nacimiento real
          final dateOfBirthFromDB = response['date_of_birth'];
          if (dateOfBirthFromDB != null && dateOfBirthFromDB.isNotEmpty && dateOfBirthFromDB.trim() != '') {
            _realDateOfBirth = dateOfBirthFromDB;
            print('Date of birth from database: $_realDateOfBirth');
          } else {
            _realDateOfBirth = 'January 15, 1990'; // Valor por defecto
            print('Using default date of birth: $_realDateOfBirth');
          }
          
          // Cargar membresía real
          final membershipFromDB = response['membership_type'];
          if (membershipFromDB != null && membershipFromDB.isNotEmpty && membershipFromDB.trim() != '') {
            _realMembership = membershipFromDB;
            print('Membership from database: $_realMembership');
          } else {
            _realMembership = 'Premium Member'; // Valor por defecto
            print('Using default membership: $_realMembership');
          }
          
          print('Final user name: $_userName');
          print('Final user email: $_userEmail');
          print('Final user avatar: $_userAvatarUrl');
          print('Final user phone: $_realPhone');
          print('Final user date of birth: $_realDateOfBirth');
          print('Final user membership: $_realMembership');
        });
      } else {
        // Usuario invitado
        setState(() {
          _userName = 'Guest User';
          _userEmail = 'guest@landgotravel.com';
          _userAvatarUrl = null;
          _realPhone = '+1 (555) 123-4567';
          _realDateOfBirth = 'January 15, 1990';
          _realMembership = 'Premium Member';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      // En caso de error, verificar si hay usuario autenticado
      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser != null) {
        setState(() {
          // Usar email como nombre si no hay datos en profiles
          final email = currentUser.email ?? 'user@example.com';
          _userName = email.split('@')[0]; // Tomar la parte antes del @
          _userEmail = email;
          _realPhone = '+1 (555) 123-4567';
          _realDateOfBirth = 'January 15, 1990';
          _realMembership = 'Premium Member';
        });
      }
    }
  }

  // Método para cargar datos financieros del usuario
  Future<void> _loadFinancialData() async {
    try {
      setState(() {
        _isLoadingFinancialData = true;
      });

      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser == null) {
        print('No user logged in for financial data');
        return;
      }

      print('Loading financial data for user: ${currentUser.id}');

      // Cargar datos de la tabla user_wallets
      final walletResponse = await SupaFlow.client
          .from('user_wallets')
          .select('balance, points, cashback')
          .eq('user_id', currentUser.id)
          .maybeSingle();

      print('Wallet data: $walletResponse');

      if (walletResponse != null) {
        setState(() {
          _accountBalance = (walletResponse['balance'] ?? 0.0).toDouble();
          _points = walletResponse['points'] ?? 0;
          _cashback = (walletResponse['cashback'] ?? 0.0).toDouble();
        });
        print('Financial data loaded: Balance=$_accountBalance, Points=$_points, Cashback=$_cashback');
      } else {
        // Si no existe wallet, crear uno por defecto
        print('Creating default wallet for user');
        await SupaFlow.client
            .from('user_wallets')
            .insert({
              'user_id': currentUser.id,
              'balance': 0.0,
              'points': 0,
              'cashback': 0.0,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });

        setState(() {
          _accountBalance = 0.0;
          _points = 0;
          _cashback = 0.0;
        });
        print('Default wallet created with zero values');
      }
    } catch (e) {
      print('Error loading financial data: $e');
      // En caso de error, mantener valores por defecto
      setState(() {
        _accountBalance = 0.0;
        _points = 0;
        _cashback = 0.0;
      });
    } finally {
      setState(() {
        _isLoadingFinancialData = false;
      });
    }
  }

  // Método para activar modo de edición
  void _toggleEditMode() {
    // Verificar si el usuario está logueado
    final currentUser = SupaFlow.client.auth.currentUser;
    if (currentUser == null) {
      // Usuario no logueado - mostrar modal de login
      _showLoginRequiredModal();
      return;
    }

    if (_isEditMode) {
      // Si está en modo edición, solo guardar si hay cambios
      if (_hasChanges) {
        _saveChanges();
      } else {
        // Si no hay cambios, solo salir del modo edición
        setState(() {
          _isEditMode = false;
          _hasChanges = false;
        });
      }
    } else {
      // Si no está en modo edición, activarlo
      setState(() {
        _isEditMode = true;
        _hasChanges = false;
        _tempFullName = _userName;
        _tempEmail = _userEmail;
        _tempPhone = _realPhone; // Usar valor real del usuario
        _tempDateOfBirth = _realDateOfBirth; // Usar valor real del usuario
        _tempMembership = _realMembership; // Usar valor real del usuario
      });
    }
  }

  // Método para mostrar modal de login requerido
  void _showLoginRequiredModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoginRequiredModal();
      },
    );
  }

  // Método para guardar cambios
  Future<void> _saveChanges() async {
    // Verificar si se requiere verificación de email
    if (!_isEmailVerificationRequired) {
      _showEmailVerificationModal();
      return;
    }

    // Activar indicador de carga
    setState(() {
      _isSavingChanges = true;
    });

    try {
      // Mínimo 2 segundos de carga para dar sensación de procesamiento
      final stopwatch = Stopwatch()..start();
      
      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser != null) {
        // Actualizar perfil en Supabase
        print('🔍 DEBUG: Guardando datos en Supabase:');
        print('  - full_name: $_tempFullName');
        print('  - phone: $_tempPhone');
        print('  - date_of_birth: $_tempDateOfBirth');
        
        final updateData = {
          'full_name': _tempFullName,
          'phone': _tempPhone,
          'date_of_birth': _tempDateOfBirth,
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        print('🔍 DEBUG: Datos a actualizar: $updateData');
        print('🔍 DEBUG: User ID: ${currentUser.id}');
        
        final response = await SupaFlow.client
            .from('profiles')
            .update(updateData)
            .eq('id', currentUser.id)
            .select();
            
        print('🔍 DEBUG: Respuesta de Supabase: $response');
        
        // Verificar que se actualizó correctamente
        if (response.isNotEmpty) {
          print('🔍 DEBUG: Perfil actualizado exitosamente');
          print('🔍 DEBUG: Datos actualizados: ${response.first}');
        } else {
          print('🔍 DEBUG: ERROR: No se encontró el perfil para actualizar');
        }

        // Esperar hasta completar mínimo 2 segundos
        final elapsed = stopwatch.elapsedMilliseconds;
        if (elapsed < 2000) {
          await Future.delayed(Duration(milliseconds: 2000 - elapsed));
        }

        // Actualizar estado local
        setState(() {
          _userName = _tempFullName;
          _userEmail = _tempEmail;
          _realPhone = _tempPhone; // Actualizar valor real del teléfono
          _realDateOfBirth = _tempDateOfBirth; // Actualizar valor real de fecha
          _realMembership = _tempMembership; // Actualizar valor real de membresía
          _isEditMode = false;
          _hasChanges = false;
          _isSavingChanges = false; // Desactivar indicador de carga
        });

        _showSuccessSnackBar('Profile updated successfully!');
        print('Profile updated successfully');
      }
    } catch (e) {
      print('Error updating profile: $e');
      _showErrorSnackBar('Error updating profile');
      
      // Desactivar indicador de carga en caso de error
      setState(() {
        _isSavingChanges = false;
      });
    }
  }


  // Método para detectar cambios
  void _onFieldChanged() {
    // Solo detectar cambios en campos editables (excluir email y membership)
    bool hasChanges = _tempFullName != _userName || 
                     _tempPhone != _realPhone ||
                     _tempDateOfBirth != _realDateOfBirth;
    
    print('🔍 DEBUG: Detección de cambios:');
    print('  - _tempFullName: "$_tempFullName" vs _userName: "$_userName"');
    print('  - _tempPhone: "$_tempPhone" vs _realPhone: "$_realPhone"');
    print('  - _tempDateOfBirth: "$_tempDateOfBirth" vs _realDateOfBirth: "$_realDateOfBirth"');
    print('  - hasChanges: $hasChanges, _hasChanges: $_hasChanges');
    
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
      print('🔍 DEBUG: _hasChanges actualizado a: $_hasChanges');
    }
  }

  // Método para seleccionar y subir imagen de perfil
  Future<void> _pickAndUploadImage() async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      // Mostrar opciones de selección
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF2C2C2C),
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Profile Photo',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Camera option
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await _selectImageWithRetry(ImageSource.camera);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4DD0E1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Camera',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Gallery option
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await _selectImageWithRetry(ImageSource.gallery);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4DD0E1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.photo_library,
                              color: Colors.black,
                              size: 30,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gallery',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print('Error showing image picker: $e');
      _showErrorSnackBar('Error opening image picker');
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  // Método con reintentos para seleccionar imagen
  Future<void> _selectImageWithRetry(ImageSource source) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        print('Attempt ${retryCount + 1} to select image from ${source.name}');
        await _selectImage(source);
        return; // Éxito, salir del bucle
      } catch (e) {
        retryCount++;
        print('Attempt $retryCount failed: $e');
        
        if (retryCount >= maxRetries) {
          _showErrorSnackBar('Failed to select image after $maxRetries attempts');
          return;
        }
        
        // Esperar un poco antes del siguiente intento
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  // Método para seleccionar imagen
  Future<void> _selectImage(ImageSource source) async {
    try {
      print('Starting image selection from ${source.name}');
      
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        print('Image selected: ${image.path}');
        await _uploadImageToSupabase(File(image.path));
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error selecting image: $e');
      _showErrorSnackBar('Error selecting image: ${e.toString()}');
    }
  }

  // Método para subir imagen a Supabase
  Future<void> _uploadImageToSupabase(File imageFile) async {
    try {
      setState(() {
        _isUploadingImage = true;
      });

      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser == null) {
        _showErrorSnackBar('User not logged in');
        return;
      }

      // Crear nombre único para la imagen
      final fileName = 'profile_${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Subir imagen a Supabase Storage
      final uploadResponse = await SupaFlow.client.storage
          .from('profile-images')
          .uploadBinary(
            fileName,
            await imageFile.readAsBytes(),
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      if (uploadResponse.isNotEmpty) {
        // Obtener URL pública de la imagen
        final publicUrl = SupaFlow.client.storage
            .from('profile-images')
            .getPublicUrl(fileName);

        // Actualizar el perfil del usuario con la nueva URL
        await SupaFlow.client
            .from('profiles')
            .update({
              'avatar_url': publicUrl,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', currentUser.id);

        // Actualizar el estado local
        setState(() {
          _userAvatarUrl = publicUrl;
        });

        _showSuccessSnackBar('Profile photo updated successfully!');
        print('Image uploaded successfully: $publicUrl');
      } else {
        _showErrorSnackBar('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
      _showErrorSnackBar('Error uploading image: ${e.toString()}');
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  // 🎉 MÉTODO PARA MOSTRAR MODAL DE ÉXITO
  void _showSuccessSnackBar(String message) {
    _showSuccessModal(message);
  }

  // ❌ MÉTODO PARA MOSTRAR MODAL DE ERROR
  void _showErrorSnackBar(String message) {
    _showErrorModal(message);
  }

  // 🎉 MODAL DE ÉXITO PROFESIONAL
  void _showSuccessModal(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                // ICONO DE ÉXITO
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA), // TURQUESA CLARO
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4DD0E1), // TURQUESA LANDGO
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // TÍTULO
                Text(
                  'Success!',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                // MENSAJE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // BOTÓN
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DD0E1), // TURQUESA LANDGO
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Continue',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔐 MODAL DE VERIFICACIÓN DE EMAIL REQUERIDA
  void _showEmailVerificationModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16), // Reducido para más ancho
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Más redondeado
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 32), // Más espacio arriba
                // ICONO DE SEGURIDAD - MÁS GRANDE
                Container(
                  width: 80, // Agrandado de 60 a 80
                  height: 80, // Agrandado de 60 a 80
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD), // AZUL CLARO
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 50, // Agrandado de 40 a 50
                      height: 50, // Agrandado de 40 a 50
                      decoration: const BoxDecoration(
                        color: Color(0xFF2196F3), // AZUL LANDGO
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Colors.white,
                        size: 30, // Agrandado de 24 a 30
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24), // Más espacio
                // TÍTULO - MÁS GRANDE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24), // Más padding
                  child: Text(
                    'Email verification required',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: 22, // Agrandado de 18 a 22
                      fontWeight: FontWeight.w700, // Más bold
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Más espacio
                // MENSAJE - MÁS GRANDE Y LEGIBLE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24), // Más padding
                  child: Text(
                    'We need to verify your identity before saving changes to your personal information.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.black87,
                      fontSize: 16, // Agrandado de 14 a 16
                      fontWeight: FontWeight.w500, // Más bold
                      height: 1.4, // Mejor interlineado
                    ),
                  ),
                ),
                const SizedBox(height: 32), // Más espacio
                // BOTONES - MÁS GRANDES Y VISIBLES
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32), // Más padding
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16), // Más alto
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Más redondeado
                              side: const BorderSide(
                                color: Colors.grey,
                                width: 1.5, // Más grueso
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 16, // Agrandado de 14 a 16
                              fontWeight: FontWeight.w600, // Más bold
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16), // Más espacio entre botones
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _sendVerificationEmail();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DD0E1), // TURQUESA LANDGO
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Más redondeado
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16), // Más alto
                            elevation: 2, // Sombra sutil
                          ),
                          child: Text(
                            'Send Code',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16, // Agrandado de 14 a 16
                              fontWeight: FontWeight.w700, // Más bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 📧 ENVIAR EMAIL DE VERIFICACIÓN
  Future<void> _sendVerificationEmail() async {
    try {

      // Guardar cambios pendientes
      final pendingChanges = {
        'full_name': _tempFullName,
        'phone': _tempPhone,
        'date_of_birth': _tempDateOfBirth,
      };
      _pendingChanges = jsonEncode(pendingChanges);

      // Enviar email de verificación usando Supabase Edge Function
      print('🔍 DEBUG: Sending verification email with data:');
      print('  - email: $_userEmail');
      print('  - type: profile_update');
      print('  - changes: $pendingChanges');
      
      final response = await SupaFlow.client.functions.invoke(
        'send-verification-code',
        body: {
          'email': _userEmail,
          'type': 'profile_update',
          'changes': pendingChanges,
        },
      );

      print('🔍 DEBUG: Email verification response: $response');

      // Navegar a la pantalla de verificación de código
      if (mounted) {
        final result = await context.pushNamed(
          'VerificationCodePage',
          queryParameters: {
            'email': _userEmail,
            'type': 'profile_update',
            'pendingChanges': _pendingChanges,
          },
        );
        
        // Si regresó con éxito (true), salir del modo edición
        if (result == true && mounted) {
          print('🔍 DEBUG: Verificación exitosa, saliendo del modo edición');
          setState(() {
            _isEditMode = false;
            _hasChanges = false;
            _isSavingChanges = false;
            _isEmailVerificationRequired = false;
            _pendingChanges = '';
          });
          await _loadUserData(); // Recargar datos actualizados
        }
      }
    } catch (e) {
      print('Error sending verification email: $e');
      _showErrorSnackBar('Error sending verification email. Please try again.');
    }
  }

  // ❌ MODAL DE ERROR PROFESIONAL
  void _showErrorModal(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                // ICONO DE ERROR
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE), // ROJO CLARO
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626), // ROJO LANDGO
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // TÍTULO
                Text(
                  'Error!',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                // MENSAJE
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // BOTÓN
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626), // ROJO LANDGO
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🌍 SELECTOR DE PAÍS PARA TELÉFONO
  void _showCountrySelectorDialog() {
    final countries = [
      // América del Norte
      {'code': '+1', 'name': 'United States', 'flag': '🇺🇸'},
      {'code': '+1', 'name': 'Canada', 'flag': '🇨🇦'},
      // América Latina
      {'code': '+52', 'name': 'Mexico', 'flag': '🇲🇽'},
      {'code': '+53', 'name': 'Cuba', 'flag': '🇨🇺'},
      {'code': '+54', 'name': 'Argentina', 'flag': '🇦🇷'},
      {'code': '+55', 'name': 'Brazil', 'flag': '🇧🇷'},
      {'code': '+56', 'name': 'Chile', 'flag': '🇨🇱'},
      {'code': '+57', 'name': 'Colombia', 'flag': '🇨🇴'},
      {'code': '+58', 'name': 'Venezuela', 'flag': '🇻🇪'},
      {'code': '+51', 'name': 'Peru', 'flag': '🇵🇪'},
      {'code': '+593', 'name': 'Ecuador', 'flag': '🇪🇨'},
      {'code': '+502', 'name': 'Guatemala', 'flag': '🇬🇹'},
      {'code': '+503', 'name': 'El Salvador', 'flag': '🇸🇻'},
      {'code': '+504', 'name': 'Honduras', 'flag': '🇭🇳'},
      {'code': '+505', 'name': 'Nicaragua', 'flag': '🇳🇮'},
      {'code': '+506', 'name': 'Costa Rica', 'flag': '🇨🇷'},
      {'code': '+507', 'name': 'Panama', 'flag': '🇵🇦'},
      {'code': '+1-787', 'name': 'Puerto Rico', 'flag': '🇵🇷'},
      {'code': '+1-809', 'name': 'Dominican Republic', 'flag': '🇩🇴'},
      {'code': '+591', 'name': 'Bolivia', 'flag': '🇧🇴'},
      {'code': '+595', 'name': 'Paraguay', 'flag': '🇵🇾'},
      {'code': '+598', 'name': 'Uruguay', 'flag': '🇺🇾'},
      // Europa
      {'code': '+34', 'name': 'Spain', 'flag': '🇪🇸'},
      {'code': '+44', 'name': 'United Kingdom', 'flag': '🇬🇧'},
      {'code': '+33', 'name': 'France', 'flag': '🇫🇷'},
      {'code': '+49', 'name': 'Germany', 'flag': '🇩🇪'},
      {'code': '+39', 'name': 'Italy', 'flag': '🇮🇹'},
      {'code': '+351', 'name': 'Portugal', 'flag': '🇵🇹'},
      {'code': '+31', 'name': 'Netherlands', 'flag': '🇳🇱'},
      {'code': '+32', 'name': 'Belgium', 'flag': '🇧🇪'},
      {'code': '+41', 'name': 'Switzerland', 'flag': '🇨🇭'},
      {'code': '+43', 'name': 'Austria', 'flag': '🇦🇹'},
      {'code': '+46', 'name': 'Sweden', 'flag': '🇸🇪'},
      {'code': '+47', 'name': 'Norway', 'flag': '🇳🇴'},
      {'code': '+45', 'name': 'Denmark', 'flag': '🇩🇰'},
      {'code': '+358', 'name': 'Finland', 'flag': '🇫🇮'},
      {'code': '+7', 'name': 'Russia', 'flag': '🇷🇺'},
      {'code': '+48', 'name': 'Poland', 'flag': '🇵🇱'},
      {'code': '+30', 'name': 'Greece', 'flag': '🇬🇷'},
      // Asia
      {'code': '+86', 'name': 'China', 'flag': '🇨🇳'},
      {'code': '+81', 'name': 'Japan', 'flag': '🇯🇵'},
      {'code': '+82', 'name': 'South Korea', 'flag': '🇰🇷'},
      {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
      {'code': '+62', 'name': 'Indonesia', 'flag': '🇮🇩'},
      {'code': '+63', 'name': 'Philippines', 'flag': '🇵🇭'},
      {'code': '+65', 'name': 'Singapore', 'flag': '🇸🇬'},
      {'code': '+66', 'name': 'Thailand', 'flag': '🇹🇭'},
      {'code': '+84', 'name': 'Vietnam', 'flag': '🇻🇳'},
      {'code': '+60', 'name': 'Malaysia', 'flag': '🇲🇾'},
      {'code': '+92', 'name': 'Pakistan', 'flag': '🇵🇰'},
      {'code': '+880', 'name': 'Bangladesh', 'flag': '🇧🇩'},
      // Medio Oriente
      {'code': '+971', 'name': 'United Arab Emirates', 'flag': '🇦🇪'},
      {'code': '+966', 'name': 'Saudi Arabia', 'flag': '🇸🇦'},
      {'code': '+972', 'name': 'Israel', 'flag': '🇮🇱'},
      {'code': '+90', 'name': 'Turkey', 'flag': '🇹🇷'},
      // África
      {'code': '+27', 'name': 'South Africa', 'flag': '🇿🇦'},
      {'code': '+20', 'name': 'Egypt', 'flag': '🇪🇬'},
      {'code': '+234', 'name': 'Nigeria', 'flag': '🇳🇬'},
      {'code': '+254', 'name': 'Kenya', 'flag': '🇰🇪'},
      // Oceanía
      {'code': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
      {'code': '+64', 'name': 'New Zealand', 'flag': '🇳🇿'},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setState) {
            // Filtrar países según búsqueda
            final filteredCountries = countries.where((country) {
              final name = country['name']!.toLowerCase();
              final code = country['code']!.toLowerCase();
              final query = searchQuery.toLowerCase();
              return name.contains(query) || code.contains(query);
            }).toList();

            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C2C),
              title: Text(
                'Select Country',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // Barra de búsqueda
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search country...',
                        hintStyle: GoogleFonts.outfit(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF4DD0E1)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Lista de países
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = filteredCountries[index];
                          final isSelected = country['code'] == _selectedCountryCode && 
                                           country['name'] == _selectedCountryName;
                
                          return ListTile(
                            leading: Text(
                              country['flag']!,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(
                              country['name']!,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              country['code']!,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF4DD0E1),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: isSelected,
                            selectedTileColor: const Color(0xFF4DD0E1).withOpacity(0.1),
                            onTap: () {
                              // Actualizar el estado del padre
                              this.setState(() {
                                _selectedCountryCode = country['code']!;
                                _selectedCountryName = country['name']!;
                              });
                              Navigator.of(context).pop();
                              _showPhoneInputDialog();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 📞 DIÁLOGO PARA INGRESAR NÚMERO TELEFÓNICO
  void _showPhoneInputDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: Text(
            'Enter Phone Number',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Country: $_selectedCountryName ($_selectedCountryCode)',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF4DD0E1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter phone number',
                  hintStyle: GoogleFonts.outfit(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4DD0E1),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4DD0E1),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4DD0E1),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final phoneNumber = controller.text.trim();
                print('🔍 DEBUG: Botón Save presionado');
                print('🔍 DEBUG: Número ingresado: "$phoneNumber"');
                print('🔍 DEBUG: País seleccionado: $_selectedCountryName ($_selectedCountryCode)');
                
                if (phoneNumber.isNotEmpty) {
                  final formattedPhone = _formatPhoneWithCountryCode(phoneNumber);
                  print('🔍 DEBUG: Teléfono formateado: "$formattedPhone"');
                  _updateFieldValue('phone', formattedPhone);
                  Navigator.of(context).pop();
                  print('🔍 DEBUG: Diálogo cerrado, valor actualizado');
                } else {
                  print('🔍 DEBUG: ERROR: Número vacío');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DD0E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Save',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 📞 FORMATEAR TELÉFONO CON CÓDIGO DE PAÍS SELECCIONADO
  String _formatPhoneWithCountryCode(String phoneNumber) {
    // Remover todos los caracteres no numéricos
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    print('🔍 DEBUG: Formateando teléfono con país:');
    print('  - País seleccionado: $_selectedCountryName ($_selectedCountryCode)');
    print('  - Número ingresado: $phoneNumber');
    print('  - Solo dígitos: $digitsOnly');
    
    if (_selectedCountryCode == '+1') {
      // Formato USA/Canadá
      if (digitsOnly.length == 10) {
        String areaCode = digitsOnly.substring(0, 3);
        String exchange = digitsOnly.substring(3, 6);
        String number = digitsOnly.substring(6, 10);
        return '+1 ($areaCode) $exchange-$number';
      }
    } else {
      // Formato internacional
      return '$_selectedCountryCode $digitsOnly';
    }
    
    return '$_selectedCountryCode $digitsOnly';
  }

  // 📅 MÉTODO PARA MOSTRAR CALENDARIO PROFESIONAL
  void _showDatePickerDialog() async {
    // Calcular fechas límite
    final today = DateTime.now();
    final minDate = DateTime(today.year - 100, today.month, today.day); // 100 años atrás
    final maxDate = DateTime(today.year - 18, today.month, today.day); // 18 años atrás
    final initialDate = DateTime(today.year - 25, today.month, today.day); // 25 años por defecto
    
    print('🔍 DEBUG: Opening date picker');
    print('  - minDate: $minDate');
    print('  - maxDate: $maxDate');
    print('  - initialDate: $initialDate');
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4DD0E1), // Turquesa LandGo
              onPrimary: Colors.black,
              surface: Color(0xFF2C2C2C), // Fondo oscuro
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4DD0E1), // Turquesa para botones
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      print('🔍 DEBUG: Date selected: $pickedDate');
      
      // Validar edad nuevamente
      final age = today.difference(pickedDate).inDays ~/ 365;
      print('  - Age calculated: $age years');
      
      if (age < 18) {
        print('  - Age validation failed');
        _showErrorSnackBar('You must be at least 18 years old to use this service');
        return;
      }
      
      print('  - Age validation passed');
      _updateFieldValue('date_of_birth', _formatDateForDisplay(pickedDate));
    } else {
      print('🔍 DEBUG: Date picker cancelled');
    }
  }




  String _formatDateForDisplay(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Método para mostrar diálogo de edición de campo
  void _showEditFieldDialog(String label, String currentValue, String fieldKey) {
    // 🚫 PROTECCIÓN: Email no se puede editar por seguridad
    if (fieldKey == 'email') {
      _showErrorSnackBar('Email cannot be changed for security reasons');
      return;
    }
    
    // 🚫 PROTECCIÓN: Membership no se puede editar desde aquí
    if (fieldKey == 'membership') {
      _showErrorSnackBar('Membership can only be changed from the membership page');
      return;
    }
    
    // 📅 CALENDARIO ESPECIAL para fecha de nacimiento
    if (fieldKey == 'date_of_birth') {
      _showDatePickerDialog();
      return;
    }
    
    // 📞 SELECTOR DE PAÍS para teléfono
    if (fieldKey == 'phone') {
      _showCountrySelectorDialog();
      return;
    }
    
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: Text(
            'Edit $label',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: controller,
            style: GoogleFonts.outfit(
              color: Colors.black, // TEXTO NEGRO PARA VISIBILIDAD
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: GoogleFonts.outfit(
                color: Colors.grey[600], // HINT MÁS VISIBLE
                fontSize: 16,
              ),
              filled: true,
              fillColor: Colors.white, // FONDO BLANCO
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF4DD0E1), // BORDE TURQUESA
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF4DD0E1), // BORDE TURQUESA
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF4DD0E1), // BORDE TURQUESA AL FOCUS
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  _updateFieldValue(fieldKey, newValue);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Save',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF4DD0E1),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Método para actualizar valor de campo
  void _updateFieldValue(String fieldKey, String newValue) {
    print('🔍 DEBUG: _updateFieldValue llamado:');
    print('  - fieldKey: $fieldKey');
    print('  - newValue: $newValue');
    print('  - _tempPhone antes: $_tempPhone');
    
    setState(() {
      switch (fieldKey) {
        case 'full_name':
          _tempFullName = newValue;
          print('  - _tempFullName actualizado a: $_tempFullName');
          break;
        case 'email':
          _tempEmail = newValue;
          print('  - _tempEmail actualizado a: $_tempEmail');
          break;
        case 'phone':
          _tempPhone = newValue; // Usar el valor ya formateado del diálogo
          print('  - _tempPhone actualizado a: $_tempPhone');
          print('  - _realPhone antes: $_realPhone');
          break;
        case 'date_of_birth':
          _tempDateOfBirth = newValue;
          print('  - _tempDateOfBirth actualizado a: $_tempDateOfBirth');
          break;
        case 'membership':
          _tempMembership = newValue;
          print('  - _tempMembership actualizado a: $_tempMembership');
          break;
      }
      _onFieldChanged();
    });
  }




  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF000000), // FONDO NEGRO EXACTO
        extendBodyBehindAppBar: false,
        extendBody: false,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con botón de regreso - ESTANDARIZADO
                  Row(
                    children: [
                      StandardBackButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Título "My Profile" centrado
                  Center(
                    child: Text(
                      'My Profile',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Profile Picture Section
                  _buildProfilePictureSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Account Balance Section
                  _buildAccountBalanceSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Personal Information Section
                  _buildPersonalInformationSection(),
                  
                  const SizedBox(height: 20),
                  
                  // Edit Profile Button
                  _buildEditProfileButton(),
                  
                  // Cancel Button (solo en modo edición)
                  if (_isEditMode) ...[
                    const SizedBox(height: 12),
                    _buildCancelButton(),
                  ],
                  
                  const SizedBox(height: 100), // ESPACIO PARA BOTTOM NAV
                ],
              ),
            ),
          ),
        ),
        // Bottom Navigation Bar EXACTO como en captura
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // Profile Picture Section
  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          // Circular Profile Picture
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4DD0E1), // BORDE TURQUESA
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _userAvatarUrl != null && _userAvatarUrl!.isNotEmpty
                  ? Image.network(
                      _userAvatarUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF2C2C2C),
                          child: Center(
                            child: Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF4DD0E1),
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: const Color(0xFF2C2C2C),
                      child: Center(
                        child: Text(
                          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF4DD0E1),
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          // Add Photo Button
          ElevatedButton.icon(
            onPressed: _isUploadingImage ? null : _pickAndUploadImage,
            icon: const Icon(
              Icons.add_a_photo,
              size: 18,
              color: Colors.black,
            ),
            label: Text(
              _isUploadingImage ? 'Uploading...' : 'Add Photo',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DD0E1), // TURQUESA
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountBalanceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO EXACTO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Account Balance',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          _isLoadingFinancialData
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4DD0E1),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBalanceCard(
                      'Balance',
                      '\$${_accountBalance.toStringAsFixed(2)}',
                      Icons.account_balance_wallet,
                      const Color(0xFF4DD0E1), // TURQUESA COMO EN CAPTURA
                    ),
                    _buildBalanceCard(
                      'Points',
                      _points.toString(),
                      Icons.star,
                      const Color(0xFFFF9800), // NARANJA COMO EN CAPTURA
                    ),
                    _buildBalanceCard(
                      'Cashback',
                      '\$${_cashback.toStringAsFixed(2)}',
                      Icons.attach_money,
                      const Color(0xFF4CAF50), // VERDE COMO EN CAPTURA
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2), // FONDO TENUE
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color, // COLOR DEL ICONO
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildInfoField('Full Name', _isEditMode ? _tempFullName : _userName, Icons.person_outline, 'full_name'),
        const SizedBox(height: 12),
        _buildInfoField('Email', _isEditMode ? _tempEmail : _userEmail, Icons.email_outlined, 'email'),
        const SizedBox(height: 12),
        _buildInfoField('Phone', _isEditMode ? _tempPhone : _realPhone, Icons.phone_outlined, 'phone'),
        const SizedBox(height: 12),
        _buildInfoField('Date of Birth', _isEditMode ? _tempDateOfBirth : _realDateOfBirth, Icons.cake_outlined, 'date_of_birth'),
        const SizedBox(height: 12),
        _buildInfoField('Membership', _isEditMode ? _tempMembership : _realMembership, Icons.diamond_outlined, 'membership'),
      ],
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon, String fieldKey) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO EXACTO
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF424242), // GRIS MEDIO PARA ICONOS
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_isEditMode && fieldKey != 'email' && fieldKey != 'membership')
            GestureDetector(
              onTap: () => _showEditFieldDialog(label, value, fieldKey),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF4DD0E1), // TURQUESA LANDGO
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.black,
                  size: 16,
                ),
              ),
            ),
          if ((fieldKey == 'email' || fieldKey == 'membership') && _isEditMode)
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF666666), // GRIS PARA INDICAR NO EDITABLE
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline, // ICONO DE CANDADO
                color: Colors.white70,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    // Determinar color del botón basado en el estado
    Color buttonColor;
    Widget? buttonChild;
    
    if (_isSavingChanges) {
      // Botón en estado de carga - Gris con spinner
      buttonColor = const Color(0xFF666666);
      buttonChild = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Saving...',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else if (_isEditMode && _hasChanges) {
      // Botón "Save Changes" - Turquesa LandGo Travel
      buttonColor = const Color(0xFF4DD0E1);
      buttonChild = Text(
        'Save Changes',
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      );
    } else if (_isEditMode && !_hasChanges) {
      // Botón en modo edición pero sin cambios - Gris para indicar inactivo
      buttonColor = const Color(0xFF666666);
      buttonChild = Text(
        'Edit Profile',
        style: GoogleFonts.outfit(
          color: Colors.white70,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      // Botón "Edit Profile" - Turquesa normal
      buttonColor = const Color(0xFF4DD0E1);
      buttonChild = Text(
        'Edit Profile',
        style: GoogleFonts.outfit(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isSavingChanges ? null : _toggleEditMode, // Deshabilitar durante carga
          child: Center(
            child: buttonChild,
          ),
        ),
      ),
    );
  }

  // ❌ BOTÓN DE CANCELAR EDICIÓN
  Widget _buildCancelButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF666666), // GRIS PARA CANCELAR
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4DD0E1), // BORDE TURQUESA
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _cancelEdit,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cancel',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ❌ MÉTODO PARA CANCELAR EDICIÓN
  void _cancelEdit() {
    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: Text(
            'Cancel Changes?',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel? All unsaved changes will be lost.',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Keep Editing',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF4DD0E1),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmCancelEdit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cancel',
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
    );
  }

  // ❌ CONFIRMAR CANCELACIÓN DE EDICIÓN
  void _confirmCancelEdit() {
    setState(() {
      _isEditMode = false;
      _hasChanges = false;
      _isSavingChanges = false;
      
      // Restaurar valores originales
      _tempFullName = _userName;
      _tempEmail = _userEmail;
      _tempPhone = _realPhone;
      _tempDateOfBirth = _realDateOfBirth;
      _tempMembership = _realMembership;
    });
    
    print('🔍 DEBUG: Edición cancelada, valores restaurados');
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C), // FONDO GRIS OSCURO EXACTO COMO EN CAPTURA
        border: Border(
          top: BorderSide(
            color: Color(0xFF333333), // BORDE SUTIL
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // PADDING BALANCEADO
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  context.pushNamed('MainPage');
                },
                child: _buildNavItem(Icons.home, 'Home', false),
              ),
              GestureDetector(
                onTap: () {
                  print('Discover button tapped from MyProfilePage');
                  context.pushNamed('DiscoverPage');
                },
                child: _buildNavItem(Icons.explore, 'Discover', false),
              ),
              GestureDetector(
                onTap: () {
                  print('My trip button tapped from MyProfilePage');
                  context.pushNamed('MyTripPage');
                },
                child: _buildNavItem(Icons.card_travel, 'My trip', false),
              ),
              GestureDetector(
                onTap: () {
                  print('My favorites button tapped from MyProfilePage');
                  context.pushNamed('MyFavoritesPage');
                },
                child: _buildNavItem(Icons.favorite_border, 'My favorites', false),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed('ProfilePage'); // NAVEGAR A PROFILE (NO QUEDARSE AQUÍ)
                },
                child: _buildNavItem(Icons.person, 'Profile', true), // PROFILE ACTIVO
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40, // TAMAÑO EXACTO BASADO EN CAPTURA MY PROFILE
          height: 40, // TAMAÑO EXACTO BASADO EN CAPTURA MY PROFILE
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4DD0E1) : Colors.transparent, // TURQUESA ACTIVO
            borderRadius: BorderRadius.circular(8), // BORDES COMO EN CAPTURA
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.black : Colors.white, // COLORES CORRECTOS
            size: 22, // TAMAÑO EXACTO
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF4DD0E1) : Colors.white, // TURQUESA ACTIVO
            fontSize: 11, // TAMAÑO EXACTO
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
