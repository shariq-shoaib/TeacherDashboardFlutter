import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectChatScreen extends StatefulWidget {
  final Map<String, dynamic> subject;

  const SubjectChatScreen({Key? key, required this.subject}) : super(key: key);

  @override
  _SubjectChatScreenState createState() => _SubjectChatScreenState();
}

class _SubjectChatScreenState extends State<SubjectChatScreen> {
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  final String _apiUrl = 'https://your-api-endpoint.com/chat';

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl?subject=${widget.subject['code']}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          messages = List<Map<String, dynamic>>.from(data['messages']);
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = {
      'text': _messageController.text,
      'is_teacher': true, // Assuming teacher is sending
      'timestamp': DateTime.now().toIso8601String(),
      'subject': widget.subject['code'],
    };

    setState(() {
      _isSending = true;
      messages.add(newMessage);
      _messageController.clear();
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newMessage),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
      // Remove the message if sending failed
      setState(() {
        messages.removeLast();
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectColor = widget.subject['color'] ?? theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          _buildChatHeader(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? Center(
              child: Text(
                'No messages yet\nStart the conversation!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) =>
                  _buildMessageBubble(messages[index], theme, subjectColor),
            ),
          ),
          _buildMessageInput(theme, subjectColor),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: widget.subject['color'] ?? Theme.of(context).primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.chat_bubble, color: Colors.white),
          SizedBox(width: 12),
          Text(
            '${widget.subject['name']} Chat',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      Map<String, dynamic> message, ThemeData theme, Color subjectColor) {
    final isTeacher = message['is_teacher'] ?? false;
    final timestamp = DateTime.parse(message['timestamp']);
    final timeString = DateFormat('h:mm a').format(timestamp);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: isTeacher ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Column(
            crossAxisAlignment:
            isTeacher ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isTeacher
                      ? subjectColor.withOpacity(0.9)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isTeacher ? 12 : 0),
                    topRight: Radius.circular(isTeacher ? 0 : 12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  message['text'],
                  style: GoogleFonts.poppins(
                    color: isTeacher ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                timeString,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: theme.colorScheme.onBackground.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme, Color subjectColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.poppins(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () {
                      // Add attachment functionality
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: subjectColor,
            ),
            child: IconButton(
              icon: _isSending
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Icon(Icons.send, color: Colors.white),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}