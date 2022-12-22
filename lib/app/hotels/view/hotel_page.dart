import 'package:bdb_challenge/app/hotels/bloc/hotel/hotel_bloc.dart';
import 'package:bdb_challenge/app/hotels/bloc/video_controller/video_controller_bloc.dart';
import 'package:bdb_challenge/repositories/models/hotel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdb_challenge/widgets/error_placeholder.dart';
import 'package:bdb_challenge/widgets/loading_placeholder.dart';
import 'package:bdb_challenge/app/hotels/widgets/hotel_video.dart';
import 'package:bdb_challenge/widgets/empty_list_placeholder.dart';
import 'package:bdb_challenge/repositories/models/enums/bloc_status.dart';

class HotelsPage extends StatefulWidget {
  const HotelsPage({super.key});

  @override
  State<HotelsPage> createState() => _HotelsPageState();
}

class _HotelsPageState extends State<HotelsPage> {
  bool initialPageBuild = true;
  Widget buildPage(BuildContext context, HotelModel model) {
    if (initialPageBuild) {
      final videoPlayerBloc = context.read<VideoPlayerBloc>();
      if (videoPlayerBloc.state.activeDatasource == "") {
        videoPlayerBloc.add(RequestVideoPlayer(datasource: model.link));
      }
      initialPageBuild = false;
    }
    return HotelVideo(model: model);
  }

  void onPageChanged(HotelModel model) {
    context
        .read<VideoPlayerBloc>()
        .add(RequestVideoPlayer(datasource: model.link));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HotelBloc, HotelState>(
        buildWhen: (previous, current) =>
            current.status != previous.status ||
            current.hotels != previous.hotels,
        builder: (context, state) {
          switch (state.status) {
            case BlocStatus.initial:
            case BlocStatus.loading:
              return const Center(child: LoadingPlaceholder());
            case BlocStatus.finished:
              if (state.hotels.isEmpty) {
                return const EmptyListPlaceholder();
              }

              return PageView.builder(
                itemCount: state.hotels.length,
                scrollDirection: Axis.vertical,
                onPageChanged: (index) => onPageChanged(state.hotels[index]),
                itemBuilder: (context, index) =>
                    buildPage(context, state.hotels[index]),
              );
            case BlocStatus.failed:
              return const ErrorPlaceHolder();
          }
        },
      ),
    );
  }
}
