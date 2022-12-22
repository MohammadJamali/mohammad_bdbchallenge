import 'package:bdb_challenge/app/hotels/bloc/video_controller/video_controller_bloc.dart';
import 'package:bdb_challenge/app/hotels/widgets/video_player_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:bdb_challenge/repositories/models/hotel.dart';
import 'package:bdb_challenge/widgets/error_placeholder.dart';

class HotelVideo extends StatefulWidget {
  const HotelVideo({
    super.key,
    required this.model,
  });

  final HotelModel model;

  @override
  State<HotelVideo> createState() => _HotelVideoState();
}

class _HotelVideoState extends State<HotelVideo> {
  late ThemeData _themeData;

  @override
  void didChangeDependencies() {
    _themeData = Theme.of(context);

    super.didChangeDependencies();
  }

  Widget _backgroundVideo() => BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
        buildWhen: (previous, current) =>
            current.activeDatasource == widget.model.link,
        builder: (context, VideoPlayerState state) =>
            state.cache[widget.model.link] != null
                ? FutureBuilder(
                    future: state.cache[widget.model.link]!.initializer,
                    builder: (context, snapshot) {
                      final controller =
                          state.cache[widget.model.link]!.controller;
                      if (snapshot.hasError || controller.value.hasError) {
                        return const ErrorPlaceHolder();
                      }
                      return FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox.fromSize(
                          size: controller.value.size,
                          child: VideoPlayer(controller),
                        ),
                      );
                    },
                  )
                : const SizedBox(),
      );

  Widget _buffering() => BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
        buildWhen: (previous, current) =>
            current.activeDatasource == widget.model.link,
        builder: (context, VideoPlayerState state) =>
            VideoPlayerLoadingIndicator(
          key: UniqueKey(),
          controller: state.cache[widget.model.link]?.controller,
        ),
      );

  Widget _linearGradient() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xD60F0F0F),
              Color(0x00000000),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.0, 0.3],
          ),
        ),
      );

  Widget _videoDescription() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          child: Align(
            alignment: AlignmentDirectional.bottomEnd,
            child: Row(
              children: [
                Expanded(child: _hotelName()),
                _volumnButton(),
              ],
            ),
          ),
        ),
      );

  Widget _hotelName() => Text(
        widget.model.name,
        style: _themeData.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _volumnButton() => Material(
        shape: const CircleBorder(),
        color: Colors.white38,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onVolumePressed,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
              buildWhen: (previous, current) =>
                  current.activeDatasource == widget.model.link,
              builder: (context, state) => Icon(
                (state.cache[widget.model.link]?.controller.value.volume ??
                            1) ==
                        0
                    ? Icons.volume_off
                    : Icons.volume_up,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      );

  void onVolumePressed() {
    context
        .read<VideoPlayerBloc>()
        .add(ToggleMuteVideoPlayerEvent(datasource: widget.model.link));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _backgroundVideo(),
        _buffering(),
        _linearGradient(),
        _videoDescription(),
      ],
    );
  }
}
