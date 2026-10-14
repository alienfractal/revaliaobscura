{{flutter_js}}
{{flutter_build_config}}

// Serve the renderer alongside the app, including on a local development server.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: new URL("canvaskit/", document.baseURI).href,
  },
});
