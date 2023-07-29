import 'package:flutter/material.dart';

import '../service/set_time_schedule_service.dart';
// import 'AvailableScheduleService.dart';

class SetTimeScheduleScreen extends StatefulWidget {
  @override
  _SetTimeScheduleScreenState createState() => _SetTimeScheduleScreenState();
}

class _SetTimeScheduleScreenState extends State<SetTimeScheduleScreen> {
  List<String> weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  Map<String, List<TimeRange>> selectedTimePeriods = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Schedule'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _editSchedule();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select weekdays:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: weekdays.map((weekday) {
                final isSelected = selectedTimePeriods.containsKey(weekday);
                return FilterChip(
                  label: Text(weekday),
                  selected: isSelected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        selectedTimePeriods[weekday] = [];
                      } else {
                        selectedTimePeriods.remove(weekday);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Select time periods:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: selectedTimePeriods.length,
                itemBuilder: (context, index) {
                  final entry = selectedTimePeriods.entries.toList()[index];
                  final weekday = entry.key;
                  final timePeriods = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: timePeriods.map((timeRange) {
                          return Chip(
                            label: Text(
                              timeRange.formatTimeRange(),
                            ),
                            onDeleted: () {
                              setState(() {
                                timePeriods.remove(timeRange);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showDateTimePicker(context, weekday);
                        },
                        child: Text('Add Time Period'),
                      ),
                      SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editSchedule() {
    // Implement the edit schedule logic
  }

  Future<void> _showDateTimePicker(BuildContext context, String weekday) async {
  final initialTime = TimeOfDay.now();
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(Duration(days: 7)), // Adjust as needed
  );

  if (pickedDate != null) {
    final pickedStartTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedStartTime != null) {
      final pickedEndTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedEndTime != null) {
        final startDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedStartTime.hour,
          pickedStartTime.minute,
        );
        final endDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedEndTime.hour,
          pickedEndTime.minute,
        );
        final timeRange = TimeRange(context: context, start: startDateTime, end: endDateTime);
        setState(() {
          selectedTimePeriods[weekday]?.add(timeRange);
        });

        // Call the service method to create the schedule
        SetTimeScheduleService.createSchedule(timeRange.toSchedule(), context);
      }
    }
  }
}

}
