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
                      title: 'Agreement to Terms',
                      content: 'By accessing LandGo Travel ("Company," "we," "our") mobile application or website ("Services"), you agree to these Terms of Service ("Terms"). If you disagree with any part of these Terms, you may not access our Services.\n\nLandGo Travel is a technology platform connecting users with travel services through authorized data providers.',
                    ),
                    
                    _buildSection(
                      number: '2.',
                      title: 'Service Description',
                      content: 'We provide a platform for travel search, comparison, and booking services. Our Services may include:\n\n• Flight and hotel search functionality\n• Booking management tools\n• Membership programs\n• Wallet and payment services\n\nServices are provided "as-is" and may change without notice.',
                    ),
                    
                    _buildSection(
                      number: '3.',
                      title: 'User Eligibility',
                      content: 'You must be at least 18 years old and legally capable of entering binding contracts to use our Services. By using our Services, you represent that you meet these requirements.',
                    ),
                    
                    _buildSection(
                      number: '4.',
                      title: 'Account Responsibilities',
                      content: 'You are responsible for:\n\n• Maintaining confidentiality of account credentials\n• All activities under your account\n• Providing accurate information\n• Promptly updating account information\n• Notifying us of unauthorized access\n\nWe reserve the right to suspend or terminate accounts that violate these Terms.',
                    ),
                    
                    _buildSection(
                      number: '5.',
                      title: 'Payments and Fees',
                      content: 'All prices are in U.S. Dollars unless otherwise stated. You agree to:\n\n• Pay all applicable fees and charges\n• Provide valid payment information\n• Accept that prices may change without notice\n• Understand that third-party fees may apply\n\nPayment processing is handled by certified third-party processors.',
                    ),
                    
                    _buildSection(
                      number: '6.',
                      title: 'Cancellations and Refunds',
                      content: 'Cancellation policies vary by service provider (airline, hotel, etc.). Refunds are subject to:\n\n• Provider-specific cancellation policies\n• Applicable fare rules and restrictions\n• Processing times (typically 7-14 business days)\n• Service fees may be non-refundable\n\nContact support for refund requests.',
                    ),
                    
                    _buildSection(
                      number: '7.',
                      title: 'Prohibited Uses',
                      content: 'You may not:\n\n• Use Services for illegal purposes\n• Provide false or fraudulent information\n• Attempt to gain unauthorized access\n• Interfere with Services operation\n• Use automated systems or bots\n• Violate third-party rights\n• Bypass geographic restrictions',
                    ),
                    
                    _buildSection(
                      number: '8.',
                      title: 'Geographic Restrictions',
                      content: 'We comply with all U.S. sanctions and international regulations. Services are not available in jurisdictions subject to comprehensive sanctions, including:\n\n• Cuba\n• Iran\n• North Korea\n• Syria\n• Crimea, Donetsk, Luhansk regions\n\nWe reserve the right to refuse or cancel service based on location.',
                    ),
                    
                    _buildSection(
                      number: '9.',
                      title: 'Intellectual Property',
                      content: 'All content, features, and functionality are owned by LandGo Travel and protected by copyright, trademark, and other laws. You may not reproduce, distribute, or create derivative works without our written permission.',
                    ),
                    
                    _buildSection(
                      number: '10.',
                      title: 'Disclaimer of Warranties',
                      content: 'Services are provided "AS IS" and "AS AVAILABLE" without warranties of any kind. We do not guarantee:\n\n• Uninterrupted or error-free operation\n• Accuracy of information\n• Availability of bookings\n• Quality of third-party services',
                    ),
                    
                    _buildSection(
                      number: '11.',
                      title: 'Limitation of Liability',
                      content: 'We act as a technology platform connecting users with travel providers. TO THE MAXIMUM EXTENT PERMITTED BY LAW, we are not liable for:\n\n• Third-party service issues (delays, cancellations)\n• Indirect or consequential damages\n• Loss of profits or data\n• Force majeure events\n\nOur total liability shall not exceed amounts paid by you in the 12 months preceding the claim.',
                    ),
                    
                    _buildSection(
                      number: '12.',
                      title: 'Indemnification',
                      content: 'You agree to indemnify and hold LandGo Travel harmless from any claims, damages, losses, or expenses arising from your use of Services, violation of these Terms, or infringement of third-party rights.',
                    ),
                    
                    _buildSection(
                      number: '13.',
                      title: 'Dispute Resolution',
                      content: 'Any disputes shall be resolved through binding arbitration in accordance with Florida state law. You waive the right to participate in class actions. These Terms are governed by the laws of Florida, United States.',
                    ),
                    
                    _buildSection(
                      number: '14.',
                      title: 'Termination',
                      content: 'We may suspend or terminate your access at our discretion, with or without notice, for violations of these Terms or other reasons. Upon termination, your right to use Services ceases immediately.',
                    ),
                    
                    _buildSection(
                      number: '15.',
                      title: 'Changes to Terms',
                      content: 'We reserve the right to modify these Terms at any time. Continued use after changes constitutes acceptance. Material changes will be notified via email or in-app notification.',
                    ),
                    
                    _buildSection(
                      number: '16.',
                      title: 'Contact Information',
                      content: 'For questions regarding these Terms:\n\nLandGo Travel\n14703 Southern Blvd\nLoxahatchee, FL 33470\nUnited States\n\nEmail: legal@landgotravel.com',
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

