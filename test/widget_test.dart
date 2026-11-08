import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';

void main() {
  setUp(() async {
    dotenv.loadFromString(envString: 'APP_NAME=Rawnaqk\nAPI_BASE_URL=https://api.example.com');
  });

  test('App environment loads correctly in test environment', () {
    expect(AppEnv.appName, 'Rawnaqk');
    expect(AppEnv.apiBaseUrl, 'https://api.example.com');
  });
}
