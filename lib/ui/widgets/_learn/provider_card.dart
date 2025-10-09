import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:karmayogi_mobile/ui/pages/index.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';

class ProviderCard extends StatelessWidget {
  final dynamic providerCardModel;
  // final CourseTopics courseTopics;
  // final String name;
  // final int count;
  // final Color cardColor;
  // final double paddingLeft;
  final bool isCollection;

  ProviderCard({this.providerCardModel, this.isCollection = false
      //   this.name = '',
      // this.count = 0,
      // this.cardColor,
      // this.courseTopics,
      // this.paddingLeft = 16.0
      });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            FadeRoute(
                page: CoursesByProvider(
              providerCardModel.name,
              isCollection: isCollection,
              collectionId: isCollection ? providerCardModel.id : '',
            )),
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
              width: 1.sw / 2 - 25.w,
              child: Stack(children: <Widget>[
                Positioned(
                  top: 0,
                  right: 0,
                  child: SvgPicture.asset(
                    'assets/img/provider_card.svg',
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
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
                            providerCardModel.name != null
                                ? providerCardModel.name.toString().trim()
                                : '',
                            maxLines: 2,
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
