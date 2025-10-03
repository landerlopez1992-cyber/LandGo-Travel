import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import 'privacy_policy_page_model.dart';
export 'privacy_policy_page_model.dart';

class PrivacyPolicyPageWidget extends StatefulWidget {
  const PrivacyPolicyPageWidget({super.key});

  static const String routeName = 'PrivacyPolicyPage';
  static const String routePath = '/privacyPolicyPage';

  @override
  State<PrivacyPolicyPageWidget> createState() => _PrivacyPolicyPageWidgetState();
}

class _PrivacyPolicyPageWidgetState extends State<PrivacyPolicyPageWidget> {
  late PrivacyPolicyPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PrivacyPolicyPageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
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
      backgroundColor: const Color(0xFF000000), // FONDO NEGRO
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            // Header con botón de regreso y título
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  StandardBackButton(
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Privacy policy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance con el back button
                ],
              ),
            ),
            
            // Content con scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              
              // Content
              _buildSection(
                number: '1.',
                title: 'Introduction',
                content: 'LandGo Travel ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and website.',
              ),
              
              _buildSection(
                number: '2.',
                title: 'Information We Collect',
                content: 'We collect information that you provide directly to us, including:\n\n• Personal identification information (name, email, phone number)\n• Payment information (processed securely through Stripe)\n• Travel preferences and booking history\n• Profile information and account credentials\n• Communication preferences',
              ),
              
              _buildSection(
                number: '3.',
                title: 'How We Use Your Information',
                content: 'We use the information we collect to:\n\n• Process your travel bookings and reservations\n• Provide customer support and respond to inquiries\n• Send booking confirmations and travel updates\n• Improve our services and user experience\n• Comply with legal obligations\n• Prevent fraud and ensure platform security',
              ),
              
              _buildSection(
                number: '4.',
                title: 'Payment Information',
                content: 'All payment transactions are processed through Stripe, a PCI DSS compliant payment processor. We do not store your complete credit card information on our servers. Payment data is encrypted and securely transmitted to Stripe for processing.',
              ),
              
              _buildSection(
                number: '5.',
                title: 'Data Security',
                content: 'We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the Internet is 100% secure.',
              ),
              
              _buildSection(
                number: '6.',
                title: 'Data Sharing',
                content: 'We may share your information with:\n\n• Travel service providers (airlines, hotels) to complete your bookings\n• Payment processors (Stripe) to process transactions\n• Law enforcement when required by law\n• Service providers who assist in operating our platform\n\nWe do not sell your personal information to third parties.',
              ),
              
              _buildSection(
                number: '7.',
                title: 'Your Rights',
                content: 'You have the right to:\n\n• Access your personal information\n• Correct inaccurate data\n• Request deletion of your data\n• Object to data processing\n• Export your data\n• Withdraw consent',
              ),
              
              _buildSection(
                number: '8.',
                title: 'Contact Us',
                content: 'If you have questions about this Privacy Policy, contact us at:\n\nLandGo Travel\n14703 Southern Blvd\nLoxahatchee, FL 33470\nWest Palm Beach, Florida, United States\n\nEmail: privacy@landgotravel.com',
              ),
              
              const SizedBox(height: 40),
              
              // Last updated
              Center(
                child: Text(
                  'Last updated: October 3, 2024',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
            ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título con número
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Contenido
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 15,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

