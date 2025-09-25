import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../themes/app_colour.dart';
import '../../models/contact.dart';
import '../../services/contact_service.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  Contact? _contact;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  Future<void> _loadContact() async {
    try {
      final contact = await ContactService.getActiveContact();
      if (mounted) {
        setState(() {
          _contact = contact;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Contact Us',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.support_agent,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Get in Touch',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'We\'re here to help with your rental needs',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Methods
                  if (_contact != null) ...[
                    if (_contact!.phone != null && _contact!.phone!.isNotEmpty)
                      _buildContactCard(
                        icon: Icons.phone,
                        title: 'Phone',
                        subtitle: _contact!.phone!,
                        color: Colors.green,
                        onTap: () => _launchUrl('tel:${_contact!.phone}'),
                        isDark: isDark,
                      ),

                    if (_contact!.email != null && _contact!.email!.isNotEmpty)
                      _buildContactCard(
                        icon: Icons.email,
                        title: 'Email',
                        subtitle: _contact!.email!,
                        color: Colors.blue,
                        onTap: () => _launchUrl('mailto:${_contact!.email}'),
                        isDark: isDark,
                      ),

                    if (_contact!.whatsapp != null && _contact!.whatsapp!.isNotEmpty)
                      _buildContactCard(
                        icon: Icons.chat,
                        title: 'WhatsApp',
                        subtitle: 'Chat with us',
                        color: const Color(0xFF25D366),
                        onTap: () {
                          // Clean the phone number for WhatsApp
                          String cleanPhone = _contact!.whatsapp!.replaceAll(RegExp(r'[^\d+]'), '');
                          if (!cleanPhone.startsWith('+')) {
                            cleanPhone = '+$cleanPhone';
                          }
                          _launchUrl('https://wa.me/$cleanPhone');
                        },
                        isDark: isDark,
                      ),

                    const SizedBox(height: 16),
                    Text(
                      'Follow Us',
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Social Media Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (_contact!.instagram != null && _contact!.instagram!.isNotEmpty)
                          _buildSocialButton(
                            icon: Icons.camera_alt,
                            color: const Color(0xFFE4405F),
                            onTap: () => _launchUrl(_contact!.instagram!),
                          ),

                        if (_contact!.facebook != null && _contact!.facebook!.isNotEmpty)
                          _buildSocialButton(
                            icon: Icons.facebook,
                            color: const Color(0xFF1877F2),
                            onTap: () => _launchUrl(_contact!.facebook!),
                          ),

                        if (_contact!.youtube != null && _contact!.youtube!.isNotEmpty)
                          _buildSocialButton(
                            icon: Icons.play_arrow,
                            color: const Color(0xFFFF0000),
                            onTap: () => _launchUrl(_contact!.youtube!),
                          ),
                      ],
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Contact information not available',
                            style: TextStyle(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again later',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 60,
          height: 60,
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      bool launched = false;

      // Special handling for different URL types
      if (url.startsWith('mailto:')) {
        // Try to launch email app
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
        } catch (e) {
          // Fallback: try platform default or show in browser
          try {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
            launched = true;
          } catch (e2) {
            // Final fallback: open Gmail in browser
            final email = url.substring(7); // Remove 'mailto:'
            final gmailUrl = 'https://mail.google.com/mail/?view=cm&to=$email';
            await launchUrl(Uri.parse(gmailUrl), mode: LaunchMode.externalApplication);
            launched = true;
          }
        }
      } else if (url.contains('wa.me')) {
        // WhatsApp handling
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
        } catch (e) {
          // Fallback: open WhatsApp web
          try {
            final webWhatsApp = url.replaceFirst('https://wa.me/', 'https://web.whatsapp.com/send?phone=');
            await launchUrl(Uri.parse(webWhatsApp), mode: LaunchMode.externalApplication);
            launched = true;
          } catch (e2) {
            // Final fallback: platform default
            await launchUrl(uri, mode: LaunchMode.platformDefault);
            launched = true;
          }
        }
      } else {
        // Generic URL handling (social media, etc.)
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
        } catch (e) {
          try {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
            launched = true;
          } catch (e2) {
            await launchUrl(uri, mode: LaunchMode.inAppWebView);
            launched = true;
          }
        }
      }

      if (!launched) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $url'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching $url: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}