import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class LanguageDetector extends StatefulWidget {
  @override
  _LanguageDetectorState createState() => _LanguageDetectorState();
}

class _LanguageDetectorState extends State<LanguageDetector> {
  final lang = LanguageIdentifier(confidenceThreshold: 0.5);
  List<String> urduWords = [];
  List<String> teluguWords = [];
  List<String> englishWords = [];
  String inputWord = '';
  String detectedLanguage = '';

  Future<void> detectAndStoreLanguage(String word) async {
    final String detectedLanguage = await lang.identifyLanguage(word);
    switch (detectedLanguage) {
      case 'ur':
        setState(() {
          urduWords.add(word);
        });
        break;
      case 'te':
        setState(() {
          teluguWords.add(word);
        });
        break;
      default:
        setState(() {
          englishWords.add(word);
        });
    }
  }

  void splitTextAndDetectLanguage(String text) {
    List<String> words = text.split(' ');
    for (String word in words) {
      detectAndStoreLanguage(word);
    }
  }

  void searchWord() {
    switch (detectedLanguage) {
      case 'ur':
        if (urduWords.contains(inputWord)) {
          print('$inputWord is urdu and found in Urdu words list.');
        } else {
          print('$inputWord not found ');
        }
        break;
      case 'te':
        if (teluguWords.contains(inputWord)) {
          print('$inputWord  is telugu and found in Telugu words list.');
        } else {
          print('$inputWord not found ');
        }
        break;
      default:
        if (englishWords.contains(inputWord)) {
          print('$inputWord is English and found in English words list.');
        } else {
          print('$inputWord not found ');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Word'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Enter Text',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                splitTextAndDetectLanguage(value);
              },
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Word',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                inputWord = value;
                setState(() {
                  detectedLanguage = '';
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (inputWord.isNotEmpty) {
                  searchWord();
                } else {
                  print('Please enter a word to search.');
                }
              },
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            Text(
              'Detected Language: $detectedLanguage',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
