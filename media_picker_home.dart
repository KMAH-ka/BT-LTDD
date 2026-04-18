import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class MediaPickerHome extends StatefulWidget {
  @override
  _MediaPickerHomeState createState() => _MediaPickerHomeState();
}

class _MediaPickerHomeState extends State<MediaPickerHome> {
  File? _mediaFile;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();

  Future<void> _requestPermission(Permission permission) async {
    if (await permission.isDenied) {
      await permission.request();
    }
  }

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    await _requestPermission(
      isVideo ? Permission.storage : Permission.photos,
    );
    final XFile? pickedFile =
        await _picker.pickImage(
          source: source,
          imageQuality: 100,
          maxWidth: 1920,
          maxHeight: 1080,
        ) ??
            await _picker.pickVideo(source: source);

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        if (_mediaFile!.path.endsWith('.mp4')) {
          _videoController?.dispose();
          _videoController = VideoPlayerController.file(_mediaFile!);
          _videoController!.initialize().then((_) {
            setState(() {});
            _videoController!.play();
          });
        } else {
          _videoController?.dispose();
          _videoController = null;
        }
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No media selected')));
    }
  }

  Future<void> _captureMedia(bool isVideo) async {
    await _requestPermission(Permission.camera);
    if (isVideo) await _requestPermission(Permission.microphone);

    final XFile? capturedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.camera)
        : await _picker.pickImage(source: ImageSource.camera);

    if (capturedFile != null) {
      setState(() {
        _mediaFile = File(capturedFile.path);
        if (isVideo) {
          _videoController?.dispose();
          _videoController = VideoPlayerController.file(_mediaFile!);
          _videoController!.initialize().then((_) {
            setState(() {});
            _videoController!.play();
          });
        } else {
          _videoController?.dispose();
          _videoController = null;
        }
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No media captured')));
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Media Picker App')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            _mediaFile == null
                ? Text('Chưa chọn ảnh hoặc video.')
                : _videoController != null &&
                _videoController!.value.isInitialized
                ? AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
                : Image.file(_mediaFile!, height: 300),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickMedia(ImageSource.gallery, false),
              child: Text('Chọn ảnh từ Gallery'),
            ),
            ElevatedButton(
              onPressed: () => _captureMedia(false),
              child: Text('Chụp ảnh từ Camera'),
            ),
            ElevatedButton(
              onPressed: () => _pickMedia(ImageSource.gallery, true),
              child: Text('Chọn video từ Gallery'),
            ),
            ElevatedButton(
              onPressed: () => _captureMedia(true),
              child: Text('Quay video từ Camera'),
            ),
          ],
        ),
      ),
    );
  }
}