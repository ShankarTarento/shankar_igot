import 'package:flutter/material.dart';

class ChatBotAnimation extends StatefulWidget {
  const ChatBotAnimation({super.key});

  @override
  State<ChatBotAnimation> createState() => _ChatBotAnimationState();
}

class _ChatBotAnimationState extends State<ChatBotAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: const Offset(0, 0.1),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Image.asset(
        'assets/img/bot body.png',
      ),
    );
  }
}
