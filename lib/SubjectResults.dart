import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'CreateAssessment.dart';
import 'EnterMarks.dart';
import 'MarkedAssessment.dart';

class SubjectResultsScreen extends StatefulWidget {
  final Map<String, dynamic> subject;

  const SubjectResultsScreen({Key? key, required this.subject}) : super(key: key);

  @override
  _SubjectResultsScreenState createState() => _SubjectResultsScreenState();
}

class _SubjectResultsScreenState extends State<SubjectResultsScreen> {
  List<Map<String, dynamic>> results = [];
  List<Map<String, dynamic>> assessments = [];
  bool isLoading = true;
  final String _apiUrl = 'https://your-api-endpoint.com/results';

  @override
  void initState() {
    super.initState();
    _loadDummyData(); // Replace with _fetchResults() when API is ready
  }

  Future<void> _fetchResults() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl?subject=${widget.subject['code']}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          results = List<Map<String, dynamic>>.from(data['results']);
          assessments = List<Map<String, dynamic>>.from(data['assessments']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load results');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading results: $e')),
      );
    }
  }

  void _loadDummyData() {
    setState(() {
      results = [
        {
          'student_id': '101',
          'student_name': 'Alice Johnson',
          'assignment_1': 85,
          'assignment_2': 90,
          'midterm': 78,
          'final_exam': 0,
          'total': 253,
        },
        {
          'student_id': '102',
          'student_name': 'Bob Smith',
          'assignment_1': 72,
          'assignment_2': 68,
          'midterm': 65,
          'final_exam': 0,
          'total': 205,
        },
        {
          'student_id': '103',
          'student_name': 'Charlie Brown',
          'assignment_1': 95,
          'assignment_2': 88,
          'midterm': 92,
          'final_exam': 0,
          'total': 275,
        },
      ];

      assessments = [
        {
          'id': '1',
          'title': 'Assignment 1',
          'type': 'assignment',
          'total_marks': 100,
          'date': '2023-06-10',
          'is_marked': true,
        },
        {
          'id': '2',
          'title': 'Assignment 2',
          'type': 'assignment',
          'total_marks': 100,
          'date': '2023-06-24',
          'is_marked': true,
        },
        {
          'id': '3',
          'title': 'Midterm Exam',
          'type': 'exam',
          'total_marks': 100,
          'date': '2023-07-08',
          'is_marked': true,
        },
        {
          'id': '4',
          'title': 'Final Exam',
          'type': 'exam',
          'total_marks': 100,
          'date': '2023-07-30',
          'is_marked': false,
        },
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectColor = widget.subject['color'] ?? theme.primaryColor;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.subject['name']} Results',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          backgroundColor: subjectColor,
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                child: Text(
                  'Student Results',
                  style: GoogleFonts.poppins(),
                ),
              ),
              Tab(
                child: Text(
                  'Assessments',
                  style: GoogleFonts.poppins(),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.bar_chart),
              onPressed: () {
                // Show analytics
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: subjectColor,
          child: Icon(Icons.add), // This should show the plus (+) icon
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateAssessmentScreen(
                  subjectCode: widget.subject['code'],
                  subjectColor: subjectColor,
                ),
              ),
            ).then((_) => _fetchResults());
          },
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _buildResultsTab(theme, subjectColor),
            _buildAssessmentsTab(theme, subjectColor),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTab(ThemeData theme, Color subjectColor) {
    final assessmentColumns = assessments
        .where((a) => a['is_marked'] == true)
        .map((a) => DataColumn(
      label: Text(
        a['title'],
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
    ))
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 16,
          columns: [
            DataColumn(
              label: Text(
                'Student',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
            ...assessmentColumns,
            DataColumn(
              label: Text(
                'Total',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Grade',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: results.map((result) {
            final cells = [
              DataCell(
                Text(
                  result['student_name'],
                  style: GoogleFonts.poppins(),
                ),
              ),
            ];

            // Add assessment marks
            for (var assessment in assessments.where((a) => a['is_marked'] == true)) {
              final assessmentKey = assessment['title'].toLowerCase().replaceAll(' ', '_');
              cells.add(
                DataCell(
                  Text(
                    result[assessmentKey]?.toString() ?? '-',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              );
            }

            // Add total and grade
            cells.addAll([
              DataCell(
                Text(
                  result['total'].toString(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                _buildGradeIndicator(result['total'], subjectColor),
              ),
            ]);

            return DataRow(cells: cells);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGradeIndicator(int total, Color subjectColor) {
    String grade;
    Color color;

    if (total >= 280) {
      grade = 'A+';
      color = Colors.green;
    } else if (total >= 250) {
      grade = 'A';
      color = Colors.green;
    } else if (total >= 220) {
      grade = 'B+';
      color = Colors.lightGreen;
    } else if (total >= 190) {
      grade = 'B';
      color = Colors.lightGreen;
    } else if (total >= 160) {
      grade = 'C+';
      color = Colors.orange;
    } else if (total >= 130) {
      grade = 'C';
      color = Colors.orange;
    } else {
      grade = 'D';
      color = Colors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        grade,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAssessmentsTab(ThemeData theme, Color subjectColor) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: assessments.length,
      itemBuilder: (context, index) {
        final assessment = assessments[index];
        final isMarked = assessment['is_marked'] == true;
        final date = DateFormat('MMM d, y').format(DateTime.parse(assessment['date']));

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.only(bottom: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (isMarked) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarkedAssessmentsScreen(
                      subjectCode: widget.subject['code'],
                      subjectColor: subjectColor,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnterMarksScreen(
                      assessmentId: assessment['id'],
                      assessmentTitle: assessment['title'],
                      totalMarks: assessment['total_marks'],
                      subjectColor: subjectColor,
                    ),
                  ),
                ).then((_) => _fetchResults());
              }
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        assessment['title'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Chip(
                        label: Text(
                          assessment['type'].toString().toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: subjectColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Total Marks: ${assessment['total_marks']}',
                    style: GoogleFonts.poppins(),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isMarked
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMarked ? Colors.green : Colors.orange,
                          ),
                        ),
                        child: Text(
                          isMarked ? 'MARKED' : 'PENDING',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isMarked ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isMarked) ...[
                    SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: subjectColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EnterMarksScreen(
                                assessmentId: assessment['id'],
                                assessmentTitle: assessment['title'],
                                totalMarks: assessment['total_marks'],
                                subjectColor: subjectColor,
                              ),
                            ),
                          ).then((_) => _fetchResults());
                        },
                        child: Text(
                          'Enter Marks',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}