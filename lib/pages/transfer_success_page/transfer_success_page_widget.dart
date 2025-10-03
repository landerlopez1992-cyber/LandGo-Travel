import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'transfer_success_page_model.dart';
export 'transfer_success_page_model.dart';

class TransferSuccessPageWidget extends StatefulWidget {
  const TransferSuccessPageWidget({
    super.key,
    required this.confirmationNumber,
    required this.recipientName,
    required this.transferAmount,
    required this.transferTime,
  });

  final String confirmationNumber;
  final String recipientName;
  final String transferAmount;
  final DateTime transferTime;

  static String routeName = 'TransferSuccessPage';
  static String routePath = '/transferSuccess';

  @override
  State<TransferSuccessPageWidget> createState() =>
      _TransferSuccessPageWidgetState();
}

class _TransferSuccessPageWidgetState extends State<TransferSuccessPageWidget> {
  late TransferSuccessPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TransferSuccessPageModel());

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
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF1A1A1A), // FONDO NEGRO LANDGO
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A1A), Color(0xFF000000)],
                stops: [0.0, 1.0],
                begin: AlignmentDirectional(0.0, -1.0),
                end: AlignmentDirectional(0, 1.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icono de éxito
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Título principal
                  Text(
                    'Transfer Successful!',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtítulo
                  Text(
                    'Your money has been sent successfully',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF9CA3AF),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Card con detalles de la transferencia
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4DD0E1).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Número de confirmación
                        _buildDetailRow(
                          'Confirmation Number',
                          widget.confirmationNumber,
                          isHighlight: true,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Nombre del destinatario
                        _buildDetailRow(
                          'Recipient',
                          widget.recipientName,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Monto transferido
                        _buildDetailRow(
                          'Amount Transferred',
                          '\$${widget.transferAmount}',
                          isAmount: true,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Fecha y hora
                        _buildDetailRow(
                          'Date & Time',
                          DateFormat('MMM dd, yyyy • hh:mm a').format(widget.transferTime),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botón de aceptar
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4DD0E1),
                          const Color(0xFF26C6DA),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4DD0E1).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // Navegar de regreso a My Wallet usando GoRouter
                          context.go('/myWalletPage');
                        },
                        child: Center(
                          child: Text(
                            'Accept',
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
                  
                  const SizedBox(height: 24),
                  
                  // Nota de seguridad
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF37474F).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
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
                            'Keep this confirmation number for your records',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false, bool isAmount = false}) {
    return Column(
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
            color: isHighlight ? const Color(0xFF4DD0E1) : Colors.white,
            fontSize: isAmount ? 20 : 16,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
