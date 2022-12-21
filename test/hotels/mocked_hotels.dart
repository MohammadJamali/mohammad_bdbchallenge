import 'package:mocktail/mocktail.dart';
import 'package:bdb_challenge/repositories/models/hotel.dart';
import 'package:bdb_challenge/repositories/hotels_repository.dart';

final mockedHotels = [
  {
    'id': "3sYTn4uxXenwTszZPnwK",
    'link': "https://storage.googleapis.com/travelo-91156.appspot.com"
        "/hotels/marriott_fallsview/0_reel_marriott_fallsview.mp4",
    'name': "Marriott Fallsview Niagara"
  },
  {
    'id': "EGJfAm3ZAEJJlbQ6wrol",
    'link': "https://storage.googleapis.com/travelo-91156.appspot.com"
        "/hotels/borgosantopietro/0_reel_borgosantopietro.mp4",
    'name': "Borgo Santo Pietro "
  },
  {
    'id': "PPiYsQcDAkQgqz4xkZKW",
    'link': "https://storage.googleapis.com/travelo-91156.appspot.com"
        "/hotels/hurawalhi/0_reel_hurawalhi.mp4",
    'name': "Hurawalhi Maldives"
  }
].map(HotelModel.fromJson).toList();

class MockHotelsRepository extends Mock implements HotelsRepository {}
