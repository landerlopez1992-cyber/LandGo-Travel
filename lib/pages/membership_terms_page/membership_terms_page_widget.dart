import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import 'membership_terms_page_model.dart';
export 'membership_terms_page_model.dart';

class MembershipTermsPageWidget extends StatefulWidget {
  const MembershipTermsPageWidget({super.key});

  static const String routeName = 'MembershipTermsPage';
  static const String routePath = '/membershipTermsPage';

  @override
  State<MembershipTermsPageWidget> createState() => _MembershipTermsPageWidgetState();
}

class _MembershipTermsPageWidgetState extends State<MembershipTermsPageWidget> {
  late MembershipTermsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MembershipTermsPageModel());
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
            'Membership Terms & Conditions',
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
                        Icons.info_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Important Information',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please read these terms carefully before subscribing',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 1. Compromiso mínimo
                _buildTermSection(
                  icon: Icons.lock_clock,
                  color: const Color(0xFFFF6B00),
                  title: '1. Minimum Commitment (6 Months)',
                  points: [
                    'All paid memberships (Basic, Premium, VIP) require a 6-month minimum commitment.',
                    'You cannot cancel or downgrade your membership during the 6-month commitment period.',
                    'After 6 months, you can cancel or downgrade at the end of any billing period.',
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 2. Penalización por cancelación
                _buildTermSection(
                  icon: Icons.warning_amber,
                  color: const Color(0xFFDC2626),
                  title: '2. Early Cancellation Fee (If cancelling before 6 months)',
                  points: [
                    'If you cancel before completing 6 months, you must pay an early termination fee.',
                    'Fee = Remaining months to reach 6 × Monthly price',
                    'Example: Cancel VIP (\$79/mo) after 1 month = 5 months × \$79 = \$395 fee',
                    'Early downgrade is treated the same as cancellation to prevent abuse.',
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 3. Período de espera
                _buildTermSection(
                  icon: Icons.schedule,
                  color: const Color(0xFF00E676),
                  title: '3. Reactivation Waiting Period (120 Days)',
                  points: [
                    'If you cancel or downgrade, you must wait 120 days before upgrading again.',
                    'This prevents repeated activation/cancellation cycles.',
                    'Example: Cancel on January 1st → Cannot upgrade until May 1st',
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 4. Cashback hold
                _buildTermSection(
                  icon: Icons.account_balance_wallet,
                  color: const Color(0xFF4DD0E1),
                  title: '4. Cashback Hold Policy',
                  points: [
                    'Cashback is not released immediately upon booking.',
                    'Cashback is held until your trip is completed (flight departure or hotel check-out).',
                    'If you cancel your booking or membership before travel, cashback is forfeited.',
                    'This ensures fair use of the cashback benefit.',
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 5. Billing
                _buildTermSection(
                  icon: Icons.credit_card,
                  color: const Color(0xFFFFD700),
                  title: '5. Billing & Payments',
                  points: [
                    'Memberships are billed monthly on your subscription date.',
                    'Payments are processed automatically via your saved payment method.',
                    'Failed payments will set your membership to INACTIVE (access restricted).',
                    'Upgrades are prorated - you only pay the difference for remaining days.',
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 6. Upgrades
                _buildTermSection(
                  icon: Icons.trending_up,
                  color: const Color(0xFF00E676),
                  title: '6. Membership Upgrades',
                  points: [
                    'You can upgrade to a higher tier anytime.',
                    'You pay only the prorated difference for the current billing period.',
                    'Your 3-month commitment resets from the upgrade date.',
                    'Example: Basic → Premium mid-month = Pay ~\$10, enjoy Premium immediately.',
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 7. Downgrades
                _buildTermSection(
                  icon: Icons.trending_down,
                  color: const Color(0xFFFF6B00),
                  title: '7. Membership Downgrades',
                  points: [
                    'Downgrades are only allowed after completing the 6-month commitment.',
                    'Downgrades take effect at the end of your current billing period.',
                    'Early downgrade requires paying the early termination fee.',
                    'This policy prevents abuse of membership benefits.',
                  ],
                ),

                const SizedBox(height: 20),

                // 8. Account Inactivity & Reactivation (90 + 7)
                _buildTermSection(
                  icon: Icons.pause_circle_filled,
                  color: const Color(0xFF4DD0E1),
                  title: '8. Account Inactivity & Reactivation (90 + 7 days)',
                  points: [
                    'If you miss a monthly payment, your account becomes INACTIVE: booking engine is disabled until reactivation.',
                    'To reactivate: pay the reactivation fee plus the current month’s membership dues (restores full access).',
                    'After 90 days past due: account is CLOSED. You have a 7-day grace window to REINSTATE the account by paying a reinstatement fee (includes the current month).',
                    'After the 90+7 window, the account is permanently cancelled and cannot be reinstated.',
                  ],
                ),

                const SizedBox(height: 20),

                // 9. Cancellations & Refunds
                _buildTermSection(
                  icon: Icons.receipt_long,
                  color: const Color(0xFFDC2626),
                  title: '9. Cancellations & Refunds',
                  points: [
                    'Monthly membership dues are non‑refundable.',
                    'If cancellation notice is received fewer than 5 business days before your billing date, cancellation becomes effective the following cycle.',
                    'Membership is personal and non‑transferable.',
                  ],
                ),

                const SizedBox(height: 20),

                // 10. Policy Changes & Suspensions
                _buildTermSection(
                  icon: Icons.policy,
                  color: const Color(0xFFFFD700),
                  title: '10. Policy Changes & Suspensions',
                  points: [
                    'Benefits may be added, removed, or substituted without notice; we will use commercially reasonable efforts to update terms and pricing.',
                    'Access can be suspended for policy violations; a written/email notice will be sent and you will have 10 calendar days to cure.',
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 8. Referral program
                _buildTermSection(
                  icon: Icons.people,
                  color: const Color(0xFF4DD0E1),
                  title: '8. Referral Program',
                  points: [
                    'Earn commissions when you refer friends to LandGo Travel.',
                    'Commission rates: Basic 3%, Premium 5%, VIP 8%',
                    '3-level pyramid system: Earn from your direct referrals and their referrals.',
                    'Referral commissions are paid monthly.',
                  ],
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
                        'Fair & Transparent',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'These terms ensure fair treatment for all members and protect both you and LandGo Travel from abuse. By subscribing, you agree to these terms.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Last updated: October 10, 2025 (Anti‑abuse update: 6‑month commitment, 90+7 inactivity, 120‑day wait)',
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

  Widget _buildTermSection({
    required IconData icon,
    required Color color,
    required String title,
    required List<String> points,
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
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    point,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}



