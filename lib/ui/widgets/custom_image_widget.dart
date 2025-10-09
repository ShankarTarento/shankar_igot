import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

class ImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final double? radius;
  final Color? color;
  final BoxFit? fit;

  const ImageWidget({
    super.key,
    required this.imageUrl,
    this.height,
    this.color,
    this.width,
    this.radius,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    bool isSvg = imageUrl.toLowerCase().endsWith('.svg');

    bool isAssetImage = !isNetworkImage && !imageUrl.startsWith('http');

    return Center(
        child: isNetworkImage
            ? isSvg
                ? SizedBox(
                    height: height,
                    width: width,
                    child: SvgPicture.network(
                      colorFilter: color != null
                          ? ColorFilter.mode(
                              color!,
                              BlendMode.srcIn,
                            )
                          : null,
                      fit: fit ?? BoxFit.fill,
                      imageUrl,
                      height: height,
                      width: width,
                      placeholderBuilder: (context) => ContainerSkeleton(
                        height: height ?? 1.sw,
                        width: width ?? 1.sh,
                        radius: radius ?? 4,
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    color: color,
                    fit: fit ?? BoxFit.fill,
                    height: height,
                    width: width,
                    imageUrl: imageUrl,
                    placeholder: (context, url) => ContainerSkeleton(
                      height: height ?? 1.sw,
                      width: width ?? 1.sh,
                      radius: radius ?? 4,
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/img/image_placeholder.jpg',
                      height: height,
                      width: width,
                      fit: BoxFit.fitWidth,
                    ),
                  )
            : isAssetImage
                ? (isSvg
                    ? SizedBox(
                        height: height,
                        width: width,
                        child: SvgPicture.asset(
                          fit: fit ?? BoxFit.fill,
                          imageUrl,
                          colorFilter: color != null
                              ? ColorFilter.mode(
                                  color!,
                                  BlendMode.srcIn,
                                )
                              : null,
                          height: height,
                          width: width,
                          placeholderBuilder: (context) => ContainerSkeleton(
                            height: height ?? 1.sw,
                            width: width ?? 1.sh,
                            radius: radius ?? 4,
                          ),
                        ),
                      )
                    : Image.asset(
                        fit: fit ?? BoxFit.fill,
                        color: color,
                        imageUrl,
                        height: height,
                        width: width,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/img/image_placeholder.jpg',
                          width: width,
                          height: height,
                          fit: BoxFit.fitWidth,
                        ),
                      ))
                : SizedBox.shrink());
  }
}
