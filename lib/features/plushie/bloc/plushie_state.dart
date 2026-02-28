part of 'plushie_bloc.dart';

abstract class PlushieState extends Equatable {
  const PlushieState();

  @override
  List<Object?> get props => [];
}

class PlushieInitial extends PlushieState {
  const PlushieInitial();
}

class PlushieLoading extends PlushieState {
  const PlushieLoading();
}

class PlushieSuccess extends PlushieState {
  final Uint8List? resultBytes;
  final String? resultUrl;
  final Uint8List originalImageBytes;

  const PlushieSuccess({
    this.resultBytes,
    this.resultUrl,
    required this.originalImageBytes,
  });

  @override
  List<Object?> get props => [resultBytes, resultUrl, originalImageBytes];
}

class PlushieError extends PlushieState {
  final String message;

  const PlushieError(this.message);

  @override
  List<Object?> get props => [message];
}
