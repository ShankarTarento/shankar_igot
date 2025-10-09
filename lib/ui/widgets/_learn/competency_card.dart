import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/ui/pages/index.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';

class CompetencyCard extends StatelessWidget {
  final BrowseCompetencyCardModel browseCompetencyCardModel;

  CompetencyCard({required this.browseCompetencyCardModel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            FadeRoute(page: CoursesInCompetency(browseCompetencyCardModel)),
          );
        },
        child: Container(
          padding: EdgeInsets.only(left: 16, bottom: 16).r,
          child: ClipPath(
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8).r)),
            child: Container(
              height: 150.w,
              width: 0.5.sw - 25.w,
              child: Stack(children: <Widget>[
                Positioned(
                  top: 0,
                  right: 0,
                  child: SvgPicture.asset(
                    'assets/img/competency_card.svg',
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
                    // height: 150.w,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 16, top: 16, bottom: 0)
                                .r,
                        child: Container(
                          width: 1.sw / 3,
                          child: Text(
                            browseCompetencyCardModel.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ));
  }
}
