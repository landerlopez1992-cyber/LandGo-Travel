import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import '/pages/payment_cards_page/payment_cards_page_widget.dart';
import '/pages/klarna_webview_page/klarna_webview_page_widget.dart';
import '/payment/payment_success_pag/payment_success_pag_widget.dart';
import '/services/klarna_service.dart';
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
      final fee = amount * 0.03; // 3% processing fee
      return fee.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  String _calculateSubTotal() {
    try {
      final amount = double.parse(_amount);
      final fee = amount * 0.03;
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
          _buildPaymentRow('Processing fee (3%)', '\$${_calculateProcessingFee()}'),
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
            
            // 🆕 DETECTAR SI ES KLARNA
            if (_selectedPaymentMethod == 'klarna') {
              await _processKlarnaPayment(totalAmount);
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

      // 3. Obtener/Crear Stripe Customer ID
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('stripe_customer_id')
          .eq('id', currentUser.id)
          .maybeSingle();
      
      String? stripeCustomerId = profileResponse?['stripe_customer_id'];

      // 4. Crear sesión de Klarna
      final session = await KlarnaService.createKlarnaSession(
        amount: totalAmount,
        userId: currentUser.id,
        customerId: stripeCustomerId,
      );

      print('✅ Klarna session created');
      print('✅ Payment Intent ID: ${session['paymentIntentId']}');

      // Cerrar loading
      if (mounted) Navigator.of(context).pop();

      // 5. Abrir Webview con Klarna
      final checkoutUrl = KlarnaService.getKlarnaCheckoutUrl(session['clientSecret']);
      
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
          
          // Navegar a PaymentSuccess
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentSuccessPagWidget(),
              ),
            );
          }
        } else {
          _showErrorDialog('Payment is ${confirmation['status']}. We\'ll notify you when it\'s complete.');
        }
      } else if (status == 'failed') {
        _showErrorDialog('Klarna payment failed. Please try another payment method.');
      } else if (status == 'cancelled') {
        print('🔄 User cancelled Klarna payment');
        // Usuario canceló, no hacer nada
      } else {
        _showErrorDialog('Payment status: $status');
      }
    } catch (e) {
      print('❌ ERROR in Klarna payment: $e');
      if (mounted) Navigator.of(context).pop();
      _showErrorDialog('Error processing Klarna payment: $e');
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
      await Supabase.instance.client.from('payments').insert({
        'user_id': currentUser.id,
        'amount': amount,
        'payment_method': 'klarna',
        'status': 'completed',
        'related_type': 'wallet_topup',
        'description': 'Wallet top-up via Klarna (PaymentIntent: $paymentIntentId)',
        'created_at': DateTime.now().toIso8601String(),
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
              'Pay with Cash App',
              Icons.attach_money,
              _selectedPaymentMethod == 'cashapp',
              'cashapp',
              const Color(0xFF00D54B), // Cash App Green
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

  Widget _buildPaymentMethod(String title, String subtitle, IconData icon, bool isSelected, String methodId, Color brandColor) {
    final paymentDetails = _getPaymentMethodDetails(methodId);
    final logoPath = paymentDetails['logoPath'] as String?;
    
    return GestureDetector(
      onTap: () {
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
          color: isSelected ? brandColor.withOpacity(0.15) : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? brandColor : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: logoPath != null ? Colors.transparent : brandColor.withOpacity(0.2),
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
