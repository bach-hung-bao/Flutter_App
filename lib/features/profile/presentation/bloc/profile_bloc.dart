import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateProfileUseCase updateProfile;

  ProfileBloc({required this.updateProfile}) : super(ProfileInitial()) {
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileUpdating());
    try {
      await updateProfile.execute(
        id: event.userId,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        dateOfBirth: event.dateOfBirth,
      );
      emit(ProfileUpdateSuccess());
    } catch (e) {
      emit(ProfileUpdateFailure(e.toString()));
    }
  }
}
