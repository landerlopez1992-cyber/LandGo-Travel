# 🔐 Configuración de Supabase Auth para LandGo Travel

## ⚠️ IMPORTANTE: Desactivar Email Automático de Confirmación

Para que el sistema funcione correctamente con nuestro flujo personalizado de códigos de verificación, debes configurar Supabase Auth de la siguiente manera:

### 1. Ir a Dashboard de Supabase

1. Abre tu proyecto en https://supabase.com/dashboard
2. Ve a **Authentication** → **Providers** → **Email**

### 2. Configurar Email Provider

Debes configurar las siguientes opciones:

#### **Confirm email** 
- ❌ **DESACTIVAR** "Confirm email"
- Esto evita que Supabase envíe su email automático de confirmación
- En su lugar, usamos nuestro sistema personalizado de códigos

#### **Enable email confirmations**
```
✅ Habilitado (para permitir la verificación)
```

#### **Secure email change**
```
✅ Habilitado (para seguridad)
```

### 3. Configurar Email Templates (OPCIONAL)

Si Supabase insiste en enviar emails, puedes:

1. Ir a **Authentication** → **Email Templates**
2. Desactivar o vaciar el template de "Confirm signup"

### 4. Verificar configuración

Después de hacer los cambios:

1. Crea una nueva cuenta de prueba
2. Verifica que SOLO recibes el email de nuestro sistema (con código de 6 dígitos)
3. NO deberías recibir el email genérico de Supabase

---

## 🔒 Flujo de Seguridad Implementado

### Sign Up
1. Usuario completa formulario → **Sign Up**
2. Se crea cuenta en Supabase Auth (SIN confirmación automática)
3. Se envía código de 6 dígitos vía **send-verification-code** Edge Function
4. Usuario introduce código
5. Al verificar código → **Supabase marca email como confirmado**
6. Trigger automático crea perfil en `profiles`

### Login
1. Usuario intenta login
2. **VERIFICACIÓN**: ¿Email confirmado?
   - ❌ NO → Cerrar sesión + Error: "Email not verified"
   - ✅ SÍ → Permitir acceso
3. Primera vez después de verificación → Enviar email de bienvenida
4. Crear perfil en `user_profiles` si no existe

---

## 📋 Checklist de Configuración

- [ ] Desactivar "Confirm email" en Email Provider
- [ ] Verificar que Edge Function `send-verification-code` está desplegada
- [ ] Verificar que Edge Function `delete-user` está desplegada
- [ ] Probar Sign Up → Solo recibir código de 6 dígitos
- [ ] Probar Login sin verificar → Debe rechazar
- [ ] Probar Login con verificación → Debe permitir

---

## 🐛 Solución de Problemas

### Problema: Recibo dos emails (Supabase + nuestro código)
**Solución**: Desactivar "Confirm email" en Dashboard de Supabase

### Problema: Puedo hacer login sin verificar email
**Solución**: El código en `email_auth.dart` ahora bloquea esto automáticamente

### Problema: "Unsupported operation: The delete user operation is not yet supported"
**Solución**: Asegúrate de que la Edge Function `delete-user` está desplegada correctamente

---

## 📱 Pantallas del Flujo

1. **SignUpPage** → Formulario de registro
2. **VerificationCodePage** → Introducir código de 6 dígitos
3. **LoginPage** → Solo permite acceso si email está verificado
4. **MainPage** → Dashboard principal

---

## 🚀 Despliegue de Edge Functions

### delete-user
```bash
supabase functions deploy delete-user
```

### send-verification-code
```bash
supabase functions deploy send-verification-code
```

---

Creado: 2025-09-30
Proyecto: LandGo Travel
