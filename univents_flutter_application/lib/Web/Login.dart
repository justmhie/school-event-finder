import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Dashboard.dart'; // your dashboard file

final SupabaseClient supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _userID;

  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((data) {
      setState(() {
        _userID = data.session?.user?.id;
      });
    });
  }

  Future<void> _nativeGoogleSignIn() async {
    const webClientId =
        '451923571225-16d5gkkhbib2bvov02p7fgv40mi2jiff.apps.googleusercontent.com';
    final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: webClientId);

    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;

    final accessToken = googleAuth?.accessToken;
    final idToken = googleAuth?.idToken;

    if (accessToken != null && idToken != null) {
      final res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final email = res.user?.email;
      if (email != null) {
        await _checkUserExists(email);
      }
    }
  }

  Future<void> _webGoogleSignIn() async {
    final res = await supabase.auth.signInWithOAuth(OAuthProvider.google);
    final email = supabase.auth.currentUser?.email;

    if (email != null) {
      await _checkUserExists(email);
    }
  }

  Future<void> _checkUserExists(String email) async {
    print('Checking email: $email');
    final allUsers = await supabase.from('users').select('email');

    final response = await supabase
        .from('users')
        .select()
        .ilike('email', email)
        .maybeSingle();

    if (response != null) {
      print('User found in users table.');
      _goToDashboard();
    } else {
      print('User NOT found in users table.');
      _showAlert("Account not found in our system.");
      await supabase.auth.signOut();
    }
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Dashboard()),
    );
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Access Denied'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final email = supabase.auth.currentUser?.email;
      if (email != null) {
        await _checkUserExists(email);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/login.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Card(
            elevation: 20,
            color: Colors.white,
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 60, top: 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      const Text("Uni-Vents",
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 45, 179),
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      const SizedBox(height: 5),
                      const Text("Ateneo de Davao Events",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25)),
                      const SizedBox(height: 30),
                      const Text("Welcome Back, Please login to your account",
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 30),
                      Text("Employee ID",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 45, 179),
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 400,
                        child: TextField(
                          controller: _emailController,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "admin@addu.edu.ph",
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 194, 190, 190)),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 232, 240, 254),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color: Color.fromARGB(255, 0, 45, 179))),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 194, 192, 192)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text("Passcode",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 45, 179),
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(height: 5),
                      SizedBox(
                        width: 400,
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 232, 240, 254),
                            hintText: "Enter your password",
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 194, 190, 190)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color: Color.fromARGB(255, 0, 45, 179))),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 194, 192, 192)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: false,
                            onChanged: (bool? newValue) {},
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            side: BorderSide(
                                color: const Color.fromARGB(255, 215, 214, 214),
                                width: 1),
                          ),
                          Text(
                            "Remember me",
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          SizedBox(
                            width: 145,
                          ),
                          Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text;

                              if (email == 'admin@addu.edu.ph' &&
                                  password == 'admin123') {
                                _goToDashboard();
                              } else {
                                _showAlert("Invalid credentials");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 0, 45, 179),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              minimumSize: const Size(150, 60),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color.fromARGB(255, 0, 45, 179),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(
                                      color: Color.fromARGB(255, 0, 45, 179))),
                              minimumSize: const Size(150, 60),
                            ),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 50),
                      _googleButton(),
                    ],
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/login.jpg'),
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _googleButton() {
    return InkWell(
      onTap: () async {
        if (!kIsWeb && Platform.isAndroid) {
          await _nativeGoogleSignIn();
        } else {
          await _webGoogleSignIn();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(255, 0, 45, 179)),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/google_logo.png', height: 24),
            const SizedBox(width: 10),
            const Text(
              'Sign in with Google',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
