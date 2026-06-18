import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers.dart';
import '../../core/themes/app_themes.dart';
import '../../l10n/generated/app_localizations.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accuracy = ref.watch(overallAccuracyProvider);
    final totalStars = ref.watch(totalStarsProvider);
    final completedLevels = ref.watch(completedLevelsProvider);
    final totalTime = ref.watch(totalTimePlayedProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context, theme, l10n, ref),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  Widget? child;
                  switch (index) {
                    case 0:
                      child = _buildOverviewCards(theme, totalStars, completedLevels, totalTime, accuracy, l10n);
                      break;
                    case 1:
                      child = const SizedBox(height: 32);
                      break;
                    case 2:
                      child = _buildPerformanceAnalytics(context, theme, accuracy, totalTime, l10n);
                      break;
                    case 3:
                      child = const SizedBox(height: 32);
                      break;
                    case 4:
                      child = _buildLevelMastery(context, theme, ref, l10n);
                      break;
                    case 5:
                      child = const SizedBox(height: 32);
                      break;
                    case 6:
                      child = _buildPerformanceInsights(context, theme, l10n);
                      break;
                  }
                  
                  if (child == null) return null;
                  
                  return child.animate()
                      .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                      .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
                },
                childCount: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme, AppLocalizations l10n, WidgetRef ref) {
    return AppBar(
      title: Text(l10n.reports),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.more_vert,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          onPressed: () => _showExportOptions(context, ref, l10n),
          tooltip: 'Export Options',
        ),
      ],
    );
  }

  Widget _buildOverviewCards(
    ThemeData theme,
    AsyncValue<int> totalStars,
    AsyncValue<int> completedLevels,
    AsyncValue<int> totalTime,
    AsyncValue<double> accuracy,
    AppLocalizations l10n,
  ) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.performanceOverview,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.starsEarned,
                  totalStars.value?.toString() ?? '0',
                  Icons.star,
                  theme.colorScheme.primary,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.levelsCompleted,
                  completedLevels.value?.toString() ?? '0',
                  Icons.flag,
                  theme.colorScheme.secondary,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.accuracy,
                  '${accuracy.value?.toStringAsFixed(1) ?? '0'}%',
                  Icons.trending_up,
                  theme.colorScheme.tertiary,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.timePlayed,
                  '${(totalTime.value ?? 0) ~/ 60}h ${(totalTime.value ?? 0) % 60}m',
                  Icons.timer,
                  theme.colorScheme.error,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withValues(alpha: 0.2),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceAnalytics(
    BuildContext context,
    ThemeData theme,
    AsyncValue<double> accuracy,
    AsyncValue<int> totalTime,
    AppLocalizations l10n,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final stats = ref.watch(sessionStatsProvider);
        final trends = ref.watch(performanceTrendsProvider);
        final bestStreak = ref.watch(bestStreakProvider);

        return RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.performanceAnalytics,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              PremiumCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.currentSession,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricItem(l10n.accuracy, '${accuracy.value?.toStringAsFixed(1) ?? '0'}%', theme),
                        _buildMetricItem(l10n.time, '${(totalTime.value ?? 0) ~/ 60}m', theme),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Colors.white10),
                    const SizedBox(height: 20),
                    Text(
                      l10n.realTimeStats,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniStat(l10n.questions, '${stats.questionsAnswered}', theme),
                        _buildMiniStat(l10n.correct, '${stats.correctAnswers}', theme),
                        _buildMiniStat(l10n.bestStreak, '${bestStreak.value ?? 0}', theme),
                        _buildMiniStat(l10n.sessions, '${trends.accuracyHistory.length}', theme),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelMastery(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final analytics = ref.watch(analyticsProvider);
        final progressMap = ref.watch(levelProgressProvider);
        
        return RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.levelMasteryBreakdown,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              PremiumCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (progressMap.isNotEmpty) ...[
                      ...progressMap.entries.map((entry) {
                        final operation = entry.key;
                        final levels = entry.value;
                        final completed = levels.where((level) => level.stars > 0).length;
                        final unlocked = levels.where((level) => level.isUnlocked).length;
                        final totalStarsEarned = levels.fold<int>(0, (sum, level) => sum + level.stars);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                operation.toUpperCase(),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: AppDesignTokens.neonYellow),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$totalStarsEarned',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 12),
                                  Text('$completed/${levels.length}'),
                                  const SizedBox(width: 8),
                                  Text(
                                    '($unlocked ${l10n.unlocked})',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else ...[
                      Center(child: Text(l10n.noProgressDataAvailable)),
                    ],
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Colors.white10),
                    const SizedBox(height: 16),
                    Text(
                      l10n.gameModeDistribution,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...analytics.operationUsage.entries.map((entry) {
                      final mode = entry.key;
                      final count = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(mode.toUpperCase(), style: theme.textTheme.bodyMedium),
                            Text(
                              '$count ${l10n.sessions}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceInsights(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final trends = ref.watch(performanceTrendsProvider);
        final stats = ref.watch(sessionStatsProvider);
        
        return RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.performanceInsights,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              PremiumCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInsightRow(
                      l10n.bestAccuracy,
                      '${trends.peakAccuracy.toStringAsFixed(1)}%',
                      Icons.arrow_upward,
                      theme.colorScheme.primary,
                      theme,
                    ),
                    const SizedBox(height: 16),
                    _buildInsightRow(
                      l10n.averageResponseTime,
                      '${stats.timeSpent > 0 && stats.questionsAnswered > 0 
                          ? (stats.timeSpent / stats.questionsAnswered).toStringAsFixed(0) 
                          : '0'}s',
                      Icons.timer,
                      theme.colorScheme.secondary,
                      theme,
                    ),
                    const SizedBox(height: 16),
                    _buildInsightRow(
                      l10n.completionRate,
                      stats.questionsAnswered > 0 
                          ? '${(stats.correctAnswers / stats.questionsAnswered * 100).toStringAsFixed(1)}%'
                          : '0%',
                      Icons.check_circle,
                      theme.colorScheme.tertiary,
                      theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightRow(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  void _showExportOptions(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PremiumGlassOverlay(
        borderRadius: 32,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    Icons.ios_share_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.exportReport,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildExportOption(
              context: context,
              icon: Icons.picture_as_pdf_rounded,
              title: l10n.exportAsPdf,
              subtitle: l10n.generateDetailedPdfReport,
              onTap: () => _shareAsPdf(context, ref, l10n),
              theme: theme,
            ),
            _buildExportOption(
              context: context,
              icon: Icons.image_rounded,
              title: l10n.shareAsImage,
              subtitle: l10n.captureHighQualityImage,
              onTap: () => _exportAsImage(context, ref, l10n),
              theme: theme,
            ),
            _buildExportOption(
              context: context,
              icon: Icons.print_rounded,
              title: l10n.printReport,
              subtitle: l10n.sendReportToPrinter,
              onTap: () => _printReport(context, ref, l10n),
              theme: theme,
            ),
            _buildExportOption(
              context: context,
              icon: Icons.save_rounded,
              title: l10n.saveToDevice,
              subtitle: l10n.savePdfToDeviceStorage,
              onTap: () => _saveToDevice(context, ref, l10n),
              theme: theme,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsImage(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.generatingImage),
          duration: Duration(seconds: 2),
        ),
      );

      final boundaryKey = GlobalKey();

      final overlayEntry = OverlayEntry(
        builder: (context) => Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: RepaintBoundary(
                key: boundaryKey,
                child: _buildReportContentForImage(context, ref, l10n),
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(overlayEntry);

      await Future.delayed(const Duration(milliseconds: 500));

      final renderObject = boundaryKey.currentContext!.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        overlayEntry.remove();
        throw 'Could not find render object';
      }

      final image = await renderObject.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      overlayEntry.remove();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/gaas_report_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      if (!context.mounted) return;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: l10n.performanceReportTitle,
        subject: 'Mathematics Learning Progress',
      );

      Future.delayed(const Duration(seconds: 10), () {
        if (file.existsSync()) file.deleteSync();
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.imageSharedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.imageExportFailed}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildReportContentForImage(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final user = ref.read(userSessionProvider);
    final accuracy = ref.read(overallAccuracyProvider);
    final totalStars = ref.read(totalStarsProvider);
    final completedLevels = ref.read(completedLevelsProvider);
    final totalTime = ref.read(totalTimePlayedProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.performanceReportTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Generated on ${DateTime.now().toString().split('.')[0]}',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        if (user != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${l10n.playerLabel}: ${user.name}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
        _buildStatCardForImage(l10n.starsEarned, '${totalStars.value ?? 0}', Icons.star, theme.colorScheme.primary, theme),
        const SizedBox(height: 12),
        _buildStatCardForImage(l10n.levelsCompleted, '${completedLevels.value ?? 0}', Icons.flag, theme.colorScheme.secondary, theme),
        const SizedBox(height: 12),
        _buildStatCardForImage(l10n.accuracy, '${accuracy.value?.toStringAsFixed(1) ?? '0'}%', Icons.trending_up, theme.colorScheme.tertiary, theme),
        const SizedBox(height: 12),
        _buildStatCardForImage(l10n.timePlayed, '${(totalTime.value ?? 0) ~/ 60}h ${(totalTime.value ?? 0) % 60}m', Icons.timer, theme.colorScheme.error, theme),
        const SizedBox(height: 24),
        Text(
          'gaas-math.app',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCardForImage(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printReport(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.preparingDocument),
          duration: Duration(seconds: 2),
        ),
      );

      final user = ref.read(userSessionProvider);
      final accuracy = ref.read(overallAccuracyProvider);
      final totalStars = ref.read(totalStarsProvider);
      final completedLevels = ref.read(completedLevelsProvider);
      final totalTime = ref.read(totalTimePlayedProvider);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'GAAS Performance Report',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Generated on ${DateTime.now().toString().split('.')[0]}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
                pw.SizedBox(height: 20),
                if (user != null) ...[
                  pw.Text('${l10n.playerLabel}: ${user.name}', style: pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 10),
                ],
                pw.Divider(),
                pw.SizedBox(height: 20),
                _buildPdfStatRow('Total Stars', totalStars.value?.toString() ?? '0'),
                _buildPdfStatRow('Levels Completed', completedLevels.value?.toString() ?? '0'),
                _buildPdfStatRow('Accuracy', '${accuracy.value?.toStringAsFixed(1) ?? '0'}%'),
                _buildPdfStatRow('Time Played', '${(totalTime.value ?? 0) ~/ 60}h ${(totalTime.value ?? 0) % 60}m'),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'GAAS_Report_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.documentSentToPrinter),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.printFailed}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  pw.Widget _buildPdfStatRow(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _exportAsPDF(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.generatingPdf),
          duration: const Duration(seconds: 2),
        ),
      );

      final user = ref.read(userSessionProvider);
      final accuracy = ref.read(overallAccuracyProvider);
      final totalStars = ref.read(totalStarsProvider);
      final completedLevels = ref.read(completedLevelsProvider);
      final totalTime = ref.read(totalTimePlayedProvider);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'GAAS Performance Report',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                if (user != null) pw.Text('${l10n.playerLabel}: ${user.name}', style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 20),
                _buildPdfStatRow('Total Stars', totalStars.value?.toString() ?? '0'),
                _buildPdfStatRow('Levels Completed', completedLevels.value?.toString() ?? '0'),
                _buildPdfStatRow('Accuracy', '${accuracy.value?.toStringAsFixed(1) ?? '0'}%'),
                _buildPdfStatRow('Time Played', '${(totalTime.value ?? 0) ~/ 60}h ${(totalTime.value ?? 0) % 60}m'),
              ],
            );
          },
        ),
      );

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir != null) {
        final fileName = 'gaas_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(await pdf.save());

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reportSaved(file.path)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw 'Could not access downloads directory';
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reportSaveFailed(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _saveToDevice(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    await _exportAsPDF(context, ref, l10n);
  }

  Future<void> _shareAsPdf(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preparing PDF...'),
          duration: const Duration(seconds: 2),
        ),
      );

      final user = ref.read(userSessionProvider);
      final accuracy = ref.read(overallAccuracyProvider);
      final totalStars = ref.read(totalStarsProvider);
      final completedLevels = ref.read(completedLevelsProvider);
      final bestStreak = ref.watch(bestStreakProvider);

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'GAAS Performance Report',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Generated on ${DateTime.now().toString().split('.')[0]}'),
                if (user != null) pw.Text('${l10n.playerLabel}: ${user.name}'),
                pw.SizedBox(height: 24),
                pw.Text('Overview', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _pdfStatColumn('Stars', '${totalStars.value ?? 0}'),
                    _pdfStatColumn('Levels', '${completedLevels.value ?? 0}'),
                    _pdfStatColumn('Streak', '${bestStreak.value ?? 0}'),
                    _pdfStatColumn('Accuracy', '${accuracy.value?.toStringAsFixed(0) ?? '0'}%'),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/gaas_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My GAAS Math Progress Report',
        subject: 'GAAS Performance Report',
      );

      Future.delayed(const Duration(seconds: 10), () {
        if (file.existsSync()) file.deleteSync();
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF shared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Share failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  pw.Widget _pdfStatColumn(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text(label, style: pw.TextStyle(fontSize: 10)),
      ],
    );
  }
}