import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'main.dart';

class LogoView extends StatefulWidget {
  const LogoView({super.key});

  @override
  State<LogoView> createState() => _LogoViewState();
}

class _LogoViewState extends State<LogoView> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  void pushMain() {
    Navigator.pushReplacementNamed(context, LifeLogRoutes.log);
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('icons/LifeLog.MP4');
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
              onHorizontalDragEnd: onHorizontalDragEnd,
              onVerticalDragEnd: onVerticalDragEnd,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(color: Colors.black87),
                  ),
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  Expanded(
                    child: Container(color: Colors.black87),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  int _state = 0;
  int get state => _state;
  set state(int a) {
    setState(() {
      _state = a;
    });
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    if (state == 0 && details.velocity.pixelsPerSecond.dx < 0) {
      state = 1;
    } else if (state == 3 && details.velocity.pixelsPerSecond.dx > 0) {
      state = 4;
      pushMain();
    } else {
      state = 0;
    }
  }

  void onVerticalDragEnd(DragEndDetails details) {
    if (state == 1 && details.velocity.pixelsPerSecond.dy < 0) {
      state = 2;
    } else if (state == 2 && details.velocity.pixelsPerSecond.dy > 0) {
      state = 3;
    } else {
      state = 0;
    }
  }
}
