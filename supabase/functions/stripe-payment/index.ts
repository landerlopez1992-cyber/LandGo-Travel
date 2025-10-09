import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
};

const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY') || 'sk_test_51SBkaB2aG6cmZRHQwkLRrfMl5vR2Id6KhpGGqlbXheXV9FKc21ORQVPEFssJ8OsjA5cYtsHnyRSNhrfGiBzSIoSm00Q1TX4TBI';
const STRIPE_API_URL = 'https://api.stripe.com/v1';

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', {
    headers: corsHeaders
  });

  try {
    const { action, ...data } = await req.json();
    console.log('🔍 action =', action);
    console.log('🔍 data =', JSON.stringify(data, null, 2));

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
      // 🆕 KLARNA ACTIONS
      case 'create_klarna_session':
        return await createKlarnaSession(data);
      case 'confirm_klarna_payment':
        return await confirmKlarnaPayment(data);
      // 🆕 AFTERPAY ACTIONS
      case 'create_afterpay_session':
        return await createAfterpaySession(data);
      case 'confirm_afterpay_payment':
        return await confirmAfterpayPayment(data);
      // 🆕 AFFIRM ACTIONS
      case 'create_affirm_session':
        return await createAffirmSession(data);
      case 'confirm_affirm_payment':
        return await confirmAffirmPayment(data);
      // 🆕 ZIP ACTIONS
      case 'create_zip_session':
        return await createZipSession(data);
      case 'confirm_zip_payment':
        return await confirmZipPayment(data);
      // 🆕 CASH APP ACTIONS
      case 'create_cashapp_session':
        return await createCashAppSession(data);
      case 'confirm_cashapp_payment':
        return await confirmCashAppPayment(data);
      case 'test_edge_function':
        return await testEdgeFunction();
      default:
        throw new Error(`Unknown action: ${action}`);
    }
  } catch (error) {
    console.error('❌ EDGE ERROR:', error);
    return json({
      success: false,
      error: String(error?.message ?? error)
    }, 400);
  }
});

/* ========== COMMON ========== */
function json(payload, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json'
    }
  });
}

/* ========== CORE APIS ========== */
async function createPaymentMethod(data) {
  const { cardNumber, expiryMonth, expiryYear, cvv, cardholderName } = data;
  const res = await fetch(`${STRIPE_API_URL}/payment_methods`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      'type': 'card',
      'card[number]': cardNumber,
      'card[exp_month]': String(expiryMonth),
      'card[exp_year]': String(expiryYear),
      'card[cvc]': cvv ?? '',
      'billing_details[name]': cardholderName ?? ''
    })
  });
  const result = await res.json();
  if (!res.ok) throw new Error(result?.error?.message ?? 'Stripe PaymentMethod error');
  return json({
    success: true,
    paymentMethod: result
  });
}

async function createCustomer(data) {
  const { email, name, phone } = data;
  const res = await fetch(`${STRIPE_API_URL}/customers`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      ...email ? {
        'email': email
      } : {},
      ...name ? {
        'name': name
      } : {},
      ...phone ? {
        'phone': phone
      } : {}
    })
  });
  const result = await res.json();
  if (!res.ok) throw new Error(result?.error?.message ?? 'Stripe Customer error');
  return json({
    success: true,
    customer: result
  });
}

async function attachPaymentMethod(data) {
  const { customerId, paymentMethodId } = data;
  const res = await fetch(`${STRIPE_API_URL}/payment_methods/${paymentMethodId}/attach`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      'customer': customerId
    })
  });
  const result = await res.json();
  if (!res.ok) throw new Error(result?.error?.message ?? 'Stripe Attach error');
  return json({
    success: true,
    paymentMethod: result
  });
}

async function createPaymentIntent(data) {
  const { amount, currency, customerId, paymentMethodId, billingDetails } = data;
  const body = {
    'amount': String(Math.round(Number(amount) * 100)),
    'currency': currency || 'usd',
    'confirm': 'true',
    'return_url': 'https://landgotravel.com/payment/return'
  };
  if (customerId) body['customer'] = customerId;
  if (paymentMethodId) body['payment_method'] = paymentMethodId;
  if (billingDetails) {
    if (billingDetails.email) body['receipt_email'] = billingDetails.email;
    const a = billingDetails.address || {};
    body['shipping[name]'] = billingDetails.email || 'Customer';
    if (billingDetails.phone) body['shipping[phone]'] = billingDetails.phone;
    if (a.line1) body['shipping[address][line1]'] = a.line1;
    if (a.line2) body['shipping[address][line2]'] = a.line2;
    if (a.city) body['shipping[address][city]'] = a.city;
    if (a.state) body['shipping[address][state]'] = a.state;
    if (a.postal_code) body['shipping[address][postal_code]'] = a.postal_code;
    if (a.country) body['shipping[address][country]'] = a.country;
  }
  const res = await fetch(`${STRIPE_API_URL}/payment_intents`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams(body)
  });
  const result = await res.json();
  if (!res.ok) throw new Error(result?.error?.message ?? 'Stripe PaymentIntent error');
  return json({
    success: true,
    paymentIntent: result
  });
}

async function confirmPayment(data) {
  const { paymentIntentId, paymentMethodId } = data;
  const res = await fetch(`${STRIPE_API_URL}/payment_intents/${paymentIntentId}/confirm`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      'payment_method': paymentMethodId
    })
  });
  const result = await res.json();
  if (!res.ok) throw new Error(result?.error?.message ?? 'Stripe Confirm error');
  return json({
    success: true,
    paymentIntent: result
  });
}

async function listPaymentMethods(data) {
  const { customerId } = data;
  if (!customerId) throw new Error('Customer ID is required');
  const res = await fetch(`${STRIPE_API_URL}/payment_methods?customer=${customerId}&type=card`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/json'
    }
  });
  const result = await res.json();
  if (!res.ok) throw new Error(result?.error?.message ?? 'Stripe List error');
  return json({
    success: true,
    paymentMethods: result.data ?? []
  });
}

async function detachPaymentMethod(data) {
  const { paymentMethodId } = data;
  if (!paymentMethodId) throw new Error('Payment Method ID is required');
  const res = await fetch(`${STRIPE_API_URL}/payment_methods/${paymentMethodId}/detach`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  });
  const result = await res.json();
  if (!res.ok) throw new Error(result?.error?.message ?? 'Stripe Detach error');
  return json({
    success: true,
    paymentMethod: result
  });
}

/* ========== KLARNA ========== */
// Crea PaymentIntent para Klarna y devuelve la URL de redirección oficial de Stripe.
async function createKlarnaSession(data) {
  const { amount, currency, customerId, userId, billingDetails } = data;
  console.log('🔍 DEBUG: Creating Klarna session for customer:', customerId, 'amount:', amount);

  const body: any = {
    'amount': Math.round(Number(amount) * 100), // Convert to cents
    'currency': currency || 'usd',
    'payment_method_types[]': 'klarna',
    'payment_method_data[type]': 'klarna',
    'confirm': 'true',
    'return_url': 'landgotravel://payment-return', // Deep link for app return
  };

  if (customerId) body['customer'] = customerId;
  if (userId) body['metadata[user_id]'] = userId;
  body['metadata[payment_type]'] = 'klarna_wallet_topup';
  if (billingDetails?.email) body['receipt_email'] = billingDetails.email;

  // 🆕 AGREGAR BILLING DETAILS (igual que Afterpay)
  if (billingDetails) {
    const name = billingDetails.name ?? billingDetails.full_name ?? billingDetails.fullName;
    if (name) body['payment_method_data[billing_details][name]'] = String(name);

    if (billingDetails.email) body['payment_method_data[billing_details][email]'] = String(billingDetails.email);
    if (billingDetails.phone) body['payment_method_data[billing_details][phone]'] = String(billingDetails.phone);

    const addr = billingDetails.address || {};
    if (addr.line1) body['payment_method_data[billing_details][address][line1]'] = String(addr.line1);
    if (addr.line2) body['payment_method_data[billing_details][address][line2]'] = String(addr.line2);
    if (addr.city) body['payment_method_data[billing_details][address][city]'] = String(addr.city);
    if (addr.state) body['payment_method_data[billing_details][address][state]'] = String(addr.state);
    if (addr.postal_code) body['payment_method_data[billing_details][address][postal_code]'] = String(addr.postal_code);

    // Country must be 2-letter code; sanitize common variants
    if (addr.country) {
      const raw = String(addr.country).trim();
      const map: Record<string,string> = {
        'USA': 'US', 
        'United States': 'US', 
        'United States of America': 'US',
        'Estados Unidos': 'US',
        'EEUU': 'US',
        'EE.UU.': 'US',
        'México': 'MX', 
        'Mexico': 'MX',
        'Canada': 'CA', 
        'Canadá': 'CA',
        'CAN': 'CA',
        'United Kingdom': 'GB',
        'Reino Unido': 'GB',
        'UK': 'GB'
      };
      const country = map[raw] || (raw.length === 2 ? raw.toUpperCase() : undefined);
      if (country) {
        body['payment_method_data[billing_details][address][country]'] = country;
        console.log('🔍 DEBUG: Country converted:', raw, '→', country);
      } else {
        console.log('⚠️ WARNING: Unknown country format:', raw);
      }
    }
  }
  
  const res = await fetch(`${STRIPE_API_URL}/payment_intents`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams(body)
  });
  const result = await res.json();
  const redirectUrl = result?.next_action?.redirect_to_url?.url ?? null;
  console.log('🔗 Klarna next_action:', result?.next_action?.type, ' url=', redirectUrl);
  if (!res.ok) throw new Error(result?.error?.message ?? 'Stripe Klarna Session error');
  return json({
    success: true,
    paymentIntentId: result.id,
    clientSecret: result.client_secret,
    status: result.status,
    amount: (result.amount ?? 0) / 100,
    redirectUrl
  });
}

async function confirmKlarnaPayment(data) {
  const { paymentIntentId } = data;
  if (!paymentIntentId) throw new Error('Payment Intent ID is required');
  const res = await fetch(`${STRIPE_API_URL}/payment_intents/${paymentIntentId}`, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/json'
    }
  });
  const result = await res.json();
  if (!res.ok) throw new Error(result?.error?.message ?? 'Stripe Klarna Confirm error');
  return json({
    success: true,
    paymentIntent: result,
    status: result.status,
    amount: (result.amount ?? 0) / 100,
    metadata: result.metadata
  });
}

/* ========== AFTERPAY ========== */
// 🆕 Create Afterpay Session
async function createAfterpaySession(data) {
  const { amount, customerId, userId, billingDetails } = data;
  console.log('🔍 DEBUG: Creating Afterpay session for customer:', customerId, 'amount:', amount);

  const body: any = {
    'amount': Math.round(Number(amount) * 100), // Convert to cents
    'currency': 'usd',
    'payment_method_types[]': 'afterpay_clearpay',
    'payment_method_data[type]': 'afterpay_clearpay',
    'confirm': 'true',
    'return_url': 'landgotravel://payment-return', // Deep link for app return
  };

  if (customerId) body['customer'] = customerId;
  if (userId) body['metadata[user_id]'] = userId;
  body['metadata[payment_type]'] = 'afterpay_wallet_topup';
  if (billingDetails?.email) body['receipt_email'] = billingDetails.email;

  // Map billing details (required: name)
  if (billingDetails) {
    const name = billingDetails.name ?? billingDetails.full_name ?? billingDetails.fullName;
    if (name) body['payment_method_data[billing_details][name]'] = String(name);

    if (billingDetails.email) body['payment_method_data[billing_details][email]'] = String(billingDetails.email);
    if (billingDetails.phone) body['payment_method_data[billing_details][phone]'] = String(billingDetails.phone);

    const addr = billingDetails.address || {};
    if (addr.line1) body['payment_method_data[billing_details][address][line1]'] = String(addr.line1);
    if (addr.line2) body['payment_method_data[billing_details][address][line2]'] = String(addr.line2);
    if (addr.city) body['payment_method_data[billing_details][address][city]'] = String(addr.city);
    if (addr.state) body['payment_method_data[billing_details][address][state]'] = String(addr.state);
    if (addr.postal_code) body['payment_method_data[billing_details][address][postal_code]'] = String(addr.postal_code);

    // Country must be 2-letter code; sanitize common variants
    if (addr.country) {
      const raw = String(addr.country).trim();
      const map: Record<string,string> = {
        'USA': 'US', 
        'United States': 'US', 
        'United States of America': 'US',
        'Estados Unidos': 'US', // Added Spanish
        'EEUU': 'US',
        'EE.UU.': 'US',
        'México': 'MX', 
        'Mexico': 'MX',
        'Canada': 'CA', 
        'Canadá': 'CA',
        'CAN': 'CA',
        'United Kingdom': 'GB',
        'Reino Unido': 'GB',
        'UK': 'GB'
      };
      const country = map[raw] || (raw.length === 2 ? raw.toUpperCase() : undefined);
      if (country) {
        body['payment_method_data[billing_details][address][country]'] = country;
        console.log('🔍 DEBUG: Country converted:', raw, '→', country);
      } else {
        console.log('⚠️ WARNING: Unknown country format:', raw);
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
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe Afterpay PaymentIntent response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status,
    nextAction: result.next_action,
  });

  if (!response.ok) {
    throw new Error(`Stripe Afterpay Session Error: ${result.error?.message || 'Unknown error'}`);
  }

  const redirectUrl = result?.next_action?.redirect_to_url?.url ?? null;
  console.log('🔗 Afterpay next_action:', result?.next_action?.type, ' url=', redirectUrl);

  return json({
    success: true,
    paymentIntentId: result.id,
    clientSecret: result.client_secret,
    status: result.status,
    amount: (result.amount ?? 0) / 100,
    redirectUrl
  });
}

// 🆕 Confirm Afterpay Payment
async function confirmAfterpayPayment(data) {
  const { paymentIntentId } = data;
  console.log('🔍 DEBUG: Confirming Afterpay PaymentIntent:', paymentIntentId);

  const response = await fetch(`${STRIPE_API_URL}/payment_intents/${paymentIntentId}`, {
    method: 'GET', // GET para obtener el estado actual
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
    },
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe Confirm Afterpay Payment response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status
  });

  if (!response.ok) {
    throw new Error(`Stripe Confirm Afterpay Payment Error: ${result.error?.message || 'Unknown error'}`);
  }

  return json({
    success: true,
    paymentIntent: result,
    status: result.status,
    amount: (result.amount ?? 0) / 100,
    metadata: result.metadata
  });
}

/* ========== AFFIRM ========== */
// 🆕 Create Affirm Session
async function createAffirmSession(data) {
  const { amount, customerId, userId, billingDetails } = data;
  console.log('🔍 DEBUG: Creating Affirm session for customer:', customerId, 'amount:', amount);

  const body: any = {
    'amount': Math.round(Number(amount) * 100), // Convert to cents
    'currency': 'usd',
    'payment_method_types[]': 'affirm',
    'payment_method_data[type]': 'affirm',
    'confirm': 'true',
    'return_url': 'landgotravel://payment-return', // Deep link for app return
  };

  if (customerId) body['customer'] = customerId;
  if (userId) body['metadata[user_id]'] = userId;
  body['metadata[payment_type]'] = 'affirm_wallet_topup';
  if (billingDetails?.email) body['receipt_email'] = billingDetails.email;

  // Map billing details (required: name)
  if (billingDetails) {
    const name = billingDetails.name ?? billingDetails.full_name ?? billingDetails.fullName;
    if (name) body['payment_method_data[billing_details][name]'] = String(name);

    if (billingDetails.email) body['payment_method_data[billing_details][email]'] = String(billingDetails.email);
    if (billingDetails.phone) body['payment_method_data[billing_details][phone]'] = String(billingDetails.phone);

    const addr = billingDetails.address || {};
    if (addr.line1) body['payment_method_data[billing_details][address][line1]'] = String(addr.line1);
    if (addr.line2) body['payment_method_data[billing_details][address][line2]'] = String(addr.line2);
    if (addr.city) body['payment_method_data[billing_details][address][city]'] = String(addr.city);
    if (addr.state) body['payment_method_data[billing_details][address][state]'] = String(addr.state);
    if (addr.postal_code) body['payment_method_data[billing_details][address][postal_code]'] = String(addr.postal_code);

    // Country must be 2-letter code; sanitize common variants
    if (addr.country) {
      const raw = String(addr.country).trim();
      const map: Record<string,string> = {
        'USA': 'US', 
        'United States': 'US', 
        'United States of America': 'US',
        'Estados Unidos': 'US', // Added Spanish
        'EEUU': 'US',
        'EE.UU.': 'US',
        'México': 'MX', 
        'Mexico': 'MX',
        'Canada': 'CA', 
        'Canadá': 'CA',
        'CAN': 'CA',
        'United Kingdom': 'GB',
        'Reino Unido': 'GB',
        'UK': 'GB'
      };
      const country = map[raw] || (raw.length === 2 ? raw.toUpperCase() : undefined);
      if (country) {
        body['payment_method_data[billing_details][address][country]'] = country;
        console.log('🔍 DEBUG: Country converted:', raw, '→', country);
      } else {
        console.log('⚠️ WARNING: Unknown country format:', raw);
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
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe Affirm PaymentIntent response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status,
    nextAction: result.next_action,
  });

  if (!response.ok) {
    throw new Error(`Stripe Affirm Session Error: ${result.error?.message || 'Unknown error'}`);
  }

  const redirectUrl = result?.next_action?.redirect_to_url?.url ?? null;
  console.log('🔗 Affirm next_action:', result?.next_action?.type, ' url=', redirectUrl);

  return json({
    success: true,
    paymentIntentId: result.id,
    clientSecret: result.client_secret,
    status: result.status,
    amount: (result.amount ?? 0) / 100,
    redirectUrl
  });
}

// 🆕 Confirm Affirm Payment
async function confirmAffirmPayment(data) {
  const { paymentIntentId } = data;
  console.log('🔍 DEBUG: Confirming Affirm PaymentIntent:', paymentIntentId);

  const response = await fetch(`${STRIPE_API_URL}/payment_intents/${paymentIntentId}`, {
    method: 'GET', // GET para obtener el estado actual
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
    },
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe Confirm Affirm Payment response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status
  });

  if (!response.ok) {
    throw new Error(`Stripe Confirm Affirm Payment Error: ${result.error?.message || 'Unknown error'}`);
  }

  return json({
    success: true,
    paymentIntent: result,
    status: result.status,
    amount: (result.amount ?? 0) / 100,
    metadata: result.metadata
  });
}

/* ========== ZIP ========== */
// 🆕 Create Zip Session
async function createZipSession(data) {
  const { amount, customerId, userId, billingDetails } = data;
  console.log('🔍 DEBUG: Creating Zip session for customer:', customerId, 'amount:', amount);

  const body: any = {
    'amount': Math.round(Number(amount) * 100), // Convert to cents
    'currency': 'usd',
    'payment_method_types[]': 'zip',
    'payment_method_data[type]': 'zip',
    'confirm': 'true',
    'return_url': 'landgotravel://payment-return', // Deep link for app return
  };

  if (customerId) body['customer'] = customerId;
  if (userId) body['metadata[user_id]'] = userId;
  body['metadata[payment_type]'] = 'zip_wallet_topup';
  if (billingDetails?.email) body['receipt_email'] = billingDetails.email;

  // Map billing details (required: name)
  if (billingDetails) {
    const name = billingDetails.name ?? billingDetails.full_name ?? billingDetails.fullName;
    if (name) body['payment_method_data[billing_details][name]'] = String(name);

    if (billingDetails.email) body['payment_method_data[billing_details][email]'] = String(billingDetails.email);
    if (billingDetails.phone) body['payment_method_data[billing_details][phone]'] = String(billingDetails.phone);

    const addr = billingDetails.address || {};
    if (addr.line1) body['payment_method_data[billing_details][address][line1]'] = String(addr.line1);
    if (addr.line2) body['payment_method_data[billing_details][address][line2]'] = String(addr.line2);
    if (addr.city) body['payment_method_data[billing_details][address][city]'] = String(addr.city);
    if (addr.state) body['payment_method_data[billing_details][address][state]'] = String(addr.state);
    if (addr.postal_code) body['payment_method_data[billing_details][address][postal_code]'] = String(addr.postal_code);

    // Country must be 2-letter code; sanitize common variants
    if (addr.country) {
      const raw = String(addr.country).trim();
      const map: Record<string,string> = {
        'USA': 'US', 
        'United States': 'US', 
        'United States of America': 'US',
        'Estados Unidos': 'US', // Added Spanish
        'EEUU': 'US',
        'EE.UU.': 'US',
        'México': 'MX', 
        'Mexico': 'MX',
        'Canada': 'CA', 
        'Canadá': 'CA',
        'CAN': 'CA',
        'United Kingdom': 'GB',
        'Reino Unido': 'GB',
        'UK': 'GB'
      };
      const country = map[raw] || (raw.length === 2 ? raw.toUpperCase() : undefined);
      if (country) {
        body['payment_method_data[billing_details][address][country]'] = country;
        console.log('🔍 DEBUG: Country converted:', raw, '→', country);
      } else {
        console.log('⚠️ WARNING: Unknown country format:', raw);
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
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe Zip PaymentIntent response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status,
    nextAction: result.next_action,
  });

  if (!response.ok) {
    throw new Error(`Stripe Zip Session Error: ${result.error?.message || 'Unknown error'}`);
  }

  const redirectUrl = result?.next_action?.redirect_to_url?.url ?? null;
  console.log('🔗 Zip next_action:', result?.next_action?.type, ' url=', redirectUrl);

  return json({
    success: true,
    paymentIntentId: result.id,
    clientSecret: result.client_secret,
    status: result.status,
    amount: (result.amount ?? 0) / 100,
    redirectUrl
  });
}

// 🆕 Confirm Zip Payment
async function confirmZipPayment(data) {
  const { paymentIntentId } = data;
  console.log('🔍 DEBUG: Confirming Zip PaymentIntent:', paymentIntentId);

  const response = await fetch(`${STRIPE_API_URL}/payment_intents/${paymentIntentId}`, {
    method: 'GET', // GET para obtener el estado actual
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
    },
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe Confirm Zip Payment response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status
  });

  if (!response.ok) {
    throw new Error(`Stripe Confirm Zip Payment Error: ${result.error?.message || 'Unknown error'}`);
  }

  return json({
    success: true,
    paymentIntent: result,
    status: result.status,
    amount: (result.amount ?? 0) / 100,
    metadata: result.metadata
  });
}

/* ========== CASH APP ========== */
// 🆕 Create Cash App Session
async function createCashAppSession(data) {
  const { amount, customerId, userId, billingDetails } = data;
  console.log('🔍 DEBUG: Creating Cash App session for customer:', customerId, 'amount:', amount);

  const body: any = {
    'amount': Math.round(Number(amount) * 100), // Convert to cents
    'currency': 'usd',
    'payment_method_types[]': 'cashapp',
    'payment_method_data[type]': 'cashapp',
    'confirm': 'true',
    'return_url': 'landgotravel://payment-return', // Deep link for app return
  };

  if (customerId) body['customer'] = customerId;
  if (userId) body['metadata[user_id]'] = userId;
  body['metadata[payment_type]'] = 'cashapp_wallet_topup';
  if (billingDetails?.email) body['receipt_email'] = billingDetails.email;

  // Map billing details (required: name)
  if (billingDetails) {
    const name = billingDetails.name ?? billingDetails.full_name ?? billingDetails.fullName;
    if (name) body['payment_method_data[billing_details][name]'] = String(name);

    if (billingDetails.email) body['payment_method_data[billing_details][email]'] = String(billingDetails.email);
    if (billingDetails.phone) body['payment_method_data[billing_details][phone]'] = String(billingDetails.phone);

    const addr = billingDetails.address || {};
    if (addr.line1) body['payment_method_data[billing_details][address][line1]'] = String(addr.line1);
    if (addr.line2) body['payment_method_data[billing_details][address][line2]'] = String(addr.line2);
    if (addr.city) body['payment_method_data[billing_details][address][city]'] = String(addr.city);
    if (addr.state) body['payment_method_data[billing_details][address][state]'] = String(addr.state);
    if (addr.postal_code) body['payment_method_data[billing_details][address][postal_code]'] = String(addr.postal_code);

    // Country must be 2-letter code; sanitize common variants
    if (addr.country) {
      const raw = String(addr.country).trim();
      const map: Record<string,string> = {
        'USA': 'US', 
        'United States': 'US', 
        'United States of America': 'US',
        'Estados Unidos': 'US', // Added Spanish
        'EEUU': 'US',
        'EE.UU.': 'US',
        'México': 'MX', 
        'Mexico': 'MX',
        'Canada': 'CA', 
        'Canadá': 'CA',
        'CAN': 'CA',
        'United Kingdom': 'GB',
        'Reino Unido': 'GB',
        'UK': 'GB'
      };
      const country = map[raw] || (raw.length === 2 ? raw.toUpperCase() : undefined);
      if (country) {
        body['payment_method_data[billing_details][address][country]'] = country;
        console.log('🔍 DEBUG: Country converted:', raw, '→', country);
      } else {
        console.log('⚠️ WARNING: Unknown country format:', raw);
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
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe Cash App PaymentIntent response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status,
    nextAction: result.next_action,
  });

  if (!response.ok) {
    throw new Error(`Stripe Cash App Session Error: ${result.error?.message || 'Unknown error'}`);
  }

  const redirectUrl = result?.next_action?.redirect_to_url?.url ?? null;
  console.log('🔗 Cash App next_action:', result?.next_action?.type, ' url=', redirectUrl);

  return json({
    success: true,
    paymentIntentId: result.id,
    clientSecret: result.client_secret,
    status: result.status,
    amount: (result.amount ?? 0) / 100,
    redirectUrl
  });
}

// 🆕 Confirm Cash App Payment
async function confirmCashAppPayment(data) {
  const { paymentIntentId } = data;
  console.log('🔍 DEBUG: Confirming Cash App PaymentIntent:', paymentIntentId);

  const response = await fetch(`${STRIPE_API_URL}/payment_intents/${paymentIntentId}`, {
    method: 'GET', // GET para obtener el estado actual
    headers: {
      'Authorization': `Bearer ${STRIPE_SECRET_KEY}`,
    },
  });

  const result = await response.json();
  console.log('🔍 DEBUG: Stripe Confirm Cash App Payment response:', {
    status: response.status,
    success: response.ok,
    id: result.id,
    paymentStatus: result.status
  });

  if (!response.ok) {
    throw new Error(`Stripe Confirm Cash App Payment Error: ${result.error?.message || 'Unknown error'}`);
  }

  return json({
    success: true,
    paymentIntent: result,
    status: result.status,
    amount: (result.amount ?? 0) / 100,
    metadata: result.metadata
  });
}

/* ========== TEST ========== */
async function testEdgeFunction() {
  try {
    const ping = await fetch(`${STRIPE_API_URL}/balance`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${STRIPE_SECRET_KEY}`
      }
    });
    const balance = await ping.json();
    return json({
      success: true,
      stripeKeyLoaded: !!STRIPE_SECRET_KEY,
      stripeReachable: ping.ok,
      availableBalance: balance?.available ?? null
    });
  } catch (e) {
    return json({
      success: false,
      error: String(e)
    }, 500);
  }
}