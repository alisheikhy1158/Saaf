import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:saaf/data/repositories/seed_product_catalog.dart';
import 'package:saaf/domain/entities/ai_routine_plan.dart';
import 'package:saaf/domain/entities/skin_analysis.dart';
import 'package:saaf/domain/entities/skin_metric.dart';
import 'package:saaf/domain/repositories/product_catalog.dart';
import 'package:saaf/presentation/providers/ai_routine_providers.dart';
import 'package:saaf/presentation/providers/analysis_providers.dart';

/// An analysed face scan.
final testAnalysis = SkinAnalysis(
  scanId: 'scan-1',
  takenAt: DateTime(2026, 10, 14),
  metrics: const [SkinMetric(kind: SkinMetricKind.oiliness, amount: 0.6)],
);

/// The routine is only built from an analysed face scan and Saaf AI's
/// options. Tests about something else use this to have one: a scan, and a
/// plan whose options are [catalog]'s products (in its order).
List<Override> aiRoutineFrom([
  ProductCatalog catalog = const SeedProductCatalog(),
]) => [
  skinAnalysisProvider.overrideWith((ref) async => testAnalysis),
  aiRoutinePlanControllerProvider.overrideWithBuild((ref, notifier) async {
    final products = await catalog.all();
    return AiRoutinePlan(
      summary: '',
      picks: [for (final p in products) AiPick(product: p, brand: '', why: '')],
    );
  }),
];
