import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/util/app_colors.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// A mini sparkline chart for showing trends
class TrendChartMini extends StatelessWidget {
  final List<double> data;
  final Color? lineColor;
  final Color? fillColor;
  final double height;
  final double width;
  final bool showGradient;
  final double strokeWidth;

  const TrendChartMini({
    super.key,
    required this.data,
    this.lineColor,
    this.fillColor,
    this.height = 40,
    this.width = 100,
    this.showGradient = true,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(height: height, width: width);
    }

    final Color effectiveLineColor = lineColor ?? Theme.of(context).primaryColor;
    final Color effectiveFillColor =
        fillColor ?? effectiveLineColor.withOpacity(0.2);

    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(
        data: data,
        lineColor: effectiveLineColor,
        fillColor: effectiveFillColor,
        showGradient: showGradient,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;
  final bool showGradient;
  final double strokeWidth;

  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.showGradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double maxValue = data.reduce((a, b) => a > b ? a : b);
    final double minValue = data.reduce((a, b) => a < b ? a : b);
    final double range = maxValue - minValue;
    final double effectiveRange = range == 0 ? 1 : range;

    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final double x = (i / (data.length - 1)) * size.width;
      final double normalizedValue = (data[i] - minValue) / effectiveRange;
      final double y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));
    }

    // Draw fill
    if (showGradient) {
      final fillPath = Path()
        ..moveTo(0, size.height)
        ..lineTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      }

      fillPath
        ..lineTo(size.width, size.height)
        ..close();

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withOpacity(0)],
      );

      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = gradient.createShader(
            Rect.fromLTWH(0, 0, size.width, size.height),
          ),
      );
    }

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(linePath, linePaint);

    // Draw end point
    canvas.drawCircle(
      points.last,
      3,
      Paint()..color = lineColor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// A mini bar chart
class BarChartMini extends StatelessWidget {
  final List<double> data;
  final List<String>? labels;
  final Color? barColor;
  final double height;
  final double barWidth;
  final double spacing;

  const BarChartMini({
    super.key,
    required this.data,
    this.labels,
    this.barColor,
    this.height = 60,
    this.barWidth = 12,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(height: height);
    }

    final double maxValue = data.reduce((a, b) => a > b ? a : b);
    final Color effectiveBarColor = barColor ?? Theme.of(context).primaryColor;

    return SizedBox(
      height: height + (labels != null ? 20 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: data.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          final double normalizedHeight =
              maxValue > 0 ? (value / maxValue) * height : 0;

          return Padding(
            padding: EdgeInsets.only(
              right: index < data.length - 1 ? spacing : 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: barWidth,
                  height: normalizedHeight.clamp(2, height),
                  decoration: BoxDecoration(
                    color: effectiveBarColor,
                    borderRadius: BorderRadius.circular(barWidth / 2),
                  ),
                ),
                if (labels != null && index < labels!.length) ...[
                  const SizedBox(height: 4),
                  Text(
                    labels![index],
                    style: robotoRegular.copyWith(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// A progress ring/donut chart mini
class ProgressRingMini extends StatelessWidget {
  final double progress;
  final Color? progressColor;
  final Color? backgroundColor;
  final double size;
  final double strokeWidth;
  final Widget? center;

  const ProgressRingMini({
    super.key,
    required this.progress,
    this.progressColor,
    this.backgroundColor,
    this.size = 50,
    this.strokeWidth = 6,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color effectiveProgressColor =
        progressColor ?? Theme.of(context).primaryColor;
    final Color effectiveBackgroundColor =
        backgroundColor ?? (isDark ? Colors.grey[800]! : Colors.grey[200]!);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: progress.clamp(0.0, 1.0),
              progressColor: effectiveProgressColor,
              backgroundColor: effectiveBackgroundColor,
              strokeWidth: strokeWidth,
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    const startAngle = -90 * 3.14159 / 180;
    final sweepAngle = progress * 2 * 3.14159;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Trend indicator with percentage
class TrendIndicatorWidget extends StatelessWidget {
  final double value;
  final String? label;
  final bool compact;

  const TrendIndicatorWidget({
    super.key,
    required this.value,
    this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPositive = value >= 0;
    final Color color = isPositive ? AppColors.success : AppColors.error;
    final IconData icon =
        isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            '${isPositive ? '+' : ''}${value.toStringAsFixed(1)}%',
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: color,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '${isPositive ? '+' : ''}${value.toStringAsFixed(1)}%',
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: color,
            ),
          ),
          if (label != null) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
