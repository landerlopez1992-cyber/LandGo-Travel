# 🚀 CONFIGURACIÓN DE EDGE FUNCTION - LANDGO TRAVEL

## 📋 PASOS PARA CREAR LA EDGE FUNCTION

### **1. Ir al Dashboard de Supabase**
- Ve a: https://supabase.com/dashboard/project/dumgmnibxhfchjyowvbz
- Navega a: **Edge Functions** en el menú lateral

### **2. Crear Nueva Edge Function**
- Haz clic en **"Create a new function"**
- Nombre: `send-verification-code`
- Descripción: `Send verification codes for password reset`

### **3. Copiar el Código**
Copia y pega este código en el editor:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { email, code } = await req.json()

    if (!email || !code) {
      return new Response(
        JSON.stringify({ error: 'Email and code are required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // For now, we'll just log the email content
    // In production, you should integrate with a real email service
    console.log('Email to send:', {
      to: email,
      subject: 'LandGo Travel - Password Reset Code',
      html: `
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>LandGo Travel - Verification Code</title>
          <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body {
              font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              background: linear-gradient(135deg, #4c669f 0%, #3b5998 50%, #192f6a 100%);
              min-height: 100vh;
              padding: 20px;
            }
            .container {
              max-width: 600px;
              margin: 0 auto;
              background: white;
              border-radius: 20px;
              overflow: hidden;
              box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            }
            .header {
              background: linear-gradient(135deg, #4c669f 0%, #3b5998 50%, #192f6a 100%);
              padding: 40px 20px;
              text-align: center;
              color: white;
            }
            .logo {
              width: 80px;
              height: 80px;
              background: white;
              border-radius: 50%;
              margin: 0 auto 20px;
              display: flex;
              align-items: center;
              justify-content: center;
              font-size: 24px;
              font-weight: bold;
              color: #4c669f;
            }
            .content {
              padding: 40px 20px;
              text-align: center;
            }
            .code {
              font-size: 48px;
              font-weight: bold;
              color: #FF9800;
              letter-spacing: 8px;
              margin: 30px 0;
              font-family: 'Courier New', monospace;
            }
            .message {
              color: #666;
              line-height: 1.6;
              margin-bottom: 30px;
            }
            .footer {
              background: #f8f9fa;
              padding: 20px;
              text-align: center;
              color: #666;
              font-size: 14px;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <div class="logo">LG</div>
              <h1>LandGo Travel</h1>
              <p>Your perfect trip begins here</p>
            </div>
            <div class="content">
              <h2>Password Reset Verification</h2>
              <p class="message">
                We received a request to reset your password. Use the verification code below to continue:
              </p>
              <div class="code">${code}</div>
              <p class="message">
                Enter this 6-digit code in the app to reset your password. This code expires in 10 minutes.
              </p>
            </div>
            <div class="footer">
              <p>If you didn't request this, please ignore this email.</p>
              <p>© 2024 LandGo Travel. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `
    })

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Verification code sent successfully',
        code: code // For testing purposes
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})
```

### **4. Deploy la Function**
- Haz clic en **"Deploy function"**
- Espera a que se despliegue exitosamente

### **5. Verificar Deployment**
- Deberías ver el estado como **"Active"**
- La URL será: `https://dumgmnibxhfchjyowvbz.supabase.co/functions/v1/send-verification-code`

## 🧪 TESTING

### **Probar la Function**
1. Ve a la pestaña **"Testing"** en la Edge Function
2. Usa este JSON de prueba:
```json
{
  "email": "test@example.com",
  "code": "123456"
}
```
3. Haz clic en **"Send request"**
4. Deberías ver una respuesta exitosa

## ✅ ESTADO ACTUAL

- ✅ Tabla `password_reset_codes` creada en Supabase
- ⏳ Edge Function `send-verification-code` pendiente de crear
- ⏳ Testing de la función pendiente

## 🎯 PRÓXIMOS PASOS

1. **Crear la Edge Function** siguiendo los pasos arriba
2. **Probar la función** con el JSON de prueba
3. **Probar en la app** el envío de códigos
4. **Verificar que lleguen los emails** con códigos de 6 dígitos

---

**NOTA:** Por ahora la función solo imprime el email en los logs. Para envío real, necesitarás integrar un servicio de email como SendGrid, Resend, o similar.
