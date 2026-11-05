/// UI/Domain failure representations mapped from exceptions.
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'تعذر الاتصال بالخادم، يرجى التحقق من اتصالك'});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'يرجى تسجيل الدخول مجدداً'});
}

