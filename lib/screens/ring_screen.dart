import 'package:alarm/alarm.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class RingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const RingScreen({super.key, required this.alarmSettings});

  @override
  State<RingScreen> createState() => _RingScreenState();
}

class _RingScreenState extends State<RingScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _stopAlarm() {
    _confettiController.play();
    Future.delayed(const Duration(seconds: 2), () {
      Alarm.stop(widget.alarmSettings.id).then((_) {
        if (mounted) Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF08080A),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_t9gkkhz4.json',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Animate(
                  onPlay: (controller) => controller.repeat(),
                  child: Lottie.network(
                    'https://assets3.lottiefiles.com/packages/lf20_6p8y1tpf.json',
                    height: 200,
                  ),
                ).shake(hz: 4, curve: Curves.easeInOut),
                
                const SizedBox(height: 40),
                Text(
                  widget.alarmSettings.notificationSettings.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: Colors.white70,
                  ),
                ).animate().fadeIn(duration: 1.seconds).slideY(begin: 0.2),
                
                const SizedBox(height: 12),
                Text(
                  DateFormat('hh:mm').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -4,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const Spacer(),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if ((details.primaryVelocity ?? 0) > 500) {
                            _stopAlarm();
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  'Swipe Right to Stop',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 8,
                                top: 8,
                                bottom: 8,
                                child: Animate(
                                  onPlay: (controller) => controller.repeat(),
                                  child: Container(
                                    width: 64,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.chevron_right, color: Colors.white, size: 32),
                                  ),
                                ).moveX(begin: 0, end: 200, duration: 1.5.seconds, curve: Curves.easeInOut),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          final now = DateTime.now();
                          Alarm.set(
                            alarmSettings: widget.alarmSettings.copyWith(
                              dateTime: now.add(const Duration(minutes: 9)),
                            ),
                          ).then((_) {
                            if (mounted) Navigator.pop(context);
                          });
                        },
                        child: Text(
                          'Snooze (9m)',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
          
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.pink, Colors.blue, Colors.orange, Colors.purple],
          ),
        ],
      ),
    );
  }
}
