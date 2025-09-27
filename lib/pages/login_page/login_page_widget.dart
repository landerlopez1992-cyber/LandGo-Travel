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
                    
                    // Logo de LandGo Travel centrado
                    Center(
                      child: Container(
                        width: 200.0,
                        height: 80.0,
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
                              onPressed: () async {
                                if (_model.formKey.currentState == null ||
                                    !_model.formKey.currentState!.validate()) {
                                  return;
                                }

                                final user = await authManager.signInWithEmail(
                                  context,
                                  _model.textController1.text,
                                  _model.textController2.text,
                                );
                                if (user != null) {
                                  context.goNamedAuth('MainPage', context.mounted);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text(
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