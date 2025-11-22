import 'package:flutter/material.dart';

void main() => runApp(TrackmateeChatbotApp());

class TrackmateeChatbotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trackmatee Chatbot UI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0E0E0E),
        primaryColor: Color(0xFFBFA6FF),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: HomeTabs(),
    );
  }
}

class HomeTabs extends StatefulWidget {
  @override
  _HomeTabsState createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      StartScreen(),
      FAQScreen(),
      ChatScreen(),
    ];

    return Scaffold(
      body: tabs[_selected],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        currentIndex: _selected,
        selectedItemColor: Color(0xFFBFA6FF),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _selected = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.question_answer), label: 'FAQ'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        ],
      ),
    );
  }
}

// ---------------- Start Screen ----------------
class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 26, backgroundColor: Colors.grey[800], child: Icon(Icons.person, color: Colors.white)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Press Start to ask question to your own personalised AI chat bot to get answers to your queries',
                    style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                  ),
                )
              ],
            ),
            SizedBox(height: 30),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.smart_toy, size: 80, color: Color(0xFF6C4BDB)),
                    SizedBox(height: 18),
                    Text(
                      'Trained over the millions of trips taken by travellers all over the country. Our bot uses verified info to provide best experience.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDCC9FF),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Start Conversation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final homeState = context.findAncestorStateOfType<_HomeTabsState>();
                  homeState?.setState(() {
                    homeState._selected = 1; // Switch to FAQ tab
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- FAQ Screen ----------------
class FAQScreen extends StatelessWidget {
  final List<String> faqs = [
    'How do I start tracking a trip?',
    'How is the suggested route chosen?',
    'How accurate is ETA (Estimated Time of Arrival)?',
    'How can I reduce fuel consumption?',
    'What information is shared with others?',
    'How do I view past trips?',
    'How are tolls and charges estimated?',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 24, backgroundColor: Colors.grey[800]),
                SizedBox(width: 12),
                Text('Frequently Asked Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 18),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                ),
                width: double.infinity,
                child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, i) => InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            initialMessage: faqs[i],
                          ),
                        ),
                      );
                    },
                    child: FAQItem(title: faqs[i]),
                  ),
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemCount: faqs.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String title;
  const FAQItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFF2F2A36),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: Colors.white))),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400])
        ],
      ),
    );
  }
}

// ---------------- Chat Screen ----------------
class ChatScreen extends StatefulWidget {
  final String? initialMessage;

  ChatScreen({this.initialMessage});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class Message {
  final String text;
  final bool isUser;
  Message(this.text, {this.isUser = false});
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _messages.add(Message('Hi, my name is Trackro, how may I help you today?', isUser: false));

    if (widget.initialMessage != null) {
      _messages.add(Message(widget.initialMessage!, isUser: true));

      Future.delayed(Duration(milliseconds: 500), () {
        _messages.add(Message("Thanks for asking: '${widget.initialMessage}'. (Mock reply)", isUser: false));
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: CircleAvatar(backgroundColor: Colors.grey[800], child: Icon(Icons.person, color: Colors.white)),
        ),
        title: Text('Trackro', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) => ChatBubble(message: _messages[i]),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF1A1A1A),
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.all(12), backgroundColor: Color(0xFF6C4BDB)),
                    child: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      _messages.add(Message(text, isUser: true));
                      setState(() {});
                      controller.clear();

                      Future.delayed(Duration(milliseconds: 600), () {
                        _messages.add(Message('Thanks — we got your question: "$text". (Mock reply)', isUser: false));
                        setState(() {});
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;

    final radius = isUser
        ? BorderRadius.only(
      topLeft: Radius.circular(14),
      topRight: Radius.circular(14),
      bottomLeft: Radius.circular(14),
    )
        : BorderRadius.only(
      topLeft: Radius.circular(14),
      topRight: Radius.circular(14),
      bottomRight: Radius.circular(14),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            ...[
              CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.android, color: Color(0xFF6C4BDB)),
              ),
              SizedBox(width: 8),
            ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? Color(0xFF2E2B2F) : Color(0xFF2C2C2C),
                borderRadius: radius,
              ),
              child: Text(message.text, style: TextStyle(color: Colors.white)),
            ),
          ),
          if (isUser) SizedBox(width: 8),
        ],
      ),
    );
  }
}
