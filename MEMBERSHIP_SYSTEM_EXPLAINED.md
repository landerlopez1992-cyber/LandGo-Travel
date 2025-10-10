# 🎯 SISTEMA DE MEMBRESÍAS LANDGO TRAVEL - GUÍA COMPLETA

## 📋 TABLA DE CONTENIDOS
1. [Flujo Completo del Usuario](#flujo-completo-del-usuario)
2. [Timeline de Eventos](#timeline-de-eventos)
3. [Dónde están los botones](#dónde-están-los-botones)
4. [Cuándo empiezan a contar los meses](#cuándo-empiezan-a-contar-los-meses)
5. [Cómo funciona la penalización](#cómo-funciona-la-penalización)
6. [Ejemplos reales paso a paso](#ejemplos-reales)

---

## 1️⃣ FLUJO COMPLETO DEL USUARIO

### **A) SUSCRIPCIÓN INICIAL (Free → Basic)**

```
📅 FECHA: 9 de octubre de 2025, 3:00 PM

PASO 1: Usuario abre la app
  └─> Home → Toca botón "Memberships"

PASO 2: Ve pantalla de Memberships
  └─> 4 tarjetas: Free (actual), Basic, Premium, VIP
  └─> Toca tarjeta "Basic"

PASO 3: Abre pantalla de detalles de Basic
  └─> Ve todos los beneficios detallados
  └─> Ve sección "Key Features"
  └─> Ve sección "What's Included"
  └─> Toca botón flotante: "Upgrade to Basic - $29/month"

PASO 4: Aparece diálogo de confirmación
  ┌─────────────────────────────────────────┐
  │ ✓ Confirm Basic Membership              │
  │                                         │
  │ $29/month                               │
  │                                         │
  │ 🔒 3-month minimum commitment           │
  │ ⚠️ Early cancellation fee applies       │
  │ ⏰ 90-day wait to reactivate            │
  │ 💰 Cashback held until trip completion  │
  │                                         │
  │ [Read Full Terms & Conditions]          │
  │                                         │
  │ ☐ I have read and agree to terms       │
  │                                         │
  │ [Cancel] [I Accept] (deshabilitado)     │
  └─────────────────────────────────────────┘

PASO 5: Usuario marca checkbox
  └─> Botón "I Accept" se habilita

PASO 6: Usuario toca "I Accept"
  └─> Va a pantalla de pago
  └─> Selecciona método de pago (tarjeta, Klarna, etc.)
  └─> Confirma pago de $29

PASO 7: Sistema procesa pago
  └─> ✅ Pago exitoso
  └─> Sistema crea registro en tabla "memberships":
      
      INSERT INTO memberships:
      - user_id: [ID del usuario]
      - membership_type: 'Basic'
      - monthly_price: 29.00
      - current_period_start: 2025-10-09 15:00:00
      - current_period_end: 2025-11-08 15:00:00
      - next_billing_date: 2025-11-08 15:00:00
      - status: 'active'
      - months_completed: 0 ← EMPIEZA EN CERO
      - locked_until: 2026-01-07 15:00:00 ← 90 DÍAS DESPUÉS
      - can_downgrade_without_penalty: FALSE
      - reactivation_wait_days: 90

PASO 8: Usuario tiene acceso inmediato
  └─> Puede reservar vuelos con 3% cashback
  └─> Cashback va a "hold" (no se libera hasta viajar)
  └─> Tiene acceso a referral program (3%)
```

---

## 2️⃣ TIMELINE DE EVENTOS (3 MESES)

```
📅 9 OCTUBRE 2025 (Día 0):
   ✅ Usuario se suscribe a Basic ($29)
   ✅ Paga $29
   📊 months_completed = 0/3
   🔒 locked_until = 7 de enero 2026
   ❌ NO puede cancelar sin penalty
   ❌ NO puede bajar de plan sin penalty

📅 8 NOVIEMBRE 2025 (Día 30 - Mes 1):
   💳 Sistema cobra automáticamente $29
   📊 months_completed = 1/3
   🔒 locked_until = 7 de enero 2026
   ❌ NO puede cancelar sin penalty (quedan 2 meses)
   💰 Penalty si cancela: 2 × $29 = $58

📅 8 DICIEMBRE 2025 (Día 60 - Mes 2):
   💳 Sistema cobra automáticamente $29
   📊 months_completed = 2/3
   🔒 locked_until = 7 de enero 2026
   ❌ NO puede cancelar sin penalty (queda 1 mes)
   💰 Penalty si cancela: 1 × $29 = $29

📅 7 ENERO 2026 (Día 89 - DESBLOQUEO):
   🔓 locked_until EXPIRA
   ⚠️ Todavía NO completó 3 meses (le falta 1 día)
   📊 months_completed = 2/3
   💰 Penalty si cancela: 1 × $29 = $29

📅 8 ENERO 2026 (Día 90 - Mes 3 - LIBRE):
   💳 Sistema cobra automáticamente $29
   📊 months_completed = 3/3 ✅ COMPLETADO
   ✅ can_downgrade_without_penalty = TRUE
   ✅ AHORA puede cancelar sin penalty
   ✅ AHORA puede bajar de plan sin penalty
   💰 Penalty = $0
```

---

## 3️⃣ DÓNDE ESTÁN LOS BOTONES

### **UBICACIONES EN LA APP:**

```
1. BOTÓN "MEMBERSHIPS" (Home):
   Home → Botón "Memberships" → Lista de membresías

2. BOTÓN "UPGRADE" (Dentro de cada membresía):
   Memberships → Toca tarjeta → Botón flotante "Upgrade to [Plan]"

3. BOTÓN "MY MEMBERSHIP" (Profile):
   Profile → "My Membership" → Ve membresía actual
                             → Botón "Cancel Membership"
                             → Botón "Change Plan"

4. INDICADOR DE MEMBRESÍA (Profile Header):
   Profile → Header muestra:
   "Current Plan: Basic (Month 2 of 3)"
   "Locked until: January 7, 2026"
```

---

## 4️⃣ CUÁNDO EMPIEZAN A CONTAR LOS MESES

### **INICIO DEL CONTADOR:**

```
El contador months_completed empieza en 0 cuando:

1. Usuario se suscribe por PRIMERA VEZ a un plan pagado
   Free → Basic: months_completed = 0

2. Usuario hace UPGRADE de plan
   Basic → Premium: months_completed = 0 (SE RESETEA)
   
3. Usuario REACTIVA después de cancelar
   Free → VIP (después de 90 días): months_completed = 0
```

### **INCREMENTO DEL CONTADOR:**

```
El contador se incrementa CADA 30 DÍAS en la fecha de billing:

Suscrito: 9 de octubre
  ↓
Mes 1 completo: 8 de noviembre → months_completed = 0 → 1
  ↓
Mes 2 completo: 8 de diciembre → months_completed = 1 → 2
  ↓
Mes 3 completo: 8 de enero → months_completed = 2 → 3 ✅ LIBRE
```

### **IMPORTANTE - RESETEO DEL CONTADOR:**

```
SI HACES UPGRADE → EL CONTADOR SE RESETEA A CERO

Ejemplo:
- Día 1: Suscribes a Basic
- Día 60: months_completed = 2/3
- Día 61: Haces upgrade a Premium
  ❌ months_completed = 2 → 0 (SE RESETEA)
  🔒 locked_until = Día 61 + 90 días
  
Razón: Previene abusar con upgrades para evitar penalty
```

---

## 5️⃣ CÓMO FUNCIONA LA PENALIZACIÓN

### **FÓRMULA DE PENALIZACIÓN:**

```
penalty = (minimum_commitment_months - months_completed) × monthly_price

Ejemplos:

BASIC ($29/mes):
- Cancela después de 0 meses: 3 × $29 = $87
- Cancela después de 1 mes: 2 × $29 = $58
- Cancela después de 2 meses: 1 × $29 = $29
- Cancela después de 3 meses: 0 × $29 = $0 ✅

PREMIUM ($49/mes):
- Cancela después de 0 meses: 3 × $49 = $147
- Cancela después de 1 mes: 2 × $49 = $98
- Cancela después de 2 meses: 1 × $49 = $49
- Cancela después de 3 meses: 0 × $49 = $0 ✅

VIP ($79/mes):
- Cancela después de 0 meses: 3 × $79 = $237
- Cancela después de 1 mes: 2 × $79 = $158
- Cancela después de 2 meses: 1 × $79 = $79
- Cancela después de 3 meses: 0 × $79 = $0 ✅
```

### **CUÁNDO SE COBRA LA PENALIZACIÓN:**

```
Opción A: Usuario acepta pagar penalty
  1. Intenta cancelar antes de 3 meses
  2. Sistema muestra: "Penalty: $87"
  3. Usuario toca "Pay $87 & Cancel"
  4. Sistema cobra $87 inmediatamente
  5. Membresía se cancela inmediatamente
  6. Cambia a Free
  7. last_cancellation_date = HOY
  8. NO puede re-activar por 90 días

Opción B: Usuario NO acepta pagar penalty
  1. Intenta cancelar antes de 3 meses
  2. Sistema muestra: "Penalty: $87"
  3. Usuario toca "Keep Membership"
  4. NO se cobra nada
  5. Membresía continúa activa
  6. Sigue pagando mensualmente
  7. Después de 3 meses puede cancelar gratis
```

---

## 6️⃣ EJEMPLOS REALES PASO A PASO

### **EJEMPLO 1: Usuario Honesto (No intenta abusar)**

```
9 OCT: Se suscribe a Premium ($49)
       - Paga $49
       - months_completed = 0/3
       - locked_until = 7 de enero

10 OCT: Reserva vuelo a Miami ($600)
        - Cashback 5% = $30 → VA A HOLD
        - hold_until = fecha del vuelo (15 de diciembre)

8 NOV: Sistema cobra $49 automáticamente
       - months_completed = 1/3
       - Penalty si cancela: 2 × $49 = $98

8 DIC: Sistema cobra $49 automáticamente
       - months_completed = 2/3
       - Penalty si cancela: 1 × $49 = $49

15 DIC: Usuario viaja a Miami
        - Cashback $30 se LIBERA a wallet ✅
        - Usuario recibe $30 en su wallet

8 ENE: Sistema cobra $49 automáticamente
       - months_completed = 3/3 ✅ COMPLETADO
       - can_downgrade_without_penalty = TRUE
       - Penalty = $0

20 ENE: Usuario decide cancelar
        - NO hay penalty (completó 3 meses)
        - Cancela al final del período (8 de febrero)
        - Sigue con Premium hasta el 8 de febrero
        - Después cambia a Free

TOTAL PAGADO: $49 × 4 meses = $196
TOTAL RECIBIDO: $30 cashback
COSTO NETO: $166
✅ Usuario satisfecho, LandGo protegido
```

### **EJEMPLO 2: Usuario Malicioso (Intenta abusar - BLOQUEADO)**

```
9 OCT: Se suscribe a VIP ($79)
       - Paga $79
       - months_completed = 0/3
       - locked_until = 7 de enero

10 OCT: Reserva vuelo a París ($2000)
        - Cashback 8% = $160 → VA A HOLD ⏳
        - hold_until = 15 de marzo

11 OCT: Intenta BAJAR a Free (para evitar pagar más)
        ❌ SISTEMA BLOQUEA:
        
        Diálogo:
        ┌─────────────────────────────────────────┐
        │ ⚠️ Cannot Downgrade Yet                 │
        ├─────────────────────────────────────────┤
        │ You are in your minimum commitment      │
        │ period.                                 │
        │                                         │
        │ Completed: 0 of 3 months                │
        │ Locked until: January 7, 2026           │
        │                                         │
        │ To cancel/downgrade now:                │
        │ Pay $237 early termination fee          │
        │ (3 months × $79)                        │
        │                                         │
        │ [Keep VIP] [Pay $237 & Cancel]          │
        └─────────────────────────────────────────┘

12 OCT: Usuario decide NO pagar penalty
        - Sigue con VIP
        - DEBE pagar $79/mes durante 3 meses

8 NOV: Sistema cobra $79
       - months_completed = 1/3
       - Penalty si cancela: 2 × $79 = $158

8 DIC: Sistema cobra $79
       - months_completed = 2/3
       - Penalty si cancela: 1 × $79 = $79

8 ENE: Sistema cobra $79
       - months_completed = 3/3 ✅
       - can_downgrade_without_penalty = TRUE

15 ENE: Usuario intenta cancelar (ya completó 3 meses)
        ✅ Sistema permite:
        - NO hay penalty
        - Cancela al final del período (8 de febrero)
        
15 MAR: Usuario viaja a París
        - Cashback $160 se LIBERA ✅
        
20 MAR: Usuario intenta RE-ACTIVAR VIP
        ❌ SISTEMA BLOQUEA:
        "Debes esperar hasta el 15 de mayo"
        "90 días desde última cancelación"

TOTAL PAGADO: $79 × 4 meses = $316
TOTAL RECIBIDO: $160 cashback
COSTO NETO: $156
✅ NO pudo abusar, pagó lo justo
```

### **EJEMPLO 3: Usuario intenta upgrade/downgrade rápido**

```
9 OCT: Se suscribe a Basic ($29)
       - months_completed = 0/3
       - locked_until = 7 de enero

15 OCT: Decide subir a Premium ($49)
        - Quedan 24 días en el ciclo
        - Diferencia: $49 - $29 = $20
        - Prorrateado: $20 × (24/30) = $16
        - Paga $16 ahora
        ✅ Upgrade inmediato
        🔒 months_completed = 0/3 (SE RESETEA)
        🔒 locked_until = 13 de enero (90 días desde upgrade)

20 OCT: Intenta bajar a Basic de nuevo
        ❌ SISTEMA BLOQUEA:
        "Estás bloqueado hasta el 13 de enero"
        "Completaste 0 de 3 meses"
        "Penalty: 3 × $49 = $147"

Resultado: NO puede hacer upgrade/downgrade rápido ✅
```

---

## 7️⃣ DÓNDE ESTÁN LOS BOTONES (UBICACIONES)

### **A) BOTÓN "MEMBERSHIPS" (Home)**
```
Archivo: lib/pages/main_page/main_page_widget.dart
Línea: ~762

_buildActionCard('Memberships', Icons.card_membership_rounded, ...)
```

### **B) BOTÓN "UPGRADE TO [PLAN]" (Membership Detail)**
```
Archivo: lib/pages/membership_detail_page/membership_detail_page_widget.dart
Línea: ~595-620

floatingActionButton: _buildUpgradeButton()
```

### **C) BOTÓN "CANCEL MEMBERSHIP" (Profile - PENDIENTE)**
```
📍 UBICACIÓN SUGERIDA: lib/pages/my_profile_page/my_profile_page_widget.dart

Agregar sección:
┌─────────────────────────────────────────┐
│ 📊 MY MEMBERSHIP                        │
├─────────────────────────────────────────┤
│ Current Plan: Basic                     │
│ Status: Month 1 of 3                    │
│ Next Billing: November 8, 2025          │
│ Locked until: January 7, 2026           │
│                                         │
│ [Change Plan] [Cancel Membership]       │
└─────────────────────────────────────────┘
```

---

## 8️⃣ AUTOMATIZACIONES NECESARIAS (Backend)

### **CRON JOBS QUE DEBES CONFIGURAR:**

#### **JOB 1: Cobro mensual automático**
```sql
-- Ejecutar DIARIAMENTE a las 00:00 AM

SELECT * FROM memberships
WHERE status = 'active'
  AND next_billing_date <= NOW()
  AND membership_type != 'Free';

-- Para cada resultado:
1. Cobrar monthly_price a stripe_subscription_id
2. Si pago exitoso:
   - Actualizar next_billing_date = next_billing_date + 30 días
   - Actualizar current_period_end = current_period_end + 30 días
   - Incrementar months_completed += 1
   - Si months_completed >= 3: can_downgrade_without_penalty = TRUE
3. Si pago falla:
   - status = 'suspended'
   - Enviar email al usuario
```

#### **JOB 2: Liberar cashback de viajes completados**
```sql
-- Ejecutar DIARIAMENTE a las 00:00 AM

SELECT * FROM membership_cashback_holds
WHERE status = 'pending'
  AND hold_until <= NOW();

-- Para cada resultado:
1. Actualizar profiles.cashback_balance += cashback_amount
2. Actualizar status = 'released'
3. Actualizar released_at = NOW()
4. Enviar notificación al usuario: "Cashback $X released!"
```

#### **JOB 3: Aplicar downgrades programados**
```sql
-- Ejecutar DIARIAMENTE a las 00:00 AM

SELECT * FROM memberships
WHERE downgrade_at_period_end = TRUE
  AND current_period_end <= NOW();

-- Para cada resultado:
1. Actualizar membership_type = pending_downgrade_to
2. Actualizar downgrade_at_period_end = FALSE
3. Actualizar pending_downgrade_to = NULL
4. Actualizar months_completed = 0
5. Actualizar locked_until = NOW() + 90 días
6. Enviar email: "Your membership is now [New Plan]"
```

---

## 9️⃣ RESUMEN PARA EL DESARROLLADOR

### **CHECKLIST DE IMPLEMENTACIÓN:**

- ✅ SQL ejecutado en Supabase
- ✅ Pantallas creadas (Memberships, Detail, Terms)
- ✅ Servicio Flutter creado (membership_service.dart)
- ⏳ PENDIENTE: Agregar sección "My Membership" en Profile
- ⏳ PENDIENTE: Integrar pagos de membresías
- ⏳ PENDIENTE: Configurar Cron Jobs en Supabase
- ⏳ PENDIENTE: Conectar cashback hold con bookings

### **REGLAS DE ORO:**

1. **months_completed SIEMPRE empieza en 0** al suscribirse o hacer upgrade
2. **locked_until SE ESTABLECE automáticamente** al hacer upgrade (90 días)
3. **Downgrade = Cancelación** (misma penalty para ambos)
4. **Upgrade RESETEA el contador** (empieza de nuevo los 3 meses)
5. **Cashback va a HOLD**, NO a wallet directamente
6. **90 días de espera** para reactivar después de cancelar

---

## 🎯 PRÓXIMOS PASOS

1. **Ejecutar el SQL** en Supabase
2. **Agregar sección de membresía** en My Profile
3. **Integrar pagos** para suscripciones
4. **Configurar Cron Jobs** en Supabase
5. **Testing completo** del flujo

¿Todo claro ahora? 🚀

