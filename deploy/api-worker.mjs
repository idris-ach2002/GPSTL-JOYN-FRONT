export default {
  async fetch(request, env) {
    const upstream = env.JOYN_BACKEND_URL?.trim().replace(/\/+$/, '');
    if (!upstream) {
      return new Response('JOYN_BACKEND_URL manquante', { status: 503 });
    }
    const url = new URL(request.url);
    if (!url.pathname.startsWith('/api/v1/')) return env.ASSETS.fetch(request);
    const headers = new Headers();
    for (const name of ['authorization', 'content-type', 'accept']) {
      if (request.headers.has(name)) headers.set(name, request.headers.get(name));
    }
    const response = await fetch(upstream + url.pathname + url.search, {
      method: request.method, headers, redirect: 'manual',
      body: ['GET', 'HEAD'].includes(request.method) ? undefined : request.body,
    });
    return new Response(response.body, {
      status: response.status,
      headers: {'content-type': response.headers.get('content-type') || 'application/json',
        'cache-control': 'no-store'},
    });
  },
};
