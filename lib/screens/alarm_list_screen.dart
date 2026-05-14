import 'package:alarm/alarm.dart';
import 'package:alarm_clock/screens/add_alarm_screen.dart';
import 'package:alarm_clock/screens/ring_screen.dart';
import 'package:alarm_clock/services/alarm_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:async';

class AlarmListScreen extends ConsumerStatefulWidget {
  const AlarmListScreen({super.key});

  @override
  ConsumerState<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends ConsumerState<AlarmListScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
    
    Alarm.ringing.listen((alarmSet) {
      if (alarmSet.alarms.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RingScreen(alarmSettings: alarmSet.alarms.first),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alarmsAsync = ref.watch(alarmListProvider);
    final historyAsync = ref.watch(alarmHistoryProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildAnalogClock(),
                    const SizedBox(height: 32),
                    _buildHistorySection(historyAsync),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Alarms',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Stay on schedule',
                              style: TextStyle(color: Colors.white.withOpacity(0.4)),
                            ),
                          ],
                        ),
                        IconButton.filledTonal(
                          onPressed: () => _showAddAlarm(context),
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            alarmsAsync.when(
              data: (alarms) {
                if (alarms.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.network(
                            'https://assets9.lottiefiles.com/packages/lf20_9n6scv.json',
                            height: 200,
                            errorBuilder: (context, error, stackTrace) => 
                              Icon(Icons.alarm, size: 80, color: Colors.white10),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Quiet morning ahead...',
                            style: TextStyle(color: Colors.white.withOpacity(0.3)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final alarm = alarms[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildAlarmCard(alarm),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: alarms.length,
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalogClock() {
    return SizedBox(
      height: 240,
      width: 240,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 12,
            showLabels: false,
            showTicks: false,
            axisLineStyle: AxisLineStyle(
              thickness: 0.1,
              color: Colors.white.withOpacity(0.05),
              thicknessUnit: GaugeSizeUnit.factor,
            ),
            pointers: <GaugePointer>[
              NeedlePointer(
                value: (_now.hour % 12) + (_now.minute / 60),
                needleLength: 0.5,
                needleStartWidth: 1,
                needleEndWidth: 4,
                needleColor: Colors.white,
                knobStyle: const KnobStyle(knobRadius: 0.05, color: Colors.white),
              ),
              NeedlePointer(
                value: _now.minute / 5,
                needleLength: 0.8,
                needleStartWidth: 1,
                needleEndWidth: 3,
                needleColor: Theme.of(context).primaryColor,
                knobStyle: KnobStyle(knobRadius: 0.05, color: Theme.of(context).primaryColor),
              ),
              RangePointer(
                value: _now.second / 5,
                width: 0.05,
                sizeUnit: GaugeSizeUnit.factor,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Text(
                  DateFormat('HH:mm').format(_now),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                positionFactor: 0.4,
                angle: 90,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAlarmCard(AlarmSettings alarm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16161D),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bedtime_rounded,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('hh:mm a').format(alarm.dateTime),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  alarm.notificationSettings.title,
                  style: TextStyle(color: Colors.white.withOpacity(0.4)),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: true,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (val) {
              if (!val) ref.read(alarmListProvider.notifier).removeAlarm(alarm.id);
            },
          ),
        ],
      ),
    );
  }

  void _showAddAlarm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAlarmScreen(),
    );
  }

  Widget _buildHistorySection(AsyncValue<List<SmartAlarmModel>> historyAsync) {
    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Add',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: history.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final alarm = history[index];
                  return ActionChip(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                    label: Text(
                      '${alarm.category.name} ${DateFormat('hh:mm a').format(alarm.dateTime)}',
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    ),
                    avatar: Icon(alarm.category.icon, size: 16, color: Theme.of(context).primaryColor),
                    onPressed: () async {
                      // Adjust time to future if needed
                      var newTime = DateTime(
                        DateTime.now().year, DateTime.now().month, DateTime.now().day,
                        alarm.dateTime.hour, alarm.dateTime.minute
                      );
                      if (newTime.isBefore(DateTime.now())) {
                        newTime = newTime.add(const Duration(days: 1));
                      }
                      
                      final newAlarm = SmartAlarmModel(
                        id: DateTime.now().millisecondsSinceEpoch % 10000,
                        dateTime: newTime,
                        category: alarm.category,
                        shakeToStop: alarm.shakeToStop,
                        mathChallenge: alarm.mathChallenge,
                      );
                      
                      await ref.read(alarmListProvider.notifier).addAlarm(newAlarm.toAlarmSettings());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Quick added: ${alarm.category.name} at ${DateFormat('hh:mm a').format(newTime)}'),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
