import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MusicPlayerApp());
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MusicPlayerHome(),
    );
  }
}

class Song {
  final String title;
  final String artist;
  final String assetPath;
  final Color color;

  Song({required this.title, required this.artist, required this.assetPath, required this.color});
}

class MusicPlayerHome extends StatefulWidget {
  const MusicPlayerHome({super.key});
  @override
  State<MusicPlayerHome> createState() => _MusicPlayerHomeState();
}

class _MusicPlayerHomeState extends State<MusicPlayerHome>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _rotationController;

  int _currentIndex = 0;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final List<Song> _songs = [
    Song(
      title: 'Cần gì hơn',
      artist: 'Tiên Tiên',
      assetPath: 'audios/Cần gì hơn - Tiên Tiên.mp3',
      color: Colors.deepPurple,
    ),
    Song(
      title: 'Em ơi sau này',
      artist: 'Trid Minh',
      assetPath: 'audios/Em ơi sau này - Trid Minh.mp3',
      color: Colors.teal,
    ),
    Song(
      title: 'Gửi anh xa nhớ',
      artist: 'Phương Bích Hữu',
      assetPath: 'audios/Gửi anh xa nhớ - Phương Bích Hữu.mp3',
      color: Colors.pink,
    ),
    Song(
      title: 'Hãy trao cho anh',
      artist: 'Sơn Tùng MTP',
      assetPath: 'audios/Hãy trao cho anh - Sơn Tùng MTP.mp3',
      color: Colors.orange,
    ),
    Song(
      title: 'Lỗi tại anh',
      artist: 'Alex Lam',
      assetPath: 'audios/Lỗi tại anh - Alex Lam.mp3',
      color: Colors.blue,
    ),
    Song(
      title: 'Từng là của nhau',
      artist: 'Bảo Anh',
      assetPath: 'audios/Từng là của nhau - Bảo Anh.mp3',
      color: Colors.red,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
      if (_isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) => _nextSong());
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _playSong() async {
    await _audioPlayer.play(AssetSource(_songs[_currentIndex].assetPath));
  }

  Future<void> _pauseSong() async {
    await _audioPlayer.pause();
  }

  Future<void> _stopSong() async {
    await _audioPlayer.stop();
    setState(() => _position = Duration.zero);
  }

  void _nextSong() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _songs.length;
    });
    _playSong();
  }

  void _previousSong() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _songs.length) % _songs.length;
    });
    _playSong();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final song = _songs[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [song.color.withOpacity(0.8), Colors.black],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
                    Text('Now Playing',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Icon(Icons.more_vert, color: Colors.white, size: 30),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Album Art (rotating circle)
              RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: song.color,
                    boxShadow: [
                      BoxShadow(
                        color: song.color.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.music_note, size: 90, color: Colors.white),
                ),
              ),

              const SizedBox(height: 30),

              // Song info
              Text(song.title,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(song.artist,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15)),

              const SizedBox(height: 20),

              // Seek bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Slider(
                      value: _position.inSeconds.toDouble().clamp(
                          0, _duration.inSeconds.toDouble()),
                      min: 0,
                      max: _duration.inSeconds.toDouble() > 0
                          ? _duration.inSeconds.toDouble()
                          : 1,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                      onChanged: (value) async {
                        await _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(_position),
                              style: const TextStyle(color: Colors.white70)),
                          Text(_formatDuration(_duration),
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white, size: 45),
                    onPressed: _previousSong,
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _isPlaying ? _pauseSong() : _playSong(),
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.white30, blurRadius: 10, spreadRadius: 3),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: song.color,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 45),
                    onPressed: _nextSong,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Stop button
              TextButton.icon(
                onPressed: _stopSong,
                icon: const Icon(Icons.stop, color: Colors.white70),
                label: const Text('Stop', style: TextStyle(color: Colors.white70)),
              ),

              // Playlist
              Expanded(
                child: ListView.builder(
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final s = _songs[index];
                    final isActive = index == _currentIndex;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: s.color,
                        child: const Icon(Icons.music_note, color: Colors.white),
                      ),
                      title: Text(s.title,
                          style: TextStyle(
                              color: isActive ? Colors.white : Colors.white60,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                      subtitle: Text(s.artist,
                          style: TextStyle(
                              color: isActive ? Colors.white60 : Colors.white30)),
                      trailing: isActive
                          ? Icon(Icons.equalizer, color: s.color)
                          : null,
                      onTap: () {
                        setState(() => _currentIndex = index);
                        _playSong();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}