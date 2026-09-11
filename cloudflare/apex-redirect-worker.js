// Cloudflare Worker bound to route: bubluestudio.com/*
// Requires a proxied (orange-cloud) placeholder DNS record at the apex:
//   AAAA  @  100::  (Proxied)
//
// Behaviour:
//   - GET /app-ads.txt        -> returns the app-ads.txt body directly (200, text/plain)
//                                so ad crawlers can read it without following a cross-domain redirect
//   - everything else on apex -> 301 redirect to https://beyondgod.bubluestudio.com<same path+query>
//
// The canonical app-ads.txt also lives at the web root of this repo
// (served at https://beyondgod.bubluestudio.com/app-ads.txt) — keep the two in sync.
export default {
  async fetch(request) {
    const url = new URL(request.url);

    if (url.pathname === "/app-ads.txt") {
      return new Response(
        "google.com, pub-9427505016327818, DIRECT, f08c47fec0942fa0\n",
        { headers: { "content-type": "text/plain; charset=utf-8" } }
      );
    }

    return Response.redirect(
      "https://beyondgod.bubluestudio.com" + url.pathname + url.search,
      301
    );
  },
};
