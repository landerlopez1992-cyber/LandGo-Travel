import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/back_button_widget.dart';
import 'transaction_detail_page_model.dart';
export 'transaction_detail_page_model.dart';

class TransactionDetailPageWidget extends StatefulWidget {
  const TransactionDetailPageWidget({
    super.key,
    required this.transaction,
    this.fromPage,
  });

  final Map<String, dynamic> transaction;
  final String? fromPage; // Pantalla de origen

  static String routeName = 'TransactionDetailPage';
  static String routePath = '/transactionDetailPage';

  @override
  State<TransactionDetailPageWidget> createState() =>
      _TransactionDetailPageWidgetState();
}

class _TransactionDetailPageWidgetState
    extends State<TransactionDetailPageWidget> {
  late TransactionDetailPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TransactionDetailPageModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final paymentMethod = (tx['payment_method'] ?? '').toString().toLowerCase();
    final status = (tx['status'] ?? 'completed').toString().toLowerCase();
    final createdAt = tx['created_at']?.toString() ?? '';
    final transactionId = tx['id']?.toString() ?? 'N/A';
    final userId = tx['user_id']?.toString() ?? 'N/A';
    final relatedId = tx['related_id']?.toString() ?? 'N/A';
    final description = tx['description']?.toString() ?? 'N/A';

    // Determinar tipo de transacción
    bool isSent = amount < 0;
    bool isReceived = amount > 0 && paymentMethod == 'wallet';
    bool isKlarna = paymentMethod == 'klarna';
    bool isAfterpay = paymentMethod == 'afterpay' || paymentMethod == 'afterpay_clearpay';
    bool isAffirm = paymentMethod == 'affirm';
    bool isZip = paymentMethod == 'zip';
    bool isCashApp = paymentMethod == 'cashapp';
    bool isStripePayment = paymentMethod.contains('stripe') || paymentMethod.contains('card') || paymentMethod == 'debit_card';

    String transactionType;
    String? logoPath; // Para logos de métodos de pago
    IconData? typeIcon; // Para iconos genéricos
    Color typeColor;

    if (isKlarna) {
      transactionType = 'Klarna';
      logoPath = 'assets/images/payment_logos/klarna_logo.png';
      typeColor = const Color(0xFF4DD0E1); // Turquesa
    } else if (isAfterpay) {
      transactionType = 'Afterpay';
      logoPath = 'assets/images/payment_logos/afterpay_logo.png';
      typeColor = const Color(0xFF4DD0E1); // Turquesa
    } else if (isAffirm) {
      transactionType = 'Affirm';
      logoPath = 'assets/images/payment_logos/affirm_logo.png';
      typeColor = const Color(0xFF4DD0E1); // Turquesa
    } else if (isZip) {
      transactionType = 'Zip';
      logoPath = 'assets/images/payment_logos/zip_logo.png';
      typeColor = const Color(0xFF4DD0E1); // Turquesa
    } else if (isCashApp) {
      transactionType = 'Cash App';
      logoPath = 'assets/images/payment_logos/cashapp_logo.png';
      typeColor = const Color(0xFF4DD0E1); // Turquesa
    } else if (isStripePayment) {
      transactionType = 'Debit Card';
      logoPath = 'assets/images/payment_logos/card_logo.png';
      typeColor = const Color(0xFF4DD0E1); // Turquesa
    } else if (isSent) {
      transactionType = 'Dinero Enviado';
      typeIcon = Icons.arrow_upward;
      typeColor = const Color(0xFFDC2626); // Rojo
    } else if (isReceived) {
      transactionType = 'Dinero Recibido';
      typeIcon = Icons.arrow_downward;
      typeColor = const Color(0xFF4CAF50); // Verde
    } else {
      transactionType = 'Transacción';
      typeIcon = Icons.receipt_long;
      typeColor = Colors.white;
    }

    // Determinar estado
    IconData statusIcon;
    Color statusColor;
    String statusText;

    if (status.contains('failed') || status.contains('denied')) {
      statusIcon = Icons.cancel;
      statusColor = const Color(0xFFDC2626); // Rojo
      statusText = 'Failed';
    } else if (status.contains('pending')) {
      statusIcon = Icons.access_time;
      statusColor = const Color(0xFFFF9800); // Naranja
      statusText = 'Pending';
    } else {
      statusIcon = Icons.check_circle;
      statusColor = const Color(0xFF4CAF50); // Verde
      statusText = 'Completed';
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF000000), // FONDO NEGRO LANDGO
        extendBodyBehindAppBar: false,
        extendBody: false,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ HEADER CON BOTÓN DE REGRESO
                  Row(
                    children: [
                      StandardBackButton(
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            context.pop();
                          } else {
                            // Regresar a la pantalla de origen
                            final fromPage = widget.fromPage;
                            if (fromPage == 'MyWalletPage') {
                              context.goNamed('MyWalletPage');
                            } else {
                              context.goNamed('AllTransactionsPage'); // Default
                            }
                          }
                        },
                      ),
                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ✅ TÍTULO CENTRADO
                  Center(
                    child: Text(
                      'Transaction Details',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ✅ ICONO Y ESTADO DE TRANSACCIÓN
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: logoPath != null
                              ? Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Image.asset(
                                    logoPath!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Icon(
                                  typeIcon!,
                                  size: 50,
                                  color: typeColor,
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          transactionType,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                color: statusColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                statusText,
                                style: GoogleFonts.outfit(
                                  color: statusColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ✅ MONTO
                  Center(
                    child: Text(
                      '${isSent ? '-' : '+'}\$${amount.abs().toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        color: isSent
                            ? const Color(0xFFDC2626) // Rojo para enviado
                            : (isStripePayment || isKlarna || isAfterpay || isAffirm || isZip)
                              ? const Color(0xFF4DD0E1) // Turquesa para métodos de pago
                              : const Color(0xFF4CAF50), // Verde para recibido
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ✅ DETALLES DE LA TRANSACCIÓN
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C), // GRIS OSCURO
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4DD0E1).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaction Information',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF4DD0E1),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Transaction ID
                        _buildDetailRow(
                          'Transaction ID',
                          _shortenId(transactionId),
                          Icons.tag,
                        ),

                        const Divider(
                          color: Color(0xFF4DD0E1),
                          height: 32,
                          thickness: 0.5,
                        ),

                        // Fecha y Hora
                        _buildDetailRow(
                          'Date & Time',
                          _formatDate(createdAt),
                          Icons.calendar_today,
                        ),

                        const Divider(
                          color: Color(0xFF4DD0E1),
                          height: 32,
                          thickness: 0.5,
                        ),

                        // Método de Pago
                        _buildDetailRow(
                          'Payment Method',
                          _formatPaymentMethod(paymentMethod),
                          Icons.payment,
                        ),

                        if (!isStripePayment) ...[
                          const Divider(
                            color: Color(0xFF4DD0E1),
                            height: 32,
                            thickness: 0.5,
                          ),

                          // Emisor (User ID)
                          _buildDetailRow(
                            isSent ? 'From (You)' : 'From',
                            _shortenId(userId),
                            Icons.person_outline,
                          ),

                          const Divider(
                            color: Color(0xFF4DD0E1),
                            height: 32,
                            thickness: 0.5,
                          ),

                          // Receptor (Related ID)
                          _buildDetailRow(
                            isSent ? 'To' : 'To (You)',
                            _shortenId(relatedId),
                            Icons.person,
                          ),
                        ],

                        if (description != 'N/A' && description.isNotEmpty) ...[
                          const Divider(
                            color: Color(0xFF4DD0E1),
                            height: 32,
                            thickness: 0.5,
                          ),

                          // Descripción
                          _buildDetailRow(
                            'Description',
                            description,
                            Icons.description,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ✅ NOTA DE SEGURIDAD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF37474F).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.security,
                          color: Color(0xFF4DD0E1),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Keep this transaction information for your records',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF4DD0E1).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4DD0E1),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return 'Unknown date';
    }
  }

  String _shortenId(String id) {
    if (id.length > 20) {
      return '${id.substring(0, 8)}...${id.substring(id.length - 8)}';
    }
    return id;
  }

  String _formatPaymentMethod(String method) {
    if (method.contains('stripe') || method.contains('card')) {
      return 'Credit/Debit Card';
    } else if (method.contains('wallet')) {
      return 'LandGo Wallet';
    } else {
      return method.toUpperCase();
    }
  }
}
