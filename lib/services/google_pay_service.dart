import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import '/services/stripe_service.dart';

/// 💳 GOOGLE PAY SERVICE - LANDGO TRAVEL
/// 
/// Maneja toda la lógica de Google Pay integrada con Stripe
/// 
/// FLUJO CORRECTO CON STRIPE:
/// 1. Usuario selecciona Google Pay
/// 2. Llamamos a Stripe.instance.presentGooglePay()
/// 3. Google Pay sheet se abre
/// 4. Usuario confirma con Google Pay
/// 5. Stripe crea automáticamente el PaymentMethod
/// 6. Obtenemos el PaymentMethod ID
/// 7. Procesamos el pago con Stripe.processPayment()
/// 8. Actualizamos balance y registramos transacción

class GooglePayService {
  /// Verificar si Google Pay está disponible en el dispositivo
  static Future<bool> isAvailable() async {
    try {
      final isAvailable = await Stripe.instance.isGooglePaySupported(
        IsGooglePaySupportedParams(),
      );
      print('🔍 DEBUG GooglePay: Disponible = $isAvailable');
      return isAvailable;
    } catch (e) {
      print('❌ Google Pay no disponible: $e');
      return false;
    }
  }
  
  /// Procesar pago con Google Pay usando Stripe
  /// 
  /// @param amount - Monto total a pagar (con fees incluidos)
  /// @return Map con success, paymentMethodId, o error
  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    String currency = 'USD',
    String countryCode = 'US',
    required String merchantName,
  }) async {
    try {
      print('🔍 DEBUG GooglePay: Iniciando pago de \$$amount');
      
      // 1. Inicializar Google Pay con Stripe
      await Stripe.instance.initGooglePay(
        GooglePayInitParams(
          merchantName: merchantName,
          countryCode: countryCode,
          testEnv: true, // Cambiar a false en producción
        ),
      );
      
      print('✅ Google Pay inicializado');
      
      // 2. Presentar Google Pay sheet
      await Stripe.instance.presentGooglePay(
        PresentGooglePayParams(
          clientSecret: '', // No necesitamos clientSecret aún
          forSetupIntent: false,
          currencyCode: currency,
        ),
      );
      
      print('✅ Google Pay sheet presentado');
      
      // 3. Confirmar el pago de Google Pay
      // Esto crea automáticamente el PaymentMethod
      final paymentMethod = await Stripe.instance.createGooglePayPaymentMethod(
        CreateGooglePayPaymentMethodParams(
          currencyCode: currency,
          amount: (amount * 100).toInt(), // Stripe usa centavos
        ),
      );
      
      print('✅ PaymentMethod creado: ${paymentMethod.id}');
      
      // 4. Retornar el PaymentMethod ID para procesarlo
      return {
        'success': true,
        'paymentMethodId': paymentMethod.id,
      };
      
    } on StripeException catch (e) {
      print('❌ Stripe Error GooglePay: ${e.error.message}');
      
      if (e.error.code == FailureCode.Canceled) {
        return {
          'success': false,
          'error': 'cancelled',
          'message': 'Payment cancelled by user',
        };
      }
      
      return {
        'success': false,
        'error': 'stripe_error',
        'message': e.error.message ?? 'Unknown Stripe error',
      };
      
    } catch (e, stackTrace) {
      print('❌ Error procesando Google Pay: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'error': 'unknown',
        'message': e.toString(),
      };
    }
  }
}

