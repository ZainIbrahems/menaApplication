import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/constants.dart';

class AvatarForLive extends StatelessWidget {
  const AvatarForLive(
      {Key? key,
      required this.isOnline,
      this.radius,
      this.pictureUrl,
      this.onlyView = true,
      this.customRingColor})
      : super(key: key);
  final bool isOnline;
  final double? radius;
  final Color? customRingColor;
  final String? pictureUrl;
  final bool onlyView;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onlyView ? null : () {},
      child: CircleAvatar(
        radius: radius != null ? radius! + 1.sp : 30.sp,
        backgroundColor:
            isOnline ? customRingColor ?? mainGreenColor : Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: CircleAvatar(
                radius: isOnline
                    ? radius == null
                        ? 27.sp
                        : (radius! - (radius! * 0.001))
                    : radius ?? 30.sp,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: (isOnline
                          ? radius == null
                              ? 27.sp
                              : (radius! - (radius! * 0.001))
                          : radius ?? 30.sp) -
                      1.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isOnline
                        ? radius == null
                            ? 26.sp
                            : (radius! - (radius! * 0.01))
                        : radius ?? 30.sp),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: DefaultImage(
                        backGroundImageUrl: pictureUrl ?? '',
                        backColor: newLightGreyColor,
                        boxFit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!onlyView)
              Align(
                alignment: Alignment.bottomRight,
                child: SvgPicture.asset('assets/svg/icons/profileFilled.svg',
                    height: 24.sp),
              )
          ],
        ),
      ),
    );
  }
}

class DefaultImage extends StatelessWidget {
  const DefaultImage(
      {Key? key,
      this.width,
      this.height,
      this.backColor,
      this.borderColor,
      this.borderWidth,
      required this.backGroundImageUrl,
      this.radius,
      this.placeholderScale,
      this.boxFit,
      this.decoration,
      this.customImageCacheHeight,
      this.withoutRadius})
      : super(key: key);
  final double? width;
  final double? height;
  final Color? backColor;
  final Color? borderColor;
  final double? borderWidth;
  final String backGroundImageUrl;
  final bool? withoutRadius;
  final double? radius;
  final double? placeholderScale;
  final BoxFit? boxFit;

  final BoxDecoration? decoration;
  final int? customImageCacheHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        decoration: decoration ??
            BoxDecoration(
              color: backColor,
              borderRadius: BorderRadius.circular(
                  withoutRadius != null ? 0.0 : radius ?? defaultRadiusVal),
              border: Border.all(
                  width: borderWidth ?? 0.0,
                  color: borderColor ?? Colors.transparent),
            ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(
                withoutRadius != null ? 0.0 : radius ?? defaultRadiusVal),
            child: backGroundImageUrl == ""
                ? const SizedBox()
                : backGroundImageUrl.endsWith('.svg')
                    ? SvgPicture.network(backGroundImageUrl)
                    : CachedNetworkImage(
                        width: width,
                        height: height,
                        imageUrl: backGroundImageUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: boxFit ?? BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) =>
                            const DefaultLoaderGrey(),
                        errorWidget: (context, url, error) => GestureDetector(
                            onTap: () {},
                            child: const Center(child: ImageLoadingError())),
                      )));
  }
}

class DefaultLoaderGrey extends StatelessWidget {
  const DefaultLoaderGrey({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 42.h,
        child: Center(
          child: Lottie.asset('assets/video/pre.json'),
        ),
      ),
    );
  }
}

class ImageLoadingError extends StatelessWidget {
  const ImageLoadingError({Key? key, this.customHeight, this.customWidth})
      : super(key: key);
  final double? customHeight;
  final double? customWidth;

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.error);
  }
}
