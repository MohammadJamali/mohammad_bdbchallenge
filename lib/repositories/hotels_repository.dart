import 'package:bdb_challenge/repositories/models/hotel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HotelsRepository {
  const HotelsRepository({
    required this.firestore,
  });

  final FirebaseFirestore firestore;

  Future<List<HotelModel>> hotels() async {
    try {
      final reponse = await firestore.collection('hotels').get();
      final result = reponse.docs.map((hotel) {
        final dictionary = hotel.data();
        dictionary['id'] = hotel.id;
        return HotelModel.fromJson(dictionary);
      }).toList();
      return result;
    } catch (e) {
      throw Exception(e);
    }
  }
}
