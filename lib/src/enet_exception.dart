class ENetException implements Exception {
  final int code;
  final String message;

  const ENetException(this.message, {this.code = 0});

  @override
  String toString() {
    if (code < 0) {
      return 'ENetException $code: $message';
    }

    return 'ENetException: $message';
  }

  void throwIfError() {}
}
