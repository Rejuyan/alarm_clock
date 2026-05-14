import 'package:alarm_clock/models/alarm_model.dart';
import 'package:alarm_clock/services/alarm_provider.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

  Future<void> _selectTimeManual() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: const Color(0xFF16161D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onTimeChanged(Time(hour: picked.hour, minute: picked.minute));
    }
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
            content: Text('Alarm set for ${selectedCategory.name} at ${DateFormat('hh:mm a').format(selectedTime)}'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to set alarm. Ensure assets are ready.'),
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
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF08080A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(44)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Alarm Time',
                    style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Massive Clickable Time Display
                  Center(
                    child: GestureDetector(
                      onTap: _selectTimeManual,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111116),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: theme.primaryColor.withOpacity(0.3), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('hh:mm').format(selectedTime),
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat('a').format(selectedTime),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.touch_app, size: 16, color: theme.primaryColor),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Tap to set custom time',
                                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle('Alarm Category'),
                  const SizedBox(height: 16),
                  _buildCategoryList(),
                  
                  const SizedBox(height: 32),
                  _buildSectionTitle('Smart Challenges'),
                  const SizedBox(height: 16),
                  _buildSmartToggle(
                    'Shake to Stop',
                    'Requires physical movement',
                    Icons.vibration_rounded,
                    shakeToStop,
                    (val) => setState(() => shakeToStop = val),
                  ),
                  _buildSmartToggle(
                    'Math Challenge',
                    'Solve problems to dismiss',
                    Icons.psychology_outlined,
                    mathChallenge,
                    (val) => setState(() => mathChallenge = val),
                  ),
                  
                  const SizedBox(height: 48),
                  _buildActivateButton(theme),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AlarmCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = AlarmCategory.values[index];
          final isSelected = selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100,
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : const Color(0xFF16161D),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isSelected ? Colors.white24 : Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(category.icon, color: isSelected ? Colors.white : Colors.white38),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 12,
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
    );
  }

  Widget _buildSmartToggle(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16161D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white24, fontSize: 11)),
        trailing: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildActivateButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: isLoading ? null : saveAlarm,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 12,
          shadowColor: theme.primaryColor.withOpacity(0.4),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded),
                  SizedBox(width: 12),
                  Text(
                    'ACTIVATE ALARM',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ],
              ),
      ),
    );
  }
}
