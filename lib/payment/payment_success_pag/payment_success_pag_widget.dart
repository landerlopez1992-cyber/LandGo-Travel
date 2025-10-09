import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'payment_success_pag_model.dart';
export 'payment_success_pag_model.dart';

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

  // Evitar persistencias duplicadas si la vista se reconstruye
  bool _persistenceCompleted = false;

  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG: PaymentSuccessPagWidget initState called');
    _model = createModel(context, () => PaymentSuccessPagModel());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔍 DEBUG: PostFrameCallback executed');
      _loadPaymentDetails();
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔍 DEBUG: PaymentSuccessPagWidget didChangeDependencies called');
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

      // Verificar si la transacción ya fue persistida (Klarna/Afterpay)
      final alreadyPersisted = args['alreadyPersisted'] as bool? ?? false;
      
      if (alreadyPersisted) {
        print('ℹ️ Transaction already persisted (Klarna/Afterpay). Skipping persistence.');
        _persistenceCompleted = true; // Marcar como completado para evitar duplicación
      } else {
        print('🔍 DEBUG: Transaction not persisted yet. Will persist now.');
        // Persistir en base de datos (payments + actualizar balance)
        _persistWalletTopUpIfNeeded();
      }
    }
  }

  Future<void> _persistWalletTopUpIfNeeded() async {
    print('🔍 DEBUG: _persistWalletTopUpIfNeeded called');
    print('🔍 DEBUG: _persistenceCompleted = $_persistenceCompleted');
    print('🔍 DEBUG: _amount = $_amount');
    print('🔍 DEBUG: _paymentIntentId = $_paymentIntentId');
    print('🔍 DEBUG: _chargeId = $_chargeId');
    
    if (_persistenceCompleted) {
      print('ℹ️ Persistence already completed. Skipping.');
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('⚠️ No authenticated user found. Cannot persist payment.');
      return;
    }
    print('🔍 DEBUG: User ID: ${user.id}');

    if (_amount <= 0) {
      print('⚠️ Invalid amount $_amount. Skipping persistence.');
      return;
    }

    try {
      print('🔍 DEBUG: Starting transaction insertion...');
      
      // 1) Calcular el monto sin fee de procesamiento
      // _amount incluye el 3% de fee, necesitamos el monto original
      // Si total = original * 1.03, entonces original = total / 1.03
      final amountWithoutFee = _amount / 1.03;
      final processingFee = _amount - amountWithoutFee;
      
      print('🔍 DEBUG: Total paid: \$$_amount');
      print('🔍 DEBUG: Amount without fee: \$${amountWithoutFee.toStringAsFixed(2)}');
      print('🔍 DEBUG: Processing fee (3%): \$${processingFee.toStringAsFixed(2)}');
      
      // 2) Insertar transacción en payments (dinero agregado via tarjeta)
      final transactionId = (_chargeId != 'N/A' && _chargeId.isNotEmpty)
          ? _chargeId
          : _paymentIntentId;

      final insertData = {
        'user_id': user.id,
        'amount': amountWithoutFee, // Solo el monto sin fee va a la wallet
        'currency': _currency,
        'status': 'completed',
        'payment_method': 'stripe_card',
        'transaction_id': transactionId,
        'description': 'Wallet top-up via ${_cardBrand.toUpperCase()} **** ${_cardLast4} (Fee: \$${processingFee.toStringAsFixed(2)})',
        'related_type': 'card_deposit',
      };

      print('🔍 DEBUG: Insert data: $insertData');

      final insertRes = await Supabase.instance.client
          .from('payments')
          .insert(insertData)
          .select()
          .limit(1);

      print('✅ Inserted card payment into payments: $insertRes');

      // 3) Actualizar el balance del usuario en profiles.cashback_balance
      print('🔍 DEBUG: Updating cashback_balance with amount: \$${amountWithoutFee.toStringAsFixed(2)}');
      
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('cashback_balance')
          .eq('id', user.id)
          .single();

      final currentBalance = (profile['cashback_balance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = currentBalance + amountWithoutFee;

      print('🔍 DEBUG: Current balance: $currentBalance, New balance: ${newBalance.toStringAsFixed(2)}');

      final updateRes = await Supabase.instance.client
          .from('profiles')
          .update({'cashback_balance': newBalance})
          .eq('id', user.id)
          .select('cashback_balance')
          .single();

      print('✅ Wallet balance updated from $currentBalance to ${updateRes['cashback_balance']}');

      _persistenceCompleted = true;
      print('✅ Persistence completed successfully');
    } catch (e, st) {
      print('❌ Error persisting card top-up: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: $st');
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
                          // Navegar a My Wallet usando context.go
                          context.goNamed('MyWalletPage');
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