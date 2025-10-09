import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/widgets/chatbotbtn.dart';

extension ChatbotOverlayExtension on Widget {
  Widget withChatbotButton({String loggedInStatus = EnglishLang.loggedIn}) {
    return _ChatbotOverlayWrapper(
      child: this,
      loggedInStatus: loggedInStatus,
    );
  }
}

class _ChatbotOverlayWrapper extends StatefulWidget {
  final Widget child;
  final String loggedInStatus;

  const _ChatbotOverlayWrapper({
    required this.child,
    this.loggedInStatus = EnglishLang.loggedIn,
  });

  @override
  State<_ChatbotOverlayWrapper> createState() => _ChatbotOverlayWrapperState();
}

class _ChatbotOverlayWrapperState extends State<_ChatbotOverlayWrapper> {
  late final ValueNotifier<Offset> _offsetNotifier;

  @override
  void initState() {
    super.initState();
    _offsetNotifier = ValueNotifier<Offset>(Offset(0.86.sw, 600));
  }

  @override
  void dispose() {
    _offsetNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          ValueListenableBuilder<Offset>(
            valueListenable: _offsetNotifier,
            builder: (context, offset, child) {
              return Positioned(
                left: offset.dx,
                top: offset.dy,
                child: Draggable(
                  feedback: _buildChatbotButton(),
                  childWhenDragging: Container(),
                  onDraggableCanceled: (velocity, offset) {
                    double constrainedDx = offset.dx;
                    double constrainedDy = offset.dy;

                    double minX = 0.0;
                    double maxX = screenWidth - 58.0.w;
                    double minY = 10.0.h;
                    double maxY = screenHeight - 100.0.h;

                    constrainedDx = constrainedDx.clamp(minX, maxX);
                    constrainedDy = constrainedDy.clamp(minY, maxY);

                    _offsetNotifier.value =
                        Offset(constrainedDx, constrainedDy);
                  },
                  child: _buildChatbotButton(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatbotButton() {
    return Chatbotbtn(
      loggedInStatus: widget.loggedInStatus,
    );
  }
}
