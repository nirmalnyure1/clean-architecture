import 'package:cleanarchitecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:cleanarchitecture/features/number_trivia/presentation/widgets/loading_widget.dart';
import 'package:cleanarchitecture/features/number_trivia/presentation/widgets/message_display.dart';
import 'package:cleanarchitecture/features/number_trivia/presentation/widgets/number_trivia_display.dart';
import 'package:cleanarchitecture/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Number trivia "),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(child: buildBody(context)),
    );
  }
}

BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
  return BlocProvider(
    create: (_) => servicelocator<NumberTriviaBloc>(),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            //! Top half

            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (BuildContext context, state) {
                if (state is Empty) {
                  return const MessageDisplay(
                    message: "Start searching!",
                  );
                } else if (state is Loading) {
                  return const LoadingWidget();
                } else if (state is Loaded) {
                  return TriviaDisplay(numberTrivia: state.trivia);
                } else if (state is Error) {
                  return MessageDisplay(message: state.message);
                }

                return Container();
              },
            ),

            const SizedBox(height: 20),
            // Bottom half

            const TriviaControls()
          ],
        ),
      ),
    ),
  );
}

class TriviaControls extends StatefulWidget {
  const TriviaControls({Key? key}) : super(key: key);

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final _controller = TextEditingController();
  String? _inputString;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TextField(
            controller: _controller,
            // keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Input a number',
            ),
            onChanged: (value) {
              _inputString = value;
            },
            onSubmitted: (_) {
              dispatchConcrete();
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  child: const Text('Search'),
                  // color: Theme.of(context).accentColor,
                  // textTheme: ButtonTextTheme.primary,
                  onPressed: dispatchConcrete,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: dispatchRandom,
                  child: const Text('Get random trivia'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void dispatchConcrete() {
    // Clearing the TextField to prepare it for the next inputted number
    _controller.clear();
    if (_inputString != null) {
      BlocProvider.of<NumberTriviaBloc>(context)
          .add(GetTriviaForConcreteNumber(numberString: _inputString!));
    }
  }

  void dispatchRandom() {
    _controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context).add(GetTriviaForRandomNumber());
  }
}
