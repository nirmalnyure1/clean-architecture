

import 'package:cleanarchitecture/core/error/exceptions.dart';
import 'package:cleanarchitecture/core/error/failure.dart';
import 'package:cleanarchitecture/core/network/network_info.dart';
import 'package:cleanarchitecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:cleanarchitecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:cleanarchitecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:cleanarchitecture/features/number_trivia/domain/entities/numer_trivia.dart';
import 'package:cleanarchitecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:dartz/dartz.dart';


typedef _concreteOrRandomChooser = Future<NumberTriviaModel> Function();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource numberTriviaRemoteDataSource;
  final NumberTriviaLocalDataSource numberTriviaLocalDataSource;
  final NetWorkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    required this.numberTriviaRemoteDataSource,
    required this.numberTriviaLocalDataSource,
    required this.networkInfo,
  });
  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) async {
    return await _getNumberTrvia(
      () async =>
          await numberTriviaRemoteDataSource.getConcreteNumberTrivia(number),
    );
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _getNumberTrvia(
        () async => await numberTriviaRemoteDataSource.getRandomNumberTrivia());
  }

  Future<Either<Failure, NumberTrivia>> _getNumberTrvia(
      _concreteOrRandomChooser chooseFunctionType) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await chooseFunctionType();
        numberTriviaLocalDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia =
            await numberTriviaLocalDataSource.getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
