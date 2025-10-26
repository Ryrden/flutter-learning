import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/group.dart';
import '../../domain/entities/expense.dart';

import '../../core/utils/currency_formatter.dart';
import '../providers/group_provider.dart';
import 'add_expense_page.dart';

/// Page showing group details, members, and expenses
/// Displays group information and allows navigation to add expenses
class GroupDetailPage extends StatefulWidget {
  final Group group;

  const GroupDetailPage({
    super.key,
    required this.group,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Expense> _expenses = []; // TODO: Implement expense loading

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load the latest group data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().loadGroup(widget.group.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final currentGroup = groupProvider.selectedGroup ?? widget.group;
        
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      currentGroup.name,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60), // Space for app bar
                            if (currentGroup.description.isNotEmpty) ...[
                              Text(
                                currentGroup.description,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 16,
                                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${currentGroup.members.length} ${currentGroup.members.length == 1 ? 'member' : 'members'}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.attach_money,
                                  size: 16,
                                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  currentGroup.currency,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40), // Space for title
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                      indicatorColor: theme.colorScheme.primary,
                      tabs: const [
                        Tab(text: 'Expenses', icon: Icon(Icons.receipt_long)),
                        Tab(text: 'Members', icon: Icon(Icons.people)),
                        Tab(text: 'Summary', icon: Icon(Icons.analytics)),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildExpensesTab(currentGroup),
                _buildMembersTab(currentGroup),
                _buildSummaryTab(currentGroup),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToAddExpense(currentGroup),
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        );
      },
    );
  }

  Widget _buildExpensesTab(Group group) {
    if (_expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first expense to start splitting costs',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddExpense(group),
              icon: const Icon(Icons.add),
              label: const Text('Add First Expense'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return _ExpenseCard(expense: expense, group: group);
      },
    );
  }

  Widget _buildMembersTab(Group group) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: group.members.length,
      itemBuilder: (context, index) {
        final member = group.members[index];
        return _MemberCard(member: member, group: group);
      },
    );
  }

  Widget _buildSummaryTab(Group group) {
    final totalExpenses = _expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    final avgExpensePerMember = group.members.isNotEmpty ? totalExpenses / group.members.length : 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryCard(
            title: 'Total Expenses',
            value: CurrencyFormatter.formatWithSymbol(totalExpenses, group.currency),
            icon: Icons.receipt_long,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _SummaryCard(
            title: 'Number of Expenses',
            value: '${_expenses.length}',
            icon: Icons.numbers,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _SummaryCard(
            title: 'Average per Member',
            value: CurrencyFormatter.formatWithSymbol(avgExpensePerMember, group.currency),
            icon: Icons.person,
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Group Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SettingRow(
                    icon: Icons.smart_toy,
                    title: 'Smart Split',
                    subtitle: 'Split expenses based on financial profiles',
                    value: group.allowSmartSplit,
                  ),
                  _SettingRow(
                    icon: Icons.visibility,
                    title: 'Show Amounts',
                    subtitle: 'Display expense amounts to all members',
                    value: group.showAmountsToAll,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddExpense(Group group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExpensePage(
          groupId: group.id,
          currentUserId: 'current_user', // TODO: Get from auth service
          groupMembers: group.members
              .map((member) => {'id': member.userId, 'name': member.name})
              .toList(),
          groupCurrency: group.currency,
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final Group group;

  const _ExpenseCard({
    required this.expense,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Icon(
            Icons.receipt_long, // Default icon since expense doesn't have category
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paid by ${expense.paidBy}'),
            Text(_formatDate(expense.createdAt)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.formatWithSymbol(expense.amount, group.currency),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              '${expense.splitAmong.length} members',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }



  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _MemberCard extends StatelessWidget {
  final GroupMember member;
  final Group group;

  const _MemberCard({
    required this.member,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCreator = member.userId == group.createdBy;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCreator 
              ? theme.colorScheme.primaryContainer 
              : theme.colorScheme.secondaryContainer,
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : 'U',
            style: TextStyle(
              color: isCreator 
                  ? theme.colorScheme.onPrimaryContainer 
                  : theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isCreator) ...[
              Chip(
                label: const Text('Creator'),
                backgroundColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.email),
            Text(
              'Joined ${_formatDate(member.joinedAt)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: member.isActive
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.pause_circle, color: Colors.orange),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: null, // TODO: Implement setting changes
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}