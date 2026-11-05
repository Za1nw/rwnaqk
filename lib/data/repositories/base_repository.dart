import 'package:rwnaqk_frontend/core/errors/exceptions.dart';
import 'package:rwnaqk_frontend/core/errors/failures.dart';

/// Base repository encapsulating error translation from Exceptions to Failures.
abstract class BaseRepository {
  /// Safely execute an asynchronous data operation and translate exceptions into Failures.
  Future<T> safeCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(message: e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}

