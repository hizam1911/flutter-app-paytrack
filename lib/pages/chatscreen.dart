import 'package:flutter/material.dart';
import 'dart:convert';
import 'ChatBubble.dart';
import 'TypewriterAnimation.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:paytrack/auth/secrets.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Widget> messages = [];
  bool _isWaiting = false; // Flag to show typewriter animation
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  @override
  void dispose() {
    //Dispose ScrollController when done
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage(String text) async {
    setState(() {
      messages.add(ChatBubble(message: text, isUser: true));
      _isWaiting = true; // Show typewriter animation
    });

    // Access your API key as an environment variable (see "Set up your API key" above)
    final apiKey = "$geminiAPIKey";
    const modelInstruction = """
    You are a certified and qualified professional financial advisor. 
    If someone ask for advice, you have to guide them by giving tips on saving 
    money and manage their financial. If someone ask for advice on anything 
    related to financial, then you have to help them. Your main purpose is to 
    guide people to stabilize their finance condition.
    """;
    if (apiKey == null) {
      print('No \$API_KEY environment variable');
      exit(1);
    }

    // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.text(modelInstruction),
    );
    final content = [Content.text(jsonEncode({'message': text}))];
    final response = await model.generateContent(content);
    print("Model Instruction: " + modelInstruction);
    print(response.text);
    setState(() {
      _isWaiting = false; // Hide typewriter animation
    });

    final meow = jsonEncode({'response': response.text});
    Map<String?, dynamic> data = jsonDecode(meow);
    setState(() {
      messages.add(ChatBubble(message: data['response'], isUser: false));
    });

    scrollToBottom();
  }

  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 50), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Gemini (Chatbot)'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) => messages[index],
            ),
          ),
          _isWaiting ? TypewriterAnimation() : _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                sendMessage(_controller.text);
                _controller.clear();
                scrollToBottom();
              }
            },
          ),
        ],
      ),
    );
  }
}