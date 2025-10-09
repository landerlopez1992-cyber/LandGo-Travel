import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import '/pages/payment_cards_page/payment_cards_page_widget.dart';
import '/pages/klarna_webview_page/klarna_webview_page_widget.dart';
import '/pages/payment_webview_page/payment_webview_page_widget.dart';
import '/payment/payment_success_pag/payment_success_pag_widget.dart';
import '/pages/payment_failed_pag/payment_failed_pag_widget.dart';
import '/services/klarna_service.dart';
import '/services/afterpay_service.dart';
import '/services/affirm_service.dart';
import '/services/zip_service.dart';
import '/services/cashapp_service.dart';
import '/services/stripe_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'review_summary_page_model.dart';
export 'review_summary_page_model.dart';

class ReviewSummaryPageWidget extends StatefulWidget {
  const ReviewSummaryPageWidget({super.key});

  static const String routeName = 'ReviewSummaryPage';
  static const String routePath = '/reviewSummaryPage';

  @override
  State<ReviewSummaryPageWidget> createState() => _ReviewSummaryPageWidgetState();
}

class _ReviewSummaryPageWidgetState extends State<ReviewSummaryPageWidget> {
  late ReviewSummaryPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Variables para recibir parámetros del modal
  String _amount = '0.00';
  String _selectedPaymentMethod = 'card'; // Default: Credit/Debit Card

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReviewSummaryPageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    
    print('🔍 DEBUG: ReviewSummary initState - _selectedPaymentMethod: $_selectedPaymentMethod');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadParameters();
  }

  void _loadParameters() {
    // Intentar obtener datos del extra
    final route = ModalRoute.of(context);
    print('🔍 DEBUG: Route settings: ${route?.settings}');
    
    final extraData = route?.settings.arguments as Map<String, dynamic>?;
    print('🔍 DEBUG: Extra data: $extraData');
    
    if (extraData != null && extraData.containsKey('amount')) {
      _amount = extraData['amount'] ?? '0.00';
      print('🔍 DEBUG: Loaded amount from extra: $_amount');
    } else {
      print('🔍 DEBUG: No amount found in extra data');
      
      // Fallback: intentar con query parameters
      final routeName = route?.settings.name ?? '';
      print('🔍 DEBUG: Route name: $routeName');
      
      final uri = Uri.parse(routeName);
      final queryParams = uri.queryParameters;
      print('🔍 DEBUG: All query parameters: $queryParams');
      
      if (queryParams.containsKey('amount')) {
        _amount = queryParams['amount'] ?? '0.00';
        print('🔍 DEBUG: Loaded amount from URL: $_amount');
      } else {
        print('🔍 DEBUG: No amount parameter found anywhere');
      }
    }
    
    print('🔍 DEBUG: Final amount: $_amount');
    
    // Forzar rebuild para mostrar los datos actualizados
    if (mounted) {
      setState(() {});
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
                  // Header con botón de regreso - ESTANDARIZADO
                  Row(
                    children: [
                      StandardBackButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Título "Review summary" centrado
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Review summary',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Amount: \$${_amount}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF4DD0E1),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Payment: ${_getPaymentMethodDetails(_selectedPaymentMethod)['name']}',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Booking Details Card
                  _buildBookingDetailsCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Payment Method Card
                  _buildPaymentMethodCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Payment Summary Card
                  _buildPaymentSummaryCard(),
                  
                  const SizedBox(height: 40),
                  
                  // Confirm Payment Button
                  _buildConfirmPaymentButton(),
                  
                  const SizedBox(height: 100), // ESPACIO PARA BOTTOM NAV
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
    // Obtener fecha actual
    final now = DateTime.now();
    final formattedDate = '${_getDayName(now.weekday)}, ${now.day} ${_getMonthName(now.month)} ${now.year}';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Amount to Add', '\$${_amount}'),
          const SizedBox(height: 12),
          _buildDetailRow('Transaction Date', formattedDate),
          const SizedBox(height: 12),
          _buildDetailRow('Transaction Type', 'Wallet Top-up'),
          const SizedBox(height: 12),
          _buildDetailRow('Payment Method', 'To be selected'),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _calculateProcessingFee() {
    try {
      final amount = double.parse(_amount);
      
      // 🆕 FEES DINÁMICOS SEGÚN MÉTODO DE PAGO
      double feePercentage = 0.029; // Default: Credit Card 2.9%
      double fixedFee = 0.30; // Fixed fee for most methods
      
      switch (_selectedPaymentMethod) {
        case 'card':
          feePercentage = 0.029; // 2.9%
          fixedFee = 0.30;
          break;
        case 'klarna':
          feePercentage = 0.0599; // 5.99%
          fixedFee = 0.30;
          break;
        case 'afterpay_clearpay':
          feePercentage = 0.06; // 6.0%
          fixedFee = 0.30;
          break;
        case 'affirm':
          feePercentage = 0.06; // 6.0%
          fixedFee = 0.30;
          break;
        case 'zip':
          feePercentage = 0.055; // 5.5%
          fixedFee = 0.30;
          break;
        case 'cashapp':
          feePercentage = 0.029; // 2.9%
          fixedFee = 0.30;
          break;
        default:
          feePercentage = 0.029; // Default 2.9%
          fixedFee = 0.30;
      }
      
      final fee = (amount * feePercentage) + fixedFee;
      return fee.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  String _calculateSubTotal() {
    try {
      final amount = double.parse(_amount);
      final fee = double.parse(_calculateProcessingFee());
      final total = amount + fee;
      return total.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard() {
    final paymentDetails = _getPaymentMethodDetails(_selectedPaymentMethod);
    final paymentName = paymentDetails['name'] as String;
    final paymentSubtitle = paymentDetails['subtitle'] as String;
    final paymentIcon = paymentDetails['icon'] as IconData;
    final paymentColor = paymentDetails['color'] as Color;
    final logoPath = paymentDetails['logoPath'] as String?;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: "Payment Method" with hint text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Method',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Available Payment Methods',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          
          const SizedBox(height: 16),
          
          // Selected Payment Method
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Payment Method Logo and Details
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: logoPath != null ? Colors.transparent : paymentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: logoPath != null
                        ? Padding(
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              logoPath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to icon if logo fails to load
                                print('❌ Error loading logo: $logoPath - $error');
                                return Icon(
                                  paymentIcon,
                                  color: paymentColor,
                                  size: 26,
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Icon(
                              paymentIcon,
                              color: paymentColor,
                              size: 26,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paymentName,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        paymentSubtitle,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Modern Change Button
              GestureDetector(
                onTap: () => _showPaymentMethodSelector(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4DD0E1).withOpacity(0.15),
                        const Color(0xFF4DD0E1).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4DD0E1).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.swap_horiz_rounded,
                        color: Color(0xFF4DD0E1),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Change',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
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
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Summary',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentRow('Amount to Add', '\$${_amount}'),
          const SizedBox(height: 12),
          _buildPaymentRow('Tax', '\$${_calculateProcessingFee()}'),
          const SizedBox(height: 12),
          _buildPaymentRow('Sub Total', '\$${_calculateSubTotal()}'),
          const SizedBox(height: 12),
          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 12),
          // Total Payment Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount to Pay',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${_calculateSubTotal()}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPaymentButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
            // Calcular el total con fees incluidos
            final totalAmount = _calculateSubTotal();
            
            print('🔍 DEBUG: Processing payment with method: $_selectedPaymentMethod');
            print('🔍 DEBUG: Original Amount: $_amount');
            print('🔍 DEBUG: Total Amount (with fees): $totalAmount');
            
            // 🆕 DETECTAR MÉTODO DE PAGO
            if (_selectedPaymentMethod == 'klarna') {
              await _processKlarnaPayment(totalAmount);
            } else if (_selectedPaymentMethod == 'afterpay_clearpay') {
              await _processAfterpayPayment(totalAmount);
            } else if (_selectedPaymentMethod == 'affirm') {
              await _processAffirmPayment(totalAmount);
            } else if (_selectedPaymentMethod == 'zip') {
              await _processZipPayment(totalAmount);
            } else if (_selectedPaymentMethod == 'cashapp') {
              await _processCashAppPayment(totalAmount);
            } else {
              // FLUJO NORMAL - CREDIT/DEBIT CARD
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentCardsPageWidget(),
                  settings: RouteSettings(
                    arguments: {
                      'amount': totalAmount, // Pasar el total con fees incluidos
                      'paymentMethod': _selectedPaymentMethod,
                    },
                  ),
                ),
              );
            }
          },
          child: Center(
            child: Text(
              'Confirm payment',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getPaymentMethodDetails(String methodId) {
    final methods = {
      'card': {
        'name': 'Credit/Debit Card',
        'subtitle': 'Visa, Mastercard, Amex',
        'icon': Icons.credit_card,
        'logoPath': 'assets/images/payment_logos/card_logo.png',
        'color': const Color(0xFF635BFF),
      },
      if (isiOS) 'apple_pay': {
        'name': 'Apple Pay',
        'subtitle': 'Quick and secure',
        'icon': Icons.apple,
        'logoPath': 'assets/images/payment_logos/apple_pay_logo.png',
        'color': const Color(0xFF000000),
      },
      if (isAndroid) 'google_pay': {
        'name': 'Google Pay',
        'subtitle': 'Fast checkout',
        'icon': Icons.account_balance_wallet,
        'logoPath': 'assets/images/payment_logos/google_pay_logo.png',
        'color': const Color(0xFF4285F4),
      },
      'cashapp': {
        'name': 'Cash App Pay',
        'subtitle': 'Pay with Cash App',
        'icon': Icons.attach_money,
        'logoPath': 'assets/images/payment_logos/cashapp_logo.png',
        'color': const Color(0xFF00D54B),
      },
      'klarna': {
        'name': 'Klarna',
        'subtitle': 'Pay in 4 payments',
        'icon': Icons.schedule,
        'logoPath': 'assets/images/payment_logos/klarna_logo.png',
        'color': const Color(0xFFFFB3C7),
      },
      'afterpay_clearpay': {
        'name': 'Afterpay/Clearpay',
        'subtitle': '4 interest-free payments',
        'icon': Icons.payment,
        'logoPath': 'assets/images/payment_logos/afterpay_logo.png',
        'color': const Color(0xFFB2FCE4),
      },
      'affirm': {
        'name': 'Affirm',
        'subtitle': 'Monthly payments',
        'icon': Icons.calendar_month,
        'logoPath': 'assets/images/payment_logos/affirm_logo.png',
        'color': const Color(0xFF00AAC4),
      },
      'us_bank_account': {
        'name': 'ACH Direct Debit',
        'subtitle': 'Bank transfer',
        'icon': Icons.account_balance,
        'logoPath': 'assets/images/payment_logos/us_bank_account_logo.png',
        'color': const Color(0xFF4DD0E1),
      },
      'alipay': {
        'name': 'Alipay',
        'subtitle': 'Popular in Asia',
        'icon': Icons.payment,
        'logoPath': 'assets/images/payment_logos/alipay_logo.png',
        'color': const Color(0xFF00A0E9),
      },
      'wechat_pay': {
        'name': 'WeChat Pay',
        'subtitle': 'China payment',
        'icon': Icons.chat,
        'logoPath': 'assets/images/payment_logos/wechat_pay_logo.png',
        'color': const Color(0xFF09BB07),
      },
      'zip': {
        'name': 'Zip',
        'subtitle': 'Buy now, pay later',
        'icon': Icons.payment,
        'logoPath': 'assets/images/payment_logos/zip_logo.png',
        'color': const Color(0xFFE91E63),
      },
    };
    
    return methods[methodId] ?? methods['card']!;
  }

  void _showPaymentMethodSelector() {
    print('🔍 DEBUG: Opening payment method selector');
    print('🔍 DEBUG: Current selected method: $_selectedPaymentMethod');
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PaymentMethodSelectorContent(
        selectedPaymentMethod: _selectedPaymentMethod,
      ),
    ).then((result) {
      print('🔍 DEBUG: Payment method selector result: $result');
      if (result != null) {
        setState(() {
          _selectedPaymentMethod = result;
          print('🔍 DEBUG: Updated selected method to: $_selectedPaymentMethod');
        });
      }
    });
  }

  /// 🆕 PROCESAR PAGO CON KLARNA
  Future<void> _processKlarnaPayment(String totalAmountStr) async {
    try {
      print('🔍 DEBUG: Iniciando flujo de Klarna');
      
      // Convertir String a double
      final totalAmount = double.parse(totalAmountStr);
      final amountWithoutFee = double.parse(_amount);
      
      // 1. Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Creating Klarna session...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // 2. Obtener usuario actual
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        if (mounted) Navigator.of(context).pop();
        _showErrorDialog('User not logged in');
        return;
      }

      // 3. Obtener/Crear Stripe Customer ID y nombre completo
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('stripe_customer_id, full_name')
          .eq('id', currentUser.id)
          .maybeSingle();
      
      String? stripeCustomerId = profileResponse?['stripe_customer_id'];
      final String fullName = (profileResponse?['full_name'] as String?)?.trim().isNotEmpty == true
          ? (profileResponse!['full_name'] as String)
          : 'Customer';

      // 3.1 Validar billing address y datos de contacto del perfil
      final validation = await StripeService.validateBillingAddress();
      if (validation == null || validation['valid'] != true) {
        if (mounted) Navigator.of(context).pop();
        _showErrorDialog(validation?['message'] ?? 'Billing address incomplete. Please complete your billing address.');
        return;
      }

      final String userEmail = validation['email'] as String? ?? '';
      final String userPhone = validation['phone'] as String? ?? '';
      final Map<String, dynamic> billingAddress = Map<String, dynamic>.from(validation['billing_address'] as Map);

      // 4. Crear sesión de Klarna
      final session = await KlarnaService.createKlarnaSession(
        amount: totalAmount,
        userId: currentUser.id,
        customerId: stripeCustomerId,
        billingDetails: {
          'name': fullName,
          'email': userEmail,
          'phone': userPhone,
          'address': billingAddress,
        },
      );

      print('✅ Klarna session created');
      print('✅ Payment Intent ID: ${session['paymentIntentId']}');

      // Cerrar loading
      if (mounted) Navigator.of(context).pop();

      // 5. Abrir Webview con Klarna
      // Preferir la URL oficial devuelta por el backend (redirectUrl)
      final redirectUrl = (session['redirectUrl'] as String?)?.trim();
      final checkoutUrl = (redirectUrl != null && redirectUrl.isNotEmpty)
          ? redirectUrl
          : KlarnaService.getKlarnaCheckoutUrl(session['clientSecret']);
      
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KlarnaWebviewPageWidget(
            checkoutUrl: checkoutUrl,
            returnUrl: 'landgotravel://payment-return',
            paymentIntentId: session['paymentIntentId'],
          ),
        ),
      );

      // 6. Manejar resultado
      if (result == null) {
        print('🔄 User closed Webview without completing');
        return;
      }

      final status = result['status'];
      final paymentIntentId = result['paymentIntentId'];

      print('🔍 DEBUG: Klarna result status: $status');

      if (status == 'success') {
        // Pago exitoso
        print('✅ Klarna payment successful');
        
        // Confirmar el estado del pago
        final confirmation = await KlarnaService.confirmKlarnaPayment(
          paymentIntentId: paymentIntentId,
        );

        if (confirmation['status'] == 'succeeded') {
          // Actualizar wallet
          await _updateWalletBalance(amountWithoutFee, paymentIntentId);
          
          // Navegar a PaymentSuccess con datos
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentSuccessPagWidget(),
                settings: RouteSettings(
                  arguments: {
                    'paymentIntentId': paymentIntentId,
                    'chargeId': 'N/A',
                    'customerName': 'Customer',
                    'cardBrand': 'Klarna',
                    'cardLast4': 'N/A',
                    'cardExpiry': 'N/A',
                    'amount': amountWithoutFee.toString(),
                    'currency': 'USD',
                    'alreadyPersisted': true, // ✅ Ya fue persistido en _updateWalletBalance
                  },
                ),
              ),
            );
          }
        } else if (confirmation['status'] == 'requires_payment_method') {
          // Klarna denegó el pago
          print('⚠️ Payment was declined by Klarna');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentFailedPagWidget(),
                settings: RouteSettings(
                  arguments: {
                    'amount': totalAmountStr,
                    'paymentMethod': 'Klarna',
                    'error': 'Payment was declined. Please try another payment method.',
                  },
                ),
              ),
            );
          }
        } else if (confirmation['status'] == 'canceled') {
          print('⚠️ Payment was cancelled by user');
          // Usuario canceló, no hacer nada
        } else {
          _showErrorDialog('Payment is ${confirmation['status']}. We\'ll notify you when it\'s complete.');
        }
      } else if (status == 'failed') {
        // Usuario hizo clic en "FAIL TEST PAYMENT" dentro del webview
        print('❌ Klarna payment intentionally failed (FAIL TEST PAYMENT)');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentFailedPagWidget(),
              settings: RouteSettings(
                arguments: {
                  'amount': totalAmountStr,
                  'paymentMethod': 'Klarna',
                  'error': 'Payment was declined. This is a test failure.',
                },
              ),
            ),
          );
        }
      } else if (status == 'cancelled') {
        print('🔄 User cancelled Klarna payment (closed webview)');
        // Usuario canceló explícitamente (cerró webview), no hacer nada
      } else {
        print('⚠️ Unknown payment status: $status');
        _showErrorDialog('Payment status: $status');
      }
    } catch (e) {
      print('❌ ERROR in Klarna payment: $e');
      if (mounted) Navigator.of(context).pop();
      _showErrorDialog('Error processing Klarna payment: $e');
    }
  }

  /// 🆕 PROCESAR PAGO CON AFTERPAY
  Future<void> _processAfterpayPayment(String totalAmountStr) async {
    try {
      print('🔍 DEBUG: Iniciando flujo de Afterpay');
      
      // Convertir String a double
      final totalAmount = double.parse(totalAmountStr);
      final amountWithoutFee = double.parse(_amount);
      
      // 1. Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Creating Afterpay session...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // 2. Obtener usuario actual
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        if (mounted) Navigator.of(context).pop();
        _showErrorDialog('User not logged in');
        return;
      }

      // 3. Obtener/Crear Stripe Customer ID y nombre completo
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('stripe_customer_id, full_name')
          .eq('id', currentUser.id)
          .maybeSingle();
      
      String? stripeCustomerId = profileResponse?['stripe_customer_id'];
      final String fullName = (profileResponse?['full_name'] as String?)?.trim().isNotEmpty == true
          ? (profileResponse!['full_name'] as String)
          : 'Customer';

      // 3.1 Validar billing address y datos de contacto del perfil
      final validation = await StripeService.validateBillingAddress();
      if (validation == null || validation['valid'] != true) {
        if (mounted) Navigator.of(context).pop();
        _showErrorDialog(validation?['message'] ?? 'Billing address incomplete. Please complete your billing address.');
        return;
      }

      final String userEmail = validation['email'] as String? ?? '';
      final String userPhone = validation['phone'] as String? ?? '';
      final Map<String, dynamic> billingAddress = Map<String, dynamic>.from(validation['billing_address'] as Map);

      // 4. Crear sesión de Afterpay
      final session = await AfterpayService.createAfterpaySession(
        amount: totalAmount,
        customerId: stripeCustomerId ?? '',
        billingDetails: {
          'name': fullName,
          'email': userEmail,
          'phone': userPhone,
          'address': billingAddress,
        },
      );

      print('✅ Afterpay session created');
      print('✅ Payment Intent ID: ${session['paymentIntentId']}');

      // Cerrar loading
      if (mounted) Navigator.of(context).pop();

      // 5. Abrir Webview con Afterpay
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebviewPageWidget(
            checkoutUrl: session['redirectUrl'],
            returnUrl: 'landgotravel://payment-return',
            paymentIntentId: session['paymentIntentId'],
            paymentMethodName: 'Afterpay',
          ),
        ),
      );

      // 6. Manejar resultado
      if (result == null) {
        print('🔄 User closed Afterpay Webview without completing');
        return;
      }

      final status = result['status'];
      final paymentIntentId = result['paymentIntentId'];

      print('🔍 DEBUG: Afterpay result status: $status');
      print('🔍 DEBUG: PaymentIntent ID: $paymentIntentId');

      if (status == 'success') {
        // Pago exitoso (aparentemente)
        print('✅ Afterpay payment successful - VERIFYING with Stripe...');
        
        // ⚠️ VERIFICAR EL ESTADO REAL del pago con Stripe
        final confirmation = await AfterpayService.confirmAfterpayPayment(
          paymentIntentId: paymentIntentId,
        );

        print('🔍 DEBUG: Payment Intent status from Stripe: ${confirmation['status']}');
        print('🔍 DEBUG: Full confirmation response: $confirmation');

        // Solo actualizar wallet si el pago realmente fue exitoso
        if (confirmation['status'] == 'succeeded') {
          print('✅ Payment confirmed as SUCCEEDED by Stripe');
          print('🔍 DEBUG: About to update wallet balance with amount: $amountWithoutFee');
          // Actualizar wallet
          await _updateWalletBalance(amountWithoutFee, paymentIntentId);
          print('✅ DEBUG: Wallet balance updated successfully');
          
          // Navegar a PaymentSuccess con datos del pago
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentSuccessPagWidget(),
                settings: RouteSettings(
                  arguments: {
                    'paymentIntentId': paymentIntentId,
                    'chargeId': 'N/A', // Afterpay no usa charge ID tradicional
                    'customerName': fullName,
                    'cardBrand': 'Afterpay',
                    'cardLast4': 'N/A',
                    'cardExpiry': 'N/A',
                    'amount': amountWithoutFee.toString(),
                    'currency': 'USD',
                    'alreadyPersisted': true, // ✅ Ya fue persistido en _updateWalletBalance
                  },
                ),
              ),
            );
          }
        } else if (confirmation['status'] == 'requires_payment_method') {
          // El pago fue denegado/cancelado por Afterpay
          print('⚠️ Payment was declined by Afterpay');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentFailedPagWidget(),
                settings: RouteSettings(
                  arguments: {
                    'amount': totalAmountStr,
                    'paymentMethod': 'Afterpay',
                    'error': 'Payment was declined. Please try another payment method or contact your bank.',
                  },
                ),
              ),
            );
          }
        } else if (confirmation['status'] == 'canceled') {
          print('⚠️ Payment was cancelled by user');
          // Usuario canceló, no hacer nada (solo cerrar webview)
        } else {
          print('⚠️ Unexpected payment status: ${confirmation['status']}');
          _showErrorDialog('Payment is ${confirmation['status']}. We\'ll notify you when it\'s complete.');
        }
      } else if (status == 'failed') {
        // Usuario hizo clic en "FAIL TEST PAYMENT" dentro del webview
        print('❌ Payment intentionally failed (FAIL TEST PAYMENT)');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentFailedPagWidget(),
              settings: RouteSettings(
                arguments: {
                  'amount': totalAmountStr,
                  'paymentMethod': 'Afterpay',
                  'error': 'Payment was declined. This is a test failure.',
                },
              ),
            ),
          );
        }
      } else if (status == 'cancelled') {
        print('🔄 User cancelled Afterpay payment (closed webview)');
        // Usuario canceló explícitamente (cerró webview), no hacer nada
      } else {
        print('⚠️ Unknown payment status: $status');
        _showErrorDialog('Payment status: $status');
      }
    } catch (e) {
      print('❌ ERROR in Afterpay payment: $e');
      if (mounted) Navigator.of(context).pop();
      _showErrorDialog('Error processing Afterpay payment: $e');
    }
  }

  /// 🆕 PROCESAR PAGO CON AFFIRM
  Future<void> _processAffirmPayment(String totalAmountStr) async {
    try {
      print('🔍 DEBUG: Iniciando flujo de Affirm');
      
      // Convertir String a double
      final totalAmount = double.parse(totalAmountStr);
      final amountWithoutFee = double.parse(_amount); // Monto sin fees
      
      print('🔍 DEBUG: Total Amount (with fees): \$${totalAmount.toStringAsFixed(2)}');
      print('🔍 DEBUG: Amount without fees: \$${amountWithoutFee.toStringAsFixed(2)}');

      // ⚠️ VERIFICAR MONTO MÍNIMO DE AFFIRM ($35.00)
      if (totalAmount < 35.00) {
        _showErrorDialog(
          'Affirm requires a minimum amount of \$35.00 USD.\n\n'
          'Your current amount: \$${totalAmount.toStringAsFixed(2)}\n\n'
          'Please increase the amount or use another payment method (Credit Card, Klarna, or Afterpay).'
        );
        return;
      }

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
          ),
        ),
      );

      // 1. Obtener usuario actual
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        if (mounted) Navigator.of(context).pop();
        _showErrorDialog('User not authenticated');
        return;
      }

      // 2. Obtener/Crear Stripe Customer ID y nombre completo
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('stripe_customer_id, full_name')
          .eq('id', currentUser.id)
          .maybeSingle();

      String? stripeCustomerId = profileResponse?['stripe_customer_id'];
      final String fullName = (profileResponse?['full_name'] as String?)?.trim().isNotEmpty == true
          ? (profileResponse!['full_name'] as String)
          : 'Customer';

      // 3.1 Validar billing address y datos de contacto del perfil
      final validation = await StripeService.validateBillingAddress();
      if (validation == null || validation['valid'] != true) {
        if (mounted) Navigator.of(context).pop();
        _showErrorDialog(validation?['message'] ?? 'Billing address incomplete. Please complete your billing address.');
        return;
      }

      final String userEmail = validation['email'] as String? ?? '';
      final String userPhone = validation['phone'] as String? ?? '';
      final Map<String, dynamic> billingAddress = Map<String, dynamic>.from(validation['billing_address'] as Map);

      // 4. Crear sesión de Affirm
      final session = await AffirmService.createAffirmSession(
        amount: totalAmount,
        customerId: stripeCustomerId ?? '',
        billingDetails: {
          'name': fullName,
          'email': userEmail,
          'phone': userPhone,
          'address': billingAddress,
        },
      );

      if (mounted) Navigator.of(context).pop(); // Cerrar loading

      // 5. Abrir webview de Affirm
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebviewPageWidget(
            checkoutUrl: session['redirectUrl'] ?? '',
            returnUrl: 'landgotravel://payment-return',
            paymentIntentId: session['paymentIntentId'] ?? '',
            paymentMethodName: 'Affirm',
          ),
        ),
      );

      // 6. Manejar resultado
      if (result == null) {
        print('🔄 User closed Affirm Webview without completing');
        return;
      }

      final status = result['status'];
      final paymentIntentId = result['paymentIntentId'];

      print('🔍 DEBUG: Affirm result status: $status');

      if (status == 'success') {
        // Pago exitoso (aparentemente)
        print('✅ Affirm payment successful');

        // ⚠️ VERIFICAR EL ESTADO REAL del pago con Stripe
        final confirmation = await AffirmService.confirmAffirmPayment(
          paymentIntentId: paymentIntentId,
        );

        print('🔍 DEBUG: Payment Intent status from Stripe: ${confirmation['status']}');

        // Solo actualizar wallet si el pago realmente fue exitoso
        if (confirmation['status'] == 'succeeded') {
          print('✅ Payment confirmed as SUCCEEDED by Stripe');
          // Actualizar wallet
          await _updateWalletBalance(amountWithoutFee, paymentIntentId);

          // Navegar a PaymentSuccess con datos del pago
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentSuccessPagWidget(),
                settings: RouteSettings(
                  arguments: {
                    'paymentIntentId': paymentIntentId,
                    'chargeId': 'N/A', // Affirm no usa charge ID tradicional
                    'customerName': fullName,
                    'cardBrand': 'Affirm',
                    'cardLast4': 'N/A',
                    'cardExpiry': 'N/A',
                    'amount': amountWithoutFee.toString(),
                    'currency': 'USD',
                    'alreadyPersisted': true,
                  },
                ),
              ),
            );
          }
        } else if (confirmation['status'] == 'requires_payment_method') {
          // El pago fue denegado/cancelado por Affirm
          print('⚠️ Payment was declined by Affirm');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentFailedPagWidget(),
                settings: RouteSettings(
                  arguments: {
                    'amount': totalAmountStr,
                    'paymentMethod': 'Affirm',
                    'error': 'Payment was declined. Please try another payment method or contact your bank.',
                  },
                ),
              ),
            );
          }
        } else if (confirmation['status'] == 'canceled') {
          print('⚠️ Payment was cancelled by user');
          // Usuario canceló, no hacer nada (solo cerrar webview)
        } else {
          print('⚠️ Unexpected payment status: ${confirmation['status']}. Full confirmation response: $confirmation');
          _showErrorDialog('Payment is ${confirmation['status']}. We\'ll notify you when it\'s complete.');
        }
      } else if (status == 'failed') {
        // Usuario hizo clic en "FAIL TEST PAYMENT" dentro del webview
        print('❌ Payment intentionally failed (FAIL TEST PAYMENT)');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentFailedPagWidget(),
              settings: RouteSettings(
                arguments: {
                  'amount': totalAmountStr,
                  'paymentMethod': 'Affirm',
                  'error': 'Payment was declined. This is a test failure.',
                },
              ),
            ),
          );
        }
      } else if (status == 'cancelled') {
        print('🔄 User cancelled Affirm payment (closed webview)');
        // Usuario canceló explícitamente (cerró webview), no hacer nada
      } else {
        print('⚠️ Unknown payment status: $status');
        _showErrorDialog('Payment status: $status');
      }
    } catch (e) {
      print('❌ ERROR in Affirm payment: $e');
      if (mounted) Navigator.of(context).pop();
      _showErrorDialog('Error processing Affirm payment: $e');
    }
  }

  /// 🆕 PROCESAR PAGO CON ZIP
  Future<void> _processZipPayment(String totalAmountStr) async {
    try {
      print('🔍 DEBUG: Iniciando flujo de Zip');
      
      // Convertir String a double
      final totalAmount = double.parse(totalAmountStr);
      final amountWithoutFee = double.parse(_amount); // Monto sin fees
      
      print('🔍 DEBUG: Total Amount (with fees): \$${totalAmount.toStringAsFixed(2)}');
      print('🔍 DEBUG: Amount without fees: \$${amountWithoutFee.toStringAsFixed(2)}');

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
          ),
        ),
      );

      // 1. Obtener usuario actual
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        if (mounted) Navigator.of(context).pop();
        _showErrorDialog('User not authenticated');
        return;
      }

      // 2. Obtener/Crear Stripe Customer ID y nombre completo
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('stripe_customer_id, full_name')
          .eq('id', currentUser.id)
          .maybeSingle();

      String? stripeCustomerId = profileResponse?['stripe_customer_id'];
      final String fullName = (profileResponse?['full_name'] as String?)?.trim().isNotEmpty == true
          ? (profileResponse!['full_name'] as String)
          : 'Customer';

      // 3.1 Validar billing address y datos de contacto del perfil
      final validation = await StripeService.validateBillingAddress();
      if (validation == null || validation['valid'] != true) {
        if (mounted) Navigator.of(context).pop();
        _showErrorDialog(validation?['message'] ?? 'Billing address incomplete. Please complete your billing address.');
        return;
      }

      final String userEmail = validation['email'] as String? ?? '';
      final String userPhone = validation['phone'] as String? ?? '';
      final Map<String, dynamic> billingAddress = Map<String, dynamic>.from(validation['billing_address'] as Map);

      // 4. Crear sesión de Zip
      final session = await ZipService.createZipSession(
        amount: totalAmount,
        customerId: stripeCustomerId ?? '',
        billingDetails: {
          'name': fullName,
          'email': userEmail,
          'phone': userPhone,
          'address': billingAddress,
        },
      );

      if (mounted) Navigator.of(context).pop(); // Cerrar loading

      // 5. Abrir webview de Zip
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebviewPageWidget(
            checkoutUrl: session['redirectUrl'] ?? '',
            returnUrl: 'landgotravel://payment-return',
            paymentIntentId: session['paymentIntentId'] ?? '',
            paymentMethodName: 'Zip',
          ),
        ),
      );

      // 6. Manejar resultado
      if (result == null) {
        print('🔄 User closed Zip Webview without completing');
        return;
      }

      final status = result['status'];
      final paymentIntentId = result['paymentIntentId'];

      print('🔍 DEBUG: Zip result status: $status');

      if (status == 'success') {
        // Pago exitoso (aparentemente)
        print('✅ Zip payment successful');

        // ⚠️ VERIFICAR EL ESTADO REAL del pago con Stripe
        final confirmation = await ZipService.confirmZipPayment(
          paymentIntentId: paymentIntentId,
        );

        print('🔍 DEBUG: Payment Intent status from Stripe: ${confirmation['status']}');

        // Solo actualizar wallet si el pago realmente fue exitoso
        if (confirmation['status'] == 'succeeded') {
          print('✅ Payment confirmed as SUCCEEDED by Stripe');
          // Actualizar wallet
          await _updateWalletBalance(amountWithoutFee, paymentIntentId);

          // Navegar a PaymentSuccess con datos del pago
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentSuccessPagWidget(),
                settings: RouteSettings(
                  arguments: {
                    'paymentIntentId': paymentIntentId,
                    'chargeId': 'N/A', // Zip no usa charge ID tradicional
                    'customerName': fullName,
                    'cardBrand': 'Zip',
                    'cardLast4': 'N/A',
                    'cardExpiry': 'N/A',
                    'amount': amountWithoutFee.toString(),
                    'currency': 'USD',
                    'alreadyPersisted': true,
                  },
                ),
              ),
            );
          }
        } else if (confirmation['status'] == 'requires_payment_method') {
          // El pago fue denegado/cancelado por Zip
          print('⚠️ Payment was declined by Zip');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentFailedPagWidget(),
                settings: RouteSettings(
                  arguments: {
                    'amount': totalAmountStr,
                    'paymentMethod': 'Zip',
                    'error': 'Payment was declined. Please try another payment method or contact your bank.',
                  },
                ),
              ),
            );
          }
        } else if (confirmation['status'] == 'canceled') {
          print('⚠️ Payment was cancelled by user');
          // Usuario canceló, no hacer nada (solo cerrar webview)
        } else {
          print('⚠️ Unexpected payment status: ${confirmation['status']}. Full confirmation response: $confirmation');
          _showErrorDialog('Payment is ${confirmation['status']}. We\'ll notify you when it\'s complete.');
        }
      } else if (status == 'failed') {
        // Usuario hizo clic en "FAIL TEST PAYMENT" dentro del webview
        print('❌ Payment intentionally failed (FAIL TEST PAYMENT)');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PaymentFailedPagWidget(),
              settings: RouteSettings(
                arguments: {
                  'amount': totalAmountStr,
                  'paymentMethod': 'Zip',
                  'error': 'Payment was declined. This is a test failure.',
                },
              ),
            ),
          );
        }
      } else if (status == 'cancelled') {
        print('🔄 User cancelled Zip payment (closed webview)');
        // Usuario canceló explícitamente (cerró webview), no hacer nada
      } else {
        print('⚠️ Unknown payment status: $status');
        _showErrorDialog('Payment status: $status');
      }
    } catch (e) {
      print('❌ ERROR in Zip payment: $e');
      if (mounted) Navigator.of(context).pop();
      _showErrorDialog('Error processing Zip payment: $e');
    }
  }

  // 🆕 CASH APP PAYMENT PROCESSING
  Future<void> _processCashAppPayment(String totalAmountStr) async {
    try {
      print('🔍 DEBUG: Iniciando flujo de Cash App');
      
      // Convertir String a double
      final totalAmount = double.parse(totalAmountStr);
      final amountWithoutFee = double.parse(_amount); // Monto sin fees
      
      print('🔍 DEBUG: Total Amount (with fees): \$${totalAmount.toStringAsFixed(2)}');
      print('🔍 DEBUG: Amount without fees: \$${amountWithoutFee.toStringAsFixed(2)}');

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
          ),
        ),
      );

      // 1. Obtener usuario actual
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        if (mounted) Navigator.of(context).pop();
        _showErrorDialog('User not authenticated');
        return;
      }

      // 2. Obtener/Crear Stripe Customer ID y nombre completo
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('stripe_customer_id, full_name')
          .eq('id', currentUser.id)
          .maybeSingle();

      String? stripeCustomerId = profileResponse?['stripe_customer_id'];
      final String fullName = (profileResponse?['full_name'] as String?)?.trim().isNotEmpty == true
          ? (profileResponse!['full_name'] as String)
          : 'Customer';

      // 3.1 Validar billing address y datos de contacto del perfil
      final validation = await StripeService.validateBillingAddress();
      if (validation == null || validation['valid'] != true) {
        if (mounted) Navigator.of(context).pop();
        _showErrorDialog(validation?['message'] ?? 'Billing address incomplete. Please complete your billing address.');
        return;
      }

      final String userEmail = validation['email'] as String? ?? '';
      final String userPhone = validation['phone'] as String? ?? '';
      final Map<String, dynamic> billingAddress = validation['address'] as Map<String, dynamic>? ?? {};

      // 3.2 Crear/Actualizar Stripe Customer si no existe
      if (stripeCustomerId == null) {
        print('🔍 DEBUG: Creating new Stripe customer for Cash App');
        final customerId = await StripeService.createCustomer(
          email: userEmail,
          name: fullName,
          phone: userPhone,
        );
        stripeCustomerId = customerId;
      }

      // 4. Crear sesión de Cash App
      print('🔍 DEBUG: Creating Cash App session');
      final sessionResult = await CashAppService.createCashAppSession(
        amount: totalAmount,
        customerId: stripeCustomerId!,
        billingDetails: {
          'name': fullName,
          'email': userEmail,
          'phone': userPhone,
          'address': billingAddress,
        },
      );

      if (!sessionResult['success']) {
        if (mounted) Navigator.of(context).pop();
        _showErrorDialog('Failed to create Cash App session');
        return;
      }

      final redirectUrl = sessionResult['redirectUrl'];
      final paymentIntentId = sessionResult['paymentIntentId'];

      print('🔍 DEBUG: Cash App session created, redirectUrl: $redirectUrl');

      if (redirectUrl == null) {
        if (mounted) Navigator.of(context).pop();
        _showErrorDialog('No redirect URL received from Cash App');
        return;
      }

      // 5. Abrir webview para Cash App
      if (mounted) {
        Navigator.of(context).pop(); // Cerrar loading
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebviewPageWidget(
              checkoutUrl: redirectUrl,
              returnUrl: 'landgotravel://payment-return',
              paymentIntentId: paymentIntentId,
              paymentMethodName: 'Cash App',
            ),
          ),
        );

        print('🔍 DEBUG: Cash App webview result: $result');

        if (result == null) {
          print('🔄 User cancelled Cash App payment (closed webview)');
          return;
        }

        final status = result['status'];
        final returnedPaymentIntentId = result['paymentIntentId'];

        print('🔍 DEBUG: Cash App result status: $status');

        if (status == 'success') {
          // Pago exitoso (aparentemente)
          print('✅ Cash App payment successful');

          // ⚠️ VERIFICAR EL ESTADO REAL del pago con Stripe
          final confirmation = await CashAppService.confirmCashAppPayment(
            paymentIntentId: returnedPaymentIntentId,
          );

          print('🔍 DEBUG: Payment Intent status from Stripe: ${confirmation['status']}');

          // Solo actualizar wallet si el pago realmente fue exitoso
          if (confirmation['status'] == 'succeeded') {
            print('✅ Payment confirmed as SUCCEEDED by Stripe');
            // Actualizar wallet
            await _updateWalletBalance(amountWithoutFee, returnedPaymentIntentId);

            // Navegar a PaymentSuccess con datos del pago
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentSuccessPagWidget(),
                  settings: RouteSettings(
                    arguments: {
                      'paymentIntentId': returnedPaymentIntentId,
                      'chargeId': 'N/A', // Cash App no usa charge ID tradicional
                      'customerName': fullName,
                      'cardBrand': 'Cash App',
                      'cardLast4': 'N/A',
                      'cardExpiry': 'N/A',
                      'amount': amountWithoutFee.toString(),
                      'currency': 'USD',
                      'alreadyPersisted': true,
                    },
                  ),
                ),
              );
            }
          } else if (confirmation['status'] == 'requires_payment_method') {
            // El pago fue denegado/cancelado por Cash App
            print('⚠️ Payment was declined by Cash App');
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentFailedPagWidget(),
                  settings: RouteSettings(
                    arguments: {
                      'amount': totalAmountStr,
                      'paymentMethod': 'Cash App',
                      'error': 'Payment was declined. Please try another payment method or contact your bank.',
                    },
                  ),
                ),
              );
            }
          } else if (confirmation['status'] == 'canceled') {
            print('⚠️ Payment was cancelled by user');
            // Usuario canceló, no hacer nada (solo cerrar webview)
          } else {
            print('⚠️ Unexpected payment status: ${confirmation['status']}. Full confirmation response: $confirmation');
            _showErrorDialog('Payment is ${confirmation['status']}. We\'ll notify you when it\'s complete.');
          }
        } else if (status == 'failed') {
          // Usuario hizo clic en "FAIL TEST PAYMENT" dentro del webview
          print('❌ Payment intentionally failed (FAIL TEST PAYMENT)');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentFailedPagWidget(),
                settings: RouteSettings(
                  arguments: {
                    'amount': totalAmountStr,
                    'paymentMethod': 'Cash App',
                    'error': 'Payment was declined. This is a test failure.',
                  },
                ),
              ),
            );
          }
        } else if (status == 'cancelled') {
          print('🔄 User cancelled Cash App payment (closed webview)');
          // Usuario canceló explícitamente (cerró webview), no hacer nada
        } else {
          print('⚠️ Unknown payment status: $status');
          _showErrorDialog('Payment status: $status');
        }
      }
    } catch (e) {
      print('❌ ERROR in Cash App payment: $e');
      if (mounted) Navigator.of(context).pop();
      _showErrorDialog('Error processing Cash App payment: $e');
    }
  }

  /// Actualizar balance del wallet
  Future<void> _updateWalletBalance(double amount, String paymentIntentId) async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;

      // Obtener balance actual
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('cashback_balance')
          .eq('id', currentUser.id)
          .single();

      final currentBalance = (profileResponse['cashback_balance'] ?? 0.0) as num;
      final newBalance = currentBalance.toDouble() + amount;

      // Actualizar balance
      await Supabase.instance.client
          .from('profiles')
          .update({'cashback_balance': newBalance})
          .eq('id', currentUser.id);

      // Registrar transacción
      String paymentMethod = 'afterpay'; // Default
      String methodName = 'Afterpay'; // Default
      
      if (_selectedPaymentMethod == 'klarna') {
        paymentMethod = 'klarna';
        methodName = 'Klarna';
      } else if (_selectedPaymentMethod == 'affirm') {
        paymentMethod = 'affirm';
        methodName = 'Affirm';
      } else if (_selectedPaymentMethod == 'zip') {
        paymentMethod = 'zip';
        methodName = 'Zip';
      } else if (_selectedPaymentMethod == 'cashapp') {
        paymentMethod = 'cashapp';
        methodName = 'Cash App';
      }

      await Supabase.instance.client.from('payments').insert({
        'user_id': currentUser.id,
        'amount': amount,
        'payment_method': paymentMethod,
        'status': 'completed',
        'related_type': 'wallet_topup',
        'description': 'Wallet top-up via $methodName (PaymentIntent: $paymentIntentId)',
      });

      print('✅ Wallet balance updated: \$${currentBalance.toStringAsFixed(2)} → \$${newBalance.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ ERROR updating wallet balance: $e');
      rethrow;
    }
  }

  /// Mostrar diálogo de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'Payment Error',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
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

// WIDGET SEPARADO PARA EL SELECTOR DE MÉTODOS DE PAGO
class _PaymentMethodSelectorContent extends StatefulWidget {
  final String selectedPaymentMethod;

  const _PaymentMethodSelectorContent({
    required this.selectedPaymentMethod,
  });

  @override
  State<_PaymentMethodSelectorContent> createState() => _PaymentMethodSelectorContentState();
}

class _PaymentMethodSelectorContentState extends State<_PaymentMethodSelectorContent> {
  late String _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.selectedPaymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Modal Header (Fixed)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Payment Method',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            
            // Payment Methods - SELECCIONABLES
            // TARJETAS DE CRÉDITO/DÉBITO
            _buildPaymentMethod(
              'Credit/Debit Card',
              'Visa, Mastercard, Amex, Discover',
              Icons.credit_card,
              _selectedPaymentMethod == 'card',
              'card',
              const Color(0xFF635BFF), // Stripe Purple
            ),
            
            const SizedBox(height: 12),
            
            // BILLETERAS DIGITALES
            if (isiOS)
              _buildPaymentMethod(
                'Apple Pay',
                'Quick and secure payment',
                Icons.apple,
                _selectedPaymentMethod == 'apple_pay',
                'apple_pay',
                const Color(0xFF000000), // Apple Black
              ),
            
            const SizedBox(height: 12),
            
            if (isAndroid)
              _buildPaymentMethod(
                'Google Pay',
                'Fast checkout with Google',
                Icons.account_balance_wallet,
                _selectedPaymentMethod == 'google_pay',
                'google_pay',
                const Color(0xFF4285F4), // Google Blue
              ),
            
            const SizedBox(height: 12),
            
            _buildPaymentMethod(
              'Cash App Pay',
              'Coming Soon - US Only',
              Icons.attach_money,
              _selectedPaymentMethod == 'cashapp',
              'cashapp',
              const Color(0xFF00D54B), // Cash App Green
              isDisabled: true, // ✅ DESHABILITADO
            ),
            
            const SizedBox(height: 12),
            
            // COMPRA AHORA, PAGA DESPUÉS (BNPL)
            _buildPaymentMethod(
              'Klarna',
              'Buy now, pay later in 4 payments',
              Icons.schedule,
              _selectedPaymentMethod == 'klarna',
              'klarna',
              const Color(0xFFFFB3C7), // Klarna Pink
            ),
            
            const SizedBox(height: 12),
            
            _buildPaymentMethod(
              'Afterpay/Clearpay',
              'Split in 4 interest-free payments',
              Icons.payment,
              _selectedPaymentMethod == 'afterpay_clearpay',
              'afterpay_clearpay',
              const Color(0xFFB2FCE4), // Afterpay Mint
            ),
            
            const SizedBox(height: 12),
            
            _buildPaymentMethod(
              'Affirm',
              'Monthly payment plans available',
              Icons.calendar_month,
              _selectedPaymentMethod == 'affirm',
              'affirm',
              const Color(0xFF00AAC4), // Affirm Teal
            ),
            
            const SizedBox(height: 12),
            
            // DÉBITOS BANCARIOS
            _buildPaymentMethod(
              'ACH Direct Debit',
              'Bank account transfer (US only)',
              Icons.account_balance,
              _selectedPaymentMethod == 'us_bank_account',
              'us_bank_account',
              const Color(0xFF4DD0E1), // Turquesa LandGo
            ),
            
            const SizedBox(height: 12),
            
            // PAGOS INTERNACIONALES
            _buildPaymentMethod(
              'Alipay',
              'Popular in China and Asia',
              Icons.payment,
              _selectedPaymentMethod == 'alipay',
              'alipay',
              const Color(0xFF00A0E9), // Alipay Blue
            ),
            
            const SizedBox(height: 12),
            
            _buildPaymentMethod(
              'WeChat Pay',
              'Leading payment method in China',
              Icons.chat,
              _selectedPaymentMethod == 'wechat_pay',
              'wechat_pay',
              const Color(0xFF09BB07), // WeChat Green
            ),
            
            const SizedBox(height: 12),
            
            _buildPaymentMethod(
              'Zip',
              'Buy now, pay later',
              Icons.payment,
              _selectedPaymentMethod == 'zip',
              'zip',
              const Color(0xFFE91E63), // Zip Pink
            ),
            
            const SizedBox(height: 40),
            
            // Select Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF4DD0E1), // TURQUESA LANDGO
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    print('🔍 DEBUG: Select button pressed');
                    print('🔍 DEBUG: Returning payment method: $_selectedPaymentMethod');
                    Navigator.pop(context, _selectedPaymentMethod);
                  },
                  child: Center(
                    child: Text(
                      'Select Payment Method',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20), // Safe area bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getPaymentMethodDetails(String methodId) {
    final methods = {
      'card': {
        'name': 'Credit/Debit Card',
        'subtitle': 'Visa, Mastercard, Amex',
        'icon': Icons.credit_card,
        'logoPath': 'assets/images/payment_logos/card_logo.png',
        'color': const Color(0xFF635BFF),
      },
      if (isiOS) 'apple_pay': {
        'name': 'Apple Pay',
        'subtitle': 'Quick and secure',
        'icon': Icons.apple,
        'logoPath': 'assets/images/payment_logos/apple_pay_logo.png',
        'color': const Color(0xFF000000),
      },
      if (isAndroid) 'google_pay': {
        'name': 'Google Pay',
        'subtitle': 'Fast checkout',
        'icon': Icons.account_balance_wallet,
        'logoPath': 'assets/images/payment_logos/google_pay_logo.png',
        'color': const Color(0xFF4285F4),
      },
      'cashapp': {
        'name': 'Cash App Pay',
        'subtitle': 'Pay with Cash App',
        'icon': Icons.attach_money,
        'logoPath': 'assets/images/payment_logos/cashapp_logo.png',
        'color': const Color(0xFF00D54B),
      },
      'klarna': {
        'name': 'Klarna',
        'subtitle': 'Pay in 4 payments',
        'icon': Icons.schedule,
        'logoPath': 'assets/images/payment_logos/klarna_logo.png',
        'color': const Color(0xFFFFB3C7),
      },
      'afterpay_clearpay': {
        'name': 'Afterpay/Clearpay',
        'subtitle': '4 interest-free payments',
        'icon': Icons.payment,
        'logoPath': 'assets/images/payment_logos/afterpay_logo.png',
        'color': const Color(0xFFB2FCE4),
      },
      'affirm': {
        'name': 'Affirm',
        'subtitle': 'Monthly payments',
        'icon': Icons.calendar_month,
        'logoPath': 'assets/images/payment_logos/affirm_logo.png',
        'color': const Color(0xFF00AAC4),
      },
      'us_bank_account': {
        'name': 'ACH Direct Debit',
        'subtitle': 'Bank transfer',
        'icon': Icons.account_balance,
        'logoPath': 'assets/images/payment_logos/us_bank_account_logo.png',
        'color': const Color(0xFF4DD0E1),
      },
      'alipay': {
        'name': 'Alipay',
        'subtitle': 'Popular in Asia',
        'icon': Icons.payment,
        'logoPath': 'assets/images/payment_logos/alipay_logo.png',
        'color': const Color(0xFF00A0E9),
      },
      'wechat_pay': {
        'name': 'WeChat Pay',
        'subtitle': 'China payment',
        'icon': Icons.chat,
        'logoPath': 'assets/images/payment_logos/wechat_pay_logo.png',
        'color': const Color(0xFF09BB07),
      },
      'zip': {
        'name': 'Zip',
        'subtitle': 'Buy now, pay later',
        'icon': Icons.payment,
        'logoPath': 'assets/images/payment_logos/zip_logo.png',
        'color': const Color(0xFFE91E63),
      },
    };

    return methods[methodId] ?? methods['card']!;
  }

  Widget _buildPaymentMethod(String title, String subtitle, IconData icon, bool isSelected, String methodId, Color brandColor, {bool isDisabled = false}) {
    final paymentDetails = _getPaymentMethodDetails(methodId);
    final logoPath = paymentDetails['logoPath'] as String?;
    
    return GestureDetector(
      onTap: isDisabled ? null : () {
        print('🔍 DEBUG: Tapped payment method: $methodId');
        print('🔍 DEBUG: Previous selection: $_selectedPaymentMethod');
        setState(() {
          _selectedPaymentMethod = methodId;
        });
        print('🔍 DEBUG: New selection: $_selectedPaymentMethod');
        print('🔍 DEBUG: Method $methodId is now selected: ${_selectedPaymentMethod == methodId}');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled 
              ? Colors.grey.withOpacity(0.1) 
              : (isSelected ? brandColor.withOpacity(0.15) : const Color(0xFF2C2C2C)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled 
                ? Colors.grey.withOpacity(0.3)
                : (isSelected ? brandColor : Colors.white.withOpacity(0.2)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: logoPath != null 
                    ? Colors.transparent 
                    : (isDisabled ? Colors.grey.withOpacity(0.2) : brandColor.withOpacity(0.2)),
                shape: BoxShape.circle,
              ),
              child: logoPath != null
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.asset(
                        logoPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if logo fails to load
                          print('❌ Error loading logo: $logoPath - $error');
                          return Icon(
                            icon,
                            color: brandColor,
                            size: 26,
                          );
                        },
                      ),
                    )
                  : Icon(
                      icon,
                      color: brandColor,
                      size: 26,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4DD0E1),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
