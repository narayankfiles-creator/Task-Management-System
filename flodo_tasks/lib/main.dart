import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // Added the Google Fonts import
import 'screens/task_list_screen.dart';

void main() {
  // Wrap the entire app in a ProviderScope so Riverpod works
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flodo Tasks',
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        // Upgrade the entire app's font to a modern, clean look (Inter):
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: const TaskListScreen(),
    );
  }
}