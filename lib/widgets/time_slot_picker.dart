// lib/widgets/time_slot_picker.dart
import 'package:flutter/material.dart';

class TimeSlotPicker extends StatelessWidget {
  final List<String> selectedSlots;
  final ValueChanged<List<String>> onSelectionChanged;

  const TimeSlotPicker({
    Key? key,
    required this.selectedSlots,
    required this.onSelectionChanged,
  }) : super(key: key);

  List<String> _generateTimeSlots() {
    List<String> slots = [];
    TimeOfDay current = const TimeOfDay(hour: 8, minute: 0);
    while (true) {
      final next = TimeOfDay(
        hour: (current.hour + (current.minute + 100) ~/ 60),
        minute: (current.minute + 100) % 60,
      );
      if (current.hour >= 22) break;
      final start = _format(current);
      final end = _format(next);
      slots.add('$start WIB - $end WIB');
      current = next;
    }
    return slots;
  }

  String _format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final slots = _generateTimeSlots();
    return SizedBox(
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: slots.length,
        itemBuilder: (context, i) {
          final slot = slots[i];
          final selected = selectedSlots.contains(slot);
          return FilterChip(
            label: Text(slot),
            selected: selected,
            onSelected: (sel) {
              final updated = List<String>.from(selectedSlots);
              if (sel) {
                updated.add(slot);
              } else {
                updated.remove(slot);
              }
              onSelectionChanged(updated);
            },
          );
        },
      ),
    );
  }
}
