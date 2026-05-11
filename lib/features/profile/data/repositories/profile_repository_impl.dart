import '../../domain/repositories/profile_repository.dart';
import '../datasources/remote/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> updateProfile({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    String? dateOfBirth,
  }) async {
    return await remoteDataSource.updateProfile(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      dateOfBirth: dateOfBirth,
    );
  }

  @override
  Future<void> updateAvatar({
    required List<int> bytes,
    required String fileName,
  }) async {
    return await remoteDataSource.updateAvatar(
      bytes: bytes,
      fileName: fileName,
    );
  }

  @override
  Future<void> addFcmToken(String tokenValue) async {
    return await remoteDataSource.addFcmToken(tokenValue);
  }
}
