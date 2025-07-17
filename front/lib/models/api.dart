class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse.success({required this.data, this.statusCode})
    : success = true,
      message = null;

  ApiResponse.error({required this.message, this.statusCode})
    : success = false,
      data = null;
}