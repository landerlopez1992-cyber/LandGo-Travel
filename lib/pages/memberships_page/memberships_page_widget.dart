import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import '/pages/membership_detail_page/membership_detail_page_widget.dart';
import '/backend/supabase/supabase.dart';
import 'memberships_page_model.dart';
export 'memberships_page_model.dart';

class MembershipsPageWidget extends StatefulWidget {
  const MembershipsPageWidget({super.key});

  static const String routeName = 'MembershipsPage';
  static const String routePath = '/membershipsPage';

  @override
  State<MembershipsPageWidget> createState() => _MembershipsPageWidgetState();
}

class _MembershipsPageWidgetState extends State<MembershipsPageWidget> {
  late MembershipsPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentMembershipType = 'Free'; // Plan actual del usuario
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MembershipsPageModel());
    _loadCurrentMembership();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }
  
  Future<void> _loadCurrentMembership() async {
    try {
      final currentUser = SupaFlow.client.auth.currentUser;
      if (currentUser == null) {
        print('❌ [MEMBERSHIP] No current user found');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('🔍 [MEMBERSHIP] Loading membership for user: ${currentUser.id}');

      // Obtener membresía actual desde Supabase
      final response = await SupaFlow.client
          .from('memberships')
          .select('membership_type, status, stripe_subscription_id')
          .eq('user_id', currentUser.id)
          .eq('status', 'active')
          .maybeSingle();

      print('🔍 [MEMBERSHIP] Supabase response: $response');

      if (response != null) {
        final membershipType = response['membership_type'] as String?;
        print('✅ [MEMBERSHIP] Found active membership: $membershipType');
        setState(() {
          _currentMembershipType = membershipType ?? 'Free';
          _isLoading = false;
        });
      } else {
        print('⚠️ [MEMBERSHIP] No active membership found, defaulting to Free');
        setState(() {
          _currentMembershipType = 'Free';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [MEMBERSHIP] Error loading membership: $e');
      setState(() {
        _currentMembershipType = 'Free';
        _isLoading = false;
      });
    }
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
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con botón de regreso
                  Row(
                    children: [
                      StandardBackButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Título principal - CENTRADO
                  Center(
                    child: Text(
                      'Choose Your Membership',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Subtítulo - CENTRADO
                  Center(
                    child: Text(
                      'Unlock exclusive benefits and save on every booking',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // FREE MEMBERSHIP
                  _buildMembershipCard(
                    title: 'Free',
                    price: '\$0',
                    period: '/month',
                    benefits: [
                      'Standard prices (no discounts)',
                      '0% cashback on bookings',
                      'Access to all flights & hotels',
                      'Standard customer support',
                    ],
                    color: const Color(0xFF4DD0E1), // TURQUESA AZUL EXISTENTE
                    isCurrentPlan: _currentMembershipType == 'Free',
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // BASIC MEMBERSHIP
                  _buildMembershipCard(
                    title: 'Basic',
                    price: '\$29',
                    period: '/month',
                    benefits: [
                      '3% cashback on completed bookings',
                      'Priority customer support',
                      'Earn referral points (3 levels)',
                      'Personalized booking assistance',
                    ],
                    color: const Color(0xFF00E676), // VERDE LLAMATIVO FUERTE
                    isPopular: true,
                    isCurrentPlan: _currentMembershipType == 'Basic',
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // PREMIUM MEMBERSHIP
                  _buildMembershipCard(
                    title: 'Premium',
                    price: '\$49',
                    period: '/month',
                    benefits: [
                      '5% cashback on completed bookings',
                      'Priority customer support 24/7',
                      'Higher referral commissions',
                      'Free booking modifications',
                    ],
                    color: const Color(0xFFFF6B00), // NARANJA FUERTE LLAMATIVO
                    isCurrentPlan: _currentMembershipType == 'Premium',
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // VIP MEMBERSHIP
                  _buildMembershipCard(
                    title: 'VIP',
                    price: '\$79',
                    period: '/month',
                    benefits: [
                      '8% cashback on completed bookings',
                      'Dedicated personal travel assistant',
                      'Maximum referral commissions',
                      'Unlimited booking modifications',
                      'Exclusive VIP promotions',
                    ],
                    color: const Color(0xFFFFD700), // GOLD
                    isVIP: true,
                    isCurrentPlan: _currentMembershipType == 'VIP',
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Benefits comparison section
                  _buildBenefitsComparisonSection(),
                  
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipCard({
    required String title,
    required String price,
    required String period,
    required List<String> benefits,
    required Color color,
    bool isCurrentPlan = false,
    bool isPopular = false,
    bool isVIP = false,
  }) {
    return GestureDetector(
      onTap: () {
        // Navegar a pantalla de detalles de la membresía
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MembershipDetailPageWidget(
              title: title,
              price: price,
              period: period,
              benefits: benefits,
              color: color,
              isCurrentPlan: isCurrentPlan,
              isPopular: isPopular,
              isVIP: isVIP,
            ),
          ),
        );
      },
      child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVIP
              ? [
                  const Color(0xFF2C2C2C),
                  const Color(0xFF3A3A3A),
                ]
              : [
                  const Color(0xFF2C2C2C),
                  const Color(0xFF2C2C2C),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5), // ✅ SIEMPRE usar el color de la membresía
          width: isVIP ? 2.5 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Popular badge
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'MOST POPULAR',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          
          // VIP badge
          if (isVIP)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.diamond,
                      color: Colors.black,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'EXCLUSIVE',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    if (isVIP)
                      Icon(
                        Icons.diamond,
                        color: color,
                        size: 18,
                      ),
                    if (isVIP) const SizedBox(width: 6),
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: GoogleFonts.outfit(
                        color: color,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7, left: 4),
                      child: Text(
                        period,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Divider
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.1),
                ),
                
                const SizedBox(height: 12),
                
                // Benefits
                ...benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: color,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11.5,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                
                const SizedBox(height: 14),
                
                // Action Button
                if (isCurrentPlan)
                  Container(
                    width: double.infinity,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Current Plan',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Navegar a la página de detalles para el upgrade real
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MembershipDetailPageWidget(
                                title: title,
                                price: price,
                                period: '/month',
                                benefits: benefits,
                                color: color,
                                isCurrentPlan: false,
                                isPopular: isPopular,
                                isVIP: isVIP,
                              ),
                            ),
                          );
                        },
                        child: Center(
                          child: Text(
                            'Upgrade to $title',
                            style: GoogleFonts.outfit(
                              color: isVIP ? Colors.black : Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      ), // ✅ Cierre del GestureDetector
    );
  }

  Widget _buildBenefitsComparisonSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Upgrade?',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 14),
          
          _buildBenefitRow(
            icon: Icons.account_balance_wallet,
            title: 'Earn More Cashback',
            description: 'Get up to 8% cashback on every completed booking with VIP',
          ),
          
          const SizedBox(height: 12),
          
          _buildBenefitRow(
            icon: Icons.people,
            title: 'Referral Program',
            description: 'Earn commissions by referring friends (3-level pyramid system)',
          ),
          
          const SizedBox(height: 12),
          
          _buildBenefitRow(
            icon: Icons.support_agent,
            title: 'Priority Support',
            description: 'Get faster responses and dedicated booking assistance',
          ),
          
          const SizedBox(height: 12),
          
          _buildBenefitRow(
            icon: Icons.edit_calendar,
            title: 'Booking Flexibility',
            description: 'Priority handling for booking changes and modifications',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF4DD0E1).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4DD0E1),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUpgradeDialog(String title, String price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'Upgrade to $title',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'You\'re about to upgrade to $title membership for $price/month.\n\nThis feature will be available soon!',
          style: GoogleFonts.outfit(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.outfit(
                color: const Color(0xFF4DD0E1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

