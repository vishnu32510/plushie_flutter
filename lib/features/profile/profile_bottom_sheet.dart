import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plushie_yourself/core/di/injection.dart';
import 'package:plushie_yourself/core/services/plushie_storage_service.dart';
import 'package:plushie_yourself/core/services/toast_service.dart';
import 'package:plushie_yourself/core/utils/app_constants.dart';
import 'package:plushie_yourself/features/authentication/authentication.dart';
import 'package:plushie_yourself/features/authentication/widgets/login_bottom_sheet.dart';
import 'package:plushie_yourself/features/paywall/paywall_screen.dart';
import 'package:plushie_yourself/features/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileBottomSheet extends StatelessWidget {
  const ProfileBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationBlocState>(
      builder: (context, authState) {
        final isLoggedIn =
            authState.status == AuthenticationStatus.authenticated;
        final user = authState.user;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.warmBeige,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.subtleGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // App icon + name
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/app_icon.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plushify Me',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.warmBrown,
                        ),
                      ),
                      Text(
                        isLoggedIn
                            ? (user.email ?? user.name ?? 'Signed in')
                            : 'Not signed in',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.warmBrownLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Divider(color: AppColors.subtleGray.withValues(alpha: 0.6)),
              const SizedBox(height: 8),

              // Sign in / Sign out
              if (isLoggedIn)
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign out',
                  color: const Color(0xFFB85C4A),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AuthenticationBloc>().add(
                      const LogoutRequested(),
                    );
                  },
                )
              else
                _MenuItem(
                  icon: Icons.login_rounded,
                  label: 'Sign in',
                  onTap: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => const LoginBottomSheet(),
                    );
                  },
                ),
              if (isLoggedIn)
                _MenuItem(
                  icon: Icons.delete_forever_rounded,
                  label: 'Delete account',
                  color: const Color(0xFFB85C4A),
                  onTap: () => _handleDeleteAccount(context),
                ),

              const SizedBox(height: 4),
              Divider(color: AppColors.subtleGray.withValues(alpha: 0.6)),
              const SizedBox(height: 4),

              _MenuItem(
                icon: Icons.star_rounded,
                label: 'Manage Subscription',
                color: AppColors.warmAmber,
                onTap: () {
                  Navigator.pop(context);
                  PaywallScreen.show(context);
                },
              ),

              const SizedBox(height: 4),
              Divider(color: AppColors.subtleGray.withValues(alpha: 0.6)),
              const SizedBox(height: 4),

              _MenuItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => _openUrl(
                  context,
                  AppConstants.privacyPolicyUrl,
                ),
              ),
              _MenuItem(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () => _openUrl(
                  context,
                  AppConstants.termsUrl,
                ),
              ),
              _MenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Support',
                onTap: () => _openUrl(
                  context,
                  AppConstants.supportUrl,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void _openUrl(BuildContext context, String url) {
  Navigator.pop(context);
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

Future<void> _handleDeleteAccount(BuildContext context) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('Delete account?'),
          content: const Text(
            'This will permanently delete your account from Firebase. '
            'Your in-app plushie list will be cleared on this device, but image files are not deleted from Photos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        ),
  );

  if (shouldDelete != true || !context.mounted) return;

  Navigator.pop(context);
  final rootNavigator = Navigator.of(context, rootNavigator: true);
  var loadingShown = false;
  var requiresReauth = false;
  var success = false;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder:
        (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.warmAmber),
        ),
  );
  loadingShown = true;

  String message;
  try {
    await context.read<FirebaseAuthenticationRepository>().deleteAccount();
    await PlushieStorageService.clearVisibleEntries();
    message = 'Account deleted. Local gallery list cleared.';
    success = true;
  } on DeleteAccountFailure catch (e) {
    message = e.message;
    // Firebase often requires a recent login before deleting an account.
    requiresReauth = e.message.toLowerCase().contains('sign in again');
  } catch (_) {
    message = 'Could not delete account. Please try again.';
  } finally {
    if (loadingShown && rootNavigator.mounted && rootNavigator.canPop()) {
      rootNavigator.pop();
    }
  }

  if (requiresReauth && context.mounted) {
    showDialog<void>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Sign in again required'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AuthenticationBloc>().add(
                    const LogoutRequested(),
                  );
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => const LoginBottomSheet(),
                  );
                },
                child: const Text('Sign in again'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
    return;
  }

  if (context.mounted) {
    if (success) {
      getIt<IToastService>().showSuccess(message);
    } else {
      getIt<IToastService>().showError(message);
    }
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.warmBrown;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: c, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppColors.warmBrownLight,
      ),
      onTap: onTap,
    );
  }
}
