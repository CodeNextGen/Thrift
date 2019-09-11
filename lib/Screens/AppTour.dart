import 'package:flutter/material.dart';

import 'package:thrift/Instances/Theme.dart';
import 'package:thrift/Instances/PolicyAccepted.dart';
import 'package:thrift/Instances/SharedPreferences.dart';

import 'package:thrift/Screens/Thrift/Thrift.dart';


class AppTour extends StatefulWidget{
  AppTourState createState() => AppTourState();
}

class AppTourState extends State<AppTour>{

  PageController controller;
  ValueNotifier<int> currentPageNotifier;

  static const int initialIndex = 0;

  @override
  void initState() {
    controller = PageController(initialPage: initialIndex,);
    controller.addListener((){
      currentPageNotifier.value = controller.page.round();
    });
    currentPageNotifier = ValueNotifier(initialIndex);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String get pageTitle{
    switch(currentPageNotifier.value){
      case 0: return firstPageTitle;
      case 1: return secondPageTitle;
      case 2: return thirdPageTitle;
      default: return null;
    }
  }

  static const String firstPageTitle = "Introduction";
  static const String secondPageTitle = "Features";
  static const String thirdPageTitle = "If you ever need help";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: AppBarTheme(
            color: white,
            iconTheme: IconThemeData(color: primaryText),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            elevation: 4,
            leading: null,
            title: ValueListenableBuilder<int>(
              valueListenable: currentPageNotifier,
              builder: (context, page, child){
                return Text(pageTitle, style: const TextStyle(color: primaryText));
              },
            ),
          ),
          bottomNavigationBar: Material(
            color: white,
            elevation: 8,
            child: ValueListenableBuilder(
              valueListenable: currentPageNotifier,
              builder: (context, page, child){
                return Container(
                  color: white,
                  height: 56,
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 125),
                          child: Container(
                            key: ValueKey<int>(page>0?1:0),
                            child: IconButton(
                              icon: page>0?const Icon(Icons.arrow_back, color: colorPrimaryDark,):Container(),
                              onPressed: page>0?(){
                                controller.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.ease);
                              }:null,
                            ),
                          ),
                        ),
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          PageIndicator(index: 0, currentPage: page,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: PageIndicator(index: 1, currentPage: page,),
                          ),
                          PageIndicator(index: 2, currentPage: page,),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 125),
                          child: Container(
                            key: ValueKey<int>(page<2?1:0),
                            child: IconButton(
                              icon: page<2?const Icon(Icons.arrow_forward, color: colorPrimaryDark,):const Icon(Icons.check, color: colorPrimaryDark,),
                              onPressed: page<2?(){
                                controller.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.ease);
                              }:(){
                                sharedPreferences.setBool(preference_disclosure, true);
                                policyAccepted = true;
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Thrift(), maintainState: false));
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          body: PageView(
            controller: controller,
            children: <Widget>[
              TourPage(
                image: const Icon(Icons.donut_large, color: colorPrimary, size: 128,),
                description: "Thrift is designed for easy and fast accounting on the go with helpful infographics, fast and performant UI.",
              ),
              TourPage(
                image: const Icon(Icons.category, color: colorPrimary, size: 128,),
                description: "Thrift allows tracking and planning expenses and incomes. Create different accounts for yourself and your business.",
              ),
              TourPage(
                image: const Icon(Icons.live_help, color: colorPrimary, size: 128,),
                description: "Our constantly updating Help Center answers most frequent questions. If you can't find what you need, dont hesitate to contact us!",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TourPage extends StatelessWidget{
  final Widget image;
  final String description;
  TourPage({@required this.image, @required this.description});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,
      child: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: image,
            ),
          ),
          Container(
            height: 156,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(child: Text(description, style: const TextStyle(fontSize: 16, color: secondaryText), textAlign: TextAlign.center,)),
            ),
          ),
        ],
      ),
    );
  }
}

class PageIndicator extends StatelessWidget{
  static const Color pageIndicatorColor_ACTIVE = Color(0xff303f9f);
  static const Color pageIndicatorColor_INACTIVE = Color(0xff7986cb);

  final int index;
  final int currentPage;
  PageIndicator({@required this.index, @required this.currentPage});

  static const double maxSize = 16;
  static const double minSize = 14;
  
  @override
  Widget build(BuildContext context) {
    final double size = index == currentPage ? maxSize: minSize;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 125),
      child: Container(
        key: ValueKey<int>(index==currentPage?1:0),
        width: maxSize,
        child: Center(
          child: Container(
            height: size, width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index==currentPage?pageIndicatorColor_ACTIVE:pageIndicatorColor_INACTIVE,
            ),
          ),
        ),
      ),
    );
  }
}