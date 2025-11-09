import '../../core/recommender.dart';

class GenerateRecommendationsUseCase {
  final Recommender recommender;
  GenerateRecommendationsUseCase(this.recommender);

  List<Recommendation> call(dynamic analysisResult) {
    // expects AnalysisResult
    return recommender.generate(analysisResult);
  }
}
