import 'package:bdb_challenge/app/hotels/bloc/hotel_bloc.dart';
import 'package:bdb_challenge/app/hotels/view/hotel.dart';
import 'package:bdb_challenge/firebase_options.dart';
import 'package:bdb_challenge/repositories/hotels_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  HotelsRepository _createRepository(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    return HotelsRepository(firestore: firestore);
  }

  HotelBloc _createHotelBloc(BuildContext context) {
    final repository = context.read<HotelsRepository>();
    final bloc = HotelBloc(repository: repository);

    bloc.add(LoadHotelsEvent());

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: _createRepository,
      child: BlocProvider(
        create: _createHotelBloc,
        child: MaterialApp(
          title: 'Beautiful Hotels',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const HotelsPage(),
        ),
      ),
    );
  }
}
