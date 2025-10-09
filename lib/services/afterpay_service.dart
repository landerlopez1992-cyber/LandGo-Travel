import 'package:supabase_flutter/supabase_flutter.dart';

/// 🆕 AFTERPAY SERVICE
/// Maneja las interacciones con Afterpay a través de Stripe
class AfterpayService {
  static const String _functionName = 'stripe-payment';

  /// Crear sesión de Afterpay
  static Future<Map<String, dynamic>> createAfterpaySession({
    required double amount,
    required String customerId,
    String currency = 'usd',
    Map<String, dynamic>? billingDetails,
  }) async {
    try {
      print('🔍 DEBUG: Creating Afterpay session for amount: \$${amount.toStringAsFixed(2)}');

      final response = await Supabase.instance.client.functions.invoke(
        _functionName,
        body: {
          'action': 'create_afterpay_session',
          'amount': amount,
          'currency': currency,
          'customerId': customerId,
          'billingDetails': billingDetails,
        },
      );

      print('🔍 DEBUG: Afterpay session response: ${response.data}');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'clientSecret': response.data['clientSecret'],
          'paymentIntentId': response.data['paymentIntentId'],
          'redirectUrl': response.data['redirectUrl'],
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to create Afterpay session');
      }
    } catch (e) {
      print('❌ ERROR creating Afterpay session: $e');
      rethrow;
    }
  }

  /// Confirmar pago de Afterpay
  static Future<Map<String, dynamic>> confirmAfterpayPayment({
    required String paymentIntentId,
  }) async {
    try {
      print('🔍 DEBUG: Confirming Afterpay payment: $paymentIntentId');

      final response = await Supabase.instance.client.functions.invoke(
        _functionName,
        body: {
          'action': 'confirm_afterpay_payment',
          'paymentIntentId': paymentIntentId,
        },
      );

      print('🔍 DEBUG: Afterpay payment confirmation response: ${response.data}');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'status': response.data['status'],
          'paymentIntent': response.data['paymentIntent'],
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to confirm Afterpay payment');
      }
    } catch (e) {
      print('❌ ERROR confirming Afterpay payment: $e');
      rethrow;
    }
  }
}
