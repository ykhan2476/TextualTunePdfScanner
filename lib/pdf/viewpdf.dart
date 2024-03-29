import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class viewpdf extends StatefulWidget {
  const viewpdf({Key? key}) : super(key: key);

  @override
  State<viewpdf> createState() => _viewpdfState();
}

class _viewpdfState extends State<viewpdf> {
    GlobalKey<ScaffoldState> scaffState = GlobalKey<ScaffoldState>();
  String _pdfPath = "";
  
  void pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _pdfPath = result.files.single.path!;
      });
     }
  }


  @override
  Widget build(BuildContext context) {
    double hght = MediaQuery.of(context).size.height;
    double wid = MediaQuery.of(context).size.width;
    return Scaffold(
      //key: scaffState,
     // drawer: Drawer(child: SingleChildScrollView(scrollDirection: Axis.vertical,child: drawer(),),),
      body: Container(height: hght,width: wid,child:SingleChildScrollView(scrollDirection: Axis.vertical,child:Column(children: [
        Container(height: hght*0.15,width: wid,decoration: BoxDecoration(borderRadius:BorderRadius.only(bottomLeft: Radius.elliptical(80,30),bottomRight:  Radius.elliptical(80,30)),
                 gradient: LinearGradient(colors: [Colors.deepPurple,Colors.black,],begin: Alignment.topCenter,end: Alignment.bottomCenter)),
                 child: Column(children: [
                  SizedBox(height: 50,),
                     Text('View PDF ',style: TextStyle(color: Colors.white,fontSize: 25),),
                 ],)),
        SizedBox(height: 25,),
            Container(child:
            _pdfPath.isNotEmpty
          ? Container(
                    height: 300,
                    child:PDFView(
                      filePath: _pdfPath,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: false,
                      pageSnap: true,
                      pageFling: false,
                      onRender: (pages) {
                        // PDF document is rendered
                      },
                      onError: (error) {
                        // Error occurred
                      },
                    ),
                  )
          : Center(
              child: Text('No PDF selected',style: TextStyle(color: Colors.black),),
            )
       ,height: hght,width: wid,
      ),
      SizedBox(height: 100,),
      ],), 
    
      ),),
      floatingActionButton: FloatingActionButton(
        onPressed: pickFiles,
        tooltip: 'Pick PDF',
        child: Icon(Icons.file_upload),
      ),
    );
  }
}