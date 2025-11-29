import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/cuisine.dart';
import 'custom_dropdown_field.dart';

class CategoryCuisineSelector extends StatefulWidget {
  final List<Category> categories;
  final List<Cuisine> cuisines;
  final ValueChanged<Category?> onCategorySelected;
  final ValueChanged<Cuisine?> onCuisineSelected;
  final Category? selectedCategory;
  final Cuisine? selectedCuisine;

  const CategoryCuisineSelector({
    Key? key,
    required this.categories,
    required this.cuisines,
    required this.onCategorySelected,
    required this.onCuisineSelected,
    this.selectedCategory,
    this.selectedCuisine,
  }) : super(key: key);

  @override
  _CategoryCuisineSelectorState createState() => _CategoryCuisineSelectorState();
}

class _CategoryCuisineSelectorState extends State<CategoryCuisineSelector> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CategoryCuisineSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  List<Category> _getDisplayCategories() {
    return widget.categories;
  }

  List<Cuisine> _getDisplayCuisines(int categoryId) {
    return widget.cuisines.where((cuisine) => cuisine.fatherId == categoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDropdownField<Category>(
          labelText: 'Category',
          hint: 'Select a category',
          items: _getDisplayCategories(),
          value: widget.selectedCategory,
          itemBuilder: (category) => category.name,
          onChanged: (category) {
            widget.onCategorySelected(category);
            widget.onCuisineSelected(null); // Reset cuisine when category changes
          },
        ),
        if (widget.selectedCategory != null)
          CustomDropdownField<Cuisine>(
            labelText: 'Cuisine',
            hint: 'Select a cuisine',
            items: _getDisplayCuisines(widget.selectedCategory!.id),
            value: widget.selectedCuisine,
            itemBuilder: (cuisine) => cuisine.name,
            onChanged: (cuisine) {
              widget.onCuisineSelected(cuisine);
            },
          ),
      ],
    );
  }
}