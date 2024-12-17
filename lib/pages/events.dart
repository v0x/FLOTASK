import 'package:calendar_view/calendar_view.dart';
import 'package:flotask/components/event_note_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:flotask/models/event_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flotask/components/events_dialog.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _eventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    _resetRecurringTasksForNewDay(eventProvider);
  }

  Future<void> _loadEvents() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    await eventProvider.loadEventsFromFirebase();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // logic to reset recurring tasks for new day
  Future<void> _resetRecurringTasksForNewDay(
      EventProvider eventProvider) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var event in eventProvider.events) {
      if (event.isRecurring) {
        final eventDate = DateTime(
          event.event.date.year,
          event.event.date.month,
          event.event.date.day,
        );

        if (event.lastCompletedDate!.isBefore(today)) {
          event.isCompleted = false;
          eventProvider.notifyListeners();
        }
      }
    }
  }

// logic to edit an event
  Future<void> _editTask(EventModel event) async {
    final eventController = EventController()..addAll([event.event]);

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) => Provider<EventController>(
        create: (context) => eventController,
        child: EventDialog(
          eventController: eventController,
          longPressDate: event.event.date,
          longPressEndDate: event.event.endDate,
          isEditing: true,
          existingEvent: event,
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String getTrophyEmoji(int dayStreak, int monthStreak, int yearStreak) {
    if (yearStreak > 0) {
      return '🏆';
    } else if (monthStreak > 0) {
      return '🥈';
    } else if (dayStreak > 0) {
      return '🥉';
    } else {
      return '🔄';
    }
  }

  Widget _buildTaskList(String type) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final tasks = type == 'todo'
            ? eventProvider.events
                .where((event) => !event.isCompleted && !event.isArchived)
                .toList()
            : eventProvider.events
                .where((event) => event.isCompleted && !event.isArchived)
                .toList();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return _buildTaskItem(tasks[index], context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBEAE3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBEAE3),
        elevation: 0,
        title: const Center(
          child: Text(
            'Events',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'To Do'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: _buildArchivedDrawer(),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTaskList('todo'),
            _buildTaskList('completed'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => EventDialog(
              eventController: EventController(),
            ),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildArchivedDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFEBEAE3),
      child: Column(
        children: <Widget>[
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Icon(Icons.archive, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Archived Tasks',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                final archivedTasks = eventProvider.events
                    .where((event) => event.isArchived)
                    .toList();

                if (archivedTasks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No archived tasks',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: archivedTasks.length,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemBuilder: (context, index) {
                    final event = archivedTasks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Slidable(
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              flex: 2,
                              onPressed: (context) {
                                context
                                    .read<EventProvider>()
                                    .updateArchivedStatus(event.id!, true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('${event.event.title} unarchived'),
                                  ),
                                );
                              },
                              backgroundColor: const Color(0xFF7BC043),
                              foregroundColor: Colors.white,
                              icon: Icons.unarchive,
                              label: 'Unarchive',
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(12),
                              ),
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    event.event.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (event.isRecurring)
                                  Text(
                                    getTrophyEmoji(
                                      event.dayStreak ?? 0,
                                      event.monthStreak ?? 0,
                                      event.yearStreak ?? 0,
                                    ),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${DateFormat('h:mm a').format(event.event.date)} - ${DateFormat('h:mm a').format(event.event.endTime!)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MMM d, yyyy')
                                          .format(event.event.date),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailWithNotes(event: event),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(EventModel event, BuildContext context) {
    String getTrophyEmoji(int dayStreak, int monthStreak, int yearStreak) {
      if (yearStreak > 0) {
        return '🏆';
      } else if (monthStreak > 0) {
        return '🥈';
      } else if (dayStreak > 0) {
        return '🥉';
      } else {
        return '🔄';
      }
    }

    String getStreakText(int dayStreak, int monthStreak, int yearStreak) {
      List<String> streaks = [];
      if (yearStreak > 0) streaks.add('$yearStreak years');
      if (monthStreak > 0) streaks.add('$monthStreak months');
      if (dayStreak > 0) streaks.add('$dayStreak days');
      return streaks.join(' • ');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                flex: 2,
                onPressed: (context) {
                  context
                      .read<EventProvider>()
                      .updateArchivedStatus(event.id!, event.isArchived);
                },
                backgroundColor: const Color(0xFF7BC043),
                foregroundColor: Colors.white,
                icon: Icons.archive,
                label: event.isArchived ? 'Unarchive' : 'Archive',
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(12)),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: event.isCompleted,
                      onChanged: (bool? value) async {
                        await context
                            .read<EventProvider>()
                            .toggleComplete(event.id!, value ?? false);
                        if (value == true && event.isRecurring) {
                          await context
                              .read<EventProvider>()
                              .updateStreak(event.id!);
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.event.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: event.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      if (event.isRecurring)
                        Text(
                          getTrophyEmoji(
                            event.dayStreak ?? 0,
                            event.monthStreak ?? 0,
                            event.yearStreak ?? 0,
                          ),
                          style: const TextStyle(fontSize: 20),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editTask(event),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EventDetailWithNotes(event: event),
                      ),
                    );
                  },
                ),
                if (event.isRecurring &&
                    (event.dayStreak! > 0 ||
                        event.monthStreak! > 0 ||
                        event.yearStreak! > 0))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            getStreakText(
                              event.dayStreak ?? 0,
                              event.monthStreak ?? 0,
                              event.yearStreak ?? 0,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 8.0,
                    bottom: 4.0,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${DateFormat('h:mm a').format(event.event.date)} - ${DateFormat('h:mm a').format(event.event.endTime!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, yyyy').format(event.event.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
