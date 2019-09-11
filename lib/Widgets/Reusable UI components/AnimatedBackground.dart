import 'package:flutter/material.dart';

import 'package:thrift/Functions/KeyboardVisibilityNotification.dart';
import 'package:thrift/Functions/setStatusBarColor.dart';

import 'package:thrift/Instances/Theme.dart';

import 'package:thrift/Widgets/Reusable UI components/BottomSelector.dart';
import 'package:thrift/Widgets/Reusable UI components/TopBarButton.dart';
import 'package:thrift/Widgets/Reusable UI components/EmptyAppBar.dart';

class AnimatedBackground extends StatefulWidget{
  final Function onKeyboardClosed;
  final List<TopBarButton> topBarButtons;
  final Widget child;
  final Widget appBar;
  final ValueNotifier<String> errorNotifier;
  final Function onConfirmed;
  final bool showBottomBar;
  final Widget bottomBar;
  final GlobalKey<ScaffoldState> scaffoldKey;
  AnimatedBackground({@required this.onKeyboardClosed, this.topBarButtons, this.appBar, this.bottomBar, @required this.child, this.showBottomBar = true, this.errorNotifier, this.onConfirmed, this.scaffoldKey,});
  AnimatedBackgroundState createState() => AnimatedBackgroundState();
}

const int primaryColorRed = 40; //28(16) = 40(10)
const int primaryColorGreen = 53; //35(16) = 53(10)
const int primaryColorBlue = 147; //93(16) = 147(10)

const int primaryColorRedShortage = 215;
const int primaryColorGreenShortage = 202;
const int primaryColorBlueShortage = 108;

//#7c4dff
const int boxColorRed = 124; //7c(16) = 124(10)
const int boxColorGreen = 77; //4d(16) = 77(10)
//blue is 255

const int boxColorRedShortage = 131;
const int boxColorGreenShortage = 178;

const int fullWhiteColor = 255;

class AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin{
  KeyboardVisibilityNotification keyboardVisibilityNotification;
  int keyboardSubscriptionID;

  AnimationController animationController;
  Animation<double> animation;

  @override
  @override
  void initState() {
    keyboardVisibilityNotification = KeyboardVisibilityNotification((keyboardVisible){
      if (keyboardVisible) {
        // animationController.fling(velocity: 1);
        animationController.forward(from: 1 - animation.value);
      } else {
        // animationController.fling(velocity: -1);
        animationController.reverse(from: 1 - animation.value);
        widget.onKeyboardClosed();
      }
    });

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    animation = Tween<double>(begin: 1, end: 0,).animate(CurvedAnimation(parent: animationController, curve: Curves.ease));

    super.initState();
  }

  @override
  void dispose() {
    keyboardVisibilityNotification.dispose();

    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topBarHeight = widget.topBarButtons != null ?(widget.topBarButtons.length*56+(widget.topBarButtons.length+1)*16).toDouble() : kToolbarHeight;//48+56+56
    return WillPopScope(
      onWillPop: () async {
        setStatusBarColor(colorPrimary);
        return true;
      },
      child: Scaffold(
        appBar: EmptyAppBar(),
        key: widget.scaffoldKey??GlobalKey(),
        bottomNavigationBar: widget.showBottomBar?
        widget.errorNotifier!=null?
        ValueListenableBuilder<String>(
          valueListenable: widget.errorNotifier,
          builder: (context, errorMSG, child){
            if(errorMSG!=null){
              Future.delayed(const Duration(milliseconds: 2500), (){
                widget.errorNotifier.value = null;
              });
            }
            return BottomSelector(
              onCancel: () => Navigator.pop(context),
              onConfirm: widget.onConfirmed,
            );
          },
        ):BottomSelector(
          onCancel: () => Navigator.pop(context),
          onConfirm: widget.onConfirmed,
        ):null,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child){
              print("gay"); //ToDo delete
              Color topBarColor = Color.fromARGB(
                fullWhiteColor,
                primaryColorRed + (primaryColorRedShortage - primaryColorRedShortage*animation.value).toInt(),
                primaryColorGreen + (primaryColorGreenShortage - primaryColorGreenShortage*animation.value).toInt(),
                primaryColorBlue + (primaryColorBlueShortage - primaryColorBlueShortage*animation.value).toInt(),
              );
              Color boxColor = Color.fromARGB(
                fullWhiteColor,
                boxColorRed + (boxColorRedShortage - boxColorRedShortage*animation.value).toInt(),
                boxColorGreen + (boxColorGreenShortage - boxColorGreenShortage*animation.value).toInt(),
                fullWhiteColor,
              );
              setStatusBarColor(topBarColor);
              List<TopBarButton> topBarButtons = List();
              if(widget.topBarButtons != null){
                widget.topBarButtons.forEach((button){
                  topBarButtons.add(
                    TopBarButton(
                      onPressed: button.onPressed,
                      iconData: button.iconData,
                      text: button.text,
                      padding: button.padding,
                      color: boxColor,
                    ),
                  );
                });
              }
              return Container(
                color: topBarColor,
                child: Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      height: topBarHeight*animation.value,
                      child: OverflowBox(
                        child: widget.topBarButtons != null?Flex(
                          direction: Axis.vertical,
                          mainAxisSize: MainAxisSize.min,
                          children: topBarButtons,
                        ):widget.appBar,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16*animation.value),
                            topRight: Radius.circular(16*animation.value),
                          ),
                        ),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}