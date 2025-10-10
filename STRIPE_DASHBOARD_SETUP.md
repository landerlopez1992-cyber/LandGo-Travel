# 🎯 PASO CRÍTICO: CREAR PRODUCTOS EN STRIPE DASHBOARD

## ⚠️ **ACCIÓN REQUERIDA POR EL USUARIO:**

Necesitas crear **manualmente** 3 productos en Stripe Dashboard con sus respectivos precios mensuales.

---

## 📋 **INSTRUCCIONES PASO A PASO:**

### **1. IR A STRIPE DASHBOARD**

```
https://dashboard.stripe.com/test/products
```

(Asegúrate de estar en **Test Mode** - esquina superior derecha debe decir "TEST DATA")

---

### **2. CREAR PRODUCTO "BASIC"**

1. Click en **"+ Add product"**
2. **Name:** `LandGo Basic Membership`
3. **Description:** `Basic membership with 3% cashback and referral commissions`
4. **Pricing model:** Recurring
5. **Price:** `$29.00`
6. **Billing period:** Monthly
7. Click **"Save product"**
8. **📋 COPIAR el "Price ID"** (empieza con `price_xxx`)
   - Ejemplo: `price_1AbC2dEfGhIjKlMn`

---

### **3. CREAR PRODUCTO "PREMIUM"**

1. Click en **"+ Add product"**
2. **Name:** `LandGo Premium Membership`
3. **Description:** `Premium membership with 6% cashback and referral commissions`
4. **Pricing model:** Recurring
5. **Price:** `$49.00`
6. **Billing period:** Monthly
7. Click **"Save product"**
8. **📋 COPIAR el "Price ID"**

---

### **4. CREAR PRODUCTO "VIP"**

1. Click en **"+ Add product"**
2. **Name:** `LandGo VIP Membership`
3. **Description:** `VIP membership with 10% cashback and referral commissions`
4. **Pricing model:** Recurring
5. **Price:** `$79.00`
6. **Billing period:** Monthly
7. Click **"Save product"**
8. **📋 COPIAR el "Price ID"**

---

## ✅ **RESULTADO ESPERADO:**

Deberías tener **3 Price IDs** como estos:

```
Basic:   price_1AbC2dEfGhIjKlMn
Premium: price_1XyZ9wVuTsRqPoNm
VIP:     price_1QwE3rTyUiOpAsDf
```

---

## 📝 **PRÓXIMO PASO:**

Una vez que tengas los 3 Price IDs, **dímelos** y yo los integraré en el código automáticamente.

---

## ⏱️ **TIEMPO ESTIMADO:** 5 minutos

No continúes hasta tener los 3 Price IDs.

