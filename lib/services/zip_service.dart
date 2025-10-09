import 'package:supabase_flutter/supabase_flutter.dart';

/// 🆕 ZIP SERVICE
/// Maneja las interacciones con Zip a través de Stripe
class ZipService {
  static const String _functionName = 'stripe-payment';

  /// Crear sesión de Zip
  static Future<Map<String, dynamic>> createZipSession({
    required double amount,
    required String customerId,
    String currency = 'usd',
    Map<String, dynamic>? billingDetails,
  }) async {
    try {
      print('🔍 DEBUG: Creating Zip session for amount: \$${amount.toStringAsFixed(2)}');

      final response = await Supabase.instance.client.functions.invoke(
        _functionName,
        body: {
          'action': 'create_zip_session',
          'amount': amount,
          'currency': currency,
          'customerId': customerId,
          'billingDetails': billingDetails,
        },
      );

      print('🔍 DEBUG: Zip session response: ${response.data}');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'clientSecret': response.data['clientSecret'],
          'paymentIntentId': response.data['paymentIntentId'],
          'redirectUrl': response.data['redirectUrl'],
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to create Zip session');
      }
    } catch (e) {
      print('❌ ERROR creating Zip session: $e');
      rethrow;
    }
  }

  /// Confirmar pago de Zip
  static Future<Map<String, dynamic>> confirmZipPayment({
    required String paymentIntentId,
  }) async {
    try {
      print('🔍 DEBUG: Confirming Zip payment: $paymentIntentId');

      final response = await Supabase.instance.client.functions.invoke(
        _functionName,
        body: {
          'action': 'confirm_zip_payment',
          'paymentIntentId': paymentIntentId,
        },
      );

      print('🔍 DEBUG: Zip payment confirmation response: ${response.data}');

      if (response.data['success'] == true) {
        return {
          'success': true,
          'status': response.data['status'],
          'paymentIntent': response.data['paymentIntent'],
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to confirm Zip payment');
      }
    } catch (e) {
      print('❌ ERROR confirming Zip payment: $e');
      rethrow;
    }
  }
}
