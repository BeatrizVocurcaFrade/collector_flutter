import '../entities/telemetry.dart';
import '../../core/analyzer.dart';

class AnalyzePerformanceUseCase {
  final Analyzer analyzer;
  AnalyzePerformanceUseCase(this.analyzer);

  AnalysisResult call(Telemetry telemetry) {
    return analyzer.analyzeTelemetry(telemetry.model);
  }
}
