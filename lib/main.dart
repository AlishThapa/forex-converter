import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forex_converter_app/module/currency_converter/currency_converter.dart';
import 'module/currency_converter/bloc/currency_converter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CurrencyConverterBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Currency Converter',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const CurrencyConverterPage(),
      ),
    );
  }
}
