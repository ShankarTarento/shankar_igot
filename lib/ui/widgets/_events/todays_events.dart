import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/no_events.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import '../../../util/faderoute.dart';
import '../../../util/index.dart';
import 'widgets/events_card.dart';

class TodaysEvents extends StatefulWidget {
  final List<Event> events;
  final String title;
  final Function()? showAllCallBack;

  const TodaysEvents(
      {Key? key,
      required this.events,
      required this.title,
      this.showAllCallBack})
      : super(key: key);

  @override
  State<TodaysEvents> createState() => _TodaysEventsState();
}

class _TodaysEventsState extends State<TodaysEvents> {
  @override
  Widget build(BuildContext context) {
    return widget.events.isNotEmpty
        ? Container(
            margin: EdgeInsets.only(top: 10).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0)
                        .r,
                    child: TitleWidget(
                      title: widget.title,
                      showAllCallBack: widget.showAllCallBack,
                    )),
                widget.events.length > 0
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8).r,
                        child: SizedBox(
                          height: 160.w,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            itemCount: widget.events.length,
                            // shrinkWrap: true,
                            // physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    FadeRoute(
                                        page: EventsDetailsScreenv2(
                                      eventId: widget.events[index].identifier,
                                    ))),
                                child: EventsCard(
                                  index: index,
                                  eventIcon: widget.events[index].eventIcon,
                                  isEventLive: widget.events[index].status !=
                                          null &&
                                      Helper.isEventLive(
                                          endDate: widget.events[index].endDate
                                              .toString(),
                                          endTime: widget.events[index].endTime
                                              .toString(),
                                          startDate: widget
                                              .events[index].startDate
                                              .toString(),
                                          startTime: widget
                                              .events[index].startTime
                                              .toString()),
                                  isEventCompleted:
                                      widget.events[index].status != null &&
                                          Helper.isEventCompleted(
                                              widget.events[index]),
                                  eventStatus:
                                      widget.events[index].status.toString(),
                                  eventType: widget.events[index].eventType,
                                  eventName: widget.events[index].name,
                                  startTime: widget.events[index].startTime,
                                  endTime: widget.events[index].endTime,
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : NoEventsWidget(),
              ],
            ),
          )
        : SizedBox();
  }
}
