import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import 'terms_conditions_page_model.dart';
export 'terms_conditions_page_model.dart';

class TermsConditionsPageWidget extends StatefulWidget {
  const TermsConditionsPageWidget({super.key});

  static const String routeName = 'TermsConditionsPage';
  static const String routePath = '/termsConditionsPage';

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
                        'Terms & conditions',
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
                    _buildSection(
                      number: '1.',
                      title: 'Acceptance of Terms',
                      content: 'By accessing or using LandGo Travel\'s mobile application and website, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.\n\nLandGo Travel is a technology platform that provides flight search and booking services through authorized travel data providers, hotel reservation services, travel booking management tools, payment processing through Stripe, and customer support assistance.',
                    ),
                    
                    _buildSection(
                      number: '2.',
                      title: 'Development Status',
                      content: 'LandGo Travel is currently in active development. Features and services may be subject to change. By using our platform, you acknowledge and accept this developmental status. We are committed to maintaining the highest standards of security and compliance in all payment processing activities.',
                    ),
                    
                    _buildSection(
                      number: '3.',
                      title: 'Geographic Restrictions',
                      content: 'LandGo Travel strictly complies with all U.S. sanctions and international regulations. We do NOT provide services to or accept bookings for destinations in jurisdictions subject to sanctions, including but not limited to:\n\n• Cuba\n• Iran\n• North Korea\n• Syria\n• Crimea, Donetsk, and Luhansk regions\n\nWe reserve the right to refuse service or cancel bookings that violate these restrictions.',
                    ),
                    
                    _buildSection(
                      number: '4.',
                      title: 'User Accounts',
                      content: 'You must be at least 18 years old to use our services. To access certain features, you must create an account. You are responsible for maintaining the confidentiality of your account credentials, all activities that occur under your account, providing accurate and complete information, and updating your information as needed.',
                    ),
                    
                    _buildSection(
                      number: '5.',
                      title: 'Booking and Payments',
                      content: 'All bookings are subject to availability and confirmation. Payment processing is handled securely through Stripe. By making a booking, you agree to pay all applicable fees and charges, provide accurate payment information, and comply with the terms of the service providers (airlines, hotels).',
                    ),
                    
                    _buildSection(
                      number: '6.',
                      title: 'Cancellations and Refunds',
                      content: 'Cancellation and refund policies vary by service provider and booking type. Refunds are processed according to the specific airline or hotel cancellation policy, applicable fare rules and restrictions, and processing times required by payment processors. Refund requests should be submitted through our support system.',
                    ),
                    
                    _buildSection(
                      number: '7.',
                      title: 'Prohibited Activities',
                      content: 'You may not use the platform for any illegal purpose, attempt to circumvent geographic restrictions, provide false or fraudulent information, interfere with the platform\'s operation, use automated systems to access the platform, or violate any applicable laws or regulations.',
                    ),
                    
                    _buildSection(
                      number: '8.',
                      title: 'Limitation of Liability',
                      content: 'LandGo Travel acts as a technology platform connecting users with travel service providers. We are not liable for flight delays, cancellations, or changes, hotel service quality or availability, travel disruptions or force majeure events, or indirect, incidental, or consequential damages.',
                    ),
                    
                    _buildSection(
                      number: '9.',
                      title: 'Contact Information',
                      content: 'For questions about these Terms of Service, contact us at:\n\nLandGo Travel\n14703 Southern Blvd\nLoxahatchee, FL 33470\nWest Palm Beach, Florida, United States\n\nEmail: legal@landgotravel.com\nSupport: support@landgotravel.com',
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

