import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:watch_my_cash_flow/data/database/app_database.dart';
// import 'package:watch_my_cash_flow/data/model/cash_flow_entry.dart';
// import 'package:watch_my_cash_flow/data/model/category.dart';
import 'package:flutter/services.dart';
import 'package:watch_my_cash_flow/utils/money_text_formatter.dart';

class AddCashFlowEntryDialog extends StatefulWidget {
  const AddCashFlowEntryDialog({super.key});

  @override
  State<AddCashFlowEntryDialog> createState() => _AddCashFlowEntryDialogState();
}

class _AddCashFlowEntryDialogState extends State<AddCashFlowEntryDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  Category? selectedCategory;
  DateTime selectedDate = DateTime.now();
  List<Category> categories = [];

  @override
  void initState() {
    // TODO: implement initState
    getCategories();
    super.initState();
  }

  Future getCategories() async {
    List<Category> response = await db.categoryDao.getAll();
    setState(() {
      categories = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Add Cash Flow"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                VNDTextInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),

            const SizedBox(height: 12),

            // Category (dropdown)
            categories.isEmpty
              ? TextField(
                  decoration: const InputDecoration(
                    labelText: "Category",
                  ),
                  onSubmitted: (value) async {
                    // final newCategory = Category(
                    //   id: nanoid(length: 8),
                    //   name: value,
                    //   isIncome: false,
                    // );
                    // setState(() {
                    //   categories.add(newCategory);
                    //   selectedCategory = newCategory;
                    // });

                    await db.categoryDao.insertCategory(
                      CategoriesCompanion.insert(
                        id: nanoid(length: 8),
                        name: value,
                        isIncome: false,
                      ),
                    );
                  },
                )
              : DropdownButtonFormField<Category>(
                  dropdownColor: Get.theme.dropdownMenuTheme.menuStyle?.backgroundColor?.resolve({}),
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                  onChanged: (c) => setState(() => selectedCategory = c),
                ),

            const SizedBox(height: 12),

            // Date
            Row(
              children: [
                Text(DateFormat.yMMMd().format(selectedDate)),
                const Spacer(),
                TextButton(
                  style: ButtonStyle(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: selectedDate,
                    );
                    if (d != null) setState(() => selectedDate = d);
                  },
                  child: const Text("Pick Date"),
                )
              ],
            ),

            const SizedBox(height: 12),

            // Note
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: "Note (optional)",
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          onPressed: () {
            if (selectedCategory == null ||
                _amountController.text.trim().isEmpty) {
              // missing data
              return;
            }

            final entry = CashFlowEntry(
              id: nanoid(length: 8),
              date: selectedDate,
              amount: double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0,
              categoryId: selectedCategory!.id,
              note: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text,
            );

            Navigator.pop(context, entry);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

final demoCategories = [
  Category(id: '1', name: 'Food', isIncome: false),
  Category(id: '2', name: 'Salary', isIncome: true),
  Category(id: '3', name: 'Transport', isIncome: false),
];
