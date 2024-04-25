import '../../models/rate_models.dart';

abstract class CurrencyConverterState {
  List<Object?> get props => [];
}

class CurrencyConverterInitial extends CurrencyConverterState {}

class CurrencyConverterLoading extends CurrencyConverterState {}

class CurrencyConverterLoaded extends CurrencyConverterState {
  final RatesModel ratesModel;
  final Map currencies;

  CurrencyConverterLoaded({required this.ratesModel, required this.currencies});

  @override
  List<Object?> get props => [ratesModel, currencies];
}

class CurrencyConverterError extends CurrencyConverterState {
  final String error;

  CurrencyConverterError({required this.error});

  @override
  List<Object?> get props => [error];
}
