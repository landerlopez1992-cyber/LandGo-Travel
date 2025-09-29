import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import 'profile_page_model.dart';
export 'profile_page_model.dart';

class ProfilePageWidget extends StatefulWidget {
  const ProfilePageWidget({super.key});

  static const String routeName = 'ProfilePage';
  static const String routePath = '/profilePage';

  @override
  State<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends State<ProfilePageWidget> {
  late ProfilePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfilePageModel());
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
          child: Column(
            children: [
              // Header Section
              _buildHeaderSection(),
              
              // Menu Options
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildMenuItem(Icons.person_outline, 'My profile'),
                        _buildMenuItem(Icons.star_outline, 'My reviews'),
                        _buildMenuItem(Icons.favorite_outline, 'My favorites'),
                        _buildMenuItem(Icons.credit_card_outlined, 'Payment Methods'),
                        _buildMenuItem(Icons.people_outline, 'My Referrals'),
                        _buildMenuItem(Icons.chat_outlined, 'Support Chat'),
                        _buildMenuItem(Icons.settings_outlined, 'Settings'),
                        _buildMenuItem(Icons.logout, 'Log out', isLogout: true),
                        const SizedBox(height: 100), // ESPACIO PARA BOTTOM NAV
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom Navigation Bar
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF000000), // FONDO NEGRO
      ),
      child: Column(
        children: [
          Text(
            'Profile',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),
          // Profile Picture
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
              child: Image.network(
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF2C2C2C),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 60,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Dev Cooper',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'devcooper@gmail.com',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            if (isLogout) {
              await SupaFlow.client.auth.signOut();
              if (mounted) {
                context.goNamed('NewWelcomePage');
              }
            } else if (title == 'My profile') {
              context.pushNamed('MyProfilePage'); // CONECTAR A MY PROFILE
            } else if (title == 'Settings') {
              // TODO: Navigate to Settings
            } else if (title == 'My reviews') {
              // TODO: Navigate to My reviews
            } else if (title == 'My favorites') {
              // TODO: Navigate to My favorites
            } else if (title == 'Payment Methods') {
              // TODO: Navigate to Payment Methods
            } else if (title == 'My Referrals') {
              // TODO: Navigate to My Referrals
            } else if (title == 'Support Chat') {
              // TODO: Navigate to Support Chat
            }
          },
          child: Container(
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
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
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
                  // Stay on current page
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
