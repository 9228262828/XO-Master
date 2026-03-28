import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/di.dart';
import '../../../../services/settings_service.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../../categories/presentation/cubit/category_state.dart';
import '../../domain/entities/expense.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

/// Thin wrapper — provides BLoCs, then delegates to [_AddExpenseForm].
/// Keeping providers here (outside the State) ensures State.context
/// is always a descendant of MultiBlocProvider, so context.read() works.
class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key, this.expenseToEdit});

  final Expense? expenseToEdit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ExpenseCubit>()..loadExpenses()),
        BlocProvider(create: (_) => sl<CategoryCubit>()..loadCategories()),
      ],
      child: _AddExpenseForm(expenseToEdit: expenseToEdit),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The actual form — now a direct child of MultiBlocProvider, so
// State.context IS inside the provider tree.
// ─────────────────────────────────────────────────────────────────────────────
class _AddExpenseForm extends StatefulWidget {
  const _AddExpenseForm({this.expenseToEdit});
  final Expense? expenseToEdit;

  @override
  State<_AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<_AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  bool get _isEditing => widget.expenseToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _amountController.text = widget.expenseToEdit!.amount.toStringAsFixed(2);
      _noteController.text = widget.expenseToEdit!.note ?? '';
      _selectedCategoryId = widget.expenseToEdit!.categoryId;
      _selectedDate = widget.expenseToEdit!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // context here is a descendant of MultiBlocProvider — safe to use.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    return BlocListener<ExpenseCubit, ExpenseState>(
      listener: (ctx, state) {
        if (state is ExpenseOperationSuccess) {
          ctx.pop();
        } else if (state is ExpenseError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isLoading = false);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: Text(_isEditing ? l.editExpense : l.addExpense),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                onPressed: _confirmDelete,
              ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _AmountField(controller: _amountController),
                const SizedBox(height: 20),
                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    final categories =
                        state is CategoryLoaded ? state.categories : <Category>[];
                    if (_selectedCategoryId == null && categories.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _selectedCategoryId = categories.first.id);
                        }
                      });
                    }
                    return _CategorySelector(
                      categories: categories,
                      selectedId: _selectedCategoryId,
                      onSelected: (id) => setState(() => _selectedCategoryId = id),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _DateSelector(
                  date: _selectedDate,
                  onChanged: (date) => setState(() => _selectedDate = date),
                ),
                const SizedBox(height: 20),
                _NoteField(controller: _noteController),
                const SizedBox(height: 32),
                AppButton(
                  label: _isEditing ? l.editExpense : l.addExpense,
                  onPressed: _isLoading ? null : _submit,
                  isLoading: _isLoading,
                  icon: _isEditing ? Icons.check_rounded : Icons.add_rounded,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.category)),
      );
      return;
    }

    setState(() => _isLoading = true);
    final amount = double.parse(_amountController.text.replaceAll(',', ''));
    final note =
        _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    if (_isEditing) {
      context.read<ExpenseCubit>().updateExpense(
            widget.expenseToEdit!.copyWith(
              amount: amount,
              categoryId: _selectedCategoryId,
              date: _selectedDate,
              note: note,
            ),
          );
    } else {
      context.read<ExpenseCubit>().addExpense(
            amount: amount,
            categoryId: _selectedCategoryId!,
            date: _selectedDate,
            note: note,
          );
    }
  }

  void _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l.deleteConfirmTitle),
          content: Text(l.deleteConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(l.delete),
            ),
          ],
        );
      },
    );
    if (confirm == true && mounted) {
      context.read<ExpenseCubit>().deleteExpense(widget.expenseToEdit!.id);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final currencyCode = SettingsService.instance.currencyCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.amount,
            style: AppTextStyles.labelLarge.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                currencyCode == 'USD' ? '\$' : currencyCode,
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: Validators.validateAmount,
                  autofocus: true,
                  style: AppTextStyles.displayMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                    hintText: '0.00',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            AppLocalizations.of(context)!.category,
            style: AppTextStyles.labelLarge.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final category = categories[index];
              final isSelected = category.id == selectedId;
              return GestureDetector(
                onTap: () => onSelected(category.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color.withValues(alpha: 0.15)
                        : isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? category.color
                          : isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                      width: isSelected ? 2 : 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category.icon,
                        color: isSelected
                            ? category.color
                            : colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.name.split(' ').first,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected
                              ? category.color
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.date, required this.onChanged});

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme:
                  Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.date,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    AppDateUtils.formatDateFull(date),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      maxLines: 3,
      minLines: 1,
      textInputAction: TextInputAction.done,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: '${l.note} (${l.optional})',
        prefixIcon: const Icon(Icons.notes_rounded, size: 20),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
