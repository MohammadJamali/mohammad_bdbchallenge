import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'hotel.g.dart';

@JsonSerializable()
class HotelModel extends Equatable {
  const HotelModel({
    required this.id,
    required this.name,
    required this.link,
  });

  final String id;
  final String name;
  final String link;

  @override
  List<Object?> get props => [id];

  factory HotelModel.fromJson(Map<String, dynamic> json) =>
      _$HotelModelFromJson(json);

  Map<String, dynamic> toJson() => _$HotelModelToJson(this);
}
