// lib/widgets/calendar_widget.dart
import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      1,
    );
    _selectedDate = widget.selectedDate;
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _currentMonth = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        1,
      );
      _selectedDate = widget.selectedDate;
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected(date);
  }

  List<TableRow> _buildCalendarRows() {
    final firstDayOfMonth = _currentMonth;
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    // Get days from previous month
    final previousMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month - 1,
      1,
    );
    final daysInPreviousMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      0,
    ).day;
    final previousMonthDays = List.generate(
      firstWeekday - 1,
      (index) => daysInPreviousMonth - (firstWeekday - 2 - index),
    );

    // Current month days
    final currentMonthDays = List.generate(daysInMonth, (index) => index + 1);

    // Next month days to fill the grid
    final totalCells = previousMonthDays.length + daysInMonth;
    final nextMonthDays = totalCells <= 35
        ? List.generate(35 - totalCells, (index) => index + 1)
        : List.generate(42 - totalCells, (index) => index + 1);

    List<DateTime> allDays = [
      ...previousMonthDays.map(
        (day) => DateTime(previousMonth.year, previousMonth.month, day),
      ),
      ...currentMonthDays.map(
        (day) => DateTime(_currentMonth.year, _currentMonth.month, day),
      ),
      ...nextMonthDays.map(
        (day) => DateTime(_currentMonth.year, _currentMonth.month + 1, day),
      ),
    ];

    List<TableRow> rows = [];
    for (int i = 0; i < allDays.length; i += 7) {
      final weekDays = allDays.sublist(i, i + 7);
      rows.add(
        TableRow(
          children: weekDays.map((date) {
            final isCurrentMonth = date.month == _currentMonth.month;
            final isSelected =
                _selectedDate.year == date.year &&
                _selectedDate.month == date.month &&
                _selectedDate.day == date.day;

            return GestureDetector(
              onTap: () => _onDateSelected(date),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.blue : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isCurrentMonth ? Colors.black : Colors.grey,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousMonth,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              children: [
                TableRow(
                  children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                      .map(
                        (day) => Center(
                          child: Text(
                            day,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                ),
                ..._buildCalendarRows(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }
}
