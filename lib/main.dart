
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'login_screen.dart';
import 'registration_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final loggingIn = state.matchedLocation == '/' || state.matchedLocation == '/register';

    // If not logged in and not on a login/register page, redirect to login
    if (!loggedIn && !loggingIn) {
      return '/';
    }

    // If logged in and on a login/register page, redirect to home
    if (loggedIn && loggingIn) {
      return '/home';
    }

    return null; // No redirect needed
  },
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// This class is used to listen to auth changes and trigger a router refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
