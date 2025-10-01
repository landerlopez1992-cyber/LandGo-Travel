# Deploy Delete User Edge Function

## 📋 PASOS PARA DESPLEGAR:

### 1. Desplegar la función:
```bash
supabase functions deploy delete-user
```

### 2. Verificar que se desplegó:
```bash
supabase functions list
```

### 3. Probar la función:
```bash
supabase functions serve delete-user --env-file .env.local
```

## 🔧 CONFIGURACIÓN REQUERIDA:

### Variables de entorno en Supabase:
- `SUPABASE_URL`: URL de tu proyecto Supabase
- `SUPABASE_SERVICE_ROLE_KEY`: Service role key (no anon key)

## 🧪 TESTING:

### Test manual:
```bash
curl -X POST \
  'https://dumgmnibxhfchjyowvbz.supabase.co/functions/v1/delete-user' \
  -H 'Authorization: Bearer YOUR_USER_JWT' \
  -H 'Content-Type: application/json' \
  -d '{"userId": "USER_ID_TO_DELETE"}'
```

## ⚠️ IMPORTANTE:

- La función usa `SUPABASE_SERVICE_ROLE_KEY` para admin operations
- Elimina de `profiles`, `verification_codes` y `auth.users`
- Requiere autenticación del usuario (JWT token)
- Solo permite eliminar el propio usuario (por seguridad)
