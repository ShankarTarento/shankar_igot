class VttCaption {
  final int index;
  final Duration start;
  final Duration end;
  final String text;

  VttCaption(
      {required this.start,
      required this.end,
      required this.text,
      required this.index});
}
