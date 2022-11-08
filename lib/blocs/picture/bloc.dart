import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:unsplash_flutter/keys.dart';
import 'package:unsplash_flutter/models/picture.dart';
import 'package:unsplash_flutter/repositories/api_base.dart';
import 'package:unsplash_flutter/repositories/picture.dart';

part 'event.dart';

part 'state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PictureBloc extends Bloc<PictureEvent, PictureState> {
  final PictureAPIRepository _api = PictureAPIRepository(
    apiRepository: const APIRepository(),
    defaultQueryParams: {
      "client_id": key,
    },
  );

  PictureBloc() : super(const PictureState()) {
    on<PictureFetched>(
      _onPostFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _onPostFetched(
      PictureFetched event, Emitter<PictureState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == PictureStatus.initial) {
        await Future.delayed(const Duration(seconds: 2));
        final List<PictureModel> pictures = await _api.getPage(
          queryParams: {
            "page": state.page.toString(),
          },
        );
        return emit(state.copyWith(
          status: PictureStatus.success,
          pictures: pictures,
          page: state.page + 1,
          hasReachedMax: false,
        ));
      }
      final List<PictureModel> pictures = await _api.getPage(
        queryParams: {
          "page": state.page.toString(),
        },
      );
      if (pictures.isEmpty) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        emit(state.copyWith(
          page: state.page + 1,
          status: PictureStatus.success,
          pictures: List.of(state.pictures)..addAll(pictures),
          hasReachedMax: false,
        ));
      }
    } catch (_) {
      if (state.pictures.isEmpty) {
        emit(state.copyWith(status: PictureStatus.failure));
      } else {
        emit(state.copyWith(hasReachedMax: true));
      }
    }
  }
}
