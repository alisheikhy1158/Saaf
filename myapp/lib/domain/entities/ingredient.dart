/// The active ingredients the app knows how to reason about (clash rules). Not
/// a full ingredient list: just what changes advice.
enum Ingredient {
  niacinamide,
  vitaminC,
  retinol,
  salicylicAcid,
  azelaicAcid,
  hyaluronicAcid,
  benzoylPeroxide,
  zinc,
  ceramides,

  /// Glycolic, lactic and other alpha-hydroxy acids.
  aha;

  /// Chemical exfoliants that irritate when layered with a retinoid.
  bool get isExfoliant => this == salicylicAcid || this == aha;
}
