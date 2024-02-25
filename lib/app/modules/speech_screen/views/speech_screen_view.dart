import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_app/app/data/api/service/api_service.dart';
import 'package:voice_app/app/data/model/katakana_request_model.dart';
import 'package:voice_app/widgets/ripple/ripple_animation.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  ApiService api = Get.find();
  final stt.SpeechToText _speech = stt.SpeechToText();
  late final Future<List<stt.LocaleName>> locales;
  bool _isListening = false;
  double _confidence = 1.0;
  String lang = 'en-IN';
  String _text = "Press the button and start speaking";

  @override
  void initState() {
    super.initState();
    _initSpeechState();
  }

  void _initSpeechState() async {
    await _speech.initialize(
      onStatus: (status) => debugPrint("onStatus: $status"),
      onError: (error) => debugPrint(
          "onError: Could not initialize speech recognition: $error"),
    );
    locales = _speech.locales();
  }

  getkatakanaText(String text) {
    KatakanaRequestModel requestModel = getRequestModel(text);
    api.getKatakanaText(requestModel: requestModel).then((res) {
      setState(() {
        _text = res.converted;
      });
      debugPrint("After conversion: ${res.converted}");
    });
  }

  KatakanaRequestModel getRequestModel(String text) {
    return KatakanaRequestModel(sentence: text, outputType: "katakana");
  }

  final Map<String, HighlightedWord> _words = {
    "Test": HighlightedWord(
      onTap: () {
        debugPrint("Test");
      },
      textStyle: TextStyle(
          color: Colors.blue.shade200,
          fontWeight: FontWeight.bold,
          fontSize: 32),
    ),
    "Indigital": HighlightedWord(
      onTap: () {
        debugPrint("Indigital");
      },
      textStyle: TextStyle(
          color: Colors.purple.shade200,
          fontWeight: FontWeight.bold,
          fontSize: 32),
    ),
    "Company": HighlightedWord(
      onTap: () {
        debugPrint("Company");
      },
      textStyle: TextStyle(
          color: Colors.green.shade200,
          fontWeight: FontWeight.bold,
          fontSize: 32),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: RippleAnimation(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        child: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          onPressed: _startListening,
          tooltip: 'Listen',
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 150),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextHighlight(
              text: _text,
              words: _words,
              textStyle: const TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            const Text('Lang :'),
            DropdownButton(
              isExpanded: true,
              value: lang,
              items: ['en-IN', 'ja-JP', 'en-US']
                  .map(
                    (String lang) => DropdownMenuItem(
                      value: lang,
                      child: Text(lang),
                    ),
                  )
                  .toList(),
              onChanged: (String? language) {
                if (language != null) {
                  setState(() => lang = language);
                }
              },
            ),
          ]),
        ),
      ),
    );
  }

  void _startListening() async {
    if (!_isListening) {
      await _speech.listen(
          localeId: lang,
          onResult: _onSpeechResult,
          listenOptions: stt.SpeechListenOptions(
              cancelOnError: true,
              autoPunctuation: true,
              listenMode: stt.ListenMode.dictation,
              onDevice: true));
      setState(() => _isListening = true);
    } else {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.recognizedWords != "") {
      getkatakanaText(result.recognizedWords);
    }
    setState(() {
      if (result.hasConfidenceRating && result.confidence > 0) {
        _confidence = result.confidence;
      }
    });
  }
}
