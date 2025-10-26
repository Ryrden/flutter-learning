import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';


/// Enhanced page for adding a new expense with categories and currency support
/// Follows Single Responsibility Principle - handles expense input UI
class AddExpensePage extends StatefulWidget {
  final String groupId;
  final String currentUserId;
  final List<Map<String, String>> groupMembers; // [{id, name}, ...]
  final String groupCurrency;

  const AddExpensePage({
    super.key,
    required this.groupId,
    required this.currentUserId,
    required this.groupMembers,
    this.groupCurrency = 'USD',
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  String? _selectedPayer;
  SplitType _selectedSplitType = SplitType.equal;
  List<String> _selectedSplitters = [];
  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  bool _isLoading = false;
  
  // Animation for real-time calculations
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _selectedPayer = widget.currentUserId;
    _selectedSplitters = widget.groupMembers.map((member) => member['id']!).toList();
    
    // Initialize animations for real-time calculations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Add Expense'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Enhanced header with category selection
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.surface,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Category Selection
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _selectedCategory.color.withOpacity(0.2),
                          child: Icon(
                            _selectedCategory.icon,
                            color: _selectedCategory.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                _selectedCategory.displayName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _showCategorySelector,
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Main form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDescriptionField(),
                    const SizedBox(height: 20),
                    _buildAmountField(),
                    const SizedBox(height: 20),
                    _buildPayerSelection(),
                    const SizedBox(height: 20),
                    _buildSplitTypeSelection(),
                    const SizedBox(height: 20),
                    _buildSplitAmongSelection(),
                    const SizedBox(height: 32),
                    
                    // Real-time calculation summary
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: _buildEnhancedSummary(),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Bottom action bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'What was this expense for?',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(),
      ),
      maxLength: 200,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Amount',
        hintText: '0.00',
        prefixIcon: Icon(Icons.attach_money),
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount greater than 0';
        }
        
        if (amount > 999999.99) {
          return 'Amount cannot exceed \$999,999.99';
        }
        
        return null;
      },
      onChanged: (value) {
        setState(() {}); // Refresh summary when amount changes
      },
    );
  }

  Widget _buildPayerSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Who paid?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedPayer,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: widget.groupMembers.map((member) {
              return DropdownMenuItem(
                value: member['id'],
                child: Text(member['name']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPayer = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select who paid';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSplitTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How to split?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              RadioListTile<SplitType>(
                title: const Text('Split Equally'),
                subtitle: const Text('Divide the amount equally among selected people'),
                value: SplitType.equal,
                groupValue: _selectedSplitType,
                onChanged: (value) {
                  setState(() {
                    _selectedSplitType = value!;
                  });
                },
              ),
              RadioListTile<SplitType>(
                title: const Text('Custom Amounts'),
                subtitle: const Text('Specify exact amounts for each person'),
                value: SplitType.custom,
                groupValue: _selectedSplitType,
                onChanged: (value) {
                  setState(() {
                    _selectedSplitType = value!;
                  });
                },
              ),
              RadioListTile<SplitType>(
                title: const Text('Smart Split'),
                subtitle: const Text('Split based on financial profiles (coming soon)'),
                value: SplitType.smart,
                groupValue: _selectedSplitType,
                onChanged: null, // Disabled for now
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSplitAmongSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Split among',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: widget.groupMembers.map((member) {
              final isSelected = _selectedSplitters.contains(member['id']);
              return CheckboxListTile(
                title: Text(member['name']!),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedSplitters.add(member['id']!);
                    } else {
                      _selectedSplitters.remove(member['id']!);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        if (_selectedSplitters.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Please select at least one person',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildSummary() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final splitAmount = _selectedSplitters.isNotEmpty ? amount / _selectedSplitters.length : 0.0;
    
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total Amount: ${CurrencyFormatter.format(amount)}'),
            Text('Split Among: ${_selectedSplitters.length} people'),
            if (_selectedSplitType == SplitType.equal && amount > 0)
              Text('Each Person Pays: ${CurrencyFormatter.format(splitAmount)}'),
            const SizedBox(height: 8),
            if (_selectedPayer != null)
              Text(
                'Payer: ${widget.groupMembers.firstWhere((m) => m['id'] == _selectedPayer)['name']}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitExpense,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add Expense'),
          ),
        ),
      ],
    );
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSplitters.isEmpty) return;
    if (_selectedPayer == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Call use case to create expense
      // final amount = double.parse(_amountController.text);
      
      // Simulate API call for now
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense "${_descriptionController.text}" added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to previous screen
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show category selection dialog
  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategorySelectorSheet(
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Show help dialog
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adding Expenses'),
        content: const Text(
          'Fill in the expense details:\n\n'
          '• Choose a category for better organization\n'
          '• Enter description and amount\n'
          '• Select who paid for the expense\n'
          '• Choose how to split the cost\n'
          '• Select which members to include\n\n'
          'The summary will show the calculated amounts for each member.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Build enhanced summary with real-time calculations
  Widget _buildEnhancedSummary() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final currency = widget.groupCurrency;
    
    if (amount <= 0 || _selectedSplitters.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.calculate,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter amount to see split calculation',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final amountPerPerson = amount / _selectedSplitters.length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Split Calculation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedSplitters.length} members',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Total amount
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    CurrencyFormatter.formatWithSymbol(amount, currency),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Per person breakdown
            Text(
              'Amount per person:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            ...widget.groupMembers.where((member) => 
              _selectedSplitters.contains(member['id'])
            ).map((member) {
              final memberName = member['name'] ?? 'Unknown';
              final isPayer = member['id'] == _selectedPayer;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isPayer 
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Text(
                        memberName.isNotEmpty ? memberName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPayer 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        memberName,
                        style: TextStyle(
                          fontWeight: isPayer ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isPayer) ...[
                      Chip(
                        label: const Text('Paid'),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      CurrencyFormatter.formatWithSymbol(amountPerPerson, currency),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPayer 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Category selector bottom sheet
class _CategorySelectorSheet extends StatelessWidget {
  final ExpenseCategory selectedCategory;
  final Function(ExpenseCategory) onCategorySelected;

  const _CategorySelectorSheet({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Category',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Popular categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Popular',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
          
          // Popular category grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategory.getPopularCategories().map((category) {
                final isSelected = category == selectedCategory;
                
                return GestureDetector(
                  onTap: () => onCategorySelected(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? category.color.withOpacity(0.2)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected 
                          ? Border.all(color: category.color, width: 2)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          size: 16,
                          color: isSelected ? category.color : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? category.color : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // All categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'All Categories',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
          
          // All categories list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ExpenseCategory.getAllCategories().length,
              itemBuilder: (context, index) {
                final category = ExpenseCategory.getAllCategories()[index];
                final isSelected = category == selectedCategory;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category.color.withOpacity(0.2),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 20,
                    ),
                  ),
                  title: Text(category.displayName),
                  trailing: isSelected 
                      ? Icon(Icons.check_circle, color: category.color)
                      : null,
                  onTap: () => onCategorySelected(category),
                );
              },
            ),
          ),
          
          // Bottom padding for safe area
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}