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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewWelcomePageModel());
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
            // Fondo de montañas paradisíacas
            image: DecorationImage(
              image: AssetImage('assets/images/vista-de-la-playa-y-el-paisaje-natural-impresionantes.jpg'),
              fit: BoxFit.cover,
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
                          'Your journey starts with a thoughtfully planned',
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
                          'From destination dreams to real itineraries, Tripplanner helps you explore the world with purpose, ease, and adventure.',
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
                                context.pushNamed('NewWelcomePage2');
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
