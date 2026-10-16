import 'package:saaf/domain/entities/skin_type.dart';

/// Reads the tissue (blotting) test: after washing and waiting, a tissue is
/// pressed on the forehead, nose and cheeks, and the user says where it picked
/// up oil and whether the skin feels tight.
///
/// Oil on the cheeks as well as the T-zone (forehead, nose) is oily skin; oil
/// only in the T-zone is combination; a clean tissue is normal, or dry when the
/// skin feels tight or flaky. Oil on the cheeks only is unusual, so the answer
/// is [SkinType.notSure] (try again another day).
SkinType classifyTissueTest({
  required bool foreheadOil,
  required bool noseOil,
  required bool cheeksOil,
  required bool feelsTight,
}) {
  final tZoneOil = foreheadOil || noseOil;
  if (tZoneOil && cheeksOil) return SkinType.oily;
  if (tZoneOil) return SkinType.combination;
  if (cheeksOil) return SkinType.notSure;
  return feelsTight ? SkinType.dry : SkinType.normal;
}
