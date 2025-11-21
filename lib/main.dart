import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Supabase
  await Supabase.initialize(
    url: 'https://apsacslumdfaacjxyarz.supabase.co', // coloque o URL DO SEU PROJETO
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFwc2Fjc2x1bWRmYWFjanh5YXJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3NTIzOTksImV4cCI6MjA3OTMyODM5OX0.D9F5DJ8RYToXH9Eb3m3ATjWEd4W3WW3CBCa34RKXi2Y',          // coloque sua ANON KEY
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
