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
      print('⚠️ NOTA: Funcionalidad de Google Pay en desarrollo');
      print('⚠️ Por ahora, redirigiendo a flujo de Credit/Debit Card');
      
      // TODO: Implementar Google Pay con la versión correcta de flutter_stripe
      // Por ahora, retornamos error para que use el flujo de tarjeta normal
      
      return {
        'success': false,
        'error': 'not_implemented',
        'message': 'Google Pay is not yet implemented. Please use Credit/Debit Card.',
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

