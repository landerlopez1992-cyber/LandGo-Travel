import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
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
            // TODO: Navigate to privacy policy
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
            // TODO: Navigate to terms & conditions
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

  // Delete Account Dialog
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'Delete Account',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 16,
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete account
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete account functionality coming soon!'),
                  backgroundColor: Color(0xFFDC2626),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626), // ROJO PARA ELIMINAR
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
