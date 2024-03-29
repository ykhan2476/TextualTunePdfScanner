import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class PdfToImage extends StatefulWidget {
  const PdfToImage({Key? key}) : super(key: key);

  @override
  State<PdfToImage> createState() => _PdfToImageState();
}

class _PdfToImageState extends State<PdfToImage> {
  int pageIndex = 0;
  Uint8List? image;
  bool open = false;
  PdfImageRendererPdf? pdf;
  int? count;
  PdfImageRendererPageSize? size;
  bool cropped = false;
  int asyncTasks = 0;

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
      image = i;
    });
    
    
  }

  Future<void> renderPageMultipleTimes() async {
    const count = 50;
    await pdf!.openPage(pageIndex: pageIndex);
    size = await pdf!.getPageSize(pageIndex: pageIndex);
    asyncTasks = count;
    final renderFutures = <Future<Uint8List?>>[];
    for (var i = 0; i < count; i++) {
      final future = pdf!.renderPage(
        pageIndex: pageIndex,
        x: (size!.width / count * i).round(),
        y: (size!.height / count * i).round(),
        width: (size!.width / count).round(),
        height: (size!.height / count).round(),
        scale: 3,
        background: Colors.white,
      );
      renderFutures.add(future);
      future.then((value) {
        setState(() {
          asyncTasks--;
        });
      });
    }
    await Future.wait(renderFutures);
    await pdf!.closePage(pageIndex: pageIndex);
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

  Future<void> closePdf() async {
    if (pdf != null) {
      await pdf!.close();
      setState(() {
        pdf = null;
        open = false;
      });
    }
  }

  Future<void> openPdfPage({required int pageIndex}) async {
    await pdf!.openPage(pageIndex: pageIndex);
  }

  @override
  Widget build(BuildContext context) {
     double hght = MediaQuery.of(context).size.height;
    double wid = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
        title: Text("Identified Languages"),backgroundColor: Colors.black,foregroundColor: Colors.white,centerTitle:true),
        //drawer: Drawer(child: SingleChildScrollView(scrollDirection: Axis.vertical,child: drawer(),),),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
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
          },tooltip: 'Pick PDF',child: Icon(Icons.file_upload),
        ),
        body: Container(height: hght,width: wid,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.deepPurple],
                    begin: Alignment.topCenter,end: Alignment.bottomCenter,),),child: SingleChildScrollView( scrollDirection: Axis.vertical,
    child: Column(
      children: <Widget>[
        if (count != null) Text('The selected PDF has $count pages.',style: TextStyle(color: Colors.white),),
        (image != null)? 
           Container(margin: EdgeInsets.all(30),child: Image(image: MemoryImage(image!)),):
           Container(width: 150, height:100.0,margin:EdgeInsets.only(top: 200,bottom :100),
            child: Shimmer.fromColors(baseColor: Colors.white,highlightColor: Colors.deepPurple,
             child: Text('Please Wait.....',style: TextStyle(fontSize: 20),),),)
           ,
        if (open) ...[
          Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
              TextButton.icon(
                onPressed: pageIndex > 0
                    ? () async {pageIndex -= 1;await renderPage();}
                    : null,
                icon: const Icon(Icons.chevron_left,color: Colors.white),
                label: const Text('Previous',style: TextStyle(color: Colors.white)),),
              TextButton.icon(
                onPressed: pageIndex < (count! - 1)
                    ? () async {pageIndex += 1;await renderPage();}
                    : null,
                icon: const Icon(Icons.chevron_right,color: Colors.white),
                label: const Text('Next',style: TextStyle(color: Colors.white),),),
            ],
          ),
        ],
        SizedBox(height: 20,),
        SizedBox(width: 20,),
        ElevatedButton(onPressed: (){}, child: Text('EXTRACT TEXT')),
      if(image!=null)Container(margin: EdgeInsets.all(30),
      child: Text("English : do you still practise? , she is lucky \n.Hindi :आप कैसे है? ,क्या आपने केक खाया?\nTelugu: నువ్వు కేక్ తిన్నావా, ఆమె అదృష్టవంతురాలు \nUrdu:  یاشا ہیلو آپ کیسے ہیں,ی کیلا ,  کیا آپ کیلا کھانا چاہتے ہیں؟"
      ,style: TextStyle(color: Colors.white)),),
       SizedBox(height: 60,),
      ],
    ),
  ),
)
,),);}
}
