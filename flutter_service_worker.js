'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/third_party/Rubik-Medium.ttf": "c87313aa86b7caa31a9a0accaa584970",
"assets/AssetManifest.json": "00f24d554630f186a835f5812e162a9f",
"assets/LICENSE": "bc0089e271413f69bdf30103733e42b3",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/FontManifest.json": "3f80277ff839f9c7cc9a28e80b8966dc",
"main.dart.js": "7d6278aee91c863f5cecc4c319dab38c",
"index.html": "45c19020bbf7611e609836914f4c7f79"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
