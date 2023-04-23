import 'package:dart_openai/openai.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:chat_with_chatgpt/constants.dart';

class GptCaller {
  late Db db;
  late DbCollection bookmarks;

  GptCaller() {
    OpenAI.apiKey = OPENAPI_KEY;
    connect();
  }

  Future<String> connect() async {
    // Connect to the database
    final db = await Db.create(MONGODB_URI);
    await db.open();
    bookmarks = db.collection('bookmarks');

    return "success";
  }

  Future<String> askChatGpt(String prompt) async {
    // Create a list of messages
    final my_msg = [
      OpenAIChatCompletionChoiceMessageModel(
          content: prompt, role: OpenAIChatMessageRole.user),
    ];

    // Create a chat
    final chat = await OpenAI.instance.chat
        .create(model: "gpt-3.5-turbo", messages: my_msg);

    // Return the response
    return chat.choices.first.message.content;
  }

  Future<String> addBookmark(String content) async {
    print("Adding bookmark: $content");
    final value = await bookmarks.findOne({'content': content});
    if (value != null) {
      print("Bookmark already exists");
      return "error - duplicate";
    }
    await bookmarks.insertOne({'content': content});

    return "success";
  }

  // Future<List<Map<String, dynamic>>> getAllBookmarks() async {
  //   var bookmarksList = await bookmarks.find().toList();
  //   print("Getting all bookmarks" + bookmarksList.toString());
  //   return bookmarksList;
  // }
}
