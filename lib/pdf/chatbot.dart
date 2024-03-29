import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shimmer/shimmer.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  
  TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  final List<Map<String, dynamic>> messages = [];
  String assistantResponse = "";
  String operation = '';
  String selectedOption = ''; // added to keep track of selected radio button

  Future<void> chatGPTAPI(String prompt) async {
    setState(() {
      isLoading = true;
    });
    messages.add({'role': 'user', 'content': prompt});
    try {
      final res = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $aikey"
        },
        body: jsonEncode(
          {"model": "gpt-3.5-turbo", "messages": messages},
        ),
      );
      print(res.body);
      if (res.statusCode == 200) {
        String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({'role': 'assistant', 'content': content});

        setState(() {
          assistantResponse = content;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch response');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        print('Error: $e');
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text Engine"),
        backgroundColor: Color.fromARGB(255, 191, 219, 243),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 191, 219, 243), Color.fromARGB(255, 188, 196, 202)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  children: messages.map<Widget>((message) => buildChatMessage(message)).toList(),
                ),
              ),
            ),
            isLoading
                ? Container(
                    width: double.infinity,
                    height: 100,
                    child: Center(
                      child: Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.deepPurple,
                        child: Text('Please Wait.....', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  Row(children: [Radio(value: 'Story',groupValue: selectedOption,
                        onChanged: (value) {setState(() {selectedOption = value!;operation = value;});},), Text('Story'),],),
                  SizedBox(width:5),
                   Row(children: [Radio(value: 'Article',groupValue: selectedOption,
                        onChanged: (value) {setState(() {selectedOption = value!;operation = value;});},), Text('Article'),],),
                  SizedBox(width:5),
                   Row(children: [Radio(value: 'Case study',groupValue: selectedOption,
                        onChanged: (value) {setState(() {selectedOption = value!;operation = value;});},), Text('Case Study'),],),
                  SizedBox(width:5),
                ],
              ),
            ),
            BottomAppBar(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type content to process.',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () {
                          if (_controller.text.isNotEmpty && operation != '') {
                            chatGPTAPI("generate $operation for/on text = ${_controller.text}");
                            _controller.clear(); // Clear input field after sending message
                          }
                        },
                        child: Icon(Icons.send)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildChatMessage(Map<String, dynamic> message) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    child: Align(
      alignment: message['role'] == 'user' ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: message['role'] == 'user' ? [Colors.blueAccent, Colors.deepPurple] : [Colors.grey, Colors.white],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message['content'],
          style: TextStyle(fontSize: 15, color: message['role'] == 'user' ? Colors.white : Colors.black),
        ),
      ),
    ),
  );
}
