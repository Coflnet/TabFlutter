{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    
    // Remove the splash screen
    const splash = document.getElementById('splash');
    if (splash) {
      splash.remove();
    }
    
    await appRunner.runApp();
  }
});
