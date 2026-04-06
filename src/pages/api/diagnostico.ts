import type { APIRoute } from 'astro';
import { runDiagnosis } from '../../lib/prologBridge.js';

export const POST: APIRoute = async ({ request }) => {
  try {
    const data = await request.json();
    const result = await runDiagnosis(data);
    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
};
