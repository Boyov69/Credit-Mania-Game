import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:credit_mania/widgets/animated_card_display.dart';
import 'package:credit_mania/models/card.dart';
import 'package:mockito/mockito.dart';

void main() {
  testWidgets('AnimatedCardDisplay shows card front by default', (WidgetTester tester) async {
    // Create a test card
    final testCard = AssetCard(
      id: 'test_asset_1',
      name: 'Test Asset',
      starLevel: 1,
      cost: 20,
      cpOnPurchase: 2,
      cpPerRound: 0,
      incomePerRound: 3,
      debtUpkeep: 1,
      imageAsset: 'assets/images/test_asset.png',
    );
    
    bool onTapCalled = false;
    
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 300,
              child: AnimatedCardDisplay(
                card: testCard,
                onTap: () {
                  onTapCalled = true;
                },
                animate: false, // Disable animation for testing
              ),
            ),
          ),
        ),
      ),
    );
    
    // Wait for animations to complete
    await tester.pumpAndSettle();
    
    // Verify card front is displayed
    expect(find.text('Test Asset'), findsOneWidget);
    expect(find.text('Cost: 20'), findsOneWidget);
    expect(find.text('CP: +2'), findsOneWidget);
    expect(find.text('Income: +3/round'), findsOneWidget);
    expect(find.text('Debt: +1/round'), findsOneWidget);
    
    // Tap the card to flip it
    await tester.tap(find.byType(AnimatedCardDisplay));
    await tester.pumpAndSettle();
    
    // Verify card back is displayed (card type name should be visible)
    expect(find.text('Asset Card'), findsOneWidget);
    
    // Tap again to flip back to front
    await tester.tap(find.byType(AnimatedCardDisplay));
    await tester.pumpAndSettle();
    
    // Verify card front is displayed again
    expect(find.text('Test Asset'), findsOneWidget);
    
    // Verify onTap callback was called
    expect(onTapCalled, isTrue);
  });
  
  testWidgets('AnimatedCardDisplay shows different colors for different card types', (WidgetTester tester) async {
    // Create test cards of different types
    final assetCard = AssetCard(
      id: 'test_asset_1',
      name: 'Test Asset',
      starLevel: 1,
      cost: 20,
      cpOnPurchase: 2,
      cpPerRound: 0,
      incomePerRound: 3,
      debtUpkeep: 1,
      imageAsset: 'assets/images/test_asset.png',
    );
    
    final eventCard = EventCard(
      id: 'test_event_1',
      name: 'Test Event',
      description: 'Test event description',
      phase: 0,
      effect: (players) {},
      imageAsset: 'assets/images/test_event.png',
    );
    
    final lifeCard = LifeCard(
      id: 'test_life_1',
      name: 'Test Life Card',
      description: 'Test life card description',
      effect: (player) {},
      imageAsset: 'assets/images/test_life.png',
    );
    
    // Build and test asset card
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 300,
              child: AnimatedCardDisplay(
                card: assetCard,
                onTap: () {},
                animate: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Test Asset'), findsOneWidget);
    
    // Build and test event card
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 300,
              child: AnimatedCardDisplay(
                card: eventCard,
                onTap: () {},
                animate: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Test Event'), findsOneWidget);
    expect(find.text('Test event description'), findsOneWidget);
    
    // Build and test life card
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 300,
              child: AnimatedCardDisplay(
                card: lifeCard,
                onTap: () {},
                animate: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Test Life Card'), findsOneWidget);
    expect(find.text('Test life card description'), findsOneWidget);
  });
}
