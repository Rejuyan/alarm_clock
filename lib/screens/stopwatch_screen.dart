import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  final List<String> _laps = [];

  void _startStopwatch() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _timer.cancel();
      } else {
        _stopwatch.start();
        _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
          setState(() {});
        });
      }
    });
  }

  void _resetStopwatch() {
    setState(() {
      _stopwatch.reset();
      _laps.clear();
      if (!_stopwatch.isRunning && _timer.isActive) {
        _timer.cancel();
      }
    });
  }

  void _addLap() {
    setState(() {
      _laps.insert(0, _formatTime(_stopwatch.elapsedMilliseconds));
    });
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / 60000).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    String hundredsStr = hundreds.toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr.$hundredsStr";
  }

  @override
  void dispose() {
    if (_stopwatch.isRunning) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Stopwatch',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
              ),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: (_stopwatch.elapsedMilliseconds % 60000) / 60000,
                      strokeWidth: 4,
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  Text(
                    _formatTime(_stopwatch.elapsedMilliseconds),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 200,
                child: _laps.isEmpty
                    ? Center(
                        child: Text(
                          'No laps yet',
                          style: TextStyle(color: Colors.white.withOpacity(0.3)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _laps.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Lap ${_laps.length - index}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _laps[index],
                                  style: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircleButton(
                    onPressed: _resetStopwatch,
                    icon: Icons.refresh,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  _buildCircleButton(
                    onPressed: _startStopwatch,
                    icon: _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                    color: Theme.of(context).primaryColor,
                    isLarge: true,
                  ),
                  _buildCircleButton(
                    onPressed: _addLap,
                    icon: Icons.flag_outlined,
                    color: Colors.white.withOpacity(0.1),
                    enabled: _stopwatch.isRunning,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    bool isLarge = false,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.3,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: isLarge ? 80 : 60,
          height: isLarge ? 80 : 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isLarge ? 40 : 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
