import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watch_my_cash_flow/data/model/cash_flow_entry.dart';
import 'package:watch_my_cash_flow/data/model/category.dart';
import 'package:flutter/services.dart';
import 'package:watch_my_cash_flow/utils/money_text_formatter.dart';

class AddCashFlowEntryDialog extends StatefulWidget {
  final CashFlowEntry? entry;
  const AddCashFlowEntryDialog({super.key, this.entry});

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

    if (widget.entry != null) {
      _amountController.text = formatter.format(widget.entry!.amount);
      selectedDate = widget.entry!.date;
    }
    super.initState();
  }

  Future getCategories() async {
    final res = await Supabase.instance.client.from('categories').select('id, name');
    setState(() {
      // categories = response;
      categories = (res as List)
        .map((m) => Category.fromMap(m as Map<String, dynamic>))
        .toList();
      selectedCategory = categories.isNotEmpty ? categories.firstWhereOrNull((o) => o.id == widget.entry?.categoryId) : null;
    });
  }

  Future updateEntry() async {
    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    final categoryId = selectedCategory!.id;
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text;
    await Supabase.instance.client.from('cash_flow_entries')
    .update({
      'date': DateFormat.yMd().format(selectedDate),
      'amount': amount,
      'category_id': categoryId.toInt(),
      'note': note,
    })
    .eq('id', widget.entry!.id.toInt());
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
                    await Supabase.instance.client.from('categories').insert({
                      'name': value,
                    });
                  },
                )
              : DropdownButtonFormField<Category>(
                  dropdownColor: Get.theme.dropdownMenuTheme.menuStyle?.backgroundColor?.resolve({}),
                  initialValue: selectedCategory,
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
          onPressed: () async {
            if (selectedCategory == null ||
                _amountController.text.trim().isEmpty) {
              // missing data
              return;
            }

            if (widget.entry != null) {
              final entry = widget.entry!.copyWith(
                amount: double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0,
                date: selectedDate,
                categoryId: selectedCategory!.id,
              );

              await updateEntry();
              Get.back(result: entry);
              
              return;
            }

            final entry = CashFlowEntry(
              id: BigInt.from(-1),
              date: selectedDate,
              amount: double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0,
              categoryId: selectedCategory!.id,
              note: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text,
            );

            await Supabase.instance.client.from('cash_flow_entries').insert({
              'date': selectedDate.toIso8601String(),
              'amount': double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0,
              'category_id': selectedCategory!.id.toInt(),
            });

            Get.back(result: entry);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
