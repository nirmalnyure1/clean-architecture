import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'core/util/presentation/input_converter.dart';
import 'features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'features/number_trivia/presentation/bloc/bloc.dart';



final servicelocator = GetIt.instance;

Future<void> init() async {
//! Features- number trivia
//bloc
  servicelocator.registerFactory<NumberTriviaBloc>(() => NumberTriviaBloc(
        concrete: servicelocator(),
        random: servicelocator(),
        inputConverter: servicelocator(),
      ));
//use cases
  servicelocator
      .registerLazySingleton(() => GetConcreteNumberTrivia(servicelocator()));
  servicelocator
      .registerLazySingleton(() => GetRandomNumberTrivia(servicelocator()));
//repositories
  servicelocator.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      networkInfo: servicelocator(),
      numberTriviaLocalDataSource: servicelocator(),
      numberTriviaRemoteDataSource: servicelocator(),
    ),
  );

  //data source
  servicelocator.registerLazySingleton<NumberTriviaLocalDataSource>(() =>
      NumberTriviaLocalDataSourceImpl(sharedPreferences: servicelocator()));
  servicelocator.registerLazySingleton<NumberTriviaRemoteDataSource>(
      () => NumberTriviaRemoteDataSourceImpl(client: servicelocator()));
//! core
  servicelocator.registerLazySingleton(() => InputConverter());
  servicelocator.registerLazySingleton<NetWorkInfo>(
      () => NetWorkInfoImpl(servicelocator()));

//! external
  final sharedPreferences = await SharedPreferences.getInstance();
  servicelocator.registerLazySingleton(() => sharedPreferences);
  servicelocator.registerLazySingleton(() => http.Client());
  servicelocator.registerLazySingleton(() => InternetConnectionChecker());
}
