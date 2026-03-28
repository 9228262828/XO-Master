import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/di.dart';
import '../../domain/entities/category.dart';
import '../cubit/category_cubit.dart';
import '../cubit/category_state.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryCubit>()..loadCategories(),
      child: const _CategoriesContent(),
    );
  }
}

class _CategoriesContent extends StatelessWidget {
  const _CategoriesContent();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.categories),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddCategorySheet(context),
          ),
        ],
      ),
      body: BlocConsumer<CategoryCubit, CategoryState>(
        listenWhen: (prev, curr) =>
            curr is CategoryOperationSuccess || curr is CategoryError,
        listener: (context, state) {
          if (state is CategoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is CategoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        buildWhen: (prev, curr) =>
            curr is CategoryLoading ||
            curr is CategoryLoaded ||
            curr is CategoryError,
        builder: (context, state) {
          if (state is CategoryLoading) return const FullScreenLoader();
          if (state is CategoryError) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<CategoryCubit>().loadCategories(),
            );
          }
          if (state is CategoryLoaded) {
            if (state.categories.isEmpty) {
              return EmptyState(
                icon: Icons.grid_view_rounded,
                title: l.noCategories,
                subtitle: AppLocalizations.of(context)!.addCategory,
                actionLabel: AppLocalizations.of(context)!.addCategory,
                onAction: () => _showAddCategorySheet(context),
              );
            }
            return _buildList(context, state.categories);
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategorySheet(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Category> categories) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, index) {
        final category = categories[index];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            title: Text(
              category.name,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: category.isDefault
                ? Text(
                    'Default',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  )
                : null,
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              onSelected: (value) async {
                if (value == 'edit') {
                  _showEditCategorySheet(ctx, category);
                } else if (value == 'delete') {
                  _confirmDelete(ctx, category);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (!category.isDefault)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: AppColors.error)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddCategorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<CategoryCubit>(),
        child: const _CategoryFormSheet(),
      ),
    );
  }

  void _showEditCategorySheet(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<CategoryCubit>(),
        child: _CategoryFormSheet(categoryToEdit: category),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<CategoryCubit>().deleteCategory(category.id);
    }
  }
}

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({this.categoryToEdit});

  final Category? categoryToEdit;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category_rounded;
  Color _selectedColor = AppColors.categoryColors[0];
  bool _isLoading = false;

  final _icons = [
    Icons.restaurant_rounded, Icons.directions_car_rounded, Icons.shopping_bag_rounded,
    Icons.receipt_long_rounded, Icons.movie_rounded, Icons.favorite_rounded,
    Icons.school_rounded, Icons.flight_rounded, Icons.category_rounded,
    Icons.home_rounded, Icons.fitness_center_rounded, Icons.coffee_rounded,
    Icons.phone_android_rounded, Icons.pets_rounded, Icons.games_rounded,
    Icons.music_note_rounded, Icons.local_hospital_rounded, Icons.business_rounded,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameController.text = widget.categoryToEdit!.name;
      _selectedIcon = widget.categoryToEdit!.icon;
      _selectedColor = widget.categoryToEdit!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.categoryToEdit != null;
    final l = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Use a fixed max-height so the sheet never overflows the screen.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      isEditing ? l.edit : l.addCategory,
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l.categoryName,
                      prefixIcon:
                          const Icon(Icons.label_outline_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.selectColor,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppColors.categoryColors.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final color = AppColors.categoryColors[index];
                        final isSel =
                            color.toARGB32() == _selectedColor.toARGB32();
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                          color: color.withValues(alpha: 0.5),
                                          blurRadius: 8)
                                    ]
                                  : null,
                            ),
                            child: isSel
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l.selectIcon,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 116,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: _icons.length,
                      itemBuilder: (_, index) {
                        final icon = _icons[index];
                        final isSel =
                            icon.codePoint == _selectedIcon.codePoint;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIcon = icon),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? _selectedColor.withValues(alpha: 0.15)
                                  : isDark
                                      ? AppColors.darkSurfaceVariant
                                      : AppColors.lightSurfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel
                                    ? _selectedColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: isSel
                                  ? _selectedColor
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                              size: 22,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(isEditing ? l.save : l.addCategory),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }
    setState(() => _isLoading = true);

    if (widget.categoryToEdit != null) {
      context.read<CategoryCubit>().updateCategory(
            widget.categoryToEdit!.copyWith(
              name: _nameController.text.trim(),
              iconCodePoint: _selectedIcon.codePoint,
              colorValue: _selectedColor.toARGB32(),
            ),
          );
    } else {
      context.read<CategoryCubit>().addCategory(
            name: _nameController.text.trim(),
            icon: _selectedIcon,
            color: _selectedColor,
          );
    }
    Navigator.pop(context);
  }
}
