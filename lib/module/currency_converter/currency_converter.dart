import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../about/about_page.dart';
import 'bloc/currency_converter_bloc.dart';
import 'bloc/events/currency_converter_events.dart';
import 'bloc/states/currency_converter_states.dart';
import 'widgets/conversion.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  @override
  void initState() {
    super.initState();
    context.read<CurrencyConverterBloc>().add(FetchDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FOREX`S CONVERTER'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => ForexInfoScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(),
        child: BlocBuilder<CurrencyConverterBloc, CurrencyConverterState>(
          builder: (context, state) {
            if (state is CurrencyConverterLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CurrencyConverterLoaded) {
              return Center(
                child: ConvertCurrencies(
                  currencies: state.currencies,
                  rates: state.ratesModel.rates,
                ),
              );
            } else if (state is CurrencyConverterError) {
              return Center(
                child: Text('Error: ${state.error}'),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
