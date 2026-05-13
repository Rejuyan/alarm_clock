import 'package:alarm/alarm.dart';
import 'package:alarm_clock/screens/alarm_list_screen.dart';
import 'package:alarm_clock/screens/stopwatch_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  runApp(
    const ProviderScope(
      child: SmartAlarmApp(),
    ),
  );
}

class SmartAlarmApp extends StatelessWidget {
  const SmartAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Alarm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08080A),
        primaryColor: const Color(0xFF818CF8),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF818CF8),
          secondary: Color(0xFFF472B6),
          surface: Color(0xFF111116),
          onSurface: Colors.white,
          tertiary: Color(0xFF2DD4BF),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AlarmListScreen(),
    const StopwatchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF08080A),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: const Color(0xFF111116),
            indicatorColor: Theme.of(context).primaryColor.withOpacity(0.2),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            height: 64,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.alarm_outlined, color: Colors.white54),
                selectedIcon: Icon(Icons.alarm, color: Color(0xFF818CF8)),
                label: 'Alarms',
              ),
              NavigationDestination(
                icon: Icon(Icons.timer_outlined, color: Colors.white54),
                selectedIcon: Icon(Icons.timer, color: Color(0xFF818CF8)),
                label: 'Stopwatch',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
