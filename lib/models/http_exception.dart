class HttpException implements Exception {
  final String errMessage;

  HttpException(this.errMessage);

  @override
  String toString() {
    return this.errMessage;
  }
}
