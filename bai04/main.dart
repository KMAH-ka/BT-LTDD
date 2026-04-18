import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(SimpleAudioPlayer());
}

class SimpleAudioPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Audio Player',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AudioPlayerHome(),
    );
  }
}

class AudioPlayerHome extends StatefulWidget {
  @override
  _AudioPlayerHomeState createState() => _AudioPlayerHomeState();
}

class _AudioPlayerHomeState extends State<AudioPlayerHome> {
  late AudioPlayer _audioPlayer;
  int _currentSongIndex = 0;
  bool _isPlaying = false;

  final List<String> _songs = [
    'assets/audios/sample1.mp3',
    'assets/audios/sample2.mp3',
    'assets/audios/sample3.mp3',
  ];

  final List<String> _songTitles = ['sample1', 'sample2', 'sample3'];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      _nextSong();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSong() async {
    await _audioPlayer.play(
      AssetSource(_songs[_currentSongIndex].replaceAll('assets/', '')),
    );
    setState(() { _isPlaying = true; });
  }

  Future<void> _pauseSong() async {
    await _audioPlayer.pause();
    setState(() { _isPlaying = false; });
  }

  Future<void> _stopSong() async {
    await _audioPlayer.stop();
    setState(() { _isPlaying = false; });
  }

  void _nextSong() {
    setState(() {
      _currentSongIndex =
      (_currentSongIndex < _songs.length - 1) ? _currentSongIndex + 1 : 0;
      _stopSong();
      _playSong();
    });
  }

  void _previousSong() {
    setState(() {
      _currentSongIndex =
      (_currentSongIndex > 0) ? _currentSongIndex - 1 : _songs.length - 1;
      _stopSong();
      _playSong();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Audio Player')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _songTitles[_currentSongIndex],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous, size: 40),
                  onPressed: _previousSong,
                ),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                  ),
                  onPressed: () {
                    _isPlaying ? _pauseSong() : _playSong();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.stop, size: 40),
                  onPressed: _stopSong,
                ),
                IconButton(
                  icon: Icon(Icons.skip_next, size: 40),
                  onPressed: _nextSong,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}