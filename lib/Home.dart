import 'package:flutter/material.dart';
import 'package:flutter_langdetect/language.dart';
import 'package:textualtune/experiment/exp.dart';
import 'package:textualtune/pdf/chatbot.dart';
import 'package:textualtune/pdf/languagechange.dart';
import 'package:textualtune/pdf/rendertext.dart';
import 'package:textualtune/pdf/search.dart';
import 'package:textualtune/pdf/search2.dart';
import 'package:textualtune/pdf/viewpdf.dart';
import 'package:textualtune/voice/voice.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    double hght = MediaQuery.of(context).size.height;
    double wid = MediaQuery.of(context).size.width;
    return Scaffold(
    body: Container(margin: EdgeInsets.all(30),child: SingleChildScrollView(scrollDirection:Axis.vertical,child:Column(children: [
      Container(height: 100,width: wid,child: Image.asset('assets/images/appbar.png'),),
      SizedBox(height: 20,),
      SizedBox(child: Text('Quick Help',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),),
      SizedBox(height: 20,),
      Row(children: [
            Icon(Icons.mic),
             SizedBox(width: 4,),
            SizedBox(child: Text('Voice Assisstant'),),
            SizedBox(width: 50,),
            Container(height: 50,width: 80,child: ElevatedButton(onPressed: (){
               Navigator.push( context,MaterialPageRoute(builder: (context) => voice()),);
            }, child: Icon(Icons.arrow_forward,),),),
            ],),
      SizedBox(height: 40,),
      SizedBox(child: Text('PDF',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),),
      SizedBox(height: 20,child: Text('Here are some things you can do',style: TextStyle(color: Colors.grey),),),
      GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2, // Number of columns
      crossAxisSpacing: 40.0,
      mainAxisSpacing: 40.0,
      children: <Widget>[
        _buildIconButtonWithLabel(Icons.document_scanner, 'Scan PDF', () {
           Navigator.push( context,MaterialPageRoute(builder: (context) =>PdfToImageAndOCR()),);
        }),
        _buildIconButtonWithLabel(Icons.picture_as_pdf, 'View PDF', () {
            Navigator.push( context,MaterialPageRoute(builder: (context) => viewpdf()),);
        }),
        _buildIconButtonWithLabel(Icons.text_format, 'Text Engine', () {
            Navigator.push( context,MaterialPageRoute(builder: (context) => ChatScreen()),);
        }),
        _buildIconButtonWithLabel(Icons.language, ' Translator', () {
           Navigator.push( context,MaterialPageRoute(builder: (context) =>PickPdf2()),);
        }),
      
      ],
    ),
  
    ],)),));
  }
}

Widget _buildIconButtonWithLabel(IconData iconData, String label, Function onPressed) {
  return Container(
    decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.deepPurple,Colors.black],begin: Alignment.topCenter,end: Alignment.bottomCenter),
      //color: Colors.white, // Background color of the grid item
      border: Border.all(color: Colors.grey), // Border color of the grid item
      borderRadius: BorderRadius.circular(8.0), // Optional: Apply border radius
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(iconData),
          onPressed: onPressed as void Function()?,
          color: Colors.white, // Color of the icon
        ),
        SizedBox(height: 5.0),
        Text(
          label,
          style: TextStyle(
            color: Colors.white, // Color of the label text
          ),
        ),
      ],
    ),
  );
}


