import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenzio_restaurant/core/constant/appcolors.dart';
import 'package:zenzio_restaurant/core/theme/text_styles.dart';
import 'package:zenzio_restaurant/models/event.dart';
import 'package:zenzio_restaurant/viewmodels/event_viewmodel.dart';
import 'package:zenzio_restaurant/widgets/custom_appbar.dart';
import 'package:zenzio_restaurant/services/auth_service.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event; // For editing an existing event

  const EventFormScreen({Key? key, this.event}) : super(key: key);

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController;
  late TextEditingController _eventDescriptionController;
  String? _selectedEventType; // Added for event type
  String? _selectedFrequency;
  String? _selectedEventDay;
  DateTime? _selectedEventDate;
  List<TimeOfDay> _selectedEventTimes = [];
  String? _selectedDiningArea;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(text: widget.event?.eventName ?? '');
    _eventDescriptionController = TextEditingController(text: widget.event?.eventDescription ?? '');
    _selectedEventType = widget.event?.eventType ?? 'EVENT'; // Initialize with 'EVENT'
    _selectedFrequency = widget.event?.frequency;
    _selectedEventDay = widget.event?.eventDay;
    _selectedEventDate = widget.event?.eventDate != null
        ? DateTime.parse(widget.event!.eventDate!)
        : null;
    
    // Fixed: Parse event times correctly
    _selectedEventTimes = widget.event?.eventTimes
            ?.map((time) {
              try {
                final parts = time.split(':');
                if (parts.length >= 2) {
                  return TimeOfDay(
                    hour: int.parse(parts[0]),
                    minute: int.parse(parts[1]),
                  );
                }
              } catch (e) {
                print('Error parsing time: $time');
              }
              return null;
            })
            .whereType<TimeOfDay>() // Filter out null values
            .toList() ??
        [];
    
    _selectedDiningArea = widget.event?.associatedDiningArea;
    _isActive = widget.event?.isActive ?? true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final eventViewModel = Provider.of<EventViewModel>(context, listen: false);
    AuthService().getRestaurantId().then((restaurantId) async {
      if (restaurantId != null) {
        await eventViewModel.fetchDiningAreas(restaurantId);
        // After fetching dining areas, ensure _selectedDiningArea is valid
        if (widget.event != null &&
            !eventViewModel.diningAreas.any((area) => area.id == widget.event!.associatedDiningArea)) {
          setState(() {
            _selectedDiningArea = null; // Reset if the associated dining area is no longer available
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEventDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedEventDate) {
      setState(() {
        _selectedEventDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, {int? index}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: index != null && index < _selectedEventTimes.length
          ? _selectedEventTimes[index]
          : TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (index != null && index < _selectedEventTimes.length) {
          _selectedEventTimes[index] = picked;
        } else {
          _selectedEventTimes.add(picked);
        }
      });
    }
  }

  void _removeTime(int index) {
    setState(() {
      _selectedEventTimes.removeAt(index);
    });
  }

  void _submitForm() async {
    // Validate all fields
    if (_formKey.currentState!.validate()) {
      // Additional validation
      if (_selectedEventTimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one event time')),
        );
        return;
      }

      if (_selectedFrequency == 'ONCE' && _selectedEventDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an event date')),
        );
        return;
      }

      if (_selectedDiningArea == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an associated dining area')),
        );
        return;
      }

      _formKey.currentState!.save();

      final eventViewModel = Provider.of<EventViewModel>(context, listen: false);

      // Get restaurant ID from AuthService
      final restaurantId = await AuthService().getRestaurantId();
      if (restaurantId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant ID not found')),
        );
        return;
      }

      final newEvent = Event(
        id: widget.event?.id ?? '', // Will be ignored for create, used for update
        restaurantId: restaurantId,
        eventName: _eventNameController.text.trim(),
        eventDescription: _eventDescriptionController.text.trim(),
        eventType: _selectedEventType!, // Added eventType
        frequency: _selectedFrequency!,
        eventDay: _selectedFrequency == 'WEEKLY' ? _selectedEventDay : null,
        eventDate: _selectedFrequency == 'ONCE'
            ? _selectedEventDate?.toIso8601String().split('T').first
            : null,
        eventTimes: _selectedEventTimes
            .map((e) => '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}')
            .toList(),
        associatedDiningArea: _selectedDiningArea!,
        isActive: _isActive,
      );

      bool success;
      if (widget.event == null) {
        success = await eventViewModel.createEvent(newEvent);
      } else {
        success = await eventViewModel.updateEvent(widget.event!.id, newEvent);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(eventViewModel.errorMessage ?? 'Failed to save event')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: CustomAppBar(
        title: widget.event == null ? 'Create Event' : 'Edit Event',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Fixed: Added missing padding value
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Event Name
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  labelText: 'Event Name',
                  hintText: 'e.g., Live Music Night',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Event Description
              TextFormField(
                controller: _eventDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Event Description',
                  hintText: 'Describe your event',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Event Type
              DropdownButtonFormField<String>(
                value: _selectedEventType,
                decoration: InputDecoration(
                  labelText: 'Event Type',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['EVENT', 'CLOSURE']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEventType = value;
                    // Potentially adjust other fields based on event type
                    if (_selectedEventType == 'CLOSURE') {
                      _eventNameController.text = 'Restaurant Closure';
                      _eventDescriptionController.text = 'Restaurant is closed for this period.';
                      _selectedFrequency = 'ONCE'; // Closures are typically once-off
                      _selectedEventDay = null;
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an event type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Frequency
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['ONCE', 'DAILY', 'WEEKLY', 'MONTHLY']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value;
                    if (value != 'WEEKLY') {
                      _selectedEventDay = null;
                    }
                    if (value != 'ONCE') {
                      _selectedEventDate = null;
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a frequency';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Event Day (for WEEKLY)
              if (_selectedFrequency == 'WEEKLY')
                DropdownButtonFormField<String>(
                  value: _selectedEventDay,
                  decoration: InputDecoration(
                    labelText: 'Event Day',
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    'MONDAY',
                    'TUESDAY',
                    'WEDNESDAY',
                    'THURSDAY',
                    'FRIDAY',
                    'SATURDAY',
                    'SUNDAY'
                  ]
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEventDay = value;
                    });
                  },
                  validator: (value) {
                    if (_selectedFrequency == 'WEEKLY' && (value == null || value.isEmpty)) {
                      return 'Please select an event day';
                    }
                    return null;
                  },
                ),
              
              if (_selectedFrequency == 'WEEKLY')
                const SizedBox(height: 16),

              // Event Date (for ONCE)
              if (_selectedFrequency == 'ONCE')
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    title: Text(
                      _selectedEventDate == null
                          ? 'Select Event Date'
                          : 'Event Date: ${_selectedEventDate!.toLocal().toString().split(' ')[0]}', // Fixed: Show only date
                      style: AppTextStyles.bodyMedium,
                    ),
                    trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
                    onTap: () => _selectDate(context),
                  ),
                ),
              
              if (_selectedFrequency == 'ONCE' && _selectedEventDate == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                  child: Text(
                    'Please select an event date',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              
              if (_selectedFrequency == 'ONCE')
                const SizedBox(height: 16),

              // Event Times Section
              Text('Event Times', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              
              // Display selected times
              if (_selectedEventTimes.isNotEmpty)
                ..._selectedEventTimes.asMap().entries.map((entry) {
                  int index = entry.key;
                  TimeOfDay time = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListTile(
                      title: Text(
                        time.format(context),
                        style: AppTextStyles.bodyMedium,
                      ),
                      leading: const Icon(Icons.access_time, color: AppColors.primary),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _removeTime(index),
                      ),
                      onTap: () => _selectTime(context, index: index),
                    ),
                  );
                }).toList(),
              
              const SizedBox(height: 8),

              // Add Event Time Button
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Event Time'),
                onPressed: () => _selectTime(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              
              if (_selectedEventTimes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                  child: Text(
                    'Please add at least one event time',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              
              const SizedBox(height: 16),

              // Associated Dining Area
              Consumer<EventViewModel>(
                builder: (context, viewModel, _) {
                  // If you have dining areas loaded in the viewmodel
                  if (viewModel.diningAreas.isNotEmpty) {
                    return DropdownButtonFormField<String>(
                      value: _selectedDiningArea,
                      decoration: InputDecoration(
                        labelText: 'Associated Dining Area',
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: viewModel.diningAreas
                          .map((area) => DropdownMenuItem(
                                value: area.id,
                                child: Text(area.areaName),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDiningArea = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a dining area';
                        }
                        return null;
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No dining areas available. Please add some in the Booking section.'),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // Is Active Switch
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: SwitchListTile(
                  title: const Text('Is Active'),
                  subtitle: Text(
                    _isActive ? 'Event is currently active' : 'Event is inactive',
                    style: TextStyle(
                      color: _isActive ? AppColors.success : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  value: _isActive,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              Consumer<EventViewModel>(
                builder: (context, viewModel, _) {
                  return ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            widget.event == null ? 'Create Event' : 'Update Event',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
