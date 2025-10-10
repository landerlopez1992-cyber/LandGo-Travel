# 🚀 INSTRUCCIONES PARA DESPLEGAR EDGE FUNCTION

## ✅ **PASO 1: Edge Function Actualizada**

La Edge Function `stripe-payment` ya tiene las 4 nuevas funciones de Stripe Subscriptions:

1. ✅ `create_subscription` - Crear suscripción mensual
2. ✅ `cancel_subscription` - Cancelar suscripción
3. ✅ `update_subscription` - Upgrade/Downgrade
4. ✅ `get_subscription` - Obtener información

---

## 📋 **PASO 2: DESPLEGAR EN SUPABASE**

### **Opción A: Desde Supabase Dashboard (Recomendado)**

1. **Ir a Supabase Dashboard:**
   ```
   https://supabase.com/dashboard/project/[TU_PROJECT_ID]/functions
   ```

2. **Seleccionar la función `stripe-payment`**

3. **Copiar TODO el contenido de:**
   ```
   supabase/functions/stripe-payment/index.ts
   ```

4. **Pegar en el editor de Supabase**

5. **Click en "Deploy"**

6. **Esperar confirmación** ✅

---

### **Opción B: Desde Terminal (Si tienes Supabase CLI)**

```bash
# 1. Login a Supabase (si no estás logueado)
supabase login

# 2. Link al proyecto
supabase link --project-ref [TU_PROJECT_ID]

# 3. Desplegar función
supabase functions deploy stripe-payment

# 4. Verificar
supabase functions list
```

---

## ⚠️ **IMPORTANTE: NO BORRAR FUNCIONES EXISTENTES**

La Edge Function ya tiene:
- ✅ Crear/attach payment methods
- ✅ Crear payment intents
- ✅ Klarna, Afterpay, Affirm, Zip
- ✅ **NUEVO:** Stripe Subscriptions

**NO ELIMINES NADA**, solo agregamos las nuevas funciones de subscriptions.

---

## 🧪 **PASO 3: VERIFICAR QUE FUNCIONA**

Después de desplegar, voy a crear un test en Flutter para verificar que las nuevas funciones responden correctamente.

---

## 📝 **NOTA:**

Este archivo es solo una guía. Las funciones ya están en el código.

**Estado actual:** ✅ Código listo, pendiente despliegue en Supabase

