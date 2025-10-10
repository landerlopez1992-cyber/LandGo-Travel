import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, stripe-signature'
};

const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY') || '';
const STRIPE_WEBHOOK_SECRET = Deno.env.get('STRIPE_WEBHOOK_SECRET') || '';

// ✅ ADMIN CLIENT PARA ACTUALIZAR SUPABASE
const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey);

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    console.log('🔍 [WEBHOOK] Received request');
    
    // Obtener el cuerpo de la petición
    const body = await req.text();
    const signature = req.headers.get('stripe-signature');
    
    console.log('🔍 [WEBHOOK] Body length:', body.length);
    console.log('🔍 [WEBHOOK] Signature exists:', !!signature);
    
    if (!signature) {
      throw new Error('No Stripe signature found');
    }

    // Verificar que viene de Stripe
    const event = await verifyStripeWebhook(body, signature);
    console.log('✅ [WEBHOOK] Event verified:', event.type);

    // Procesar el evento
    await handleWebhookEvent(event);

    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });

  } catch (error) {
    console.error('❌ [WEBHOOK] Error:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});

async function verifyStripeWebhook(body: string, signature: string) {
  const crypto = await import('https://deno.land/std@0.168.0/crypto/mod.ts');
  
  const elements = signature.split(',');
  const timestamp = elements.find(el => el.startsWith('t='))?.split('=')[1];
  const v1 = elements.find(el => el.startsWith('v1='))?.split('=')[1];

  if (!timestamp || !v1) {
    throw new Error('Invalid signature format');
  }

  const payload = `${timestamp}.${body}`;
  const expectedSignature = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(payload + STRIPE_WEBHOOK_SECRET)
  );
  
  const expectedHex = Array.from(new Uint8Array(expectedSignature))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');

  if (expectedHex !== v1) {
    throw new Error('Invalid signature');
  }

  return JSON.parse(body);
}

async function handleWebhookEvent(event: any) {
  console.log('🔄 [WEBHOOK] Processing event:', event.type);

  switch (event.type) {
    case 'customer.subscription.updated':
      await handleSubscriptionUpdated(event.data.object);
      break;
    
    case 'customer.subscription.deleted':
      await handleSubscriptionDeleted(event.data.object);
      break;
    
    case 'customer.subscription.created':
      await handleSubscriptionCreated(event.data.object);
      break;
    
    default:
      console.log('ℹ️ [WEBHOOK] Unhandled event type:', event.type);
  }
}

async function handleSubscriptionUpdated(subscription: any) {
  console.log('🔄 [WEBHOOK] Subscription updated:', subscription.id);
  console.log('🔍 [WEBHOOK] Status:', subscription.status);
  console.log('🔍 [WEBHOOK] Customer:', subscription.customer);

  try {
    // Obtener el customer de Stripe para encontrar el user_id
    const customerResponse = await fetch(`https://api.stripe.com/v1/customers/${subscription.customer}`, {
      headers: { 'Authorization': `Bearer ${STRIPE_SECRET_KEY}` }
    });
    
    if (!customerResponse.ok) {
      throw new Error(`Failed to fetch customer: ${customerResponse.statusText}`);
    }
    
    const customer = await customerResponse.json();
    console.log('🔍 [WEBHOOK] Customer data:', customer);

    // Buscar el user_id en Supabase usando el email del customer
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('profiles')
      .select('id')
      .eq('email', customer.email)
      .single();

    if (profileError || !profile) {
      console.error('❌ [WEBHOOK] Profile not found for email:', customer.email);
      return;
    }

    console.log('✅ [WEBHOOK] Found user:', profile.id);

    // Determinar el tipo de membresía basado en el price_id
    const priceId = subscription.items.data[0].price.id;
    let membershipType = 'Free';
    
    if (priceId.includes('Basic') || priceId.includes('price_1SGVdz2aG6cmZRHQ')) {
      membershipType = 'Basic';
    } else if (priceId.includes('Premium') || priceId.includes('price_1SGVht2aG6cmZRHQ')) {
      membershipType = 'Premium';
    } else if (priceId.includes('VIP') || priceId.includes('price_1SGVjV2aG6cmZRHQ')) {
      membershipType = 'VIP';
    }

    console.log('🔍 [WEBHOOK] Membership type:', membershipType);

    // Actualizar o crear el registro en la tabla memberships
    const membershipData = {
      user_id: profile.id,
      membership_type: membershipType,
      stripe_subscription_id: subscription.id,
      stripe_customer_id: subscription.customer,
      status: subscription.status,
      current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
      current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
      next_billing_date: new Date(subscription.current_period_end * 1000).toISOString(),
      updated_at: new Date().toISOString()
    };

    console.log('🔄 [WEBHOOK] Updating membership:', membershipData);

    const { error: upsertError } = await supabaseAdmin
      .from('memberships')
      .upsert(membershipData, {
        onConflict: 'user_id,stripe_subscription_id'
      });

    if (upsertError) {
      console.error('❌ [WEBHOOK] Error updating membership:', upsertError);
      throw upsertError;
    }

    console.log('✅ [WEBHOOK] Membership updated successfully');

  } catch (error) {
    console.error('❌ [WEBHOOK] Error in handleSubscriptionUpdated:', error);
    throw error;
  }
}

async function handleSubscriptionDeleted(subscription: any) {
  console.log('🔄 [WEBHOOK] Subscription deleted:', subscription.id);

  try {
    // Marcar la membresía como cancelada en Supabase
    const { error } = await supabaseAdmin
      .from('memberships')
      .update({
        status: 'cancelled',
        updated_at: new Date().toISOString()
      })
      .eq('stripe_subscription_id', subscription.id);

    if (error) {
      console.error('❌ [WEBHOOK] Error cancelling membership:', error);
      throw error;
    }

    console.log('✅ [WEBHOOK] Membership cancelled successfully');

  } catch (error) {
    console.error('❌ [WEBHOOK] Error in handleSubscriptionDeleted:', error);
    throw error;
  }
}

async function handleSubscriptionCreated(subscription: any) {
  console.log('🔄 [WEBHOOK] Subscription created:', subscription.id);
  
  // Reutilizar la lógica de actualización
  await handleSubscriptionUpdated(subscription);
}
