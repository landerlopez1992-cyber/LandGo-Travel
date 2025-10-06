# 🎯 ESTRATEGIA DE PANEL DE ADMINISTRACIÓN - LANDGO TRAVEL

## 🎯 **CONCEPTO PRINCIPAL**

### **Arquitectura Propuesta:**
```
📱 App Móvil (Flutter) → Solo usuarios/clientes
🌐 Panel Web (Flutter Web) → Solo admins/empleados  
🔒 Supabase → 3 roles: user, admin, employee
```

### **URLs:**
- **App Principal:** `landgotravel.com` (Flutter Web App)
- **Panel Admin:** `landgotravel.com/admin` (Panel de Administración)

---

## 👥 **SISTEMA DE ROLES**

### **1. USER (Cliente)** 👤
- **Acceso:** Solo app móvil
- **Funciones:**
  - Buscar vuelos/hoteles
  - Agregar saldo a billetera
  - Hacer reservas
  - Ver historial de viajes
  - Transferir dinero a otros usuarios

### **2. ADMIN (Tú)** 👑
- **Acceso:** Solo panel web (`/admin`)
- **Funciones:**
  - Ver todas las transacciones
  - Gestionar usuarios
  - Configurar Duffel
  - Ver estadísticas de ventas
  - Gestionar empleados
  - Configurar políticas de billetera
  - Ver logs del sistema

### **3. EMPLOYEE (Empleados)** 👨‍💼
- **Acceso:** Solo panel web (`/admin`)
- **Funciones:**
  - Ver transacciones (limitado)
  - Ayudar a usuarios
  - Procesar reembolsos
  - Ver reportes básicos

---

## 🛠️ **IMPLEMENTACIÓN TÉCNICA**

### **1. Configurar Supabase RLS (Row Level Security)**

**Tabla: `profiles`**
```sql
-- Agregar columna role
ALTER TABLE profiles ADD COLUMN role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin', 'employee'));

-- Crear políticas RLS
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Employees can view user profiles" ON profiles
  FOR SELECT USING (
    role = 'user' AND EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'employee')
    )
  );
```

**Tabla: `payments`**
```sql
CREATE POLICY "Users can view own payments" ON payments
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Admins can view all payments" ON payments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Employees can view payments" ON payments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() AND role IN ('admin', 'employee')
    )
  );
```

### **2. Estructura de Archivos Flutter**

```
lib/
├── pages/
│   ├── admin/                    # 🆕 Panel de administración
│   │   ├── admin_login_page/
│   │   ├── admin_dashboard/
│   │   ├── admin_users/
│   │   ├── admin_transactions/
│   │   ├── admin_settings/
│   │   └── admin_reports/
│   └── [páginas existentes]     # Páginas de usuarios
├── services/
│   ├── admin_service.dart        # 🆕 Servicio para admin
│   └── [servicios existentes]
└── widgets/
    ├── admin/                    # 🆕 Widgets para admin
    │   ├── admin_app_bar.dart
    │   ├── admin_sidebar.dart
    │   └── admin_data_table.dart
    └── [widgets existentes]
```

### **3. Configurar GoRouter**

**Archivo:** `lib/flutter_flow/nav/nav.dart`

```dart
GoRouter(
  initialLocation: '/',
  routes: [
    // 🆕 Rutas de administración
    GoRoute(
      path: '/admin',
      builder: (context, state) => AdminLoginPageWidget(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => AdminDashboardPageWidget(),
    ),
    GoRoute(
      path: '/admin/users',
      builder: (context, state) => AdminUsersPageWidget(),
    ),
    GoRoute(
      path: '/admin/transactions',
      builder: (context, state) => AdminTransactionsPageWidget(),
    ),
    GoRoute(
      path: '/admin/settings',
      builder: (context, state) => AdminSettingsPageWidget(),
    ),
    
    // Rutas existentes de usuarios
    GoRoute(
      path: '/',
      builder: (context, state) => MainPageWidget(),
    ),
    // ... resto de rutas existentes
  ],
);
```

### **4. Middleware de Autenticación**

**Archivo:** `lib/services/admin_service.dart`

```dart
class AdminService {
  static const String _adminPath = '/admin';
  
  // Verificar si es ruta de admin
  static bool isAdminRoute(String path) {
    return path.startsWith(_adminPath);
  }
  
  // Verificar rol del usuario
  static Future<String?> getUserRole() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;
      
      final response = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();
      
      return response.data['role'];
    } catch (e) {
      return null;
    }
  }
  
  // Verificar si puede acceder a admin
  static Future<bool> canAccessAdmin() async {
    final role = await getUserRole();
    return role == 'admin' || role == 'employee';
  }
  
  // Redirigir si no tiene permisos
  static Future<void> checkAdminAccess(BuildContext context) async {
    if (isAdminRoute(GoRouterState.of(context).uri.path)) {
      final canAccess = await canAccessAdmin();
      if (!canAccess) {
        context.go('/');
      }
    }
  }
}
```

### **5. Widget de Verificación de Rol**

**Archivo:** `lib/widgets/admin/admin_guard.dart`

```dart
class AdminGuard extends StatelessWidget {
  final Widget child;
  final List<String> allowedRoles;
  
  const AdminGuard({
    Key? key,
    required this.child,
    this.allowedRoles = const ['admin', 'employee'],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AdminService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Color(0xFF1A1A1A),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4DD0E1),
              ),
            ),
          );
        }
        
        final role = snapshot.data;
        
        if (role == null || !allowedRoles.contains(role)) {
          // Redirigir a página principal
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/');
          });
          return Scaffold(
            backgroundColor: Color(0xFF1A1A1A),
            body: Center(
              child: Text(
                'Acceso denegado',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        
        return child;
      },
    );
  }
}
```

---

## 📱 **PÁGINAS DEL PANEL DE ADMINISTRACIÓN**

### **1. Admin Login Page** (`/admin`)
```dart
class AdminLoginPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo LandGo Travel
              Image.asset(
                'assets/images/logo.png',
                height: 60,
              ),
              SizedBox(height: 32),
              
              Text(
                'Panel de Administración',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              
              // Formulario de login
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF4DD0E1)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF4DD0E1)),
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: () => _handleLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4DD0E1),
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _handleLogin(BuildContext context) async {
    // Verificar credenciales y rol
    final user = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (user.user != null) {
      final role = await AdminService.getUserRole();
      if (role == 'admin' || role == 'employee') {
        context.go('/admin/dashboard');
      } else {
        // Mostrar error: no tiene permisos
      }
    }
  }
}
```

### **2. Admin Dashboard** (`/admin/dashboard`)
```dart
class AdminDashboardPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        appBar: AdminAppBar(),
        body: Row(
          children: [
            // Sidebar
            AdminSidebar(),
            
            // Contenido principal
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // Cards de estadísticas
                    Row(
                      children: [
                        _buildStatCard('Usuarios Total', '1,234', Icons.people),
                        SizedBox(width: 16),
                        _buildStatCard('Ventas Hoy', '\$12,345', Icons.attach_money),
                        SizedBox(width: 16),
                        _buildStatCard('Reservas Hoy', '45', Icons.flight),
                        SizedBox(width: 16),
                        _buildStatCard('Billetera Total', '\$89,012', Icons.account_balance_wallet),
                      ],
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Gráfico de ventas
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ventas por Día',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 24),
                              // Gráfico de ventas
                              Expanded(child: SalesChart()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Color(0xFF4DD0E1),
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### **3. Admin Users** (`/admin/users`)
```dart
class AdminUsersPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      allowedRoles: ['admin'], // Solo admin puede ver usuarios
      child: Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        appBar: AdminAppBar(),
        body: Row(
          children: [
            AdminSidebar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Usuarios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // Tabla de usuarios
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AdminDataTable(
                          columns: [
                            'ID',
                            'Email',
                            'Nombre',
                            'Saldo Billetera',
                            'Rol',
                            'Fecha Registro',
                            'Acciones',
                          ],
                          data: _loadUsers(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<List<Map<String, dynamic>>> _loadUsers() async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select('*')
        .order('created_at', ascending: false);
    
    return response.data;
  }
}
```

### **4. Admin Transactions** (`/admin/transactions`)
```dart
class AdminTransactionsPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        appBar: AdminAppBar(),
        body: Row(
          children: [
            AdminSidebar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transacciones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // Filtros
                    Row(
                      children: [
                        _buildFilterDropdown('Tipo', ['Todos', 'Recarga', 'Transferencia', 'Reserva']),
                        SizedBox(width: 16),
                        _buildFilterDropdown('Estado', ['Todos', 'Completado', 'Pendiente', 'Fallido']),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => _exportTransactions(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4DD0E1),
                            foregroundColor: Colors.black,
                          ),
                          child: Text('Exportar'),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Tabla de transacciones
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AdminDataTable(
                          columns: [
                            'ID',
                            'Usuario',
                            'Tipo',
                            'Monto',
                            'Método',
                            'Estado',
                            'Fecha',
                            'Acciones',
                          ],
                          data: _loadTransactions(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔒 **SEGURIDAD**

### **1. Middleware de Autenticación**
- Verificar rol en cada página de admin
- Redirigir si no tiene permisos
- Session timeout automático

### **2. RLS en Supabase**
- Políticas por rol
- Usuarios solo ven sus datos
- Admins ven todo
- Empleados ven datos limitados

### **3. Validación de Rutas**
- Solo rutas `/admin/*` para administradores
- Redirección automática si no tiene permisos
- Logs de acceso al panel

---

## 📊 **FUNCIONALIDADES DEL PANEL**

### **Para ADMIN (Tú):**
- ✅ Dashboard con estadísticas completas
- ✅ Gestión de usuarios (crear, editar, eliminar)
- ✅ Ver todas las transacciones
- ✅ Configurar Duffel
- ✅ Gestionar empleados
- ✅ Ver logs del sistema
- ✅ Exportar reportes
- ✅ Configurar políticas de billetera

### **Para EMPLOYEE (Empleados):**
- ✅ Dashboard básico
- ✅ Ver transacciones (limitado)
- ✅ Ayudar a usuarios
- ✅ Procesar reembolsos
- ✅ Ver reportes básicos

---

## 🎯 **VENTAJAS DE ESTA ARQUITECTURA**

### **1. Separación Clara:**
- App móvil = usuarios
- Panel web = administración
- Sin confusión de roles

### **2. Seguridad:**
- RLS en Supabase
- Verificación de roles
- Rutas protegidas

### **3. Escalabilidad:**
- Fácil agregar nuevos roles
- Fácil agregar nuevas funcionalidades
- Código organizado

### **4. Mantenimiento:**
- Un solo proyecto Flutter
- Código compartido
- Fácil deployment

---

## 📋 **PLAN DE IMPLEMENTACIÓN**

### **Fase 1: Configuración Base**
- [ ] Configurar roles en Supabase
- [ ] Crear políticas RLS
- [ ] Configurar GoRouter
- [ ] Crear AdminService

### **Fase 2: Páginas de Admin**
- [ ] Admin Login Page
- [ ] Admin Dashboard
- [ ] Admin Users
- [ ] Admin Transactions

### **Fase 3: Funcionalidades Avanzadas**
- [ ] Admin Settings
- [ ] Admin Reports
- [ ] Admin Logs
- [ ] Export de datos

### **Fase 4: Testing y Deployment**
- [ ] Testing de seguridad
- [ ] Testing de roles
- [ ] Deployment
- [ ] Documentación

---

**ESTADO:** ✅ ESTRATEGIA COMPLETA
**PRÓXIMO:** Implementar cuando decidas
**FECHA:** 2025-10-03
