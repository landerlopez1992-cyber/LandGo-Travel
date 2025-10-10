import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import '/pages/membership_terms_page/membership_terms_page_widget.dart';
import '/config/stripe_config.dart';
import '/services/membership_subscription_service.dart';
import 'membership_detail_page_model.dart';
export 'membership_detail_page_model.dart';

class MembershipDetailPageWidget extends StatefulWidget {
  final String title;
  final String price;
  final String period;
  final List<String> benefits;
  final Color color;
  final bool isCurrentPlan;
  final bool isPopular;
  final bool isVIP;

  const MembershipDetailPageWidget({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    required this.benefits,
    required this.color,
    this.isCurrentPlan = false,
    this.isPopular = false,
    this.isVIP = false,
  });

  static const String routeName = 'MembershipDetailPage';
  static const String routePath = '/membershipDetailPage';

  @override
  State<MembershipDetailPageWidget> createState() => _MembershipDetailPageWidgetState();
}

class _MembershipDetailPageWidgetState extends State<MembershipDetailPageWidget> {
  late MembershipDetailPageModel _model;
  bool termsAccepted = false; // estado local para el checkbox del diálogo

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MembershipDetailPageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Obtener información detallada según la membresía
  Map<String, dynamic> _getMembershipDetails() {
    switch (widget.title) {
      case 'Free':
        return {
          'cashback': '0%',
          'bookingFee': 'Standard pricing',
          'support': 'Email support (24-48h)',
          'cancellation': 'Standard policy',
          'insurance': 'Not included',
          'loungeAccess': 'Not included',
          'features': [
            'Access to all flights & hotels worldwide',
            'Standard market pricing',
            'Email support within 48 hours',
            'Booking confirmations via email',
            'Access to LandGo Travel mobile app',
            'Complete transaction history',
            'Secure payment processing',
          ],
        };
      case 'Basic':
        return {
          'cashback': '3%',
          'bookingFee': 'Standard pricing',
          'support': 'Priority support (12-24h)',
          'cancellation': 'Flexible changes',
          'insurance': 'Not included',
          'loungeAccess': 'Not included',
          'features': [
            'Everything in Free, plus:',
            '3% cashback on completed bookings',
            'Priority customer support (faster response)',
              'Earn referral commissions (3-level program)',
            'Personalized booking assistance',
            'Flexible booking change requests',
            'Early access to promotional offers',
            'Monthly travel tips & deals newsletter',
          ],
        };
      case 'Premium':
        return {
          'cashback': '6%',
          'bookingFee': 'Standard pricing',
          'support': 'Priority 24/7 (2-6h)',
          'cancellation': 'Priority changes',
          'insurance': 'Not included',
          'loungeAccess': 'Not included',
          'features': [
            'Everything in Basic, plus:',
            '5% cashback on completed bookings',
            '24/7 priority customer support',
              'Higher referral commissions (up to 5%)',
            'Dedicated booking consultant',
            'Priority booking change handling',
            'Exclusive flash sales notifications',
            'Weekly personalized travel deals',
            'Business travel management tools',
          ],
        };
      case 'VIP':
        return {
          'cashback': '10%',
          'bookingFee': 'Standard pricing',
          'support': 'VIP personal assistant 24/7',
          'cancellation': 'VIP priority',
          'insurance': 'Not included',
          'loungeAccess': 'Not included',
          'features': [
            'Everything in Premium, plus:',
            '8% cashback on completed bookings',
            'Dedicated VIP personal travel assistant 24/7',
              'Maximum referral commissions (up to 8%)',
            'Exclusive VIP-only travel promotions',
            'Instant booking change priority',
            'Personalized travel recommendations',
            'Direct phone line to VIP support',
            'Early access to all new features',
            'Invitation to exclusive travel webinars',
            'Custom travel itinerary planning',
          ],
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _getMembershipDetails();

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
            child: Column(
              children: [
                // Header con gradiente del color de la membresía
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withOpacity(0.3),
                        widget.color.withOpacity(0.1),
                        const Color(0xFF1A1A1A),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: widget.color.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Botón de regreso
                        Row(
                          children: [
                            StandardBackButton(
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Spacer(),
                            // Badge si es popular o VIP
                            if (widget.isPopular)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(20),
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
                            if (widget.isVIP)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: widget.color,
                                  borderRadius: BorderRadius.circular(20),
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
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Título de la membresía
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.isVIP)
                              Icon(
                                Icons.diamond,
                                color: widget.color,
                                size: 32,
                              ),
                            if (widget.isVIP) const SizedBox(width: 8),
                            Text(
                              '${widget.title} Membership',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Precio grande
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.price,
                              style: GoogleFonts.outfit(
                                color: widget.color,
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14, left: 4),
                              child: Text(
                                widget.period,
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Descripción corta
                        Text(
                          _getShortDescription(widget.title),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Contenido detallado
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Key Features
                      _buildSectionTitle('Key Features', widget.color),
                      const SizedBox(height: 16),
                      _buildKeyFeaturesGrid(details),
                      
                      const SizedBox(height: 30),
                      
                      // All Benefits
                      _buildSectionTitle('What\'s Included', widget.color),
                      const SizedBox(height: 16),
                      _buildBenefitsList(details['features'] as List<String>),
                      
                      const SizedBox(height: 30),
                      
                      // Comparison with other plans
                      if (widget.title != 'Free')
                        _buildComparisonSection(),
                      
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Floating action button at bottom
        floatingActionButton: widget.isCurrentPlan ? null : _buildUpgradeButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  String _getShortDescription(String title) {
    switch (title) {
      case 'Free':
        return 'Perfect for occasional travelers';
      case 'Basic':
        return 'Great for frequent travelers who want to save';
      case 'Premium':
        return 'Best value for serious travelers';
      case 'VIP':
        return 'Ultimate luxury travel experience';
      default:
        return '';
    }
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyFeaturesGrid(Map<String, dynamic> details) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                'Cashback',
                details['cashback'] ?? '0%',
                Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                'Booking Fee',
                details['bookingFee'] ?? 'Standard',
                Icons.receipt_long,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                'Support',
                details['support'] ?? 'Basic',
                Icons.support_agent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                'Insurance',
                details['insurance'] ?? 'Not included',
                Icons.security,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: widget.color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList(List<String> features) {
    return Column(
      children: features.map((feature) {
        final isHeader = feature.contains('Everything in');
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isHeader)
                Icon(
                  Icons.check_circle,
                  color: widget.color,
                  size: 18,
                ),
              if (!isHeader) const SizedBox(width: 10),
              Expanded(
                child: Text(
                  feature,
                  style: GoogleFonts.outfit(
                    color: isHeader ? widget.color : Colors.white,
                    fontSize: isHeader ? 14 : 13,
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComparisonSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.compare_arrows,
                color: widget.color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Why Choose ${widget.title}?',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildComparisonText(),
        ],
      ),
    );
  }

  Widget _buildComparisonText() {
    String text;
    switch (widget.title) {
      case 'Basic':
        text = 'Basic membership is perfect for travelers who book 2-4 trips per year. '
            'Earn 3% cashback on every completed booking and get priority customer support. '
            'Plus, earn referral bonuses when you invite friends to LandGo Travel!';
        break;
      case 'Premium':
        text = 'Premium membership offers the best value for frequent travelers. '
            'Enjoy 5% cashback, priority 24/7 support, and higher referral commissions. '
            'Ideal for those who travel monthly and want a dedicated booking consultant.';
        break;
      case 'VIP':
        text = 'VIP membership is designed for serious travelers and business professionals. '
            'Get 8% cashback, a dedicated personal travel assistant available 24/7, and '
            'maximum referral commissions (up to 8%). The ultimate LandGo Travel experience.';
        break;
      default:
        text = '';
    }
    
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: Colors.white70,
        fontSize: 13,
        height: 1.5,
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      height: 56,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.color,
            widget.color.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showUpgradeDialog();
          },
          child: Center(
            child: Text(
              'Upgrade to ${widget.title} - ${widget.price}${widget.period}',
              style: GoogleFonts.outfit(
                color: widget.isVIP ? Colors.black : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog() {
    bool dialogTermsAccepted = false; // Estado local del diálogo
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder( // ← SOLUCIÓN: Usar StatefulBuilder
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.color.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.card_membership,
                      color: widget.color,
                      size: 36,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    'Confirm ${widget.title} Membership',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.price}${widget.period}',
                      style: GoogleFonts.outfit(
                        color: widget.color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Divider
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Key Terms (resumen)
                  _buildKeyTerm(
                    icon: Icons.lock_clock,
                    text: '6-month minimum commitment',
                    color: widget.color,
                  ),
                  const SizedBox(height: 12),
                  _buildKeyTerm(
                    icon: Icons.warning_amber,
                    text: 'Early cancellation fee applies',
                    color: widget.color,
                  ),
                  const SizedBox(height: 12),
                  _buildKeyTerm(
                    icon: Icons.schedule,
                    text: '120-day wait to reactivate if cancelled',
                    color: widget.color,
                  ),
                  const SizedBox(height: 12),
                  _buildKeyTerm(
                    icon: Icons.account_balance_wallet,
                    text: 'Cashback held until trip completion',
                    color: widget.color,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Link to full terms
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Cerrar diálogo
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MembershipTermsPageWidget(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article,
                            color: widget.color,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Read Full Terms & Conditions',
                            style: GoogleFonts.outfit(
                              color: widget.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Checkbox de aceptación
                  _buildAcceptanceCheckbox(
                    value: dialogTermsAccepted,
                    onChanged: (val) {
                      setDialogState(() {
                        dialogTermsAccepted = val;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.pop(context),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Confirm button
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.color,
                                widget.color.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: dialogTermsAccepted
                                  ? () {
                                      Navigator.pop(context);
                                      _proceedToPayment();
                                    }
                                  : null,
                              child: Center(
                                child: Text(
                                  'I Accept',
                                  style: GoogleFonts.outfit(
                                    color: dialogTermsAccepted ? Colors.black : Colors.black38,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        ), // Cierre de StatefulBuilder
      ),
    );
  }

  Widget _buildKeyTerm({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptanceCheckbox({required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: value
            ? widget.color.withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? widget.color
              : Colors.white.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Checkbox nativo de Flutter para asegurar la actualización visual
          Checkbox(
            value: value,
            onChanged: (bool? value) {
              onChanged(value ?? false);
            },
            activeColor: widget.color,
            checkColor: Colors.black,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'I have read and agree to the membership terms and conditions',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() async {
    try {
      // 1. Verificar si hay tarjetas guardadas ANTES de crear suscripción
      final hasCards = await _checkSavedCards();
      
      if (!hasCards) {
        _showAddCardDialog();
        return;
      }

      // 2. Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                ),
                const SizedBox(height: 16),
                Text(
                  'Creating Subscription...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // 3. Obtener Price ID
      final priceId = StripeConfig.getPriceId(widget.title);
      
      // 4. Crear suscripción
      final result = await MembershipSubscriptionService.createSubscription(
        membershipType: widget.title,
        priceId: priceId,
      );

      // Cerrar loading
      Navigator.pop(context);

      if (result['success'] == true) {
        // Navegar al flujo de pago de Stripe
        await _processStripePayment(result);
      } else {
        // Mostrar error normal
        final errorMessage = result['error'] ?? 'Subscription creation failed';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      // Cerrar loading si está abierto
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Mostrar error
      _showErrorDialog('Payment processing failed: $e');
    }
  }

  Future<bool> _checkSavedCards() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return false;

      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('stripe_customer_id')
          .eq('id', currentUser.id)
          .single();

      final customerId = profileResponse['stripe_customer_id'];
      if (customerId == null || customerId.isEmpty) return false;

      // Verificar si hay tarjetas guardadas
      final paymentMethodsResponse = await Supabase.instance.client.functions.invoke(
        'stripe-payment',
        body: {
          'action': 'list_payment_methods',
          'customerId': customerId,
        },
      );

      final pmData = paymentMethodsResponse.data as Map<String, dynamic>?;
      final paymentMethods = pmData?['paymentMethods'] as List<dynamic>?;
      
      return paymentMethods != null && paymentMethods.isNotEmpty;
    } catch (e) {
      print('⚠️ Error checking saved cards: $e');
      return false;
    }
  }

  Future<void> _processStripePayment(Map<String, dynamic> subscriptionResult) async {
    try {
      final clientSecret = subscriptionResult['clientSecret'];
      final needsSubscriptionCreation = subscriptionResult['needsSubscriptionCreation'] == true;
      final priceId = subscriptionResult['priceId'];
      final paymentMethodId = subscriptionResult['paymentMethodId'];
      
      if (clientSecret == null) {
        _showErrorDialog('No payment intent received');
        return;
      }

      // Inicializar Stripe Payment Sheet - MOSTRAR TARJETAS GUARDADAS
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.dark,
          merchantDisplayName: 'LandGo Travel',
          customerId: subscriptionResult['customerId'],
          customerEphemeralKeySecret: subscriptionResult['ephemeralKey'], // Necesario para mostrar tarjetas guardadas
          allowsDelayedPaymentMethods: false, // Desactivar métodos BNPL
          appearance: const PaymentSheetAppearance(
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFF4DD0E1),
                  text: Colors.black,
                ),
                dark: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFF4DD0E1),
                  text: Colors.black,
                ),
              ),
            ),
          ),
        ),
      );

      // Mostrar Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // Pago exitoso
      String? subscriptionId;
      
      // Si necesita crear suscripción, hacerlo ahora
      if (needsSubscriptionCreation) {
        print('🔄 Creating subscription after successful payment...');
        final completeResult = await Supabase.instance.client.functions.invoke(
          'stripe-payment',
          body: {
            'action': 'complete_subscription',
            'customerId': subscriptionResult['customerId'],
            'priceId': priceId,
            'userId': Supabase.instance.client.auth.currentUser?.id,
            'membershipType': widget.title,
            'paymentMethodId': paymentMethodId,
          },
        );
        
        final completeData = completeResult.data as Map<String, dynamic>?;
        if (completeData?['success'] == true) {
          subscriptionId = completeData!['subscriptionId'] as String?;
          print('✅ Subscription created: $subscriptionId');
        }
      } else {
        subscriptionId = subscriptionResult['subscriptionId'] as String?;
      }

      // Actualizar membresía en la base de datos
      if (subscriptionId != null) {
        await _updateMembershipInDatabase(subscriptionId);
      }

      // Mostrar éxito
      _showSuccessDialog();

    } catch (e) {
      // Manejar errores de pago
      if (e.toString().contains('canceled') || e.toString().contains('cancelled')) {
        // Usuario canceló - no mostrar error
        return;
      }
      _showErrorDialog('Payment failed: ${e.toString()}');
    }
  }

  Future<void> _updateMembershipInDatabase(String subscriptionId) async {
    try {
      // Actualizar membresía en Supabase
      await Supabase.instance.client
          .from('memberships')
          .update({
            'membership_type': widget.title,
            'stripe_subscription_id': subscriptionId,
            'status': 'active',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', Supabase.instance.client.auth.currentUser?.id ?? '');

      print('✅ Membership updated in database: $subscriptionId');
    } catch (e) {
      print('❌ Error updating membership: $e');
      // No mostrar error al usuario ya que el pago fue exitoso
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.color.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: widget.color,
                    size: 36,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'Welcome to ${widget.title}!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Message
                Text(
                  'Your membership has been activated successfully. You now have access to all ${widget.title} benefits!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Continue button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(context);
                        // Navegar a la pantalla principal
                        context.goNamedAuth('MainPage', context.mounted);
                      },
                      child: Center(
                        child: Text(
                          'Continue to App',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 16,
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
        ),
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'Payment Failed',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          error,
          style: GoogleFonts.outfit(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.outfit(
                color: widget.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.color.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.credit_card,
                    color: widget.color,
                    size: 36,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                Text(
                  'Payment Method Required',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Message
                Text(
                  'You need to add a debit/credit card before subscribing to ${widget.title} membership. Would you like to add a card now?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white24,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.outfit(
                                  color: Colors.white54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Add Card button
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.pop(context); // Cerrar diálogo
                              // Navegar a Payment Methods
                              Navigator.pushNamed(context, '/paymentMethodsPage');
                            },
                            child: Center(
                              child: Text(
                                'Add Card',
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




