import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  String get apiUrl => dotenv.env['API_URL'] ?? 'http://192.168.8.117:8000/api/gold/app/master';
  String get appMode => dotenv.env['APP_MODE'] ?? 'development';
  String get databaseName => dotenv.env['DATABASE_NAME'] ?? 'app.db';
  String get apiKey => dotenv.env['API_KEY'] ?? '';
  String get secretKey => dotenv.env['SECRET_KEY'] ?? '';

  bool get isProduction => appMode == 'production';
  bool get isDevelopment => appMode == 'development';


  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }

  static final Environment _instance = Environment._internal();
  factory Environment() {
    return _instance;
  }
  Environment._internal();

  static final Environment instance = Environment();

  @override
  String toString() {
    return 'Environment(apiUrl: $apiUrl, appMode: $appMode, apiKey: $apiKey)';  
  }
}
