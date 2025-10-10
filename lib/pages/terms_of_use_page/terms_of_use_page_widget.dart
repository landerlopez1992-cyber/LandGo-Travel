import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import 'terms_of_use_page_model.dart';
export 'terms_of_use_page_model.dart';

class TermsOfUsePageWidget extends StatefulWidget {
  const TermsOfUsePageWidget({super.key});

  static const String routeName = 'TermsOfUsePage';
  static const String routePath = '/termsOfUsePage';

  @override
  State<TermsOfUsePageWidget> createState() => _TermsOfUsePageWidgetState();
}

class _TermsOfUsePageWidgetState extends State<TermsOfUsePageWidget> {
  late TermsOfUsePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TermsOfUsePageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF1A1A1A), // FONDO NEGRO LANDGO
        appBar: AppBar(
          backgroundColor: const Color(0xFF2C2C2C),
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StandardBackButton(
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: Text(
            'Terms of Use',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4DD0E1),
                        Color(0xFF2C2C2C),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.gavel,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'LandGo Travel Terms of Use',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please read these terms carefully before using our services',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Last Updated: October 10, 2025',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 1. Acceptance of Terms
                _buildSection(
                  number: '1',
                  title: 'Acceptance of Terms Through Use',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF4DD0E1),
                  content: 'By using the LandGo Travel mobile application, website, or services, or by clicking "I Agree", you signify your agreement to these Terms of Use. If you do not agree, please do not use the Platform.\n\nWe reserve the right to revise these Terms at any time. Your continued use following changes constitutes acceptance of such changes.',
                ),
                
                const SizedBox(height: 20),
                
                // 2. Age Requirement
                _buildSection(
                  number: '2',
                  title: 'Age Requirement',
                  icon: Icons.person_outline,
                  color: const Color(0xFFFF6B00),
                  content: 'YOU MUST BE 18 YEARS OR OLDER TO USE THIS PLATFORM.\n\nIf you are under 18, you may not use the Platform unless a parent or legal guardian provides explicit written permission and accepts full legal responsibility.',
                ),
                
                const SizedBox(height: 20),
                
                // 3. License to Use
                _buildSection(
                  number: '3',
                  title: 'License to Use the Platform',
                  icon: Icons.verified_user,
                  color: const Color(0xFF4DD0E1),
                  content: 'LandGo Travel grants you a non-exclusive, non-transferable, revocable, limited license to access and use the Platform.\n\nYou agree to provide accurate information, not make false statements, and pay for all purchases using a valid payment method.',
                ),
                
                const SizedBox(height: 20),
                
                // 4. License Restrictions
                _buildSection(
                  number: '4',
                  title: 'License Restrictions',
                  icon: Icons.block,
                  color: const Color(0xFFDC2626),
                  content: 'You agree NOT to:\n\n• Download, copy, or distribute Platform content without permission\n• Use automated tools (bots, scrapers) to access the Platform\n• Reverse engineer or decompile the Platform\n• Share your account credentials\n• Use the Platform for illegal purposes',
                ),
                
                const SizedBox(height: 20),
                
                // 5. Membership Plans & Billing
                _buildSection(
                  number: '5',
                  title: 'Membership Plans & Billing',
                  icon: Icons.card_membership,
                  color: const Color(0xFFFFD700),
                  content: 'Plans: Free (\$0), Basic (\$29/mo), Premium (\$49/mo), VIP (\$79/mo)\n\n• All payments processed securely through Stripe\n• Automatic monthly billing on your subscription date\n• 6-month minimum commitment for paid plans\n• Early cancellation fee applies if cancelled before 6 months\n• 120-day wait period after cancellation to reactivate\n\nFailed Payments:\n• Day 1: Account becomes INACTIVE\n• After 90 days: Account CLOSED (7-day grace period)\n• After 97 days: Permanently cancelled',
                ),
                
                const SizedBox(height: 20),
                
                // 6. Travel Bookings & Services
                _buildSection(
                  number: '6',
                  title: 'Travel Bookings & Services',
                  icon: Icons.flight_takeoff,
                  color: const Color(0xFF4DD0E1),
                  content: 'LandGo Travel acts as an intermediary between you and third-party travel providers.\n\nBooking Limits:\n• Free: 1 booking/month\n• Basic: 2 bookings/month\n• Premium: 4 bookings/month\n• VIP: 8 bookings/month\n\nCashback Policy:\n• Minimum purchase: \$400\n• Rates: Free 0%, Basic 3%, Premium 6%, VIP 10%\n• Held for 30 days after trip completion\n• Forfeited if you cancel before travel',
                ),
                
                const SizedBox(height: 20),
                
                // 7. User Conduct
                _buildSection(
                  number: '7',
                  title: 'User Conduct & Prohibited Activities',
                  icon: Icons.warning_amber,
                  color: const Color(0xFFDC2626),
                  content: 'You agree NOT to:\n\n• Post unlawful, threatening, or harassing content\n• Infringe intellectual property rights\n• Distribute viruses or malicious code\n• Send spam or unsolicited advertising\n• Impersonate others\n• Attempt unauthorized access\n• Manipulate cashback or referral systems\n\nViolations may result in immediate account suspension or termination.',
                ),
                
                const SizedBox(height: 20),
                
                // 8. Intellectual Property
                _buildSection(
                  number: '8',
                  title: 'Intellectual Property',
                  icon: Icons.copyright,
                  color: const Color(0xFFFFD700),
                  content: 'The Platform and all content (text, graphics, logos, code) are the exclusive property of LandGo Travel and protected by copyright and trademark laws.\n\nBy submitting content (reviews, photos), you grant us a perpetual, royalty-free license to use, reproduce, and display such content.',
                ),
                
                const SizedBox(height: 20),
                
                // 9. Third-Party Links
                _buildSection(
                  number: '9',
                  title: 'Third-Party Links & Services',
                  icon: Icons.link,
                  color: const Color(0xFF4DD0E1),
                  content: 'The Platform may contain links to third-party sites (Stripe, airlines, hotels). We do not control these sites.\n\nUse of third-party sites is at your own risk. LandGo Travel is not liable for damages arising from third-party sites.',
                ),
                
                const SizedBox(height: 20),
                
                // 10. Returns & Refunds
                _buildSection(
                  number: '10',
                  title: 'Returns & Refunds',
                  icon: Icons.receipt_long,
                  color: const Color(0xFF00E676),
                  content: '14-Day Money-Back Guarantee:\n• Initial membership fee only\n• Request within 14 days of purchase\n• Email: support@landgotravel.com\n\nNon-Refundable:\n• Monthly membership dues (after 14 days)\n• Travel bookings (subject to provider policies)\n• Processing fees\n• Reactivation/reinstallation fees',
                ),
                
                const SizedBox(height: 20),
                
                // 11. Disclaimer of Warranties
                _buildSection(
                  number: '11',
                  title: 'Disclaimer of Warranties',
                  icon: Icons.info_outline,
                  color: const Color(0xFFFF6B00),
                  content: 'THE PLATFORM IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND.\n\nWe do not guarantee that the Platform will be:\n• Uninterrupted or error-free\n• Secure from viruses or malware\n• Accurate or reliable\n• That third-party services will meet expectations\n\nUse of the Platform is at your sole risk.',
                ),
                
                const SizedBox(height: 20),
                
                // 12. Limitation of Liability
                _buildSection(
                  number: '12',
                  title: 'Limitation of Liability',
                  icon: Icons.shield_outlined,
                  color: const Color(0xFFDC2626),
                  content: 'TO THE MAXIMUM EXTENT PERMITTED BY LAW, LANDGO TRAVEL SHALL NOT BE LIABLE FOR:\n\n• Indirect, incidental, or consequential damages\n• Loss of profits, revenue, or data\n• Damages from third-party providers\n• Unauthorized access to your account\n\nOur total liability shall not exceed the amount you paid in the 12 months preceding the claim.',
                ),
                
                const SizedBox(height: 20),
                
                // 13. Dispute Resolution
                _buildSection(
                  number: '13',
                  title: 'Dispute Resolution',
                  icon: Icons.gavel,
                  color: const Color(0xFFFFD700),
                  content: 'Before filing a formal claim, contact us at legal@landgotravel.com to resolve the dispute informally.\n\nIf informal resolution fails:\n• Binding arbitration administered by the American Arbitration Association (AAA)\n• Arbitration in Miami-Dade County, Florida, USA\n• Arbitrator\'s decision is final and binding\n\nYOU WAIVE YOUR RIGHT TO A JURY TRIAL AND CLASS ACTION PARTICIPATION.',
                ),
                
                const SizedBox(height: 20),
                
                // 14. Governing Law
                _buildSection(
                  number: '14',
                  title: 'Governing Law',
                  icon: Icons.location_on,
                  color: const Color(0xFF4DD0E1),
                  content: 'These Terms shall be governed by the laws of the State of Florida, USA.\n\nYou consent to the exclusive jurisdiction of state and federal courts located in Miami-Dade County, Florida for any disputes not subject to arbitration.',
                ),
                
                const SizedBox(height: 20),
                
                // 15. Contact Information
                _buildSection(
                  number: '15',
                  title: 'Contact Information',
                  icon: Icons.email,
                  color: const Color(0xFF00E676),
                  content: 'LandGo Travel\n\nEmail: support@landgotravel.com\nLegal inquiries: legal@landgotravel.com\nMembership cancellations: support@landgotravel.com',
                ),
                
                const SizedBox(height: 30),
                
                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF4DD0E1).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.verified_user,
                        color: Color(0xFF4DD0E1),
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'By Using LandGo Travel',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By clicking "I Agree," creating an account, or using the Platform, you acknowledge that you have read and understood these Terms of Use and agree to be bound by them.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Version 1.0 • Last updated: October 10, 2025',
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '© 2025 LandGo Travel. All Rights Reserved.',
                        style: GoogleFonts.outfit(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number,
                      style: GoogleFonts.outfit(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

