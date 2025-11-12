import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _eventDateController = TextEditingController();

  String _selectedFrequency = 'Monthly';
  List<String> _eventTimes = ['--:--'];
  String? _selectedDiningHall;

  final List<String> _frequencies = ['Weekly', 'Monthly', 'Specific Dates'];
  final List<String> _diningHalls = ['Main Dining Hall', 'Patio', 'Private Room'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const CustomAppBar(title: 'Edit Event: Trivia Night'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Name
              CustomTextField(
                controller: _eventNameController,
                label: 'Event Name',
                hint: 'Trivia Night',
              ),
              const SizedBox(height: 16),

              // Event Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Event Description',
                hint: '',
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Event Frequency
              Text(
                'Event Frequency',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: _frequencies.map((frequency) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(frequency),
                      selected: _selectedFrequency == frequency,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFrequency = frequency);
                        }
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _selectedFrequency == frequency
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Event Day
              CustomTextField(
                controller: _eventDateController,
                label: 'Event Day',
                hint: 'mm/dd/yyyy',
                readOnly: true,
                onTap: () => _selectDate(),
              ),
              const SizedBox(height: 16),

              // Event Times
              Text(
                'Event Time',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              ..._eventTimes.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '--:--',
                            suffixIcon: const Icon(Icons.access_time),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          readOnly: true,
                          onTap: () => _selectTime(entry.key),
                        ),
                      ),
                      if (_eventTimes.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () {
                            setState(() {
                              _eventTimes.removeAt(entry.key);
                            });
                          },
                        ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 8),

              // Add New Event Time Button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _eventTimes.add('--:--');
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Event Time'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),

              const SizedBox(height: 24),

              // Associated Dining Hall
              Text(
                'Associated Dining Hall',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedDiningHall,
                decoration: InputDecoration(
                  hintText: 'Main Dining Hall',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _diningHalls
                    .map((hall) => DropdownMenuItem(
                          value: hall,
                          child: Text(hall),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedDiningHall = value);
                },
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Save Event Changes',
                      onPressed: () {
                        // Save event logic
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      _eventDateController.text = DateFormat('MM/dd/yyyy').format(picked);
    }
  }

  Future<void> _selectTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _eventTimes[index] = picked.format(context);
      });
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _eventDateController.dispose();
    super.dispose();
  }
}
