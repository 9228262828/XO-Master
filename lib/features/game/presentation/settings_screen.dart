import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/app_theme.dart';
import '../../../services/sound_service.dart';
import '../../../services/theme_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeService = context.watch<ThemeService>();
    final soundService = context.watch<SoundService>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkBgGradient : AppColors.lightBgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildAppBar(context, isDark),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  children: [
                    _SectionHeader(title: 'General', isDark: isDark),
                    const SizedBox(height: 10),
                    _SettingsTile(
                      isDark: isDark,
                      icon: Icons.dark_mode_rounded,
                      title: 'Dark Mode',
                      subtitle: themeService.themeMode == ThemeMode.system
                          ? 'System default'
                          : isDark
                              ? 'On'
                              : 'Off',
                      trailing: Switch.adaptive(
                        value: isDark,
                        activeColor: AppColors.primary(isDark),
                        onChanged: (_) => themeService.toggleTheme(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SettingsTile(
                      isDark: isDark,
                      icon: Icons.volume_up_rounded,
                      title: 'Sound & Haptics',
                      subtitle: soundService.enabled ? 'On' : 'Off',
                      trailing: Switch.adaptive(
                        value: soundService.enabled,
                        activeColor: AppColors.primary(isDark),
                        onChanged: (_) => soundService.toggle(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SectionHeader(title: 'Legal', isDark: isDark),
                    const SizedBox(height: 10),
                    _SettingsTile(
                      isDark: isDark,
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.textSecondary(isDark),
                        size: 16,
                      ),
                      onTap: () => _showPrivacyPolicy(context, isDark),
                    ),
                    const SizedBox(height: 8),
                    _SettingsTile(
                      isDark: isDark,
                      icon: Icons.description_rounded,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms',
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.textSecondary(isDark),
                        size: 16,
                      ),
                      onTap: () => _showTermsOfService(context, isDark),
                    ),
                    const SizedBox(height: 28),
                    _SectionHeader(title: 'About', isDark: isDark),
                    const SizedBox(height: 10),
                    _SettingsTile(
                      isDark: isDark,
                      icon: Icons.info_outline_rounded,
                      title: 'Version',
                      subtitle: '1.0.0',
                      trailing: const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _BackButton(isDark: isDark),
          const SizedBox(width: 14),
          Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context, bool isDark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PolicyPage(
          isDark: isDark,
          title: 'Privacy Policy',
          content: _privacyPolicyText,
        ),
      ),
    );
  }

  void _showTermsOfService(BuildContext context, bool isDark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PolicyPage(
          isDark: isDark,
          title: 'Terms of Service',
          content: _termsOfServiceText,
        ),
      ),
    );
  }
}

class _PolicyPage extends StatelessWidget {
  final bool isDark;
  final String title;
  final String content;

  const _PolicyPage({
    required this.isDark,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: dark ? AppColors.darkBgGradient : AppColors.lightBgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _BackButton(isDark: dark),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(dark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  child: Text(
                    content,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.7,
                      color: AppColors.textPrimary(dark),
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
}

class _BackButton extends StatelessWidget {
  final bool isDark;
  const _BackButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(isDark).withOpacity(isDark ? 0.4 : 1.0),
      borderRadius: BorderRadius.circular(12),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary(isDark),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary(isDark),
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(isDark).withOpacity(isDark ? 0.5 : 1.0),
      borderRadius: BorderRadius.circular(16),
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withOpacity(0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary(isDark).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary(isDark), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

const String _privacyPolicyText = '''
Last updated: April 2026

XO Master ("we", "our", or "us") respects your privacy and is committed to protecting your personal data. This privacy policy explains how we handle information when you use our mobile application XO Master - Tic Tac Toe ("the App").

1. Information We Collect

The App is designed to be a simple, offline game. We do not collect, store, or transmit any personal information from our users. The App does not require you to create an account, sign in, or provide any personal details.

2. Data Storage

All game data, including scores and preferences (such as theme and sound settings), is stored locally on your device. This data is never transmitted to any external servers.

3. Third-Party Services

The App does not integrate with any third-party analytics, advertising, or tracking services. We do not share any data with third parties.

4. Children's Privacy

The App is suitable for users of all ages. Since we do not collect any personal information, there are no special concerns regarding children's privacy under COPPA or similar regulations.

5. Permissions

The App does not require any special device permissions. It does not access your camera, microphone, contacts, location, or any other sensitive device features.

6. Changes to This Policy

We may update this privacy policy from time to time. Any changes will be reflected within the App. We encourage you to review this policy periodically.

7. Contact Us

If you have any questions or concerns about this privacy policy, please contact us at:

Email: support@xomaster.app

By using XO Master, you agree to the terms outlined in this privacy policy.
''';

const String _termsOfServiceText = '''
Last updated: April 2026

Please read these Terms of Service ("Terms") carefully before using the XO Master - Tic Tac Toe mobile application ("the App") operated by XO Master ("we", "our", or "us").

1. Acceptance of Terms

By downloading, installing, or using the App, you agree to be bound by these Terms. If you do not agree to these Terms, please do not use the App.

2. License

We grant you a limited, non-exclusive, non-transferable, revocable license to use the App for personal, non-commercial purposes on any device that you own or control, subject to these Terms.

3. Restrictions

You agree not to:
- Modify, reverse engineer, decompile, or disassemble the App
- Copy, distribute, or create derivative works based on the App
- Use the App for any unlawful purpose
- Attempt to gain unauthorized access to any part of the App

4. Intellectual Property

The App, including all content, features, graphics, and design elements, is owned by us and is protected by intellectual property laws. All rights not expressly granted are reserved.

5. Disclaimer of Warranties

The App is provided "as is" and "as available" without warranties of any kind, either express or implied. We do not warrant that the App will be uninterrupted, error-free, or free of harmful components.

6. Limitation of Liability

To the fullest extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the App.

7. Changes to Terms

We reserve the right to modify these Terms at any time. Changes will be effective when posted within the App. Your continued use of the App after changes constitutes acceptance of the new Terms.

8. Governing Law

These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which we operate, without regard to conflict of law principles.

9. Contact Us

If you have any questions about these Terms, please contact us at:

Email: support@xomaster.app

By using XO Master, you acknowledge that you have read, understood, and agree to be bound by these Terms.
''';
