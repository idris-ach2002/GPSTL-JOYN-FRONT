// Démarrage du moteur Flutter ; substitutions résolues par le build.
// Référence : doc/landing/web.md.
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    try {
      // Le runner est disponible après initialisation du moteur.
      const runner = await engineInitializer.initializeEngine();
      await runner.runApp();
    } catch (error) {
      // Le point d’entrée HTML prend en charge l’affichage de l’échec.
      window.dispatchEvent(new Event('joyn-load-error'));
      console.error('JOYN startup failed', error);
    }
  }
}).catch(function (error) {
  window.dispatchEvent(new Event('joyn-load-error'));
  console.error('JOYN loader failed', error);
});
