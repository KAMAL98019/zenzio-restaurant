import 'package:flutter/material.dart';
import 'package:zenzio_restaurant/widgets/custom_appbar.dart';
import 'package:zenzio_restaurant/widgets/custom_button.dart';
import 'package:zenzio_restaurant/core/theme/app_theme.dart';

class ManageOperationalHoursScreen extends StatefulWidget {
  const ManageOperationalHoursScreen({super.key});

  @override
  State<ManageOperationalHoursScreen> createState() => _ManageOperationalHoursScreenState();
}

class _ManageOperationalHoursScreenState extends State<ManageOperationalHoursScreen> {
  Map<String, Map<String, dynamic>> operationalHours = {
    'Monday': {'open': true, 'slots': [{'opening': '09:00 AM', 'closing': '10:00 PM'}]},
    'Tuesday': {'open': true, 'slots': [{'opening': '09:00 AM', 'closing': '10:00 PM'}]},
    'Wednesday': {'open': true, 'slots': [{'opening': '09:00 AM', 'closing': '03:00 PM'}, {'opening': '05:00 PM', 'closing': '10:00 PM'}]},
    'Thursday': {'open': true, 'slots': [{'opening': '09:00 AM', 'closing': '10:00 PM'}]},
    'Friday': {'open': true, 'slots': [{'opening': '09:00 AM', 'closing': '10:00 PM'}]},
    'Saturday': {'open': true, 'slots': [{'opening': '10:00 AM', 'closing': '11:00 PM'}]},
    'Sunday': {'open': false, 'slots': []},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Operational Hours',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: operationalHours.keys.length,
                itemBuilder: (context, index) {
                  String day = operationalHours.keys.elementAt(index);
                  Map<String, dynamic> dayHours = operationalHours[day]!;
                  bool isOpen = dayHours['open'];
                  List<Map<String, String>> slots = List<Map<String, String>>.from(dayHours['slots']);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                day,
                                style: AppTheme.lightTheme.textTheme.titleLarge,
                              ),
                              Row(
                                children: [
                                  Text(isOpen ? 'Open' : 'Closed'),
                                  Switch(
                                    value: isOpen,
                                    onChanged: (value) {
                                      setState(() {
                                        operationalHours[day]!['open'] = value;
                                      });
                                    },
                                    activeColor: AppTheme.lightTheme.primaryColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (isOpen) ...[
                            const SizedBox(height: 16.0),
                            ...slots.map((slot) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    if (slots.length > 1)
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            slots.remove(slot);
                                          });
                                        },
                                      ),
                                    Expanded(
                                      child: _buildTimePickerField(
                                        context,
                                        'Opening Time',
                                        slot['opening']!,
                                            (time) {
                                          setState(() {
                                            slot['opening'] = time;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Expanded(
                                      child: _buildTimePickerField(
                                        context,
                                        'Closing Time',
                                        slot['closing']!,
                                            (time) {
                                          setState(() {
                                            slot['closing'] = time;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  slots.add({'opening': '09:00 AM', 'closing': '10:00 PM'});
                                });
                              },
                              icon: Icon(Icons.add, color: AppTheme.lightTheme.primaryColor),
                              label: Text(
                                'Add Break/Multiple Slots',
                                style: TextStyle(color: AppTheme.lightTheme.primaryColor),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            CustomButton(
              text: 'Submit',
              onPressed: () {
                // Handle submit logic here
                print('Operational Hours: $operationalHours');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerField(
      BuildContext context, String label, String initialTime, Function(String) onTimeSelected) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          onTimeSelected(pickedTime.format(context));
        }
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.access_time),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          controller: TextEditingController(text: initialTime),
        ),
      ),
    );
  }
}