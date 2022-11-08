part of 'bloc.dart';

abstract class PictureEvent extends Equatable {
  const PictureEvent();

  @override
  List<Object> get props => [];
}

class PictureFetched extends PictureEvent {
  const PictureFetched();
}
