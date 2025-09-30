import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'payment_failed_pag_model.dart';
export 'payment_failed_pag_model.dart';

class PaymentFailedPagWidget extends StatefulWidget {
  const PaymentFailedPagWidget({super.key});

  static const String routeName = 'PaymentFailedPag';
  static const String routePath = '/paymentFailedPag';

  @override
  State<PaymentFailedPagWidget> createState() => _PaymentFailedPagWidgetState();
}

class _PaymentFailedPagWidgetState extends State<PaymentFailedPagWidget> {
  late PaymentFailedPagModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Variables para recibir parámetros
  String _amount = '0.00';
  String _paymentMethod = 'stripe';
  Map<String, dynamic>? _card;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentFailedPagModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadParameters();
  }

  void _loadParameters() {
    final route = ModalRoute.of(context);
    final extraData = route?.settings.arguments as Map<String, dynamic>?;
    
    if (extraData != null) {
      _amount = extraData['amount'] ?? '0.00';
      _paymentMethod = extraData['paymentMethod'] ?? 'stripe';
      _card = extraData['card'] as Map<String, dynamic>?;
      _errorMessage = extraData['error'] ?? 'Payment failed. Please try again.';
      print('🔍 DEBUG: Loaded payment failed parameters: amount=$_amount, method=$_paymentMethod');
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
                  
                  // Icono de error
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Color(0xFFDC2626),
                        size: 60,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Título
                  Text(
                    'Payment Failed',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Mensaje de error
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Detalles del pago
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
                        _buildDetailRow('Amount', '\$${_amount}'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Payment Method', _paymentMethod == 'stripe' ? 'Stripe' : 'Apple Pay'),
                        if (_card != null) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow('Card', '**** ${_card!['last4']}'),
                        ],
                        const SizedBox(height: 12),
                        _buildDetailRow('Status', 'Failed', isError: true),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botón para intentar de nuevo
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
                          // Regresar a la pantalla anterior
                          Navigator.of(context).pop();
                        },
                        child: Center(
                          child: Text(
                            'Try Again',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Botón para ir al inicio
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Navegar al inicio usando GoRouter
                          context.goNamedAuth('MainPage', context.mounted);
                        },
                        child: Center(
                          child: Text(
                            'Go to Home',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 100), // ESPACIO PARA BOTTOM NAV
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isError = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: isError ? const Color(0xFFDC2626) : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
