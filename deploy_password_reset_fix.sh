#!/bin/bash

echo "🚀 DESPLEGANDO FUNCIÓN ACTUALIZADA CON PASSWORD_RESET..."

# Verificar que estamos en el directorio correcto
if [ ! -f "supabase/functions/send-verification-code/index.ts" ]; then
    echo "❌ Error: No se encontró la función send-verification-code"
    exit 1
fi

echo "📋 Verificando que el caso password_reset está presente..."
if grep -q "case 'password_reset':" supabase/functions/send-verification-code/index.ts; then
    echo "✅ Caso password_reset encontrado"
else
    echo "❌ Error: Caso password_reset no encontrado"
    exit 1
fi

echo "📋 Verificando que el caso profile_update está presente..."
if grep -q "case 'profile_update':" supabase/functions/send-verification-code/index.ts; then
    echo "✅ Caso profile_update encontrado"
else
    echo "❌ Error: Caso profile_update no encontrado"
    exit 1
fi

echo ""
echo "🎯 INSTRUCCIONES PARA DESPLEGAR:"
echo "1. Ve a Supabase Dashboard → Edge Functions → send-verification-code"
echo "2. Copia TODO el contenido del archivo: supabase/functions/send-verification-code/index.ts"
echo "3. Pega y reemplaza en el editor de Supabase"
echo "4. Haz clic en 'Deploy'"
echo ""
echo "📄 Contenido del archivo:"
echo "----------------------------------------"
cat supabase/functions/send-verification-code/index.ts
echo "----------------------------------------"

echo ""
echo "✅ DESPUÉS DEL DEPLOY:"
echo "1. Prueba Forgot Password en la app"
echo "2. Debe enviar email con 'Password Reset Request' (NO 'Notification')"
echo "3. El código debe funcionar correctamente"
