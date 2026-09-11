import 'errors.dart';

/// A lightweight result type for use-case returns where throwing is not
/// desired (e.g. batch sync results). Domain invariants still throw
/// [AppError]; [Result] is for orchestration layers that collect outcomes.
sealed class Result<T> {
  const Result();

  factory Result.ok(T value) = Ok<T>;
  factory Result.err(AppError error) = Err<T>;

  bool get isOk => this is Ok<T>;

  R fold<R>(R Function(T value) onOk, R Function(AppError error) onErr) =>
      switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final error) => onErr(error),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.error);
  final AppError error;
}
