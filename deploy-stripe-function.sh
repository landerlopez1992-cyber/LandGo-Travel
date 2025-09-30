#!/bin/bash

# Script para desplegar la Supabase Edge Function de Stripe
# Ejecutar desde la raíz del proyecto

echo "🚀 Desplegando Supabase Edge Function para Stripe..."

# Verificar que Supabase CLI esté instalado
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI no está instalado. Instálalo con:"
    echo "npm install -g supabase"
    exit 1
fi

# Verificar que estemos en el directorio correcto
if [ ! -f "supabase/functions/stripe-payment/index.ts" ]; then
    echo "❌ No se encontró la Edge Function. Asegúrate de estar en la raíz del proyecto."
    exit 1
fi

# Desplegar la función
echo "📦 Desplegando función stripe-payment..."
supabase functions deploy stripe-payment

if [ $? -eq 0 ]; then
    echo "✅ Edge Function desplegada exitosamente!"
    echo ""
    echo "🔧 Próximos pasos:"
    echo "1. Ve a tu dashboard de Supabase"
    echo "2. Ve a Edge Functions"
    echo "3. Configura la variable de entorno STRIPE_SECRET_KEY"
    echo "4. Prueba la función desde tu app"
    echo ""
    echo "📝 URL de la función:"
    echo "https://dumgmnibxhfchjyowvbz.supabase.co/functions/v1/stripe-payment"
else
    echo "❌ Error al desplegar la Edge Function"
    exit 1
fi
