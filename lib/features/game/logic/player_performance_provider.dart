import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/performance/performance_models.dart';
import '../../../core/performance/isar_service.dart';
import '../../../core/providers.dart';
import 'game_session_provider.dart';
import 'session_stats_provider.dart';

class PerformanceTrends {
  final List<PerformanceDataPoint> dataPoints;

  PerformanceTrends({this.dataPoints = const []});

  double get averageAccuracy => dataPoints.isEmpty 
      ? 0.0 
      : dataPoints.map((e) => e.accuracy).reduce((a, b) => a + b) / dataPoints.length;

  double get peakAccuracy => dataPoints.isEmpty
      ? 0.0
      : dataPoints.map((e) => e.accuracy).reduce((a, b) => a > b ? a : b);

  double get averageHeat => dataPoints.isEmpty
      ? 1.0
      : dataPoints.map((e) => e.avgHeatIndex ?? 1.0).reduce((a, b) => a + b) / dataPoints.length;

  List<double> get heatHistory => dataPoints
      .map((e) => e.avgHeatIndex ?? 1.0)
      .toList();

  List<double> get accuracyHistory => dataPoints.map((e) => e.accuracy).toList();

  List<DateTime> get timestamps => dataPoints.map((e) => e.timestamp).toList();
}

class PerformanceTrendsNotifier extends StateNotifier<PerformanceTrends> {
  final IsarService _isarService;
  PerformanceTrendsNotifier(this._isarService) : super(PerformanceTrends()) {
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _isarService.getAllPerformanceData();
    state = PerformanceTrends(dataPoints: data);
  }

  void addDataPoint({
    required double accuracy,
    required int averageTimeMs,
    required int streak,
    double? avgHeatIndex,
    String? mode,
  }) {
    final point = PerformanceDataPoint(
      timestamp: DateTime.now(),
      accuracy: accuracy,
      averageTime: averageTimeMs,
      streak: streak,
      avgHeatIndex: avgHeatIndex,
      mode: mode,
    );
    
    _isarService.savePerformanceData(point);
    state = PerformanceTrends(dataPoints: [...state.dataPoints, point]);
  }
}

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

final performanceTrendsProvider = StateNotifierProvider<PerformanceTrendsNotifier, PerformanceTrends>((ref) {
  final isar = ref.watch(isarServiceProvider);
  return PerformanceTrendsNotifier(isar);
});

final filteredPerformanceTrendsProvider = Provider<PerformanceTrends>((ref) {
  final trends = ref.watch(performanceTrendsProvider);
  final filter = ref.watch(reportsFilterProvider);
  
  if (filter == null) return trends;
  
  final filteredPoints = trends.dataPoints.where((p) {
    if (p.mode == null) return false;
    // Map internal names to match filters if necessary, 
    // but assuming they match for now.
    return p.mode == filter;
  }).toList();
  
  return PerformanceTrends(dataPoints: filteredPoints);
});

class PlayerPerformanceNotifier extends StateNotifier<void> {
  final Ref ref;
  PlayerPerformanceNotifier(this.ref) : super(null);

  void recordAnswer({
    required String operation,
    required bool isCorrect,
    required int responseTimeMs,
    int hintsUsed = 0,
  }) {
    final heatIndex = ref.read(gameSessionProvider)?.heatIndex ?? 1.0;
    final streak = ref.read(sessionStatsProvider).currentStreak;
    
    // For single answers, we treat accuracy as 100 or 0
    ref.read(performanceTrendsProvider.notifier).addDataPoint(
      accuracy: isCorrect ? 100.0 : 0.0,
      averageTimeMs: responseTimeMs,
      streak: streak,
      avgHeatIndex: heatIndex,
      mode: operation,
    );
  }
}

final playerPerformanceProvider = StateNotifierProvider<PlayerPerformanceNotifier, void>((ref) {
  return PlayerPerformanceNotifier(ref);
});
