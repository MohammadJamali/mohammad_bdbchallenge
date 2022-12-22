import 'dart:async';
import 'dart:math';

import 'package:bdb_challenge/app/hotels/hotels.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

part 'video_controller_event.dart';
part 'video_controller_state.dart';

class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  int cacheAheadSize;
  int cacheBehindSize;
  bool rewindOnRequest;
  late List<String> datasource;
  late StreamSubscription<HotelState> hotelStateStream;

  VideoPlayerBloc({
    required HotelBloc hotelBloc,
    this.cacheAheadSize = 6,
    this.cacheBehindSize = 6,
    this.rewindOnRequest = false,
  }) : super(const VideoPlayerState()) {
    datasource = [];

    onRepositoryChanged(hotelBloc.state);
    hotelStateStream = hotelBloc.stream.listen(onRepositoryChanged);

    on<RequestVideoPlayer>(_onRequest);
    on<ToggleMuteVideoPlayerEvent>(_onToggleMute);
  }

  FutureOr<void> _onToggleMute(
    ToggleMuteVideoPlayerEvent event,
    Emitter<VideoPlayerState> emit,
  ) async {
    final isMuted = !state.isMuted;
    for (var controller in state.cache.values) {
      await controller.controller.setVolume(isMuted ? 0 : 1);
    }

    emit(state.copyWith(isMuted: isMuted));
  }

  Future<void> _onRequest(
    RequestVideoPlayer event,
    Emitter<VideoPlayerState> emit,
  ) async {
    // if an outlayer is passed, stop the playing controller and return
    final index = datasource.indexOf(event.datasource);

    await _stopController(state.cache[state.activeDatasource]);
    if (index == -1) {
      emit(state.copyWith(activeDatasource: null));
      return;
    }

    Map<String, VideoControllerCache> cache = state.cache;
    if (!state.cache.containsKey(index)) {
      cache = await _manageCache(index);
    }
    await cache[event.datasource]?.initializer;
    await cache[event.datasource]?.controller.play();

    emit(VideoPlayerState(cache: cache, activeDatasource: event.datasource));
  }

  Future<Map<String, VideoControllerCache>> _manageCache(
    int datasourceIndex,
  ) async {
    if (datasource.isEmpty) return state.cache;

    // find the boundry to cache the videos after and before of the current
    // video: [-, -, -, cached, cached, playing, cached, cached, -, -, -]
    final minPage = clipIndex(datasourceIndex - cacheBehindSize);
    final maxPage = clipIndex(datasourceIndex + cacheAheadSize);
    final boundary = {for (var i = minPage; i <= maxPage; i++) datasource[i]};

    final cache = {...state.cache};

    // find out of boundries videos to dispose and freeup some memory
    final toDispose = cache.keys.toSet().difference(boundary);
    for (final index in toDispose) {
      cache.remove(index)?.controller.dispose();
    }

    // add new players to the list to cache for smooth playing
    final newControllers = boundary.difference(cache.keys.toSet());
    for (final key in newControllers) {
      final controller = VideoPlayerController.network(key);
      cache[key] = VideoControllerCache(
        datasource: key,
        controller: controller,
        initializer: _initializeController(controller),
      );
    }

    return cache;
  }

  Future<void> _stopController(VideoControllerCache? controller) async {
    await controller?.controller.pause();
    if (rewindOnRequest) {
      await controller?.controller.seekTo(const Duration());
    }
  }

  Future<void> _initializeController(VideoPlayerController controller) async {
    await controller.initialize();
    await controller.setLooping(true);
    await controller.setVolume(state.isMuted ? 0 : 1);
  }

  void onRepositoryChanged(HotelState hotelState) {
    final datasourceWasEmpty = datasource.isEmpty;
    datasource = hotelState.hotels.map((hotel) => hotel.link).toList();

    if (datasourceWasEmpty && datasource.isNotEmpty) {
      _manageCache(0);
    }
  }

  @override
  Future<void> close() {
    hotelStateStream.cancel();
    return super.close();
  }

  int clipIndex(int index) => max(0, min(datasource.length - 1, index));
}
