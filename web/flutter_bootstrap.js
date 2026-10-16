{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    try {
      const runner = await engineInitializer.initializeEngine();
      await runner.runApp();
    } catch (error) {
      window.dispatchEvent(new Event('joyn-load-error'));
      console.error('JOYN startup failed', error);
    }
  }
}).catch(function (error) {
  window.dispatchEvent(new Event('joyn-load-error'));
  console.error('JOYN loader failed', error);
});
