import 'package:supabase_flutter/supabase_flutter.dart';

/// 🆕 KLARNA SERVICE
/// Maneja todas las operaciones de pago con Klarna
class KlarnaService {
  static final _supabase = Supabase.instance.client;

  /// Crear sesión de Klarna
  /// 
  /// Llama al Edge Function para crear un PaymentIntent con Klarna
  /// 
  /// Retorna:
  /// - paymentIntentId: ID del PaymentIntent
  /// - clientSecret: Secret para autenticar con Stripe
  /// - status: Estado del pago
  /// - amount: Monto del pago
  static Future<Map<String, dynamic>> createKlarnaSession({
    required double amount,
    required String userId,
    String? customerId,
    Map<String, dynamic>? billingDetails,
  }) async {
    try {
      print('🔍 DEBUG: Creating Klarna session...');
      print('🔍 DEBUG: Amount: \$$amount');
      print('🔍 DEBUG: User ID: $userId');
      print('🔍 DEBUG: Customer ID: $customerId');

      // Llamar al Edge Function
      final response = await _supabase.functions.invoke(
        'stripe-payment',
        body: {
          'action': 'create_klarna_session',
          'amount': amount,
          'currency': 'usd',
          'userId': userId,
          if (customerId != null) 'customerId': customerId,
          if (billingDetails != null) 'billingDetails': billingDetails,
        },
      );

      print('🔍 DEBUG: Klarna session response status: ${response.status}');
      print('🔍 DEBUG: Klarna session response data: ${response.data}');

      if (response.status != 200) {
        throw Exception('Failed to create Klarna session: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error creating Klarna session');
      }

      print('✅ Klarna session created successfully');
      print('✅ Payment Intent ID: ${data['paymentIntentId']}');
      print('✅ Status: ${data['status']}');
      if (data['redirectUrl'] != null) {
        print('✅ Redirect URL: ${data['redirectUrl']}');
      } else {
        print('⚠️ No redirectUrl provided by backend; will fallback to checkout.stripe.com');
      }

      return {
        'paymentIntentId': data['paymentIntentId'],
        'clientSecret': data['clientSecret'],
        'status': data['status'],
        'amount': data['amount'],
        'redirectUrl': data['redirectUrl'],
      };
    } catch (e) {
      print('❌ ERROR creating Klarna session: $e');
      rethrow;
    }
  }

  /// Confirmar pago de Klarna
  /// 
  /// Verifica el estado de un PaymentIntent después de que el usuario
  /// complete el flujo de Klarna
  /// 
  /// Retorna:
  /// - status: succeeded, requires_action, pending, failed
  /// - amount: Monto del pago
  /// - metadata: Datos adicionales del pago
  static Future<Map<String, dynamic>> confirmKlarnaPayment({
    required String paymentIntentId,
  }) async {
    try {
      print('🔍 DEBUG: Confirming Klarna payment...');
      print('🔍 DEBUG: Payment Intent ID: $paymentIntentId');

      // Llamar al Edge Function
      final response = await _supabase.functions.invoke(
        'stripe-payment',
        body: {
          'action': 'confirm_klarna_payment',
          'paymentIntentId': paymentIntentId,
        },
      );

      print('🔍 DEBUG: Klarna confirm response status: ${response.status}');
      print('🔍 DEBUG: Klarna confirm response data: ${response.data}');

      if (response.status != 200) {
        throw Exception('Failed to confirm Klarna payment: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown error confirming Klarna payment');
      }

      final paymentIntent = data['paymentIntent'] as Map<String, dynamic>;
      final status = data['status'] as String;

      print('✅ Klarna payment confirmed');
      print('✅ Status: $status');
      print('✅ Amount: \$${data['amount']}');

      return {
        'status': status,
        'amount': data['amount'],
        'metadata': data['metadata'],
        'paymentIntent': paymentIntent,
      };
    } catch (e) {
      print('❌ ERROR confirming Klarna payment: $e');
      rethrow;
    }
  }

  /// Generar URL de Klarna para Webview
  /// 
  /// Klarna usa un checkout de Stripe que se puede abrir en Webview
  static String getKlarnaCheckoutUrl(String clientSecret) {
    // URL del checkout de Stripe con Klarna
    return 'https://checkout.stripe.com/pay/$clientSecret';
  }
}

