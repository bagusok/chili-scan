sealed class AppResult<T> {
  const AppResult();
}

class AppSuccess<T> extends AppResult<T> {
  final T data;
  const AppSuccess(this.data);
}

class AppFailure<T> extends AppResult<T> {
  final String message;
  const AppFailure(this.message);
}
