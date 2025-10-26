import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';
import '../../core/utils/currency_formatter.dart';

/// Comprehensive profile page with user settings and financial profile management
/// Follows Single Responsibility Principle - manages user profile UI
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock user data - in real app, this would come from auth service
  final UserProfile _userProfile = const UserProfile(
    monthlyIncome: 5000.0,
    monthlyExpenses: 3000.0,
    monthlyFunBudget: 800.0,
    allowSmartSplit: true,
    showAmountsToGroup: false,
  );
  
  // Mock user info - in real app, this would come from auth service
  final String _userName = 'John Doe';
  final String _userEmail = 'john.doe@example.com';

  bool _isDarkMode = false;
  String _preferredCurrency = 'USD';
  bool _notificationsEnabled = true;
  bool _smartSplitEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Profile header with sliver app bar
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Profile',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20), // Minimal space for app bar
                      // User avatar and info
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.surface,
                        child: CircleAvatar(
                          radius: 27,
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            _userName.isNotEmpty 
                                ? _userName[0].toUpperCase() 
                                : 'U',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _userEmail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8), // Minimal space for title
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Profile content
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              
              // Financial Profile Section
              _buildSectionCard(
                title: 'Financial Profile',
                icon: Icons.account_balance_wallet,
                children: [
                  _buildFinancialOverview(),
                  const SizedBox(height: 16),
                  _buildFinancialMetrics(),
                  const SizedBox(height: 16),
                  _buildPrivacySettings(),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // App Settings Section
              _buildSectionCard(
                title: 'App Settings',
                icon: Icons.settings,
                children: [
                  _buildAppSettings(),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Smart Split Settings
              _buildSectionCard(
                title: 'Smart Split',
                icon: Icons.smart_toy,
                children: [
                  _buildSmartSplitSettings(),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Account Actions
              _buildSectionCard(
                title: 'Account',
                icon: Icons.account_circle,
                children: [
                  _buildAccountActions(),
                ],
              ),
              
              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Section content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Overview',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Income',
                  CurrencyFormatter.format(_userProfile.monthlyIncome),
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricItem(
                  'Expenses',
                  CurrencyFormatter.format(_userProfile.monthlyExpenses),
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetricItem(
            'Fun Budget',
            CurrencyFormatter.format(_userProfile.monthlyFunBudget),
            Icons.celebration,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetrics() {
    final savingsRate = ((_userProfile.monthlyIncome - _userProfile.monthlyExpenses) / _userProfile.monthlyIncome * 100).clamp(0, 100);
    final funBudgetPercent = (_userProfile.monthlyFunBudget / _userProfile.monthlyIncome * 100).clamp(0, 100);
    
    return Column(
      children: [
        _buildProgressIndicator(
          'Savings Rate',
          '${savingsRate.toStringAsFixed(1)}%',
          savingsRate / 100,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildProgressIndicator(
          'Fun Budget Allocation',
          '${funBudgetPercent.toStringAsFixed(1)}%',
          funBudgetPercent / 100,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy & Sharing',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildSettingsTile(
          icon: Icons.visibility,
          title: 'Show amounts to group',
          subtitle: _userProfile.showAmountsToGroup 
              ? 'Group members can see your expense amounts'
              : 'Your expense amounts are private',
          trailing: Switch(
            value: _userProfile.showAmountsToGroup,
            onChanged: (value) {
              // TODO: Update user profile
            },
          ),
        ),
        _buildSettingsTile(
          icon: Icons.smart_toy,
          title: 'Smart split suggestions',
          subtitle: _userProfile.allowSmartSplit 
              ? 'Enable AI-powered fair splitting'
              : 'Use equal splitting only',
          trailing: Switch(
            value: _userProfile.allowSmartSplit,
            onChanged: (value) {
              // TODO: Update user profile
            },
          ),
        ),
      ],
    );
  }



  Widget _buildAppSettings() {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.palette,
          title: 'Dark Mode',
          subtitle: 'Switch between light and dark themes',
          trailing: Switch(
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              // TODO: Implement theme switching
            },
          ),
        ),
        _buildSettingsTile(
          icon: Icons.currency_exchange,
          title: 'Default Currency',
          subtitle: _preferredCurrency,
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showCurrencySelector,
        ),
        _buildSettingsTile(
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Expense updates and reminders',
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSmartSplitSettings() {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.smart_toy,
          title: 'Smart Split',
          subtitle: 'Enable AI-powered fair expense splitting',
          trailing: Switch(
            value: _smartSplitEnabled,
            onChanged: (value) {
              setState(() {
                _smartSplitEnabled = value;
              });
            },
          ),
        ),
        if (_smartSplitEnabled) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Smart Split uses your financial profile to suggest fair expense distributions.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.edit,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showEditProfile,
        ),
        _buildSettingsTile(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'FAQs, contact support',
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showHelpSupport,
        ),
        _buildSettingsTile(
          icon: Icons.info,
          title: 'About',
          subtitle: 'Version, licenses, terms',
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showAbout,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showSignOutConfirmation,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }



  void _showCurrencySelector() {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'INR', 'BRL'];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Currency',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...currencies.map((currency) => ListTile(
              title: Text(currency),
              trailing: _preferredCurrency == currency 
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _preferredCurrency = currency;
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showEditProfile() {
    // TODO: Navigate to edit profile page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile coming soon')),
    );
  }

  void _showHelpSupport() {
    // TODO: Navigate to help & support page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & support coming soon')),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Count Splitter',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.calculate,
        size: 32,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const Text(
          'A smart expense splitting app that makes group expenses fair and easy to manage.',
        ),
      ],
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement sign out
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

