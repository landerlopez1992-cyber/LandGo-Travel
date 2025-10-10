# 🎯 PLAN COMPLETO: STRIPE SUBSCRIPTIONS + MEMBERSHIP UPGRADES

## 📊 ESTADO ACTUAL DEL SISTEMA

### ✅ **LO QUE YA EXISTE:**

1. **📁 Base de Datos Supabase:**
   - ✅ Tabla `memberships` con todos los campos necesarios
   - ✅ Funciones SQL implementadas:
     - `create_default_membership()` - Crear Free por defecto
     - `calculate_prorated_upgrade()` - Calcular upgrade prorrateado
     - `validate_membership_downgrade()` - Validar cancelación
     - `get_membership_cancellation_info()` - Info de cancelación
     - `schedule_membership_cancellation()` - Programar cancelación
     - `cancel_membership_immediate()` - Cancelación inmediata con penalty
   - ✅ Triggers automáticos
   - ✅ RLS (Row Level Security)
   - ✅ Tabla `membership_cashback_holds` para retener cashback

2. **📱 Pantallas Flutter:**
   - ✅ `MembershipsPageWidget` - Pantalla principal con 4 planes
   - ✅ `MembershipDetailPageWidget` - Detalles de cada plan
   - ✅ Botón "Upgrade" en cada detalle
   - ✅ Botón "Cancel Membership" en Profile

3. **🛡️ Protecciones Anti-Abuso:**
   - ✅ Compromiso mínimo 6 meses
   - ✅ Penalty por cancelación temprana
   - ✅ 120 días de espera para reactivar
   - ✅ Downgrade = Cancelación (misma penalty)
   - ✅ Cashback retenido hasta completar viaje

### ❌ **LO QUE FALTA:**

1. **💳 Stripe Subscriptions Integration:**
   - Crear productos en Stripe Dashboard
   - Crear precios (prices) para cada plan
   - Actualizar Edge Function con subscription logic
   - Webhooks para eventos de Stripe

2. **📱 Flujo de Upgrade en Flutter:**
   - Conectar botón "Upgrade" → Stripe Payment
   - Procesar pago con tarjeta guardada o nueva
   - Actualizar membresía en Supabase tras pago exitoso
   - Manejo de errores profesional

3. **🔄 Flujo de Renovación Automática:**
   - Webhook `invoice.paid` para renovaciones
   - Incrementar `months_completed`
   - Actualizar `next_billing_date`

---

## 🔧 IMPLEMENTACIÓN PASO A PASO

### **FASE 1: STRIPE DASHBOARD SETUP** ⏱️ 5 minutos

#### 1.1. Crear Productos en Stripe Dashboard

```
https://dashboard.stripe.com/test/products
```

**Productos a crear:**

| Producto | Nombre | Precio | Price ID (guardar) |
|----------|--------|--------|-------------------|
| Basic | LandGo Basic Membership | $29.00/mes | price_xxx_basic |
| Premium | LandGo Premium Membership | $49.00/mes | price_xxx_premium |
| VIP | LandGo VIP Membership | $79.00/mes | price_xxx_vip |

**IMPORTANTE:** 
- Marcar como "Recurring" (mensual)
- Guardar cada `price_id` para usarlo en código

---

### **FASE 2: EDGE FUNCTION UPDATE** ⏱️ 15 minutos

#### 2.1. Agregar nuevas acciones a `stripe-payment/index.ts`

**Nuevas funciones a implementar:**

```typescript
// 1. create_subscription - Crear suscripción mensual
case 'create_subscription':
  return await createSubscription(data);

// 2. cancel_subscription - Cancelar suscripción
case 'cancel_subscription':
  return await cancelSubscription(data);

// 3. update_subscription - Upgrade/Downgrade
case 'update_subscription':
  return await updateSubscription(data);

// 4. get_subscription - Obtener info de suscripción
case 'get_subscription':
  return await getSubscription(data);
```

**Lógica de `createSubscription()`:**

```typescript
async function createSubscription(data) {
  const { customerId, priceId, userId, membershipType } = data;
  
  // 1. Crear suscripción en Stripe
  const subscription = await stripe.subscriptions.create({
    customer: customerId,
    items: [{ price: priceId }],
    metadata: {
      user_id: userId,
      membership_type: membershipType
    },
    payment_behavior: 'default_incomplete',
    payment_settings: { save_default_payment_method: 'on_subscription' },
    expand: ['latest_invoice.payment_intent']
  });
  
  // 2. Actualizar membresía en Supabase
  await supabaseAdmin
    .from('memberships')
    .update({
      membership_type: membershipType,
      stripe_subscription_id: subscription.id,
      stripe_price_id: priceId,
      status: 'active',
      current_period_start: new Date(subscription.current_period_start * 1000),
      current_period_end: new Date(subscription.current_period_end * 1000),
      next_billing_date: new Date(subscription.current_period_end * 1000)
    })
    .eq('user_id', userId);
  
  return { success: true, subscription };
}
```

---

### **FASE 3: FLUTTER SERVICE** ⏱️ 10 minutos

#### 3.1. Crear `MembershipSubscriptionService`

**Archivo:** `lib/services/membership_subscription_service.dart`

```dart
class MembershipSubscriptionService {
  // 1. Crear suscripción
  static Future<Map<String, dynamic>> createSubscription({
    required String membershipType,
    required String priceId,
  }) async {
    final currentUser = SupaFlow.client.auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');
    
    // Obtener Stripe Customer ID
    final profile = await SupaFlow.client
        .from('profiles')
        .select('stripe_customer_id')
        .eq('id', currentUser.id)
        .single();
    
    final customerId = profile['stripe_customer_id'];
    
    // Llamar Edge Function
    final response = await SupaFlow.client.functions.invoke(
      'stripe-payment',
      body: {
        'action': 'create_subscription',
        'customerId': customerId,
        'priceId': priceId,
        'userId': currentUser.id,
        'membershipType': membershipType,
      },
    );
    
    return response.data;
  }
  
  // 2. Cancelar suscripción
  static Future<Map<String, dynamic>> cancelSubscription() async {
    // Similar logic...
  }
}
```

---

### **FASE 4: CONECTAR BOTÓN UPGRADE** ⏱️ 10 minutos

#### 4.1. Actualizar `MembershipDetailPageWidget`

**Modificar función `_showUpgradeDialog()`:**

```dart
Future<void> _proceedToPayment() async {
  if (!termsAccepted) {
    _showMessage('Please accept terms and conditions');
    return;
  }
  
  Navigator.pop(context); // Cerrar diálogo
  
  // Mostrar loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DD0E1)),
      ),
    ),
  );
  
  try {
    // Determinar priceId según membershipType
    final priceId = _getPriceId(widget.membershipType);
    
    // Crear suscripción
    final result = await MembershipSubscriptionService.createSubscription(
      membershipType: widget.membershipType,
      priceId: priceId,
    );
    
    // Cerrar loading
    if (context.mounted) Navigator.pop(context);
    
    if (result['success'] == true) {
      final subscription = result['subscription'];
      final paymentIntent = subscription['latest_invoice']['payment_intent'];
      
      if (paymentIntent['status'] == 'requires_payment_method') {
        // Abrir pantalla de pago
        if (context.mounted) {
          context.pushNamed(
            'PaymentCardsPage',
            queryParameters: {
              'subscriptionId': subscription['id'],
              'amount': widget.monthlyPrice.toString(),
              'membershipType': widget.membershipType,
            },
          );
        }
      } else if (paymentIntent['status'] == 'succeeded') {
        // Pago exitoso
        _showSuccessDialog();
      }
    } else {
      throw Exception(result['error'] ?? 'Unknown error');
    }
  } catch (e) {
    if (context.mounted) Navigator.pop(context);
    _showMessage('Error processing payment: ${e.toString()}');
  }
}

String _getPriceId(String membershipType) {
  switch (membershipType) {
    case 'Basic':
      return 'price_xxx_basic'; // TODO: Reemplazar con real Price ID
    case 'Premium':
      return 'price_xxx_premium'; // TODO: Reemplazar con real Price ID
    case 'VIP':
      return 'price_xxx_vip'; // TODO: Reemplazar con real Price ID
    default:
      throw Exception('Invalid membership type');
  }
}
```

---

### **FASE 5: WEBHOOKS STRIPE** ⏱️ 10 minutos

#### 5.1. Crear Edge Function `stripe-webhooks`

**Archivo:** `supabase/functions/stripe-webhooks/index.ts`

```typescript
import Stripe from 'stripe';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!);

serve(async (req) => {
  const signature = req.headers.get('stripe-signature')!;
  const body = await req.text();
  
  let event;
  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      Deno.env.get('STRIPE_WEBHOOK_SECRET')!
    );
  } catch (err) {
    return json({ error: 'Webhook signature verification failed' }, { status: 400 });
  }
  
  switch (event.type) {
    case 'invoice.paid':
      // Renovación exitosa
      await handleInvoicePaid(event.data.object);
      break;
      
    case 'invoice.payment_failed':
      // Pago fallido
      await handlePaymentFailed(event.data.object);
      break;
      
    case 'customer.subscription.deleted':
      // Suscripción cancelada
      await handleSubscriptionDeleted(event.data.object);
      break;
  }
  
  return json({ received: true });
});

async function handleInvoicePaid(invoice: Stripe.Invoice) {
  const subscriptionId = invoice.subscription as string;
  
  // Incrementar months_completed
  await supabaseAdmin
    .from('memberships')
    .update({
      months_completed: sql`months_completed + 1`,
      next_billing_date: new Date(invoice.period_end * 1000),
      updated_at: new Date()
    })
    .eq('stripe_subscription_id', subscriptionId);
}
```

---

## 📋 CHECKLIST DE IMPLEMENTACIÓN

### **ANTES DE EMPEZAR:**
- [ ] Revisar que todas las funciones SQL están desplegadas en Supabase
- [ ] Verificar que existe la tabla `memberships`
- [ ] Confirmar que usuario actual tiene membresía "Free"

### **STRIPE SETUP:**
- [ ] Crear producto "Basic" ($29/mes)
- [ ] Crear producto "Premium" ($49/mes)
- [ ] Crear producto "VIP" ($79/mes)
- [ ] Guardar cada `price_id` en archivo de configuración
- [ ] Configurar webhook endpoint en Stripe Dashboard

### **BACKEND:**
- [ ] Actualizar Edge Function `stripe-payment` con subscription logic
- [ ] Crear Edge Function `stripe-webhooks`
- [ ] Desplegar ambas funciones en Supabase
- [ ] Probar con Stripe CLI (`stripe listen --forward-to`)

### **FRONTEND:**
- [ ] Crear `MembershipSubscriptionService`
- [ ] Actualizar `MembershipDetailPageWidget._proceedToPayment()`
- [ ] Agregar `_getPriceId()` con Price IDs reales
- [ ] Conectar `PaymentCardsPage` con subscriptions
- [ ] Manejo de errores profesional

### **TESTING:**
- [ ] Upgrade de Free → Basic (tarjeta test 4242 4242 4242 4242)
- [ ] Verificar que membresía se actualiza en DB
- [ ] Verificar que `stripe_subscription_id` se guarda
- [ ] Probar Cancel Membership (debe mostrar penalty)
- [ ] Probar Schedule Cancellation

---

## ⚠️ PUNTOS CRÍTICOS A CONSIDERAR

### 1. **Price IDs Hardcoded**
- Actualmente los Price IDs están hardcoded en el código
- **Solución:** Crear tabla `membership_config` en Supabase con Price IDs

### 2. **Webhook Signing Secret**
- Necesario para verificar webhooks
- **Obtener:** Stripe Dashboard → Developers → Webhooks → Signing secret

### 3. **Prorated Upgrades**
- Si usuario tiene Basic ($29) y upgrade a Premium ($49) a mitad de mes
- **Solución:** Usar `calculate_prorated_upgrade()` función SQL existente

### 4. **Downgrade Protection**
- Usuario con 2 meses completados no puede bajar sin penalty
- **Garantizado:** Función `validate_membership_downgrade()` ya implementada

### 5. **Payment Failure Handling**
- ¿Qué pasa si falla renovación mensual?
- **Solución:** Webhook `invoice.payment_failed` → Status = 'suspended'

---

## 🎯 RESULTADO FINAL ESPERADO

### **Flujo Completo:**

```
1. Usuario en Memberships → Toca "Basic"
2. Membership Detail → "Upgrade" → Terms Dialog
3. Acepta términos → Loading
4. Stripe crea subscription (status: incomplete)
5. Navega a Payment Cards → Selecciona tarjeta
6. Stripe procesa pago → Subscription status: active
7. Edge Function actualiza memberships table
8. Usuario ve "Payment Success" → Navega a My Profile
9. My Profile muestra "Basic Member"
10. Profile → Cancel Membership → Diálogo con penalty info
```

---

## ⏱️ TIEMPO TOTAL ESTIMADO: 50-60 minutos

1. **Stripe Dashboard Setup:** 5 min
2. **Edge Function Update:** 15 min
3. **Flutter Service:** 10 min
4. **Connect Upgrade Button:** 10 min
5. **Webhooks:** 10 min
6. **Testing:** 10 min

---

## 🚀 ¿LISTO PARA EMPEZAR?

**Confirma que entiendes el plan completo y empezamos con FASE 1.**

Si hay algo que no esté claro, pregunta AHORA antes de empezar a implementar.

