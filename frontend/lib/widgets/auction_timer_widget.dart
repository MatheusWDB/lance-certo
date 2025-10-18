import 'package:flutter/material.dart';
import 'dart:async';

class AuctionTimerWidget extends StatefulWidget {
  const AuctionTimerWidget({
    required this.endTime,
    required this.updateList,
    super.key,
  });

  final DateTime endTime;
  final Future<void> Function() updateList;

  @override
  State<AuctionTimerWidget> createState() => _AuctionTimerWidgetState();
}

class _AuctionTimerWidgetState extends State<AuctionTimerWidget> {
  Timer? _timer;
  Duration _timeRemaining = Duration.zero;
  bool isActive = true;

  void _calculateAndUpdateTime() async {
    final now = DateTime.now();
    final remaining = widget.endTime.difference(now);
    final bool timerExpired = remaining.isNegative;

    if (timerExpired) {
      _timeRemaining = Duration.zero;
      _timer?.cancel();
      _timer = null;

      await widget.updateList();

      if (!mounted) return;
    } else {
      _timeRemaining = remaining;
    }

    if (mounted) {
      setState(() {
        if (timerExpired && isActive) {
          isActive = false;
        }
      });
    }
  }

  void _startOrStopTimer() {
    _calculateAndUpdateTime();

    if (_timeRemaining.isNegative || _timeRemaining == Duration.zero) {
      _timer?.cancel();
      _timer = null;

      return;
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateAndUpdateTime();
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String hours = twoDigits(duration.inHours);
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${hours}h ${minutes}m ${seconds}s';
  }

  @override
  void initState() {
    super.initState();
    _startOrStopTimer();
  }

  @override
  void didUpdateWidget(covariant AuctionTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) {
      _timer?.cancel();
      _timer = null;
      _startOrStopTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      isActive == true ? _formatDuration(_timeRemaining) : 'Leilão Encerrado.',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: isActive == true
            ? const Color(0xFF374151)
            : const Color(0xFFDC2626),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
