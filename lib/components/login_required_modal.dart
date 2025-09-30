import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Modal de login requerido para usuarios no autenticados
/// Basado en el diseño de la imagen de referencia
class LoginRequiredModal extends StatelessWidget {
  const LoginRequiredModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 320,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de advertencia
            _buildWarningIcon(),
            
            // Texto principal
            _buildMainText(),
            
            // Botones de acción
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningIcon() {
    return Container(
      margin: EdgeInsets.only(top: 24, bottom: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo exterior rosa
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFFFB3BA), // Rosa claro
              shape: BoxShape.circle,
            ),
          ),
          // Círculo interior rojo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xFFDC2626), // Rojo
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'You need to be logged in to edit your personal information',
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          // Botón "No" (Cancelar)
          Expanded(
            child: _buildNoButton(context),
          ),
          SizedBox(width: 12),
          // Botón "Yes" (Login)
          Expanded(
            child: _buildYesButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNoButton(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.of(context).pop(); // Cerrar modal
          },
          child: Center(
            child: Text(
              'No',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYesButton(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Color(0xFF4DD0E1), // Turquesa LandGo Travel
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.of(context).pop(); // Cerrar modal
            context.pushNamed('LoginPage'); // Navegar a login
          },
          child: Center(
            child: Text(
              'Login',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
