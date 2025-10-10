import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';

/// Mixin para funcionalidad de Cancel Membership
/// Usar en MyProfilePageWidget para mantener el código organizado
mixin CancelMembershipMixin {
  BuildContext get context;
  
  /// Maneja el flujo completo de cancelación de membresía
  Future<void> handleCancelMembership() async {
    print('🔴 [Cancel Membership] Iniciando proceso...');
    
    final currentUser = SupaFlow.client.auth.currentUser;
    if (currentUser == null) {
      print('❌ [Cancel Membership] Usuario no autenticado');
      _showMessage('Please log in to continue');
      return;
    }
    
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
          ),
        ),
      );
      
      // Obtener información de membresía
      print('📋 [Cancel Membership] Obteniendo información de membresía...');
      final response = await SupaFlow.client.rpc(
        'get_membership_cancellation_info',
        params: {'p_user_id': currentUser.id},
      );
      
      print('✅ [Cancel Membership] Respuesta: $response');
      
      // Cerrar loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      // Verificar si tiene membresía activa
      if (response == null || response['has_membership'] == false) {
        print('ℹ️ [Cancel Membership] No tiene membresía activa');
        _showMessage(response?['message'] ?? 'You don\'t have an active paid membership');
        return;
      }
      
      // Mostrar diálogo de confirmación
      if (context.mounted) {
        _showCancellationDialog(response);
      }
    } catch (e) {
      print('❌ [Cancel Membership] Error: $e');
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _showMessage('Error getting membership information: ${e.toString()}');
    }
  }
  
  /// Muestra el diálogo de confirmación de cancelación
  void _showCancellationDialog(dynamic membershipInfo) {
    final membershipType = membershipInfo['membership_type'] ?? 'Unknown';
    final monthlyPrice = (membershipInfo['monthly_price'] ?? 0).toDouble();
    final monthsCompleted = membershipInfo['months_completed'] ?? 0;
    final minimumMonths = membershipInfo['minimum_commitment_months'] ?? 6;
    final canCancelWithoutPenalty = membershipInfo['can_cancel_without_penalty'] ?? false;
    final penaltyAmount = (membershipInfo['penalty_amount'] ?? 0).toDouble();
    final nextBillingDate = membershipInfo['next_billing_date'];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFDC2626).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header con ícono de advertencia
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626),
                      size: 36,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Título
                  Text(
                    'Cancel $membershipType Membership?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Divider
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Información de membresía
                  _buildInfoRow('Current Plan', membershipType, const Color(0xFF4DD0E1)),
                  const SizedBox(height: 12),
                  _buildInfoRow('Monthly Price', '\$${monthlyPrice.toStringAsFixed(2)}', const Color(0xFF4DD0E1)),
                  const SizedBox(height: 12),
                  _buildInfoRow('Commitment Progress', '$monthsCompleted / $minimumMonths months', const Color(0xFF4DD0E1)),
                  
                  if (!canCancelWithoutPenalty) ...[
                    const SizedBox(height: 20),
                    
                    // Penalty warning
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFDC2626).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFDC2626),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Early Cancellation Fee',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFDC2626),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You haven\'t completed the 6-month minimum commitment. Cancelling now requires a penalty payment.',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '\$${penaltyAmount.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFDC2626),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Buttons
                  if (canCancelWithoutPenalty) ...[
                    // Solo "Schedule Cancel" sin penalty
                    _buildActionButton(
                      label: 'Schedule Cancellation',
                      subtitle: 'Cancel at end of billing period',
                      icon: Icons.schedule,
                      color: const Color(0xFFFF6B00),
                      onTap: () {
                        Navigator.pop(context);
                        _scheduleCancellation();
                      },
                    ),
                  ] else ...[
                    // "Pay & Cancel Now"
                    _buildActionButton(
                      label: 'Pay \$${penaltyAmount.toStringAsFixed(2)} & Cancel Now',
                      subtitle: 'Immediate cancellation',
                      icon: Icons.payment,
                      color: const Color(0xFFDC2626),
                      onTap: () {
                        Navigator.pop(context);
                        _cancelImmediateWithPenalty(penaltyAmount);
                      },
                    ),
                    const SizedBox(height: 12),
                    // "Schedule Cancel"
                    _buildActionButton(
                      label: 'Schedule Cancellation',
                      subtitle: 'No penalty, keeps access until $nextBillingDate',
                      icon: Icons.schedule,
                      color: const Color(0xFFFF6B00),
                      onTap: () {
                        Navigator.pop(context);
                        _scheduleCancellation();
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Keep My Membership',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF4DD0E1),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
  
  /// Construye una fila de información
  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  /// Construye un botón de acción
  Widget _buildActionButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Cancelación inmediata con penalty
  Future<void> _cancelImmediateWithPenalty(double penaltyAmount) async {
    print('💳 [Cancel Membership] Cancelando con penalty: \$${penaltyAmount.toStringAsFixed(2)}');
    
    // TODO: Implementar flujo de pago con Stripe
    // Por ahora mostraremos un mensaje de que la funcionalidad está en desarrollo
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'Payment Processing',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Penalty payment processing will be implemented soon!\n\nYou would be charged \$${penaltyAmount.toStringAsFixed(2)} to cancel your membership immediately.',
          style: GoogleFonts.outfit(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.outfit(
                color: const Color(0xFF4DD0E1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Cancelación programada (sin penalty)
  Future<void> _scheduleCancellation() async {
    print('📅 [Cancel Membership] Programando cancelación...');
    
    final currentUser = SupaFlow.client.auth.currentUser;
    if (currentUser == null) return;
    
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
          ),
        ),
      );
      
      // Llamar función SQL
      final response = await SupaFlow.client.rpc(
        'schedule_membership_cancellation',
        params: {'p_user_id': currentUser.id},
      );
      
      print('✅ [Cancel Membership] Programado: $response');
      
      // Cerrar loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      if (response['success'] == true) {
        final cancellationDate = response['cancellation_date'];
        _showSuccessDialog(
          'Cancellation Scheduled',
          'Your membership will be cancelled on $cancellationDate.\n\nYou\'ll keep full access until then.',
        );
      } else {
        _showMessage('Error scheduling cancellation: ${response['error']}');
      }
    } catch (e) {
      print('❌ [Cancel Membership] Error: $e');
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _showMessage('Error scheduling cancellation: ${e.toString()}');
    }
  }
  
  /// Muestra un mensaje usando SnackBar
  void _showMessage(String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2C2C2C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Muestra un diálogo de éxito
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF4DD0E1),
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.outfit(
                color: const Color(0xFF4DD0E1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



