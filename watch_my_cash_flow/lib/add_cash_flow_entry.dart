import 'dart:math';

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
      contentPadding: EdgeInsets.all(16),
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
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                )
              ),
            ),

            const SizedBox(height: 16),

            // Category (dropdown)
            categories.isEmpty
              ? addNewCategoryField()
              : buildCategoryDropdown(),

            const SizedBox(height: 16),

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

            const SizedBox(height: 16),

            // Note
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: "Note (optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))
                )
              ),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
            )
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            deleteButton(),
            Row(
              children: [
                cancelButton(context),
                const SizedBox(width: 8),
                saveButton()
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget saveButton() {
    return FilledButton(
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
    );
  }

  Widget deleteButton() {
    return TextButton(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
        visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity),
        overlayColor: WidgetStatePropertyAll(Colors.red.withValues(alpha: .1)),
      ),
      onPressed: () async {
        await Supabase.instance.client.from('cash_flow_entries')
          .delete()
          .eq('id', widget.entry!.id.toInt());
        Get.back(result: widget.entry);
      },
      child: Icon(Icons.delete, color: Colors.red)
    );
  }

  Widget categorySection() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        final rotate = Tween(begin: pi, end: 0.0).animate(animation);

        return AnimatedBuilder(
          animation: rotate,
          child: child,
          builder: (context, child) {
            final angle = rotate.value;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(angle),
              child: child,
            );
          },
        );
      },
      child: isAddingCategory
          ? addNewCategoryField()
          : DropdownButtonFormField<Category>(
              padding: EdgeInsets.zero,
              dropdownColor: Get.theme.dropdownMenuTheme.menuStyle?.backgroundColor?.resolve({}),
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                )
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (c) => setState(() => selectedCategory = c),
            )
    );
  }

  bool isAddingCategory = false;

  Widget addNewCategoryField() {
    return TextField(
      decoration: const InputDecoration(
        labelText: "Add Category",
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)))
      ),
      onSubmitted: (value) async {
        await Supabase.instance.client.from('categories').insert({
          'name': value,
        });
      },
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
    );
  }

  Widget buildCategoryDropdown() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
      Expanded(
        child: categorySection()
      ),
      const SizedBox(width: 8),
      IconButton(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.zero),
          visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
          shape: WidgetStatePropertyAll(
            CircleBorder(),
          ),
          backgroundColor: WidgetStatePropertyAll(Get.theme.colorScheme.primary),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap
        ),
        onPressed: () {
          setState(() {
            isAddingCategory = !isAddingCategory;
          });
        },
        icon: const Icon(Icons.add),
      )
    ]);
  }
}

Widget cancelButton(BuildContext context) {
  return TextButton(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    onPressed: () => Navigator.pop(context),
    child: const Text("Cancel"),
  );
}
