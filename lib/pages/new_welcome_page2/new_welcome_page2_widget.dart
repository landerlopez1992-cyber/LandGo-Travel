import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'new_welcome_page2_model.dart';
export 'new_welcome_page2_model.dart';

/// Onboarding Page 2 - Varadero Beach, Cuba
class NewWelcomePage2Widget extends StatefulWidget {
  const NewWelcomePage2Widget({super.key});

  static String routeName = 'NewWelcomePage2';
  static String routePath = '/newWelcomePage2';

  @override
  State<NewWelcomePage2Widget> createState() => _NewWelcomePage2WidgetState();
}

class _NewWelcomePage2WidgetState extends State<NewWelcomePage2Widget> {
  late NewWelcomePage2Model _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewWelcomePage2Model());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/istockphoto-475903022-612x612.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
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
                          'Discover paradise beaches around the world',
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
                          'From the crystal waters of Varadero to the exotic sands of the Maldives, explore the most beautiful beaches and create unforgettable memories.',
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
                          children: [
                            // Indicator inactivo
                            Container(
                              width: 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Indicator activo (verde-azulado)
                            Container(
                              width: 24,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4DD0E1), // Verde-azulado
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Indicator inactivo
                            Container(
                              width: 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Indicator inactivo
                            Container(
                              width: 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
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
                              onPressed: () async {
                                context.pushNamed('NewWelcomePage3');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4DD0E1), // Verde-azulado
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Next',
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
        ),
      ),
    );
  }
}
