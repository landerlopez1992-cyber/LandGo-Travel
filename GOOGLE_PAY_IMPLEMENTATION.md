# 💳 GOOGLE PAY IMPLEMENTATION - LANDGO TRAVEL

## 📋 **PLAN DE IMPLEMENTACIÓN**

### **FASE 1: CONFIGURACIÓN ANDROID (2-3 horas)**

#### 1.1 Dependencies
- [ ] Agregar `pay` package (Google Pay oficial)
- [ ] Agregar configuración en pubspec.yaml
- [ ] Verificar versión de Stripe compatible con Google Pay

#### 1.2 Android Configuration
- [ ] Actualizar `android/app/src/main/AndroidManifest.xml`
- [ ] Agregar Google Pay metadata
- [ ] Configurar permisos necesarios
- [ ] Actualizar `build.gradle` si es necesario

#### 1.3 Stripe Configuration
- [ ] Verificar que Stripe Dashboard tiene Google Pay habilitado
- [ ] Configurar merchant ID
- [ ] Configurar payment gateway tokenization

---

### **FASE 2: INTEGRACIÓN FLUTTER (3-4 horas)**

#### 2.1 Payment Button Widget
- [ ] Crear `GooglePayButton` widget
- [ ] Configurar payment configuration
- [ ] Definir payment data request
- [ ] Implementar onPaymentResult callback

#### 2.2 Payment Flow Integration
- [ ] Integrar en `ReviewSummaryPage`
- [ ] Manejar cuando se selecciona Google Pay
- [ ] Crear PaymentMethod con token de Google Pay
- [ ] Procesar pago igual que Credit/Debit Card

#### 2.3 Error Handling
- [ ] Manejar errores de Google Pay API
- [ ] Manejar cancelación del usuario
- [ ] Manejar dispositivos sin Google Pay
- [ ] Mostrar mensajes apropiados

---

### **FASE 3: BACKEND (2-3 horas)**

#### 3.1 Edge Function Updates
- [ ] Actualizar `stripe-payment` function
- [ ] Agregar soporte para Google Pay tokens
- [ ] Manejar payment_method tipo 'card' de Google Pay
- [ ] Logging y debugging

#### 3.2 Database
- [ ] Actualizar tabla `payments` si es necesario
- [ ] Agregar `payment_method = 'google_pay'`
- [ ] Registrar transacciones correctamente

---

### **FASE 4: TESTING (2-3 horas)**

#### 4.1 Development Testing
- [ ] Probar con Google Pay test cards
- [ ] Verificar flujo completo
- [ ] Verificar balance update
- [ ] Verificar transacciones en DB

#### 4.2 Real Device Testing
- [ ] Probar en dispositivo Android real
- [ ] Agregar tarjeta real a Google Pay
- [ ] Hacer transacción de prueba
- [ ] Verificar todo funciona

#### 4.3 Edge Cases
- [ ] Probar sin Google Pay instalado
- [ ] Probar sin tarjetas en Google Pay
- [ ] Probar cancelación
- [ ] Probar errores de red

---

## 🔧 **CONFIGURACIÓN TÉCNICA**

### **1. Dependencies (pubspec.yaml)**

```yaml
dependencies:
  flutter_stripe: ^11.3.0  # Ya instalado
  pay: ^2.0.0  # NUEVO - Google Pay oficial
```

### **2. Android Manifest**

```xml
<manifest>
  <application>
    <!-- Google Pay -->
    <meta-data
      android:name="com.google.android.gms.wallet.api.enabled"
      android:value="true" />
  </application>
</manifest>
```

### **3. Payment Configuration (JSON)**

```json
{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "stripe",
            "stripe:version": "2018-10-31",
            "stripe:publishableKey": "pk_test_..."
          }
        },
        "parameters": {
          "allowedCardNetworks": ["VISA", "MASTERCARD", "AMEX"],
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "billingAddressRequired": true
        }
      }
    ],
    "merchantInfo": {
      "merchantName": "LandGo Travel"
    },
    "transactionInfo": {
      "totalPriceStatus": "FINAL",
      "totalPrice": "10.30",
      "currencyCode": "USD",
      "countryCode": "US"
    }
  }
}
```

---

## 📱 **FLUJO DE PAGO GOOGLE PAY**

```
1. User selecciona Google Pay en Review Summary
   ↓
2. Se muestra botón Google Pay
   ↓
3. User toca botón → Abre sheet de Google Pay
   ↓
4. User selecciona tarjeta y confirma
   ↓
5. Google Pay retorna payment token
   ↓
6. Flutter crea PaymentMethod con token
   ↓
7. Edge Function procesa pago con Stripe
   ↓
8. Balance se actualiza
   ↓
9. Se registra transacción en DB
   ↓
10. Se muestra Payment Success
```

---

## 🎯 **CRITERIOS DE ÉXITO**

### **Funcionalidad**
- [ ] ✅ Google Pay se muestra solo en Android
- [ ] ✅ Botón Google Pay aparece correctamente
- [ ] ✅ Sheet de Google Pay abre correctamente
- [ ] ✅ Pago se procesa exitosamente
- [ ] ✅ Balance se actualiza correctamente
- [ ] ✅ Transacción se registra en DB

### **UX**
- [ ] ✅ Flujo intuitivo y rápido
- [ ] ✅ Errores se manejan apropiadamente
- [ ] ✅ Loading states claros
- [ ] ✅ Feedback visual apropiado

### **Seguridad**
- [ ] ✅ Tokens se manejan correctamente
- [ ] ✅ No se exponen datos sensibles
- [ ] ✅ Billing address se valida

---

## 🔍 **TESTING CHECKLIST**

### **Test 1: Configuración Básica**
- [ ] Package instalado correctamente
- [ ] Android manifest configurado
- [ ] Google Pay disponible en dispositivo
- [ ] Botón se muestra correctamente

### **Test 2: Flujo de Pago**
- [ ] Botón abre sheet de Google Pay
- [ ] Tarjetas disponibles se muestran
- [ ] Pago se procesa
- [ ] Success screen se muestra

### **Test 3: Balance y DB**
- [ ] Balance se actualiza correctamente
- [ ] No hay duplicación
- [ ] Transacción en payments table
- [ ] payment_method = 'google_pay'

### **Test 4: Error Handling**
- [ ] Cancelación manejada
- [ ] Errores de red manejados
- [ ] Sin Google Pay manejado
- [ ] Sin tarjetas manejado

---

## 📝 **NOTAS IMPORTANTES**

### **Google Pay Test Cards**
Para testing, usar tarjetas de prueba de Stripe:
- **Visa:** 4242424242424242
- **Mastercard:** 5555555555554444
- **Amex:** 378282246310005

### **Environment**
- **TEST:** Para desarrollo (usar pk_test_ y sk_test_)
- **PRODUCTION:** Para live (usar pk_live_ y sk_live_)

### **Stripe Dashboard**
Verificar que Google Pay esté habilitado en:
Settings → Payment Methods → Digital Wallets → Google Pay

---

## 🚀 **PRÓXIMOS PASOS**

1. **AHORA:** Instalar dependencies
2. **LUEGO:** Configurar Android
3. **DESPUÉS:** Implementar payment button
4. **FINALMENTE:** Testing completo

---

**ESTIMACIÓN TOTAL:** 8-12 horas
**PRIORIDAD:** Alta (Android only)
**DEPENDENCIAS:** flutter_stripe (ya instalado)

**FECHA INICIO:** 2025-01-30
**ESTADO:** 🔄 EN PROGRESO
