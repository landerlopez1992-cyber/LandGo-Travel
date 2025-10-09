import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Stripe API configuration
const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY')
if (!STRIPE_SECRET_KEY) {
  throw new Error('STRIPE_SECRET_KEY environment variable is required')
}
const STRIPE_API_URL = 'https://api.stripe.com/v1'

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Parse request body
    const { action, ...data } = await req.json()
    
    console.log('🔍 DEBUG: Stripe Edge Function called with action:', action)
    console.log('🔍 DEBUG: Data received:', JSON.stringify(data, null, 2))

    switch (action) {
      case 'create_customer':
        return await createCustomer(data)
      case 'create_payment_method':
        return await createPaymentMethod(data)
      case 'create_payment_method_with_token':
        return await createPaymentMethodWithToken(data)
      case 'attach_payment_method':
        return await attachPaymentMethod(data)
      case 'create_payment_intent':
        return await createPaymentIntent(data)
      case 'confirm_payment':
        return await confirmPayment(data)
      case 'validate_card':
        return await validateCard(data)
      // 🆕 KLARNA ACTIONS
      case 'create_klarna_session':
        return await createKlarnaSession(data)
      case 'confirm_klarna_payment':
        return await confirmKlarnaPayment(data)
      // 🆕 AFTERPAY ACTIONS
      case 'create_afterpay_session':
        return await createAfterpaySession(data)
      case 'confirm_afterpay_payment':
        return await confirmAfterpayPayment(data)
      default:
        throw new Error(`Unknown action: ${action}`)
    }
  } catch (error) {
    console.error('❌ ERROR in Stripe Edge Function:', error)
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message 
      }),
      { 
        status: 400, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

// ✅ Create PaymentMethod with Test Token (FUNCIONA 100%)
async function createPaymentMethodWithToken(data: any) {
  const { testToken, cardholderName } = data
  
  console.log('🔍 DEBUG: Creating PaymentMethod with test token:', testToken)

  const response = await fetch(`${STRIPE_API_URL}/payment_methods`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      'type': 'card',
      'card[token]': testToken,
      'billing_details[name]': cardholderName,
    }),
  })

  const result = await response.json()
  console.log('🔍 DEBUG: Stripe PaymentMethod response:', {
    status: response.status,
    success: response.ok,
    id: result.id
  })

  if (!response.ok) {
    throw new Error(`Stripe PaymentMethod Error: ${result.error?.message || 'Unknown error'}`)
  }

  return new Response(
    JSON.stringify({ 
      success: true, 
      paymentMethod: result 
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// ✅ Create PaymentMethod
async function createPaymentMethod(data: any) {
  const { cardNumber, expiryMonth, expiryYear, cvv, cardholderName } = data
  
  console.log('🔍 DEBUG: Creating PaymentMethod with data:', {
    cardNumber: cardNumber?.replace(/\d(?=\d{4})/g, "*"), // Mask card number
    expiryMonth,
    expiryYear,
    cvv: cvv ? "***" : undefined,
    cardholderName
  })

  const response = await fetch(`${STRIPE_API_URL}/payment_methods`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      'type': 'card',
      'card[number]': cardNumber,
      'card[exp_month]': expiryMonth,
      'card[exp_year]': expiryYear,
      'card[cvc]': cvv,
      'billing_details[name]': cardholderName,
    }),
  })

  const result = await response.json()
  console.log('🔍 DEBUG: Stripe PaymentMethod response:', {
    status: response.status,
    success: response.ok,
    id: result.id
  })

  if (!response.ok) {
    throw new Error(`Stripe PaymentMethod Error: ${result.error?.message || 'Unknown error'}`)
  }

  return new Response(
    JSON.stringify({ 
      success: true, 
      paymentMethod: result 
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// ✅ Create Customer
async function createCustomer(data: any) {
  const { email, name, phone } = data
  
  console.log('🔍 DEBUG: Creating Customer with data:', { email, name, phone })

  const response = await fetch(`${STRIPE_API_URL}/customers`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      'email': email,
      ...(name && { 'name': name }),
      ...(phone && { 'phone': phone }),
    }),
  })

  const result = await response.json()
  console.log('🔍 DEBUG: Stripe Customer response:', {
    status: response.status,
    success: response.ok,
    id: result.id
  })

  if (!response.ok) {
    throw new Error(`Stripe Customer Error: ${result.error?.message || 'Unknown error'}`)
  }

  return new Response(
    JSON.stringify({ 
      success: true, 
      customer: result 
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// ✅ Attach PaymentMethod to Customer
async function attachPaymentMethod(data: any) {
  const { customerId, paymentMethodId } = data
  
  console.log('🔍 DEBUG: Attaching PaymentMethod to Customer:', {
    customerId,
    paymentMethodId
  })

  const response = await fetch(`${STRIPE_API_URL}/payment_methods/${paymentMethodId}/attach`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      'customer': customerId,
    }),
  })

  const result = await response.json()
  console.log('🔍 DEBUG: Stripe Attach PaymentMethod response:', {
    status: response.status,
    success: response.ok,
    id: result.id
  })

  if (!response.ok) {
    throw new Error(`Stripe Attach PaymentMethod Error: ${result.error?.message || 'Unknown error'}`)
  }

  return new Response(
    JSON.stringify({ 
      success: true, 
      paymentMethod: result 
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// ✅ Create PaymentIntent
async function createPaymentIntent(data: any) {
  const { amount, currency, customerId, paymentMethodId, billingDetails } = data
  
  console.log('🔍 DEBUG: Creating PaymentIntent with data:', {
    amount,
    currency,
    customerId,
    paymentMethodId,
    billingDetails: billingDetails ? 'Present' : 'Not provided'
  })

  const body: any = {
    'amount': Math.round(amount * 100), // Convert to cents
    'currency': currency || 'usd',
    'confirm': 'true',
    'return_url': 'landgotravel://payment-return',
  }

  if (customerId) body['customer'] = customerId
  if (paymentMethodId) body['payment_method'] = paymentMethodId

  // Add billing details if provided
  if (billingDetails) {
    console.log('🔍 DEBUG: Adding billing details to PaymentIntent')
    if (billingDetails.email) body['receipt_email'] = billingDetails.email
    if (billingDetails.phone || billingDetails.address) {
      body['shipping'] = {
        name: billingDetails.name || 'Customer',
        phone: billingDetails.phone,
        address: {
          line1: billingDetails.address?.line1,
          line2: billingDetails.address?.line2,
          city: billingDetails.address?.city,
          state: billingDetails.address?.state,
          postal_code: billingDetails.address?.postal_code,
          country: billingDetails.address?.country,
        }
      }
    }
  }

  const response = await fetch(`${STRIPE_API_URL}/payment_intents`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams(body),
  })

  const result = await response.json()
  console.log('🔍 DEBUG: Stripe PaymentIntent response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status
  })

  if (!response.ok) {
    console.error('❌ Stripe PaymentIntent Error:', result.error)
    throw new Error(`Stripe PaymentIntent Error: ${result.error?.message || 'Unknown error'}`)
  }

  return new Response(
    JSON.stringify({ 
      success: true, 
      paymentIntent: result 
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// ✅ Confirm Payment
async function confirmPayment(data: any) {
  const { paymentIntentId, paymentMethodId } = data
  
  console.log('🔍 DEBUG: Confirming Payment with data:', {
    paymentIntentId,
    paymentMethodId
  })

  const response = await fetch(`${STRIPE_API_URL}/payment_intents/${paymentIntentId}/confirm`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      'payment_method': paymentMethodId,
    }),
  })

  const result = await response.json()
  console.log('🔍 DEBUG: Stripe Confirm Payment response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status
  })

  if (!response.ok) {
    throw new Error(`Stripe Confirm Payment Error: ${result.error?.message || 'Unknown error'}`)
  }

  return new Response(
    JSON.stringify({ 
      success: true, 
      paymentIntent: result 
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// Validate Card with SetupIntent (no charge)
async function validateCard(data: any) {
  const { paymentMethodId } = data
  
  console.log('🔍 DEBUG: Validating card with SetupIntent:', {
    paymentMethodId
  })

  const response = await fetch(`${STRIPE_API_URL}/setup_intents`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      'payment_method': paymentMethodId,
      'confirm': 'true',
      'usage': 'off_session',
    }),
  })

  const result = await response.json()
  console.log('🔍 DEBUG: Stripe SetupIntent response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    status: result.status
  })

  if (!response.ok) {
    throw new Error(`Stripe SetupIntent Error: ${result.error?.message || 'Unknown error'}`)
  }

  return new Response(
    JSON.stringify({ 
      success: true, 
      setupIntent: result 
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// 🆕 KLARNA FUNCTIONS

// ✅ Create Klarna Session
async function createKlarnaSession(data: any) {
  const { amount, currency, customerId, billingDetails } = data
  
  console.log('🔍 DEBUG: Creating Klarna session with data:', {
    amount,
    currency,
    customerId,
    billingDetails: billingDetails ? 'Present' : 'Not provided'
  })

  const body: any = {
    'amount': Math.round(amount * 100), // Convert to cents
    'currency': currency || 'usd',
    'payment_method_types[]': 'klarna',
    'payment_method_data[type]': 'klarna',
    'confirm': 'true',
    'return_url': 'landgotravel://payment-return',
  }

  if (customerId) body['customer'] = customerId

  // Add billing details if provided
  if (billingDetails) {
    console.log('🔍 DEBUG: Adding billing details to Klarna session')
    if (billingDetails.email) body['receipt_email'] = billingDetails.email
    if (billingDetails.phone || billingDetails.address) {
      body['shipping'] = {
        name: billingDetails.name || 'Customer',
        phone: billingDetails.phone,
        address: {
          line1: billingDetails.address?.line1,
          line2: billingDetails.address?.line2,
          city: billingDetails.address?.city,
          state: billingDetails.address?.state,
          postal_code: billingDetails.address?.postal_code,
          country: billingDetails.address?.country,
        }
      }
    }
  }

  const response = await fetch(`${STRIPE_API_URL}/payment_intents`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams(body),
  })

  const result = await response.json()
  console.log('🔍 DEBUG: Stripe Klarna session response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    status: result.status,
    nextAction: result.next_action?.type
  })

  if (!response.ok) {
    console.error('❌ Stripe Klarna session error:', result.error)
    throw new Error(`Stripe Klarna session error: ${result.error?.message || 'Unknown error'}`)
  }

  // Extract redirect URL for Klarna checkout
  const redirectUrl = result.next_action?.redirect_to_url?.url
  if (!redirectUrl) {
    throw new Error('No redirect URL received from Klarna')
  }

  return new Response(
    JSON.stringify({ 
      success: true, 
      paymentIntent: result,
      clientSecret: result.client_secret,
      paymentIntentId: result.id,
      redirectUrl: redirectUrl
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// ✅ Confirm Klarna Payment
async function confirmKlarnaPayment(data: any) {
  const { paymentIntentId } = data
  
  console.log('🔍 DEBUG: Confirming Klarna payment:', { paymentIntentId })

  const response = await fetch(`${STRIPE_API_URL}/payment_intents/${paymentIntentId}`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  })

  const result = await response.json()
  console.log('🔍 DEBUG: Stripe Klarna payment status:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status
  })

  if (!response.ok) {
    throw new Error(`Stripe Klarna payment status error: ${result.error?.message || 'Unknown error'}`)
  }

  return new Response(
    JSON.stringify({ 
      success: true, 
      paymentIntent: result,
      status: result.status
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// 🆕 AFTERPAY FUNCTIONS

// ✅ Create Afterpay Session
async function createAfterpaySession(data: any) {
  const { amount, currency, customerId, billingDetails } = data
  
  console.log('🔍 DEBUG: Creating Afterpay session with data:', {
    amount,
    currency,
    customerId,
    billingDetails: billingDetails ? 'Present' : 'Not provided'
  })

  const body: any = {
    'amount': Math.round(amount * 100), // Convert to cents
    'currency': currency || 'usd',
    'payment_method_types[]': 'afterpay_clearpay',
    'payment_method_data[type]': 'afterpay_clearpay',
    'confirm': 'true',
    'return_url': 'landgotravel://payment-return',
  }

  if (customerId) body['customer'] = customerId

  // Add billing details if provided
  if (billingDetails) {
    console.log('🔍 DEBUG: Adding billing details to Afterpay session')
    if (billingDetails.email) body['receipt_email'] = billingDetails.email
    if (billingDetails.phone || billingDetails.address) {
      body['shipping'] = {
        name: billingDetails.name || 'Customer',
        phone: billingDetails.phone,
        address: {
          line1: billingDetails.address?.line1,
          line2: billingDetails.address?.line2,
          city: billingDetails.address?.city,
          state: billingDetails.address?.state,
          postal_code: billingDetails.address?.postal_code,
          country: billingDetails.address?.country,
        }
      }
    }
  }

  const response = await fetch(`${STRIPE_API_URL}/payment_intents`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams(body),
  })

  const result = await response.json()
  console.log('🔍 DEBUG: Stripe Afterpay session response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    status: result.status,
    nextAction: result.next_action?.type
  })

  if (!response.ok) {
    console.error('❌ Stripe Afterpay session error:', result.error)
    throw new Error(`Stripe Afterpay session error: ${result.error?.message || 'Unknown error'}`)
  }

  // Extract redirect URL for Afterpay checkout
  const redirectUrl = result.next_action?.redirect_to_url?.url
  if (!redirectUrl) {
    throw new Error('No redirect URL received from Afterpay')
  }

  return new Response(
    JSON.stringify({ 
      success: true, 
      paymentIntent: result,
      clientSecret: result.client_secret,
      paymentIntentId: result.id,
      redirectUrl: redirectUrl
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}

// ✅ Confirm Afterpay Payment
async function confirmAfterpayPayment(data: any) {
  const { paymentIntentId } = data
  
  console.log('🔍 DEBUG: Confirming Afterpay payment:', { paymentIntentId })

  const response = await fetch(`${STRIPE_API_URL}/payment_intents/${paymentIntentId}`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  })

  const result = await response.json()
  console.log('🔍 DEBUG: Stripe Afterpay payment status:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status
  })

  if (!response.ok) {
    throw new Error(`Stripe Afterpay payment status error: ${result.error?.message || 'Unknown error'}`)
  }

  return new Response(
    JSON.stringify({ 
      success: true, 
      paymentIntent: result,
      status: result.status
    }),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  )
}