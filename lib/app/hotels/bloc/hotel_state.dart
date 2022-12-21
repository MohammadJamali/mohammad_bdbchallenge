part of 'hotel_bloc.dart';

class HotelState extends Equatable {
  const HotelState({
    this.status = BlocStatus.initial,
    this.hotels = const [],
  });

  final BlocStatus status;
  final List<HotelModel> hotels;

  @override
  List<Object?> get props => [status, hotels];

  HotelState copyWith({
    BlocStatus? status,
    List<HotelModel>? hotels,
  }) =>
      HotelState(
        status: status ?? this.status,
        hotels: hotels ?? this.hotels,
      );
}
