import '/flutter_flow/flutter_flow_util.dart';
import '/auth/supabase_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'review_summary_page_model.dart';
export 'review_summary_page_model.dart';

class ReviewSummaryPageWidget extends StatefulWidget {
  const ReviewSummaryPageWidget({super.key});

  static String routeName = 'ReviewSummaryPage';
  static String routePath = '/reviewSummaryPage';

  @override
  State<ReviewSummaryPageWidget> createState() => _ReviewSummaryPageWidgetState();
}

class _ReviewSummaryPageWidgetState extends State<ReviewSummaryPageWidget> {
  late ReviewSummaryPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReviewSummaryPageModel());
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
              'Review summary',
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
            children: [
              // Información del usuario y booking
              _buildInfoCard(),
              SizedBox(height: 16.0),
              
              // Método de pago
              _buildPaymentMethodCard(),
              SizedBox(height: 16.0),
              
              // Resumen de pago
              _buildPaymentSummaryCard(),
              
              Spacer(),
              
              // Botón de confirmación
              Container(
                width: double.infinity,
                height: 56.0,
                decoration: BoxDecoration(
                  color: Color(0xFF4DD0E1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _showPaymentSuccessDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Confirm payment',
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

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        child: Column(
          children: [
            _buildInfoRow('Name', 'Dev Cooper'),
            SizedBox(height: 12.0),
            _buildInfoRow('Phone', '-'),
            SizedBox(height: 12.0),
            _buildInfoRow('Booking Date', 'Sat, 27 Sep 2025'),
            SizedBox(height: 12.0),
            _buildInfoRow('Duration', '4 - 7 days'),
            SizedBox(height: 12.0),
            _buildInfoRow('Number of people', '1'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        child: Row(
          children: [
            // Logo de Stripe
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: Color(0xFF635BFF),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Icon(
                Icons.credit_card,
                color: Color(0xFFFFFFFF),
                size: 20.0,
              ),
            ),
            SizedBox(width: 16.0),
            
            // Nombre del método de pago
            Expanded(
              child: Text(
                'Stripe',
                style: GoogleFonts.inter(
                  color: Color(0xFFFFFFFF),
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Botón Change
            Container(
              height: 32.0,
              decoration: BoxDecoration(
                color: Color(0xFFFF6B6B),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.pushNamed('PaymentMethodPage');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Change',
                  style: GoogleFonts.inter(
                    color: Color(0xFFFFFFFF),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: GoogleFonts.inter(
                color: Color(0xFFFFFFFF),
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            
            _buildPaymentRow('Price per person (number of people 1)', '\$45'),
            SizedBox(height: 8.0),
            _buildPaymentRow('Taxes & fees', '\$10'),
            SizedBox(height: 8.0),
            _buildPaymentRow('Sub Total', '\$55'),
            
            // Línea divisoria
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.0),
              height: 1.0,
              color: Color(0xFF404040),
            ),
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Payment Amount',
                  style: GoogleFonts.inter(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$55',
                  style: GoogleFonts.inter(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Color(0xFFFFFFFF),
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Color(0xFFFFFFFF),
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Color(0xFFFFFFFF),
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Color(0xFFFFFFFF),
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 320.0,
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono de éxito
                  Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF4DD0E1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: Color(0xFF4DD0E1),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Color(0xFFFFFFFF),
                        size: 30.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  
                  // Título
                  Text(
                    'Payment successful',
                    style: GoogleFonts.inter(
                      color: Color(0xFF000000),
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.0),
                  
                  // Mensaje
                  Text(
                    'Thank you for choose your courses. go to home to continue your journey',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Color(0xFF666666),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  
                  // Botón
                  Container(
                    width: double.infinity,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: Color(0xFF4DD0E1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Cerrar dialog
                        context.goNamed('MainPage'); // Ir al home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        'Go to home',
                        style: GoogleFonts.inter(
                          color: Color(0xFF000000),
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
