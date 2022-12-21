import 'package:bdb_challenge/widgets/error_placeholder.dart';
import 'package:video_player/video_player.dart';

import 'mocked_hotels.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bdb_challenge/app/hotels/hotels.dart';
import 'package:bdb_challenge/widgets/empty_list_placeholder.dart';

Future<void> pumpHotelWidget(
  WidgetTester tester,
  MockHotelsRepository repository,
) async {
  await tester.pumpWidget(
    RepositoryProvider(
      create: (_) => repository,
      child: BlocProvider<HotelBloc>(
        create: (_) =>
            HotelBloc(repository: repository)..add(LoadHotelsEvent()),
        child: const MaterialApp(
          home: HotelsPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Hotel View', () {
    testWidgets(
      "Empty video list",
      (tester) async {
        final repository = MockHotelsRepository();
        when(() => repository.hotels())
            .thenAnswer((invocation) async => const []);

        await pumpHotelWidget(tester, repository);

        expect(find.text('Empty List'), findsOneWidget);
        expect(find.byType(EmptyListPlaceholder), findsOneWidget);
      },
    );

    testWidgets(
      "Show video list",
      (tester) async {
        // Mock the hotel repository
        final repository = MockHotelsRepository();
        when(() => repository.hotels())
            .thenAnswer((invocation) async => mockedHotels);

        // pump the main widget and providers using the mocked repository
        await pumpHotelWidget(tester, repository);

        // wait for the `PageView` widget to be build
        await expectLater(find.byType(PageView), findsOneWidget);

        // for each hotel a fullscreen HotelPage is expected
        await expectLater(find.byType(HotelVideo), findsWidgets);

        for (var hotel in mockedHotels) {
          // Wait for bloc event to emit
          await expectLater(
              find.widgetWithText(Row, hotel.name), findsOneWidget);

          int attemps = 0;
          List<Element> videoPlayers;
          do {
            // check if the video player is inilized correctly
            videoPlayers = find
                .byType(VideoPlayer)
                .evaluate()
                .where(
                  (element) =>
                      (element.widget as VideoPlayer).controller.dataSource ==
                      hotel.link,
                )
                .toList();
            if (videoPlayers.isEmpty) {
              // if it doesn't have a change to rebuild itself wait for 1 sec
              await tester.pump(const Duration(seconds: 1));
            }
            // limit the number of attempts to `10`
            expect(++attemps, lessThanOrEqualTo(10));

            // and loop until one VideoPlayer widget with correct configuration
            // apears
          } while (videoPlayers.isEmpty);

          // Simulate a vertical scroll gesture by dragging the page down
          await tester.drag(find.byType(PageView), const Offset(0.0, -500.0));

          // Wait for the widget tree to be rebuilt
          await tester.pump(const Duration(seconds: 1));
        }
      },
    );
  });

  testWidgets(
    "Error while fetching from repository",
    (tester) async {
      final repository = MockHotelsRepository();
      when(() => repository.hotels()).thenThrow(Exception("error"));

      await pumpHotelWidget(tester, repository);

      await expectLater(find.byType(ErrorPlaceHolder), findsOneWidget);
    },
  );
}
