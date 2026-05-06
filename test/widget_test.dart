import 'package:flutter_test/flutter_test.dart';
import 'package:admin_patitas/main.dart';

void main() {
  test('App route table contains critical routes', () {
    expect(appRoutes.containsKey('/login'), isTrue);
    expect(appRoutes.containsKey('/register'), isTrue);
    expect(appRoutes.containsKey('/adoptions'), isTrue);
  });
}
