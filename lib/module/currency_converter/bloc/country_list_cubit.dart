import 'package:bloc/bloc.dart';

import 'currency_converter_bloc.dart';

class CurrencyConverterCubit extends Cubit<CurrencyConverterState> {
  final Map<String, double> rates;

  CurrencyConverterCubit(this.rates) : super(CurrencyConverterState.initial()) {
    convertCurrency();
  }

  void updateAmount(String amount) {
    emit(state.copyWith(amount: amount));
    convertCurrency();
  }

  void updateCurrency(String currency, int index) {
    List<String> updatedCurrencies = List.from(state.selectedCurrencies);
    updatedCurrencies[index] = currency;
    emit(state.copyWith(selectedCurrencies: updatedCurrencies));
    convertCurrency();
  }

  // void addCurrency() {
  //   List<String> updatedCurrencies = List.from(state.selectedCurrencies)..add('NPR');
  //   List<String> updatedAnswers = List.from(state.answers)..add('0.0 NPR');
  //   emit(state.copyWith(selectedCurrencies: updatedCurrencies, answers: updatedAnswers));
  //   convertCurrency();
  // }

  void addCurrency() async {
    emit(state.copyWith(isLoading: true));

    await Future.delayed(Duration(seconds: 2)); // Simulate network delay

    List<String> newSelectedCurrencies = List.from(state.selectedCurrencies)..add('NPR');
    List<String> newAnswers = List.from(state.answers)
      ..add('${convertAny(rates, '1', 'USD', 'NPR')} NPR');

    emit(state.copyWith(selectedCurrencies: newSelectedCurrencies, answers: newAnswers, isLoading: false));
  }
  void removeCurrency(int index) {
    List<String> updatedCurrencies = List.from(state.selectedCurrencies)..removeAt(index);
    List<String> updatedAnswers = List.from(state.answers)..removeAt(index);
    emit(state.copyWith(selectedCurrencies: updatedCurrencies, answers: updatedAnswers));
    convertCurrency();
  }

  void convertCurrency() {
    if (state.amount.isNotEmpty) {
      List<String> updatedAnswers = List.generate(state.selectedCurrencies.length, (index) {
        return '${convertAny(rates, state.amount, state.baseCurrency, state.selectedCurrencies[index])} ${state.selectedCurrencies[index]}';
      });
      emit(state.copyWith(answers: updatedAnswers));
    } else {
      emit(state.copyWith(answers: List.generate(state.selectedCurrencies.length, (index) => '0')));
    }
  }

  void reset() {
    emit(CurrencyConverterState.initial());
    convertCurrency();
  }
}

class CurrencyConverterState {
  final String amount;
  final String baseCurrency;
  final List<String> selectedCurrencies;
  final List<String> answers;
  final bool isLoading;

  CurrencyConverterState({required this.amount, required this.baseCurrency, required this.selectedCurrencies, required this.answers, this.isLoading = false});

  factory CurrencyConverterState.initial() {
    return CurrencyConverterState(
      amount: '1',
      baseCurrency: 'USD',
      selectedCurrencies: ['NPR'],
      answers: ['0.0 NPR'],
    );
  }

  CurrencyConverterState copyWith({String? amount, String? baseCurrency, List<String>? selectedCurrencies, List<String>? answers, bool? isLoading}) {
    return CurrencyConverterState(
        amount: amount ?? this.amount,
        baseCurrency: baseCurrency ?? this.baseCurrency,
        selectedCurrencies: selectedCurrencies ?? this.selectedCurrencies,
        answers: answers ?? this.answers,
        isLoading: isLoading ?? this.isLoading);
  }
}
