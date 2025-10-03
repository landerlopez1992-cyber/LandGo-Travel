import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'payment_success_pag_model.dart';
export 'payment_success_pag_model.dart';
import '/pages/my_wallet_page/my_wallet_page_widget.dart';

class PaymentSuccessPagWidget extends StatefulWidget {
  const PaymentSuccessPagWidget({super.key});

  static String routeName = 'PaymentSuccessPag';
  static String routePath = '/paymentSuccessPag';

  @override
  State<PaymentSuccessPagWidget> createState() => _PaymentSuccessPagWidgetState();
}

class _PaymentSuccessPagWidgetState extends State<PaymentSuccessPagWidget> {
  late PaymentSuccessPagModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Variables para recibir parámetros del pago real
  String _paymentIntentId = 'N/A';
  String _chargeId = 'N/A';
  String _customerName = 'N/A';
  String _cardBrand = 'N/A';
  String _cardLast4 = 'N/A';
  String _cardExpiry = 'N/A';
  double _amount = 0.00;
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentSuccessPagModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPaymentDetails();
  }

  void _loadPaymentDetails() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      setState(() {
        _paymentIntentId = args['paymentIntentId'] as String? ?? 'N/A';
        _chargeId = args['chargeId'] as String? ?? 'N/A';
        _customerName = args['customerName'] as String? ?? 'N/A';
        _cardBrand = args['cardBrand'] as String? ?? 'N/A';
        _cardLast4 = args['cardLast4'] as String? ?? 'N/A';
        _cardExpiry = args['cardExpiry'] as String? ?? 'N/A';
        _amount = double.tryParse(args['amount']?.toString() ?? '0.0') ?? 0.0;
        _currency = args['currency'] as String? ?? 'USD';
      });
      print('✅ Payment details loaded: amount=\$${_amount}, card=$_cardBrand **** $_cardLast4');
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  const SizedBox(height: 40),
                  
                  // ✅ Icono de éxito (TURQUESA LANDGO)
                Container(
                    width: 120,
                    height: 120,
                  decoration: BoxDecoration(
                      color: const Color(0xFF4DD0E1).withOpacity(0.1), // TURQUESA LANDGO
                    shape: BoxShape.circle,
                  ),
                    child: const Center(
                    child: Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF4DD0E1), // TURQUESA ÉXITO
                        size: 60,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // ✅ Título
                    Text(
                      'Payment Successful!',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 32,
                                fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // ✅ Mensaje de confirmación
                    Text(
                    'Your wallet has been funded successfully.',
                      textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // ✅ Detalles del pago
                  Container(
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
                          'Payment Details',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                                  fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Payment Intent ID', _paymentIntentId),
                        const SizedBox(height: 12),
                        _buildDetailRow('Charge ID', _chargeId),
                        const SizedBox(height: 12),
                        _buildDetailRow('Customer', '$_customerName'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Card', '$_cardBrand **** $_cardLast4'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Expiry', _cardExpiry),
                        const SizedBox(height: 12),
                        _buildDetailRow('Amount', '\$${_amount.toStringAsFixed(2)} $_currency', isHighlight: true),
                        const SizedBox(height: 12),
                        _buildDetailRow('Status', '✅ Succeeded', isSuccess: true),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // ✅ Botón principal (View My Wallet)
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
                          // Navegar a My Wallet usando GoRouter
                          context.go('/myWalletPage');
                        },
                        child: Center(
                          child: Text(
                            'Accept',
                            style: GoogleFonts.outfit(
                              color: Colors.black, // TEXTO NEGRO SOBRE TURQUESA
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isSuccess = false, bool isHighlight = false}) {
    // Acortar IDs muy largos (Payment Intent, Charge ID)
    String displayValue = value;
    if (label.contains('ID') && value.length > 25 && value != 'N/A') {
      displayValue = '${value.substring(0, 20)}...';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayValue,
          style: GoogleFonts.outfit(
            color: isSuccess || isHighlight
              ? const Color(0xFF4DD0E1) // TURQUESA LANDGO (ÚNICO COLOR PERMITIDO)
              : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}