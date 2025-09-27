import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_method_page_model.dart';
export 'payment_method_page_model.dart';

class PaymentMethodPageWidget extends StatefulWidget {
  const PaymentMethodPageWidget({super.key});

  static String routeName = 'PaymentMethodPage';
  static String routePath = '/paymentMethodPage';

  @override
  State<PaymentMethodPageWidget> createState() => _PaymentMethodPageWidgetState();
}

class _PaymentMethodPageWidgetState extends State<PaymentMethodPageWidget> {
  late PaymentMethodPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PaymentMethodPageModel());
    _model.selectedPaymentMethod = 'Stripe'; // Stripe seleccionado por defecto
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color(0xFF000000), // Fondo negro
      appBar: AppBar(
        backgroundColor: Color(0xFF000000),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Botón de retroceso
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFFFFFFFF),
                  size: 20.0,
                ),
              ),
            ),
            SizedBox(width: 16.0),
            // Título
            Text(
              'Payment method',
              style: GoogleFonts.inter(
                color: Color(0xFFFFFFFF),
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de instrucción
              Text(
                'Select payment method',
                style: GoogleFonts.inter(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24.0),
              
              // Lista de métodos de pago
              Expanded(
                child: Column(
                  children: [
                    // PayPal
                    _buildPaymentMethodCard(
                      'Paypal',
                      'assets/images/paypal_logo.png', // Necesitarás agregar este logo
                      false,
                    ),
                    SizedBox(height: 16.0),
                    
                    // Apple Pay
                    _buildPaymentMethodCard(
                      'Apple pay',
                      'assets/images/apple_logo.png', // Necesitarás agregar este logo
                      false,
                    ),
                    SizedBox(height: 16.0),
                    
                    // Stripe (seleccionado)
                    _buildPaymentMethodCard(
                      'Stripe',
                      'assets/images/stripe_logo.png', // Necesitarás agregar este logo
                      true,
                    ),
                    SizedBox(height: 16.0),
                    
                    // Razor Pay
                    _buildPaymentMethodCard(
                      'Razor pay',
                      'assets/images/razorpay_logo.png', // Necesitarás agregar este logo
                      false,
                    ),
                  ],
                ),
              ),
              
              // Botón Continue payment
              Container(
                width: double.infinity,
                height: 56.0,
                decoration: BoxDecoration(
                  color: Color(0xFF4DD0E1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implementar continuación del pago
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Continue payment',
                    style: GoogleFonts.inter(
                      color: Color(0xFF000000),
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(String title, String logoPath, bool isSelected) {
    return Container(
      width: double.infinity,
      height: 60.0,
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _model.selectedPaymentMethod = title;
            });
          },
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            child: Row(
              children: [
                // Logo (por ahora usar icono genérico)
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: _getLogoColor(title),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Icon(
                    _getLogoIcon(title),
                    color: _getLogoIconColor(title),
                    size: 20.0,
                  ),
                ),
                SizedBox(width: 16.0),
                
                // Título
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                // Radio button
                Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF4DD0E1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isSelected ? Color(0xFF4DD0E1) : Color(0xFFFFFFFF),
                      width: 2.0,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: Color(0xFF000000),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLogoColor(String title) {
    switch (title.toLowerCase()) {
      case 'paypal':
        return Color(0xFF0070BA);
      case 'apple pay':
        return Color(0xFF000000);
      case 'stripe':
        return Color(0xFF635BFF);
      case 'razor pay':
        return Color(0xFF3395FF);
      default:
        return Color(0xFF404040);
    }
  }

  IconData _getLogoIcon(String title) {
    switch (title.toLowerCase()) {
      case 'paypal':
        return Icons.payment;
      case 'apple pay':
        return Icons.apple;
      case 'stripe':
        return Icons.credit_card;
      case 'razor pay':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  Color _getLogoIconColor(String title) {
    switch (title.toLowerCase()) {
      case 'apple pay':
        return Color(0xFFFFFFFF);
      default:
        return Color(0xFFFFFFFF);
    }
  }
}
