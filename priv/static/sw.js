// PhoenixGym service worker — cache static assets for offline use
const CACHE_NAME = "phoenixgym-v1";

self.addEventListener("install", (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) =>
      cache.addAll([
        "/",
        "/assets/css/app.css",
        "/assets/js/app.js",
        "/images/logo.svg",
        "/manifest.json"
      ])
    )
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k))
      )
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  const { request } = event;
  const url = new URL(request.url);
  // Only cache same-origin GET requests; let LiveView/API go to network
  if (url.origin !== self.location.origin || request.method !== "GET") {
    return;
  }
  if (url.pathname.startsWith("/live") || url.pathname.startsWith("/phoenix")) {
    return;
  }
  // Cache static assets
  if (
    url.pathname.startsWith("/assets/") ||
    url.pathname.startsWith("/images/") ||
    url.pathname === "/manifest.json"
  ) {
    event.respondWith(
      caches.match(request).then((cached) => cached || fetch(request))
    );
  }
});
