import 'package:supabase_flutter/supabase_flutter.dart';

/// 🆕 AFFIRM SERVICE
/// Maneja las interacciones con Affirm a través de Stripe
class AffirmService {
  static const String _functionName = 'stripe-payment';

  /// Crear sesión de Affirm
  static Future<Map<String, dynamic>> createAffirmSession({
    required double amount,
    required String customerId,
    String currency = 'usd',
    Map<String, dynamic>? billingDetails,
  }) async {
    try {
      print('🔍 DEBUG: Creating Affirm session for amount: \$${amount.toStringAsFixed(2)}');

      final response = await Supabase.instance.client.functions.invoke(
        _functionName,
        body: {
          'action': 'create_affirm_session',
          'amount': amount,
          'currency': currency,
          'customerId': customerId,
          'billingDetails': billingDetails,
        },
      );

      print('🔍 DEBUG: Affirm session response: ${response.data}');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'clientSecret': response.data['clientSecret'],
          'paymentIntentId': response.data['paymentIntentId'],
          'redirectUrl': response.data['redirectUrl'],
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to create Affirm session');
      }
    } catch (e) {
      print('❌ ERROR creating Affirm session: $e');
      rethrow;
    }
  }

  /// Confirmar pago de Affirm
  static Future<Map<String, dynamic>> confirmAffirmPayment({
    required String paymentIntentId,
  }) async {
    try {
      print('🔍 DEBUG: Confirming Affirm payment: $paymentIntentId');

      final response = await Supabase.instance.client.functions.invoke(
        _functionName,
        body: {
          'action': 'confirm_affirm_payment',
          'paymentIntentId': paymentIntentId,
        },
      );

      print('🔍 DEBUG: Affirm payment confirmation response: ${response.data}');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'status': response.data['status'],
          'paymentIntent': response.data['paymentIntent'],
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to confirm Affirm payment');
      }
    } catch (e) {
      print('❌ ERROR confirming Affirm payment: $e');
      rethrow;
    }
  }
}
