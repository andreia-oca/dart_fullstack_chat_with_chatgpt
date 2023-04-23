import 'package:dart_openai/openai.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:chat_with_chatgpt/constants.dart';

class ChatBackend {
  late Db db;
  late DbCollection bookmarks;

  ChatBackend() {
    // Set the OpenAI API key
    OpenAI.apiKey = OPENAPI_KEY;

    // Connect to the database
    _connect().catchError((e) {
      print("Error connecting to database: $e");
      throw e;
    });
  }

  Future<String> _connect() async {
    // Connect to the database
    db = await Db.create(MONGODB_URI).catchError((e) {
      print("Error connecting to database: $e");
      throw e;
    });

    // Open the database
    await db.open().catchError((e) {
      print("Error opening database: $e");
      throw e;
    });

    // Get the bookmarks collection
    bookmarks = db.collection('bookmarks');

    return "success";
  }

  Future<String> askChatGpt(String prompt) async {
    // Create a list of messages (that contains only one message)
    final my_msg = [
      OpenAIChatCompletionChoiceMessageModel(
          content: prompt, role: OpenAIChatMessageRole.user),
    ];

    // Create a chat OpenAI instance
    final chat = await OpenAI.instance.chat
        .create(model: "gpt-3.5-turbo", messages: my_msg);

    // Return the response from chatGPT
    return chat.choices.first.message.content;
  }

  Future<String> addBookmark(String content) async {
    print("Adding bookmark with content: $content");

    // Check if bookmark already exists
    final value = await bookmarks.findOne({'content': content});
    if (value != null) {
      print("Bookmark already exists");
      throw "Bookmark already exists";
    }

    // Add bookmark into the database
    await bookmarks.insertOne({'content': content}).catchError((e) {
      print("Error adding bookmark: $e");
      throw e;
    });

    return "success";
  }

  Future<List<String>> getAllBookmarks() async {
    // Get all the bookmarks from the database
    final rawBookmarks = await bookmarks.find();

    // Convert the list of bookmarks into a list of strings List<String>
    final bookmarksList = await rawBookmarks
        .map((element) => element['content'].toString())
        .toList();
    print("All the bookmarks " + bookmarksList.toString());

    return bookmarksList;
  }
}
