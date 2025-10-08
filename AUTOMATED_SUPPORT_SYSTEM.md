# 🤖 Sistema de Chat de Soporte Automatizado - LandGo Travel

## 📋 Descripción General

Sistema inteligente de soporte que automatiza el 80-90% de las consultas comunes, reduciendo la carga del personal y brindando respuestas instantáneas 24/7.

## 🎯 Características Principales

### ✅ **Automatización Inteligente**
- Menú de opciones contextual basado en el problema del usuario
- Detección automática del usuario logueado
- Consulta automática de reservas, transacciones y saldo
- Respuestas instantáneas para problemas comunes

### 🔄 **Escalamiento Inteligente**
- Cuando el bot no puede resolver → Redirige a agente humano
- Transferencia de contexto completo al agente
- Historial de conversación preservado

### 📊 **Categorías de Soporte**
1. **✈️ Vuelos** - Reservas, cambios, cancelaciones
2. **🏨 Hoteles** - Reservaciones, modificaciones
3. **💰 Billetera** - Saldo, transacciones, transferencias
4. **💳 Pagos** - Problemas de pago, reembolsos
5. **👤 Cuenta** - Configuración, contraseña, perfil
6. **👨‍💼 Agente** - Hablar con humano

## 🗂️ Estructura de Base de Datos

### 1️⃣ `support_conversations`
Almacena las conversaciones de soporte.

**Campos clave:**
- `user_id` - Usuario que inicia el chat
- `status` - active, resolved, escalated, closed
- `category` - flights, hotels, wallet, payment, account
- `is_automated` - true si es manejado por bot
- `assigned_agent_id` - ID del agente si se escaló

### 2️⃣ `support_messages`
Mensajes individuales del chat.

**Campos clave:**
- `conversation_id` - Conversación a la que pertenece
- `sender_type` - user, bot, agent
- `message_text` - Contenido del mensaje
- `message_type` - text, option, action, info

### 3️⃣ `support_bot_options`
Menú de opciones del bot (árbol jerárquico).

**Campos clave:**
- `parent_option_id` - Opción padre (NULL para raíz)
- `option_key` - Identificador único
- `option_text` - Texto mostrado al usuario
- `requires_data` - Si necesita input del usuario
- `action_type` - Acción a ejecutar

### 4️⃣ `support_automated_actions`
Registro de acciones automatizadas ejecutadas.

## 🚀 Flujo de Trabajo

```
1. Usuario abre chat
   ↓
2. Bot muestra menú principal
   ↓
3. Usuario selecciona categoría (ej: "Vuelos")
   ↓
4. Bot muestra sub-opciones
   ↓
5. Usuario selecciona acción (ej: "Verificar mi reserva")
   ↓
6. Bot solicita datos si es necesario (ej: Booking ID)
   ↓
7. Bot consulta automáticamente la base de datos
   ↓
8. Bot muestra información o ejecuta acción
   ↓
9a. Problema resuelto → Cierra chat
9b. Problema complejo → Escala a agente humano
```

## 📱 Ejemplo de Conversación Automatizada

**Escenario: Usuario quiere verificar su reserva de vuelo**

```
🤖 Bot: "Welcome to LandGo Travel Support! How can I help you today?"

[✈️ Flight Bookings]
[🏨 Hotel Reservations]
[💰 My Wallet]
[💳 Payments & Refunds]
[👤 Account & Profile]
[👨‍💼 Speak to an Agent]

👤 User: *Selecciona "Flight Bookings"*

🤖 Bot: "What do you need help with regarding your flight?"

[📋 Check My Booking]
[❌ Cancel Flight]
[🔄 Change Flight]
[📧 Resend Confirmation]
[⬅️ Back to Main Menu]

👤 User: *Selecciona "Check My Booking"*

🤖 Bot: "Please provide your booking reference number (e.g., LG2024-123456)"

👤 User: "LG2024-789456"

🤖 Bot: *Consulta automáticamente la base de datos*

🤖 Bot: "✅ I found your booking!

📋 Booking Details:
- Reference: LG2024-789456
- Flight: Miami (MIA) → New York (JFK)
- Date: Jan 15, 2025
- Passenger: John Doe
- Status: Confirmed
- Confirmation sent to: john@email.com

Is there anything else I can help you with?"

[❌ Cancel This Flight]
[🔄 Change This Flight]
[📧 Resend Confirmation]
[🏠 Main Menu]
[✅ Close Chat]
```

## 🔧 Instalación

### Paso 1: Ejecutar SQL en Supabase

1. Abre Supabase Dashboard
2. Ve a SQL Editor
3. Copia y pega el contenido de `create_automated_support_system.sql`
4. Ejecuta el script

### Paso 2: Verificar Tablas Creadas

Verifica que se crearon estas tablas:
- ✅ `support_conversations`
- ✅ `support_messages`
- ✅ `support_bot_options`
- ✅ `support_automated_actions`

### Paso 3: Verificar Opciones del Bot

Ejecuta en SQL Editor:
```sql
SELECT option_key, option_text, category, action_type 
FROM public.support_bot_options 
WHERE parent_option_id IS NULL
ORDER BY order_index;
```

Deberías ver el menú principal con 7 opciones.

## 🎨 Integración con Flutter

La página `SupportChatPageWidget` ya existe en:
```
lib/user/support_chat_page/support_chat_page_widget.dart
```

Necesitamos modificarla para:
1. Cargar opciones del bot desde Supabase
2. Mostrar opciones como botones interactivos
3. Detectar automáticamente el usuario logueado
4. Consultar reservas/transacciones según la opción
5. Escalar a agente cuando sea necesario

## 📊 Beneficios del Sistema

### Para el Usuario:
- ✅ Respuestas instantáneas 24/7
- ✅ No esperar en cola
- ✅ Resolución rápida de problemas comunes
- ✅ Interfaz intuitiva con opciones claras

### Para la Empresa:
- ✅ Reduce carga de trabajo del personal en 80-90%
- ✅ Ahorro de costos operativos
- ✅ Mejor experiencia del cliente
- ✅ Métricas y analytics automáticos
- ✅ Escalamiento solo cuando es necesario

## 🔄 Próximos Pasos

1. ✅ Ejecutar SQL en Supabase
2. ⏳ Modificar `SupportChatPageWidget` para conectar con el sistema
3. ⏳ Implementar lógica de consultas automáticas
4. ⏳ Crear panel de admin para agentes
5. ⏳ Agregar analytics y reportes

## 📞 Soporte

Para dudas o problemas con la implementación, contacta al equipo de desarrollo.
