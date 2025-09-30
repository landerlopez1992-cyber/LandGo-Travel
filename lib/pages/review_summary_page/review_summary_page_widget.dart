import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
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
  String _selectedPaymentMethod = 'stripe'; // 'stripe', 'apple'

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
                          'Payment: ${_selectedPaymentMethod == 'stripe' ? 'Stripe' : 'Apple Pay'}',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Payment Method Logo
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _selectedPaymentMethod == 'stripe' 
                    ? const Color(0xFF635BFF) // PURPLE STRIPE
                    : const Color(0xFF4DD0E1), // TURQUESA APPLE
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _selectedPaymentMethod == 'stripe' 
                    ? const Icon(
                        Icons.credit_card,
                        color: Colors.white,
                        size: 20,
                      )
                    : const Icon(
                        Icons.apple,
                        color: Colors.white,
                        size: 20,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedPaymentMethod == 'stripe' ? 'Stripe' : 'Apple Pay',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _selectedPaymentMethod == 'stripe' ? 'Credit/Debit Card' : 'Quick and secure payment',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Change Button
          GestureDetector(
            onTap: () => _showPaymentMethodSelector(),
            child: Text(
              'Change',
              style: GoogleFonts.outfit(
                color: const Color(0xFFDC2626), // ROJO LANDGO
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
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
          onTap: () {
            // TODO: Process payment
            print('Processing payment with method: $_selectedPaymentMethod');
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
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C), // GRIS OSCURO LANDGO
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header
            Row(
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
            
            const SizedBox(height: 20),
            
            // Payment Methods - SELECCIONABLES
            _buildPaymentMethod(
              'Stripe',
              'Credit/Debit Card',
              Icons.credit_card,
              _selectedPaymentMethod == 'stripe',
              'stripe',
            ),
            
            const SizedBox(height: 16),
            
            _buildPaymentMethod(
              'Apple Pay',
              'Quick and secure payment',
              Icons.apple,
              _selectedPaymentMethod == 'apple',
              'apple',
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
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, String subtitle, IconData icon, bool isSelected, String methodId) {
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
          color: isSelected ? const Color(0xFF4DD0E1).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4DD0E1) : Colors.white,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4DD0E1) : Colors.white,
              size: 24,
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
