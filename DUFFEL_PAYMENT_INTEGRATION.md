# 💳 INTEGRACIÓN DUFFEL PAYMENTS - LANDGO TRAVEL

## 🎯 **ESTRATEGIA DE PAGOS CON DUFFEL**

### **Arquitectura de Pagos:**
```
1. Usuario agrega $300 a billetera (Stripe procesa)
2. Usuario paga viaje $300 (Billetera → Duffel)
3. Duffel cobra desde saldo Duffel
4. Admin recarga saldo Duffel con tarjeta de débito empresarial
```

---

## 📋 **MÉTODOS DE PAGO DISPONIBLES EN DUFFEL**

### **1. Saldo de Duffel** 💰 (RECOMENDADO)
- **Funcionamiento:** Recargas tu cuenta Duffel con dinero
- **Ventajas:**
  - ✅ Control total sobre recargas
  - ✅ Pagos predecibles
  - ✅ Usa tu tarjeta de débito empresarial
  - ✅ Menos riesgo (saldo limitado)
- **Desventajas:**
  - ❌ Requiere recargar saldo manualmente
  - ❌ Fondos inmovilizados

### **2. Tarjeta de Crédito** 💳
- **Funcionamiento:** Pagas cada reserva con tarjeta
- **Ventajas:**
  - ✅ No requiere saldo previo
  - ✅ Pagos automáticos
- **Desventajas:**
  - ❌ No se puede configurar como método fijo
  - ❌ Requiere tarjeta en cada transacción

### **3. ARC/BSP Cash** 🏦
- **Funcionamiento:** Solo para agentes IATA acreditados
- **Estado:** No aplica para tu caso

---

## 🛠️ **IMPLEMENTACIÓN TÉCNICA**

### **Opción 1: Saldo de Duffel (RECOMENDADA)**

#### **1. Servicio de Duffel**
**Archivo:** `lib/services/duffel_service.dart`

```dart
class DuffelService {
  static const String _duffelApiKey = String.fromEnvironment('DUFFEL_API_KEY');
  static const String _duffelBaseUrl = 'https://api.duffel.com/air';

  // NUEVO: Verificar saldo de Duffel
  Future<double> getDuffelBalance() async {
    try {
      final response = await http.get(
        Uri.parse('$_duffelBaseUrl/balances'),
        headers: {
          'Authorization': 'Bearer $_duffelApiKey',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data']['amount'] / 100).toDouble(); // En dólares
      }
      return 0.0;
    } catch (e) {
      throw Exception('Error getting Duffel balance: $e');
    }
  }

  // NUEVO: Recargar saldo de Duffel
  Future<void> topUpDuffelBalance(double amount) async {
    try {
      final response = await http.post(
        Uri.parse('$_duffelBaseUrl/balances/top_up'),
        headers: {
          'Authorization': 'Bearer $_duffelApiKey',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': (amount * 100).toInt(), // En centavos
          'currency': 'USD',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error topping up balance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error topping up Duffel balance: $e');
    }
  }

  // NUEVO: Crear orden con saldo de Duffel
  Future<Map<String, dynamic>> createOrderWithBalance({
    required String offerId,
    required double amount,
    required List<Map<String, dynamic>> passengers,
  }) async {
    try {
      // Verificar saldo suficiente
      final balance = await getDuffelBalance();
      if (balance < amount) {
        throw Exception('Insufficient Duffel balance. Current: \$${balance.toStringAsFixed(2)}, Required: \$${amount.toStringAsFixed(2)}');
      }

      final response = await http.post(
        Uri.parse('$_duffelBaseUrl/orders'),
        headers: {
          'Authorization': 'Bearer $_duffelApiKey',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'selected_offers': [offerId],
          'payments': [
            {
              'type': 'balance',
              'currency': 'USD',
              'amount': (amount * 100).toInt(),
            }
          ],
          'passengers': passengers,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Error creating order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  // NUEVO: Procesar pago desde billetera
  Future<Map<String, dynamic>> processWalletPayment({
    required String offerId,
    required double amount,
    required String userId,
    required List<Map<String, dynamic>> passengers,
  }) async {
    try {
      // 1. Crear orden en Duffel
      final order = await createOrderWithBalance(
        offerId: offerId,
        amount: amount,
        passengers: passengers,
      );

      // 2. Debitar de billetera del usuario
      await _debitFromWallet(userId, amount);

      // 3. Registrar transacción
      await _recordTransaction(
        userId: userId,
        amount: amount,
        type: 'travel_booking',
        duffelOrderId: order['data']['id'],
        status: 'completed',
      );

      return {
        'success': true,
        'orderId': order['data']['id'],
        'confirmationCode': order['data']['booking_reference'],
        'totalAmount': order['data']['total_amount'],
      };
    } catch (e) {
      // Si falla, revertir débito de billetera
      await _creditToWallet(userId, amount);
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // NUEVO: Debitar de billetera
  Future<void> _debitFromWallet(String userId, double amount) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .update({
            'cashback_balance': Supabase.instance.client
                .from('profiles')
                .select('cashback_balance')
                .eq('id', userId)
                .then((result) => result.first['cashback_balance'] - amount),
          })
          .eq('id', userId);

      if (response.error != null) {
        throw Exception('Error debiting wallet: ${response.error}');
      }
    } catch (e) {
      throw Exception('Error debiting wallet: $e');
    }
  }

  // NUEVO: Acreditar a billetera (para reversiones)
  Future<void> _creditToWallet(String userId, double amount) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .update({
            'cashback_balance': Supabase.instance.client
                .from('profiles')
                .select('cashback_balance')
                .eq('id', userId)
                .then((result) => result.first['cashback_balance'] + amount),
          })
          .eq('id', userId);

      if (response.error != null) {
        throw Exception('Error crediting wallet: ${response.error}');
      }
    } catch (e) {
      throw Exception('Error crediting wallet: $e');
    }
  }

  // NUEVO: Registrar transacción
  Future<void> _recordTransaction({
    required String userId,
    required double amount,
    required String type,
    required String duffelOrderId,
    required String status,
  }) async {
    try {
      await Supabase.instance.client.from('payments').insert({
        'user_id': userId,
        'amount': amount,
        'payment_method': 'wallet',
        'type': type,
        'status': status,
        'description': 'Travel booking via Duffel',
        'external_reference': duffelOrderId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error recording transaction: $e');
    }
  }

  // NUEVO: Obtener detalles de orden
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_duffelBaseUrl/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $_duffelApiKey',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error getting order details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting order details: $e');
    }
  }

  // NUEVO: Cancelar orden
  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_duffelBaseUrl/orders/$orderId/actions/cancel'),
        headers: {
          'Authorization': 'Bearer $_duffelApiKey',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error canceling order: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error canceling order: $e');
    }
  }
}
```

#### **2. Actualizar UI de Booking**
**Archivo:** `lib/pages/flight_booking_page/flight_booking_page_widget.dart`

```dart
class FlightBookingPageWidget extends StatefulWidget {
  final Map<String, dynamic> selectedOffer;
  final double totalAmount;
  final List<Map<String, dynamic>> passengers;

  @override
  _FlightBookingPageWidgetState createState() => _FlightBookingPageWidgetState();
}

class _FlightBookingPageWidgetState extends State<FlightBookingPageWidget> {
  final DuffelService _duffelService = DuffelService();
  bool _isProcessing = false;
  double _walletBalance = 0.0;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
    _loadCurrentUser();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('cashback_balance')
          .eq('id', _currentUserId)
          .single();

      setState(() {
        _walletBalance = (response.data['cashback_balance'] ?? 0.0).toDouble();
      });
    } catch (e) {
      print('Error loading wallet balance: $e');
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF37474F),
        title: Text(
          'Confirmar Reserva',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detalles del vuelo
            _buildFlightDetails(),
            
            SizedBox(height: 24),
            
            // Detalles de pasajeros
            _buildPassengerDetails(),
            
            SizedBox(height: 24),
            
            // Resumen de precios
            _buildPriceSummary(),
            
            SizedBox(height: 32),
            
            // Opciones de pago
            _buildPaymentOptions(),
            
            Spacer(),
            
            // Botón de confirmación
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightDetails() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles del Vuelo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          
          // Información del vuelo
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.selectedOffer['origin']['iata_code'],
                      style: TextStyle(
                        color: Color(0xFF4DD0E1),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.selectedOffer['origin']['city_name'],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.flight_takeoff,
                color: Color(0xFF4DD0E1),
                size: 24,
              ),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.selectedOffer['destination']['iata_code'],
                      style: TextStyle(
                        color: Color(0xFF4DD0E1),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.selectedOffer['destination']['city_name'],
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerDetails() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pasajeros',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          
          ...widget.passengers.map((passenger) => Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: Color(0xFF4DD0E1),
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  '${passenger['given_name']} ${passenger['family_name']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de Precios',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                '\$${widget.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Color(0xFF4DD0E1),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de Pago',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        
        // Opción de billetera
        GestureDetector(
          onTap: _canPayWithWallet ? _handleWalletPayment : null,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _canPayWithWallet ? Color(0xFF2C2C2C) : Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _canPayWithWallet ? Color(0xFF4DD0E1) : Colors.grey,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: _canPayWithWallet ? Color(0xFF4DD0E1) : Colors.grey,
                  size: 24,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pagar con Billetera',
                        style: TextStyle(
                          color: _canPayWithWallet ? Colors.white : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Saldo disponible: \$${_walletBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: _canPayWithWallet ? Colors.white70 : Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_canPayWithWallet)
                  Icon(
                    Icons.check_circle,
                    color: Color(0xFF4DD0E1),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
        
        if (!_canPayWithWallet) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFDC2626).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFDC2626)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Saldo insuficiente. Agrega \$${(widget.totalAmount - _walletBalance).toStringAsFixed(2)} a tu billetera.',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _canPayWithWallet && !_isProcessing ? _handleWalletPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canPayWithWallet ? Color(0xFF4DD0E1) : Colors.grey,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              )
            : Text(
                'Confirmar Reserva',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  bool get _canPayWithWallet {
    return _walletBalance >= widget.totalAmount;
  }

  Future<void> _handleWalletPayment() async {
    setState(() => _isProcessing = true);

    try {
      final result = await _duffelService.processWalletPayment(
        offerId: widget.selectedOffer['id'],
        amount: widget.totalAmount,
        userId: _currentUserId,
        passengers: widget.passengers,
      );

      if (result['success']) {
        // Mostrar confirmación
        _showBookingConfirmation(result);
      } else {
        _showErrorDialog(result['error']);
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showBookingConfirmation(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2C2C2C),
        title: Text(
          '¡Reserva Confirmada!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Código de confirmación:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              result['confirmationCode'],
              style: TextStyle(
                color: Color(0xFF4DD0E1),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Total pagado: \$${result['totalAmount']}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Volver a la página anterior
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4DD0E1),
              foregroundColor: Colors.black,
            ),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2C2C2C),
        title: Text(
          'Error',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          error,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4DD0E1),
              foregroundColor: Colors.black,
            ),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
```

### **Opción 2: Tarjeta por cada reserva**

```dart
// NUEVO: Crear orden con tarjeta
Future<Map<String, dynamic>> createOrderWithCard({
  required String offerId,
  required double amount,
  required List<Map<String, dynamic>> passengers,
  required Map<String, dynamic> cardDetails,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$_duffelBaseUrl/orders'),
      headers: {
        'Authorization': 'Bearer $_duffelApiKey',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'selected_offers': [offerId],
        'payments': [
          {
            'type': 'card',
            'currency': 'USD',
            'amount': (amount * 100).toInt(),
            'card': {
              'number': cardDetails['number'],
              'expiry_month': cardDetails['expiry_month'],
              'expiry_year': cardDetails['expiry_year'],
              'cvv': cardDetails['cvv'],
              'holder_name': cardDetails['holder_name'],
            },
          }
        ],
        'passengers': passengers,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error creating order: ${response.body}');
    }
  } catch (e) {
    throw Exception('Error creating order: $e');
  }
}
```

---

## 💰 **ANÁLISIS FINANCIERO**

### **Opción 1: Saldo de Duffel**
- **Control:** Total sobre recargas
- **Riesgo:** Saldo limitado
- **Flexibilidad:** Recargas según necesidad
- **Costos:** Sin costos adicionales

### **Opción 2: Tarjeta por reserva**
- **Control:** Limitado (cada transacción)
- **Riesgo:** Exposición total de tarjeta
- **Flexibilidad:** Automático
- **Costos:** Posibles comisiones adicionales

---

## 🎯 **RECOMENDACIÓN FINAL**

### **Usar Saldo de Duffel porque:**
1. ✅ **Control total** sobre recargas
2. ✅ **Pagos predecibles** desde saldo
3. ✅ **Usas tu tarjeta de débito** para recargar
4. ✅ **Menos riesgo** (saldo limitado)
5. ✅ **Mejor flujo de caja**

### **Flujo recomendado:**
```
1. Usuario agrega $300 a billetera (Stripe)
2. Usuario paga viaje $300 (Billetera → Duffel)
3. Duffel cobra desde tu saldo Duffel
4. Tú recargas saldo Duffel con tu tarjeta de débito
```

---

## 📋 **PRÓXIMOS PASOS**

### **Implementación:**
1. **Configurar Duffel API** con tu clave
2. **Implementar servicio de saldo** de Duffel
3. **Actualizar UI de booking** para usar billetera
4. **Configurar recargas** de saldo Duffel
5. **Testing completo** del flujo

### **Configuración requerida:**
- [ ] Clave API de Duffel
- [ ] Configurar recargas de saldo
- [ ] Configurar webhooks de Duffel
- [ ] Testing con ofertas reales

---

**ESTADO:** ✅ ESTRATEGIA COMPLETA
**PRÓXIMO:** Implementar cuando decidas
**FECHA:** 2025-10-03
