import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page_model.dart';
export 'login_page_model.dart';

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({super.key});

  static String routeName = 'LoginPage';
  static String routePath = '/loginPage';

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  late LoginPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginPageModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _showLoadingModal() {
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
                // Icono de loading moderno con gradiente
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4DD0E1), // Turquesa
                        const Color(0xFF26C6DA), // Turquesa más oscuro
                        const Color(0xFF00BCD4), // Cyan
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4DD0E1).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo exterior animado
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      // Círculo interior
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flight_takeoff,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Texto de loading moderno
                Text(
                  'Signing in...',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1F2937),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  'Please wait while we verify your credentials',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF6B7280),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Indicador de progreso adicional
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4DD0E1),
                          const Color(0xFF26C6DA),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFF1A1A1A), // Fondo negro con gradiente sutil
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
            ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24.0, 40.0, 24.0, 24.0),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // Header con Skip button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        // Botón Skip
                        TextButton(
                          onPressed: () {
                            context.goNamed('MainPage');
                          },
                          child: Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              color: Color(0xFFFFFFFF),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 40.0),
                    
                    // Logo de LandGo Travel centrado (agrandado)
                    Center(
                      child: Container(
                        width: 280.0, // Agrandado de 200 a 280
                        height: 120.0, // Agrandado de 80 a 120
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/land-go-travel-khmzio/assets/72g91s54bkzj/1.png',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 32.0),
                    
                    // Título Log in centrado
                    Center(
                      child: Text(
                        'Log in',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Color(0xFFFFFFFF),
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 8.0),
                    
                    // Tagline centrado
                    Center(
                      child: Text(
                        'Login exclusive trips, plan easily, and make memories',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Color(0xFFFFFFFF),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 40.0),
                  
                  // Formulario
                  Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          // Campo Email
                          Text(
                            'Email address',
                            style: GoogleFonts.inter(
                              color: Color(0xFFFFFFFF),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: Color(0xFF404040),
                                width: 1.0,
                              ),
                            ),
                            child: TextFormField(
                          controller: _model.textController1,
                          focusNode: _model.textFieldFocusNode1,
                          autofocus: false,
                          autofillHints: [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          obscureText: false,
                              style: GoogleFonts.inter(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16.0,
                              ),
                          decoration: InputDecoration(
                                hintText: 'devcooper@gmail.com',
                                hintStyle: GoogleFonts.inter(
                                  color: Color(0xFF888888),
                                  fontSize: 16.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: _model.textController1Validator.asValidator(context),
                            ),
                          ),
                          
                          SizedBox(height: 20.0),
                          
                          // Campo Password
                          Text(
                            'Password',
                            style: GoogleFonts.inter(
                              color: Color(0xFFFFFFFF),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: Color(0xFF404040),
                                width: 1.0,
                              ),
                            ),
                            child: TextFormField(
                          controller: _model.textController2,
                          focusNode: _model.textFieldFocusNode2,
                          autofocus: false,
                          autofillHints: [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          obscureText: !_model.passwordVisibility,
                              style: GoogleFonts.inter(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16.0,
                              ),
                          decoration: InputDecoration(
                                hintText: '••••••',
                                hintStyle: GoogleFonts.inter(
                                  color: Color(0xFF888888),
                                  fontSize: 16.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                                suffixIcon: InkWell(
                                  onTap: () => safeSetState(
                                    () => _model.passwordVisibility = !_model.passwordVisibility,
                                  ),
                                  focusNode: FocusNode(skipTraversal: true),
                                  child: Icon(
                                    _model.passwordVisibility
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Color(0xFF888888),
                                    size: 20.0,
                                  ),
                                ),
                              ),
                              validator: _model.textController2Validator.asValidator(context),
                            ),
                          ),
                          
                          SizedBox(height: 12.0),
                          
                          // Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  context.pushNamed('ForgotPasswordPage');
                                },
                                child: Text(
                                  'Forget password?',
                                  style: GoogleFonts.inter(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 30.0),
                          
                          // Botón Log in
                          Container(
                            width: double.infinity,
                            height: 56.0,
                            decoration: BoxDecoration(
                              color: Color(0xFF4DD0E1), // Turquesa
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoggingIn ? null : () async {
                                if (_model.formKey.currentState == null ||
                                    !_model.formKey.currentState!.validate()) {
                                  return;
                                }

                                // Activar loading
                                setState(() {
                                  _isLoggingIn = true;
                                });

                                // Mostrar modal de loading
                                _showLoadingModal();

                                // Iniciar cronómetro para mínimo 2 segundos
                                final stopwatch = Stopwatch()..start();

                                try {
                                  final user = await authManager.signInWithEmail(
                                    context,
                                    _model.textController1.text,
                                    _model.textController2.text,
                                  );

                                  // Asegurar mínimo 4 segundos de loading
                                  final elapsed = stopwatch.elapsedMilliseconds;
                                  if (elapsed < 4000) {
                                    await Future.delayed(Duration(milliseconds: 4000 - elapsed));
                                  }

                                  if (context.mounted) {
                                    // Cerrar modal de loading
                                    Navigator.of(context).pop();
                                    
                                    if (user != null) {
                                      context.goNamedAuth('MainPage', context.mounted);
                                    } else {
                                      setState(() {
                                        _isLoggingIn = false;
                                      });
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    // Cerrar modal de loading
                                    Navigator.of(context).pop();
                                    
                                    setState(() {
                                      _isLoggingIn = false;
                                    });
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Login failed: ${e.toString()}'),
                                        backgroundColor: const Color(0xFFDC2626),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: _isLoggingIn 
                                  ? Row(
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
                                        SizedBox(width: 12),
                                        Text(
                                          'Signing in...',
                                          style: GoogleFonts.inter(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Log in',
                                      style: GoogleFonts.inter(
                                        color: Color(0xFFFFFFFF),
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          
                          SizedBox(height: 30.0),
                          
                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Color(0xFF404040),
                                  thickness: 1.0,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                child: Text(
                                  'Or',
                                  style: GoogleFonts.inter(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Color(0xFF404040),
                                  thickness: 1.0,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 30.0),
                          
                          // Botones sociales
                          Column(
                            children: [
                              // Google
                              Container(
                                width: double.infinity,
                                height: 56.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFF2C2C2C),
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: Color(0xFF404040),
                                    width: 1.0,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Google authentication coming soon'),
                                        backgroundColor: Color(0xFF37474F),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.google,
                                        color: Color(0xFF4285F4),
                                        size: 20.0,
                                      ),
                                      SizedBox(width: 12.0),
                            Text(
                                        'Google',
                                        style: GoogleFonts.inter(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                                ),
                              ),
                              
                              SizedBox(height: 16.0),
                              
                              // Apple
                              Container(
                                width: double.infinity,
                                height: 56.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFF2C2C2C),
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: Color(0xFF404040),
                                    width: 1.0,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Apple authentication coming soon'),
                                        backgroundColor: Color(0xFF37474F),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                                      Icon(
                                        Icons.apple,
                                        color: Color(0xFFFFFFFF),
                                        size: 20.0,
                                      ),
                                      SizedBox(width: 12.0),
                          Text(
                                        'Apple',
                                        style: GoogleFonts.inter(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  
                    SizedBox(height: 40.0),
                    
                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Text(
                          'Don\'t have an account? ',
                          style: GoogleFonts.inter(
                            color: Color(0xFFFFFFFF),
                            fontSize: 14.0,
                          ),
                        ),
                        InkWell(
                          onTap: () => context.pushNamed('SignUpPage'),
                          child: Text(
                            'Sign up',
                            style: GoogleFonts.inter(
                              color: Color(0xFF4DD0E1),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24.0),
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