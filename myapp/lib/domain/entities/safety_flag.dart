/// Things that change which ingredients are suitable. Health-related, so they
/// stay on the device (docs/store-compliance.md) and are only used to filter the
/// routine. Not a diagnosis.
enum SafetyFlag {
  /// Retinoids and some other actives are usually avoided.
  pregnantOrBreastfeeding,

  /// e.g. isotretinoin or a dermatologist's cream: keep the routine gentle and
  /// suggest checking with the prescriber.
  prescriptionTreatment,

  /// A known reaction to fragrance or a specific ingredient.
  ingredientAllergy,
}
