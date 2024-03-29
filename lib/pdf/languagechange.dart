import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:shimmer/shimmer.dart';
import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class PickPdf2 extends StatefulWidget {
  const PickPdf2({Key? key}) : super(key: key);

  @override
  State<PickPdf2> createState() => _PickPdf2State();
}

class _PickPdf2State extends State<PickPdf2> {
  GlobalKey<ScaffoldState> scaffState = GlobalKey<ScaffoldState>();
  String _pdfPath = "";
  String _pdfText = "";
  String _selectedLanguage = 'en'; // Default language is English
  Map<String, String> languageMap = {
    'en': 'English',
    'ur': 'Urdu',
    'hi': 'Hindi',
    'te': 'Telugu',
    'mr': 'Marathi',
    'bn': 'Bengali',
    'gu': 'Gujarati',
    'ar':'Arabic',
    'ta':'Tamil'
  };
  bool _loading = false;

  void pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdfPath = result.files.single.path!;
        _loadPdfText();
      });
    }
  }

  void _loadPdfText() async {
    setState(() {
      _loading = true;
    });

    String text = "";
    try {
      text = await ReadPdfText.getPDFtext(_pdfPath);
    } on PlatformException {
      print('Failed to get PDF text.');
    }

    setState(() {
      _pdfText = text;
      _loading = false;
    });
    _showResult(_pdfText,'Extracted Text');
  }
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double hght = MediaQuery.of(context).size.height;
    double wid = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffState,
      body: Container(
        height: hght,
        width: wid,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                height: hght * 0.15,
                width: wid,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.elliptical(80, 30),
                    bottomRight: Radius.elliptical(80, 30),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Text(
                      'Translator',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ],
                ),
              ),
              Container(
                child: _pdfPath.isNotEmpty
                    ? _loading
                        ? Container(
                            width: 150,
                            height: 100.0,
                            margin: EdgeInsets.only(top: 200, bottom: 100),
                            child: Shimmer.fromColors(
                              baseColor: Colors.white,
                              highlightColor: Colors.deepPurple,
                              child: Center(
                                child: Text(
                                  'Please Wait.....',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.all(40),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: [
                                  Row(children: [
                                    Text('Select Language'),
                                    SizedBox(width: 30,),
                                     DropdownButton<String>(
                                    value: _selectedLanguage,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedLanguage = newValue!;
                                      });
                                    },
                                    items: languageMap.entries.map((entry) {
                                      return DropdownMenuItem<String>(
                                        value: entry.key,
                                        child: Text(entry.value),
                                      );
                                    }).toList(),
                                  ),
                                  ],),
                                 
                                  Row(children: [
                                    ElevatedButton(onPressed: () { _copyToClipboard(_pdfText);}, child: Icon(Icons.copy),),
                                    SizedBox(width: 20,),
                                    ElevatedButton(
                                    onPressed: () {
                                      _translateText();
                                    },
                                    child: Text('Translate Text'),
                                  ),
                                  ],),
                                  
                                  
                                   SizedBox(height: 20),
                                  Text(_loading ? 'Loading...' : _pdfText,
                                  style: TextStyle(color: Colors.black),),
                                  SizedBox(height: 100),
                              /*   BottomAppBar(
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
                          if (_controller.text.isNotEmpty ) {
                           
                            _controller.clear(); // Clear input field after sending message
                          }
                        },
                        child: Icon(Icons.send)),
                  ],
                ),
              ),
            ),*/
                                 
                                  
                                ],
                              ),
                            ),
                          )
                    : Center(
                        child: Text(
                          'No PDF selected',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                height: hght,
                width: wid,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickFiles,
        tooltip: 'Pick PDF',
        child: Icon(Icons.file_upload),
      ),
    );
  }

  void _showResult(String text,String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: Text(
                text,
                softWrap: true,
              ),
            ),
          ),
          actions: [
            ElevatedButton(onPressed: () { _copyToClipboard(_pdfText);}, child: Icon(Icons.copy),),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
 
 void _copyToClipboard(String text) {
    FlutterClipboard.copy(text).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Text copied to clipboard'),
        ),
      );
    });
  }

 void _translateText() async {
  if (_pdfText.isNotEmpty) {
    setState(() {
      _loading = true; // Set loading state to true when translation starts
    });
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await langdetect.initLangDetect();  
      String detectedLanguage = langdetect.detect(_pdfText); 
      print(detectedLanguage);
      final _modelManager = OnDeviceTranslatorModelManager();
      final Translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.values.firstWhere((element) => element.bcpCode == detectedLanguage),
        targetLanguage: TranslateLanguage.values.firstWhere((element) => element.bcpCode == _selectedLanguage)
      );
      final translatedText = await Translator.translateText(_pdfText);
      setState(() {
        _pdfText = translatedText;
        _loading = false; // Set loading state to false when translation is finished
      });
      _showResult(translatedText,"Translated Text");
      
    } catch (e) {
      print("Translation Error: $e");
      Fluttertoast.showToast(
        msg: "Translation Error: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white
      );
      setState(() {
        _loading = false; // Set loading state to false if there's an error during translation
      });
    }
  }
}

}


