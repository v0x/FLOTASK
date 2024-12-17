import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flotask/models/event_provider.dart';
import 'package:provider/provider.dart';
import 'package:flotask/models/event_model.dart';

class VoiceMemo extends StatefulWidget {
  final EventModel? event;
  final Function(String)? onTextChanged;

  const VoiceMemo({
    super.key,
    this.event,
    this.onTextChanged,
  });

  @override
  State<VoiceMemo> createState() => _VoiceMemoState();
}

class _VoiceMemoState extends State<VoiceMemo> {
  late TextEditingController speech;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _showTextField = false;

  @override
  void initState() {
    super.initState();
    speech = TextEditingController();
    if (widget.event != null) {
      speech.text = widget.event?.voiceMemos ?? '';
    }
    _showTextField = speech.text.isEmpty;
    _initSpeech();
  }

  // Initialize speech to text
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  // Start listening to speech
  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      partialResults: true,
    );
    setState(() {});
  }

  // Stop listening to speech
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  String _formatDateTime(DateTime now) {
    final date = "${now.day}/${now.month}/${now.year}";
    final hour =
        now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    final time =
        "${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $amPm";
    return "$date $time";
  }

  // Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      final timestamp = _formatDateTime(DateTime.now());
      setState(() {
        if (speech.text.isNotEmpty) {
          speech.text = "${speech.text}\n$timestamp: ${result.recognizedWords}";
        } else {
          speech.text = "$timestamp: ${result.recognizedWords}";
        }
        widget.onTextChanged?.call(speech.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        children: [
          if (_showTextField) ...[
            Expanded(
              child: TextField(
                controller: speech,
                maxLines: null,
                onChanged: widget.onTextChanged,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  hintText: 'Speak or type your note...',
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ] else if (speech.text.isNotEmpty) ...[
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _showTextField = true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    speech.text,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: TextField(
                controller: speech,
                maxLines: null,
                onChanged: widget.onTextChanged,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  hintText: 'Speak or type your note...',
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
          const SizedBox(width: 12),
          if (speech.text.isNotEmpty && widget.event != null) ...[
            IconButton(
              onPressed: () {
                context
                    .read<EventProvider>()
                    .saveMemo(widget.event!.id!, speech.text);
                setState(() => _showTextField = false);
              },
              tooltip: 'Save memo',
              icon: const Icon(Icons.save),
            ),
          ],
          if (!_showTextField && speech.text.isNotEmpty) ...[
            IconButton(
              onPressed: () => setState(() => _showTextField = true),
              tooltip: 'Edit memo',
              icon: const Icon(Icons.edit),
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
              _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
              color: _speechToText.isListening
                  ? Theme.of(context).primaryColor
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    speech.dispose();
    super.dispose();
  }
}
