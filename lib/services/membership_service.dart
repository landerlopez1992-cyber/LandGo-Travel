import 'package:supabase_flutter/supabase_flutter.dart';

/// 🎯 MEMBERSHIP SERVICE
/// Maneja todas las operaciones de membresías de LandGo Travel
class MembershipService {
  static final _supabase = Supabase.instance.client;

  /// Obtener membresía actual del usuario
  static Future<Map<String, dynamic>?> getCurrentMembership() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('memberships')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error getting membership: $e');
      return null;
    }
  }

  /// Calcular upgrade prorrateado
  /// 
  /// Ejemplo: Si tienes Basic ($29) y quieres subir a Premium ($49)
  /// y quedan 15 días en tu ciclo, pagas: ($49-$29) × (15/30) = $10
  static Future<Map<String, dynamic>> calculateProratedUpgrade({
    required String newMembershipType,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase.rpc(
        'calculate_prorated_upgrade',
        params: {
          'p_user_id': user.id,
          'p_new_membership_type': newMembershipType,
        },
      );

      print('🔍 Prorated calculation: $response');
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      print('❌ Error calculating prorated upgrade: $e');
      rethrow;
    }
  }

  /// Realizar upgrade de membresía
  /// 
  /// Si es upgrade: Calcular y cobrar monto prorrateado
  /// Si es downgrade: Programar para final del período
  static Future<Map<String, dynamic>> upgradeMembership({
    required String newMembershipType,
    required double proratedAmount,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Obtener membresía actual
      final currentMembership = await getCurrentMembership();
      if (currentMembership == null) {
        throw Exception('No current membership found');
      }

      final currentType = currentMembership['membership_type'] as String;
      
      // Determinar si es upgrade o downgrade
      final membershipLevels = {'Free': 0, 'Basic': 1, 'Premium': 2, 'VIP': 3};
      final currentLevel = membershipLevels[currentType] ?? 0;
      final newLevel = membershipLevels[newMembershipType] ?? 0;
      
      final isUpgrade = newLevel > currentLevel;
      
      if (isUpgrade) {
        // UPGRADE: Actualizar inmediatamente
        await _supabase
            .from('memberships')
            .update({
              'membership_type': newMembershipType,
              'previous_membership_type': currentType,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id);

        return {
          'success': true,
          'type': 'upgrade',
          'message': 'Membership upgraded successfully!',
          'prorated_amount': proratedAmount,
        };
      } else {
        // DOWNGRADE: Programar para final del período
        await _supabase
            .from('memberships')
            .update({
              'pending_downgrade_to': newMembershipType,
              'downgrade_at_period_end': true,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id);

        return {
          'success': true,
          'type': 'downgrade',
          'message': 'Downgrade scheduled for end of billing period',
          'effective_date': currentMembership['current_period_end'],
        };
      }
    } catch (e) {
      print('❌ Error upgrading membership: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Validar si puede cancelar membresía (anti-abuso)
  /// 
  /// Verifica:
  /// - Compromiso mínimo de 3 meses
  /// - Período de espera desde última cancelación
  /// - Calcula penalización si aplica
  static Future<Map<String, dynamic>> validateCancellation() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase.rpc(
        'validate_membership_cancellation',
        params: {
          'p_user_id': user.id,
        },
      );

      print('🔍 Cancellation validation: $response');
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      print('❌ Error validating cancellation: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Cancelar membresía
  /// 
  /// La cancelación se hace efectiva al final del período pagado
  /// REQUIERE haber completado 3 meses o pagar penalización
  static Future<Map<String, dynamic>> cancelMembership({
    bool acceptPenalty = false,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Primero validar si puede cancelar
      final validation = await validateCancellation();
      
      if (validation['success'] != true) {
        return validation;
      }

      // Si requiere penalty y no la acepta
      if (validation['penalty_amount'] != null && 
          validation['penalty_amount'] > 0 && 
          !acceptPenalty) {
        return {
          'success': false,
          'requires_penalty': true,
          'penalty_amount': validation['penalty_amount'],
          'message': validation['message'],
        };
      }

      final currentMembership = await getCurrentMembership();
      if (currentMembership == null) {
        throw Exception('No current membership found');
      }

      await _supabase
          .from('memberships')
          .update({
            'pending_downgrade_to': 'Free',
            'downgrade_at_period_end': true,
            'cancelled_at': DateTime.now().toIso8601String(),
            'last_cancellation_date': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id);

      return {
        'success': true,
        'message': 'Membership will be cancelled at end of billing period',
        'effective_date': currentMembership['current_period_end'],
        'penalty_charged': validation['penalty_amount'] ?? 0.00,
      };
    } catch (e) {
      print('❌ Error cancelling membership: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Obtener nombre del tipo de membresía
  static String getMembershipName(String type) {
    switch (type) {
      case 'Free':
        return 'Free';
      case 'Basic':
        return 'Basic';
      case 'Premium':
        return 'Premium';
      case 'VIP':
        return 'VIP';
      default:
        return 'Free';
    }
  }

  /// Obtener precio de membresía
  static double getMembershipPrice(String type) {
    switch (type) {
      case 'Free':
        return 0.00;
      case 'Basic':
        return 29.00;
      case 'Premium':
        return 49.00;
      case 'VIP':
        return 79.00;
      default:
        return 0.00;
    }
  }

  /// Obtener porcentaje de cashback
  static double getCashbackPercentage(String type) {
    switch (type) {
      case 'Free':
        return 0.00;
      case 'Basic':
        return 3.00;
      case 'Premium':
        return 5.00;
      case 'VIP':
        return 8.00;
      default:
        return 0.00;
    }
  }
}



