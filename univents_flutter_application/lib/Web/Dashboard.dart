import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univents_flutter_application/Widget/Organizations.dart';
import 'package:univents_flutter_application/Widget/Events.dart';
import 'Login.dart';
// import 'dart:html' as html;


final SupabaseClient supabase = Supabase.instance.client;

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await supabase.auth.signOut();

                // // Clear session storage for web
                // if (kIsWeb) {
                //   // Clear stored Supabase session on web
                //   html.window.localStorage.clear();
                //   html.window.sessionStorage.clear();
                // }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Login()),
                );
              })
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Admin Drawer'),
            ),
            ListTile(
              title: const Text('Organizations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Organizations()),
                );
              },
            ),
            ListTile(
              title: const Text('Events'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Events())
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Hello, ${user?.userMetadata?["full_name"] ?? user?.email ?? "User"}!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
