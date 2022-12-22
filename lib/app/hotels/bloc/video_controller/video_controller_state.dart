part of 'video_controller_bloc.dart';

@immutable
class VideoPlayerState extends Equatable {
  const VideoPlayerState({
    this.nonce = 0,
    this.isMuted = false,
    this.cache = const {},
    this.activeDatasource = "",
  });

  final bool isMuted;
  final String activeDatasource;
  final Map<String, VideoControllerCache> cache;

  // sometimes a change in the cache map will happen and an emit is
  // needed but if we call emit with the same data it will not trigger
  // the build method. E.x. toggling mute, increasing build volume
  final int nonce;

  VideoPlayerState copyWith({
    Map<String, VideoControllerCache>? cache,
    String? activeDatasource,
    bool? isMuted,
    int? nonce,
  }) =>
      VideoPlayerState(
        isMuted: isMuted ?? this.isMuted,
        nonce: nonce ?? this.nonce,
        cache: cache ?? this.cache,
        activeDatasource: activeDatasource ?? this.activeDatasource,
      );

  @override
  List<Object?> get props => [activeDatasource, cache, nonce, isMuted];
}

class VideoControllerCache extends Equatable {
  final String datasource;
  final Future initializer;
  final VideoPlayerController controller;

  const VideoControllerCache({
    required this.datasource,
    required this.controller,
    required this.initializer,
  });

  @override
  List<Object?> get props => [datasource];

  VideoControllerCache copyWith({
    String? datasource,
    Future? initializer,
    VideoPlayerController? controller,
  }) =>
      VideoControllerCache(
        controller: controller ?? this.controller,
        datasource: datasource ?? this.datasource,
        initializer: initializer ?? this.initializer,
      );
}
