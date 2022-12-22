import 'package:bdb_challenge/repositories/hotels_repository.dart';
import 'package:bdb_challenge/repositories/models/hotel.dart';
import 'package:bdb_challenge/repositories/models/enums/bloc_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'hotel_event.dart';
part 'hotel_state.dart';

class HotelBloc extends Bloc<HotelEvent, HotelState> {
  HotelBloc({
    required this.repository,
  }) : super(const HotelState()) {
    on<LoadHotelsEvent>(_loadHotels);
  }

  final HotelsRepository repository;

  Future<void> _loadHotels(
    LoadHotelsEvent event,
    Emitter<HotelState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading));
    try {
      emit(
        state.copyWith(
          status: BlocStatus.finished,
          hotels: await repository.hotels(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: BlocStatus.failed));
    }
  }
}
