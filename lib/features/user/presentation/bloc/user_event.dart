import '../../domain/entities/user_entity.dart';

abstract class UserEvent {
  const UserEvent();
}

class LoadUsersEvent extends UserEvent {
  final bool reset;
  const LoadUsersEvent({this.reset = false});
}

class LoadMoreUsersEvent extends UserEvent {
  const LoadMoreUsersEvent();
}

class CreateUserEvent extends UserEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String? avatarUrl;

  const CreateUserEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.avatarUrl,
  });
}

class UpdateUserEvent extends UserEvent {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final int status;
  final String? avatarUrl;

  const UpdateUserEvent({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.status,
    this.avatarUrl,
  });
}

class DeleteUserEvent extends UserEvent {
  final UserEntity user;
  const DeleteUserEvent(this.user);
}
