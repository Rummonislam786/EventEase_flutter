import 'package:calendar_app/database/database_helper.dart';
import 'package:calendar_app/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import 'package:flutter/foundation.dart';

class AddEditEventScreen extends StatefulWidget {
  final Event? event;

  const AddEditEventScreen({super.key, this.event});

  @override
  // ignore: library_private_types_in_public_api
  _AddEditEventScreenState createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _todoController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      // Edit mode - populate fields
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description ?? '';
      _locationController.text = widget.event!.location ?? '';
      _selectedDate = widget.event!.date;
      _startTime = TimeOfDay.fromDateTime(widget.event!.startTime);
      _endTime = TimeOfDay.fromDateTime(widget.event!.endTime);
      _loadTodos();
    } else {
      // Add mode - set default values
      _selectedDate = DateTime.now();
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(hours: 1)),
      );
    }
  }

  Future<void> _loadTodos() async {
    if (widget.event?.id != null) {
      final todos =
          await DatabaseHelper.instance.getTodosForEvent(widget.event!.id!);
      setState(() {
        _todos = todos;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _todoController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  bool _validateDateTime() {
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    // Check if selected time is at least 1 hour after current time
    // final minimumDateTime = now.add(const Duration(hours: 1));

    // if (selectedDateTime.isBefore(minimumDateTime)) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Event must be scheduled at least 1 hour in advance'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return false;
    // }

    // Validate end time is after start time
    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(selectedDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }
  // void _submitForm() {
  //   if (_formKey.currentState!.validate()) {
  //     _formKey.currentState!.save();

  //     // Create or update event
  //     final eventProvider = Provider.of<EventProvider>(context, listen: false);

  //     final newEvent = Event(
  //       id: widget.event?.id,
  //       title: _title,
  //       description: _description,
  //       date: _date,
  //       startTime: _startTime,
  //       endTime: _endTime,
  //       location: _location,
  //       completed: widget.event?.completed ?? false,
  //     );

  //     if (widget.event == null) {
  //       // Adding new event
  //       eventProvider.addEvent(newEvent);
  //     } else {
  //       // Updating existing event
  //       eventProvider.updateEvent(newEvent);
  //     }

  //     // Navigate back
  //     Navigator.of(context).pop();
  //   }
  // }

  void _addTodo() {
    if (_todoController.text.isEmpty) return;

    setState(() {
      _todos.add(
        Todo(
          eventId: widget.event?.id ?? 0, // Will be updated when event is saved
          task: _todoController.text,
        ),
      );
      _todoController.clear();
    });
  }

  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index] = _todos[index].copyWith(
        completed: !_todos[index].completed,
      );
    });
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateDateTime()) return;

    // Create DateTime objects for start and end times
    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final event = Event(
      id: widget.event?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      date: _selectedDate,
      startTime: startDateTime,
      endTime: endDateTime,
      location: _locationController.text,
      todos: _todos,
      completed: widget.event?.completed ?? false,
    );

    try {
      final Event savedEvent = widget.event == null
          ? await DatabaseHelper.instance.create(event)
          : await DatabaseHelper.instance.update(event) as Event;

      await NotificationService().scheduleEventNotification(
        id: savedEvent.id!,
        title: 'Upcoming Event: ${savedEvent.title}',
        body: savedEvent.location != null
            ? 'at ${savedEvent.location}'
            : 'Starting soon',
        eventTime: savedEvent.startTime,
        reminderBefore: const Duration(minutes: 15),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Future<void> _selectTime(BuildContext context, bool isStartTime) async {
  //   final TimeOfDay? picked = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.fromDateTime(isStartTime ? _startTime : _endTime),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       if (isStartTime) {
  //         _startTime = DateTime(
  //             _date.year, _date.month, _date.day, picked.hour, picked.minute);
  //         // Ensure end time is after start time
  //         if (_endTime.isBefore(_startTime)) {
  //           _endTime = _startTime.add(const Duration(hours: 1));
  //         }
  //       } else {
  //         _endTime = DateTime(
  //             _date.year, _date.month, _date.day, picked.hour, picked.minute);
  //       }
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title Input
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an event title';
                }
                return null;
              },
              // onSaved: (value) => _titleController.text = value!,
            ),
            const SizedBox(height: 16),

            // Date Selection
            // Row(
            //   children: [
            //     Expanded(
            //       child: Text(
            //         'Date: ${DateFormat('EEEE, MMMM d, yyyy').format(_date)}',
            //         style: Theme.of(context).textTheme.labelSmall,
            //       ),
            //     ),
            //     ElevatedButton(
            //       onPressed: () => _selectDate(context),
            //       child: const Text('Change Date'),
            //     ),
            //   ],
            // ),
            ListTile(
              title: Text(
                  'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),

            // Time Selection
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('Start: ${_startTime.format(context)}'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _selectTime(context, true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('End: ${_endTime.format(context)}'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _selectTime(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            // Location Input (Optional)
            const Text(
              'Todo List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: const InputDecoration(
                      hintText: 'Add a todo item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text('Add'),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return CheckboxListTile(
                  title: Text(todo.task),
                  value: todo.completed,
                  onChanged: (_) => _toggleTodo(index),
                  secondary: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeTodo(index),
                  ),
                );
              },
            ),
            // Submit Button
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveEvent,
                child:
                    Text(widget.event == null ? 'Add Event' : 'Update Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
