# CANCEL MEMBERSHIP - CÓDIGO UI A IMPLEMENTAR

## 🎯 RESUMEN
Voy a agregar el botón "Cancel Membership" en My Profile y toda la lógica de cancelación.

## 📱 UBICACIÓN DEL BOTÓN
En `my_profile_page_widget.dart`, después del botón "Payment Methods" y antes de "Log Out".

## 🔧 FUNCIONES A AGREGAR

### 1. `_handleCancelMembership()` - Punto de entrada
```dart
Future<void> _handleCancelMembership() async {
  final currentUser = SupaFlow.client.auth.currentUser;
  if (currentUser == null) return;
  
  // Obtener información de membresía
  final response = await SupaFlow.client.rpc('get_membership_cancellation_info', params: {'p_user_id': currentUser.id});
  
  if (response['has_membership'] == false) {
    _showMessage('You don\'t have an active paid membership');
    return;
  }
  
  _showCancellationDialog(response);
}
```

### 2. `_showCancellationDialog()` - Diálogo principal
Muestra:
- Información de membresía actual
- Meses completados / requeridos
- Penalty (si aplica)
- Botones: "Pay & Cancel Now" o "Schedule Cancel"

### 3. `_cancelImmediateWithPenalty()` - Cancelación con penalty
```dart
Future<void> _cancelImmediateWithPenalty(double penaltyAmount) async {
  // 1. Procesar pago de penalty con Stripe
  // 2. Llamar a cancel_membership_immediate() con payment_intent_id
  // 3. Mostrar éxito y actualizar UI
}
```

### 4. `_scheduleCancellation()` - Cancelación programada
```dart
Future<void> _scheduleCancellation() async {
  // 1. Llamar a schedule_membership_cancellation()
  // 2. Mostrar mensaje "Your membership will end on [date]"
  // 3. Actualizar UI
}
```

## 🎨 DISEÑO DEL BOTÓN
```dart
// En la sección de opciones de perfil (después de Payment Methods)
Container(
  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _handleCancelMembership,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFDC2626).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: Color(0xFFDC2626),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cancel Membership',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'End your current plan',
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  ),
),
```

## 🎨 DISEÑO DEL DIÁLOGO
```dart
Dialog(
  backgroundColor: Colors.transparent,
  child: Container(
    decoration: BoxDecoration(
      color: const Color(0xFF2C2C2C),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFFDC2626).withOpacity(0.5),
        width: 2,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header con ícono de advertencia
        // Información de membresía
        // Penalty (si aplica)
        // Botones de acción
      ],
    ),
  ),
)
```

## ✅ TESTING
1. Usuario Free → Mensaje "No active membership"
2. Usuario Basic (1 mes) → Penalty $145
3. Usuario VIP (6+ meses) → Schedule cancel sin penalty
4. Pago exitoso → Actualiza a Free
5. Cancelación programada → Muestra fecha

---

**Estado:** Listo para implementar en my_profile_page_widget.dart

