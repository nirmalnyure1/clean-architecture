import 'package:cleanarchitecture/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'package:cleanarchitecture/injection_container.dart' as ic;
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ic.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Number Trivia",
      theme: ThemeData(
        primaryColor: Colors.green.shade800,
        primarySwatch: Colors.red,
        
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Colors.green.shade600),
      ),
      home: const NumberTriviaPage(),
    );
  }
}
