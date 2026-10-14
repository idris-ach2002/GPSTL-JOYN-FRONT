/// Sections vers lesquelles la navbar marketing peut naviguer.
///
/// Ces destinations appartiennent uniquement à la landing page.
/// Elles ne représentent pas des routes applicatives.
enum LandingSection {
  hero,
  opportunities,
  howItWorks,
  features,
  companies,
  testimonials,
}

typedef LandingNavigate = void Function(LandingSection section);
