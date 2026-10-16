import 'package:saaf/domain/entities/skin_concern.dart';
import 'package:saaf/domain/entities/skin_type.dart';

/// The four kinds of step in a routine, in the order they are done.
enum ProductCategory { cleanser, treatment, moisturiser, sunscreen }

/// Part of the day a routine is for.
enum RoutineTime { morning, night }

/// A skincare product the routine can suggest. Prices are in Pakistani rupees
/// and only a guide ("as of" the catalogue date): the shop sets the real price.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePkr,
    required this.times,
    this.skinTypes = const {},
    this.targets = const {},
    this.isStrongActive = false,
    this.avoidInPregnancy = false,
    this.fragranceFree = false,
  });

  final String id;
  final String name;
  final ProductCategory category;
  final int pricePkr;

  /// When it can be used (sunscreen: morning only).
  final Set<RoutineTime> times;

  /// Skin types it suits; empty means gentle enough for any.
  final Set<SkinType> skinTypes;

  /// Concerns it helps with.
  final Set<SkinConcern> targets;

  /// A strong active ingredient (retinoid, vitamin C, salicylic acid…): only
  /// suggested to someone with a matching concern, never with sensitive skin or
  /// a prescription treatment.
  final bool isStrongActive;

  /// Usually avoided when pregnant or breastfeeding.
  final bool avoidInPregnancy;

  /// Free of added fragrance (for people who reacted to an ingredient before).
  final bool fragranceFree;

  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
