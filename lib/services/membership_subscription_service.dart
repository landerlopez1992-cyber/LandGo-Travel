import '/backend/supabase/supabase.dart';
import '/config/stripe_config.dart';

/// Servicio para manejar suscripciones de membresías con Stripe
class MembershipSubscriptionService {
  /// 1. CREAR SUSCRIPCIÓN
  /// Crea una nueva suscripción mensual en Stripe
  static Future<Map<String, dynamic>> createSubscription({
    required String membershipType,
    required String priceId,
  }) async {
    print('💳 [MembershipSubscriptionService] Creating subscription for $membershipType');
    
    final currentUser = SupaFlow.client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      // 1. Obtener Stripe Customer ID del usuario
      final profileResponse = await SupaFlow.client
          .from('profiles')
          .select('stripe_customer_id, full_name, email')
          .eq('id', currentUser.id)
          .single();
      
      print('📋 [MembershipSubscriptionService] Profile: $profileResponse');
      
      final customerId = profileResponse['stripe_customer_id'];
      if (customerId == null || customerId.isEmpty) {
        throw Exception('No Stripe customer found. Please add a payment method first.');
      }
      
      // 2. Obtener payment methods del usuario (intentar usar el primero disponible)
      String? paymentMethodId;
      try {
        final paymentMethodsResponse = await SupaFlow.client.functions.invoke(
          'stripe-payment',
          body: {
            'action': 'list_payment_methods',
            'customerId': customerId,
          },
        );
        
        final pmData = paymentMethodsResponse.data as Map<String, dynamic>?;
        final paymentMethods = pmData?['paymentMethods'] as List<dynamic>?;
        
        if (paymentMethods != null && paymentMethods.isNotEmpty) {
          paymentMethodId = paymentMethods.first['id'] as String?;
          print('💳 [MembershipSubscriptionService] Using payment method: $paymentMethodId');
        }
      } catch (e) {
        print('⚠️ [MembershipSubscriptionService] Could not fetch payment methods: $e');
      }
      
      // 3. Llamar Edge Function para crear suscripción
      final response = await SupaFlow.client.functions.invoke(
        'stripe-payment',
        body: {
          'action': 'create_subscription',
          'customerId': customerId,
          'priceId': priceId,
          'userId': currentUser.id,
          'membershipType': membershipType,
          if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
        },
      );
      
      print('✅ [MembershipSubscriptionService] Response: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Empty response from server');
      }
      
      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Failed to create subscription');
      }
      
      return data;
    } catch (e) {
      print('❌ [MembershipSubscriptionService] Error: $e');
      rethrow;
    }
  }
  
  /// 2. CANCELAR SUSCRIPCIÓN
  /// Cancela una suscripción existente (al final del período o inmediatamente)
  static Future<Map<String, dynamic>> cancelSubscription({
    required String subscriptionId,
    bool cancelAtPeriodEnd = true,
  }) async {
    print('🚫 [MembershipSubscriptionService] Canceling subscription: $subscriptionId');
    
    try {
      final response = await SupaFlow.client.functions.invoke(
        'stripe-payment',
        body: {
          'action': 'cancel_subscription',
          'subscriptionId': subscriptionId,
          'cancelAtPeriodEnd': cancelAtPeriodEnd,
        },
      );
      
      print('✅ [MembershipSubscriptionService] Cancelled: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Empty response from server');
      }
      
      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Failed to cancel subscription');
      }
      
      return data;
    } catch (e) {
      print('❌ [MembershipSubscriptionService] Error: $e');
      rethrow;
    }
  }
  
  /// 3. ACTUALIZAR SUSCRIPCIÓN (UPGRADE/DOWNGRADE)
  /// Cambia el precio de una suscripción existente
  static Future<Map<String, dynamic>> updateSubscription({
    required String subscriptionId,
    required String newPriceId,
    required String newMembershipType,
    bool prorate = true,
  }) async {
    print('🔄 [MembershipSubscriptionService] Updating subscription: $subscriptionId to $newPriceId ($newMembershipType)');
    
    final currentUser = SupaFlow.client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      final response = await SupaFlow.client.functions.invoke(
        'stripe-payment',
        body: {
          'action': 'update_subscription',
          'subscriptionId': subscriptionId,
          'newPriceId': newPriceId,
          'prorate': prorate,
          'userId': currentUser.id,
          'newMembershipType': newMembershipType,
        },
      );
      
      print('✅ [MembershipSubscriptionService] Updated: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Empty response from server');
      }
      
      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Failed to update subscription');
      }
      
      return data;
    } catch (e) {
      print('❌ [MembershipSubscriptionService] Error: $e');
      rethrow;
    }
  }
  
  /// 4. OBTENER INFORMACIÓN DE SUSCRIPCIÓN
  /// Obtiene los detalles de una suscripción existente
  static Future<Map<String, dynamic>> getSubscription({
    required String subscriptionId,
  }) async {
    print('📋 [MembershipSubscriptionService] Getting subscription: $subscriptionId');
    
    try {
      final response = await SupaFlow.client.functions.invoke(
        'stripe-payment',
        body: {
          'action': 'get_subscription',
          'subscriptionId': subscriptionId,
        },
      );
      
      print('✅ [MembershipSubscriptionService] Retrieved: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Empty response from server');
      }
      
      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Failed to get subscription');
      }
      
      return data;
    } catch (e) {
      print('❌ [MembershipSubscriptionService] Error: $e');
      rethrow;
    }
  }
  
  /// HELPER: Obtener Price ID según tipo de membresía (automático test/live)
  static String getPriceId(String membershipType) {
    return StripeConfig.getPriceId(membershipType);
  }
  
  /// HELPER: Obtener precio según tipo de membresía
  static double getPrice(String membershipType) {
    return StripeConfig.getPrice(membershipType);
  }
}


