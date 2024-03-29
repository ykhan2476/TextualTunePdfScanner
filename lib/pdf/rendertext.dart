import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:textualtune/pdf/search2.dart';

class PdfToImageAndOCR extends StatefulWidget {
  @override
  State<PdfToImageAndOCR> createState() => _PdfToImageAndOCRState();
}

class _PdfToImageAndOCRState extends State<PdfToImageAndOCR> {
  String _ocrText = '';
  String image = '';
  bool bload = false;
  bool open = false;
  int pageIndex = 0;
  Uint8List? pdfImage;
  PdfImageRendererPdf? pdf;
  int? count;
  PdfImageRendererPageSize? size;
  bool cropped = false;
  int asyncTasks = 0;
  var selectList = ["eng","urd",'tel'];
  var LangList = ["eng", "urd", "tel"];
  
 Future<void> _getImageFromCamera() async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(source: ImageSource.camera);
  if (pickedImage != null) {
      setState(() {
          image=pickedImage.path;
      });
    }
     _ocr(image);
  // Process the pickedImage further (e.g., pass it to OCR function)
}

Future<void> _getImageFromGallery() async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(source: ImageSource.gallery);
  if (pickedImage != null) {
      setState(() {
          image=pickedImage.path;
      });
    }
    _ocr(image);
  // Process the pickedImage further (e.g., pass it to OCR function)
}

  Future<String> convertUint8ListToImageFile(Uint8List bytes) async {
  Directory tempDir = await getTemporaryDirectory();
  File tempFile = File('${tempDir.path}/temp_image.png');
  await tempFile.writeAsBytes(bytes);
  return tempFile.path;
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
            ElevatedButton(onPressed: () { _copyToClipboard(text);}, child: Icon(Icons.copy),),
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

  @override
  Widget build(BuildContext context) {
    double hght = MediaQuery.of(context).size.height;
    double wid = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(floatingActionButton: FloatingActionButton(onPressed:  () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (result != null) {
                      await openPdf(path: result.paths[0]!);
                      pageIndex = 0;
                      count = await pdf!.getPageCount();
                      await renderPage();
                    }
                  },
                  child:Icon(Icons.upload)),
        body: Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: <Widget>[
                Container(height: hght*0.15,width: wid,decoration: BoxDecoration(borderRadius:BorderRadius.only(bottomLeft: Radius.elliptical(80,30),bottomRight:  Radius.elliptical(80,30)),
                 gradient: LinearGradient(colors: [Colors.deepPurple,Colors.black,],begin: Alignment.topCenter,end: Alignment.bottomCenter)),
                 child: Column(children: [
                  SizedBox(height: 50,),
                     Text('Extract Text ',style: TextStyle(color: Colors.white,fontSize: 25),),
                 ],)),
                  SizedBox(height: 20,),
                if (count != null) Text('The selected PDF has $count pages.'),
                (pdfImage != null)
                    ? Container(margin: EdgeInsets.all(10),
                        child: Image(image: MemoryImage(pdfImage!)),
                      )
                    : Container(
                       
                        margin: EdgeInsets.only(top: 200, bottom: 100),
                        child: Center(child: Text("please upload pdf",style: TextStyle(fontSize: 20),))
                      ),
                if (open)
                  ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextButton.icon(
                          onPressed: (pageIndex > 0)
                              ? () async {
                                  pageIndex -= 1;
                                  await renderPage();
                                }
                              : null,
                          icon: const Icon(Icons.chevron_left),
                          label: const Text('Previous'),
                        ),
                        TextButton.icon(
                          onPressed: (pageIndex < (count! - 1))
                              ? () async {
                                  pageIndex += 1;
                                  await renderPage();
                                }
                              : null,
                          icon: const Icon(Icons.chevron_right),
                          label: const Text('Next'),
                        ),
                      ],
                    ),
                  ], if (pdfImage != null)
                ElevatedButton(
                  onPressed: () async {
                    if (pdfImage != null) {
                      String imagePath = await convertUint8ListToImageFile(pdfImage!);
                      _ocr(imagePath);
                    }
                  },
                  child: Text('Extract Text'),
                ),
                 SizedBox(height: 100,),
                  ElevatedButton(onPressed: (){
       Navigator.push( context,MaterialPageRoute(builder: (context) =>WordSearch(imagetext: _ocrText)),);
    }, child: Text('search')),
    ElevatedButton(onPressed: _getImageFromCamera, child: Text('camera')),
    ElevatedButton(onPressed: _getImageFromGallery, child: Text('gallery')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openPdf({required String path}) async {
    if (pdf != null) {
      await pdf!.close();
    }
    pdf = PdfImageRendererPdf(path: path);
    await pdf!.open();
    setState(() {
      open = true;
    });
  }

  Future<void> renderPage() async {
    size = await pdf!.getPageSize(pageIndex: pageIndex);
    final i = await pdf!.renderPage(
      pageIndex: pageIndex,
      x: cropped ? 100 : 0,
      y: cropped ? 100 : 0,
      width: cropped ? 100 : size!.width,
      height: cropped ? 100 : size!.height,
      scale: 3,
      background: Colors.white,
    );

    setState(() {
      pdfImage = i;
    });
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
    _showResult(_ocrText, "Extracted Text");
    print("hello");
  } catch (e) {
    print("Error during OCR: $e");
  }

  setState(() {
    bload = false;
  });
}
}
