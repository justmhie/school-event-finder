import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Web/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bokvzsmpjkdvcxndjfop.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJva3Z6c21wamtkdmN4bmRqZm9wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ1NTQ2ODksImV4cCI6MjA2MDEzMDY4OX0.ffciwyoTJshK42Llpv55rRVx6-_JlO_PNIWtyYbKVgg',
  );

  final supabase = Supabase.instance.client;

  final uri = Uri.base;

  if (kIsWeb &&
      (uri.queryParameters.containsKey('access_token') ||
          uri.queryParameters.containsKey('refresh_token') ||
          uri.queryParameters.containsKey('error'))) {
    try {
      await supabase.auth.getSessionFromUrl(uri);

      html.window.history.replaceState(null, '', '/');
    } catch (e) {
      debugPrint('OAuth session restoration failed: $e');
    }
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}
