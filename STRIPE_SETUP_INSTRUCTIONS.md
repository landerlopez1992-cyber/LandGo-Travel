# 🚀 CONFIGURACIÓN DE STRIPE SANDBOX - LANDGO TRAVEL

## 📋 PASOS PARA CONFIGURAR STRIPE

### **1. Obtener Credenciales de Stripe Sandbox**

1. **Ir a Stripe Dashboard**: https://dashboard.stripe.com/test/apikeys
2. **Copiar las claves de prueba**:
   - **Publishable key**: `pk_test_...`
   - **Secret key**: `sk_test_...`

### **2. Configurar Credenciales en la App**

Editar `lib/services/stripe_service.dart`:

```dart
// CREDENCIALES DE STRIPE SANDBOX (PRUEBAS) - REEMPLAZAR CON LAS TUYAS
static const String _publishableKey = 'pk_test_TU_PUBLISHABLE_KEY_AQUI';
static const String _secretKey = 'sk_test_TU_SECRET_KEY_AQUI';
```

### **3. Crear Supabase Edge Function para PaymentIntent**

1. **Ir a Supabase Dashboard**: https://supabase.com/dashboard/project/dumgmnibxhfchjyowvbz
2. **Navegar a**: Edge Functions
3. **Crear nueva función**: `create-payment-intent`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@14.21.0'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') || '', {
      apiVersion: '2023-10-16',
    })

    const { amount, currency, customer, payment_method } = await req.json()

    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convertir a centavos
      currency: currency || 'usd',
      customer: customer,
      payment_method: payment_method,
      confirmation_method: 'manual',
      confirm: true,
      return_url: 'https://your-app.com/return',
    })

    return new Response(
      JSON.stringify({ 
        id: paymentIntent.id, 
        status: paymentIntent.status,
        client_secret: paymentIntent.client_secret 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400 
      }
    )
  }
})
```

### **4. Configurar Variables de Entorno en Supabase**

1. **Ir a**: Settings → Edge Functions
2. **Agregar variable**:
   - **Name**: `STRIPE_SECRET_KEY`
   - **Value**: `sk_test_TU_SECRET_KEY_AQUI`

### **5. Tarjetas de Prueba de Stripe**

Usar estas tarjetas para testing:

- **Visa**: `4242 4242 4242 4242`
- **Visa (debit)**: `4000 0566 5566 5556`
- **Mastercard**: `5555 5555 5555 4444`
- **American Express**: `3782 822463 10005`
- **Declined**: `4000 0000 0000 0002`
- **Insufficient funds**: `4000 0000 0000 9995`

**CVV**: Cualquier 3-4 dígitos
**Fecha**: Cualquier fecha futura

### **6. Para Cambiar a LIVE (Producción)**

Solo cambiar en `stripe_service.dart`:

```dart
// CAMBIAR DE:
static const String _publishableKey = 'pk_test_...';
static const String _secretKey = 'sk_test_...';

// A:
static const String _publishableKey = 'pk_live_...';
static const String _secretKey = 'sk_live_...';
```

### **7. Testing del Flujo**

1. **Ejecutar la app**: `flutter run`
2. **Navegar a**: My Wallet → Add Money
3. **Agregar cantidad**: $23
4. **Seleccionar tarjeta**: Usar tarjeta de prueba
5. **Confirmar pago**: Debería procesar con Stripe

### **8. Logs de Debug**

Los logs mostrarán:
```
🔍 DEBUG: Processing payment with Stripe
🔍 DEBUG: Amount: 23.0
🔍 DEBUG: Payment method: stripe
🔍 DEBUG: Selected card: card_xxx
```

### **9. Estado Actual**

✅ **Stripe SDK instalado**: `flutter_stripe 12.0.2`
✅ **Servicio creado**: `StripeService`
✅ **Inicialización**: En `main.dart`
✅ **Integración**: En `PaymentCardsPage`
✅ **Modal de procesamiento**: Con Stripe real
✅ **Pantallas de resultado**: Existentes

### **10. Próximos Pasos**

1. **Configurar credenciales** de Stripe
2. **Crear Edge Function** en Supabase
3. **Probar con tarjetas** de prueba
4. **Verificar logs** de procesamiento
5. **Cambiar a LIVE** cuando esté listo

---

**⚠️ IMPORTANTE**: Mantener credenciales de prueba separadas de las de producción. Nunca usar claves live en desarrollo.
