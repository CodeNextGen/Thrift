  import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:thrift/Instances/Notifiers/backdropOpen.dart';
import 'package:thrift/Instances/Theme.dart';

class Backdrop extends StatefulWidget{
  final Widget frontLayer;
  final Widget backLayer;
  final Widget header;
  final double headerSize;
  Backdrop({@required this.headerSize, @required this.header, @required this.backLayer, @required this.frontLayer});
  BackdropState createState() => BackdropState();
}

class BackdropState extends State<Backdrop> with SingleTickerProviderStateMixin{
  final backdropKey = GlobalKey();
  final headerKey = GlobalKey();
  AnimationController _controller;

  @override
  void initState(){
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      value: backdropOpenNotifier.value ? 1.0 : 0.0,
      vsync: this,
    );

    backdropOpenNotifier.addListener(notifierListener);

    _controller.addStatusListener((status){
      if(status == AnimationStatus.completed){
        backdropOpenNotifier.value=true;
      } else if (status == AnimationStatus.dismissed){
        backdropOpenNotifier.value=false;
      }
    });
  }

  void notifierListener(){
    if(backdropVisible != backdropOpenNotifier.value){
      toggleState();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    backdropOpenNotifier.removeListener(notifierListener);
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_controller.isAnimating)
      _controller.value -= details.primaryDelta / _backdropHeight;
  }
  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / _backdropHeight;
    if (flingVelocity < 0.0)
      _controller.fling(velocity: math.max(2, -flingVelocity));
    else if (flingVelocity > 0.0)
      _controller.fling(velocity: math.min(-2, -flingVelocity));
    else
      _controller.fling(
          velocity:
          _controller.value < 0.5 ? -2 : 2);
  }

  double get _backdropHeight {
    final RenderBox renderBox = backdropKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  bool get backdropVisible => _controller.status == AnimationStatus.completed || _controller.status == AnimationStatus.forward;

  void toggleState(){
    _controller.fling(velocity: backdropVisible ? -2 : 2);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){

        final position = Tween<Offset>(
          begin: Offset(0, (constraints.maxHeight - widget.headerSize)/constraints.maxHeight),
          end: Offset(0,0),
        ).animate(_controller.view);

        return Stack(
          key: backdropKey,
          children: <Widget>[
            widget.backLayer,
            SlideTransition(
              position: position,
              child: Material(
                color: Colors.transparent,
                elevation: backdropOpenNotifier.value? 0 : 12,
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    GestureDetector(
                      key: headerKey,
                      onVerticalDragUpdate: _handleDragUpdate,
                      onVerticalDragEnd: _handleDragEnd,
                      behavior: HitTestBehavior.opaque,
                      onTap: toggleState,
                      child: widget.header,
                    ),
                    Expanded(
                      child: Container(
                        color: white,
                        child: Flex(
                          direction: Axis.vertical,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(
                                height: 1,
                                color: dividerColor,
                              ),
                            ),
                            Expanded(child: widget.frontLayer),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}