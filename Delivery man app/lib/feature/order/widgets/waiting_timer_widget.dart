import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_delivery/util/styles.dart';

class WaitingTimerWidget extends StatefulWidget {
  final String? arrivedAt;
  final String label;
  const WaitingTimerWidget({super.key, this.arrivedAt, required this.label});

  @override
  State<WaitingTimerWidget> createState() => _WaitingTimerWidgetState();
}

class _WaitingTimerWidgetState extends State<WaitingTimerWidget> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateElapsed();
    });
  }

  void _calculateElapsed() {
    if (widget.arrivedAt != null) {
      try {
        DateTime arrivedTime = DateTime.parse(widget.arrivedAt!);
        setState(() {
          _elapsed = DateTime.now().difference(arrivedTime);
          if (_elapsed.isNegative) _elapsed = Duration.zero;
        });
      } catch (_) {
        setState(() => _elapsed = Duration.zero);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      String hours = d.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(HeroiconsOutline.clock, size: 18, color: Colors.amber.shade700),
        const SizedBox(width: 8),
        Text(
          widget.label.tr,
          style: robotoMedium.copyWith(fontSize: 13, color: Colors.amber.shade700),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.shade700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _formatDuration(_elapsed),
            style: robotoBold.copyWith(fontSize: 14, color: Colors.white),
          ),
        ),
      ]),
    );
  }
}
