import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import 'settings_page_model.dart';
export 'settings_page_model.dart';

class SettingsPageWidget extends StatefulWidget {
  const SettingsPageWidget({super.key});

  static const String routeName = 'SettingsPage';
  static const String routePath = '/settingsPage';

  @override
  State<SettingsPageWidget> createState() => _SettingsPageWidgetState();
}

class _SettingsPageWidgetState extends State<SettingsPageWidget> {
  late SettingsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingsPageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    try {
      print('🗑️ Iniciando eliminación de cuenta...');
      
      // Mostrar loading por 3 segundos
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Deleting account...',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF2C2C2C),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      print('🔍 Usuario a eliminar: ${currentUser.email}');
      print('🔍 User ID: ${currentUser.id}');

      // Esperar 3 segundos mínimo
      await Future.delayed(const Duration(seconds: 3));

      // Usar Edge Function para eliminar usuario (permite admin operations)
      print('🗑️ Llamando Edge Function para eliminar usuario...');
      final response = await SupaFlow.client.functions.invoke(
        'delete-user',
        body: {
          'userId': currentUser.id,
        },
      );

      print('📄 Response from delete-user function: $response');

      if (response.data == null || response.data['success'] != true) {
        throw Exception(response.data?['error'] ?? 'Failed to delete user');
      }

      print('✅ Usuario eliminado exitosamente desde Edge Function');

      // Cerrar loading
      if (context.mounted) {
        Navigator.of(context).pop();
        
        print('✅ Usuario eliminado exitosamente');
        
        // Mostrar éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        
        // Navegar a login después de 1 segundo
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            context.goNamedAuth('LoginPage', context.mounted);
          }
        });
      }
    } catch (e) {
      print('❌ Error eliminando cuenta: $e');
      
      // Cerrar loading si está abierto
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: ${e.toString()}'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
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
                  // Header con botón de regreso - COMPONENTE ESTANDARIZADO
                  Row(
                    children: [
                      StandardBackButton(
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Título "Settings" centrado
                  Center(
                    child: Text(
                      'Settings',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Settings Options
                  _buildSettingsSection(),
                  
                  const SizedBox(height: 100), // ESPACIO PARA BOTTOM NAV
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  // Settings Section - CLONADO EXACTAMENTE DE LA CAPTURA
  Widget _buildSettingsSection() {
    return Column(
      children: [
        // Change password
        _buildSettingsItem(
          icon: Icons.lock_outline,
          title: 'Change password',
          onTap: () {
            // TODO: Navigate to change password
          },
        ),
        
        const SizedBox(height: 16),
        
        // Privacy policy
        _buildSettingsItem(
          icon: Icons.shield_outlined,
          title: 'Privacy policy',
          onTap: () {
            context.pushNamed('PrivacyPolicyPage');
          },
        ),
        
        const SizedBox(height: 16),
        
        // About us
        _buildSettingsItem(
          icon: Icons.info_outline,
          title: 'About us',
          onTap: () {
            // TODO: Navigate to about us
          },
        ),
        
        const SizedBox(height: 16),
        
        // Terms & conditions
        _buildSettingsItem(
          icon: Icons.shield_outlined,
          title: 'Terms & conditions',
          onTap: () {
            context.pushNamed('TermsConditionsPage');
          },
        ),
        
        const SizedBox(height: 16),
        
        // Delete account
        _buildSettingsItem(
          icon: Icons.delete_outline,
          title: 'Delete account',
          onTap: () {
            _showDeleteAccountDialog();
          },
        ),
      ],
    );
  }

  // Settings Item - EXACTAMENTE COMO EN LA CAPTURA
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C), // GRIS OSCURO COMO EN CAPTURA
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icono circular gris
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF404040), // GRIS MÁS CLARO
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Título
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Flecha derecha
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // Delete Account Dialog - EXACTAMENTE COMO EN TU IMAGEN
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                // Icono de eliminación - EXACTAMENTE COMO EN TU IMAGEN
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo medio
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Círculo interior con X
                      Container(
                        width: 45,
                        height: 45,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Texto de confirmación
                Text(
                  'Are you sure you want to\ndelete account?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF2C2C2C),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Botones
                Row(
                  children: [
                    // Botón No
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFF2C2C2C),
                            width: 2,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () => Navigator.of(context).pop(),
                            child: Center(
                              child: Text(
                                'No',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF2C2C2C),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Botón Yes
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () async {
                              Navigator.of(context).pop();
                              await _deleteAccount();
                            },
                            child: Center(
                              child: Text(
                                'Yes',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
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
    );
  }

  // Bottom Navigation
  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C),
        border: Border(
          top: BorderSide(
            color: Color(0xFF333333),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                  print('Discover button tapped from SettingsPage');
                  context.pushNamed('DiscoverPage');
                },
                child: _buildNavItem(Icons.explore, 'Discover', false),
              ),
              GestureDetector(
                onTap: () {
                  print('My trip button tapped from SettingsPage');
                  context.pushNamed('MyTripPage');
                },
                child: _buildNavItem(Icons.card_travel, 'My trip', false),
              ),
              GestureDetector(
                onTap: () {
                  print('My favorites button tapped from SettingsPage');
                  context.pushNamed('MyFavoritesPage');
                },
                child: _buildNavItem(Icons.favorite_border, 'My favorites', false),
              ),
              GestureDetector(
                onTap: () {
                  context.pushNamed('ProfilePage');
                },
                child: _buildNavItem(Icons.person, 'Profile', false),
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4DD0E1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.black : Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF4DD0E1) : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
