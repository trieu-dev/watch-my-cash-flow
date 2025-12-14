import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:watch_my_cash_flow/app/services/date_service.dart';
import 'package:watch_my_cash_flow/app/services/localization_service.dart';
import 'package:watch_my_cash_flow/app/services/supabase_service.dart';
import 'package:watch_my_cash_flow/data/model/cash_flow_entry.dart';
import 'package:watch_my_cash_flow/data/model/category.dart';
import 'package:flutter/services.dart';
import 'package:watch_my_cash_flow/day_wheel_selector.dart';
import 'package:watch_my_cash_flow/utils/money_text_formatter.dart';

class AddCashFlowEntryDialog extends StatefulWidget {
  final CashFlowEntry? entry;
  const AddCashFlowEntryDialog({super.key, this.entry});

  @override
  State<AddCashFlowEntryDialog> createState() => _AddCashFlowEntryDialogState();
}

class _AddCashFlowEntryDialogState extends State<AddCashFlowEntryDialog> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();
  final TextEditingController _noteController = TextEditingController();
  Category? selectedCategory;
  DateTime selectedDate = DateTime.now();
  List<Category> categories = [];
  final loc = Get.find<LocalizationService>();

  @override
  void initState() {
    // TODO: implement initState
    getCategories();

    if (widget.entry != null) {
      _amountController.text = formatter.format(widget.entry!.amount);
      selectedDate = widget.entry!.date;
    }
    super.initState();

    _amountFocus.addListener(() { setState(() { }); });
  }

  Future getCategories() async {
    final res = await SupabaseService().client.from('categories').select('id, name');
    
    categories = (res as List)
      .map((m) => Category.fromMap(m as Map<String, dynamic>))
      .toList();
    categories.sort((a, b) => a.name.compareTo(b.name));
    selectedCategory = categories.isNotEmpty ? categories.firstWhereOrNull((o) => o.id == widget.entry?.categoryId) : null;
    
    setState(() { });
  }

  Future updateEntry() async {
    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    final categoryId = selectedCategory!.id;
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text;
    await SupabaseService().client.from('cash_flow_entries')
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
    return SafeArea(child: Stack(
      children: [
        body(),
        Positioned(
          bottom: 0,
          child: amountSuggestion(),
        )
      ],
    ));
  }

  Widget body() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.all(16),
      title: Text("app.addCashFlow".tr),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Amount
            amountField(),

            const SizedBox(height: 16),

            // Category (dropdown)
            categories.isEmpty
              ? addNewCategoryField()
              : buildCategoryDropdown(),

            const SizedBox(height: 16),

            FullDatePicker(
              initialDate: DateTime.now(),
              onDateChanged: (date) { setState(() => selectedDate = date); },
            ),

            const SizedBox(height: 16),

            // Date
            dateField(),

            const SizedBox(height: 16),

            // Note
            noteField()
          ],
        ),
      ),
      actionsPadding: EdgeInsets.all(16),
      actions: [ actions() ],
    );
  }

  Widget amountSuggestion() {
    if (!_amountFocus.hasFocus) return SizedBox.shrink();
    if (_amountController.text.isEmpty) return SizedBox.shrink();
    double amountNumb = double.tryParse(_amountController.text.replaceAll('.', ''))!;
    return Container(
      color: Get.theme.scaffoldBackgroundColor,
      padding: EdgeInsets.all(8),
      width: Get.width,
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: amountSuggestionItem(amountNumb*100)),
        SizedBox(width: 8),
        Expanded(child: amountSuggestionItem(amountNumb*1000)),
        SizedBox(width: 8),
        Expanded(child: amountSuggestionItem(amountNumb*10000)),
      ],
    ),
    );
  }

  Widget amountSuggestionItem(double amount) {
    return TextButton(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Get.theme.colorScheme.primary,
            ),
          ),
        ),
      ),
      onPressed: () {
        _amountController.text = formatter.format(amount);
        _amountController.selection = TextSelection.collapsed(offset: _amountController.text.length);
      },
      child: Text(formatAmount(amount))
    );
  }

  Widget amountField() {
    return TextField(
      controller: _amountController,
      focusNode: _amountFocus,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        VNDTextInputFormatter(),
      ],
      // onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onChanged: (value) {
        if (value.length > 5) return;
        setState(() { });
      },
      decoration: InputDecoration(
        labelText: "app.amount".tr,
        prefixIcon: Icon(Icons.payments_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        )
      ),
    );
  }

  Widget dateField() {
    return Row(
      children: [
        Text(dateService.format(selectedDate, pattern: 'yMMMd')),
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
              locale: loc.currentLocale,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDate: selectedDate,
            );
            if (d != null) setState(() => selectedDate = d);
          },
          child: Text("app.pickDate".tr),
        )
      ],
    );
  }

  Widget noteField() {
    return TextField(
      controller: _noteController,
      decoration: InputDecoration(
        labelText: "app.note".tr,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))
        )
      ),
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
    );
  }

  Widget actions() => 
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
    );

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

        await SupabaseService().client.from('cash_flow_entries').insert({
          'date': selectedDate.toIso8601String(),
          'amount': double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0,
          'category_id': selectedCategory!.id.toInt(),
          'note': entry.note,
        });

        Get.back(result: entry);
      },
      child: Text("app.save".tr),
    );
  }

  Widget deleteButton() {
    if (widget.entry == null) return SizedBox.shrink();

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
        await SupabaseService().client.from('cash_flow_entries')
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
              decoration: InputDecoration(
                labelText: "app.category".tr,
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
      decoration: InputDecoration(
        labelText: "app.category.add".tr,
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)))
      ),
      onSubmitted: (value) async {
        final data = await SupabaseService().client.from('categories').insert({
          'name': value,
        }).select().single();

        final newCategory = Category.fromMap(data);
        categories.add(newCategory);
        categories.sort((a, b) => a.name.compareTo(b.name));
        setState(() { });
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
      categoryButton()
    ]);
  }

  Widget categoryButton() {
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
          ? IconButton(
              style: ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
                visualDensity: VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                shape: WidgetStatePropertyAll(
                  CircleBorder(),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: () {
                setState(() {
                  isAddingCategory = !isAddingCategory;
                });
              },
              icon: const Icon(Icons.close),
            )
          : IconButton(
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
    );
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
    child: Text("app.cancel".tr),
  );
}
