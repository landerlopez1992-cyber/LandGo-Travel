import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Manejar confirmación de cuenta por GET request
  if (req.method === 'GET') {
    console.log('GET request received for email confirmation')
    
    const url = new URL(req.url)
    const userId = url.searchParams.get('userId')
    const email = url.searchParams.get('email')
    const fullName = url.searchParams.get('fullName')

    console.log('Parameters:', { userId, email, fullName })

    if (!userId) {
      console.log('No userId provided')
      return new Response(`
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <title>Error - LandGo Travel</title>
          <style>
            body { 
              font-family: 'Arial', sans-serif; 
              background: #f5f5f5; 
              margin: 0; 
              padding: 20px; 
              display: flex;
              align-items: center;
              justify-content: center;
              min-height: 100vh;
            }
            .container { 
              background: white; 
              border-radius: 12px; 
              padding: 40px; 
              text-align: center; 
              box-shadow: 0 4px 20px rgba(0,0,0,0.1);
              max-width: 500px;
            }
            .error-icon { font-size: 64px; color: #DC2626; margin-bottom: 20px; }
            h1 { color: #1F2937; margin-bottom: 16px; }
            p { color: #6B7280; margin-bottom: 30px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="error-icon">❌</div>
            <h1>Invalid Confirmation Link</h1>
            <p>This confirmation link is not valid. Please try again or contact support.</p>
          </div>
        </body>
        </html>
      `, { 
        status: 400,
        headers: { 'Content-Type': 'text/html', ...corsHeaders }
      })
    }

    try {
      console.log('Creating Supabase client...')
      const supabaseClient = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
      )

      console.log('Confirming user email...')
      // Confirmar el email del usuario
      const { error } = await supabaseClient.auth.admin.updateUserById(
        userId,
        { email_confirm: true }
      )

      if (error) {
        console.error('Error confirming user:', error)
        throw error
      }

      console.log('Email confirmed successfully for user:', userId)

      // Mostrar página de éxito
      return new Response(`
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Email Confirmed - LandGo Travel</title>
          <style>
            body { 
              font-family: 'Arial', sans-serif; 
              background: linear-gradient(135deg, #4c669f 0%, #3b5998 50%, #192f6a 100%); 
              margin: 0; 
              padding: 20px; 
              min-height: 100vh;
              display: flex;
              align-items: center;
              justify-content: center;
            }
            .container { 
              background: white; 
              border-radius: 12px; 
              padding: 40px; 
              text-align: center; 
              box-shadow: 0 4px 20px rgba(0,0,0,0.1);
              max-width: 500px;
              width: 100%;
            }
            .logo { 
              width: 120px; 
              height: 90px; 
              margin: 0 auto 20px; 
              display: flex;
              align-items: center;
              justify-content: center;
            }
            .logo img { 
              width: 100%; 
              height: 100%; 
              object-fit: contain; 
            }
            .success-icon {
              font-size: 64px;
              color: #4CAF50;
              margin-bottom: 20px;
            }
            h1 {
              color: #1F2937;
              margin-bottom: 16px;
            }
            p {
              color: #6B7280;
              margin-bottom: 30px;
              line-height: 1.6;
            }
            .btn {
              background: #FF9800;
              color: white;
              padding: 12px 24px;
              border: none;
              border-radius: 8px;
              font-weight: bold;
              cursor: pointer;
              text-decoration: none;
              display: inline-block;
              margin: 10px;
            }
            .btn:hover {
              background: #F57C00;
            }
            .btn-secondary {
              background: #37474F;
            }
            .btn-secondary:hover {
              background: #2C3E50;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="logo">
              <img src="https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/land-go-travel-khmzio/assets/72g91s54bkzj/1.png" alt="LandGo Travel Logo">
            </div>
            <div class="success-icon">✅</div>
            <h1>Email Confirmed Successfully!</h1>
            <p>Hello <strong>${fullName || 'Traveler'}</strong>, your email address has been verified. You can now log in to your LandGo Travel account and start planning your next adventure.</p>
            <div>
              <a href="javascript:window.close()" class="btn">Close Window</a>
              <a href="http://localhost:3000/loginPage" class="btn btn-secondary">Go to Login</a>
            </div>
            <script>
              // Mostrar mensaje de confirmación después de 3 segundos
              setTimeout(() => {
                if (confirm('Email confirmed successfully! Close this window and return to the app?')) {
                  try {
                    window.close();
                  } catch (e) {
                    // Si no se puede cerrar, redirigir a la app
                    window.location.href = 'http://localhost:3000/loginPage';
                  }
                }
              }, 3000);
            </script>
          </div>
        </body>
        </html>
      `, {
        status: 200,
        headers: {
          'Content-Type': 'text/html',
          ...corsHeaders
        }
      })
    } catch (error) {
      console.error('Error confirming account:', error)
      return new Response(`
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <title>Error - LandGo Travel</title>
          <style>
            body { 
              font-family: 'Arial', sans-serif; 
              background: #f5f5f5; 
              margin: 0; 
              padding: 20px; 
              display: flex;
              align-items: center;
              justify-content: center;
              min-height: 100vh;
            }
            .container { 
              background: white; 
              border-radius: 12px; 
              padding: 40px; 
              text-align: center; 
              box-shadow: 0 4px 20px rgba(0,0,0,0.1);
              max-width: 500px;
            }
            .error-icon { font-size: 64px; color: #DC2626; margin-bottom: 20px; }
            h1 { color: #1F2937; margin-bottom: 16px; }
            p { color: #6B7280; margin-bottom: 30px; }
            .error-details { 
              background: #FEF2F2; 
              border: 1px solid #FECACA; 
              border-radius: 8px; 
              padding: 15px; 
              margin: 20px 0; 
              color: #991B1B; 
              font-family: monospace; 
              font-size: 12px;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="error-icon">❌</div>
            <h1>Confirmation Error</h1>
            <p>There was an error confirming your email address. Please try again or contact support.</p>
            <div class="error-details">Error: ${error.message}</div>
          </div>
        </body>
        </html>
      `, { 
        status: 500,
        headers: { 'Content-Type': 'text/html', ...corsHeaders }
      })
    }
  }

  try {
    const { email, code, type, fullName, bookingData, amount, currency, passengerData, paymentMethod, marketingData, userId } = await req.json()

    if (!email) {
      return new Response(
        JSON.stringify({ error: 'Email is required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')

    if (!RESEND_API_KEY) {
      return new Response(
        JSON.stringify({ error: 'RESEND_API_KEY not configured' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    let emailSubject = ''
    let emailHtml = ''

    // Función para generar HTML base con LOGO REAL de la app (SIN FONDO BLANCO)
    const generateBaseHTML = (content: string) => `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>LandGo Travel</title>
        <style>
          body { 
            font-family: 'Arial', sans-serif; 
            background: #f5f5f5; 
            padding: 20px; 
            margin: 0; 
            line-height: 1.6;
          }
          .container { 
            max-width: 600px; 
            margin: 0 auto; 
            background: white; 
            border-radius: 12px; 
            overflow: hidden; 
            box-shadow: 0 4px 20px rgba(0,0,0,0.1); 
          }
          .header { 
            background: linear-gradient(135deg, #4c669f 0%, #3b5998 50%, #192f6a 100%); 
            color: white; 
            padding: 30px; 
            text-align: center; 
          }
          .logo { 
            width: 120px; 
            height: 90px; 
            margin: 0 auto 20px; 
            display: flex;
            align-items: center;
            justify-content: center;
          }
          .logo img { 
            width: 100%; 
            height: 100%; 
            object-fit: contain; 
          }
          .content { 
            padding: 30px; 
            color: #333; 
            line-height: 1.6; 
          }
          .cta-button { 
            display: inline-block; 
            background: #FF9800; 
            color: white; 
            padding: 15px 30px; 
            text-decoration: none; 
            border-radius: 8px; 
            font-weight: bold; 
            margin: 20px 0; 
            transition: background-color 0.3s ease;
          }
          .cta-button:hover {
            background: #F57C00;
          }
          .footer { 
            background: #F8FAFC; 
            padding: 20px; 
            text-align: center; 
            color: #666; 
            font-size: 14px; 
            border-top: 1px solid #eee; 
          }
          .booking-details { 
            background: #F8FAFC; 
            padding: 20px; 
            border-radius: 8px; 
            margin: 20px 0; 
            border: 1px solid #E2E8F0;
          }
          .detail-row { 
            display: flex; 
            justify-content: space-between; 
            margin: 10px 0; 
            padding: 8px 0; 
            border-bottom: 1px solid #e0e0e0; 
          }
          .detail-row:last-child {
            border-bottom: none;
          }
          .detail-label { 
            font-weight: bold; 
            color: #37474F; 
          }
          .detail-value { 
            color: #1F2937; 
          }
          .referral-box { 
            background: linear-gradient(135deg, #4CAF50, #45a049); 
            color: white; 
            padding: 20px; 
            border-radius: 8px; 
            margin: 20px 0; 
            text-align: center; 
          }
          .referral-code { 
            background: rgba(255,255,255,0.2); 
            padding: 10px; 
            border-radius: 5px; 
            font-family: monospace; 
            font-size: 18px; 
            margin: 10px 0; 
            display: inline-block;
          }
          .company-info { 
            background: #F1F5F9; 
            padding: 15px; 
            border-radius: 8px; 
            margin: 20px 0; 
            text-align: center; 
          }
          .verification-code {
            display: inline-block;
            background-color: #F1F5F9;
            color: #1F2937;
            font-size: 32px;
            font-weight: bold;
            padding: 15px 30px;
            border-radius: 8px;
            letter-spacing: 5px;
            margin: 20px 0;
            border: 2px solid #E2E8F0;
          }
          .security-notice {
            background: #FFF3CD;
            border: 1px solid #FFEAA7;
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
            color: #856404;
          }
          .success-icon {
            color: #4CAF50;
            font-size: 48px;
            margin: 20px 0;
          }
          .product-grid { 
            display: grid; 
            grid-template-columns: 1fr; 
            gap: 20px; 
            margin: 20px 0; 
          }
          .product-card { 
            border: 1px solid #e0e0e0; 
            border-radius: 8px; 
            overflow: hidden; 
            background: white; 
          }
          .product-image { 
            width: 100%; 
            height: 200px; 
            background: linear-gradient(45deg, #f0f0f0, #e0e0e0); 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            color: #666; 
            font-size: 14px; 
          }
          .product-info { 
            padding: 15px; 
          }
          .product-title { 
            font-size: 18px; 
            font-weight: bold; 
            color: #1F2937; 
            margin-bottom: 8px; 
          }
          .product-location { 
            color: #6B7280; 
            font-size: 14px; 
            margin-bottom: 8px; 
          }
          .product-price { 
            font-size: 20px; 
            font-weight: bold; 
            color: #FF9800; 
            margin-bottom: 8px; 
          }
          .product-original-price { 
            text-decoration: line-through; 
            color: #6B7280; 
            font-size: 14px; 
          }
          .product-discount { 
            background: #4CAF50; 
            color: white; 
            padding: 4px 8px; 
            border-radius: 4px; 
            font-size: 12px; 
            font-weight: bold; 
          }
          .product-dates { 
            color: #6B7280; 
            font-size: 12px; 
            margin-top: 8px; 
          }
          .marketing-header { 
            background: linear-gradient(135deg, #FF9800, #F57C00); 
            color: white; 
            padding: 20px; 
            text-align: center; 
            border-radius: 8px; 
            margin: 20px 0; 
          }
          .offer-badge { 
            background: #DC2626; 
            color: white; 
            padding: 8px 16px; 
            border-radius: 20px; 
            font-size: 14px; 
            font-weight: bold; 
            display: inline-block; 
            margin: 10px 0; 
          }
          @media (max-width: 600px) {
            .container {
              margin: 10px;
              border-radius: 8px;
            }
            .header, .content, .footer {
              padding: 20px;
            }
            .logo {
              width: 100px;
              height: 75px;
            }
            .verification-code {
              font-size: 24px;
              padding: 12px 20px;
            }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <div class="logo">
              <img src="https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/land-go-travel-khmzio/assets/72g91s54bkzj/1.png" alt="LandGo Travel Logo">
            </div>
            <h1 style="margin: 0; font-size: 28px;">LandGo Travel</h1>
            <p style="margin: 10px 0 0 0; opacity: 0.9;">Your perfect trip begins here</p>
          </div>
          <div class="content">
            ${content}
          </div>
          <div class="footer">
            <div class="company-info">
              <p style="margin: 0 0 10px 0; font-weight: bold; color: #37474F;">LandGo Travel</p>
              <p style="margin: 5px 0; color: #6B7280;">14703 Southern Blvd, Loxahatchee, FL 33470</p>
              <p style="margin: 5px 0; color: #6B7280;">West Palm Beach, Florida</p>
              <p style="margin: 5px 0; color: #6B7280;">📧 info@landgotravel.com</p>
              <p style="margin: 5px 0; color: #6B7280;">📞 (561) 123-4567</p>
            </div>
            <p style="margin: 15px 0 5px 0;">© 2024 LandGo Travel. All rights reserved.</p>
            <p style="margin: 0; font-style: italic;">Your trusted partner in creating unforgettable travel experiences.</p>
          </div>
        </div>
      </body>
      </html>
    `

    // Función para generar productos de marketing
    const generateProductCard = (product: any) => `
      <div class="product-card">
        <div class="product-image">
          ${product.imageUrl ? `<img src="${product.imageUrl}" alt="${product.name}" style="width: 100%; height: 100%; object-fit: cover;">` : '🏨 Hotel Image'}
        </div>
        <div class="product-info">
          <div class="product-title">${product.name}</div>
          <div class="product-location">📍 ${product.location}</div>
          <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
            <span class="product-price">$${product.price}</span>
            ${product.originalPrice ? `<span class="product-original-price">$${product.originalPrice}</span>` : ''}
            ${product.discount ? `<span class="product-discount">-${product.discount}%</span>` : ''}
          </div>
          <div class="product-dates">📅 ${product.dates}</div>
          ${product.description ? `<div style="font-size: 12px; color: #6B7280; margin-top: 8px;">${product.description}</div>` : ''}
        </div>
      </div>
    `

    switch (type) {
      case 'email_confirmation':
        const confirmationUrl = `${req.url}?userId=${userId}&email=${encodeURIComponent(email)}&fullName=${encodeURIComponent(fullName || '')}`
        
        emailSubject = 'LandGo Travel - Confirm Your Email Address'
        emailHtml = generateBaseHTML(`
          <div style="text-align: center;">
            <div class="success-icon">✉️</div>
            <h2 style="color: #1F2937; margin: 0 0 20px 0;">Welcome to LandGo Travel!</h2>
          </div>
          
          <p>Hello <strong>${fullName || 'Traveler'}</strong>,</p>
          <p>Thank you for signing up with LandGo Travel! To complete your account setup and start exploring amazing destinations, please confirm your email address by clicking the button below.</p>
          
          <div style="text-align: center; margin: 30px 0;">
            <a href="${confirmationUrl}" class="cta-button">Confirm Email Address</a>
          </div>
          
          <div class="booking-details">
            <h3 style="color: #37474F; margin: 0 0 15px 0;">What happens next?</h3>
            <div class="detail-row">
              <span class="detail-label">✓ Email Confirmed</span>
              <span class="detail-value">Your account will be activated</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">✓ Access Granted</span>
              <span class="detail-value">Start booking amazing trips</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">✓ Welcome Benefits</span>
              <span class="detail-value">Exclusive deals and offers</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">✓ Referral Program</span>
              <span class="detail-value">Earn money by referring friends</span>
            </div>
          </div>

          <div class="security-notice">
            <p style="margin: 0;"><strong>Security Notice:</strong> If you didn't create an account with LandGo Travel, you can safely ignore this email. This confirmation link will expire in 24 hours for security reasons.</p>
          </div>
          
          <p>Welcome to the LandGo Travel family! We're excited to help you plan your next adventure.</p>
          <p style="margin: 20px 0 0 0;"><strong>The LandGo Travel Team</strong></p>
        `)
        break

      case 'welcome':
        emailSubject = 'Welcome to LandGo Travel - Your Journey Begins!'
        emailHtml = generateBaseHTML(`
          <div style="text-align: center;">
            <div class="success-icon">🎉</div>
            <h2 style="color: #1F2937; margin: 0 0 20px 0;">Welcome to the LandGo Travel Family!</h2>
          </div>
          
          <p>Hello <strong>${fullName || 'Traveler'}</strong>,</p>
          <p>Thank you for confirming your email and joining LandGo Travel! We're thrilled to have you as part of our travel community. Your journey to amazing destinations starts now.</p>
          
          <div class="booking-details">
            <h3 style="color: #37474F; margin: 0 0 15px 0;">What LandGo Travel offers you:</h3>
            <div class="detail-row">
              <span class="detail-label">✓ Exclusive flight deals</span>
              <span class="detail-value">Up to 50% discounts</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">✓ Premium hotel bookings</span>
              <span class="detail-value">Special rates</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">✓ Travel points system</span>
              <span class="detail-value">Earn while you travel</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">✓ 24/7 customer support</span>
              <span class="detail-value">Always here for you</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">✓ Travel insurance</span>
              <span class="detail-value">Complete protection</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">✓ Group discounts</span>
              <span class="detail-value">Family packages</span>
            </div>
          </div>

          <div class="referral-box">
            <h3 style="margin: 0 0 15px 0;">🎉 EARN MONEY BY REFERRING FRIENDS!</h3>
            <p style="margin: 0 0 15px 0;">Join our referral program and earn rewards for every friend you bring to LandGo Travel!</p>
            
            <div class="referral-code">
              Your Referral Code: <strong>${fullName?.toUpperCase().replace(/\s/g, '') || 'TRAVELER'}2024</strong>
            </div>
            
            <div style="text-align: left; margin: 15px 0;">
              <p style="margin: 8px 0;"><strong>How it works:</strong></p>
              <p style="margin: 5px 0;">• Share your referral code with friends</p>
              <p style="margin: 5px 0;">• They get 10% off their first booking</p>
              <p style="margin: 5px 0;">• You earn $25 in travel credits per referral</p>
              <p style="margin: 5px 0;">• Unlimited referrals = Unlimited earnings!</p>
            </div>
            
            <div style="text-align: left; margin: 15px 0;">
              <p style="margin: 8px 0;"><strong>Referral Levels:</strong></p>
              <p style="margin: 5px 0;">🥉 Level 1: $25 per referral</p>
              <p style="margin: 5px 0;">🥈 Level 2: $35 per referral (after 5 referrals)</p>
              <p style="margin: 5px 0;">🥇 Level 3: $50 per referral (after 15 referrals)</p>
            </div>
            
            <p style="margin: 15px 0 0 0;"><strong>Start referring today and turn your network into your income!</strong></p>
          </div>

          <p>Ready to explore the world? Log in to your account and discover amazing destinations waiting for you.</p>
          
          <div style="text-align: center;">
            <a href="#" class="cta-button">Start Planning Your Trip</a>
          </div>
          
          <p>Welcome aboard, and happy travels!</p>
          <p style="margin: 20px 0 0 0;"><strong>The LandGo Travel Team</strong></p>
        `)
        break

      case 'verification':
        emailSubject = 'LandGo Travel - Your Verification Code'
        emailHtml = generateBaseHTML(`
          <div style="text-align: center;">
            <div class="success-icon">🔐</div>
            <h2 style="color: #1F2937; margin: 0 0 20px 0;">Verification Code</h2>
          </div>
          
          <p>Hello <strong>${fullName || 'User'}</strong>,</p>
          <p>You requested a verification code for your LandGo Travel account. Please use the following code to complete your request:</p>
          
          <div style="text-align: center; margin: 30px 0;">
            <div class="verification-code">${code}</div>
          </div>
          
          <div class="security-notice">
            <p style="margin: 0;"><strong>Important:</strong> This code is valid for 10 minutes only. If you didn't request this code, please ignore this email or contact our support team.</p>
          </div>
          
          <p>Thank you for choosing LandGo Travel!</p>
          <p style="margin: 20px 0 0 0;"><strong>The LandGo Travel Team</strong></p>
        `)
        break

      case 'password_changed':
        emailSubject = 'LandGo Travel - Password Updated Successfully'
        emailHtml = generateBaseHTML(`
          <div style="text-align: center;">
            <div class="success-icon">🔒</div>
            <h2 style="color: #1F2937; margin: 0 0 20px 0;">Password Updated Successfully</h2>
          </div>
          
          <p>Hello <strong>${fullName || 'User'}</strong>,</p>
          <p>Your password has been successfully updated for your LandGo Travel account. Your account security is now enhanced.</p>
          
          <div class="booking-details">
            <h3 style="color: #37474F; margin: 0 0 15px 0;">Security Information:</h3>
            <div class="detail-row">
              <span class="detail-label">Account:</span>
              <span class="detail-value">${email}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Updated:</span>
              <span class="detail-value">${new Date().toLocaleString()}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Status:</span>
              <span class="detail-value">Secure</span>
            </div>
          </div>

          <div class="security-notice">
            <p style="margin: 0;"><strong>Security Alert:</strong> If you did not make this change, please contact our support team immediately at info@landgotravel.com or call (561) 123-4567.</p>
          </div>
          
          <p>Thank you for keeping your account secure!</p>
          <p style="margin: 20px 0 0 0;"><strong>The LandGo Travel Team</strong></p>
        `)
        break

      case 'flight_booking':
        emailSubject = 'LandGo Travel - Flight Booking Confirmation'
        emailHtml = generateBaseHTML(`
          <div style="text-align: center;">
            <div class="success-icon">✈️</div>
            <h2 style="color: #1F2937; margin: 0 0 20px 0;">Flight Booking Confirmed!</h2>
          </div>
          
          <p>Hello <strong>${fullName || 'Traveler'}</strong>,</p>
          <p>Your flight has been successfully booked. Here are your booking details:</p>
          
          <div class="booking-details">
            <h3 style="color: #37474F; margin: 0 0 15px 0;">Flight Details:</h3>
            <div class="detail-row">
              <span class="detail-label">From:</span>
              <span class="detail-value">${bookingData?.origin || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">To:</span>
              <span class="detail-value">${bookingData?.destination || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Date:</span>
              <span class="detail-value">${bookingData?.date || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Flight:</span>
              <span class="detail-value">${bookingData?.flightNumber || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Total:</span>
              <span class="detail-value">${currency || '$'}${amount || '0'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Payment Method:</span>
              <span class="detail-value">${paymentMethod || 'Credit Card'}</span>
            </div>
          </div>

          <div class="booking-details">
            <h3 style="color: #37474F; margin: 0 0 15px 0;">Passenger Information:</h3>
            <div class="detail-row">
              <span class="detail-label">Name:</span>
              <span class="detail-value">${passengerData?.fullName || fullName || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Email:</span>
              <span class="detail-value">${passengerData?.email || email}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Phone:</span>
              <span class="detail-value">${passengerData?.phone || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Date of Birth:</span>
              <span class="detail-value">${passengerData?.dateOfBirth || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Passport/ID:</span>
              <span class="detail-value">${passengerData?.passportId || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Seat:</span>
              <span class="detail-value">${passengerData?.seatNumber || 'N/A'}</span>
            </div>
          </div>

          <p>Your e-ticket will be sent separately. Please check-in online 24 hours before departure.</p>
          
          <div style="text-align: center;">
            <a href="#" class="cta-button">Download Ticket</a>
          </div>
          
          <p>Have a great trip!</p>
          <p style="margin: 20px 0 0 0;"><strong>The LandGo Travel Team</strong></p>
        `)
        break

      case 'hotel_booking':
        emailSubject = 'LandGo Travel - Hotel Booking Confirmation'
        emailHtml = generateBaseHTML(`
          <div style="text-align: center;">
            <div class="success-icon">🏨</div>
            <h2 style="color: #1F2937; margin: 0 0 20px 0;">Hotel Booking Confirmed!</h2>
          </div>
          
          <p>Hello <strong>${fullName || 'Traveler'}</strong>,</p>
          <p>Your hotel reservation has been successfully confirmed. Here are your booking details:</p>
          
          <div class="booking-details">
            <h3 style="color: #37474F; margin: 0 0 15px 0;">Hotel Details:</h3>
            <div class="detail-row">
              <span class="detail-label">Hotel:</span>
              <span class="detail-value">${bookingData?.hotelName || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Location:</span>
              <span class="detail-value">${bookingData?.location || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Check-in:</span>
              <span class="detail-value">${bookingData?.checkIn || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Check-out:</span>
              <span class="detail-value">${bookingData?.checkOut || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Total:</span>
              <span class="detail-value">${currency || '$'}${amount || '0'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Payment Method:</span>
              <span class="detail-value">${paymentMethod || 'Credit Card'}</span>
            </div>
          </div>

          <div class="booking-details">
            <h3 style="color: #37474F; margin: 0 0 15px 0;">Guest Information:</h3>
            <div class="detail-row">
              <span class="detail-label">Name:</span>
              <span class="detail-value">${passengerData?.fullName || fullName || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Email:</span>
              <span class="detail-value">${passengerData?.email || email}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Phone:</span>
              <span class="detail-value">${passengerData?.phone || 'N/A'}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Special Requests:</span>
              <span class="detail-value">${passengerData?.specialRequests || 'None'}</span>
            </div>
          </div>

          <p>Your hotel voucher will be sent separately. Please present this confirmation at check-in.</p>
          
          <div style="text-align: center;">
            <a href="#" class="cta-button">Download Voucher</a>
          </div>
          
          <p>Enjoy your stay!</p>
          <p style="margin: 20px 0 0 0;"><strong>The LandGo Travel Team</strong></p>
        `)
        break

      case 'marketing':
        emailSubject = marketingData?.subject || 'LandGo Travel - Special Offer!'
        
        // Generar productos de marketing
        let productsHTML = ''
        if (marketingData?.products && Array.isArray(marketingData.products)) {
          productsHTML = `
            <div class="product-grid">
              ${marketingData.products.map(product => generateProductCard(product)).join('')}
            </div>
          `
        }

        emailHtml = generateBaseHTML(`
          <div class="marketing-header">
            <div class="offer-badge">${marketingData?.badge || 'LIMITED TIME OFFER'}</div>
            <h2 style="margin: 0 0 10px 0;">${marketingData?.title || 'Special Travel Offer!'}</h2>
            <p style="margin: 0; opacity: 0.9;">${marketingData?.subtitle || 'Don\'t miss these amazing deals!'}</p>
          </div>

          <p>Hello <strong>${fullName || 'Traveler'}</strong>,</p>
          <p>${marketingData?.message || 'We have an amazing offer just for you!'}</p>
          
          ${marketingData?.discount ? `
          <div class="referral-box">
            <h3 style="margin: 0 0 15px 0;">🎉 ${marketingData.discount}% OFF!</h3>
            <p style="margin: 0 0 10px 0;">Use code: <strong>${marketingData.promoCode || 'TRAVEL2024'}</strong></p>
            <p style="margin: 0;">Valid until: ${marketingData.expiryDate || 'End of month'}</p>
          </div>
          ` : ''}

          ${productsHTML}

          ${marketingData?.offerDetails ? `
          <div class="booking-details">
            <h3 style="color: #37474F; margin: 0 0 15px 0;">Offer Details:</h3>
            ${marketingData.offerDetails}
          </div>
          ` : ''}

          <div style="text-align: center;">
            <a href="#" class="cta-button">${marketingData?.ctaText || 'Book Now'}</a>
          </div>
          
          <p>Don't miss out on this amazing opportunity!</p>
          <p style="margin: 20px 0 0 0;"><strong>The LandGo Travel Team</strong></p>
        `)
        break

      default:
        emailSubject = 'LandGo Travel - Notification'
        emailHtml = generateBaseHTML(`
          <div style="text-align: center;">
            <div class="success-icon">📧</div>
            <h2 style="color: #1F2937; margin: 0 0 20px 0;">Notification</h2>
          </div>
          
          <p>Hello <strong>${fullName || 'User'}</strong>,</p>
          <p>This is a notification from LandGo Travel.</p>
          <p>Thank you for using our services!</p>
          <p style="margin: 20px 0 0 0;"><strong>The LandGo Travel Team</strong></p>
        `)
    }

    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: 'LandGo Travel <onboarding@resend.dev>',
        to: [email],
        subject: emailSubject,
        html: emailHtml,
      }),
    })

    if (!resendResponse.ok) {
      const error = await resendResponse.text()
      console.error('Resend error:', error)
      throw new Error('Failed to send email')
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Email sent successfully',
        type: type || 'verification',
        timestamp: new Date().toISOString()
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ 
        error: error.message,
        timestamp: new Date().toISOString()
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})