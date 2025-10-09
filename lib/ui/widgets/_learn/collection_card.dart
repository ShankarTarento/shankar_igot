import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import '../../../constants/index.dart';
import '../../../models/_models/course_model.dart';
import '../../pages/_pages/learn/courses_by_provider.dart';

class CollectionCard extends StatelessWidget {
  final Course? collection;
  const CollectionCard({Key? key, this.collection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          FadeRoute(
              page: CoursesByProvider(
            collection!.name,
            isCollection: true,
            collectionId: collection!.id,
            collectionDescription: collection!.description,
          )),
        );
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, bottom: 16).r,
        child: Container(
          width: 1.sw / 2 - 25.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(const Radius.circular(8.0)).r,
            color: AppColors.appBarBackground,
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ).r,
                child: collection?.appIcon != null
                    ? CachedNetworkImage(
                        imageUrl: Helper.convertPortalImageUrl(
                            collection?.appIcon.toString()),
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                        height: 90.w,
                        memCacheWidth: 172,
                        memCacheHeight: 172,
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/img/image_placeholder.jpg',
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          height: 90.w,
                        ),
                      )
                    : Image.asset(
                        'assets/img/image_placeholder.jpg',
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                        height: 90.w,
                      ),
              ),
              Container(
                width: 1.sw,
                color: AppColors.appBarBackground,
                padding: EdgeInsets.all(4).r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 4).r,
                      width: 0.435.sw,
                      child: Text(
                          collection?.name != null ? collection!.name : '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.displayLarge),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 8).r,
                      width: 0.47.sw,
                      child: Text(
                        collection?.description != null
                            ? collection!.description
                            : '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
