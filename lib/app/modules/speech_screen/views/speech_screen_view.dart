import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_app/widgets/ripple/ripple_animation.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button and start speaking";
  double _confidence = 1.0;
  late final Future<List<stt.LocaleName>> locales;
  String lang = 'en-IN';

  @override
  void initState() {
    super.initState();
    _initSpeechState();
  }

  void _initSpeechState() {
    _speech = stt.SpeechToText();
    locales = _speech.locales();
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
          onPressed: _startListening,
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
      try {
        bool available = await _speech.initialize(
          onStatus: (status) => debugPrint("onStatus: $status"),
          onError: (error) => debugPrint("onError: $error"),
        );

        // If speech initialization was successful, start listening
        if (available) {
          _speech.listen(
            localeId: lang,
            onResult: _onSpeechResult,
          );
          setState(() => _isListening = true);
        }
      } catch (error) {
        debugPrint('Could not initialize speech recognition: $error');
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _text = result.recognizedWords;

      if (result.hasConfidenceRating && result.confidence > 0) {
        _confidence = result.confidence;
      }
    });
  }
}
