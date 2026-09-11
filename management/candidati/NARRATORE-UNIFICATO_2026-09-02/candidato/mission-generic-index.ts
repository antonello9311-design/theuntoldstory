import {createClient} from 'jsr:@supabase/supabase-js@2';
import {handleMissionGeneric} from './mission-generic-http.mjs';
import {createResponsesProvider} from './exam_regia17/edge/src/provider.mjs';

export const BUILD = 'mission-generic-ai/2026-09-11.2';
const allowedOrigins = ['https://theuntoldstory.it', 'https://www.theuntoldstory.it'];

// Only the deployed runtime resolves these credentials. Nothing is returned or logged.
// Auth.getUser and the service-only RPC adapter live in the shared HTTP handler.
Deno.serve(async req => {
  try {
    const url = Deno.env.get('SUPABASE_URL') ?? '';
    const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const apiKey = Deno.env.get('OPENAI_API_KEY') ?? '';
    const workerToken = Deno.env.get('MISSION_NARRATIVE_WORKER_TOKEN') ?? '';
    const admin = url && serviceKey
      ? createClient(url, serviceKey, {auth: {persistSession: false, autoRefreshToken: false, detectSessionInUrl: false}})
      : null;
    const provider = apiKey ? createResponsesProvider({apiKey}) : null;
    const response = await handleMissionGeneric(req, {admin, provider, workerToken, allowedOrigins});
    response.headers.set('x-mission-build', BUILD);
    return response;
  } catch {
    // Keep provider, Auth and configuration details out of public errors.
    const headers = new Headers({'content-type': 'application/json', 'cache-control': 'no-store',
      'vary': 'Origin', 'x-mission-build': BUILD});
    const origin = req.headers.get('origin');
    if (origin && allowedOrigins.includes(origin)) headers.set('access-control-allow-origin', origin);
    return new Response(JSON.stringify({code: 'MISSION_SERVICE_UNAVAILABLE', retry: false}), {status: 503, headers});
  }
});
