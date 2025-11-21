class LoginState {
  final bool isLoading;
  final bool isLogged;
  final String? errorMessage;

  const LoginState({
    this.isLoading = false,
    this.isLogged = false,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isLogged,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isLogged: isLogged ?? this.isLogged,
      errorMessage: errorMessage,
    );
  }
}
