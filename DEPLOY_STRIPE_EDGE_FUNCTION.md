# 🚀 Desplegar Edge Function de Stripe - SOLUCIÓN COMPLETA

## 📋 **Cambios Realizados**

### ✅ **Problema Resuelto:**
- **Antes:** Enviaba números de tarjeta directamente → Stripe lo bloqueaba por seguridad
- **Ahora:** Usa **Tokens** primero, luego crea **PaymentMethod** → Método seguro y aprobado por Stripe

### 🔧 **Funcionalidades Agregadas:**
1. ✅ `create_customer` - Crear clientes
2. ✅ `create_payment_method` - Crear método de pago (CON TOKENS)
3. ✅ `attach_payment_method` - Asociar tarjeta a cliente
4. ✅ `create_payment_intent` - Crear intención de pago
5. ✅ `confirm_payment` - Confirmar pago

---

## 🎯 **Cómo Desplegar en Supabase Dashboard**

### **Paso 1: Abrir el Editor**
1. Ve a tu **Dashboard de Supabase**
2. En el menú lateral, haz clic en **Edge Functions**
3. Busca la función `stripe-payment`
4. Haz clic en **"Edit"** o **"Deploy new version"**

### **Paso 2: Copiar el Código Actualizado**
1. Abre el archivo local: `supabase/functions/stripe-payment/index.ts`
2. **Copia TODO el contenido** del archivo
3. **Pega** en el editor del dashboard de Supabase
4. Haz clic en **"Deploy"**

### **Paso 3: Verificar Variables de Entorno**
Asegúrate de que la variable `STRIPE_SECRET_KEY` esté configurada:
1. Ve a **Edge Functions** → `stripe-payment` → **Settings**
2. En **Environment Variables**, verifica que exista:
   - **Name:** `STRIPE_SECRET_KEY`
   - **Value:** `YOUR_STRIPE_SECRET_KEY_HERE`

---

## 🧪 **Códigos de Prueba Actualizados**

### ✅ **Test 1: Crear Customer**
```json
{
  "action": "create_customer",
  "email": "test@landgotravel.com",
  "name": "Test User LandGo"
}
```
**Resultado esperado:** `"success": true` con `customer.id`

---

### ✅ **Test 2: Crear PaymentMethod (USANDO TEST TOKEN)**

**OPCIÓN A: Usando Test Token de Stripe (RECOMENDADO)**
```json
{
  "action": "create_payment_method",
  "testToken": "tok_visa",
  "cardholderName": "Test User LandGo"
}
```

**OPCIÓN B: Usando Test Token de Mastercard**
```json
{
  "action": "create_payment_method",
  "testToken": "tok_mastercard",
  "cardholderName": "Test User LandGo"
}
```

**OPCIÓN C: Usando Test Token de Amex**
```json
{
  "action": "create_payment_method",
  "testToken": "tok_amex",
  "cardholderName": "Test User LandGo"
}
```

**Resultado esperado:** `"success": true` con `paymentMethod.id`

**⚠️ IMPORTANTE:** Guarda el `paymentMethod.id` (ej: `pm_1234567890`) para el siguiente test.

---

### 📋 **Tokens de Prueba de Stripe**

| Token | Tipo de Tarjeta | Resultado |
|-------|-----------------|-----------|
| `tok_visa` | Visa | ✅ Aprobado |
| `tok_visa_debit` | Visa Debit | ✅ Aprobado |
| `tok_mastercard` | Mastercard | ✅ Aprobado |
| `tok_mastercard_debit` | Mastercard Debit | ✅ Aprobado |
| `tok_amex` | American Express | ✅ Aprobado |
| `tok_discover` | Discover | ✅ Aprobado |
| `tok_chargeDeclined` | - | ❌ Declinado |
| `tok_chargeDeclinedInsufficientFunds` | - | ❌ Fondos insuficientes |

---

### ✅ **Test 3: Asociar PaymentMethod a Customer**
```json
{
  "action": "attach_payment_method",
  "customerId": "cus_T9PfRkJfretNXq",
  "paymentMethodId": "pm_XXXXXXXXXXXXXXX"
}
```
**Nota:** Reemplaza `customerId` y `paymentMethodId` con los IDs reales de los tests anteriores.

---

### ✅ **Test 4: Crear PaymentIntent**
```json
{
  "action": "create_payment_intent",
  "amount": 100.00,
  "currency": "usd",
  "customerId": "cus_T9PfRkJfretNXq",
  "paymentMethodId": "pm_XXXXXXXXXXXXXXX"
}
```

---

## 🎨 **Tarjetas de Prueba de Stripe**

| Tarjeta | Número | CVV | Exp | Resultado |
|---------|--------|-----|-----|-----------|
| **Visa Éxito** | `4242424242424242` | `123` | `12/25` | ✅ Aprobado |
| **Visa Declinada** | `4000000000000002` | `123` | `12/25` | ❌ Rechazado |
| **Mastercard** | `5555555555554444` | `123` | `12/25` | ✅ Aprobado |
| **Amex** | `378282246310005` | `1234` | `12/25` | ✅ Aprobado |

---

## 📊 **Flujo Completo de Prueba**

1. **Crear Customer** → Obtienes `cus_XXXXX`
2. **Crear PaymentMethod** → Obtienes `pm_XXXXX`
3. **Asociar PaymentMethod** → Vinculas `pm_XXXXX` a `cus_XXXXX`
4. **Crear PaymentIntent** → Procesas el pago de \$100 USD

---

## ✅ **Verificación de Éxito**

Después de cada test, verifica:
- ✅ **Respuesta:** `"success": true`
- ✅ **Dashboard de Stripe:** Ve a [Stripe Dashboard](https://dashboard.stripe.com/test/customers) y verifica:
  - Customers creados
  - PaymentMethods guardados
  - PaymentIntents procesados

---

## 🚨 **Solución de Problemas**

### **Error: "Sending credit card numbers directly..."**
✅ **Solucionado:** La nueva versión usa tokens, este error ya no debería aparecer.

### **Error: "Unknown action: attach_payment_method"**
✅ **Solucionado:** La acción ya fue agregada al switch.

### **Error: "No such PaymentMethod"**
⚠️ **Causa:** Estás usando `pm_XXXXXXXXXXXXX` (placeholder) en lugar de un ID real.
📝 **Solución:** Usa el `paymentMethod.id` real que obtienes del Test 2.

---

## 📞 **¿Necesitas Ayuda?**

Si encuentras errores después de desplegar:
1. Revisa los **Logs** en Supabase Edge Functions
2. Verifica que `STRIPE_SECRET_KEY` esté configurada
3. Asegúrate de estar usando **IDs reales**, no placeholders

---

## 🎯 **Próximos Pasos**

Después de verificar que la Edge Function funciona:
1. ✅ Compilar la app Flutter con los cambios
2. ✅ Probar agregar tarjetas reales desde la app
3. ✅ Verificar que los pagos se procesen correctamente
4. ✅ Revisar el dashboard de Stripe para confirmar transacciones

---

**🚀 ¡Listo para desplegar!**
