import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'performance_models.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [PerformanceDataPointSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> savePerformanceData(PerformanceDataPoint data) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.performanceDataPoints.put(data);
    });
  }

  Future<List<PerformanceDataPoint>> getAllPerformanceData() async {
    final isar = await db;
    return await isar.performanceDataPoints.where().sortByTimestamp().findAll();
  }

  Future<List<PerformanceDataPoint>> getRecentPerformanceData(int limit) async {
    final isar = await db;
    return await isar.performanceDataPoints
        .where()
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }

  List<PerformanceDataPoint> getRecentPerformanceDataSync(int limit) {
    final isar = Isar.getInstance();
    if (isar == null) return [];
    return isar.performanceDataPoints
        .where()
        .sortByTimestampDesc()
        .limit(limit)
        .findAllSync();
  }
}
