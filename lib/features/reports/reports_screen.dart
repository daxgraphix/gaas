import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../core/providers.dart';
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
    final levelProgress = ref.watch(levelProgressProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, theme, l10n, ref),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.02),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    switch (index) {
                      case 0:
                        return _buildOverviewCards(theme, totalStars, completedLevels, totalTime, accuracy, l10n);
                      case 1:
                        return const SizedBox(height: 32);
                      case 2:
                        return _buildPerformanceAnalytics(context, theme, accuracy, totalTime, l10n);
                      case 3:
                        return const SizedBox(height: 32);
                      case 4:
                        return _buildAccuracyChart(context, theme, l10n);
                      case 5:
                        return const SizedBox(height: 32);
                      case 6:
                        return _buildLevelProgression(context, theme, AsyncValue.data(levelProgress), l10n);
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                  childCount: 7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _exportAsImage(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      // Show loading
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating image...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Create a RepaintBoundary key for capturing
      final boundaryKey = GlobalKey();

      // Show a temporary overlay with the report content
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

      // Wait for the widget to render
      await Future.delayed(const Duration(milliseconds: 500));

      // Capture the image
      final renderObject = boundaryKey.currentContext!.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) throw 'Could not find render object';
      final boundary = renderObject;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Remove overlay
      overlayEntry.remove();

      // Share the image
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/gaas_report_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      if (!context.mounted) return;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'GAAS Performance Report',
        subject: 'Mathematics Learning Progress',
      );

      // Clean up
      Future.delayed(const Duration(seconds: 10), () {
        if (file.existsSync()) file.deleteSync();
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image shared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image export failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _printReport(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing document for printing...'),
          duration: Duration(seconds: 2),
        ),
      );

      final user = ref.read(userSessionProvider);
      final accuracy = ref.read(overallAccuracyProvider);
      final totalStars = ref.read(totalStarsProvider);
      final completedLevels = ref.read(completedLevelsProvider);
      final totalTime = ref.read(totalTimePlayedProvider);

      // Create PDF document for printing
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
                  pw.Text('Player: ${user.name}', style: pw.TextStyle(fontSize: 14)),
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

      // Print the PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'GAAS_Report_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document sent to printer!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Print failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _saveToDevice(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating PDF...'),
          duration: Duration(seconds: 2),
        ),
      );

      final user = ref.read(userSessionProvider);
      final accuracy = ref.read(overallAccuracyProvider);
      final totalStars = ref.read(totalStarsProvider);
      final completedLevels = ref.read(completedLevelsProvider);
      final totalTime = ref.read(totalTimePlayedProvider);

      // Create PDF
      final pdf = pw.Document();

      // Add content pages
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
                if (user != null) pw.Text('Player: ${user.name}', style: pw.TextStyle(fontSize: 14)),
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

      // Get downloads directory
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
            content: Text('Report saved to: ${file.path}'),
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
          content: Text('Save failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme, AppLocalizations l10n, WidgetRef ref) {
    return AppBar(
      title: Text(l10n.reports),
      centerTitle: true,
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
          'GAAS Performance Report',
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
          const SizedBox(height: 16),
          Text('Player: ${user.name}', style: theme.textTheme.titleMedium),
        ],
        const SizedBox(height: 24),
        _buildStatCardForImage('Stars Earned', '${totalStars.value ?? 0}', Icons.star, theme.colorScheme.primary, theme),
        const SizedBox(height: 12),
        _buildStatCardForImage('Levels Completed', '${completedLevels.value ?? 0}', Icons.flag, theme.colorScheme.secondary, theme),
        const SizedBox(height: 12),
        _buildStatCardForImage('Accuracy', '${accuracy.value?.toStringAsFixed(1) ?? '0'}%', Icons.trending_up, theme.colorScheme.tertiary, theme),
        const SizedBox(height: 12),
        _buildStatCardForImage('Time Played', '${(totalTime.value ?? 0) ~/ 60}h ${(totalTime.value ?? 0) % 60}m', Icons.timer, theme.colorScheme.error, theme),
      ],
    );
  }

  Widget _buildStatCardForImage(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
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
                'Stars Earned',
                totalStars.value?.toString() ?? '0',
                Icons.star,
                theme.colorScheme.primary,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Levels Completed',
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
                'Accuracy',
                '${accuracy.value?.toStringAsFixed(1) ?? '0'}%',
                Icons.trending_up,
                theme.colorScheme.tertiary,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Time Played',
                '${(totalTime.value ?? 0) ~/ 60}h ${(totalTime.value ?? 0) % 60}m',
                Icons.timer,
                theme.colorScheme.error,
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
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
    return Column(
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                'Current Session',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem('Accuracy', '${accuracy.value?.toStringAsFixed(1) ?? '0'}%', theme),
                  _buildMetricItem('Time', '${(totalTime.value ?? 0) ~/ 60}m', theme),
                ],
              ),
            ],
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

  Widget _buildAccuracyChart(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final performanceTrends = ref.watch(performanceTrendsProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accuracyTrends,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
              ),
              child: performanceTrends.accuracyHistory.isEmpty
                  ? Center(
                      child: Text(
                        'No accuracy data available yet.\nComplete some sessions to see trends.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 10,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: theme.colorScheme.outline.withValues(alpha: 0.2),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: theme.colorScheme.outline.withValues(alpha: 0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 2,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < performanceTrends.accuracyHistory.length && index % 2 == 0) {
                                  return Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      fontSize: 12,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 20,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}%',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        minX: 0,
                        maxX: (performanceTrends.accuracyHistory.length - 1).toDouble(),
                        minY: 0,
                        maxY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              performanceTrends.accuracyHistory.length,
                              (index) => FlSpot(
                                index.toDouble(),
                                performanceTrends.accuracyHistory[index],
                              ),
                            ),
                            isCurved: true,
                            color: theme.colorScheme.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: theme.colorScheme.primary,
                                  strokeWidth: 2,
                                  strokeColor: theme.colorScheme.surface,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((touchedSpot) {
                                return LineTooltipItem(
                                  '${touchedSpot.y.toStringAsFixed(1)}%',
                                  TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                            getTooltipColor: (touchedSpot) => theme.colorScheme.surface,
                            tooltipBorder: BorderSide(
                              color: theme.colorScheme.outline,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            if (performanceTrends.accuracyHistory.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Latest',
                      '${performanceTrends.accuracyHistory.last.toStringAsFixed(1)}%',
                      theme.colorScheme.primary,
                      theme,
                    ),
                    _buildStatItem(
                      'Average',
                      '${performanceTrends.averageAccuracy.toStringAsFixed(1)}%',
                      theme.colorScheme.secondary,
                      theme,
                    ),
                    _buildStatItem(
                      'Peak',
                      '${performanceTrends.accuracyHistory.reduce((a, b) => a > b ? a : b).toStringAsFixed(1)}%',
                      theme.colorScheme.tertiary,
                      theme,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelProgression(
    BuildContext context,
    ThemeData theme,
    AsyncValue<Map<String, List<dynamic>>> levelProgress,
    AppLocalizations l10n,
  ) {
    return Column(
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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              if (levelProgress is AsyncData && levelProgress.value != null) ...[
                ...levelProgress.value!.entries.map((entry) {
                  final operation = entry.key;
                  final levels = entry.value;
                  final completed = levels.where((level) => (level as dynamic).stars > 0).length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(operation.toUpperCase()),
                        Text('$completed/${levels.length}'),
                      ],
                    ),
                  );
                }),
              ] else ...[
                const Center(child: Text('No progress data available')),
              ],
            ],
          ),
        ),
      ],
    );
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



  void _showExportOptions(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.file_download,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Export Report',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Export Options
            _buildExportOption(
              context: context,
              icon: Icons.picture_as_pdf,
              title: 'Export as PDF',
              subtitle: 'Generate and share detailed PDF report',
              onTap: () => _exportAsPDF(context, ref, l10n),
              theme: theme,
            ),
            _buildExportOption(
              context: context,
              icon: Icons.image,
              title: 'Share as Image',
              subtitle: 'Capture and share report as high-quality image',
              onTap: () => _exportAsImage(context, ref, l10n),
              theme: theme,
            ),
            _buildExportOption(
              context: context,
              icon: Icons.print,
              title: 'Print Report',
              subtitle: 'Send report to printer',
              onTap: () => _printReport(context, ref, l10n),
              theme: theme,
            ),
            _buildExportOption(
              context: context,
              icon: Icons.save,
              title: 'Save to Device',
              subtitle: 'Save PDF to device storage',
              onTap: () => _saveToDevice(context, ref, l10n),
              theme: theme,
            ),
            const SizedBox(height: 20),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsPDF(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      // Show loading
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('Generating PDF...'),
          duration: const Duration(seconds: 2),
        ),
      );

      final user = ref.read(userSessionProvider);
      final accuracy = ref.read(overallAccuracyProvider);
      final totalStars = ref.read(totalStarsProvider);
      final completedLevels = ref.read(completedLevelsProvider);
      final totalTime = ref.read(totalTimePlayedProvider);

      // Create PDF
      final pdf = pw.Document();

      // Add content pages
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
                if (user != null) pw.Text('Player: ${user.name}', style: pw.TextStyle(fontSize: 14)),
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

      // Get downloads directory
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
            content: Text('Report saved to: ${file.path}'),
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
          content: Text('Save failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}