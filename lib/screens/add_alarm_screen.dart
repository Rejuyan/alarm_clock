import 'package:alarm_clock/models/alarm_model.dart';
import 'package:alarm_clock/services/alarm_provider.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddAlarmScreen extends ConsumerStatefulWidget {
  const AddAlarmScreen({super.key});

  @override
  ConsumerState<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends ConsumerState<AddAlarmScreen> {
  DateTime selectedTime = DateTime.now().add(const Duration(minutes: 1));
  AlarmCategory selectedCategory = AlarmCategory.sleep;
  bool shakeToStop = false;
  bool mathChallenge = false;
  bool isLoading = false;

  void onTimeChanged(Time time) {
    setState(() {
      final now = DateTime.now();
      selectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (selectedTime.isBefore(now)) {
        selectedTime = selectedTime.add(const Duration(days: 1));
      }
    });
  }

  Future<void> saveAlarm() async {
    setState(() => isLoading = true);
    
    try {
      final alarmSettings = SmartAlarmModel(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        dateTime: selectedTime,
        category: selectedCategory,
        shakeToStop: shakeToStop,
        mathChallenge: mathChallenge,
      ).toAlarmSettings();

      await ref.read(alarmListProvider.notifier).addAlarm(alarmSettings);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alarm set for ${selectedCategory.name} at ${TimeOfDay.fromDateTime(selectedTime).format(context)}'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set alarm: Please ensure audio files exist in assets/'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFF08080A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Alarm',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your wake-up experience',
                    style: TextStyle(color: Colors.white.withOpacity(0.4)),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      height: 300,
                      child: showPicker(
                        context: context,
                        value: Time(hour: selectedTime.hour, minute: selectedTime.minute),
                        onChange: onTimeChanged,
                        is24HrFormat: false,
                        accentColor: Theme.of(context).primaryColor,
                        unselectedColor: Colors.white12,
                        borderRadius: 32,
                        elevation: 0,
                        barrierDismissible: false,
                        isInlinePicker: true,
                        isOnChangeValueMode: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Routine',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AlarmCategory.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final category = AlarmCategory.values[index];
                        final isSelected = selectedCategory == category;
                        return GestureDetector(
                          onTap: () => setState(() => selectedCategory = category),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 90,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : const Color(0xFF16161D),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white24
                                    : Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  category.icon,
                                  color: isSelected ? Colors.white : Colors.white38,
                                  size: 28,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isSelected ? Colors.white : Colors.white38,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildSmartToggle(
                    'Shake to Wake',
                    'You must shake the device to stop',
                    Icons.vibration_rounded,
                    shakeToStop,
                    (val) => setState(() => shakeToStop = val),
                  ),
                  _buildSmartToggle(
                    'Mental Math',
                    'Solve a puzzle to ensure clarity',
                    Icons.psychology_outlined,
                    mathChallenge,
                    (val) => setState(() => mathChallenge = val),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : saveAlarm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                        disabledBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Activate Alarm',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white24, fontSize: 12)),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
