import 'package:flutter_test/flutter_test.dart';

import 'package:fall_festival_guest_roster/database_helper.dart';
import 'package:fall_festival_guest_roster/folder.dart';
import 'package:fall_festival_guest_roster/main.dart';
import 'package:fall_festival_guest_roster/repository.dart';

class FakeDatabaseHelper extends DatabaseHelper {}

class FakeRepository extends Repository {
  FakeRepository() : super(FakeDatabaseHelper());

  @override
  Future<List<Folder>> getFolders() async => const [];
}

void main() {
  testWidgets('app shows folders screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(repository: FakeRepository()));

    expect(find.text('Folders'), findsOneWidget);
  });
}
