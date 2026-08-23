import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plushie_yourself/core/config/global_keys.dart';
import 'package:get_it/get_it.dart';
import 'package:plushie_yourself/core/services/toast_service.dart';
import 'package:plushie_yourself/features/plushie/bloc/plushie_bloc.dart';
import 'package:plushie_yourself/features/plushie/repository/gemini_service.dart';
import 'package:plushie_yourself/features/plushie/repository/openai_service.dart';
import 'package:plushie_yourself/features/theme/theme.dart';

final getIt = GetIt.instance;

void setupDI() {
  final openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  // Register both specific services as singletons
  getIt.registerLazySingleton<OpenAIService>(
    () => OpenAIService(apiKey: openAiApiKey),
  );

  getIt.registerLazySingleton<GeminiService>(
    () => GeminiService(apiKey: geminiApiKey),
  );

  // Primary Plushie Service: Uses Gemini if key is provided, or OpenAIService as fallback.
  // You can easily switch this to getIt<OpenAIService>() whenever you want.
  getIt.registerLazySingleton<IPlushieService>(() {
    if (geminiApiKey.isNotEmpty) {
      return getIt<GeminiService>();
    }
    return getIt<OpenAIService>();
  });

  // ToastService — singleton behind interface
  getIt.registerLazySingleton<IToastService>(
    () => ToastService(messengerKey: scaffoldMessengerKey),
  );

  // BLoCs — factories (new instance each time, keeps state fresh)
  getIt.registerFactory<PlushieBloc>(
    () => PlushieBloc(plushieService: getIt<IPlushieService>()),
  );
  getIt.registerFactory<ThemeBloc>(() => ThemeBloc());
}
