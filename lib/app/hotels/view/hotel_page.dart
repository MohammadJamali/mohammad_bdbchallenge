import 'package:bdb_challenge/app/hotels/bloc/hotel_bloc.dart';
import 'package:bdb_challenge/app/hotels/widget/hotel_video.dart';
import 'package:bdb_challenge/repositories/models/enums/bloc_status.dart';
import 'package:bdb_challenge/widgets/error_placeholder.dart';
import 'package:bdb_challenge/widgets/loading_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HotelsPage extends StatelessWidget {
  const HotelsPage({super.key});

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
              return const LoadingPlaceholder();
            case BlocStatus.finished:
              return PageView.builder(
                itemCount: state.hotels.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) => HotelVideoView(
                  model: state.hotels[index],
                ),
              );
            case BlocStatus.failed:
              return const ErrorPlaceHolder();
          }
        },
      ),
    );
  }
}
