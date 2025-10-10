/// Configuración de Stripe para Test y Live modes
class StripeConfig {
  // Clave de Stripe (TEST mode por defecto)
  static const String _stripeKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51SBkaB2aG6cmZRHQ22KDLCfL4qnQFBojMVG5v7Ywwl4CoxDWnHm7r6qmFyaohPNvg9woIgCVrgGneIzPLJ8K31lq00dRrrHUJt',
  );
  
  // Detectar si estamos en modo test o live
  static bool get isTestMode {
    return _stripeKey.startsWith('pk_test_');
  }
  
  // Price IDs para TEST mode (REALES DE STRIPE)
  static const Map<String, String> testPriceIds = {
    'Basic': 'price_1SGVdz2aG6cmZRHQOOJRisXY',    // ✅ Basic $29/mes
    'Premium': 'price_1SGVht2aG6cmZRHQEFcSwpA5', // ✅ Premium $49/mes
    'VIP': 'price_1SGVjV2aG6cmZRHQgAsxvtnC',        // ✅ VIP $79/mes
  };
  
  // Price IDs para LIVE mode
  static const Map<String, String> livePriceIds = {
    'Basic': 'price_LIVE_BASIC_REPLACE_ME',    // TODO: Reemplazar con real live Price ID
    'Premium': 'price_LIVE_PREMIUM_REPLACE_ME', // TODO: Reemplazar con real live Price ID
    'VIP': 'price_LIVE_VIP_REPLACE_ME',        // TODO: Reemplazar con real live Price ID
  };
  
  /// Obtener Price ID según el modo actual (test/live)
  static String getPriceId(String membershipType) {
    final priceIds = isTestMode ? testPriceIds : livePriceIds;
    final priceId = priceIds[membershipType];
    
    if (priceId == null || priceId.contains('REPLACE_ME')) {
      throw Exception('Price ID not configured for $membershipType in ${isTestMode ? 'TEST' : 'LIVE'} mode');
    }
    
    return priceId;
  }
  
  /// Obtener precio según tipo de membresía (mismo en test y live)
  static double getPrice(String membershipType) {
    switch (membershipType) {
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
  
  /// Información de debug
  static Map<String, dynamic> get debugInfo => {
    'isTestMode': isTestMode,
    'currentPriceIds': isTestMode ? testPriceIds : livePriceIds,
    'stripeKeyPrefix': isTestMode ? 'pk_test_' : 'pk_live_',
  };
}

