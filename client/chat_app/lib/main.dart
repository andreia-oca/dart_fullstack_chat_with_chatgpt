import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';

import 'package:chat_app/sdk/gpt_caller.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatPage(
        title: "Chat with ChatGPT ",
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.title});
  final String title;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
    lastName: "John",
    firstName: "Doe",
  );

  final _user_chatgpt = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ad',
    lastName: "GPT",
    firstName: "Chat",
  );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          backgroundColor: Colors.purple,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(CupertinoIcons.heart),
            ),
          ],
        ),
        body: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          onMessageDoubleTap: _onMessageDoubleTap,
          showUserAvatars: true,
          showUserNames: true,
          user: _user,
          theme: const DefaultChatTheme(
            inputBackgroundColor: Colors.purple,
            primaryColor: Colors.purple,
            secondaryColor: Colors.purple,
            inputBorderRadius: BorderRadius.all(Radius.circular(20)),
            inputMargin: EdgeInsets.all(10),
          ),
        ),
      );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    // Send prompt to chatGPT
    GptCaller.askChatGpt(message.text).then((response) {
      final gptMessage = types.TextMessage(
        author: _user_chatgpt,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: response,
      );
      _addMessage(gptMessage);
    });
  }

  void _onMessageDoubleTap(BuildContext _, types.Message message) async {
    if (message is types.TextMessage) {
      GptCaller.addBookmark(message.text);
      print("Data saved to bookmarks");
    }
  }
}
