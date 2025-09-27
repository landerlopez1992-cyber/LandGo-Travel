import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'terms_conditions_page_model.dart';
export 'terms_conditions_page_model.dart';

class TermsConditionsPageWidget extends StatefulWidget {
  const TermsConditionsPageWidget({super.key});

  static String routeName = 'TermsConditionsPage';
  static String routePath = '/termsConditionsPage';

  @override
  State<TermsConditionsPageWidget> createState() => _TermsConditionsPageWidgetState();
}

class _TermsConditionsPageWidgetState extends State<TermsConditionsPageWidget> {
  late TermsConditionsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TermsConditionsPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFF000000), // Fondo negro
      appBar: AppBar(
        backgroundColor: Color(0xFF000000),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Botón de retroceso
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFFFFFFFF),
                  size: 20.0,
                ),
              ),
            ),
            SizedBox(width: 16.0),
            // Título
            Text(
              'Terms & conditions',
              style: GoogleFonts.inter(
                color: Color(0xFFFFFFFF),
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección 1
                _buildSection(
                  '1. Agreement of terms',
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                ),
                SizedBox(height: 24.0),
                
                // Sección 2
                _buildSection(
                  '2. User responsibilities',
                  'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                ),
                SizedBox(height: 24.0),
                
                // Sección 3
                _buildSection(
                  '3. Service availability',
                  'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',
                ),
                SizedBox(height: 24.0),
                
                // Sección 4
                _buildSection(
                  '4. Privacy policy',
                  'Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.',
                ),
                SizedBox(height: 24.0),
                
                // Sección 5
                _buildSection(
                  '5. Limitation of liability',
                  'Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.',
                ),
                SizedBox(height: 24.0),
                
                // Sección 6
                _buildSection(
                  '6. Contact information',
                  'Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: Color(0xFFFFFFFF),
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.0),
        Text(
          content,
          style: GoogleFonts.inter(
            color: Color(0xFFFFFFFF),
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
