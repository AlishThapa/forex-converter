import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';

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
  String dropdownValue1 = 'USD';
  String country1 = 'United States Dollar';
  String dropdownValue2 = 'NPR';

  List<String> answers = ['Converted Currency'];

  List<String> selectedCurrencies = ['NPR'];

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
  void initState() {
    amountController.text = '1';
    convertCurrency();
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), topLeft: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: 10),
                    DropdownMenu<String>(
                      width: 180,
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
                        controller: amountController,
                        onChanged: (value) {
                          // amountController.text = value;
                          convertCurrency();
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter Amount (E.g. 1)',
                          hintStyle: TextStyle(
                            fontSize: 12,
                          ),
                          // isDense: true,
                          // isCollapsed: true,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$'))],
                        textAlign: TextAlign.end,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      dropdownValue1,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(widget.currencies[dropdownValue1]),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/convert.svg', height: 30),
              ],
            ),
          ),
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
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), topLeft: Radius.circular(12)),
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
                            const SizedBox(width: 10),
                            DropdownMenu<String>(
                              width: 180,
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
                            Text(answers[index] == '' ? 'Converted Currency' : answers[index], style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 10),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            widget.currencies[selectedCurrencies[index]],
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
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
                  selectedCurrencies.add('NPR');
                  answers.add('${convertAny(widget.rates, amountController.text, dropdownValue1, 'NPR')} NPR');
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
                  amountController.text = '';
                  answers = List.generate(selectedCurrencies.length, (index) => 'Converted Currency');
                });
              },
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
    );
  }
}
