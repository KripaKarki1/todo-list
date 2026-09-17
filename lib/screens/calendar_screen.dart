import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ncmt_kripa/constants/colors.dart';
import 'package:ncmt_kripa/providers/task_provider.dart';
import 'package:provider/provider.dart';

String calendarDateKey(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return normalized.toIso8601String().substring(0, 10);
}

String calendarMonthLabel(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${months[date.month - 1]} ${date.year}';
}

String calendarDayLabel(DateTime date) => date.day.toString();

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> _groupTasksByDate(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> tasks,
  ) {
    final grouped = <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};

    for (final task in tasks) {
      final data = task.data();
      final rawDate = data['date'];
      final taskDate = switch (rawDate) {
        String value => value,
        Timestamp value => DateTime.fromMillisecondsSinceEpoch(
            value.millisecondsSinceEpoch,
          ).toIso8601String().substring(0, 10),
        _ => null,
      };

      if (taskDate == null) {
        continue;
      }

      grouped.putIfAbsent(taskDate, () => []).add(task);
    }

    return grouped;
  }

  Future<void> _openTaskForm({
    String? taskId,
    Map<String, dynamic>? existingTask,
    required DateTime selectedDate,
  }) async {
    final titleController = TextEditingController(
      text: existingTask?['title']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingTask?['description']?.toString() ?? '',
    );
    var dateValue = selectedDate;
    var timeValue = (existingTask?['time'] ?? '').toString();

    final taskKey = taskId ?? 'new-task';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        final provider = context.read<TaskProvider>();

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      taskId == null ? 'Add Task' : 'Edit Task',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: dateValue,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setSheetState(() {
                          dateValue = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Selected date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(calendarDateKey(dateValue)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: timeValue.isNotEmpty
                            ? TimeOfDay(
                                hour: int.parse(timeValue.split(':')[0]),
                                minute: int.parse(timeValue.split(':')[1]),
                              )
                            : TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        final formatted =
                            '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                        setSheetState(() {
                          timeValue = formatted;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time (optional)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(timeValue.isEmpty ? 'Not set' : timeValue),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.loading
                          ? null
                          : () async {
                              final title = titleController.text.trim();
                              final description = descriptionController.text.trim();

                              if (title.isEmpty) {
                                return;
                              }

                              if (taskId == null) {
                                await provider.addTask(
                                  title,
                                  description,
                                  date: dateValue,
                                  time: timeValue,
                                );
                              } else {
                                await provider.updateTask(
                                  taskId,
                                  title: title,
                                  description: description,
                                  date: dateValue,
                                  time: timeValue,
                                );
                              }

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: provider.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(taskId == null ? 'Save Task' : 'Update Task'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: provider.taskStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
          final tasksByDate = _groupTasksByDate(tasks.toList());

          final daysInMonth = DateTime(
            _visibleMonth.year,
            _visibleMonth.month + 1,
            0,
          ).day;
          final firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
          final firstWeekday = firstDayOfMonth.weekday;
          final startOffset = firstWeekday - 1;

          final cells = List.generate(42, (index) {
            final date = DateTime(
              _visibleMonth.year,
              _visibleMonth.month,
              index - startOffset + 1,
            );
            return date;
          });

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _visibleMonth = DateTime(
                                _visibleMonth.year,
                                _visibleMonth.month - 1,
                              );
                            });
                          },
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              calendarMonthLabel(_visibleMonth),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _visibleMonth = DateTime(
                                _visibleMonth.year,
                                _visibleMonth.month + 1,
                              );
                            });
                          },
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.95,
                    physics: const NeverScrollableScrollPhysics(),
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map(
                          (day) => Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.92,
                      children: cells.map((date) {
                        final isCurrentMonth = date.month == _visibleMonth.month;
                        final isSelected = calendarDateKey(date) == calendarDateKey(_selectedDate);
                        final isToday = calendarDateKey(date) == calendarDateKey(DateTime.now());
                        final taskCount = tasksByDate[calendarDateKey(date)]?.length ?? 0;

                        return GestureDetector(
                          onTap: () {
                            if (isCurrentMonth) {
                              setState(() {
                                _selectedDate = date;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withOpacity(0.2)
                                  : isToday
                                      ? Colors.amber.withOpacity(0.18)
                                      : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : isToday
                                        ? Colors.orange
                                        : Colors.transparent,
                                width: isSelected || isToday ? 1.7 : 0,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Text(
                                    calendarDayLabel(date),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isCurrentMonth
                                          ? Theme.of(context).colorScheme.onSurface
                                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                                    ),
                                  ),
                                ),
                                if (taskCount > 0)
                                  Positioned(
                                    bottom: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$taskCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Tasks for ${calendarDateKey(_selectedDate)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () async {
                                await _openTaskForm(
                                  selectedDate: _selectedDate,
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Task'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if ((tasksByDate[calendarDateKey(_selectedDate)] ?? []).isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('No tasks scheduled for this date.'),
                          )
                        else
                          ...((tasksByDate[calendarDateKey(_selectedDate)] ?? []).map((doc) {
                            final data = doc.data();
                            final bool completed = data['completed'] ?? false;
                            final String? taskTime = data['time']?.toString();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Checkbox(
                                    value: completed,
                                    onChanged: (value) async {
                                      await provider.updateTask(
                                        doc.id,
                                        completed: value ?? false,
                                      );
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['title'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            decoration: completed
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        if ((data['description'] ?? '').toString().isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            data['description'] ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        if (taskTime != null && taskTime.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(taskTime),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          await _openTaskForm(
                                            taskId: doc.id,
                                            existingTask: data,
                                            selectedDate: _selectedDate,
                                          );
                                        },
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          await provider.deleteTask(doc.id);
                                        },
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          })),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}