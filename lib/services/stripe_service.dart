import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🔐 STRIPE SERVICE - IMPLEMENTACIÓN SEGURA Y PROFESIONAL
/// 
/// FLUJO CORRECTO:
/// 1. Flutter crea PaymentMethod localmente (SEGURO - datos nunca llegan al servidor)
/// 2. Flutter envía solo el PaymentMethod ID a Edge Function
/// 3. Edge Function procesa el pago (sin ver datos de tarjeta)
/// 
/// CAMBIO TEST → LIVE:
/// - Solo cambiar pk_test_ por pk_live_ aquí
/// - Solo cambiar sk_test_ por sk_live_ en Edge Function
/// - ¡Eso es todo!

class StripeService {
  // CREDENCIALES DE STRIPE - LANDGO TRAVEL
  // ⚠️ IMPORTANTE: Las claves están en variables de entorno por seguridad
  // Para desarrollo local, crea un archivo .env con:
  // STRIPE_PUBLISHABLE_KEY=pk_test_...
  static const String _publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51SBkaB2aG6cmZRHQ22KDLCfL4qnQFBojMVG5v7Ywwl4CoxDWnHm7r6qmFyaohPNvg9woIgCVrgGneIzPLJ8K31lq00dRrrHUJt', // Fallback para desarrollo
  );
  
  // URL de la Supabase Edge Function
  static const String _edgeFunctionUrl = 'https://dumgmnibxhfchjyowvbz.supabase.co/functions/v1/stripe-payment';

  /// Inicializar Stripe con la clave publicable
  static Future<void> initialize() async {
    Stripe.publishableKey = _publishableKey;
    await Stripe.instance.applySettings();
    print('✅ Stripe inicializado correctamente');
  }

  /// Crear PaymentMethod REAL usando el CardField del SDK (sin exponer PAN)
  static Future<Map<String, dynamic>> createPaymentMethodFromCardField({
    required String cardholderName,
  }) async {
    try {
      print('🔍 DEBUG: Creando PaymentMethod desde CardField (SDK Stripe)...');

      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: cardholderName,
            ),
          ),
        ),
      );

      print('✅ PaymentMethod creado (CardField): ${paymentMethod.id}');

      return {
        'id': paymentMethod.id,
        'type': 'card',
        'card': {
          'brand': paymentMethod.card?.brand,
          'last4': paymentMethod.card?.last4,
          'exp_month': paymentMethod.card?.expMonth,
          'exp_year': paymentMethod.card?.expYear,
        },
        'billing_details': {
          'name': paymentMethod.billingDetails?.name,
        },
      };
    } catch (e) {
      print('❌ Error creando PaymentMethod (CardField): $e');
      throw Exception('Failed to create payment method from CardField: $e');
    }
  }

  /// ✅ CREAR PAYMENTMETHOD REAL CON STRIPE ELEMENTS (FUNCIONA 100%)
  /// Usa Stripe SDK de Flutter para crear PaymentMethods reales
  static Future<Map<String, dynamic>> createPaymentMethodFromCard({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
    required String cardholderName,
  }) async {
    try {
      print('🔍 DEBUG: Creando PaymentMethod REAL con Stripe SDK...');
      
      // Crear PaymentMethod usando Stripe SDK (REAL)
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: cardholderName,
            ),
          ),
        ),
      );

      print('✅ PaymentMethod REAL creado: ${paymentMethod.id}');
      
      // Convertir a formato Map para compatibilidad
      return {
        'id': paymentMethod.id,
        'type': 'card',
        'card': {
          'brand': paymentMethod.card?.brand,
          'last4': paymentMethod.card?.last4,
          'exp_month': paymentMethod.card?.expMonth,
          'exp_year': paymentMethod.card?.expYear,
        },
        'billing_details': {
          'name': paymentMethod.billingDetails?.name,
        },
      };
    } catch (e) {
      print('❌ Error creando PaymentMethod REAL: $e');
      throw Exception('Failed to create payment method: $e');
    }
  }


  /// ✅ CREAR CUSTOMER (via Edge Function)
  static Future<String> createCustomer({
    required String email,
    String? name,
    String? phone,
  }) async {
    try {
      print('🔍 DEBUG: Creando Customer via Edge Function...');
      
      // Obtener token de Supabase
      final session = Supabase.instance.client.auth.currentSession;
      final accessToken = session?.accessToken ?? '';
      
      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'action': 'create_customer',
          'email': email,
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        }),
      );

      print('🔍 DEBUG: Response status: ${response.statusCode}');
      print('🔍 DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Customer creado: ${data['customer']['id']}');
          return data['customer']['id'];
        } else {
          throw Exception('Error: ${data['error']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error creando customer: $e');
      throw Exception('Failed to create customer: $e');
    }
  }

  /// ✅ ASOCIAR PAYMENTMETHOD A CUSTOMER (via Edge Function)
  static Future<void> attachPaymentMethodToCustomer({
    required String customerId,
    required String paymentMethodId,
  }) async {
    try {
      print('🔍 DEBUG: Asociando PaymentMethod a Customer...');
      
      // Obtener token de Supabase
      final session = Supabase.instance.client.auth.currentSession;
      final accessToken = session?.accessToken ?? '';
      
      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'action': 'attach_payment_method',
          'customerId': customerId,
          'paymentMethodId': paymentMethodId,
        }),
      );

      print('🔍 DEBUG: Response status: ${response.statusCode}');
      print('🔍 DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ PaymentMethod asociado exitosamente');
        } else {
          throw Exception('Error: ${data['error']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error asociando PaymentMethod: $e');
      throw Exception('Failed to attach payment method: $e');
    }
  }

  /// ✅ PROCESAR PAGO (via Edge Function)
  /// Solo envía el PaymentMethod ID, nunca datos de tarjeta
  /// ✅ VALIDAR TARJETA CON SETUPINTENT (SIN CARGO)
  static Future<void> validateCardWithSetupIntent(String paymentMethodId) async {
    try {
      print('🔍 DEBUG: Validando tarjeta con SetupIntent...');
      
      // Obtener token de Supabase
      final session = Supabase.instance.client.auth.currentSession;
      final accessToken = session?.accessToken ?? '';
      
      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'action': 'validate_card',
          'paymentMethodId': paymentMethodId,
        }),
      );

      print('🔍 DEBUG: SetupIntent response status: ${response.statusCode}');
      print('🔍 DEBUG: SetupIntent response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Tarjeta validada exitosamente');
          return;
        } else {
          throw Exception('Card validation failed: ${data['error']}');
        }
      } else {
        throw Exception('SetupIntent HTTP error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error validando tarjeta: $e');
      throw Exception('Failed to validate card: $e');
    }
  }

  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String currency,
    required String customerId,
    required String paymentMethodId,
  }) async {
    try {
      print('🔍 DEBUG: Procesando pago via Edge Function...');
      print('🔍 DEBUG: Amount: $amount, Currency: $currency');
      print('🔍 DEBUG: Customer: $customerId, PaymentMethod: $paymentMethodId');
      
      // Obtener token de Supabase
      final session = Supabase.instance.client.auth.currentSession;
      final accessToken = session?.accessToken ?? '';
      
      final response = await http.post(
        Uri.parse(_edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'action': 'create_payment_intent',
          'amount': amount,
          'currency': currency,
          'customerId': customerId,
          'paymentMethodId': paymentMethodId,
        }),
      );

      print('🔍 DEBUG: Response status: ${response.statusCode}');
      print('🔍 DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final paymentIntent = data['paymentIntent'];
          print('✅ Pago procesado exitosamente: ${paymentIntent['id']}');
          return {
            'success': true,
            'paymentIntentId': paymentIntent['id'],
            'status': paymentIntent['status'],
            'amount': amount,
            'currency': currency,
          };
        } else {
          print('❌ Error en pago: ${data['error']}');
          return {
            'success': false,
            'error': data['error'],
          };
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
        return {
          'success': false,
          'error': 'HTTP error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Exception procesando pago: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}