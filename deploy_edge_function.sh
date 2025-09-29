#!/bin/bash

# 🚀 DEPLOY EDGE FUNCTION TO SUPABASE
echo "🚀 Deploying send-verification-code function to Supabase..."

# Verificar que estamos en el directorio correcto
if [ ! -d "supabase/functions/send-verification-code" ]; then
    echo "❌ Error: supabase/functions/send-verification-code directory not found"
    exit 1
fi

# Desplegar la función
echo "📦 Deploying function..."
supabase functions deploy send-verification-code

# Verificar el despliegue
if [ $? -eq 0 ]; then
    echo "✅ Function deployed successfully!"
    echo "🔍 You can check the logs with:"
    echo "   supabase functions logs send-verification-code"
else
    echo "❌ Function deployment failed!"
    exit 1
fi

echo "🎯 Next steps:"
echo "1. Test the function by updating profile data"
echo "2. Check Supabase Dashboard > Edge Functions > send-verification-code > Logs"
echo "3. Verify that verification_codes table exists and has data"
