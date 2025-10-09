import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pay/pay.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '/services/stripe_service.dart';

/// 💳 GOOGLE PAY SERVICE - LANDGO TRAVEL
/// 
/// Maneja toda la lógica de Google Pay integrada con Stripe
/// 
/// FLUJO:
/// 1. Usuario selecciona Google Pay
/// 2. Se muestra el botón/sheet de Google Pay
/// 3. Usuario confirma el pago
/// 4. Google Pay retorna un token
/// 5. Creamos PaymentMethod con el token
/// 6. Procesamos el pago con Stripe
/// 7. Actualizamos balance y registramos transacción

class GooglePayService {
  // Configuration
  static const String _paymentConfigAsset = 'assets/google_pay_config.json';
  
  /// Verificar si Google Pay está disponible en el dispositivo
  static Future<bool> isAvailable() async {
    try {
      final config = await rootBundle.loadString(_paymentConfigAsset);
      final paymentConfig = PaymentConfiguration.fromJsonString(config);
      
      // Intentar crear un PayClient para verificar disponibilidad
      final payClient = Pay.withAssets([_paymentConfigAsset]);
      
      // Nota: En producción, deberías verificar si el usuario tiene
      // tarjetas configuradas en Google Pay
      return true;
    } catch (e) {
      print('❌ Google Pay no disponible: $e');
      return false;
    }
  }
  
  /// Procesar pago con Google Pay
  /// 
  /// @param amount - Monto total a pagar (con fees incluidos)
  /// @param onSuccess - Callback cuando el pago es exitoso
  /// @param onError - Callback cuando hay un error
  /// @param onCancelled - Callback cuando el usuario cancela
  static Future<Map<String, dynamic>?> processPayment({
    required double amount,
    String currency = 'USD',
    String countryCode = 'US',
  }) async {
    try {
      print('🔍 DEBUG GooglePay: Iniciando pago de \$$amount');
      
      // 1. Cargar configuración de Google Pay
      final configString = await rootBundle.loadString(_paymentConfigAsset);
      final configJson = json.decode(configString);
      
      // 2. Actualizar el monto en la configuración
      configJson['data']['transactionInfo'] = {
        'totalPriceStatus': 'FINAL',
        'totalPrice': amount.toStringAsFixed(2),
        'currencyCode': currency,
        'countryCode': countryCode,
      };
      
      // 3. Crear PaymentConfiguration
      final paymentConfig = PaymentConfiguration.fromJsonString(
        json.encode(configJson)
      );
      
      // 4. Inicializar Pay client
      final payClient = Pay.withAssets([_paymentConfigAsset]);
      
      // 5. Obtener el token de Google Pay
      print('🔍 DEBUG GooglePay: Solicitando token...');
      
      final result = await payClient.showPaymentSelector(
        provider: PayProvider.google_pay,
        paymentItems: [
          PaymentItem(
            label: 'LandGo Travel Wallet Top-up',
            amount: amount.toStringAsFixed(2),
            status: PaymentItemStatus.final_price,
          ),
        ],
      );
      
      print('🔍 DEBUG GooglePay: Token recibido');
      print('🔍 DEBUG GooglePay: Result type: ${result.runtimeType}');
      
      // 6. Parsear el resultado
      final paymentData = json.decode(result);
      print('🔍 DEBUG GooglePay: Payment data: $paymentData');
      
      // 7. Extraer el token de Google Pay
      final paymentMethodData = paymentData['paymentMethodData'];
      final tokenizationData = paymentMethodData['tokenizationData'];
      final token = tokenizationData['token'];
      
      print('🔍 DEBUG GooglePay: Token extraído: ${token.substring(0, 20)}...');
      
      // 8. Retornar el token para procesarlo
      return {
        'success': true,
        'token': token,
        'paymentData': paymentData,
      };
      
    } on PlatformException catch (e) {
      if (e.code == Pay.userCancelledError) {
        print('⚠️ Usuario canceló Google Pay');
        return {
          'success': false,
          'error': 'cancelled',
          'message': 'Payment cancelled by user',
        };
      } else {
        print('❌ Error de plataforma Google Pay: ${e.code} - ${e.message}');
        return {
          'success': false,
          'error': 'platform_error',
          'message': e.message ?? 'Unknown platform error',
        };
      }
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
  
  /// Crear PaymentMethod de Stripe con token de Google Pay
  /// 
  /// @param googlePayToken - Token retornado por Google Pay
  /// @return PaymentMethod ID de Stripe
  static Future<String?> createPaymentMethodFromGooglePayToken(
    String googlePayToken,
  ) async {
    try {
      print('🔍 DEBUG GooglePay: Creando PaymentMethod con token de Google Pay');
      
      // El token de Google Pay ya es un token de Stripe
      // Solo necesitamos crear el PaymentMethod
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            // Google Pay retorna un token que Stripe puede usar directamente
            token: googlePayToken,
          ),
        ),
      );
      
      print('✅ PaymentMethod creado: ${paymentMethod.id}');
      return paymentMethod.id;
      
    } catch (e) {
      print('❌ Error creando PaymentMethod desde Google Pay: $e');
      return null;
    }
  }
  
  /// Botón de Google Pay (Widget)
  /// 
  /// Este widget muestra el botón oficial de Google Pay
  /// y maneja todo el flujo de pago
  static Pay getGooglePayButton({
    required double amount,
    required Function(Map<String, dynamic>) onPaymentResult,
  }) {
    return Pay.withAssets(
      [_paymentConfigAsset],
      onPaymentResult: (result) {
        print('🔍 DEBUG GooglePay: onPaymentResult callback');
        print('🔍 DEBUG GooglePay: Result: $result');
        onPaymentResult(result as Map<String, dynamic>);
      },
    );
  }
}

