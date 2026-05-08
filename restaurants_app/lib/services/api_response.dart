class ApiResponse<T> {
  final T? data;
  final String? error;

  const ApiResponse._({this.data, this.error});

  bool get isSuccess => error == null;

  factory ApiResponse.success(T data) => ApiResponse._(data: data);

  factory ApiResponse.failure(String error) => ApiResponse._(error: error);
}
