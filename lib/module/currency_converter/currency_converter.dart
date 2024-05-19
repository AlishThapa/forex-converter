// import 'dart:async';
//
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
//
// import '../about/about_page.dart';
// import 'bloc/currency_converter_bloc.dart';
// import 'bloc/events/currency_converter_events.dart';
// import 'bloc/states/currency_converter_states.dart';
// import 'widgets/conversion.dart';
//
// class CurrencyConverterPage extends StatefulWidget {
//   const CurrencyConverterPage({super.key});
//
//   @override
//   State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
// }
//
// class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
//   late StreamSubscription internetSubscription;
//   bool hasInternet = true;
//   List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     internetSubscription = InternetConnectionChecker().onStatusChange.listen((status) {
//       final hasInternet = status == InternetConnectionStatus.connected;
//       setState(() {
//         this.hasInternet = hasInternet;
//       });
//     });
//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//     context.read<CurrencyConverterBloc>().add(FetchDataEvent());
//   }
//
//   Future<void> initConnectivity() async {
//     late List<ConnectivityResult> result;
//     try {
//       result = await _connectivity.checkConnectivity();
//     } on PlatformException catch (e) {
//       return;
//     }
//
//     if (!mounted) {
//       return Future.value(null);
//     }
//
//     return _updateConnectionStatus(result);
//   }
//
//   Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
//     setState(() {
//       _connectionStatus = result;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         decoration: BoxDecoration(
//           color: Color(0xff17202A),
//         ),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 SizedBox.shrink(),
//                 Text(
//                   'FOREX CONVERTER',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 30,
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: IconButton(
//                     icon: const Icon(
//                       Icons.info_outline,
//                       color: Colors.white,
//                     ),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         PageRouteBuilder(
//                           pageBuilder: (context, animation, secondaryAnimation) => ForexInfoScreen(),
//                           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                             const begin = Offset(1.0, 0.0);
//                             const end = Offset.zero;
//                             const curve = Curves.ease;
//                             var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//                             var offsetAnimation = animation.drive(tween);
//                             return SlideTransition(
//                               position: offsetAnimation,
//                               child: child,
//                             );
//                           },
//                           transitionDuration: const Duration(milliseconds: 300),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             Expanded(
//               child: BlocBuilder<CurrencyConverterBloc, CurrencyConverterState>(
//                 builder: (context, state) {
//                   if (state is CurrencyConverterLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (state is CurrencyConverterLoaded) {
//                     return Center(
//                       child: ConvertCurrencies(
//                         currencies: state.currencies,
//                         rates: state.ratesModel.rates,
//                       ),
//                     );
//                   } else if (state is CurrencyConverterError) {
//                     return Center(
//                       child: Text('Error: ${state.error}'),
//                     );
//                   } else {
//                     return const SizedBox.shrink();
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
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
  var connectivityResult = ConnectivityResult.none;
  late StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        connectivityResult = result;
      });
      debugPrint("connection result: ${result.toString()}");
    });

    context.read<CurrencyConverterBloc>().add(FetchDataEvent());
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: connectivityResult == ConnectivityResult.none
            ? Center(
                child: Text(
                  'No internet connection',
                ),
              )
             : Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xff17202A),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox.shrink(),
                        Text(
                          'FOREX CONVERTER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: IconButton(
                            icon: const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                            ),
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
                        ),
                      ],
                    ),
                    Expanded(
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
                  ],
                ),
              ),
      ),
    );
  }
}
