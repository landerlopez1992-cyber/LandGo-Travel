import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'new_welcome_page_model.dart';
export 'new_welcome_page_model.dart';

/// Pantalla Welcome idéntica a la captura - Diseño Dark con imagen de montaña
class NewWelcomePageWidget extends StatefulWidget {
  const NewWelcomePageWidget({super.key});

  static String routeName = 'NewWelcomePage';
  static String routePath = '/newWelcomePage';

  @override
  State<NewWelcomePageWidget> createState() => _NewWelcomePageWidgetState();
}

class _NewWelcomePageWidgetState extends State<NewWelcomePageWidget> {
  late NewWelcomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  int _currentPage = 0;
  final PageController _pageController = PageController();
  
  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Discover paradise\ndestinations with LandGo Travel',
      subtitle: 'Your trusted travel agency with over 10 years creating unforgettable experiences for families around the world.',
      imageUrl: 'assets/images/1.png',
    ),
    OnboardingData(
      title: 'Travel with family\nwith exclusive discounts',
      subtitle: 'Save up to 50% on hotels and flights. Create unforgettable memories with your loved ones in the best destinations.',
      imageUrl: 'assets/images/2.png',
    ),
    OnboardingData(
      title: 'Earn points and\nreferrals on every trip',
      subtitle: 'Every purchase gives you points that you can use for future trips. Invite friends and earn commissions for each referral.',
      imageUrl: 'assets/images/3.png',
    ),
    OnboardingData(
      title: 'Tropical paradises\nat your fingertips',
      subtitle: 'Join our VIP membership program and enjoy automatic cashback, priority support and additional discounts.',
      imageUrl: 'assets/images/4.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewWelcomePageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Ir a login
      context.pushNamed('LoginPage');
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
        backgroundColor: Colors.black,
        body: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemCount: _onboardingData.length,
          itemBuilder: (context, index) {
            return _buildOnboardingPage(_onboardingData[index]);
          },
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: data.imageUrl.startsWith('assets/') 
              ? AssetImage(data.imageUrl) as ImageProvider
              : NetworkImage(data.imageUrl),
          fit: BoxFit.cover, // Las fotos tienen las dimensiones exactas (1080 x 2400)
        ),
      ),
      child: Container(
        // Overlay oscuro para legibilidad del texto
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Status bar spacer
                const SizedBox(height: 20),
                
                // Spacer to push content down
                const Expanded(
                  flex: 3,
                  child: SizedBox(),
                ),
                
                // Main content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main title - exacto como la captura
                    Text(
                      data.title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Subtitle - exacto como la captura
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Page indicators - exacto como la captura
                    Row(
                      children: List.generate(
                        _onboardingData.length,
                        (index) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: _currentPage == index ? 24 : 8,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _currentPage == index 
                                ? const Color(0xFF4DD0E1) // Verde-azulado activo
                                : Colors.white.withOpacity(0.3), // Inactivo
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Buttons - exactos como la captura
                Row(
                  children: [
                    // Skip button (outline transparente)
                    Expanded(
                      child: Container(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () async {
                            context.pushNamed('LoginPage');
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Next button (verde-azulado sólido)
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4DD0E1), // Verde-azulado
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentPage == _onboardingData.length - 1 
                                ? 'Get Started' 
                                : 'Next',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String imageUrl;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

