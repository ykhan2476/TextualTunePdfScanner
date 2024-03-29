import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class exp2 extends StatefulWidget {
   const exp2({super.key, required this.title});

  final String title;

  @override
  _exp2State createState() => _exp2State();
}

class _exp2State extends State<exp2> {
  String _ocrText = '';
  String _ocrHocr = '';
  
  var LangList = ["eng", "urd", "tel"];
  var selectList = [ "urd"];
  String path = "";
  String image='';
  bool bload = false;

  bool bDownloadtessFile = false;
  var urlEditController = TextEditingController()..text = "";

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void runFilePicker() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
          image=pickedFile.path;
      });
    }
  }

  void _ocr(String imagePath) async {
  if (selectList.isEmpty) {
    print("Please select at least one language");
    return;
  }

  String langs = selectList.join("+");
  setState(() {
    bload = true;
  });

  try {
    _ocrText = await FlutterTesseractOcr.extractText(
      imagePath,
      language: langs,
      args: {
        "preserve_interword_spaces": "1",
      },
    );
    print("hello");
  } catch (e) {
    print("Error during OCR: $e");
  }

  setState(() {
    bload = false;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ocr'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          if (image.isNotEmpty) { _ocr(image); }},

                        child: Text("Run")),
                  ],
                ),
                Row(
                  children: [
                    ...LangList.map((e) {
                      return Row(children: [
                        Checkbox(
                            value: selectList.indexOf(e) >= 0,
                            onChanged: (v) async {
                              if (selectList.indexOf(e) < 0) {
                                selectList.add(e);
                              } else {
                                selectList.remove(e);
                              }
                              setState(() {});
                            }),
                        Text(e)
                      ]);
                    }).toList(),
                  ],
                ),
                Expanded(
                    child: ListView(
                  children: [
                    path.length <= 0
                        ? Container()
                        : path.indexOf("http") >= 0
                            ? Image.network(path)
                            : Image.file(File(path)),
                    bload
                        ? Column(children: [CircularProgressIndicator()])
                        : Text(
                            '$_ocrText',
                          ),
                  ],
                ))
              ],
            ),
          ),
          Container(
            color: Colors.black26,
            child: bDownloadtessFile
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [CircularProgressIndicator(), Text('download Trained language files')],
                  ))
                : SizedBox(),
          )
        ],
      ),
      floatingActionButton: kIsWeb
          ? Container()
          : FloatingActionButton(
              onPressed: runFilePicker,
              tooltip: 'Pick Image',
              child: Icon(Icons.add),
            ),
    );
  }
}

