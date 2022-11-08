part of 'bloc.dart';

enum PictureStatus { initial, success, failure }

class PictureState extends Equatable {
  final PictureStatus status;
  final List<PictureModel> pictures;
  final bool hasReachedMax;
  final int page;

  const PictureState({
    this.page = 2,
    this.status = PictureStatus.initial,
    this.pictures = const <PictureModel>[],
    this.hasReachedMax = false,
  });

  PictureState copyWith({
    int? page,
    PictureStatus? status,
    List<PictureModel>? pictures,
    bool? hasReachedMax,
  }) {
    return PictureState(
      page: page ?? this.page,
      status: status ?? this.status,
      pictures: pictures ?? this.pictures,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [status, pictures, hasReachedMax];
}
