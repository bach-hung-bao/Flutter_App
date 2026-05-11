import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/user_usecases.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUsersUseCase getUsers;
  final CreateUserUseCase createUser;
  final UpdateUserUseCase updateUser;
  final DeleteUserUseCase deleteUser;

  UserBloc({
    required this.getUsers,
    required this.createUser,
    required this.updateUser,
    required this.deleteUser,
  }) : super(const UserState()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onLoadUsers(
      LoadUsersEvent event, Emitter<UserState> emit) async {
    if (event.reset) {
      emit(state.copyWith(
        users: [],
        pageIndex: 1,
        totalCount: 0,
        error: '',
        isLoading: true,
      ));
    } else {
      emit(state.copyWith(isLoading: true, error: ''));
    }

    try {
      final (items, total) = await getUsers.execute(
        pageIndex: state.pageIndex,
        pageSize: state.pageSize,
      );
      emit(state.copyWith(
        users: event.reset ? items : [...state.users, ...items],
        totalCount: total,
        isLoading: false,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
        isLoadingMore: false,
      ));
    }
  }

  Future<void> _onLoadMoreUsers(
      LoadMoreUsersEvent event, Emitter<UserState> emit) async {
    if (state.isLoadingMore || state.users.length >= state.totalCount) return;

    emit(state.copyWith(
      isLoadingMore: true,
      pageIndex: state.pageIndex + 1,
    ));

    try {
      final (items, total) = await getUsers.execute(
        pageIndex: state.pageIndex,
        pageSize: state.pageSize,
      );
      emit(state.copyWith(
        users: [...state.users, ...items],
        totalCount: total,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        // Giữ nguyên users, có thể show snackbar error ở view
      ));
    }
  }

  Future<void> _onCreateUser(
      CreateUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(isSubmitting: true, submitError: '', submitSuccess: false));
    try {
      await createUser.execute(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
        password: event.password,
        avatarUrl: event.avatarUrl,
      );
      emit(state.copyWith(isSubmitting: false, submitSuccess: true));
      // Tải lại danh sách
      add(const LoadUsersEvent(reset: true));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, submitError: e.toString()));
    }
  }

  Future<void> _onUpdateUser(
      UpdateUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(isSubmitting: true, submitError: '', submitSuccess: false));
    try {
      await updateUser.execute(
        id: event.id,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        status: event.status,
        avatarUrl: event.avatarUrl,
      );
      emit(state.copyWith(isSubmitting: false, submitSuccess: true));
      // Tải lại danh sách
      add(const LoadUsersEvent(reset: true));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, submitError: e.toString()));
    }
  }

  Future<void> _onDeleteUser(
      DeleteUserEvent event, Emitter<UserState> emit) async {
    try {
      await deleteUser.execute(event.user.id);
      // Cập nhật state lạc quan
      final updatedUsers = state.users.where((u) => u.id != event.user.id).toList();
      emit(state.copyWith(
        users: updatedUsers,
        totalCount: state.totalCount - 1,
      ));
    } catch (e) {
      // Có thể emit lỗi để view show snackbar
    }
  }
}
