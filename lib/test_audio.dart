// countdown.mp3 파일만 직접 테스트하는 간단한 앱
// 작성: 2024-07-15

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(const CountdownTestApp());

class CountdownTestApp extends StatelessWidget {
  const CountdownTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CountdownTestScreen());
  }
}

class CountdownTestScreen extends StatefulWidget {
  const CountdownTestScreen({super.key});

  @override
  _CountdownTestScreenState createState() => _CountdownTestScreenState();
}

class _CountdownTestScreenState extends State<CountdownTestScreen> {
  final AudioPlayer _player = AudioPlayer();
  String _logText = "준비됨";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("countdown.mp3 테스트")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("countdown.mp3 재생"),
              onPressed: () async {
                setState(() => _logText = "로드 중...");
                try {
                  await _player.setAsset('assets/sounds/countdown.mp3');
                  setState(() => _logText = "로드 성공, 재생 중...");
                  await _player.play();
                  setState(() => _logText = "재생 성공!");
                } catch (e) {
                  setState(() => _logText = "오류: $e");
                }
              },
            ),
            const SizedBox(height: 20),
            Text(_logText)
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
