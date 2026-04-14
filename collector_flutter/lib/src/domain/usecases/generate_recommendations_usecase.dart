import '../../core/recommender.dart';
import '../../core/analyzer.dart';

class GenerateRecommendationsUseCase {
  final Recommender recommender;
  GenerateRecommendationsUseCase(this.recommender);

  List<Recommendation> call(AnalysisResult analysisResult) {
    return recommender.generate(analysisResult);
  }
}
