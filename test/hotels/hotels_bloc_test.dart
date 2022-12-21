import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bdb_challenge/app/hotels/hotels.dart';
import 'package:bdb_challenge/repositories/models/enums/bloc_status.dart';

import 'mocked_hotels.dart';

void main() {
  group('Hotel Bloc', () {
    late HotelBloc bloc;
    late MockHotelsRepository repository;

    setUp(() {
      repository = MockHotelsRepository();
      bloc = HotelBloc(repository: repository);
    });

    test('initial state test', () {
      expect(bloc.state, const HotelState());
    });

    blocTest<HotelBloc, HotelState>(
      'empty list of hotel',
      setUp: () => when(
        () => repository.hotels(),
      ).thenAnswer((invocation) async => const []),
      build: () => HotelBloc(repository: repository),
      act: (bloc) => bloc.add(LoadHotelsEvent()),
      expect: () => contains(const HotelState(status: BlocStatus.finished)),
    );

    blocTest<HotelBloc, HotelState>(
      'hotels fetched',
      setUp: () => when(
        () => repository.hotels(),
      ).thenAnswer((invocation) async => mockedHotels),
      build: () => HotelBloc(repository: repository),
      act: (bloc) => bloc.add(LoadHotelsEvent()),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        const HotelState(status: BlocStatus.loading),
        HotelState(status: BlocStatus.finished, hotels: mockedHotels),
      ],
    );
  });
}
