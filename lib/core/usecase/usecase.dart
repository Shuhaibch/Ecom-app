import 'package:ecom/core/utils/result.dart';

abstract interface class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

final class NoParams {
  const NoParams();
}
