import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/storage/auth_storage.dart';
import 'features/shell/presentation/main_nav_screen.dart';
import 'features/welcome/presentation/welcome_screen.dart';

void main() {
  runApp(const WhiteHotelApp());
}

class WhiteHotelApp extends StatelessWidget {
  const WhiteHotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'White Hotel',
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          background: const Color(0xFFF9F5F0),
        ),
      ),
      home: const AppGate(),
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const AppGate());
      },
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  final AuthStorage _authStorage = AuthStorage();
  late final Future<bool> _hasSessionFuture;

  @override
  void initState() {
    super.initState();
    _hasSessionFuture = _checkSession();
  }

  Future<bool> _checkSession() async {
    final token = await _authStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          return const MainNavScreen(); // ← was HomeScreen
        }
        return const WelcomeScreen();
      },
    );
  }
}
