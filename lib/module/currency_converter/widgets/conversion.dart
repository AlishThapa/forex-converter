import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forex_converter_app/module/currency_converter/bloc/country_list_cubit.dart';

class ConvertCurrencies extends StatelessWidget {
  final Map<String, double> rates;
  final Map currencies;

  const ConvertCurrencies({Key? key, required this.rates, required this.currencies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CurrencyConverterCubit(rates),
      child: BlocBuilder<CurrencyConverterCubit, CurrencyConverterState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CurrencyInputSection(currencies: currencies),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/convert.svg', height: 30),
                    ],
                  ),
                ),
                ToConvert(currencies: currencies),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CurrencyInputSection extends StatelessWidget {
  final Map currencies;

  const CurrencyInputSection({Key? key, required this.currencies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CurrencyConverterCubit>();
    final state = context.watch<CurrencyConverterCubit>().state;
    TextEditingController amountController = TextEditingController(text: state.amount);

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), topLeft: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownMenu<String>(
                width: 160,
                menuHeight: MediaQuery.of(context).size.height * 0.7,
                textStyle: const TextStyle(fontSize: 10),
                requestFocusOnTap: true,
                enableSearch: true,
                initialSelection: currencies[state.baseCurrency],
                onSelected: (String? newValue) {
                  if (newValue != null) {
                    cubit.updateCurrency(newValue, 0);
                  }
                },
                dropdownMenuEntries: currencies.values.toList().map<DropdownMenuEntry<String>>((value) {
                  return DropdownMenuEntry<String>(
                    value: value,
                    label: value,
                  );
                }).toList(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  key: const ValueKey('amount'),
                  controller: amountController,
                  onChanged: (value) {
                    value = value.replaceFirst(RegExp(r'^0+(?!$)'), '');
                    amountController.value = amountController.value.copyWith(
                      text: value,
                      selection: TextSelection.collapsed(offset: value.length),
                    );
                    cubit.updateAmount(value);
                  },
                  decoration: const InputDecoration(
                    hintStyle: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$'))],
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                state.baseCurrency,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              currencies[state.baseCurrency],
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ToConvert extends StatelessWidget {
  final Map currencies;

  const ToConvert({Key? key, required this.currencies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CurrencyConverterCubit>();
    final state = context.watch<CurrencyConverterCubit>().state;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...List.generate(state.selectedCurrencies.length, (index) {
              return Column(
                children: [
                  Slidable(
                    enabled: index != 0,
                    key: UniqueKey(),
                    endActionPane: ActionPane(
                      dismissible: DismissiblePane(onDismissed: () {
                        cubit.removeCurrency(index);
                      }),
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          flex: 2,
                          onPressed: (_) {
                            cubit.removeCurrency(index);
                          },
                          backgroundColor: const Color(0xFFFF0000),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: CurrencyItem(
                      currencies: currencies,
                      index: index,
                      selectedCurrency: state.selectedCurrencies[index],
                      answer: state.answers[index],
                      onCurrencyChanged: (String? newValue) {
                        cubit.updateCurrency(newValue!, index);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: cubit.addCurrency,
                child: Text(
                  'Add more countries',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: cubit.reset,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrencyItem extends StatelessWidget {
  final Map currencies;
  final int index;
  final String selectedCurrency;
  final String answer;
  final ValueChanged<String?>? onCurrencyChanged;

  const CurrencyItem({
    Key? key,
    required this.currencies,
    required this.index,
    required this.selectedCurrency,
    required this.answer,
    required this.onCurrencyChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), topLeft: Radius.circular(12)),
        border: Border(
          right: BorderSide(color: index == 0 ? Colors.transparent : const Color(0xFFFF0000), width: 12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DropdownMenu<String>(
                width: 160,
                menuHeight: MediaQuery.of(context).size.height * 0.45,
                requestFocusOnTap: true,
                initialSelection: currencies[selectedCurrency],
                textStyle: const TextStyle(fontSize: 10),
                onSelected: onCurrencyChanged,
                dropdownMenuEntries: currencies.values.toList().map<DropdownMenuEntry<String>>((value) {
                  return DropdownMenuEntry<String>(
                    value: value,
                    label: value,
                  );
                }).toList(),
              ),
              Expanded(
                child: Text(
                  answer.isEmpty ? '0' : answer,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              currencies[selectedCurrency],
              maxLines: 2,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
