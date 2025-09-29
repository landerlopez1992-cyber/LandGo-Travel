import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
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
  
  // Variables para carga de imagen
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;

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
            .select('id, full_name, email, avatar_url')
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
            .select('full_name, email, avatar_url')
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
          print('Final user name: $_userName');
          print('Final user email: $_userEmail');
          print('Final user avatar: $_userAvatarUrl');
        });
      } else {
        // Usuario invitado
        setState(() {
          _userName = 'Guest User';
          _userEmail = 'guest@landgotravel.com';
          _userAvatarUrl = null;
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
    if (_isEditMode) {
      // Si está en modo edición, guardar cambios
      _saveChanges();
    } else {
      // Si no está en modo edición, activarlo
      setState(() {
        _isEditMode = true;
        _hasChanges = false;
        _tempFullName = _userName;
        _tempEmail = _userEmail;
        _tempPhone = '+1 (555) 123-4567'; // Valor por defecto
        _tempDateOfBirth = 'January 15, 1990'; // Valor por defecto
        _tempMembership = 'Premium Member'; // Valor por defecto
      });
    }
  }

  // Método para guardar cambios
  Future<void> _saveChanges() async {
    try {
      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser != null) {
        // Actualizar perfil en Supabase
        await SupaFlow.client
            .from('profiles')
            .update({
              'full_name': _tempFullName,
              'email': _tempEmail,
              'phone': _tempPhone,
              'date_of_birth': _tempDateOfBirth,
              'membership_type': _tempMembership,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', currentUser.id);

        // Actualizar estado local
        setState(() {
          _userName = _tempFullName;
          _userEmail = _tempEmail;
          _isEditMode = false;
          _hasChanges = false;
        });

        _showSuccessSnackBar('Profile updated successfully!');
        print('Profile updated successfully');
      }
    } catch (e) {
      print('Error updating profile: $e');
      _showErrorSnackBar('Error updating profile');
    }
  }


  // Método para detectar cambios
  void _onFieldChanged() {
    bool hasChanges = _tempFullName != _userName || 
                     _tempEmail != _userEmail;
    
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
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

  // Método para mostrar mensaje de éxito
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Método para mostrar mensaje de error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Método para mostrar diálogo de edición de campo
  void _showEditFieldDialog(String label, String currentValue, String fieldKey) {
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
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: GoogleFonts.outfit(
                color: Colors.grey,
                fontSize: 16,
              ),
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
    setState(() {
      switch (fieldKey) {
        case 'full_name':
          _tempFullName = newValue;
          break;
        case 'email':
          _tempEmail = newValue;
          break;
        case 'phone':
          _tempPhone = newValue;
          break;
        case 'date_of_birth':
          _tempDateOfBirth = newValue;
          break;
        case 'membership':
          _tempMembership = newValue;
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
        _buildInfoField('Phone', _isEditMode ? _tempPhone : '+1 (555) 123-4567', Icons.phone_outlined, 'phone'),
        const SizedBox(height: 12),
        _buildInfoField('Date of Birth', _isEditMode ? _tempDateOfBirth : 'January 15, 1990', Icons.cake_outlined, 'date_of_birth'),
        const SizedBox(height: 12),
        _buildInfoField('Membership', _isEditMode ? _tempMembership : 'Premium Member', Icons.diamond_outlined, 'membership'),
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
          if (_isEditMode)
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
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF4DD0E1), // TURQUESA EXACTO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _toggleEditMode,
          child: Center(
            child: Text(
              _isEditMode 
                  ? (_hasChanges ? 'Save Changes' : 'Edit Profile')
                  : 'Edit Profile',
              style: GoogleFonts.outfit(
                color: Colors.black, // TEXTO NEGRO SOBRE TURQUESA
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
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
                  // TODO: Navigate to Discover
                },
                child: _buildNavItem(Icons.explore, 'Discover', false),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to My trip
                },
                child: _buildNavItem(Icons.card_travel, 'My trip', false),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to My favorites
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
