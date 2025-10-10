# 🎯 CONFIGURACIÓN DE PRICE IDs - TEST Y LIVE

## 📋 **PASO 1: CREAR PRODUCTOS EN STRIPE (TEST MODE)**

### **1.1. Ir a Stripe Dashboard Test Mode**
```
https://dashboard.stripe.com/test/products
```

### **1.2. Crear 3 productos TEST:**
- **Basic:** `LandGo Basic Membership` - $29/mes
- **Premium:** `LandGo Premium Membership` - $49/mes  
- **VIP:** `LandGo VIP Membership` - $79/mes

### **1.3. Copiar Price IDs TEST:**
```
Basic:   price_1ABC123test...
Premium: price_1DEF456test...
VIP:     price_1GHI789test...
```

---

## 📋 **PASO 2: CREAR PRODUCTOS EN STRIPE (LIVE MODE)**

### **2.1. Cambiar a Live Mode**
- En Stripe Dashboard, cambiar de **"Test data"** a **"Live data"**

### **2.2. Crear 3 productos LIVE (mismos nombres y precios):**
- **Basic:** `LandGo Basic Membership` - $29/mes
- **Premium:** `LandGo Premium Membership` - $49/mes  
- **VIP:** `LandGo VIP Membership` - $79/mes

### **2.3. Copiar Price IDs LIVE:**
```
Basic:   price_1XYZ123live...
Premium: price_1UVW456live...
VIP:     price_1RST789live...
```

---

## 🔧 **PASO 3: ACTUALIZAR CÓDIGO**

Una vez que tengas **TODOS LOS 6 PRICE IDs**, dímelos así:

```
=== TEST MODE PRICE IDs ===
Basic:   price_1ABC123test...
Premium: price_1DEF456test...
VIP:     price_1GHI789test...

=== LIVE MODE PRICE IDs ===
Basic:   price_1XYZ123live...
Premium: price_1UVW456live...
VIP:     price_1RST789live...
```

Y yo actualizaré automáticamente el archivo `lib/config/stripe_config.dart`

---

## ✅ **VENTAJAS DEL SISTEMA:**

1. **🔄 Automático:** Detecta si estás en test o live mode
2. **🛡️ Seguro:** No hay que cambiar código al publicar
3. **📱 Fácil:** Solo actualizar Price IDs una vez
4. **🧪 Testing:** Puedes probar en test mode sin problemas

---

## ⚠️ **IMPORTANTE:**

- **TEST MODE:** Usa tarjetas de prueba (4242 4242 4242 4242)
- **LIVE MODE:** Usa tarjetas reales y cobra dinero real
- **NUNCA** mezcles Price IDs de test con claves live

---

## 🎯 **RESULTADO FINAL:**

Una vez configurado, la app automáticamente:
- Usa Price IDs de test cuando desarrollas
- Usa Price IDs de live cuando publicas
- Sin cambios de código necesarios

---

**¿Listo para crear los productos en Stripe Dashboard?**
