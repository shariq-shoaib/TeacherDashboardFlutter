import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SubjectQueriesScreen extends StatefulWidget {
  final Map<String, dynamic> subject;

  const SubjectQueriesScreen({Key? key, required this.subject}) : super(key: key);

  @override
  _SubjectQueriesScreenState createState() => _SubjectQueriesScreenState();
}

class _SubjectQueriesScreenState extends State<SubjectQueriesScreen> {
  List<Map<String, dynamic>> queries = [];
  bool isLoading = false; // Changed to false since we're using dummy data
  final TextEditingController _responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    // Dummy data with more realistic queries
    setState(() {
      queries = [
        {
          'id': '1',
          'student_name': 'Alex Johnson',
          'student_avatar': '👨‍🎓',
          'question': 'Could you explain the concept of polynomial division again? I missed the last class.',
          'status': 'pending',
          'created_at': '2023-06-10T09:30:00Z',
          'response': null,
        },
        {
          'id': '2',
          'student_name': 'Sarah Williams',
          'student_avatar': '👩‍🎓',
          'question': 'Is there any recommended reading material for the upcoming exam?',
          'status': 'answered',
          'created_at': '2023-06-08T14:15:00Z',
          'response': 'Yes, please check chapters 3-5 in the textbook and the additional PDF I shared on the course portal.',
        },
        {
          'id': '3',
          'student_name': 'Michael Chen',
          'student_avatar': '👨‍💻',
          'question': 'Can I get an extension for Assignment 2? I had a family emergency.',
          'status': 'answered',
          'created_at': '2023-06-05T16:45:00Z',
          'response': 'I understand. You have until Friday to submit without penalty.',
        },
        {
          'id': '4',
          'student_name': 'Emma Davis',
          'student_avatar': '👩‍🔬',
          'question': 'The solution for problem 3 in the practice set seems incorrect. Can you verify?',
          'status': 'pending',
          'created_at': '2023-06-12T11:20:00Z',
          'response': null,
        },
      ];
    });
  }

  Future<void> _respondToQuery(String queryId, String responseText) async {
    if (responseText.trim().isEmpty) return;

    setState(() {
      final index = queries.indexWhere((q) => q['id'] == queryId);
      if (index != -1) {
        queries[index]['status'] = 'answered';
        queries[index]['response'] = responseText;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Response sent successfully')),
    );
  }

  void _showResponseDialog(Map<String, dynamic> query) {
    final subjectColor = widget.subject['color'] ?? Theme.of(context).primaryColor;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(query['student_avatar']),
                    backgroundColor: subjectColor.withOpacity(0.2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    query['student_name'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Question:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  query['question'],
                  style: GoogleFonts.poppins(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _responseController,
                decoration: InputDecoration(
                  labelText: 'Your Response',
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 4,
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subjectColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      _respondToQuery(query['id'], _responseController.text);
                      _responseController.clear();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Send',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectColor = widget.subject['color'] ?? theme.primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              'Student Queries',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: subjectColor,
            centerTitle: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      subjectColor.withOpacity(0.8),
                      subjectColor.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildQueryCard(queries[index], theme, subjectColor),
              childCount: queries.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: subjectColor,
        child: const Icon(Icons.refresh, color: Colors.white),
        onPressed: _loadDummyData,
      ),
    );
  }

  Widget _buildQueryCard(Map<String, dynamic> query, ThemeData theme, Color subjectColor) {
    final isPending = query['status'] == 'pending';
    final date = query['created_at'] != null
        ? DateFormat('MMM d, h:mm a').format(DateTime.parse(query['created_at']))
        : '';
    final hasResponse = query['response'] != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showResponseDialog(query),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      child: Text(query['student_avatar']),
                      backgroundColor: subjectColor.withOpacity(0.2),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            query['student_name'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            date,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPending
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPending ? Colors.orange : Colors.green,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isPending ? 'PENDING' : 'RESOLVED',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPending ? Colors.orange : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  query['question'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                if (hasResponse) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: subjectColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: subjectColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: subjectColor,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Your Response',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: subjectColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          query['response'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: subjectColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () => _showResponseDialog(query),
                      child: Text(
                        'Respond Now',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }
}