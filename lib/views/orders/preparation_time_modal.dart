import 'package:flutter/material.dart';

class PreparationTimeModal extends StatefulWidget {
  final Function(String)? onAccept;

  const PreparationTimeModal({super.key, this.onAccept});

  @override
  State<PreparationTimeModal> createState() => _PreparationTimeModalState();
}

class _PreparationTimeModalState extends State<PreparationTimeModal> {
  String? selectedTime;

  final List<String> times = [
    "10 mins",
    "15 mins",
    "20 mins",
    "25 mins",
    "30 mins",
    "35 mins",
    "40 mins",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select Preparation Time",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: times.map((time) {
              bool isSelected = selectedTime == time;

              return ChoiceChip(
                label: Text(time),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    selectedTime = time;
                  });
                },
                selectedColor: Colors.red,
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              if (selectedTime != null) {
                Navigator.pop(context, selectedTime);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              "Confirm Time",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
