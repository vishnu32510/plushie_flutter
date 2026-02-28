import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plushie_yourself/core/config/global_keys.dart';
import 'package:get_it/get_it.dart';
import 'package:plushie_yourself/core/services/auth_service.dart';
import 'package:plushie_yourself/core/services/toast_service.dart';
import 'package:plushie_yourself/features/plushie/bloc/plushie_bloc.dart';
import 'package:plushie_yourself/features/plushie/repository/openai_service.dart';
import 'package:plushie_yourself/modules/theme/theme.dart';

final getIt = GetIt.instance;

void setupDI() {
  final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  // Services — singletons
  getIt.registerLazySingleton<OpenAIService>(
    () => OpenAIService(apiKey: apiKey),
  );

  // ToastService — initialize with scaffold messenger key
  getIt.registerLazySingleton<ToastService>(() {
    ToastService.initialize(scaffoldMessengerKey);
    return ToastService();
  });

  // AuthService — static helpers, registered for convenience
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // BLoCs — factories (new instance each time, keeps state fresh)
  getIt.registerFactory<PlushieBloc>(
    () => PlushieBloc(openAIService: getIt<OpenAIService>()),
  );
  getIt.registerFactory<ThemeBloc>(() => ThemeBloc());
}
