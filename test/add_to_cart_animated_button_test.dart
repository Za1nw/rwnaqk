import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk/widgets/common/add_to_cart_animated_button.dart';

void main() {
  Widget buildSubject({
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AddToCartAnimatedButton(
            label: 'Add to cart',
            onPressed: onPressed,
            isLoading: isLoading,
          ),
        ),
      ),
    );
  }

  testWidgets('shows loading indicator and ignores taps while loading', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      buildSubject(
        onPressed: () => tapCount++,
        isLoading: true,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(tapCount, 0);
  });

  testWidgets('stays disabled when callback is null', (tester) async {
    await tester.pumpWidget(buildSubject(onPressed: null));

    final button = tester.widget<InkWell>(find.byType(InkWell));
    expect(button.onTap, isNull);
  });

  testWidgets('runs callback after the animation completes', (tester) async {
    var tapCount = 0;

    await tester.pumpWidget(
      buildSubject(
        onPressed: () => tapCount++,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(tapCount, 0);

    await tester.pumpAndSettle();

    expect(tapCount, 1);
  });
}
