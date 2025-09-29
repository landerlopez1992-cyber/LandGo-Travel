// 🔧 CÓDIGO PARA AGREGAR A LA FUNCIÓN DE SUPABASE
// Agregar este caso ANTES del caso 'default' en el switch statement

case 'profile_update':
  // Generar código de verificación de 6 dígitos
  const verificationCode = Math.floor(100000 + Math.random() * 900000).toString()
  
  emailSubject = 'LandGo Travel - Profile Update Verification'
  emailHtml = generateBaseHTML(`
    <div style="text-align: center;">
      <div class="success-icon">🔐</div>
      <h2 style="color: #FFFFFF; margin: 0 0 20px 0;">Profile Update Verification</h2>
    </div>
    
    <p>Hello <strong>${fullName || 'User'}</strong>,</p>
    <p>You are trying to update your profile information. For security reasons, please verify this change using the code below:</p>
    
    <div style="text-align: center; margin: 30px 0;">
      <div class="verification-code">${verificationCode}</div>
    </div>
    
    <div class="security-notice">
      <p style="margin: 0;"><strong>Security Notice:</strong> This code is valid for 10 minutes only. If you didn't request this profile update, please ignore this email and contact our support team immediately.</p>
    </div>
    
    <p>Once verified, your profile changes will be saved securely.</p>
    <p>Thank you for keeping your account secure!</p>
    <p style="margin: 20px 0 0 0;"><strong>The LandGo Travel Team</strong></p>
  `)
  
  // Guardar el código en la base de datos para verificación posterior
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )
    
    // Guardar código de verificación (expira en 10 minutos)
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString()
    
    await supabaseClient
      .from('verification_codes')
      .insert({
        email: email,
        code: verificationCode,
        type: 'profile_update',
        expires_at: expiresAt,
        created_at: new Date().toISOString()
      })
      
    console.log('Verification code saved:', verificationCode)
  } catch (dbError) {
    console.error('Error saving verification code:', dbError)
  }
  break
