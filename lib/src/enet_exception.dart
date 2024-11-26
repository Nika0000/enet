/// {@template enet_exception}
///
/// Represents an exception thrown by the ENet library.
///
/// This exception is used to encapsulate errors that occur during
/// ENet operations.
///
/// {@endtemplate}
class ENetException implements Exception {
  /// {@macro enet_exception}
  const ENetException(this.message, {this.code = 0});

  /// Throws an [ENetException] if the result is negative.
  ///
  /// This is a utility method for checking the result of an ENet operation.
  /// If the result is less than zero, it throws an `ENetException` with
  /// the provided [message] or a default one. Optionally, a custom [code]
  /// can be included for better error categorization.
  ///
  /// - [result]: The result of the ENet operation to evaluate.
  /// - [message]: Optional custom message to describe the error.
  /// - [code]: Optional error code (default is 0).
  static void throwIfError({
    required int result,
    String? message,
    int code = 0,
  }) {
    if (result < 0) {
      throw ENetException(
        message ?? 'Operation failed with code $result.',
        code: code,
      );
    }
  }

  /// The error code associated with this exception.
  final int code;

  /// A descriptive error message for the exception.
  final String message;

  @override
  String toString() {
    if (code < 0) {
      return 'ENetException $code: $message';
    }

    return 'ENetException: $message';
  }
}
