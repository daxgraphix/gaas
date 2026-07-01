import 'package:isar/isar.dart';

part 'performance_models.g.dart';

@collection
class PerformanceDataPoint {
  Id id = Isar.autoIncrement;

  @Index()
  final DateTime timestamp;

  final double accuracy;
  final int averageTime;
  final int streak;
  final double? avgHeatIndex;
  final String? mode;

  PerformanceDataPoint({
    required this.timestamp,
    required this.accuracy,
    required this.averageTime,
    required this.streak,
    this.avgHeatIndex,
    this.mode,
  });
}
