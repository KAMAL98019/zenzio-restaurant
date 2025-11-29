import 'package:flutter/material.dart';
import '../core/constant/appcolors.dart';
import '../core/theme/text_styles.dart';

class CustomDropdownField<T> extends StatefulWidget {
  final String labelText; // Changed to labelText
  final String hint;
  final List<T> items; // Generic type
  final T? value; // Generic type
  final Function(T?)? onChanged; // Generic type
  final String Function(T) itemBuilder; // New: to build display string from T
  final bool isSearchable;
  final bool enabled;

  const CustomDropdownField({
    Key? key,
    required this.labelText, // Changed to labelText
    required this.hint,
    required this.items,
    this.value,
    required this.onChanged,
    required this.itemBuilder, // Required for generic type
    this.isSearchable = true,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => widget.itemBuilder(item).toLowerCase().contains(query.toLowerCase())) // Use itemBuilder for search
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText, // Changed to labelText
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.enabled && widget.onChanged != null
              ? () => _showDropdownDialog(context)
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.enabled
                    ? Colors.grey.shade300
                    : Colors.grey.shade200,
              ),
              borderRadius: BorderRadius.circular(8),
              color: widget.enabled ? Colors.white : Colors.grey.shade50,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.value != null ? widget.itemBuilder(widget.value!) : widget.hint, // Use itemBuilder to display value
                    style: widget.value != null
                        ? AppTextStyles.bodyMedium
                        : AppTextStyles.bodyMedium.copyWith(
                            color: Colors.grey.shade500,
                          ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: widget.enabled
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDropdownDialog(BuildContext context) {
    if (widget.onChanged == null) return;
    
    _searchController.clear();
    _filteredItems = widget.items;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select ${widget.labelText}', // Changed to labelText
                            style: AppTextStyles.h1.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),

                    // Search Field
                    if (widget.isSearchable)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search ${widget.labelText}...', // Changed to labelText
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              _filterItems(value);
                            });
                          },
                        ),
                      ),

                    // Items List
                    Expanded(
                      child: _filteredItems.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'No results found',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                final isSelected = item == widget.value;
                                return ListTile(
                                  title: Text(
                                    widget.itemBuilder(item), // Use itemBuilder to display item
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                        )
                                      : null,
                                  onTap: () {
                                    widget.onChanged!(item);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// import 'package:flutter/material.dart';
// import '../core/constant/appcolors.dart';
// import '../core/theme/text_styles.dart';

// class CustomDropdownField extends StatefulWidget {
//   final String label;
//   final String hint;
//   final List<String> items;
//   final String? value;
//   final Function(String?) onChanged;
//   final bool isSearchable;

//   const CustomDropdownField({
//     Key? key,
//     required this.label,
//     required this.hint,
//     required this.items,
//     this.value,
//     required this.onChanged,
//     this.isSearchable = true,
//   }) : super(key: key);

//   @override
//   State<CustomDropdownField> createState() => _CustomDropdownFieldState();
// }

// class _CustomDropdownFieldState extends State<CustomDropdownField> {
//   final TextEditingController _searchController = TextEditingController();
//   List<String> _filteredItems = [];
//   bool _isSearching = false;

//   @override
//   void initState() {
//     super.initState();
//     _filteredItems = widget.items;
//   }

//   void _filterItems(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredItems = widget.items;
//       } else {
//         _filteredItems = widget.items
//             .where((item) => item.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.label,
//           style: AppTextStyles.bodyMedium.copyWith(
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () => _showDropdownDialog(context),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     widget.value ?? widget.hint,
//                     style: widget.value != null
//                         ? AppTextStyles.bodyMedium
//                         : AppTextStyles.bodyMedium.copyWith(
//                             color: Colors.grey.shade500,
//                           ),
//                   ),
//                 ),
//                 Icon(
//                   Icons.arrow_drop_down,
//                   color: Colors.grey.shade600,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _showDropdownDialog(BuildContext context) {
//     _searchController.clear();
//     _filteredItems = widget.items;

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Container(
//                 constraints: BoxConstraints(
//                   maxHeight: MediaQuery.of(context).size.height * 0.6,
//                   maxWidth: MediaQuery.of(context).size.width * 0.9,
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Header
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary.withOpacity(0.1),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(12),
//                           topRight: Radius.circular(12),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Select ${widget.label}',
//                             style: AppTextStyles.h1.copyWith(
//                               color: AppColors.primary,
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.close),
//                             onPressed: () => Navigator.pop(context),
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // Search Field
//                     if (widget.isSearchable)
//                       Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: TextField(
//                           controller: _searchController,
//                           decoration: InputDecoration(
//                             hintText: 'Search ${widget.label}...',
//                             prefixIcon: const Icon(Icons.search),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           onChanged: (value) {
//                             setDialogState(() {
//                               _filterItems(value);
//                             });
//                           },
//                         ),
//                       ),

//                     // Items List
//                     Expanded(
//                       child: _filteredItems.isEmpty
//                           ? Center(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(20),
//                                 child: Text(
//                                   'No results found',
//                                   style: AppTextStyles.bodyMedium.copyWith(
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : ListView.builder(
//                               shrinkWrap: true,
//                               itemCount: _filteredItems.length,
//                               itemBuilder: (context, index) {
//                                 final item = _filteredItems[index];
//                                 final isSelected = item == widget.value;
//                                 return ListTile(
//                                   title: Text(
//                                     item,
//                                     style: AppTextStyles.bodyMedium.copyWith(
//                                       color: isSelected
//                                           ? AppColors.primary
//                                           : Colors.black87,
//                                       fontWeight: isSelected
//                                           ? FontWeight.w600
//                                           : FontWeight.normal,
//                                     ),
//                                   ),
//                                   trailing: isSelected
//                                       ? const Icon(
//                                           Icons.check_circle,
//                                           color: AppColors.primary,
//                                         )
//                                       : null,
//                                   onTap: () {
//                                     widget.onChanged(item);
//                                     Navigator.pop(context);
//                                   },
//                                 );
//                               },
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }