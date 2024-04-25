import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../utils/const.dart';
import '../models/currencies.dart';
import '../models/rate_models.dart';
import 'events/currency_converter_events.dart';
import 'states/currency_converter_states.dart';

class CurrencyConverterBloc extends Bloc<CurrencyConverterEvent, CurrencyConverterState> {
  CurrencyConverterBloc() : super(CurrencyConverterInitial()) {
    on<FetchDataEvent>(_fetchData);
  }

  Future<void> _fetchData(FetchDataEvent event, Emitter<CurrencyConverterState> emit) async {
    try {
      emit(CurrencyConverterLoading());
      final ratesModel = await _fetchLatestRates();
      final currencies = await _fetchCurrencies();
      emit(CurrencyConverterLoaded(ratesModel: ratesModel, currencies: currencies));
    } catch (e) {
      emit(CurrencyConverterError(error: e.toString()));
    }
  }

  Future<RatesModel> _fetchLatestRates() async {
    final uri = Uri.https('openexchangerates.org', '/api/latest.json', {'app_id': apiKey, 'base': 'USD'});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final result = RatesModel.fromJson(json.decode(response.body));
      return result;
    } else {
      throw Exception('Failed to fetch rates');
    }
  }

  Future<Map> _fetchCurrencies() async {
    final uri = Uri.https('openexchangerates.org', '/api/currencies.json', {
      'app_id': apiKey,
    });
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final allCurrencies = allCurrenciesFromJson(response.body);
      return allCurrencies;
    } else {
      throw Exception('Failed to fetch currencies');
    }
  }
}

String convertAny(Map exchangeRates, String amount, String currencyBase, String currencyFinal) {
  String output = (double.parse(amount) / exchangeRates[currencyBase] * exchangeRates[currencyFinal]).toStringAsFixed(2).toString();
  return output;
}
