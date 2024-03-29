import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';



class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;
  String _extractedText = '';
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _extractText() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
    });

    final inputImage = InputImage.fromFilePath(_imageFile!.path);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final textDetectorOutput = await textRecognizer.processImage(inputImage);

    setState(() {
      _extractedText = textDetectorOutput.text;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR '),
      ),floatingActionButton: FloatingActionButton(onPressed: _pickImage,child: Icon(Icons.upload),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageFile != null
                ? Image.file(
                    _imageFile!,
                    height: 200,
                  )
                : const SizedBox(),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _imageFile != null ? _extractText : null,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Extract ENGLISH Text'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _imageFile != null ? _extractText : null,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Extract URDU Text'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _imageFile != null ? _extractText : null,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Extract TELUGU Text'),
            ),
            const SizedBox(height: 20),
            _extractedText.isNotEmpty
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _extractedText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
