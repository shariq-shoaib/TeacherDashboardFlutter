import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SubjectAssignments.dart';
import 'SubjectQueries.dart';
import 'SubjectResults.dart';
import 'SubjectAttendance.dart';
import 'SubjectChat.dart';
import 'SubjectAnnouncementsScreen.dart';

class SubjectDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> subject;

  const SubjectDashboardScreen({Key? key, required this.subject})
    : super(key: key);

  @override
  _SubjectDashboardScreenState createState() => _SubjectDashboardScreenState();
}

class _SubjectDashboardScreenState extends State<SubjectDashboardScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = []; // Initialize empty list
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now it's safe to access inherited widgets
    _screens = [
      _buildOverviewScreen(),
      SubjectAssignmentsScreen(subject: widget.subject),
      SubjectQueriesScreen(subject: widget.subject),
      SubjectResultsScreen(subject: widget.subject),
      SubjectAttendanceScreen(subject: widget.subject),
      SubjectChatScreen(subject: widget.subject), // Added chat screen
    ];
  }

  Widget _buildOverviewScreen() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuickStatsPanel(),
          SizedBox(height: 24),
          _buildSectionPreview(
            title: 'Recent Announcements',
            onViewAll:
                () => _navigateToScreen(
                  SubjectAnnouncementsScreen(subject: widget.subject),
                ),
            child: _buildAnnouncementsPreview(),
          ),
          _buildSectionPreview(
            title: 'Upcoming Assignments',
            onViewAll:
                () => _navigateToScreen(
                  SubjectAssignmentsScreen(subject: widget.subject),
                ),
            child: _buildAssignmentsPreview(),
          ),
          _buildSectionPreview(
            title: 'Pending Queries',
            onViewAll:
                () => _navigateToScreen(
                  SubjectQueriesScreen(subject: widget.subject),
                ),
            child: _buildQueriesPreview(),
          ),
          _buildSectionPreview(
            title: 'Attendance Summary',
            onViewAll:
                () => _navigateToScreen(
                  SubjectAttendanceScreen(subject: widget.subject),
                ),
            child: _buildAttendancePreview(),
          ),
          _buildSectionPreview(
            title: 'Recent Messages',
            onViewAll:
                () => _navigateToScreen(
                  SubjectChatScreen(subject: widget.subject),
                ),
            child: _buildChatPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatPreview() {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[50],
            child: Icon(Icons.person, color: Colors.blue),
          ),
          title: Text(
            'Prof. Smith',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Don\'t forget about the assignment due tomorrow',
            style: GoogleFonts.poppins(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '10m ago',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
          ),
        ),
        Divider(height: 1),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green[50],
            child: Icon(Icons.person, color: Colors.green),
          ),
          title: Text(
            'You',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'I submitted the assignment last night',
            style: GoogleFonts.poppins(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '5m ago',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final subjectColor =
        widget.subject['color'] ?? Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subject['name'],
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: subjectColor,
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions:
            _currentIndex == 5
                ? [
                  IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () {
                      // Show chat info
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.people_outline),
                    onPressed: () {
                      // Show participants
                    },
                  ),
                ]
                : null,
      ),
      body:
          _screens.isNotEmpty
              ? _screens[_currentIndex]
              : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: subjectColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer_outlined),
            activeIcon: Icon(Icons.question_answer),
            label: 'Queries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
            label: 'Results',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      floatingActionButton:
          _currentIndex == 0 ? null : _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    final subjectColor =
        widget.subject['color'] ?? Theme.of(context).primaryColor;

    switch (_currentIndex) {
      case 1: // Assignments
        return FloatingActionButton(
          backgroundColor: subjectColor,
          child: Icon(Icons.add),
          onPressed: () {
            // Add new assignment
          },
        );
      case 2: // Queries
        return FloatingActionButton(
          backgroundColor: subjectColor,
          child: Icon(Icons.add_comment),
          onPressed: () {
            // Add new query
          },
        );
      case 3: // Results
        return FloatingActionButton(
          backgroundColor: subjectColor,
          child: Icon(Icons.download),
          onPressed: () {
            // Export results
          },
        );
      case 4: // Attendance
        return FloatingActionButton(
          backgroundColor: subjectColor,
          child: Icon(Icons.date_range),
          onPressed: () {
            // View attendance calendar
          },
        );
      default:
        return null;
    }
  }

  Widget _buildQuickStatsPanel() {
    final subjectColor =
        widget.subject['color'] ?? Theme.of(context).primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            subjectColor.withOpacity(0.8),
            subjectColor.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('45', 'Students', Icons.people),
              _buildStatItem('5', 'Assignments', Icons.assignment),
              _buildStatItem('92%', 'Attendance', Icons.calendar_today),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('3', 'Pending Queries', Icons.question_answer),
              _buildStatItem('4.2', 'Avg. Grade', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionPreview({
    required String title,
    required VoidCallback onViewAll,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color:
                        widget.subject['color'] ??
                        Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(padding: EdgeInsets.all(8), child: child),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAnnouncementsPreview() {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[50],
            child: Icon(Icons.announcement, color: Colors.blue),
          ),
          title: Text(
            'Exam Schedule Posted',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Final exams will begin next week on Monday',
            style: GoogleFonts.poppins(),
          ),
          trailing: Text(
            '2h ago',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
          ),
        ),
        Divider(height: 1),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green[50],
            child: Icon(Icons.assignment, color: Colors.green),
          ),
          title: Text(
            'Assignment 3 Graded',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Grades for the last assignment are now available',
            style: GoogleFonts.poppins(),
          ),
          trailing: Text(
            '1d ago',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentsPreview() {
    final subjectColor =
        widget.subject['color'] ?? Theme.of(context).primaryColor;

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange[50],
            child: Icon(Icons.assignment, color: Colors.orange),
          ),
          title: Text(
            'Linear Algebra Homework',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Due: Jun 15, 2023', style: GoogleFonts.poppins()),
              SizedBox(height: 4),
              LinearProgressIndicator(
                value: 0.7,
                backgroundColor: subjectColor.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
              ),
              Text('32/45 submitted', style: GoogleFonts.poppins(fontSize: 12)),
            ],
          ),
        ),
        Divider(height: 1),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple[50],
            child: Icon(Icons.assignment, color: Colors.purple),
          ),
          title: Text(
            'Midterm Project',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Due: Jun 30, 2023', style: GoogleFonts.poppins()),
              SizedBox(height: 4),
              LinearProgressIndicator(
                value: 0.3,
                backgroundColor: subjectColor.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
              ),
              Text('12/45 submitted', style: GoogleFonts.poppins(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQueriesPreview() {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red[50],
            child: Icon(Icons.question_answer, color: Colors.red),
          ),
          title: Text(
            'Alice Johnson',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Clarification on problem 3 in homework',
            style: GoogleFonts.poppins(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Chip(
            label: Text(
              'Pending',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        ),
        Divider(height: 1),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green[50],
            child: Icon(Icons.question_answer, color: Colors.green),
          ),
          title: Text(
            'Bob Smith',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Extension request for assignment',
            style: GoogleFonts.poppins(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Chip(
            label: Text(
              'Answered',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendancePreview() {
    final subjectColor =
        widget.subject['color'] ?? Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              Text(
                '92%',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: subjectColor,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.92,
            backgroundColor: subjectColor.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniAttendanceStat(
                'Mon',
                '100%',
                Icons.check,
                Colors.green,
              ),
              _buildMiniAttendanceStat('Tue', '95%', Icons.check, Colors.green),
              _buildMiniAttendanceStat('Wed', '89%', Icons.check, Colors.green),
              _buildMiniAttendanceStat('Thu', '92%', Icons.check, Colors.green),
              _buildMiniAttendanceStat(
                'Fri',
                '85%',
                Icons.warning,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAttendanceStat(
    String day,
    String percent,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Text(day, style: GoogleFonts.poppins(fontSize: 12)),
        SizedBox(height: 4),
        Icon(icon, color: color, size: 16),
        Text(percent, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }

  Widget _buildAnnouncementsScreen() {
    final subjectColor =
        widget.subject['color'] ?? Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('All Announcements'),
        backgroundColor: subjectColor,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildAnnouncementCard(
            title: 'Exam Schedule Posted',
            content: 'Final exams will begin next week on Monday',
            time: '2h ago',
            icon: Icons.announcement,
            color: Colors.blue,
          ),
          SizedBox(height: 12),
          _buildAnnouncementCard(
            title: 'Assignment 3 Graded',
            content: 'Grades for the last assignment are now available',
            time: '1d ago',
            icon: Icons.assignment,
            color: Colors.green,
          ),
          SizedBox(height: 12),
          _buildAnnouncementCard(
            title: 'Course Materials Updated',
            content: 'New reading materials have been uploaded for Chapter 4',
            time: '3d ago',
            icon: Icons.library_books,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required String title,
    required String content,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(content, style: GoogleFonts.poppins()),
          ],
        ),
      ),
    );
  }
}
