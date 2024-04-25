import 'package:flutter/material.dart';

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
  String country2 = 'Australian Dollar';
  List<String> answers = ['Converted Currency'];

  List<String> selectedCurrencies = ['AUD'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Convert Currency from', style: TextStyle(color: Colors.white)),
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
                        width: 100,
                        menuHeight: MediaQuery.of(context).size.height * 0.7,
                        textStyle: const TextStyle(fontSize: 12),
                        requestFocusOnTap: true,
                        initialSelection: dropdownValue1,
                        onSelected: (String? newValue) {
                          setState(() {
                            dropdownValue1 = newValue!;
                            country1 = widget.currencies[newValue] ?? 'Unknown Country'; // Update the country name based on the selection
                          });
                        },
                        dropdownMenuEntries: widget.currencies.keys.toList().map<DropdownMenuEntry<String>>((value) {
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
                            if (amountController.text.isNotEmpty) {
                              setState(() {
                                for (int index = 0; index < selectedCurrencies.length; index++) {
                                  answers[index] =
                                      '${convertAny(widget.rates, amountController.text, dropdownValue1, selectedCurrencies[index])} ${selectedCurrencies[index]}';
                                }
                              });
                            } else {
                              answers = List.generate(selectedCurrencies.length, (index) => 'Converted Currency');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter amount'),
                                ),
                              );
                            }
                          },
                          controller: amountController,
                          decoration: const InputDecoration(hintText: 'Enter Amount'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  Text(country1),
                ],
              ),
            ),
          ),
          Divider(
            color: Colors.white,
            thickness: 2,
          ),
          Text('to', style: TextStyle(color: Colors.white)),

          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 20),
              shrinkWrap: true,
              itemCount: selectedCurrencies.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DropdownMenu<String>(
                              width: 100,
                              menuHeight: MediaQuery.of(context).size.height * 0.7,
                              requestFocusOnTap: true,
                              initialSelection: selectedCurrencies[index],
                              textStyle: const TextStyle(fontSize: 12),
                              onSelected: (String? newValue) {
                                setState(() {
                                  selectedCurrencies[index] = newValue!;
                                  country2 = widget.currencies[newValue] ?? 'Unknown Country'; // Update the country name based on the selection
                                  answers[index] = 'Converted Currency';
                                });
                              },
                              dropdownMenuEntries: widget.currencies.keys.toList().map<DropdownMenuEntry<String>>((value) {
                                return DropdownMenuEntry<String>(
                                  value: value,
                                  label: value,
                                );
                              }).toList(),
                            ),
                            const SizedBox(width: 10),
                            Text(answers[index] == '' ? 'Converted Currency' : answers[index], style: const TextStyle(fontSize: 12)),
                            if (index != 0) const Spacer(),
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
                        Text(country2),
                      ],
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
          // Center(
          //   child: InkWell(
          //     onTap: () {
          //       if (amountController.text.isNotEmpty) {
          //         setState(() {
          //           for (int index = 0; index < selectedCurrencies.length; index++) {
          //             answers[index] =
          //                 '${convertAny(widget.rates, amountController.text, dropdownValue1, selectedCurrencies[index])} ${selectedCurrencies[index]}';
          //           }
          //         });
          //       } else {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(
          //             content: Text('Please enter amount'),
          //           ),
          //         );
          //       }
          //     },
          //     child: Container(
          //       padding: const EdgeInsets.all(10),
          //       decoration: BoxDecoration(
          //         color: Theme.of(context).primaryColor,
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       child: const Text('Convert'),
          //     ),
          //   ),
          // ),
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
