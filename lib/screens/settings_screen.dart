import 'package:fast_note/enums/sort_enums.dart';
import 'package:fast_note/models/settings.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:fast_note/providers/settings_provider.dart';
import 'package:fast_note/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settings = settingsProvider.settings;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('Settings',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            )),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Display', theme),
            _buildSettingSwitch(
              context: context,
              icon: Iconsax.link,
              title: 'Display Rich Links',
              subtitle: 'Show rich previews for links in notes',
              value: settings.displayRichLinks,
              onChanged: (value) => settingsProvider.toggleRichLinks(value),
            ),
            _buildSettingSwitch(
              context: context,
              icon: Iconsax.add_circle,
              title: 'Add New Items to Bottom',
              subtitle: 'New notes will appear at the bottom of the list',
              value: settings.addItemToBottom,
              onChanged: (value) => settingsProvider.toggleAddToBottom(value),
            ),

            _buildSectionHeader('Appearance', theme),
            _buildThemeSelector(themeProvider, settingsProvider),
            _buildSectionHeader('Features', theme),
            _buildSettingSwitch(
              context: context,
              icon: Iconsax.share,
              title: 'Enable Sharing',
              subtitle: 'Allow sharing notes with other apps',
              value: settings.enableSharing,
              onChanged: (value) => settingsProvider.toggleSharing(value),
            ),
            _buildSettingSwitch(
              context: context,
              icon: Iconsax.maximize,
              title: 'Full Screen Mode',
              subtitle: 'Hide system UI for immersive experience',
              value: settings.enableFullScreen,
              onChanged: (value) => settingsProvider.toggleFullScreen(value),
            ),
            _buildSettingSwitch(
              context: context,
              icon: Iconsax.search_normal_1,
              title: 'Open with Search Focus',
              subtitle: 'Automatically focus search bar when app opens',
              value: settings.openWithSearchBar,
              onChanged: (value) =>
                  settingsProvider.toggleOpenWithSearchBar(value),
            ),

            _buildSectionHeader('Default View', theme),
            _buildDefaultSortSelector(settingsProvider, theme),
            _buildSettingSwitch(
              context: context,
              icon: Iconsax.grid_1,
              title: 'Default Grid View',
              subtitle: 'Open app in grid view by default',
              value: settings.defaultGridView,
              onChanged: (value) async {
                await settingsProvider.updateDefaultGridView(value);
              },
            ),
            _buildSectionHeader('About', theme),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.info_circle,
                    color: Colors.white, size: 24),
              ),
              title: Text('App Version', style: theme.textTheme.bodyMedium),
              subtitle: const Text('1.0.0'),
              trailing: const Icon(Iconsax.arrow_right_3, size: 20),
              onTap: () => _showAboutDialog(context),
            ),

            const SizedBox(height: 32),

            Center(
              child: OutlinedButton(
                onPressed: () =>
                    _showResetConfirmation(context, settingsProvider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Reset to Default Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
      child: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
      ThemeProvider themeProvider, SettingsProvider settingsProvider) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.sun, color: Colors.amber, size: 20),
            ),
            title: Text('Theme', style: theme.textTheme.bodyMedium),
            subtitle: Text(
              _getThemeModeText(settingsProvider.settings.themeMode),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    'Light',
                    'light',
                    settingsProvider,
                    theme,
                    icon: Iconsax.sun_1,
                    iconColor: Colors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemeOption(
                    'Dark',
                    'dark',
                    settingsProvider,
                    theme,
                    icon: Iconsax.moon,
                    iconColor: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemeOption(
                    'System',
                    'system',
                    settingsProvider,
                    theme,
                    icon: Iconsax.cpu,
                    iconColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String title,
    String value,
    SettingsProvider settingsProvider,
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = settingsProvider.settings.themeMode == value;

    return GestureDetector(
      onTap: () async {
        settingsProvider.settings.themeMode = value;
        await settingsProvider.updateSettings(settingsProvider.settings);
        await Provider.of<ThemeProvider>(context, listen: false)
            .setThemeMode(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? theme.colorScheme.primary : iconColor,
                size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultSortSelector(
      SettingsProvider settingsProvider, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Iconsax.sort, color: Colors.purple, size: 20),
        ),
        title: Text('Default Sort', style: theme.textTheme.bodyMedium),
        subtitle: Text(
          _getSortOptionName(settingsProvider.settings.defaultSortOption),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: const Icon(Iconsax.arrow_right_3, size: 20),
        onTap: () => _showSortOptionsDialog(settingsProvider),
      ),
    );
  }

  String _getThemeModeText(String themeMode) {
    switch (themeMode) {
      case 'light':
        return 'Light Theme';
      case 'dark':
        return 'Dark Theme';
      case 'system':
        return 'Follow System';
      default:
        return 'Follow System';
    }
  }

  Widget _buildSettingSwitch({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        title: Text(title, style: theme.textTheme.bodyMedium),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  String _getSortOptionName(SortOption option) {
    switch (option) {
      case SortOption.dateUpdated:
        return 'Last Updated';
      case SortOption.dateCreated:
        return 'Date Created';
      case SortOption.title:
        return 'Title (A-Z)';
    }
  }

  void _showSortOptionsDialog(SettingsProvider settingsProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Default Sort By',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              height: 1,
            ),
            ...SortOption.values.map((option) {
              final isSelected =
                  settingsProvider.settings.defaultSortOption == option;
              return ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                title: Text(
                  _getSortOptionName(option),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                ),
                trailing: isSelected
                    ? Icon(
                        Iconsax.tick_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      )
                    : null,
                onTap: () async {
                  await settingsProvider.updateDefaultSortOption(option);
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('About Fast Note',
            style: Theme.of(context).textTheme.bodyLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'A beautiful note-taking app with customizable colors and themes.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('Rich text notes with colors'),
            _buildFeatureItem('Multiple view modes'),
            _buildFeatureItem('Customizable themes'),
            _buildFeatureItem('Offline storage'),
            _buildFeatureItem('Search functionality'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Iconsax.tick_circle,
              size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  void _showResetConfirmation(
      BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Reset Settings?',
            style: Theme.of(context).textTheme.bodyLarge),
        content: Text('All settings will be restored to default values.',
            style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                )),
          ),
          TextButton(
            onPressed: () {
              settingsProvider.updateSettings(Settings());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Settings reset to default'),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}