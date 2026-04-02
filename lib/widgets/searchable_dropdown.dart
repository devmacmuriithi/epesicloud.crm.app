import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_colors.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<dynamic> items;
  final Function(T?) onChanged;
  final String displayKey;
  final String valueKey;
  final bool disabled;
  final String? hintText;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.displayKey = 'title',
    this.valueKey = 'id',
    this.disabled = false,
    this.hintText,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  String _getDisplayValue(dynamic item) {
    if (item is String) return item;
    
    // Dynamic access for different models
    try {
      if (widget.displayKey == 'fullName') return item.fullName;
      if (widget.displayKey == 'productName') return item.productName;
      if (widget.displayKey == 'accountName') return item.accountName;
      if (widget.displayKey == 'dealName') return item.dealName;
      if (widget.displayKey == 'name') return item.name;
      return item.title ?? item.name ?? 'Unknown';
    } catch (e) {
      return item.toString();
    }
  }

  T _getItemValue(dynamic item) {
    if (item is String) return item as T;
    if (widget.valueKey == 'title') return _getDisplayValue(item) as T;
    return item.id as T;
  }

  String _getCurrentValueLabel() {
    if (widget.value == null) return '';
    final selectedItem = widget.items.firstWhereOrNull((item) => _getItemValue(item) == widget.value);
    return selectedItem != null ? _getDisplayValue(selectedItem) : '';
  }

  void _showSearchModal() {
    if (widget.disabled) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SearchModal<T>(
        title: widget.label,
        items: widget.items,
        initialValue: widget.value,
        getDisplayValue: _getDisplayValue,
        getItemValue: _getItemValue,
        onSelected: (val) {
          widget.onChanged(val);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final valueLabel = _getCurrentValueLabel();

    return GestureDetector(
      onTap: _showSearchModal,
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText ?? 'Select ${widget.label}',
            filled: true,
            fillColor: widget.disabled ? AppColors.divider.withOpacity(0.5) : AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          controller: TextEditingController(text: valueLabel),
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _SearchModal<T> extends StatefulWidget {
  final String title;
  final List<dynamic> items;
  final T? initialValue;
  final String Function(dynamic) getDisplayValue;
  final T Function(dynamic) getItemValue;
  final Function(T?) onSelected;

  const _SearchModal({
    required this.title,
    required this.items,
    required this.initialValue,
    required this.getDisplayValue,
    required this.getItemValue,
    required this.onSelected,
  });

  @override
  State<_SearchModal<T>> createState() => _SearchModalState<T>();
}

class _SearchModalState<T> extends State<_SearchModal<T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterResults(String query) {
    setState(() {
      _filteredItems = widget.items.where((item) {
        final display = widget.getDisplayValue(item).toLowerCase();
        return display.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Select ${widget.title}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: _filterResults,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // List
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(child: Text('No matching items found', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final displayValue = widget.getDisplayValue(item);
                      final itemValue = widget.getItemValue(item);
                      final isSelected = itemValue == widget.initialValue;

                      return ListTile(
                        onTap: () => widget.onSelected(itemValue),
                        title: Text(
                          displayValue,
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary, size: 20) : null,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
