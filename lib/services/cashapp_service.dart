import 'package:supabase_flutter/supabase_flutter.dart';

/// 🆕 CASH APP SERVICE
/// Maneja las interacciones con Cash App Pay a través de Stripe
class CashAppService {
  static const String _functionName = 'stripe-payment';

  /// Crear sesión de Cash App
  static Future<Map<String, dynamic>> createCashAppSession({
    required double amount,
    required String customerId,
    String currency = 'usd',
    Map<String, dynamic>? billingDetails,
  }) async {
    try {
      print('🔍 DEBUG: Creating Cash App session for amount: \$${amount.toStringAsFixed(2)}');

      final response = await Supabase.instance.client.functions.invoke(
        _functionName,
        body: {
          'action': 'create_cashapp_session',
          'amount': amount,
          'currency': currency,
          'customerId': customerId,
          'billingDetails': billingDetails,
        },
      );

      print('🔍 DEBUG: Cash App session response: ${response.data}');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'clientSecret': response.data['clientSecret'],
          'paymentIntentId': response.data['paymentIntentId'],
          'redirectUrl': response.data['redirectUrl'],
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to create Cash App session');
      }
    } catch (e) {
      print('❌ ERROR creating Cash App session: $e');
      rethrow;
    }
  }

  /// Confirmar pago de Cash App
  static Future<Map<String, dynamic>> confirmCashAppPayment({
    required String paymentIntentId,
  }) async {
    try {
      print('🔍 DEBUG: Confirming Cash App payment: $paymentIntentId');

      final response = await Supabase.instance.client.functions.invoke(
        _functionName,
        body: {
          'action': 'confirm_cashapp_payment',
          'paymentIntentId': paymentIntentId,
        },
      );

      print('🔍 DEBUG: Cash App payment confirmation response: ${response.data}');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'status': response.data['status'],
          'paymentIntent': response.data['paymentIntent'],
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to confirm Cash App payment');
      }
    } catch (e) {
      print('❌ ERROR confirming Cash App payment: $e');
      rethrow;
    }
  }
}
