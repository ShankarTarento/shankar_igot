import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/container_skeleton.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class ImageWidget extends StatefulWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final double? radius;
  final BoxFit? boxFit;
  final Color? imageColor;
  final int? cacheWidth;
  final int? cacheHeight;
  final bool enableImageCache;

  const ImageWidget(
      {super.key,
      required this.imageUrl,
      this.height,
      this.width,
      this.radius,
      this.boxFit,
      this.imageColor,
      this.cacheWidth,
      this.cacheHeight,
      this.enableImageCache = true});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    bool isNetworkImage = widget.imageUrl.startsWith('http://') ||
        widget.imageUrl.startsWith('https://');

    bool isSvg = widget.imageUrl.toLowerCase().endsWith('.svg');

    bool isAssetImage = !isNetworkImage && !widget.imageUrl.startsWith('http');

    return isNetworkImage
        ? isSvg
            ? SizedBox(
                height: widget.height,
                width: widget.width,
                child: SvgPicture.network(
                  fit: widget.boxFit ?? BoxFit.fill,
                  widget.imageUrl,
                  height: widget.height,
                  width: widget.width,
                  colorFilter: widget.imageColor != null
                      ? ColorFilter.mode(
                          widget.imageColor!,
                          BlendMode.srcIn,
                        )
                      : null,
                  placeholderBuilder: (context) => ContainerSkeleton(
                    height: widget.height ?? 16,
                    width: widget.width ?? 16,
                    radius: widget.radius ?? 4,
                  ),
                ),
              )
            : SizedBox(
                height: widget.height,
                width: widget.width,
                child: CachedNetworkImage(
                  fit: widget.boxFit ?? BoxFit.fill,
                  height: widget.height,
                  width: widget.width,
                  memCacheWidth: widget.enableImageCache
                      ? widget.cacheWidth != null
                          ? widget.cacheWidth
                          : 172
                      : null,
                  memCacheHeight: widget.enableImageCache
                      ? widget.cacheHeight != null
                          ? widget.cacheHeight
                          : 172
                      : null,
                  imageUrl: widget.imageUrl
                          .contains('https://storage.googleapis.com/igotprod')
                      ? Helper.upgradeGoogleAPI(widget.imageUrl)
                      : widget.imageUrl,
                  color: widget.imageColor,
                  placeholder: (context, url) => ContainerSkeleton(
                    height: widget.height ?? 16,
                    width: widget.width ?? 16,
                    radius: widget.radius ?? 4,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/img/image_placeholder.jpg',
                    height: widget.height,
                    width: widget.width,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              )
        : isAssetImage
            ? (isSvg
                ? SizedBox(
                    height: widget.height,
                    width: widget.width,
                    child: SvgPicture.asset(
                      fit: widget.boxFit ?? BoxFit.fill,
                      widget.imageUrl,
                      height: widget.height,
                      width: widget.width,
                      colorFilter: widget.imageColor != null
                          ? ColorFilter.mode(
                              widget.imageColor!,
                              BlendMode.srcIn,
                            )
                          : null,
                      placeholderBuilder: (context) => ContainerSkeleton(
                        height: widget.height ?? 16,
                        width: widget.width ?? 16,
                        radius: widget.radius ?? 4,
                      ),
                    ),
                  )
                : SizedBox(
                    height: widget.height,
                    width: widget.width,
                    child: Image.asset(
                      fit: widget.boxFit ?? BoxFit.fill,
                      widget.imageUrl,
                      height: widget.height,
                      width: widget.width,
                      color: widget.imageColor,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/img/image_placeholder.jpg',
                        width: widget.width,
                        height: widget.height,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ))
            : SizedBox.shrink();
  }
}
