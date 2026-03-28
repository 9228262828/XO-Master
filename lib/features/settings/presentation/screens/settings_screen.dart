import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../services/di.dart';
import '../../../../services/export_service.dart';
import '../../../../services/settings_service.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../../categories/presentation/cubit/category_state.dart';
import '../../../expenses/presentation/cubit/expense_cubit.dart';
import '../../../expenses/presentation/cubit/expense_state.dart';
import '../cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingsCubit is provided at the root (main.dart). 
    // Only provide the data-loading cubits needed for CSV export here.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ExpenseCubit>()..loadExpenses()),
        BlocProvider(create: (_) => sl<CategoryCubit>()..loadCategories()),
      ],
      child: const _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          final l = AppLocalizations.of(context)!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SettingsSection(
                title: l.appearance,
                children: [_ThemeTile(settings: settings)],
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: l.general,
                children: [
                  _CurrencyTile(settings: settings),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _LanguageTile(settings: settings),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: l.notifications,
                children: [
                  _NotificationTile(settings: settings),
                  if (settings.notificationsEnabled) ...[
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _ReminderTimeTile(settings: settings),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: l.exportData,
                children: [_ExportTile()],
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: l.about,
                children: [
                  _InfoTile(
                    icon: Icons.info_outline_rounded,
                    title: l.version,
                    subtitle: '1.0.0',
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _PrivacyPolicyTile(),
                ],
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.settings});

  final SettingsState settings;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.palette_rounded, color: AppColors.primary, size: 20),
      ),
      title: Text(AppLocalizations.of(context)!.darkMode),
      subtitle: Text(_themeName(context, settings.themeMode)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () => _showThemePicker(context, settings.themeMode, AppLocalizations.of(context)!),
    );
  }

  String _themeName(BuildContext context, ThemeMode mode) {
    final l = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.light:
        return l.light;
      case ThemeMode.dark:
        return l.dark;
      default:
        return l.systemDefault;
    }
  }

  void _showThemePicker(BuildContext context, ThemeMode current, AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(l.darkMode, style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              for (final mode in ThemeMode.values)
                ListTile(
                  leading: Icon(_themeIcon(mode)),
                  title: Text(_themeName(ctx, mode)),
                  trailing: mode == current
                      ? const Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ctx.read<SettingsCubit>().setThemeMode(mode);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      default:
        return Icons.brightness_auto_rounded;
    }
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({required this.settings});

  final SettingsState settings;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.attach_money_rounded, color: AppColors.success, size: 20),
      ),
      title: Text(AppLocalizations.of(context)!.currency),
      subtitle: Text('${settings.currencyCode} (${CurrencyFormatter.symbol(settings.currencyCode)})'),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () => _showCurrencyPicker(context),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (_, controller) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.currency, style: AppTextStyles.headlineSmall),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: AppConstants.supportedCurrencies.length,
                    itemBuilder: (_, index) {
                      final code = AppConstants.supportedCurrencies[index];
                      final isSelected = code == settings.currencyCode;
                      return ListTile(
                        leading: Text(
                          CurrencyFormatter.symbol(code),
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(code),
                        trailing: isSelected
                            ? const Icon(Icons.check_rounded, color: AppColors.primary)
                            : null,
                        onTap: () {
                          ctx.read<SettingsCubit>().setCurrencyCode(code);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.settings});

  final SettingsState settings;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.language_rounded, color: AppColors.secondary, size: 20),
      ),
      title: Text(AppLocalizations.of(context)!.language),
      subtitle: Text(settings.languageCode == 'ar'
          ? AppLocalizations.of(context)!.arabic
          : AppLocalizations.of(context)!.english),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () => _showLanguagePicker(context),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(AppLocalizations.of(context)!.language, style: AppTextStyles.headlineSmall),
              const SizedBox(height: 16),
              for (final code in AppConstants.supportedLocales)
                ListTile(
                  leading: Text(
                    code == 'ar' ? '🇸🇦' : '🇺🇸',
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(code == 'ar'
                      ? '${AppLocalizations.of(ctx)!.arabic} (العربية)'
                      : AppLocalizations.of(ctx)!.english),
                  trailing: code == settings.languageCode
                      ? const Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ctx.read<SettingsCubit>().setLanguageCode(code);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.settings});

  final SettingsState settings;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.notifications_outlined, color: AppColors.warning, size: 20),
      ),
      title: Text(AppLocalizations.of(context)!.notifications),
      subtitle: Text(AppLocalizations.of(context)!.notificationsDesc),
      trailing: Switch.adaptive(
        value: settings.notificationsEnabled,
        onChanged: (v) => context.read<SettingsCubit>().toggleNotifications(v),
        activeThumbColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withAlpha(128),
      ),
    );
  }
}

class _ReminderTimeTile extends StatelessWidget {
  const _ReminderTimeTile({required this.settings});

  final SettingsState settings;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay(hour: settings.reminderHour, minute: settings.reminderMinute);
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.access_time_rounded, color: AppColors.warning, size: 20),
      ),
      title: Text(AppLocalizations.of(context)!.reminderTime),
      subtitle: Text(time.format(context)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.primary),
            ),
            child: child!,
          ),
        );
        if (picked != null && context.mounted) {
          context.read<SettingsCubit>().setReminderTime(picked.hour, picked.minute);
        }
      },
    );
  }
}

class _ExportTile extends StatelessWidget {
  const _ExportTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.download_rounded, color: AppColors.primary, size: 20),
      ),
      title: Text(AppLocalizations.of(context)!.exportCSV),
      subtitle: Text(AppLocalizations.of(context)!.exportDesc),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () => _exportData(context),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final expenseState = context.read<ExpenseCubit>().state;
    final categoryState = context.read<CategoryCubit>().state;

    if (expenseState is! ExpenseLoaded || categoryState is! CategoryLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for data to load')),
      );
      return;
    }

    if (expenseState.allExpenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expenses to export')),
      );
      return;
    }

    final currencyCode = SettingsService.instance.currencyCode;
    final categoryMap = {for (final c in categoryState.categories) c.id: c};

    await ExportService.instance.exportToCSV(
      expenseState.allExpenses,
      categoryMap,
      currencyCode,
      context,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _PrivacyPolicyTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A).withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.shield_outlined,
            size: 20, color: Color(0xFF16A34A)),
      ),
      title: const Text('Privacy Policy'),
      subtitle: const Text('Your data stays on device'),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: () => context.push(AppRoutes.privacyPolicy),
    );
  }
}
