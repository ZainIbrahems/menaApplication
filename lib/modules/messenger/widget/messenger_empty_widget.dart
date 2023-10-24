import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/constants.dart';
import '../../../core/functions/main_funcs.dart';
import '../../../core/shared_widgets/shared_widgets.dart';
import '../users_to_start_chat.dart';

class MessengerEmptyWidget extends StatelessWidget {
  const MessengerEmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// back icon button
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 25.w,
                  horizontal: 25.w
                ),
                child: SvgPicture.asset(
                  'assets/icons/messenger/back_icon.svg',
                  color: Color(0xFF4273B8),
                  width: 20.w,
                ),
              ),
            ),
          ),

          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child:
                SvgPicture.asset("assets/icons/messenger/mena_messenger_logo.svg"),
              ),
              heightBox(
                5.h,
              ),
              Text(
                getTranslatedStrings(context).welcomeToMenaMessenger,
                style: mainStyle(context, 13,
                    weight: FontWeight.w700,
                    color: newDarkGreyColor,
                    isBold: true),
              ),
              heightBox(
                10.h,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Text(
                  getTranslatedStrings(context)
                      .startMessagingWithProvidersClients,
                  style: mainStyle(context, 10,
                      weight: FontWeight.w700,
                      color: newLightTextGreyColor,
                      textHeight: 1.5),
                  textAlign: TextAlign.justify,
                ),
              ),
              heightBox(
                30.h,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DefaultButton(
                text: getTranslatedStrings(context).startMessaging,
                height: 45.h,
                onClick: () {
                  navigateTo(context, UsersToStartChatLayout());
                }),
          )
        ],
      ),
    );
  }
}