


import 'package:cleanarchitecture/core/error/failure.dart';
import 'package:cleanarchitecture/core/usercase/usecases.dart';
import 'package:cleanarchitecture/core/util/presentation/input_converter.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/numer_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  GetConcreteNumberTrivia getConcreteNumberTrivia;
  GetRandomNumberTrivia getRandomNumberTrivia;
  InputConverter inputConverter;

  NumberTriviaBloc({
    required GetConcreteNumberTrivia concrete,
    required GetRandomNumberTrivia random,
    required this.inputConverter,
  })  : assert(concrete != null),
        assert(random != null),
        assert(inputConverter != null),
        getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random,
        super(Empty()) {
    on<GetTriviaForConcreteNumber>(_contreteNumber);
    on<GetTriviaForRandomNumber>(_randomNumber);
  }
  NumberTriviaState get initialState => Empty();

  void _contreteNumber(
    GetTriviaForConcreteNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(Loading());
    final inputEither =
        inputConverter.stringToUnsignedInteger(event.numberString);
    final state = await inputEither.fold(
        (failure) => const Error(message: INVALID_INPUT_FAILURE_MESSAGE),
        (integer) => _getTrivia(integer));
    emit(state);
  }

  void _randomNumber(
    GetTriviaForRandomNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(Loading());
    final failureOrTrivia = await getRandomNumberTrivia(NoParams());
    emit(failureOrTrivia.fold(
        (failure) => Error(message: _mapFailureToMessage(failure)),
        (numberTrivia) => Loaded(trivia: numberTrivia)));
  }

  dynamic _getTrivia(int integer) async {
    final failureOrTrivia =
        await getConcreteNumberTrivia(Params(number: integer));
    return failureOrTrivia.fold(
      (failure) => Error(message: _mapFailureToMessage(failure)),
      (numberTrivia) => Loaded(trivia: numberTrivia),
    );
  }
}

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return SERVER_FAILURE_MESSAGE;

    case CacheFailure:
      return CACHE_FAILURE_MESSAGE;
    default:
      return "unexpected error";
  }
}
