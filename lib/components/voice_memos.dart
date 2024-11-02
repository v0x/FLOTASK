import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceMemo extends StatefulWidget {
  const VoiceMemo({super.key});

  @override
  State<VoiceMemo> createState() => _VoiceMemoState();
}

class _VoiceMemoState extends State<VoiceMemo> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _showTextField = false;
  TextEditingController speech = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    setState(() => _showTextField = true);
    speech.text = speech.text.trim();
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 3),
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      setState(() {
        speech.text = speech.text.trim() + ' ' + result.recognizedWords;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (_showTextField) ...[
              Expanded(
                child: TextField(
                  controller: speech,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Speak or type your note...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => speech.clear()),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (speech.text.isNotEmpty) ...[
              IconButton(
                onPressed: () =>
                    setState(() => _showTextField = !_showTextField),
                tooltip: _showTextField ? 'Hide text' : 'Edit text',
                icon: Icon(_showTextField ? Icons.edit_off : Icons.edit),
              ),
            ],
            IconButton(
              onPressed: _speechEnabled
                  ? (_speechToText.isNotListening
                      ? _startListening
                      : _stopListening)
                  : null,
              tooltip: 'Record voice',
              icon: Icon(
                  _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            ),
          ],
        ),
      ),
    );
  }
}
