import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../bloc/currency_converter_bloc.dart';

class ConvertCurrencies extends StatefulWidget {
  final Map<String, double> rates;
  final Map currencies;

  const ConvertCurrencies({Key? key, required this.rates, required this.currencies}) : super(key: key);

  @override
  State<ConvertCurrencies> createState() => _ConvertCurrenciesState();
}

class _ConvertCurrenciesState extends State<ConvertCurrencies> {
  TextEditingController amountController = TextEditingController();
  String dropdownValue1 = 'AUD';
  String country1 = 'Australian Dollar';
  String dropdownValue2 = 'AUD';

  List<String> answers = ['Converted Currency'];

  List<String> selectedCurrencies = ['AUD'];

  void convertCurrency() {
    if (amountController.text.isNotEmpty) {
      setState(() {
        for (int index = 0; index < selectedCurrencies.length; index++) {
          answers[index] = '${convertAny(widget.rates, amountController.text, dropdownValue1, selectedCurrencies[index])} ${selectedCurrencies[index]}';
        }
      });
    } else {
      setState(() {
        answers = List.generate(selectedCurrencies.length, (index) => 'Converted Currency');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Convert Currency from', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownMenu<String>(
                        width: 160,
                        menuHeight: MediaQuery.of(context).size.height * 0.7,
                        textStyle: const TextStyle(fontSize: 12),
                        requestFocusOnTap: true,
                        initialSelection: widget.currencies[dropdownValue1],
                        onSelected: (String? newValue) {
                          setState(() {
                            country1 = newValue!;
                            dropdownValue1 = widget.currencies.keys.firstWhere((k) => widget.currencies[k] == newValue);
                          });
                          convertCurrency();
                        },
                        dropdownMenuEntries: widget.currencies.values.toList().map<DropdownMenuEntry<String>>((value) {
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
                          onChanged: (value) {
                            convertCurrency();
                          },
                          controller: amountController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Amount',
                            hintStyle: TextStyle(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$'))],
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  Text(widget.currencies[dropdownValue1]),
                ],
              ),
            ),
          ),
          Divider(
            color: Colors.white,
            thickness: 2,
          ),
          Text('To', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
              shrinkWrap: true,
              itemCount: selectedCurrencies.length,
              itemBuilder: (BuildContext context, int index) {
                return Slidable(
                  enabled: index == 0 ? false : true,
                  key: UniqueKey(),
                  endActionPane: ActionPane(
                    dismissible: DismissiblePane(onDismissed: () {
                      setState(() {
                        selectedCurrencies.removeAt(index);
                        answers.removeAt(index);
                      });
                    }),
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        flex: 2,
                        onPressed: (_) {
                          setState(() {
                            selectedCurrencies.removeAt(index);
                            answers.removeAt(index);
                          });
                        },
                        backgroundColor: const Color(0xFFFF0000),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              DropdownMenu<String>(
                                width: 160,
                                menuHeight: MediaQuery.of(context).size.height * 0.45,
                                requestFocusOnTap: true,
                                initialSelection: widget.currencies[selectedCurrencies[index]],
                                textStyle: const TextStyle(fontSize: 12),
                                onSelected: (String? newValue) {
                                  setState(() {
                                    selectedCurrencies[index] = widget.currencies.keys.firstWhere((k) => widget.currencies[k] == newValue);
                                    answers[index] = 'Converted Currency';
                                  });
                                  convertCurrency();
                                },
                                dropdownMenuEntries: widget.currencies.values.toList().map<DropdownMenuEntry<String>>((value) {
                                  return DropdownMenuEntry<String>(
                                    value: value,
                                    label: value,
                                  );
                                }).toList(),
                              ),
                              Spacer(),
                              Text(answers[index] == '' ? 'Converted Currency' : answers[index], style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 10),
                              if (index != 0)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedCurrencies.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.delete),
                                )
                            ],
                          ),
                          Text(widget.currencies[selectedCurrencies[index]]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  selectedCurrencies.add('AUD');
                  answers.add('Converted Currency');
                });
              },
              child: Text(
                'Add more countries',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: InkWell(
              onTap: () {
                setState(() {
                  amountController.clear();
                  answers = List.generate(selectedCurrencies.length, (index) => 'Converted Currency');
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
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
    );
  }
}
