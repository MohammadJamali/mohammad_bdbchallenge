import 'package:bdb_challenge/widgets/loading_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerLoadingIndicator extends StatefulWidget {
  const VideoPlayerLoadingIndicator({
    super.key,
    this.controller,
  });

  final VideoPlayerController? controller;

  @override
  State<VideoPlayerLoadingIndicator> createState() =>
      _VideoPlayerLoadingIndicatorState();
}

class _VideoPlayerLoadingIndicatorState
    extends State<VideoPlayerLoadingIndicator> {
  late bool showIndicator = widget.controller == null;

  @override
  void initState() {
    widget.controller?.addListener(listener);
    super.initState();
  }

  void listener() {
    if (!mounted) {
      widget.controller?.removeListener(listener);
      return;
    }

    final condition = (widget.controller?.value.isBuffering ?? true) ||
        !(widget.controller?.value.isInitialized ?? false);
    if (showIndicator != condition) {
      setState(() {
        showIndicator = condition;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return showIndicator
        ? const Align(
            alignment: Alignment.center,
            child: LoadingPlaceholder(),
          )
        : const SizedBox();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(listener);
    super.dispose();
  }
}
