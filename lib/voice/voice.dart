import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shimmer/shimmer.dart';

class voice extends StatefulWidget {
  @override
  voiceState createState() => voiceState();
}
 
class voiceState extends State<voice> {

 //speech to text 
  late  stt.SpeechToText speech;
  String textString = "What can I help you with ?";
  bool isListen = false;
  bool isLoading = false;
  //chatgpt api
  final List<Map<String ,String>> messages=[];
  String assistantresponse ="";
 //language detect
  String detectedLanguage = "";
 
 
  //openai api se data liya
 //final openaiService service =  openaiService();
  Future <String> chatGPTAPI(String prompt) async {
    messages.add({'role': 'user','content': prompt});
     try{
      final res =await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {"Content-Type" : " application/json",
        "Authorization": "Bearer $aikey"},
        body:jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages}));
        print(res.body);
        if (res.statusCode==200){
          String content = jsonDecode(res.body)['choices'][0]['message']['content'];
          content = content.trim();
          messages.add({'role':'assistant','content':content});

          setState(() {
            assistantresponse =content;
          });
          return content;
        }
        return "";
    }catch(e){
      return e.toString();
    }
  }


//language detect and translate
  void check() async{
    //language detection
    final lang = LanguageIdentifier(confidenceThreshold: 0.5);
    final String resp =await lang.identifyLanguage(textString);
    final List<IdentifiedLanguage> possibleLanguages = await lang.identifyPossibleLanguages(textString);
    if (possibleLanguages.isNotEmpty) {
      setState(() {
        detectedLanguage = possibleLanguages[0].languageTag;
      });
    } else {
      setState(() {
        detectedLanguage = "Language not identified.";
      });
    }
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.setLanguage(detectedLanguage);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(assistantresponse);
 }



//speech to text method
  void listen() async {
    if (!isListen) {
     // messages.clear();
      bool avail = await speech.initialize();
      if (avail) {
        setState(() {
          isListen = true;
        });
        speech.listen(onResult: (value) {
          setState(() {
            textString = value.recognizedWords;
          });
        });
      }
    } else {
      setState(() {
        isListen = false;
        isLoading = true;
      });
      await chatGPTAPI(textString);
      check();       //language check and translate krega
      speech.stop(); //voice ko stop krega
      setState(() {
        isLoading = false; //  API call is complete
      });
    }
    
  }

    loading(){
      if(assistantresponse==""){
        return SizedBox(height: 10,); 
      }
      else{
           return Align(alignment: Alignment.topLeft,child:Container(margin:EdgeInsets.only(top: 30,right: 50,left:20),padding: EdgeInsets.all(20)
           ,decoration: BoxDecoration(color: Colors.white,//gradient:LinearGradient(colors: [Colors.grey, Colors.white]),
            borderRadius: BorderRadius.circular(30).copyWith(bottomLeft: Radius.circular(0))),
            child: Text(assistantresponse,style: TextStyle(fontSize: 15.0,color: Colors.black),),) ,);
      }
    }

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }
  @override
  Widget build(BuildContext context) {
    double hght = MediaQuery.of(context).size.height;
    double wid = MediaQuery.of(context).size.width;
    return Scaffold(

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListen,
        glowColor: Colors.deepPurple,
        glowRadiusFactor: 0.7,// glowShape: BoxShape.circle,
        duration: Duration(milliseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          child: Icon(isListen ? Icons.mic : Icons.mic_none),
          onPressed: () {
            listen();},),),
         //,leading: IconButton(onPressed: (){}, icon:Icon(Icons.menu))
      appBar: AppBar(
        title: Text("VOICE ASSISSTANT"),backgroundColor: Color.fromARGB(255, 191, 219, 243),foregroundColor: Colors.black,centerTitle:true),
      //drawer: Drawer(child: SingleChildScrollView(scrollDirection: Axis.vertical,child: drawer(),),),

      body: Container(height: hght,width: wid,decoration: BoxDecoration(
           gradient:LinearGradient(colors: [Color.fromARGB(255, 191, 219, 243), Color.fromARGB(255, 188, 196, 202)],begin: Alignment.topCenter,end: Alignment.bottomCenter) ),
      child: SingleChildScrollView(child:Column(
      children: [
        SizedBox(height: 25,child:Text('Press The Button',style: TextStyle(color:Colors.grey ,fontSize: 20),),),
        Align(alignment: Alignment.topRight,child:
        Container(margin:EdgeInsets.only(top: 30,left:wid*0.1,right: 20),padding: EdgeInsets.all(20),
                     decoration: BoxDecoration(gradient:LinearGradient(colors: [Colors.blueAccent, Colors.deepPurple]),
                     borderRadius: BorderRadius.circular(30).copyWith(bottomRight:Radius.circular(0))),
                     child: Text(textString,style: TextStyle(fontSize: 20.0,color: Colors.white),),),),
        isLoading?
           Container(width: 150, height:100.0,margin:EdgeInsets.only(top: 200,bottom :100),
            child: Shimmer.fromColors(baseColor: Colors.white,highlightColor: Colors.deepPurple,
             child: Text('Please Wait.....',style: TextStyle(fontSize: 20),),),)
             :loading(),  
        ],
      ),),),
    );
  }
}