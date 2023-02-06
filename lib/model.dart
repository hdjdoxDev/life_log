import 'package:flutter/material.dart';
import 'package:mypack/core/viewmodels/base_viewmodel.dart';

abstract class IScrollableModel extends BaseModel {
  ScrollController controllerScroll = ScrollController();

  void goToBottom({int delay = 100, int duration = 500, int threshold = 150}) =>
      controllerScroll.hasClients
          ? _goToBottom(delay: delay, duration: duration, threshold: threshold)
          : null;
  void _goToBottom({int delay = 50, int duration = 500, int threshold = 150}) =>
      controllerScroll.position.maxScrollExtent - controllerScroll.offset <
              threshold
          ? _scrollDown(mill: duration, delay: delay)
          : _moveDown(delay: delay);
  void _moveDown({int delay = 50}) => Future.delayed(
      Duration(milliseconds: delay),
      () => controllerScroll.jumpTo(controllerScroll.position.maxScrollExtent));

  void _scrollDown({int mill = 500, int delay = 50}) async => Future.delayed(
      Duration(milliseconds: delay),
      () => controllerScroll.animateTo(
            controllerScroll.position.maxScrollExtent,
            duration: Duration(
              milliseconds: mill,
            ),
            curve: Curves.fastOutSlowIn,
          ));

  void scrollUp() async => Future.delayed(
      const Duration(milliseconds: 50),
      () => controllerScroll.animateTo(
            0,
            duration: const Duration(
              milliseconds: 500,
            ),
            curve: Curves.easeInOut,
          ));
}
