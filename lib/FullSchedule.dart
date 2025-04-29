import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class FullScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> subject;

  const FullScheduleScreen({Key? key, required this.subject}) : super(key: key);

  @override
  _FullScheduleScreenState createState() => _FullScheduleScreenState();
}

class _FullScheduleScreenState extends State<FullScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now(); // Changed from nullable to non-nullable
  final String _apiUrl = 'https://your-api-endpoint.com/schedule';  // Sample data - replace with API call
  List<ScheduleEvent> _events = [
    ScheduleEvent(
      id: '1',
      title: 'Linear Algebra Lecture',
      description: 'Chapter 3: Vector Spaces',
      startTime: DateTime.now().subtract(Duration(days: 1)).copyWith(
          hour: 9, minute: 0),
      endTime: DateTime.now().subtract(Duration(days: 1)).copyWith(
          hour: 10, minute: 30),
      location: 'Building A, Room 203',
      type: 'lecture',
      subjectColor: Colors.blue,
    ),
    ScheduleEvent(
      id: '2',
      title: 'Calculus Tutorial',
      description: 'Problem solving session',
      startTime: DateTime.now().copyWith(hour: 11, minute: 0),
      endTime: DateTime.now().copyWith(hour: 12, minute: 30),
      location: 'Building B, Room 105',
      type: 'tutorial',
      subjectColor: Colors.green,
    ),
    ScheduleEvent(
      id: '3',
      title: 'Physics Lab',
      description: 'Experiment 5: Thermodynamics',
      startTime: DateTime.now().copyWith(hour: 14, minute: 0),
      endTime: DateTime.now().copyWith(hour: 16, minute: 0),
      location: 'Science Lab 3',
      type: 'lab',
      subjectColor: Colors.red,
    ),
    ScheduleEvent(
      id: '4',
      title: 'Computer Science Lecture',
      description: 'Algorithms: Sorting Techniques',
      startTime: DateTime.now().add(Duration(days: 1)).copyWith(
          hour: 10, minute: 0),
      endTime: DateTime.now().add(Duration(days: 1)).copyWith(
          hour: 11, minute: 30),
      location: 'CS Building, Room 301',
      type: 'lecture',
      subjectColor: Colors.purple,
    ),
    ScheduleEvent(
      id: '5',
      title: 'Mathematics Workshop',
      description: 'Advanced Problem Solving',
      startTime: DateTime.now().add(Duration(days: 2)).copyWith(
          hour: 13, minute: 0),
      endTime: DateTime.now().add(Duration(days: 2)).copyWith(
          hour: 15, minute: 0),
      location: 'Main Auditorium',
      type: 'workshop',
      subjectColor: Colors.orange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Uncomment when API is ready
    // _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl?start=${_focusedDay.subtract(Duration(days: 7))
            .toIso8601String()}&end=${_focusedDay.add(Duration(days: 14))
            .toIso8601String()}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _events = List<ScheduleEvent>.from(
              data['events'].map((e) => ScheduleEvent.fromJson(e)));
        });
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading schedule: $e')),
      );
    }
  }

  List<ScheduleEvent> _getEventsForDay(DateTime day) {
    return _events.where((event) => isSameDay(event.startTime, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectColor = widget.subject['color'] ?? theme.primaryColor;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Weekly Schedule',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      subjectColor.withOpacity(0.8),
                      subjectColor.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.today),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _fetchSchedule,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TableCalendar<ScheduleEvent>(
                firstDay: DateTime.now().subtract(Duration(days: 365)),
                lastDay: DateTime.now().add(Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: _getEventsForDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: subjectColor,
                    shape: BoxShape.circle,
                  ),
                  markersAlignment: Alignment.bottomCenter,
                  markerDecoration: BoxDecoration(
                    color: subjectColor,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  weekendStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: _buildEventsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: subjectColor,
        child: Icon(Icons.add),
        onPressed: () {
          // Add new schedule event
        },
      ),
    );
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDay!);
    final theme = Theme.of(context);

    if (events.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_available, size: 60,
                  color: theme.colorScheme.onSurface.withOpacity(0.3)),
              SizedBox(height: 16),
              Text(
                'No events scheduled',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final event = events[index];
          return _buildEventCard(event);
        },
        childCount: events.length,
      ),
    );
  }

  Widget _buildEventCard(ScheduleEvent event) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');
    final duration = event.endTime.difference(event.startTime);

    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: event.subjectColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show event details
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: event.subjectColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          event.description,
                          style: GoogleFonts.poppins(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildEventTypeChip(event.type),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  SizedBox(width: 8),
                  Text(
                    '${timeFormat.format(event.startTime)} - ${timeFormat
                        .format(event.endTime)} (${duration.inHours}h ${duration
                        .inMinutes.remainder(60)}m)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  SizedBox(width: 8),
                  Text(
                    event.location,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeChip(String type) {
    final theme = Theme.of(context);
    final typeData = {
      'lecture': {'label': 'Lecture', 'color': Colors.blue},
      'tutorial': {'label': 'Tutorial', 'color': Colors.green},
      'lab': {'label': 'Lab', 'color': Colors.red},
      'workshop': {'label': 'Workshop', 'color': Colors.orange},
      'exam': {'label': 'Exam', 'color': Colors.purple},
    };

    final label = (typeData[type]?['label'] as String?) ?? type;
    final color = (typeData[type]?['color'] as Color?) ?? theme.primaryColor;

    return Chip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }
}
class ScheduleEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String type;
  final Color subjectColor;

  ScheduleEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.type,
    required this.subjectColor,
  });

  factory ScheduleEvent.fromJson(Map<String, dynamic> json) {
    return ScheduleEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      location: json['location'],
      type: json['type'],
      subjectColor: Color(int.parse(json['color'].substring(1, 7), radix: 16) + 0xFF000000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'type': type,
      'color': '#${subjectColor.value.toRadixString(16).substring(2, 8)}',
    };
  }
}