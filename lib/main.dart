import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat GPT3',
      theme: ThemeData(
        brightness: Brightness.dark,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const Chat_home(),
    );
  }
}

class Chat_home extends StatefulWidget {
  const Chat_home({Key? key}) : super(key: key);

  @override
  State<Chat_home> createState() => _Chat_homeState();
}

const backgroundColor = Color(0xff343541);
const userBackgroundColor = Color(0xffe0e0e2);

const botBackgroundColor = Color(0xff444654);

Future<String> generateResponse(String prompt) async {
  // const apiKey = apiSecretKey;

  var url = Uri.https("api.openai.com", "/v1/completions");
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      "Authorization":
    },
    body: json.encode({
      "model": "text-davinci-003",
      "prompt":
          "pretend you are jesus christ from new international version bible.$prompt",
      'temperature': 0.8,
      'max_tokens': 1000,
      'top_p': 1,
      'frequency_penalty': 0.2,
      'presence_penalty': 0.0,
    }),
  );
  print(response.body);

// Do something with the response
  Map<String, dynamic> newresponse = jsonDecode(response.body);

  return newresponse['choices'][0]['text'];
}

class _Chat_homeState extends State<Chat_home> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
    _initSpeech();

  }
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {
    });
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    print('STARTING');

    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      print('STARTING');

      // _speechToText.isListening
      //     ? '$_lastWords'
      // // If listening isn't active but could be tell the user
      // // how to start it, otherwise indicate that speech
      // // recognition is not yet ready or not supported on
      // // the target device
      //     : _speechEnabled
      //     ? 'Tap the microphone to start listening...'
      //     : 'Speech not available',
    });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    print('STOP');
    await _speechToText.stop();
    setState(() {
      print('STOP');

    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      print(_lastWords);
      _textController.text=result.recognizedWords;

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What would Jesus say'),
        centerTitle: true,
        //toolbarHeight: 100,
        backgroundColor: botBackgroundColor,
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildList(),
                Visibility(
                    visible: isLoading,
                    child: CardSkeleton(
                      isCircularImage: true,
                      isBottomLinesActive: false,
                    ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _buildInput(),
                _buildSubmit(),
                _microphone(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _microphone() {
    return Visibility(
      child: Container(
        color: botBackgroundColor,
        child: IconButton(
          icon:  Icon(_speechToText.isNotListening ? Icons.mic : Icons.mic_off,
              color: Colors.white //Color.fromRGBO(142, 142, 160, 1),
              ),
          onPressed: ()  {
            _speechToText.isNotListening ? _startListening : _stopListening;

          },
        ),
      ),
    );
  }


  Widget _buildSubmit() {
    return Visibility(
      visible: !isLoading,
      child: Container(
        color: botBackgroundColor,
        child: IconButton(
          icon: const Icon(
            Icons.send_rounded,
            color: Colors.white, //Color.fromRGBO(142, 142, 160, 1),
          ),
          onPressed: () async {
            setState(
              () {
                _messages.add(
                  ChatMessage(
                    text: _textController.text,
                    chatMessageType: ChatMessageType.user,
                  ),
                );
                isLoading = true;
              },
            );
            var input = _textController.text;
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
                .then((_) => _scrollDown());
            generateResponse(input).then((value) {
              setState(() {
                isLoading = false;
                _messages.add(
                  ChatMessage(
                    text: value,
                    chatMessageType: ChatMessageType.bot,
                  ),
                );
              });
            });
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
                .then((_) => _scrollDown());
          },
        ),
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        decoration: const InputDecoration(
          fillColor: botBackgroundColor,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      },
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class ChatMessageWidget extends StatefulWidget {
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  final String text;
  final ChatMessageType chatMessageType;

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  FlutterTts ftts = FlutterTts();
  bool isplaying=false;

  play_text(String text) async {
    await ftts.setLanguage("en-US");
    await ftts.setSpeechRate(0.4); //speed of speech
    await ftts.setVolume(100.0); //volume of speech
    await ftts.setPitch(1);
    //ftts.awaitSpeakCompletion(true);//pitc of sound
    //play text to sp
    var result = await ftts.speak(text).whenComplete((){
      setState(() {
        //speaking
        isplaying=false;
      });
    });
    if (result == 1) {
      setState(() {
        //speaking
        isplaying=true;
      });
    } else {
      setState(() {
        isplaying=false;
      });
      //not speaking
    }
  }
  pause_text(){

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width:double.infinity, //MediaQuery.of(context).size.width / 2,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: widget.chatMessageType == ChatMessageType.bot
              ? botBackgroundColor
              : userBackgroundColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: widget.chatMessageType == ChatMessageType.bot
          //     ? MainAxisAlignment.start
          //     : MainAxisAlignment.end,
          children: <Widget>[
            if (widget.chatMessageType == ChatMessageType.bot)
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: const CircleAvatar(
                  backgroundColor: Color.fromRGBO(16, 163, 127, 1),
                  child: Icon(
                    Icons.android,
                    color: Colors.white,
                  ),
                ),
              ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Align(
                  alignment: widget.chatMessageType == ChatMessageType.bot? Alignment.centerLeft:Alignment.centerRight,
                  child: Text(
                    widget.text,
                    textAlign: widget.chatMessageType == ChatMessageType.bot?TextAlign.start:TextAlign.end,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: widget.chatMessageType == ChatMessageType.bot
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
            ),
            if (widget.chatMessageType != ChatMessageType.bot)
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: const CircleAvatar(
                  child: Icon(
                    Icons.person,
                  ),
                ),
              )
            else
                  _playButton(widget.text),
          ],
        ),
      ),
    );
  }
  Widget _playButton(String string_to_play) {
    return Visibility(
      visible: !isplaying,
      replacement: Container(
        //color: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.pause,
              size: 40,
              color: Colors.white //Color.fromRGBO(142, 142, 160, 1),

          ),
          onPressed: () async {
            ftts.pause();
            setState(() {
              isplaying=false;
            });
          },
        ),
      ),
      child: Container(
       // color: Colors.white,
        child: IconButton(
          icon: const Icon(Icons.play_circle,
              size: 40,
              color: Colors.white //Color.fromRGBO(142, 142, 160, 1),

          ),
          onPressed: () async {
            setState(() {
              isplaying=true;
            });
            await play_text(string_to_play).whenComplete((){
              setState(() {
                //speaking
                //isplaying=false;
              });
            });

          },
        ),
      ),
    );
  }

}
