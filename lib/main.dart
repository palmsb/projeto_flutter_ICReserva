import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://apsacslumdfaacjxyarz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFwc2Fjc2x1bWRmYWFjanh5YXJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3NTIzOTksImV4cCI6MjA3OTMyODM5OX0.D9F5DJ8RYToXH9Eb3m3ATjWEd4W3WW3CBCa34RKXi2Y',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Reserva de Salas",
      theme: ThemeData(
        fontFamily: "Arial",
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
