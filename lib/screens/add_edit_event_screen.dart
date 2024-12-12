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

  late String _title;
  String? _description;
  late DateTime _date;
  late DateTime _startTime;
  late DateTime _endTime;
  String? _location;

  @override
  void initState() {
    super.initState();
    // Initialize with existing event data or current date/time
    if (widget.event != null) {
      _title = widget.event!.title;
      _description = widget.event!.description;
      _date = widget.event!.date;
      _startTime = widget.event!.startTime;
      _endTime = widget.event!.endTime;
      _location = widget.event!.location;
    } else {
      _date = DateTime.now();
      _startTime = DateTime.now();
      _endTime = DateTime.now().add(const Duration(hours: 1));
      _title = '';
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create or update event
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      final newEvent = Event(
        id: widget.event?.id,
        title: _title,
        description: _description,
        date: _date,
        startTime: _startTime,
        endTime: _endTime,
        location: _location,
        completed: widget.event?.completed ?? false,
      );

      if (widget.event == null) {
        // Adding new event
        eventProvider.addEvent(newEvent);
      } else {
        // Updating existing event
        eventProvider.updateEvent(newEvent);
      }

      // Navigate back
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartTime ? _startTime : _endTime),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = DateTime(
              _date.year, _date.month, _date.day, picked.hour, picked.minute);
          // Ensure end time is after start time
          if (_endTime.isBefore(_startTime)) {
            _endTime = _startTime.add(const Duration(hours: 1));
          }
        } else {
          _endTime = DateTime(
              _date.year, _date.month, _date.day, picked.hour, picked.minute);
        }
      });
    }
  }

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
              initialValue: _title,
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
              onSaved: (value) => _title = value!,
            ),
            const SizedBox(height: 16),

            // Date Selection
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${DateFormat('EEEE, MMMM d, yyyy').format(_date)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Change Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time Selection
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Start Time: ${DateFormat('h:mm a').format(_startTime)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context, true),
                  child: const Text('Change Start'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'End Time: ${DateFormat('h:mm a').format(_endTime)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectTime(context, false),
                  child: const Text('Change End'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description Input (Optional)
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              onSaved: (value) => _description = value,
            ),
            const SizedBox(height: 16),

            // Location Input (Optional)
            TextFormField(
              initialValue: _location,
              decoration: const InputDecoration(
                labelText: 'Location (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              onSaved: (value) => _location = value,
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                widget.event == null ? 'Create Event' : 'Update Event',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
