import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const String _contactEmail = 'legal@spendwise.app';
  static const String _websiteUrl = 'https://9228262828.github.io/SpendWise/terms/';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          ..._sections.map((s) => _TermsSection(
                title: s['title']!,
                body: s['body']!,
                isDark: isDark,
                colorScheme: colorScheme,
              )),

          // Contact section
          const SizedBox(height: 8),
          _buildContactSection(context, isDark, colorScheme),
          const SizedBox(height: 16),

          // Link back to Privacy Policy
          _buildPrivacyLink(context, isDark, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            'Terms & Conditions',
            style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'By downloading and using SpendWise, you agree to these terms. Please read them carefully before using the app.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 12, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                'Effective date: March 2025  •  Version 1.0',
                style: AppTextStyles.labelSmall
                    .copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(
      BuildContext context, bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '10. Contact & Governing Law',
            style: AppTextStyles.headlineSmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'These Terms are governed by applicable law. For any questions regarding these Terms, please contact us:',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),

          // Email link
          _ContactLinkTile(
            icon: Icons.email_outlined,
            label: _contactEmail,
            onTap: () => _launchEmail(context),
          ),
          const SizedBox(height: 8),

          // Website link
          _ContactLinkTile(
            icon: Icons.language_rounded,
            label: _websiteUrl,
            onTap: () => _launchWebsite(context),
          ),

          const SizedBox(height: 12),
          Text(
            'We aim to respond to all legal inquiries within 14 business days.',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyLink(
      BuildContext context, bool isDark, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => context.push(AppRoutes.privacyPolicy),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF16A34A).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.shield_outlined,
                  color: Color(0xFF16A34A), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF16A34A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Read our full privacy policy',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Color(0xFF16A34A)),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _contactEmail,
      query: 'subject=SpendWise Terms & Conditions Inquiry',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open mail app. Email us at $_contactEmail'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _launchWebsite(BuildContext context) async {
    final uri = Uri.parse(_websiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open browser'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static const List<Map<String, String>> _sections = [
    {
      'title': '1. Acceptance of Terms',
      'body':
          'By downloading, installing, or using SpendWise ("the App"), you agree to be bound by these Terms and Conditions ("Terms"). If you do not agree to these Terms, please do not use the App.\n\n'
          'We reserve the right to update these Terms at any time. Continued use of the App after changes constitutes acceptance of the updated Terms.',
    },
    {
      'title': '2. License to Use',
      'body':
          'SpendWise grants you a limited, non-exclusive, non-transferable, revocable license to install and use the App on your personal mobile device solely for your own personal, non-commercial purposes.\n\n'
          'You may not:\n'
          '• Copy, modify, or distribute the App or its content\n'
          '• Reverse-engineer or attempt to extract source code\n'
          '• Use the App for any commercial purpose\n'
          '• Transfer your license to any other person\n'
          '• Remove any proprietary notices or labels on the App',
    },
    {
      'title': '3. Your Responsibilities',
      'body':
          'You are responsible for:\n\n'
          '• Maintaining the security of your device\n'
          '• All data you enter into the App\n'
          '• Backing up your data (the App stores data locally; we cannot recover lost data)\n'
          '• Ensuring you have the necessary permissions to use the App in your jurisdiction\n\n'
          'You agree not to use the App for any unlawful purpose or in any way that could damage, disable, or impair the App.',
    },
    {
      'title': '4. Intellectual Property',
      'body':
          'The App and its original content, features, and functionality are owned by SpendWise and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.\n\n'
          'The SpendWise name, logo, and all related names, logos, product and service names, designs, and slogans are trademarks of SpendWise. You must not use such marks without our prior written permission.',
    },
    {
      'title': '5. Data and Privacy',
      'body':
          'SpendWise stores all your expense data locally on your device. We do not collect, transmit, or store any of your personal or financial data on our servers.\n\n'
          'You retain full ownership of all data you enter into the App. By using the App, you acknowledge that you have read and understood our Privacy Policy, which is incorporated into these Terms by reference.',
    },
    {
      'title': '6. Disclaimer of Warranties',
      'body':
          'THE APP IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED.\n\n'
          'We do not warrant that:\n'
          '• The App will be uninterrupted or error-free\n'
          '• Defects will be corrected\n'
          '• The App is free of viruses or other harmful components\n'
          '• The results of using the App will meet your requirements\n\n'
          'The App is intended for personal expense tracking only and should not be used as a substitute for professional financial advice.',
    },
    {
      'title': '7. Limitation of Liability',
      'body':
          'TO THE MAXIMUM EXTENT PERMITTED BY LAW, SPENDWISE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING BUT NOT LIMITED TO:\n\n'
          '• Loss of data\n'
          '• Loss of profits\n'
          '• Loss of goodwill\n'
          '• Service interruption\n'
          '• Computer damage or system failure\n\n'
          'Our total liability to you for any claim arising from these Terms or your use of the App shall not exceed the amount you paid for the App (if any).',
    },
    {
      'title': '8. Third-Party Services',
      'body':
          'The App does not integrate with any third-party services that process your personal data. The App may use Google Fonts for typography, which may involve a network request on first launch. This request contains no personal data.\n\n'
          'Any links or references to third-party websites or services are provided for convenience only. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.',
    },
    {
      'title': '9. Termination',
      'body':
          'These Terms are effective until terminated by either you or SpendWise.\n\n'
          'Your rights under these Terms will terminate automatically if you fail to comply with any of its provisions. Upon termination, you must destroy all copies of the App and all of its component parts.\n\n'
          'We reserve the right to discontinue the App or any of its features at any time without notice. You may terminate these Terms at any time by deleting the App from your device.',
    },
  ];
}

// ─── Contact link tile ────────────────────────────────────────────────────────
class _ContactLinkTile extends StatelessWidget {
  const _ContactLinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
            const Icon(Icons.open_in_new_rounded,
                size: 14, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────
class _TermsSection extends StatelessWidget {
  const _TermsSection({
    required this.title,
    required this.body,
    required this.isDark,
    required this.colorScheme,
  });

  final String title;
  final String body;
  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.78),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
