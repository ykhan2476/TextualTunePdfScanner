import 'package:flutter/material.dart';



class WordSearch extends StatefulWidget {
  String imagetext;
   WordSearch({super.key,required this.imagetext});
  @override
  _WordSearchState createState() => _WordSearchState();
}

class _WordSearchState extends State<WordSearch> {
  TextEditingController _controller = TextEditingController();
  String _searchedWord = '';
  
  void _searchWord() {
    setState(() {
      _searchedWord = _controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    String new2= "${widget.imagetext}";
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Search'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter word to search',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchWord,
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            Text(
              'Text: ${widget.imagetext}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Searched Word: $_searchedWord',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Word Found: ${new2.contains(_searchedWord)}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
