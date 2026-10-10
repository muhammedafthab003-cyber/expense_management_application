
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

const Color editTeal = Color(0xFF438F89);

class EditTransactionScreen extends StatefulWidget {
  final dynamic transactionKey;
  final Map<String, dynamic> transaction;

  const EditTransactionScreen({
    super.key,
    required this.transactionKey,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends State<EditTransactionScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController amountController;

  late String transactionType;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.transaction['name']?.toString() ?? '',
    );

    amountController = TextEditingController(
      text: widget.transaction['amount']?.toString() ?? '',
    );

    transactionType =
        widget.transaction['type']?.toString() ?? 'Expense';

    selectedDate = DateTime.tryParse(
          widget.transaction['date']?.toString() ?? '',
        ) ??
        DateTime.now();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> saveChanges() async {
    if (!formKey.currentState!.validate()) return;

    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) return;

    final box = Hive.box('transactions');

    // Update the existing record using its original Hive key.
    await box.put(widget.transactionKey, {
      ...widget.transaction,
      'type': transactionType,
      'name': nameController.text.trim(),
      'amount': amount,
      'date': selectedDate.toIso8601String(),
    });

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Transaction',
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: editTeal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('TRANSACTION TYPE'),
                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          value: transactionType,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Expense',
                              child: Text('Expense'),
                            ),
                            DropdownMenuItem(
                              value: 'Income',
                              child: Text('Income'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                transactionType = value;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Select transaction type';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),
                        _fieldLabel('NAME'),
                        const SizedBox(height: 8),

                        TextFormField(
                          controller: nameController,
                          textCapitalization:
                              TextCapitalization.words,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter transaction name';
                            }

                            if (value.trim().length < 2) {
                              return 'Enter at least 2 characters';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),
                        _fieldLabel('AMOUNT'),
                        const SizedBox(height: 8),

                        TextFormField(
                          controller: amountController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            suffixIcon: TextButton(
                              onPressed: () {
                                amountController.clear();
                              },
                              child: const Text('Clear'),
                            ),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter amount';
                            }

                            final amount = double.tryParse(
                              value.trim(),
                            );

                            if (amount == null || amount <= 0) {
                              return 'Enter a valid amount';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),
                        _fieldLabel('DATE'),
                        const SizedBox(height: 8),

                        InkWell(
                          onTap: pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(
                                Icons.calendar_month,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              '${selectedDate.day} '
                              '${_monthName(selectedDate.month)} '
                              '${selectedDate.year}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: editTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: Colors.grey,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return months[month - 1];
  }
}
