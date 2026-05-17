import 'package:get_it/get_it.dart';

import 'core/network/api_client.dart';
import 'features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/data/datasources/remote/home_remote_data_source.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/get_home_recommendations_usecase.dart';
import 'features/home/domain/usecases/get_provinces_usecase.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

import 'features/hotel/data/datasources/remote/hotel_remote_data_source.dart';
import 'features/hotel/data/repositories/hotel_repository_impl.dart';
import 'features/hotel/domain/repositories/hotel_repository.dart';
import 'features/hotel/domain/usecases/get_hotel_by_id_usecase.dart';
import 'features/hotel/presentation/bloc/hotel_bloc.dart';

import 'features/booking/data/datasources/remote/booking_remote_data_source.dart';
import 'features/booking/data/repositories/booking_repository_impl.dart';
import 'features/booking/domain/repositories/booking_repository.dart';
import 'features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'features/booking/domain/usecases/create_booking_usecase.dart';
import 'features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'features/booking/domain/usecases/get_rooms_usecase.dart';
import 'features/booking/domain/usecases/get_time_slots_usecase.dart';
import 'features/booking/domain/usecases/update_booking_status_usecase.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';

import 'features/favorite/data/datasources/remote/favorite_remote_data_source.dart';
import 'features/favorite/data/repositories/favorite_repository_impl.dart';
import 'features/favorite/domain/repositories/favorite_repository.dart';
import 'features/favorite/domain/usecases/check_favorite_usecase.dart';
import 'features/favorite/domain/usecases/get_favorites_usecase.dart';
import 'features/favorite/domain/usecases/toggle_favorite_usecase.dart';
import 'features/favorite/presentation/bloc/favorite_bloc.dart';

import 'features/profile/data/datasources/remote/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

import 'features/review/data/datasources/remote/review_remote_data_source.dart';
import 'features/review/data/repositories/review_repository_impl.dart';
import 'features/review/domain/repositories/review_repository.dart';
import 'features/review/domain/usecases/create_review_usecase.dart';
import 'features/review/presentation/bloc/review_bloc.dart';

import 'features/search/data/datasources/remote/search_remote_data_source.dart';
import 'features/search/data/repositories/search_repository_impl.dart';
import 'features/search/domain/repositories/search_repository.dart';
import 'features/search/domain/usecases/search_usecases.dart';
import 'features/search/presentation/bloc/search_bloc.dart';

import 'features/user/data/datasources/remote/user_remote_data_source.dart';
import 'features/user/data/repositories/user_admin_repository_impl.dart';
import 'features/user/domain/repositories/user_admin_repository.dart';
import 'features/user/domain/usecases/user_usecases.dart';
import 'features/user/presentation/bloc/user_bloc.dart';

import 'features/notification/data/datasources/remote/notification_remote_data_source.dart';
import 'features/notification/data/repositories/notification_repository_impl.dart';
import 'features/notification/domain/repositories/notification_repository.dart';
import 'features/notification/domain/usecases/notification_usecases.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Features
  // Home
  sl.registerFactory(
    () => HomeBloc(getRecommendations: sl(), getProvinces: sl()),
  );
  sl.registerLazySingleton(() => GetHomeRecommendationsUseCase(sl()));
  sl.registerLazySingleton(() => GetProvincesUseCase(sl()));
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSource(client: sl()),
  );

  // Auth
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), registerUseCase: sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(client: sl()),
  );

  // Booking
  sl.registerFactory(
    () => BookingBloc(
      getMyBookings: sl(),
      cancelBooking: sl(),
      createBooking: sl(),
      getRoomsByHotel: sl(),
      getTimeSlotsByRoom: sl(),
      updateBookingStatus: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetMyBookingsUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));
  sl.registerLazySingleton(() => CreateBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetRoomsByHotelIdUseCase(sl()));
  sl.registerLazySingleton(() => GetTimeSlotsByRoomIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBookingStatusUseCase(sl()));
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSource(client: sl()),
  );

  // Favorite
  sl.registerFactory(
    () => FavoriteBloc(getFavorites: sl(), toggleFavorite: sl()),
  );
  sl.registerLazySingleton(() => CheckFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<FavoriteRemoteDataSource>(
    () => FavoriteRemoteDataSource(client: sl()),
  );

  // Profile
  sl.registerFactory(() => ProfileBloc(updateProfile: sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAvatarUseCase(sl()));
  sl.registerLazySingleton(() => AddFcmTokenUseCase(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(client: sl()),
  );

  // Review
  sl.registerFactory(() => ReviewBloc(createReview: sl()));
  sl.registerLazySingleton(() => CreateReviewUseCase(sl()));
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSource(client: sl()),
  );

  // Search
  sl.registerFactory(
    () => SearchBloc(
      getFeaturedHotels: sl(),
      searchHotelsByName: sl(),
      searchHotelsByProvince: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetFeaturedHotelsUseCase(sl()));
  sl.registerLazySingleton(() => SearchHotelsByNameUseCase(sl()));
  sl.registerLazySingleton(() => SearchHotelsByProvinceUseCase(sl()));
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSource(client: sl()),
  );

  // User
  sl.registerFactory(
    () => UserBloc(
      getUsers: sl(),
      createUser: sl(),
      updateUser: sl(),
      deleteUser: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserUseCase(sl()));
  sl.registerLazySingleton<UserAdminRepository>(
    () => UserAdminRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(client: sl()),
  );

  // Notification
  sl.registerFactory(
    () =>
        NotificationBloc(getNotifications: sl(), markNotificationAsRead: sl()),
  );
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(client: sl()),
  );

  // Hotel
  sl.registerFactory(
    () => HotelBloc(getHotel: sl(), checkFav: sl(), toggleFav: sl()),
  );
  sl.registerLazySingleton(() => GetHotelByIdUseCase(sl()));
  sl.registerLazySingleton<HotelRepository>(
    () => HotelRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HotelRemoteDataSource>(
    () => HotelRemoteDataSource(client: sl()),
  );

  // Notification
  // Profile
  // Review
  // Search
  // User
}
