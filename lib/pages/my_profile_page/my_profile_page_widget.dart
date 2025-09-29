import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyProfilePageModel());
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
        appBar: AppBar(
          backgroundColor: const Color(0xFF000000), // FONDO NEGRO
          automaticallyImplyLeading: true,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2C), // GRIS OSCURO
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          title: Text(
            'My Profile',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Balance Section
                  _buildAccountBalanceSection(),
                  
                  const SizedBox(height: 30),
                  
                  // Personal Information Section
                  _buildPersonalInformationSection(),
                  
                  const SizedBox(height: 30),
                  
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBalanceCard(
                'Balance',
                '\$1,250.00',
                Icons.account_balance_wallet,
                const Color(0xFF4DD0E1), // TURQUESA COMO EN CAPTURA
              ),
              _buildBalanceCard(
                'Points',
                '2,450',
                Icons.star,
                const Color(0xFFFF9800), // NARANJA COMO EN CAPTURA
              ),
              _buildBalanceCard(
                'Cashback',
                '\$89.50',
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
        
        _buildInfoField('Full Name', 'Dev Cooper', Icons.person_outline),
        const SizedBox(height: 12),
        _buildInfoField('Email', 'devcooper@gmail.com', Icons.email_outlined),
        const SizedBox(height: 12),
        _buildInfoField('Phone', '+1 (555) 123-4567', Icons.phone_outlined),
        const SizedBox(height: 12),
        _buildInfoField('Date of Birth', 'January 15, 1990', Icons.cake_outlined),
        const SizedBox(height: 12),
        _buildInfoField('Membership', 'Premium Member', Icons.diamond_outlined),
      ],
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
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
          Icon(
            Icons.edit,
            color: const Color(0xFF4DD0E1), // TURQUESA EDIT ICONS
            size: 20,
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
          onTap: () {
            // TODO: Edit profile functionality
          },
          child: Center(
            child: Text(
              'Edit Profile',
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
