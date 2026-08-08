import 'package:ecom/core/error/failures.dart';

sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) ok,
    required R Function(Failure failure) err,
  }) => switch (this) {
    Ok<T>(:final value) => ok(value),
    Err<T>(:final failure) => err(failure),
  };
}

final class Ok<T> extends Result<T> {
  final T value;

  const Ok(this.value);
}

final class Err<T> extends Result<T> {
  final Failure failure;

  const Err(this.failure);
}
