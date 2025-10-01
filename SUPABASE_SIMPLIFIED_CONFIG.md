# 🔧 Configuración Supabase para Flujo Simplificado

## 📋 **PASOS OBLIGATORIOS:**

### **1. ACTIVAR EMAIL AUTOMÁTICO EN SUPABASE:**

Ve a tu **Supabase Dashboard:**
- https://supabase.com/dashboard
- Tu proyecto → **Authentication** → **Providers** → **Email**

**CONFIGURAR:**
- ✅ **ACTIVAR** "Confirm email" 
- ✅ **ACTIVAR** "Enable email confirmations"
- ✅ **ACTIVAR** "Secure email change"

### **2. CONFIGURAR EMAIL TEMPLATES (OPCIONAL):**

**Authentication** → **Email Templates** → **Confirm signup**

Puedes personalizar el template o usar el predeterminado.

### **3. EJECUTAR SQL PARA TRIGGER:**

Copia y ejecuta este SQL en **SQL Editor**:

```sql
-- Función para crear perfil automáticamente cuando se confirma email
CREATE OR REPLACE FUNCTION handle_email_confirmation()
RETURNS trigger AS $$
BEGIN
  -- Solo crear perfil si es la primera confirmación de email
  IF NEW.email_confirmed_at IS NOT NULL AND OLD.email_confirmed_at IS NULL THEN
    -- Insertar en profiles si no existe
    INSERT INTO public.profiles (
      id,
      email,
      full_name,
      cashback_balance,
      membership_type,
      created_at,
      updated_at
    ) VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NEW.raw_user_meta_data->>'full_name', 'Traveler'),
      0.0, -- Balance inicial
      'basic', -- Membresía básica
      NOW(),
      NOW()
    )
    ON CONFLICT (id) DO NOTHING; -- No hacer nada si ya existe
    
    RAISE NOTICE 'Profile created for user: %', NEW.email;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger en auth.users para crear perfil al confirmar email
DROP TRIGGER IF EXISTS on_auth_user_email_confirmed ON auth.users;
CREATE TRIGGER on_auth_user_email_confirmed
  AFTER UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_email_confirmation();
```

---

## 🎯 **FLUJO ESPERADO:**

### **Sign Up:**
1. Usuario completa formulario → **Sign Up**
2. Se crea cuenta en `auth.users` (SIN confirmar)
3. **Supabase envía automáticamente** email de confirmación
4. Navega a `EmailNotificationPage` (sin botones)

### **EmailNotificationPage:**
1. **Sin botones, sin acciones**
2. **Auto-refresh** cada 5 segundos
3. Verifica si `emailConfirmedAt != null`
4. Si confirmado → **Navega automáticamente** a Login

### **Login:**
1. Usuario intenta login
2. **SI email NO confirmado** → Navega a `EmailNotificationPage`
3. **SI email SÍ confirmado** → Permite acceso normal

### **Confirmación de Email:**
1. Usuario hace clic en link del email
2. **Supabase confirma automáticamente** el email
3. **Trigger automático** → Crea perfil en `profiles`
4. **Auto-navegación** → Va a Login

---

## ✅ **VENTAJAS DEL FLUJO SIMPLIFICADO:**

1. **Más simple** - No códigos de 6 dígitos
2. **Menos pantallas** - Solo notificación
3. **Automático** - No requiere intervención del usuario
4. **Estándar** - Usa sistema nativo de Supabase
5. **Seguro** - No permite acceso sin confirmación

---

## 🔍 **VERIFICACIÓN:**

Después de configurar:

1. **Sign Up** → Debe navegar a `EmailNotificationPage`
2. **Email automático** → Debe recibirse de Supabase
3. **Clic en link** → Debe confirmar y navegar a Login
4. **Login sin confirmar** → Debe ir a `EmailNotificationPage`
5. **Login confirmado** → Debe permitir acceso

---

Creado: 2025-09-30
Proyecto: LandGo Travel - Flujo Simplificado
