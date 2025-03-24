import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:lyfer/core/theme/theme_provider.dart';
import 'package:lyfer/core/utils/dialogs/confirm_dialog.dart';
import 'package:lyfer/features/auth/providers/auth_provider.dart';
import 'package:lyfer/features/settings/presentation/widgets/settings_profile_card.dart';
import 'package:lyfer/features/settings/presentation/widgets/settings_tile.dart';

/// Settings screen that allows users to configure app preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
// Watch the theme mode value (not the notifier)
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Column(
        children: [
          SettingsProfileCard(),
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 8),
                _buildDarkSwitch(context, ref, isDarkMode),
                const SizedBox(height: 8),
                _buildSignOutButton(context, ref),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildDarkSwitch(
  BuildContext context,
  WidgetRef ref,
  bool isDarkMode,
) {
  return SettingsTile(
    leading: const Icon(Icons.dark_mode),
    title: const Text('Dark Mode'),
    text: const Text('Enable dark mode'),
    trailing: Switch(
      value: isDarkMode,
      onChanged: (value) {
        // Toggle the theme mode
        ref.read(themeProvider.notifier).toggleTheme();
      },
    ),
  );
}

Widget _buildSignOutButton(
  BuildContext context,
  WidgetRef ref,
) {
  return SettingsTile(
    leading: const Icon(Icons.logout),
    title: const Text('Sign Out'),
    text: const Text('Sign out of your account'),
    onTap: () {
      ConfirmDialog.show(
              context: context, content: 'Are you sure you want to sign out?')
          .then((value) {
        if (value == true) {
          // Handle sign out logic here
          ref.read(authServiceProvider).signOut();
        }
      });
    },
    trailing: LineIcon(
      LineIcons.arrowRight,
      color: Theme.of(context).colorScheme.primary,
      size: 20,
    ),
  );
}
