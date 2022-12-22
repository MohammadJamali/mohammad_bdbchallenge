part of 'video_controller_bloc.dart';

abstract class VideoPlayerEvent {
  final String datasource;
  const VideoPlayerEvent({required this.datasource});
}

class RequestVideoPlayer extends VideoPlayerEvent {
  const RequestVideoPlayer({
    required String datasource,
  }) : super(datasource: datasource);
}

class ToggleMuteVideoPlayerEvent extends VideoPlayerEvent {
  const ToggleMuteVideoPlayerEvent({required String datasource})
      : super(datasource: datasource);
}

class PauseVideoPlayerEvent extends VideoPlayerEvent {
  const PauseVideoPlayerEvent({required String datasource})
      : super(datasource: datasource);
}
