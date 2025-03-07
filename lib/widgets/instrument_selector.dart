import 'package:flutter/material.dart';

class InstrumentSelector extends StatelessWidget {
  final String selectedInstrument;
  final ValueChanged<String> onInstrumentChanged;

  const InstrumentSelector({
    Key? key,
    required this.selectedInstrument,
    required this.onInstrumentChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // Reduced fixed width
      margin: const EdgeInsets.only(top: 16), // Added top margin to move down
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: selectedInstrument,
        isExpanded: true,
        dropdownColor: Colors.black87,
        focusColor: Colors.transparent, // Remove hover effect
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.white70,
        ),
        underline: Container(),
        items: ['Piano', 'Guitar', 'Drums', 'Violin'].map((String value) {
          return DropdownMenuItem(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onInstrumentChanged(newValue);
          }
        },
      ),
    );
  }
}