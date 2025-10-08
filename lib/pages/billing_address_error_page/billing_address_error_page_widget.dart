import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'billing_address_error_page_model.dart';
export 'billing_address_error_page_model.dart';

class BillingAddressErrorPageWidget extends StatefulWidget {
  const BillingAddressErrorPageWidget({
    Key? key,
    this.missingFields,
    this.amount,
    this.paymentMethod,
  }) : super(key: key);

  final List<String>? missingFields;
  final String? amount;
  final String? paymentMethod;

  @override
  _BillingAddressErrorPageWidgetState createState() =>
      _BillingAddressErrorPageWidgetState();
}

class _BillingAddressErrorPageWidgetState
    extends State<BillingAddressErrorPageWidget> {
  late BillingAddressErrorPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BillingAddressErrorPageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          top: true,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF000000),
                ],
              ),
            ),
            child: Column(
              children: [
                // Header sin botón de regreso
                _buildHeader(),
                
                // Contenido principal
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icono de error
                          _buildErrorIcon(),
                          const SizedBox(height: 24),
                          
                          // Título
                          _buildTitle(),
                          const SizedBox(height: 12),
                          
                          // Descripción
                          _buildDescription(),
                          const SizedBox(height: 20),
                          
                          // Campos faltantes
                          if (widget.missingFields != null && widget.missingFields!.isNotEmpty)
                            _buildMissingFields(),
                          
                          const SizedBox(height: 32),
                          
                          // Botones de acción
                          _buildActionButtons(),
                        ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: Text(
          'Billing Address Required',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4DD0E1).withOpacity(0.1),
            const Color(0xFF4DD0E1).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: const Color(0xFF4DD0E1).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4DD0E1).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: -3,
          ),
        ],
      ),
      child: const Icon(
        Icons.location_off_rounded,
        color: Color(0xFF4DD0E1),
        size: 50,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Billing Address Incomplete',
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Column(
      children: [
        Text(
          'We need your complete billing address to process this payment.',
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (widget.amount != null && widget.paymentMethod != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Payment Details:',
                  style: GoogleFonts.outfit(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount:',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${widget.amount}',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF4DD0E1),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Method:',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.paymentMethod!,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMissingFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDC2626).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFDC2626),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Missing Information:',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFDC2626),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.missingFields!.map((field) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getFieldDisplayName(field),
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  String _getFieldDisplayName(String field) {
    switch (field) {
      case 'line1':
        return 'Street Address';
      case 'city':
        return 'City';
      case 'state':
        return 'State/Province';
      case 'postal_code':
        return 'ZIP/Postal Code';
      case 'country':
        return 'Country';
      case 'email':
        return 'Email Address';
      case 'phone':
        return 'Phone Number';
      default:
        return field.replaceAll('_', ' ').toUpperCase();
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón principal - Go to Payment Methods
        SizedBox(
          width: double.infinity,
          height: 68,
          child: FFButtonWidget(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar esta pantalla
              Navigator.pushNamed(context, '/PaymentMethodsPage');
            },
            text: 'Complete Billing Address',
            icon: const Icon(
              Icons.location_on_rounded,
              color: Colors.black,
              size: 24,
            ),
            options: FFButtonOptions(
              height: 68,
              padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
              iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
              color: const Color(0xFF4DD0E1),
              textStyle: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
              elevation: 0,
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 0,
              ),
              borderRadius: BorderRadius.circular(22),
              hoverColor: const Color(0xFF4DD0E1).withOpacity(0.9),
              hoverBorderSide: BorderSide(
                color: const Color(0xFF4DD0E1).withOpacity(0.8),
                width: 2,
              ),
              hoverTextColor: Colors.black,
              hoverElevation: 8,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Botón secundario - Go Back
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FFButtonWidget(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'Go Back',
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white70,
              size: 20,
            ),
            options: FFButtonOptions(
              height: 56,
              padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
              iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
              color: Colors.transparent,
              textStyle: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0,
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
              hoverColor: Colors.white.withOpacity(0.05),
              hoverBorderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              hoverTextColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
