import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};

// Stripe API configuration
const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY') || 'sk_test_51SBkaB2aG6cmZRHQwkLRrfMl5vR2Id6KhpGGqlbXheXV9FKc21ORQVPEFssJ8OsjA5cYtsHnyRSNhrfGiBzSIoSm00Q1TX4TBI';
const STRIPE_API_URL = 'https://api.stripe.com/v1';

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }

  try {
    // Parse request body
    const { action, ...data } = await req.json();
    console.log('🔍 DEBUG: Stripe Edge Function called with action:', action);
    console.log('🔍 DEBUG: Data received:', JSON.stringify(data, null, 2));

    switch (action) {
      case 'create_customer':
        return await createCustomer(data);
      case 'create_payment_method':
        return await createPaymentMethod(data);
      case 'attach_payment_method':
        return await attachPaymentMethod(data);
      case 'create_payment_intent':
        return await createPaymentIntent(data);
      case 'confirm_payment':
        return await confirmPayment(data);
      case 'list_payment_methods':
        return await listPaymentMethods(data);
      case 'detach_payment_method':
        return await detachPaymentMethod(data);
      default:
        throw new Error(`Unknown action: ${action}`);
    }
  } catch (error) {
    console.error('❌ ERROR in Stripe Edge Function:', error);
    return new Response(JSON.stringify({
      success: false,
      error: error.message
    }), {
      status: 400,
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      }
    });
  }
});

// ✅ Create PaymentMethod
async function createPaymentMethod(data: any) {
  const { cardNumber, expiryMonth, expiryYear, cvv, cardholderName } = data;
  console.log('🔍 DEBUG: Creating PaymentMethod with data:', {
    cardNumber: cardNumber?.replace(/\d(?=\d{4})/g, "*"),
    expiryMonth,
    expiryYear,
    cvv: cvv ? "***" : undefined,
    cardholderName
  });

  const response = await fetch(`${STRIPE_API_URL}/payment_methods`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      'type': 'card',
      'card[number]': cardNumber,
      'card[exp_month]': expiryMonth,
      'card[exp_year]': expiryYear,
      'card[cvc]': cvv,
      'billing_details[name]': cardholderName
    })
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe PaymentMethod response:', {
    status: response.status,
    success: response.ok,
    id: result.id
  });

  if (!response.ok) {
    throw new Error(`Stripe PaymentMethod Error: ${result.error?.message || 'Unknown error'}`);
  }

  return new Response(JSON.stringify({
    success: true,
    paymentMethod: result
  }), {
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json'
    }
  });
}

// ✅ Create Customer
async function createCustomer(data: any) {
  const { email, name, phone } = data;
  console.log('🔍 DEBUG: Creating Customer with data:', {
    email,
    name,
    phone
  });

  const response = await fetch(`${STRIPE_API_URL}/customers`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      'email': email,
      ...name && {
        'name': name
      },
      ...phone && {
        'phone': phone
      }
    })
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe Customer response:', {
    status: response.status,
    success: response.ok,
    id: result.id
  });

  if (!response.ok) {
    throw new Error(`Stripe Customer Error: ${result.error?.message || 'Unknown error'}`);
  }

  return new Response(JSON.stringify({
    success: true,
    customer: result
  }), {
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json'
    }
  });
}

// ✅ Attach PaymentMethod to Customer
async function attachPaymentMethod(data: any) {
  const { customerId, paymentMethodId } = data;
  console.log('🔍 DEBUG: Attaching PaymentMethod to Customer:', {
    customerId,
    paymentMethodId
  });

  const response = await fetch(`${STRIPE_API_URL}/payment_methods/${paymentMethodId}/attach`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      'customer': customerId
    })
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe Attach PaymentMethod response:', {
    status: response.status,
    success: response.ok,
    id: result.id
  });

  if (!response.ok) {
    throw new Error(`Stripe Attach PaymentMethod Error: ${result.error?.message || 'Unknown error'}`);
  }

  return new Response(JSON.stringify({
    success: true,
    paymentMethod: result
  }), {
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json'
    }
  });
}

// ✅ Create PaymentIntent with Billing Details
async function createPaymentIntent(data: any) {
  const { amount, currency, customerId, paymentMethodId, billingDetails } = data;
  console.log('🔍 DEBUG: Creating PaymentIntent with data:', {
    amount,
    currency,
    customerId,
    paymentMethodId,
    billingDetails
  });
  
  const body: any = {
    'amount': Math.round(amount * 100),
    'currency': currency || 'usd',
    'confirm': 'true',
    'return_url': 'https://landgotravel.com/payment/return'
  };
  
  if (customerId) body['customer'] = customerId;
  if (paymentMethodId) body['payment_method'] = paymentMethodId;
  
  // 🔐 Agregar billing details al PaymentIntent
  if (billingDetails) {
    if (billingDetails.email) {
      body['receipt_email'] = billingDetails.email;
    }
    
    // Agregar shipping (Stripe usa shipping para validar billing address)
    if (billingDetails.address) {
      const shippingName = billingDetails.email || 'Customer';
      body['shipping[name]'] = shippingName;
      
      if (billingDetails.phone) {
        body['shipping[phone]'] = billingDetails.phone;
      }
      
      body['shipping[address][line1]'] = billingDetails.address.line1 || '';
      if (billingDetails.address.line2) {
        body['shipping[address][line2]'] = billingDetails.address.line2;
      }
      body['shipping[address][city]'] = billingDetails.address.city || '';
      body['shipping[address][state]'] = billingDetails.address.state || '';
      body['shipping[address][postal_code]'] = billingDetails.address.postal_code || '';
      body['shipping[address][country]'] = billingDetails.address.country || '';
    }
    
    console.log('✅ Billing details added to PaymentIntent');
  }
  
  const response = await fetch(`${STRIPE_API_URL}/payment_intents`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams(body)
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe PaymentIntent response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status,
    hasShipping: !!result.shipping
  });
  
  if (!response.ok) {
    const errorMessage = result.error?.message || 'Unknown error';
    const errorCode = result.error?.code || 'unknown';
    console.error('❌ Stripe PaymentIntent Error:', {
      code: errorCode,
      message: errorMessage,
      decline_code: result.error?.decline_code
    });
    throw new Error(`Stripe PaymentIntent Error: ${errorMessage}`);
  }

  return new Response(JSON.stringify({
    success: true,
    paymentIntent: result
  }), {
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json'
    }
  });
}

// ✅ Confirm Payment
async function confirmPayment(data: any) {
  const { paymentIntentId, paymentMethodId } = data;
  console.log('🔍 DEBUG: Confirming Payment with data:', {
    paymentIntentId,
    paymentMethodId
  });

  const response = await fetch(`${STRIPE_API_URL}/payment_intents/${paymentIntentId}/confirm`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      'payment_method': paymentMethodId
    })
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe Confirm Payment response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status
  });

  if (!response.ok) {
    throw new Error(`Stripe Confirm Payment Error: ${result.error?.message || 'Unknown error'}`);
  }

  return new Response(JSON.stringify({
    success: true,
    paymentIntent: result
  }), {
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json'
    }
  });
}

// ✅ List Payment Methods
async function listPaymentMethods(data: any) {
  const { customerId } = data;
  console.log('🔍 DEBUG: Listing PaymentMethods for Customer:', {
    customerId
  });

  if (!customerId) {
    throw new Error('Customer ID is required');
  }

  const response = await fetch(`${STRIPE_API_URL}/payment_methods?customer=${customerId}&type=card`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/json'
    }
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe List PaymentMethods response:', {
    status: response.status,
    success: response.ok,
    count: result.data?.length || 0
  });

  if (!response.ok) {
    throw new Error(`Stripe List PaymentMethods Error: ${result.error?.message || 'Unknown error'}`);
  }

  return new Response(JSON.stringify({
    success: true,
    paymentMethods: result.data || []
  }), {
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json'
    }
  });
}

// ✅ Detach Payment Method
async function detachPaymentMethod(data: any) {
  const { paymentMethodId } = data;
  console.log('🔍 DEBUG: Detaching PaymentMethod:', {
    paymentMethodId
  });

  if (!paymentMethodId) {
    throw new Error('Payment Method ID is required');
  }

  const response = await fetch(`${STRIPE_API_URL}/payment_methods/${paymentMethodId}/detach`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe Detach PaymentMethod response:', {
    status: response.status,
    success: response.ok,
    id: result.id
  });

  if (!response.ok) {
    throw new Error(`Stripe Detach PaymentMethod Error: ${result.error?.message || 'Unknown error'}`);
  }

  return new Response(JSON.stringify({
    success: true,
    paymentMethod: result
  }), {
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json'
    }
  });
}

