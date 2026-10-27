/* Echipament XCC: ține aplicația în telefon ca să meargă și fără internet.
   Pagina: întâi de pe net (ca să vezi ultima versiune), iar dacă netul lipsește sau e prea lent, din cache.
   Biblioteca Supabase și iconițele: din cache. Fonturile: din cache, actualizate în fundal.
   Cererile către baza de date Supabase nu trec prin cache. */
var VERSION = "xcc-v1";
var CACHE = "xcc-" + VERSION;
var LIB = "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.117.2/dist/umd/supabase.js";
var CORE = [
  "./",
  "./manifest.webmanifest",
  "./icon-192.png",
  "./icon-512.png",
  "./icon-maskable-512.png",
  "./apple-touch-icon.png",
  "./favicon-32.png"
];
var PAGE_TIMEOUT = 3500;

self.addEventListener("install", function(e){
  e.waitUntil(caches.open(CACHE).then(function(c){
    return c.addAll(CORE).then(function(){
      return fetch(LIB, {mode: "cors"}).then(function(r){ if(r.ok) return c.put(LIB, r); }).catch(function(){});
    });
  }).then(function(){ return self.skipWaiting(); }));
});

self.addEventListener("activate", function(e){
  e.waitUntil(caches.keys().then(function(keys){
    return Promise.all(keys.filter(function(k){ return k.indexOf("xcc-") === 0 && k !== CACHE; }).map(function(k){ return caches.delete(k); }));
  }).then(function(){ return self.clients.claim(); }));
});

function pageKey(){ return new URL("./", self.registration.scope).href; }

function fromNetworkThenCache(req){
  return caches.open(CACHE).then(function(c){
    var net = fetch(req).then(function(r){
      if(r && r.ok) c.put(pageKey(), r.clone());
      return r;
    });
    var cached = c.match(pageKey());
    var slow = new Promise(function(res){ setTimeout(res, PAGE_TIMEOUT); }).then(function(){ return cached; });
    /* răspunde cine vine primul: netul, sau cache-ul după 3,5 s; dacă netul pică, imediat cache-ul */
    return Promise.race([
      net.catch(function(){ return cached.then(function(m){ return m || Promise.reject(new Error("offline")); }); }),
      slow.then(function(m){ return m || net; })
    ]);
  });
}

function cacheFirst(req){
  return caches.open(CACHE).then(function(c){
    return c.match(req).then(function(m){
      return m || fetch(req).then(function(r){ if(r && (r.ok || r.type === "opaque")) c.put(req, r.clone()); return r; });
    });
  });
}

function staleWhileRevalidate(req){
  return caches.open(CACHE).then(function(c){
    return c.match(req).then(function(m){
      var net = fetch(req).then(function(r){ if(r && (r.ok || r.type === "opaque")) c.put(req, r.clone()); return r; }).catch(function(){ return m; });
      return m || net;
    });
  });
}

self.addEventListener("fetch", function(e){
  var req = e.request;
  if(req.method !== "GET") return;
  var url = new URL(req.url);
  var scope = new URL(self.registration.scope);

  if(req.mode === "navigate" && url.origin === scope.origin && url.pathname.indexOf(scope.pathname) === 0){
    e.respondWith(fromNetworkThenCache(req));
    return;
  }
  if(url.origin === scope.origin && url.pathname.indexOf(scope.pathname) === 0){
    e.respondWith(cacheFirst(req));
    return;
  }
  if(req.url === LIB){
    e.respondWith(cacheFirst(req));
    return;
  }
  if(url.hostname === "fonts.googleapis.com" || url.hostname === "fonts.gstatic.com"){
    e.respondWith(staleWhileRevalidate(req));
  }
  /* restul (Supabase, magazinele) merge direct pe net */
});
