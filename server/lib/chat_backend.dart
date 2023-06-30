import 'package:dart_openai/openai.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:chat_with_chatgpt/constants.dart';

class ChatBackend {
  Db? db = null;

  // Private constructor
  ChatBackend() {
    // Set the OpenAI API key
    OpenAI.apiKey = OPENAPI_KEY;
  }

  Future<String> askChatGpt(String prompt, String question) async {
    // Create a list of messages (that contains only one message)
    final my_msg = [
      OpenAIChatCompletionChoiceMessageModel(
          content: prompt + question, role: OpenAIChatMessageRole.user),
    ];

    // Create a chat OpenAI instance
    var chat;
    try {
      chat = await OpenAI.instance.chat
          .create(model: "gpt-3.5-turbo", messages: my_msg, stop: ["\n\n"]);
    } catch (e) {
      if (e is RequestFailedException && e.statusCode == 401) {
        print(
            "OpenAI request failed: $e. Your OpenAI API key might be invalid");
        return "OpenAI request failed: $e. Your OpenAI API key might be invalid";
      }

      print("OpenAI request failed: $e");
      return "OpenAI request failed: $e";
    }

    // Return the response from chatGPT
    return chat.choices.first.message.content;
  }

  Future<String> askYoda(String question) async {
    String prompt = "Respond to me as if you are Yoda from Star Wars: \n\n";
    return askChatGpt(prompt, question);
  }

  Future<String> askChewbacca(String question) async {
    String prompt =
        "Respond to me as if you are Chewbacca from Star Wars: \n\n";
    return askChatGpt(prompt, question);
  }

  Future<String> _connect() async {
    // Connect to the database
    db = await Db.create(MONGODB_URI).catchError((e) {
      print("Error connecting to database: $e");
      throw e;
    });

    // Open the database
    await db?.open().catchError((e) {
      print("Error opening database: $e");
      throw e;
    });

    return "success";
  }

  Future<String> addBookmark(String content) async {
    print("Trying to add bookmark with content: $content");

    // Check if the database is connected
    if (db == null) {
      // Connect to the database
      await _connect();
    }

    // Check if bookmark already exists
    final value =
        await db?.collection("bookmarks").findOne({'content': content});
    if (value != null) {
      print("Bookmark already exists");
      throw "Bookmark already exists";
    }

    // Add bookmark into the database
    await db
        ?.collection("bookmarks")
        .insertOne({'content': content}).catchError((e) {
      print("Error adding bookmark: $e");
      throw e;
    });

    return "success";
  }

  Future<List<String>> getAllBookmarks() async {
    // Check if the database is connected
    if (db == null) {
      // Connect to the database
      await _connect();
    }

    // Get all the bookmarks from the database
    final rawBookmarks = await db?.collection("bookmarks").find();

    // Check if there are any bookmarks
    if (rawBookmarks == null) {
      return [];
    }

    // Convert the list of bookmarks into a list of strings List<String>
    final bookmarksList = await rawBookmarks
        .map((element) => element['content'].toString())
        .toList();
    print("All the bookmarks " + bookmarksList.toString());

    return bookmarksList;
  }
}
