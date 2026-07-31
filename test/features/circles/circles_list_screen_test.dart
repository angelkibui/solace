import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solace/core/theme/app_theme.dart';
import 'package:solace/features/circles/data/models/circle_model.dart';
import 'package:solace/features/circles/data/repositories/circle_repository.dart';
import 'package:solace/features/circles/presentation/bloc/circle_bloc.dart';
import 'package:solace/features/circles/presentation/bloc/circle_event.dart';
import 'package:solace/features/circles/presentation/pages/circles_list_screen.dart';

void main() {
  testWidgets('lists, filters, joins, and opens a circle on a small phone',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final firestore = FakeFirebaseFirestore();
    final circle = CircleModel(
      id: 'anxiety-support',
      name: 'Anxiety Support',
      description: 'Share coping strategies in a moderated space.',
      category: 'Anxiety Support',
      memberCount: 12,
      isModerated: true,
      moderatorName: 'Diane Uwase',
      createdAt: DateTime.utc(2026, 7, 31),
      imageUrl: '',
    );
    await firestore.collection('circles').doc(circle.id).set(circle.toMap());
    final bloc = CircleBloc(
      CircleRepository(firestore: firestore),
      userId: 'user-1',
    )..add(const CirclesRequested());
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider.value(
          value: bloc,
          child: const CirclesListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Community Circles'), findsOneWidget);
    expect(find.text('Anxiety Support'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();
    expect(find.text('Leave'), findsOneWidget);

    await tester.tap(find.text('My Circles'));
    await tester.pumpAndSettle();
    expect(find.text('Anxiety Support'), findsWidgets);

    await tester.tap(find.text('Anxiety Support').last);
    await tester.pumpAndSettle();
    expect(find.text('About this circle'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(640, 360);
    await tester.pumpAndSettle();
    expect(find.text('About this circle'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
