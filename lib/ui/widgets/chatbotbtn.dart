import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/chatbot/chat_bot.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/chat_bot_animation.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import '../../util/faderoute.dart';

class Chatbotbtn extends StatefulWidget {
  final String loggedInStatus;

  const Chatbotbtn({Key? key, required this.loggedInStatus}) : super(key: key);
  @override
  ChatbotbtnState createState() => ChatbotbtnState();
}

class ChatbotbtnState extends State<Chatbotbtn> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 150.0).r,
        child: FloatingActionButton(
          splashColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              FadeRoute(
                page: ChatBot(
                  loggedInStatus: widget.loggedInStatus,
                ),
              ),
            );
          },
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(20).r, right: Radius.zero)),
          child: widget.loggedInStatus == EnglishLang.NotLoggedIn ||
                  !AppConfiguration.iGOTAiConfig.iGOTAI
              ? Image.asset(
                  'assets/img/KS_banner.png',
                  scale: 1.w,
                )
              : Container(
                  height: 55.w,
                  width: 55.w,
                  padding: EdgeInsets.all(8).r,
                  decoration: BoxDecoration(
                    color: AppColors.botBackgroundColor,
                    borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                            topRight: Radius.circular(30))
                        .r,
                  ),
                  child: ChatBotAnimation()),
        ),
      ),
    );
  }
}
