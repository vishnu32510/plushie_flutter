import 'package:flutter/material.dart';
import 'package:plushie_yourself/features/authentication/screens/login_screen.dart';
import 'package:plushie_yourself/features/plushie/screens/home_screen.dart';
import 'package:plushie_yourself/features/plushie/screens/result_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String result = '/result';
  static const String login = '/login';
}

class CustomRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.result:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ResultScreen(
            imageBytes: args?['imageBytes'],
            resultUrl: args?['resultUrl'],
            resultBytes: args?['resultBytes'],
          ),
        );
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
