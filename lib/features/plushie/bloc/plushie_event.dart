part of 'plushie_bloc.dart';

abstract class PlushieEvent extends Equatable {
  const PlushieEvent();

  @override
  List<Object?> get props => [];
}

class TransformImageEvent extends PlushieEvent {
  final File imageFile;

  const TransformImageEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class ResetPlushieEvent extends PlushieEvent {
  const ResetPlushieEvent();
}
