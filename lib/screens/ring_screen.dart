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
    final theme = Theme.of(context);
    final title = widget.alarmSettings.notificationSettings.title;
    final timeStr = DateFormat('hh:mm').format(DateTime.now());

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF08080A),
          ),
          
          // Background Animation
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_t9gkkhz4.json',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Ringing Bell Animation
                Animate(
                  onPlay: (controller) => controller.repeat(),
                  child: Lottie.network(
                    'https://assets3.lottiefiles.com/packages/lf20_6p8y1tpf.json',
                    height: 180,
                    errorBuilder: (context, error, stackTrace) => 
                      Icon(Icons.notifications_active, size: 100, color: theme.primaryColor),
                  ),
                ).shake(hz: 2, curve: Curves.easeInOut, rotation: 0.1),
                
                const SizedBox(height: 48),
                
                // Alarm Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
                
                const SizedBox(height: 8),
                
                // Digital Time
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontSize: 110,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -5,
                  ),
                ).animate().scale(duration: 700.ms, curve: Curves.elasticOut),
                
                const Spacer(),
                
                // Dismiss Interaction
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      _buildSwipeToStopButton(theme),
                      const SizedBox(height: 32),
                      
                      // Snooze Button
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
                          'Snooze for 9 minutes',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
          
          // Celebration
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.indigo, Colors.blue, Colors.pink, Colors.cyan],
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeToStopButton(ThemeData theme) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 400) {
          _stopAlarm();
        }
      },
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white10),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                'SWIPE TO DISMISS',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  fontSize: 12,
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
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 36),
                ),
              ).moveX(begin: 0, end: 200, duration: 1.8.seconds, curve: Curves.easeInOut),
            ),
          ],
        ),
      ),
    );
  }
}
