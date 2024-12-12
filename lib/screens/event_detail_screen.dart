import 'package:calendar_app/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import 'add_edit_event_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddEditEventScreen(event: widget.event)));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.event.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Date and Time
            _buildDetailRow(
              context,
              icon: Icons.calendar_today,
              label: 'Date',
              value: DateFormat('EEEE, MMMM d, yyyy').format(widget.event.date),
            ),
            _buildDetailRow(
              context,
              icon: Icons.access_time,
              label: 'Time',
              value: '${DateFormat('h:mm a').format(widget.event.startTime)} - '
                  '${DateFormat('h:mm a').format(widget.event.endTime)}',
            ),

            // Location (if available)
            if (widget.event.location != null &&
                widget.event.location!.isNotEmpty)
              _buildDetailRow(
                context,
                icon: Icons.location_on,
                label: 'Location',
                value: widget.event.location!,
              ),

            // Description (if available)
            if (widget.event.description != null &&
                widget.event.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.event.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

            // Completion Status
            Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                // Find the specific event by its ID
                final updatedEvent = eventProvider.events.firstWhere(
                  (e) => e.id == widget.event.id,
                  // Use the original event if not found (fallback)
                  orElse: () => widget.event,
                );
                return SwitchListTile(
                  title: const Text('Mark as Completed'),
                  value: updatedEvent.completed,
                  onChanged: (bool value) {
                    // Update event completion status
                    Provider.of<EventProvider>(context, listen: false)
                        .updateEvent(updatedEvent.copyWith(completed: value));
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build consistent detail rows
  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Delete'),
              // style: ElevatedButton.styleFrom(primary: Colors.red),
              onPressed: () {
                // Delete the event
                if (widget.event.id != null) {
                  Provider.of<EventProvider>(context, listen: false)
                      .deleteEvent(widget.event.id!);
                }
                // Close the dialog and go back to previous screen
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
