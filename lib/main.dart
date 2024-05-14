import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AudioPlayer audioPlayer = AudioPlayer();
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  stt.SpeechToText _speech = stt.SpeechToText();
  late String _tempPath;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _initialize() async {
    // Request microphone permissions
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Microphone permission not granted");
    }

    // Initialize the recorder
    await _recorder.openRecorder();

    // Prepare temporary file path
    Directory tempDir = await getTemporaryDirectory();
    _tempPath = '${tempDir.path}/temp.wav';
  }

  Future<void> playAudio(Source audioPath) async {
    final result = await audioPlayer.play(audioPath);
  }

  Future<void> startRecording() async {
    if (!_recorder.isRecording) {
      await _recorder.startRecorder(
        toFile: _tempPath,
        codec: Codec.pcm16WAV,
      );
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> stopRecording() async {
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      comparePronunciation(_tempPath);
    }
  }

  Future<void> comparePronunciation(String filePath) async {
    File audioFile = File(filePath);
    List<int> audioBytes = audioFile.readAsBytesSync();
    String audioBase64 = base64Encode(audioBytes);

    var request = {
      'config': {
        'encoding': 'LINEAR16',
        'sampleRateHertz': 16000,
        'languageCode': 'en-US',
      },
      'audio': {
        'content': audioBase64,
      },
    };

    var response = await http.post(
      Uri.parse(
          'https://speech.googleapis.com/v1/speech:recognize?key=AIzaSyBT_oqU1eZE7MDGuJpsnAOH1Z8ewQ1wslo'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['results'] != null &&
          jsonResponse['results'].isNotEmpty) {
        String recognizedText =
            jsonResponse['results'][0]['alternatives'][0]['transcript'];
        print('Recognized Text: $recognizedText');
        // Implement your own comparison logic here
      } else {
        print('No speech recognized');
      }
    } else {
      print('Error: ${response.statusCode} ${response.reasonPhrase}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Non-Word Repetition Task'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => playAudio(AssetSource('sibad.wav')),
                child: Text('Play Correct Pronunciation'),
              ),
              ElevatedButton(
                onPressed: _isRecording ? stopRecording : startRecording,
                child:
                    Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
