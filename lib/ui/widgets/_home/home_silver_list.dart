import 'package:flutter/widgets.dart';

class HomeSilverList extends StatelessWidget {
  final Widget child;

  const HomeSilverList({Key? key,required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => child,
        childCount: 1,
      ),
    );
  }
}
