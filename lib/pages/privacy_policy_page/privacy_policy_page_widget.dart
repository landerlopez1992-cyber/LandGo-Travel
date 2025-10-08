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
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        context.pop();
                      } else {
                        context.goNamedAuth('MainPage', context.mounted);
                      }
                    },
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
                content: 'LandGo Travel ("Company," "we," "our," or "us") values your privacy. This Privacy Policy describes how we collect, use, and protect your personal information when you use our mobile application and website ("Services").',
              ),
              
              _buildSection(
                number: '2.',
                title: 'Information Collection',
                content: 'We collect information you provide directly:\n\n• Account information (name, email, phone)\n• Payment details (processed via secure third-party processors)\n• Travel preferences and search history\n• User-generated content and communications\n• Device information and usage data',
              ),
              
              _buildSection(
                number: '3.',
                title: 'Use of Information',
                content: 'Your information is used to:\n\n• Provide and improve our Services\n• Process transactions and bookings\n• Communicate service updates and offers\n• Ensure security and prevent fraud\n• Comply with legal requirements\n• Personalize your experience',
              ),
              
              _buildSection(
                number: '4.',
                title: 'Payment Security',
                content: 'Payment processing is handled by certified third-party payment processors. We do not store complete payment card information. All transactions are encrypted and comply with industry security standards (PCI DSS).',
              ),
              
              _buildSection(
                number: '5.',
                title: 'Information Sharing',
                content: 'We may share information with:\n\n• Service providers necessary to deliver our Services\n• Payment processors for transaction completion\n• Travel partners (airlines, hotels) for booking fulfillment\n• Legal authorities when required by law\n\nWe do not sell personal information to third parties.',
              ),
              
              _buildSection(
                number: '6.',
                title: 'Data Security',
                content: 'We implement industry-standard security measures to protect your information. However, no system is completely secure. You are responsible for maintaining the confidentiality of your account credentials.',
              ),
              
              _buildSection(
                number: '7.',
                title: 'Your Rights',
                content: 'Subject to applicable law, you may:\n\n• Access and review your personal information\n• Request correction of inaccurate data\n• Request deletion of your account and data\n• Opt-out of marketing communications\n• Export your data in portable format',
              ),
              
              _buildSection(
                number: '8.',
                title: 'International Users',
                content: 'Our Services are operated from the United States. By using our Services, you consent to the transfer and processing of your information in the United States and other countries where we operate.',
              ),
              
              _buildSection(
                number: '9.',
                title: 'Changes to Policy',
                content: 'We may update this Privacy Policy periodically. Continued use of our Services after changes constitutes acceptance of the updated policy. We will notify users of material changes via email or in-app notification.',
              ),
              
              _buildSection(
                number: '10.',
                title: 'Contact Information',
                content: 'For privacy-related inquiries:\n\nLandGo Travel\n14703 Southern Blvd\nLoxahatchee, FL 33470\nUnited States\n\nEmail: privacy@landgotravel.com',
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

