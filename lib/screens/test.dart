import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int? _currentPlayingIndex;
  Set<int> _playedIndices = {};
  Set<int> _recordedIndices = {};
  late Timer _stopRecordingTimer;
  bool _isRecording = false;
  late AnimationController _animationController;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  List<bool> _isRecordingList = List.generate(28, (index) => false);

  // Store comparison results
  List<bool> _comparisonResults = List.generate(28, (index) => false);

  @override
  void initState() {
    super.initState();
    _recorder.openRecorder();
    _requestPermissions();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<String> _getFilePath(String assetPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/${assetPath.split('/').last}');

    if (!(await file.exists())) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer.asUint8List());
    }
    return file.path;
  }

  Future<String> _getRecordedFilePath(int index) async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/audio_example_$index.wav';
  }

  void _playAudio(String assetPath, int index) async {
    if (_playedIndices.contains(index)) {
      return;
    }

    if (_isPlaying && _currentPlayingIndex != index) {
      await _audioPlayer.stop();
    }

    String filePath = await _getFilePath(assetPath);
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.play(DeviceFileSource(filePath));
      setState(() {
        _isPlaying = true;
        _currentPlayingIndex = index;
        _playedIndices.add(index);
      });
    }
  }

  void _startRecording(int index) async {
    if (await Permission.microphone.request().isGranted) {
      if (!_isRecordingList[index]) {
        try {
          String filePath = await _getRecordedFilePath(index);
          await _recorder.startRecorder(toFile: filePath);
          setState(() {
            _isRecordingList[index] = true;
            _isRecording = true;
          });

          _stopRecordingTimer = Timer(Duration(seconds: 2), () {
            _stopRecording(index);
          });
        } catch (e) {
          print('Error starting recording: $e');
        }
      }
    }
  }

  void _stopRecording(int index) async {
    if (_isRecordingList[index]) {
      try {
        await _recorder.stopRecorder();
        setState(() {
          _isRecordingList[index] = false;
          _isRecording = false;
          _recordedIndices.add(index);
        });
        _compareAudioAndStoreResult(index);
      } catch (e) {
        print('Error stopping recording: $e');
      }
    }
  }

  Future<void> _compareAudioAndStoreResult(int index) async {
    try {
      String recordedFilePath = await _getRecordedFilePath(index);
      String targetAudioPath =
          await _getFilePath('assets/audios/audio${index + 1}.wav');

      File recordedFile = File(recordedFilePath);
      if (await recordedFile.exists()) {
        File targetAudio = File(targetAudioPath);
        double distance = await _compareAudio(recordedFile, targetAudio);
        setState(() {
          _comparisonResults[index] = distance < 0.5;
        });
      } else {
        throw Exception('Recorded file does not exist');
      }
    } catch (e) {
      print('Error during comparison: $e');
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

  void _calculateAndShowResults() {
    int correctCount = _comparisonResults.where((result) => result).length;
    double percentage = (correctCount / 28) * 100;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Test Results"),
          content: Text(
              "You got $correctCount out of 28 correct.\nPercentage: ${percentage.toStringAsFixed(2)}%"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Text(
              'Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 50, 50, 50),
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.grey.withOpacity(0.3),
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: _isPlaying ? ((_currentPlayingIndex! + 1) / 28) : 0.1,
                  minHeight: 10,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color.fromARGB(80, 1, 51, 200),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                height: 350,
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: 28,
                    itemBuilder: (context, index) {
                      List<String> audioFiles = List.generate(
                          28, (index) => 'assets/audios/audio${index + 1}.wav');
                      String audioFilePath = audioFiles[index];

                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Container(
                              width: 250,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                elevation: 8.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color(0xFF8EAEF1).withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF8EAEF1),
                                        Color(0xFFE4E7F6),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: 10),
                                        Text(
                                          (index == 0 ||
                                                  index == 11 ||
                                                  index == 21)
                                              ? 'Practice'
                                              : 'Test',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Image(
                                          width: 150,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                            (index == 0 ||
                                                    index == 11 ||
                                                    index == 21)
                                                ? 'assets/Avatar/ph.png'
                                                : 'assets/Avatar/phh.png',
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: ShaderMask(
                                                shaderCallback: (Rect bounds) {
                                                  return LinearGradient(
                                                    colors: [
                                                      Colors.white,
                                                      Color.fromARGB(
                                                          210, 128, 54, 174),
                                                    ],
                                                  ).createShader(bounds);
                                                },
                                                child: Icon(
                                                  _playedIndices.contains(index)
                                                      ? Icons.block
                                                      : (_currentPlayingIndex ==
                                                                  index &&
                                                              _isPlaying
                                                          ? Icons.pause
                                                          : Icons.play_arrow),
                                                ),
                                              ),
                                              onPressed:
                                                  _playedIndices.contains(index)
                                                      ? null
                                                      : () => _playAudio(
                                                          audioFilePath, index),
                                              iconSize: 50,
                                              color: Colors.white,
                                            ),
                                            GestureDetector(
                                              onTapDown: (_) =>
                                                  _startRecording(index),
                                              onTapUp: (_) =>
                                                  _stopRecording(index),
                                              child: ScaleTransition(
                                                scale:
                                                    Tween(begin: 1.0, end: 1.2)
                                                        .animate(
                                                  CurvedAnimation(
                                                    parent:
                                                        _animationController,
                                                    curve: Curves.easeInOut,
                                                  ),
                                                ),
                                                child: _recordedIndices
                                                        .contains(index)
                                                    ? Icon(
                                                        Icons.block,
                                                        color: Colors.grey,
                                                        size: 40,
                                                      )
                                                    : _isRecordingList[index]
                                                        ? Icon(
                                                            Icons.mic,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    54,
                                                                    108,
                                                                    244),
                                                            size: 40,
                                                          )
                                                        : Icon(
                                                            Icons.mic,
                                                            color: Colors.white,
                                                            size: 40,
                                                          ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.check_circle_outline,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                              onPressed: null,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Spacer(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MaterialButton(
                  onPressed: _calculateAndShowResults,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  color: Color.fromARGB(80, 1, 51, 200),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
