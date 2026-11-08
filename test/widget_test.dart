import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';

void main() {
  setUp(() async {
    dotenv.loadFromString(
      envString: 'APP_NAME=Rawnaqk\nAPI_BASE_URL=https://api.example.com',
    );
  });

  test('App environment loads correctly in test environment', () {
    expect(AppEnv.appName, 'Rawnaqk');
    expect(AppEnv.apiBaseUrl, 'https://api.example.com');
  });

  test('Decouples Build Mode from App Environment and blocks Mock Data in Production', () {
    // 1. Production strictly blocks mock data
    dotenv.loadFromString(
      envString: 'APP_ENV=production\nENABLE_MOCK_DATA=true',
    );
    expect(AppEnv.isProduction, isTrue);
    expect(AppEnv.enableMockData, isFalse);

    // 2. Staging allows mock data when explicitly configured
    dotenv.loadFromString(
      envString: 'APP_ENV=staging\nENABLE_MOCK_DATA=true',
    );
    expect(AppEnv.isStaging, isTrue);
    expect(AppEnv.isProduction, isFalse);
    expect(AppEnv.enableMockData, isTrue);

    // 3. Staging disables mock data when set to false or unset
    dotenv.loadFromString(
      envString: 'APP_ENV=staging\nENABLE_MOCK_DATA=false',
    );
    expect(AppEnv.enableMockData, isFalse);

    // 4. Development defaults to mock data enabled
    dotenv.loadFromString(
      envString: 'APP_ENV=development',
    );
    expect(AppEnv.isDevelopment, isTrue);
    expect(AppEnv.enableMockData, isTrue);
  });
}

