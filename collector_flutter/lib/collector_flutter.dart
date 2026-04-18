/// collector_flutter — real-time performance monitoring for Flutter apps.
///
/// Tracks frame timings (FPS, jank, P50/P95/P99), memory (RSS and heap),
/// HTTP traffic, and custom events. Analysed by a heuristic engine that
/// generates severity-coded recommendations, all displayed in an embedded
/// [DashboardPage] with no external tools required.
///
/// ## Quick start
///
/// ```dart
/// final collector = ResourceCollector(
///   collectionInterval: const Duration(seconds: 2),
///   budget: const PerformanceBudget(targetFrameRate: 60),
/// );
/// await collector.start();
///
/// // Open dashboard
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => DashboardPage(collector: collector),
/// ));
///
/// // Clean up
/// collector.dispose();
/// ```
library;

export 'src/src.dart';
