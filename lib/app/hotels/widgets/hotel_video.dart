import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:bdb_challenge/repositories/models/hotel.dart';
import 'package:bdb_challenge/widgets/error_placeholder.dart';
import 'package:bdb_challenge/widgets/loading_placeholder.dart';

class HotelVideo extends StatefulWidget {
  const HotelVideo({super.key, required this.model});

  final HotelModel model;

  @override
  State<HotelVideo> createState() => _HotelVideoState();
}

class _HotelVideoState extends State<HotelVideo> {
  late ThemeData _themeData;

  VideoPlayerController? _playerController;
  late Future _playerFuture;

  @override
  void initState() {
    _playerFuture = initalizeController();
    super.initState();
  }

  Future<void> initalizeController() async {
    await _playerController?.dispose();

    _playerController = VideoPlayerController.network(widget.model.link);

    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      await _playerController!.initialize();
    }

    await _playerController!.setLooping(true);
    await _playerController!.play();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    _themeData = Theme.of(context);

    super.didChangeDependencies();
  }

  Widget _backgroundVideo() => FutureBuilder(
        future: _playerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError ||
              (_playerController?.value.hasError ?? false)) {
            return const ErrorPlaceHolder();
          }

          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const LoadingPlaceholder();
            case ConnectionState.active:
            case ConnectionState.done:
              return FittedBox(
                fit: BoxFit.cover,
                child: SizedBox.fromSize(
                  size: _playerController!.value.size,
                  child: VideoPlayer(_playerController!),
                ),
              );
          }
        },
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
          onTap: _playerController?.value.isInitialized == true
              ? onVolumePressed
              : null,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              _playerController?.value.volume == 0
                  ? Icons.volume_off
                  : Icons.volume_up,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );

  void onVolumePressed() {
    setState(() {
      _playerController?.setVolume(
        _playerController?.value.volume == 0 ? 1 : 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _backgroundVideo(),
        _linearGradient(),
        _videoDescription(),
      ],
    );
  }

  @override
  void dispose() {
    _playerController?.dispose();
    super.dispose();
  }
}
