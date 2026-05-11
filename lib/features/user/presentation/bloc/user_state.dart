import '../../domain/entities/user_entity.dart';

class UserState {
  final List<UserEntity> users;
  final bool isLoading;
  final bool isLoadingMore;
  final String error;
  final int pageIndex;
  final int totalCount;
  final int pageSize;

  final bool isSubmitting;
  final String submitError;
  final bool submitSuccess;

  const UserState({
    this.users = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error = '',
    this.pageIndex = 1,
    this.totalCount = 0,
    this.pageSize = 20,
    this.isSubmitting = false,
    this.submitError = '',
    this.submitSuccess = false,
  });

  UserState copyWith({
    List<UserEntity>? users,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? pageIndex,
    int? totalCount,
    int? pageSize,
    bool? isSubmitting,
    String? submitError,
    bool? submitSuccess,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      pageIndex: pageIndex ?? this.pageIndex,
      totalCount: totalCount ?? this.totalCount,
      pageSize: pageSize ?? this.pageSize,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError ?? this.submitError,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }
}
