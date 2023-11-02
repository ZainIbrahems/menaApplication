import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mena/core/cache/cache.dart';
import 'package:mena/core/functions/main_funcs.dart';
import 'package:mena/core/main_cubit/main_cubit.dart';
import 'package:mena/core/responsive/responsive.dart';
import 'package:mena/modules/feeds_screen/feeds_screen.dart';
import 'package:mena/modules/home_screen/cubit/home_screen_cubit.dart';
import 'package:mena/modules/messenger/screens/messenger_get_start_page.dart';
import 'package:mena/modules/messenger/screens/messenger_home_page.dart';

// import 'package:mena/modules/test/test_layout.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../core/constants/constants.dart';
import '../../core/shared_widgets/mena_shared_widgets/custom_containers.dart';
import '../../core/shared_widgets/shared_widgets.dart';
import '../../models/local_models.dart';
import '../auth_screens/cubit/auth_cubit.dart';
import '../auth_screens/cubit/auth_state.dart';
import '../auth_screens/sign_in_screen.dart';
import '../feeds_screen/cubit/feeds_cubit.dart';
import '../home_screen/home_screen.dart';
import '../live_screens/live_main_layout.dart';
import '../live_screens/meetings/meetings_layout.dart';
import '../messenger/cubit/messenger_cubit.dart';
import '../messenger/messenger_layout.dart';
import '../my_profile/my_profile.dart';
import '../splash_screen/route_engine.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late PersistentTabController _controller;
  late bool _hideNavBar;
  IO.Socket? socket;


  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _hideNavBar = false;
    var messengerCubit =MessengerCubit.get(context);
    messengerCubit
      ..fetchMyMessages()
      ..fetchOnlineUsers();

    socket = MainCubit.get(context).socket;
    socket?.on('new-message', (data) {
      logg('new message socket: $data');
      messengerCubit
        ..fetchMyMessages()
        ..fetchOnlineUsers();
    });
    
    // if (getCachedToken() != null) {
    //   checkPhoneVerified();
    // }

    // MainCubit.socketInitial();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildScreens() {
    return const [
      HomeScreen(),
      ComingSoonWidget(),
      LiveMainLayout(),
      MeetingsLayout(),
      FeedsScreen(
        inHome: true,
        isMyFeeds: false,
        user: null,
      )
    ];
    // return const [
    //   HomeScreen(),
    //   DealsScreen(),
    //   LiveMainLayout(),
    //   CommunityScreen(),
    //   FeedsScreen(inHome: true,)
    // ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          'assets/svg/icons/home.svg',
          color: mainBlueColor,
          fit: BoxFit.contain,
          // height: 33.h,
        ),
        inactiveIcon: SvgPicture.asset(
          'assets/svg/icons/home.svg',
          fit: BoxFit.contain,
          color: Colors.black.withOpacity(0.5),
          // height: 30.h,
        ),
        title: getTranslatedStrings(context).home.toUpperCase(),
        textStyle: mainStyle(context, 10.0, isBold: true),
        activeColorPrimary: mainBlueColor,
        inactiveColorPrimary: Colors.grey,
        inactiveColorSecondary: Colors.purple,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          'assets/svg/icons/promotion.svg',
          fit: BoxFit.contain,
          color: mainBlueColor,
        ),
        inactiveIcon: SvgPicture.asset(
          'assets/svg/icons/promotion.svg',
          fit: BoxFit.contain,
          color: Colors.black.withOpacity(0.5),
        ),
        title: getTranslatedStrings(context).deals.toUpperCase(),
        textStyle: mainStyle(context, 10.0, isBold: true),
        activeColorPrimary: mainBlueColor,
        inactiveColorPrimary: Colors.grey,
        inactiveColorSecondary: Colors.purple,
      ),
      PersistentBottomNavBarItem(
        icon: Padding(
          padding: const EdgeInsets.all(0),
          child: SvgPicture.asset(
            'assets/svg/icons/live screencast.svg',
            color: mainBlueColor,
            // fit: BoxFit.contain,
            // height: 28.h,
          ),
        ),
        inactiveIcon: SvgPicture.asset(
          'assets/svg/icons/live screencast.svg',
          fit: BoxFit.contain,
          color: newDarkGreyColor,
          // height: 28.h,
        ),
        title: getTranslatedStrings(context).live.toUpperCase(),
        textStyle: mainStyle(context, 10.0, isBold: true),
        activeColorPrimary: mainBlueColor,
        inactiveColorPrimary: Colors.grey,
        inactiveColorSecondary: Colors.purple,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          'assets/svg/icons/community.svg',
          color: mainBlueColor,
          fit: BoxFit.contain,
          // height: 30.h,
        ),
        inactiveIcon: SvgPicture.asset(
          'assets/svg/icons/community.svg',
          fit: BoxFit.contain,
          color: Colors.black.withOpacity(0.5),
          // height: 28.h,
        ),
        title: getTranslatedStrings(context).meetings.toUpperCase(),
        textStyle: mainStyle(context, 10.0, isBold: true),
        activeColorPrimary: mainBlueColor,
        inactiveColorPrimary: Colors.grey,
        inactiveColorSecondary: Colors.purple,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          'assets/svg/icons/feeds.svg',
          fit: BoxFit.contain,
          color: mainBlueColor,
        ),
        inactiveIcon: SvgPicture.asset(
          'assets/svg/icons/feeds.svg',
          color: Colors.black.withOpacity(0.5),
          fit: BoxFit.contain,
        ),
        title: getTranslatedStrings(context).feeds.toUpperCase(),
        textStyle: mainStyle(context, 10.0, isBold: true),
        activeColorPrimary: mainBlueColor,
        inactiveColorPrimary: Colors.grey,
        inactiveColorSecondary: Colors.purple,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var mainCubit = MainCubit.get(context);
    var homeCubit = HomeScreenCubit.get(context);
    var messengerCubit = MessengerCubit.get(context);

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Do you want to exit?'),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    if (!kIsWeb) {
                      Platform.isAndroid ? SystemNavigator.pop() : exit(0);
                    }
                  },
                  child: const Text('Yes'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('No'),
                ),
              ],
            );
          },
        );
        return shouldPop!;
      },
      child: Scaffold(
        // appBar: AppBar(),
        backgroundColor: Colors.white,
        // floatingActionButton: FloatingActionButton(
        //   // onPressed: (){
        //   //   MainCubit.get(context).updateMenaViewedLogo('assets/svg/icons/menalive.svg');
        //   // },
        // ),
        key: myScaffoldKey,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: ()async{
        //     var userBox = await Hive.openBox('userBox');
        //     UserInfoModel test=
        //     UserInfoModel.fromJson( userBox.get('userModel'));
        //     // await userBox.close();
        //     logg('yefghjdksmf: ${test.data.user.fullName}');
        //   },
        // ),
        // appBar: AppBar(
        //   flexibleSpace: Container(
        //     color: Colors.white,
        //   ),
        //   elevation: 0.1,
        //   leadingWidth: 50.w,
        //   leading:  Padding(
        //     padding:  EdgeInsets.symmetric(horizontal: defaultHorizontalPadding*2),
        //     child: Row(
        //       children: [
        //         SvgPicture.asset('assets/svg/mena8.svg',width: 0.4.sw,)
        //       ],
        //     ),
        //   ),
        // ),

        ///
        ///  change to getCachedToken()==null
        ///
        ///

        // drawer: getCachedToken() == null ? const GuestDrawer() : const UserProfileDrawer(),
        endDrawer: BlocConsumer<HomeScreenCubit, HomeScreenState>(
          listener: (context, state) {
            // TODO: implement listener
          },
          builder: (context, state) {
            return FloatingPickPlatformsDrawer(
              buttons: mainCubit.configModel!.data.platforms
                  .map(
                    (e) => SelectorButtonModel(
                      title: e.name!,
                      image: e.image,
                      onClickCallback: () {
                        myScaffoldKey.currentState?.closeEndDrawer();
                        homeCubit.changeSelectedHomePlatform(e.id.toString());
                      },
                      isSelected: homeCubit.selectedHomePlatformId == e.id,
                    ),
                  )
                  .toList(),
            );
          },
        ),
        endDrawerEnableOpenDragGesture: false,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: (){
        //     scaffoldKey.currentState?.openEndDrawer();
        //
        //   },
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
        drawerScrimColor: Colors.white.withOpacity(0.2),
        body: BlocConsumer<MainCubit, MainState>(
          listener: (context, state) {
            // TODO: implement listener
          },
          builder: (context, state) {
            return (MainCubit.get(context).userInfoModel == null &&
                    getCachedToken() != null)
                ? SizedBox()
                : Padding(
                    padding: EdgeInsets.only(top: topScreenPadding),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          mainCubit.isHeaderVisible
                              ? Padding(
                                  padding: EdgeInsets.only(
                                      right: defaultHorizontalPadding,
                                      left: defaultHorizontalPadding,
                                      top: Responsive.isMobile(context)
                                          ? defaultHorizontalPadding / 8
                                          : defaultHorizontalPadding / 2),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 5.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              mainCubit.currentLogo,
                                              height:
                                                  Responsive.isMobile(context)
                                                      ? 22.w
                                                      : 12.w,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/svg/icons/searchFilled.svg',
                                              height:
                                                  Responsive.isMobile(context)
                                                      ? 30.w
                                                      : 12.w,
                                            ),
                                            widthBox(10.w),
                                            MessengerIconBubble(),
                                            widthBox(10.w),
                                            GestureDetector(
                                              onTap: () {
                                                logg('profile bubble clicked');
                                                navigateToWithoutNavBar(
                                                    context,
                                                    getCachedToken() == null
                                                        ? SignInScreen()
                                                        : MyProfile(),
                                                    '');
                                                // getCachedToken() == null ? SignInScreen() : MyProfile(), '');

                                                // viewComingSoonAlertDialog(context,
                                                //     customAddedWidget: DefaultButton(
                                                //         text: getCachedToken() == null ? 'Login' : 'Logout',
                                                //         onClick: () {
                                                //           // AuthCubit.get(context).lo
                                                //
                                                //           if (getCachedToken() == null) {
                                                //             navigateToAndFinishUntil(context, SignInScreen());
                                                //           } else {
                                                //             removeToken();
                                                //             MainCubit.get(context).removeUserModel();
                                                //             navigateToAndFinishUntil(context, SignInScreen());
                                                //           }
                                                //         }));
                                              },
                                              child: getCachedToken() == null
                                                  ? SvgPicture.asset(
                                                      'assets/svg/icons/profileFilled.svg',
                                                      height:
                                                          Responsive.isMobile(
                                                                  context)
                                                              ? 30.w
                                                              : 12.w,
                                                    )
                                                  : ProfileBubble(
                                                      isOnline: true,
                                                      customRingColor:
                                                          mainBlueColor,
                                                      pictureUrl: MainCubit.get(
                                                                      context)
                                                                  .userInfoModel ==
                                                              null
                                                          ? ''
                                                          : MainCubit.get(
                                                                  context)
                                                              .userInfoModel!
                                                              .data
                                                              .user
                                                              .personalPicture,
                                                      onlyView: true,
                                                      radius:
                                                          Responsive.isMobile(
                                                                  context)
                                                              ? 14.w
                                                              : 5.w,
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          Expanded(
                            child: PersistentTabView(
                              context,
                              navBarHeight: Responsive.isMobile(context)
                                  ? kBottomNavigationBarHeight * 1
                                  : kBottomNavigationBarHeight * 1.3,
                              controller: _controller,
                              // floatingActionButton: Container(
                              //   c
                              // ),
                              onItemSelected: (index) {
                                // mainCubit.changeHeaderVisibility(true);
                                if (index == 2) {
                                  MainCubit.get(context).updateMenaViewedLogo(
                                      'assets/svg/icons/menalive.svg');
                                } else if (index == 4) {
                                  /// feeds public
                                  MainCubit.get(context).updateMenaViewedLogo(
                                      'assets/svg/mena8.svg');
                                  //        FeedsCubit.get(context).getFeeds();
                                } else {
                                  MainCubit.get(context).updateMenaViewedLogo(
                                      'assets/svg/mena8.svg');
                                }
                              },
                              screens: _buildScreens(),
                              items: _navBarsItems(),
                              confineInSafeArea: true,
                              backgroundColor: Colors.white,
                              handleAndroidBackButtonPress: true,
                              resizeToAvoidBottomInset: true,
                              stateManagement: true,
                              hideNavigationBarWhenKeyboardShows: true,
                              margin: const EdgeInsets.all(0.0),
                              popActionScreens: PopActionScreensType.all,
                              onWillPop: (context) async {
                                await showDialog(
                                  context: context!,
                                  useSafeArea: true,
                                  builder: (context) => Container(
                                    ///
                                    /// height:50.0,
                                    /// width:50.0,
                                    ///
                                    ///
                                    height: 50.0,
                                    width: 50.0,
                                    color: Colors.white,
                                    child: ElevatedButton(
                                      child: const Text("Close"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                );
                                return false;
                              },
                              hideNavigationBar: _hideNavBar,
                              decoration: NavBarDecoration(
                                colorBehindNavBar: Colors.white,
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    /// todo: test this
                                    color: mainBlueColor,
                                    // blurRadius: 0.001,
                                  ),
                                ],
                              ),
                              popAllScreensOnTapOfSelectedTab: true,
                              itemAnimationProperties:
                                  const ItemAnimationProperties(
                                duration: Duration(milliseconds: 400),
                                curve: Curves.ease,
                              ),
                              screenTransitionAnimation:
                                  const ScreenTransitionAnimation(
                                // Screen transition animation on change of selected tab.
                                animateTabTransition: false,
                                curve: Curves.fastOutSlowIn,
                                duration: Duration(milliseconds: 200),
                              ),
                              navBarStyle: NavBarStyle.style6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }
}

class MessengerIconBubble extends StatelessWidget {
  const MessengerIconBubble({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var mainCubit = MainCubit.get(context);
    return GestureDetector(
      onTap: () {
        if(getCachedToken() == null){
          viewMessengerLoginAlertDialog(context);
        }else if (MessengerCubit.get(context).myMessagesModel!.data.myChats!.isEmpty){
          navigateToWithoutNavBar(context, const MessengerGetStartPage(), '');
        }else{
          navigateToWithoutNavBar(context, const MessengerHomePage(), '');
        }

      },
      child: SizedBox(
        height: Responsive.isMobile(context) ? 30.w : 12.w,
        width: Responsive.isMobile(context) ? 30.w : 12.w,
        child: BlocConsumer<MainCubit, MainState>(
          listener: (context, state) {
            // TODO: implement listener
          },
          builder: (context, state) {
            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/icons/msngrFilled.svg',
                      height: Responsive.isMobile(context) ? 29.w : 12.w,
                      width: Responsive.isMobile(context) ? 29.w : 12.w,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: NotificationCounterBubble(
                      counter: mainCubit.countersModel == null
                          ? '0'
                          : mainCubit.countersModel!.data.messages.toString()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class NotificationIconBubble extends StatelessWidget {
  const NotificationIconBubble({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // viewComingSoonAlertDialog(context);
        // getCachedToken() == null
        //     ? viewMessengerLoginAlertDialog(context)
        //     : navigateToWithoutNavBar(context, const MessengerLayout(), '');
      },
      child: SizedBox(
        height: Responsive.isMobile(context) ? 30.w : 12.w,
        width: Responsive.isMobile(context) ? 30.w : 12.w,
        child: BlocConsumer<MainCubit, MainState>(
          listener: (context, state) {
            // TODO: implement listener
          },
          builder: (context, state) {
            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/icons/notification.svg',
                      height: Responsive.isMobile(context) ? 25.w : 12.w,
                      width: Responsive.isMobile(context) ? 25.w : 12.w,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: NotificationCounterBubble(
                      counter: MainCubit.get(context).countersModel == null
                          ? '0'
                          : MainCubit.get(context)
                              .countersModel!
                              .data
                              .notifications
                              .toString()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
