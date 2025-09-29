# DEBUG - Verificación de Códigos

## Problema
El código de verificación está siendo rechazado como "Invalid or expired".

## Pasos para Debugging

### 1. Verifica que la tabla existe
Ejecuta en Supabase SQL Editor:

```sql
SELECT * FROM verification_codes 
WHERE email = 'landerlopez1992@gmail.com'
ORDER BY created_at DESC
LIMIT 5;
```

### 2. Verifica el código específico
Reemplaza `189852` con el código que recibiste por email:

```sql
SELECT 
  id,
  email,
  code,
  type,
  expires_at,
  created_at,
  NOW() as current_time,
  (expires_at > NOW()) as is_valid,
  EXTRACT(EPOCH FROM (expires_at - NOW()))/60 as minutes_until_expiry
FROM verification_codes
WHERE code = '189852'
  AND email = 'landerlopez1992@gmail.com'
  AND type = 'profile_update';
```

### 3. Verifica todos los códigos del día
```sql
SELECT 
  id,
  email,
  code,
  type,
  expires_at,
  created_at,
  NOW() as current_time,
  (expires_at > NOW()) as is_valid
FROM verification_codes
WHERE email = 'landerlopez1992@gmail.com'
  AND created_at >= CURRENT_DATE
ORDER BY created_at DESC;
```

### 4. Limpia códigos expirados (si es necesario)
```sql
DELETE FROM verification_codes
WHERE expires_at < NOW();
```

### 5. Verifica la estructura de la tabla
```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'verification_codes'
ORDER BY ordinal_position;
```

## Solución Temporal
Si el problema persiste, ejecuta esto para limpiar y empezar de nuevo:

```sql
-- Eliminar todos los códigos del email
DELETE FROM verification_codes
WHERE email = 'landerlopez1992@gmail.com';
```

Luego intenta de nuevo desde la app.

## Logs a Revisar
En la app, verifica en los logs (terminal donde ejecutas Flutter):

- `🔍 DEBUG: Verifying code:`
- `🔍 DEBUG: Code check result:`
- `🔍 DEBUG: Code expires at:`
- `🔍 DEBUG: Current time (UTC):`
- `🔍 DEBUG: Is expired:`
