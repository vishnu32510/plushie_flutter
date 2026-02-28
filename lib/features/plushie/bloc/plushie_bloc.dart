import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:plushie_yourself/features/plushie/repository/openai_service.dart';

part 'plushie_event.dart';
part 'plushie_state.dart';

class PlushieBloc extends Bloc<PlushieEvent, PlushieState> {
  final OpenAIService _openAIService;

  PlushieBloc({required OpenAIService openAIService})
      : _openAIService = openAIService,
        super(const PlushieInitial()) {
    on<TransformImageEvent>(_onTransformImage);
    on<ResetPlushieEvent>(_onReset);
  }

  Future<void> _onTransformImage(
    TransformImageEvent event,
    Emitter<PlushieState> emit,
  ) async {
    emit(const PlushieLoading());

    final Uint8List originalBytes;
    try {
      originalBytes = await event.imageFile.readAsBytes();
    } catch (_) {
      emit(const PlushieError('Could not read image file. Please try again.'));
      return;
    }

    final result = await _openAIService.transformToPlushie(
      imageFile: event.imageFile,
    );

    if (result.isSuccess) {
      emit(PlushieSuccess(
        resultBytes: result.imageBytes,
        resultUrl: result.url,
        originalImageBytes: originalBytes,
      ));
    } else {
      emit(PlushieError(result.error ?? 'Unknown error'));
    }
  }

  void _onReset(ResetPlushieEvent event, Emitter<PlushieState> emit) {
    emit(const PlushieInitial());
  }
}
