import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../../utils/const.dart';
import '../database/database_helper.dart';
import '../models/currencies.dart';
import '../models/rate_models.dart';
import 'events/currency_converter_events.dart';
import 'states/currency_converter_states.dart';

class CurrencyConverterBloc
    extends Bloc<CurrencyConverterEvent, CurrencyConverterState> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  var connectivityResult = ConnectivityResult.none;

  StreamSubscription<ConnectivityResult> listenToNetwork() {
    return Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      connectivityResult = result;
    });
  }

  CurrencyConverterBloc() : super(CurrencyConverterInitial()) {
    on<FetchDataEvent>(_fetchData);
  }

  void _fetchData(
      FetchDataEvent event,
      Emitter<CurrencyConverterState> emit,
      ) async {
    try {
      emit(CurrencyConverterLoading());
      final localRates = await _databaseHelper.getLatestRatesFromLocalDb();
      final localCurrencies = await _databaseHelper.getCurrenciesFromLocalDb();

      /// Check for network connection
      if (connectivityResult == ConnectivityResult.none) {
        emit(CurrencyConverterLoaded(
          ratesModel: localRates ?? RatesModel(
              disclaimer: "Usage subject to terms: https://openexchangerates.org/terms",
              license: "https://openexchangerates.org/license",
              timestamp: 1716199200,
              base: 'USD',
              rates: {}
          ),
          currencies: localCurrencies ?? {},
        ));
      } else {
        /// Always fetch from network if connected
        final ratesModel = await _fetchLatestRates();
        final currencies = await _fetchCurrencies();

        // Save latest rates to local database
        await _databaseHelper.insertRatesToLocalDb(ratesModel);
        await _databaseHelper.insertCurrenciesToLocalDb(currencies);

        emit(CurrencyConverterLoaded(
          ratesModel: ratesModel,
          currencies: currencies,
        ));
      }
    } catch (e) {
      emit(CurrencyConverterError(error: e.toString()));
    }
  }


  Future<RatesModel> _fetchLatestRates() async {
    final uri = Uri.https('openexchangerates.org', '/api/latest.json',
        {'app_id': apiKey, 'base': 'USD'});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final result = RatesModel.fromJson(json.decode(response.body));
      return result;
    } else {
      throw Exception('Failed to fetch rates');
    }
  }

  Future<Map<String, String>> _fetchCurrencies() async {
    final uri = Uri.https(
        'openexchangerates.org', '/api/currencies.json', {'app_id': apiKey});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final allCurrencies = allCurrenciesFromJson(response.body);
      return allCurrencies;
    } else {
      throw Exception('Failed to fetch currencies');
    }
  }
}

String convertAny(Map exchangeRates, String amount, String currencyBase,
    String currencyFinal) {
  String output = (double.parse(amount) /
          exchangeRates[currencyBase] *
          exchangeRates[currencyFinal])
      .toStringAsFixed(2)
      .toString();
  return output;
}

