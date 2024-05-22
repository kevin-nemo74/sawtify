import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Non-Word Repetition Task',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _audioPath = 'audio/fim.wav'; // Corrected audio file path
  final String _audioPath2 =
      'assets/audio/fim.wav'; // Corrected audio file path

  final AudioPlayer _audioPlayer = AudioPlayer();
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecording = false;
  File? _recordedFile;

  @override
  void initState() {
    super.initState();
    _audioRecorder = FlutterSoundRecorder();
    _openRecorder();
  }

  Future<void> _openRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException("Microphone permission not granted");
    }
    await _audioRecorder!.openRecorder();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder!.closeRecorder();
    super.dispose();
  }

  void _playAudio() async {
    await _audioPlayer.play(
      AssetSource(_audioPath),
    );
  }

  void _record() async {
    Directory tempDir = await getTemporaryDirectory();
    String filePath = '${tempDir.path}/recorded.wav';
    if (_isRecording) {
      await _audioRecorder!.stopRecorder();
      setState(() {
        _isRecording = false;
        _recordedFile = File(filePath);
      });
    } else {
      await _audioRecorder!.startRecorder(toFile: filePath);
      setState(() {
        _isRecording = true;
      });
      // Stop recording after 1 second
      Future.delayed(Duration(seconds: 2), () async {
        if (_isRecording) {
          await _audioRecorder!.stopRecorder();
          setState(() {
            _isRecording = false;
            _recordedFile = File(filePath);
          });
        }
      });
    }
  }

  Future<double> _compareAudio(File userAudio, File targetAudio) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('https://sawtify-7esi5utsqq-uc.a.run.app/compare'));
    request.files
        .add(await http.MultipartFile.fromPath('user_audio', userAudio.path));
    request.files.add(
        await http.MultipartFile.fromPath('target_audio', targetAudio.path));

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);

    try {
      var result = jsonDecode(responseString);
      print(result);
      return result['distance'];
    } catch (e) {
      print('Error parsing response: $e');
      print('Response was: $responseString');
      throw Exception('Failed to parse server response');
    }
  }

  void _onCompare() async {
    if (_recordedFile != null) {
      // Use the correct path for the asset
      Directory tempDir = await getTemporaryDirectory();
      String targetAudioPath = '${tempDir.path}/sibad.wav';

      // Copy the asset to a temporary location
      ByteData data = await rootBundle.load(_audioPath2);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(targetAudioPath).writeAsBytes(bytes);

      File targetAudio = File(targetAudioPath);
      double distance = await _compareAudio(_recordedFile!, targetAudio);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Comparison Result"),
            content: Text("Phonetic distance: $distance"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      // Handle case where no recording is available
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(
                "No recording available. Please record your pronunciation first."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Non-Word Repetition Task"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AudioPlayerWidget(
                audioPath: AssetSource(_audioPath), audioPlayer: _audioPlayer),
            SizedBox(height: 20),
            AudioRecorderWidget(
              isRecording: _isRecording,
              onRecord: _record,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onCompare,
              child: Text("Compare Pronunciation"),
            ),
          ],
        ),
      ),
    );
  }
}

class AudioPlayerWidget extends StatelessWidget {
  final Source audioPath;
  final AudioPlayer audioPlayer;

  AudioPlayerWidget({required this.audioPath, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.play_arrow),
      onPressed: () async {
        await audioPlayer.play(audioPath);
      },
    );
  }
}

class AudioRecorderWidget extends StatelessWidget {
  final bool isRecording;
  final Function onRecord;

  AudioRecorderWidget({required this.isRecording, required this.onRecord});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isRecording ? Icons.stop : Icons.mic),
      onPressed: () => onRecord(),
    );
  }
}
