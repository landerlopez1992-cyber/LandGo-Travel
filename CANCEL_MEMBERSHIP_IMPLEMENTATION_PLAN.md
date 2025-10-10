# CANCEL MEMBERSHIP - PLAN DE IMPLEMENTACIÓN

## 📋 OBJETIVO
Implementar botón "Cancel Membership" en My Profile que permita al usuario cancelar su membresía de forma segura y controlada.

## 🎯 FUNCIONALIDADES

### 1. Validación Inicial
- ✅ Verificar que el usuario tiene una membresía activa (Basic/Premium/VIP)
- ✅ Obtener información de la membresía desde Supabase
- ✅ Llamar función SQL `validate_membership_downgrade(user_id, 'cancel')`

### 2. Diálogo de Confirmación
**Muestra:**
- Nombre de la membresía actual
- Precio mensual
- Meses completados / Meses requeridos (6)
- Penalty calculado (si aplica)
- Fecha de próximo cobro

**Opciones:**
- **Si completó 6 meses:** Solo "Schedule Cancel" (sin penalty)
- **Si NO completó 6 meses:** "Pay $X & Cancel Now" o "Schedule Cancel"

### 3. Cancelación Inmediata (Con Penalty)
**Flujo:**
1. Usuario confirma pago de penalty
2. Procesar pago con Stripe
3. Actualizar membresía a 'Free' en Supabase
4. Establecer `cancelled_at = NOW()`
5. Establecer `last_cancellation_date = NOW()`
6. Mostrar mensaje de éxito
7. Navegar a My Profile

### 4. Cancelación Programada (Sin Penalty)
**Flujo:**
1. Usuario confirma cancelación al final del período
2. Actualizar `pending_downgrade_to = 'Free'`
3. Actualizar `downgrade_at_period_end = TRUE`
4. Mostrar mensaje: "Your membership will be cancelled on [date]"
5. Usuario sigue con acceso hasta la fecha de fin

## 🗄️ FUNCIONES SQL NECESARIAS

### validate_membership_downgrade(user_id, action)
**Ya existe en Supabase** - Retorna:
```json
{
  "can_proceed": true/false,
  "months_completed": 2,
  "months_required": 6,
  "months_remaining": 4,
  "penalty_amount": 316.00,
  "monthly_price": 79.00,
  "can_downgrade_without_penalty": false,
  "message": "Early cancellation penalty: $316 (4 months × $79)"
}
```

### cancel_membership_immediate(user_id, payment_intent_id)
**Nueva función a crear** - Pasos:
1. Validar que el penalty fue pagado
2. Actualizar membresía a 'Free'
3. Establecer fechas de cancelación
4. Retornar confirmación

### schedule_membership_cancellation(user_id)
**Nueva función a crear** - Pasos:
1. Validar que puede cancelar sin penalty
2. Actualizar `pending_downgrade_to = 'Free'`
3. Actualizar `downgrade_at_period_end = TRUE`
4. Retornar fecha de cancelación

## 📱 UI/UX

### Botón en My Profile
```dart
_buildProfileOption(
  icon: Icons.cancel_outlined,
  title: 'Cancel Membership',
  subtitle: 'End your current plan',
  color: Color(0xFFDC2626), // Rojo
  onTap: () => _handleCancelMembership(),
),
```

### Diálogo de Confirmación
- Header con ícono de advertencia
- Información de membresía
- Cálculo de penalty
- Dos botones claramente diferenciados
- Checkbox "I understand" para confirmar

## 🧪 TESTING

### Casos de Prueba
1. ✅ Usuario Free intenta cancelar → Mensaje: "You don't have an active membership"
2. ✅ Usuario Basic (1 mes) cancela → Penalty: $145 (5 meses)
3. ✅ Usuario Premium (3 meses) cancela → Penalty: $147 (3 meses)
4. ✅ Usuario VIP (6 meses) cancela → Sin penalty, solo schedule
5. ✅ Usuario VIP (7 meses) cancela → Sin penalty, cancela inmediato

## 📝 IMPLEMENTACIÓN

### Archivos a Modificar
1. `lib/pages/my_profile_page/my_profile_page_widget.dart`
   - Agregar botón "Cancel Membership"
   - Implementar `_handleCancelMembership()`
   - Implementar diálogos de confirmación

2. `supabase/sql/membership_cancellation_functions.sql`
   - `cancel_membership_immediate()`
   - `schedule_membership_cancellation()`

### Orden de Implementación
1. ✅ Crear funciones SQL
2. ✅ Desplegar en Supabase
3. ✅ Agregar botón en My Profile
4. ✅ Implementar validación
5. ✅ Implementar diálogo
6. ✅ Implementar flujos de cancelación
7. ✅ Testing completo

---

**Versión:** 1.0  
**Fecha:** 2025-10-10  
**Estado:** Iniciando implementación

