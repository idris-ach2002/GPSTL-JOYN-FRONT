/// Ancres de la page marketing ; les routes d'authentification restent séparées.
enum LandingSection { hero, features, companies, pricing }
typedef LandingNavigate = void Function(LandingSection section);
