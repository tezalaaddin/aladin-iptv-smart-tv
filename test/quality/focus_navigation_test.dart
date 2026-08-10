import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('D-pad traversal is stable and activation fires once',
      (tester) async {
    var activations = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Row(
            children: List.generate(
              4,
              (index) => Focus(
                autofocus: index == 0,
                onKeyEvent: (_, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter) {
                    activations++;
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: Text('item-$index'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(activations, 1);
    expect(FocusManager.instance.primaryFocus, isNotNull);
  });
}
