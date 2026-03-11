import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plushie_yourself/bloc_observer.dart';
import 'package:plushie_yourself/core/config/global_keys.dart';
import 'package:plushie_yourself/core/config/routes.dart';
import 'package:plushie_yourself/core/di/injection.dart';
import 'package:plushie_yourself/features/authentication/wrappers/authentication_wrapper.dart';
import 'package:plushie_yourself/features/plushie/bloc/plushie_bloc.dart';
import 'package:plushie_yourself/features/theme/theme.dart';
import 'package:plushie_yourself/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  Bloc.observer = SimpleBlocObserver();
  setupDI();
  runApp(const PlushieApp());
}

class PlushieApp extends StatelessWidget {
  const PlushieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthenticationWrapper(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(create: (_) => getIt<ThemeBloc>()),
          BlocProvider<PlushieBloc>(create: (_) => getIt<PlushieBloc>()),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp(
              title: 'Plushie Yourself',
              debugShowCheckedModeBanner: false,
              theme: themeState.themeData,
              themeMode: themeState.themeMode,
              navigatorKey: navigatorKey,
              scaffoldMessengerKey: scaffoldMessengerKey,
              onGenerateRoute: CustomRouter.generateRoute,
              initialRoute: AppRoutes.home,
            );
          },
        ),
      ),
    );
  }
}
