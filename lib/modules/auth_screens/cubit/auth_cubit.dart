import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mena/core/cache/cache.dart';
import 'package:mena/core/main_cubit/main_cubit.dart' as mainCubit;
import 'package:mena/core/shared_widgets/shared_widgets.dart';
import 'package:mena/models/api_model/config_model.dart';
import 'package:mena/models/api_model/home_section_model.dart';
import 'package:mena/models/api_model/user_info_model.dart';
import 'package:mena/modules/main_layout/main_layout.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/constants.dart';
import '../../../core/constants/validators.dart';
import '../../../core/dialogs/dialogs_page.dart';
import '../../../core/functions/main_funcs.dart';
import '../../../core/network/dio_helper.dart';
import '../../../core/network/network_constants.dart';
import '../../../models/api_model/categories_model.dart';
import '../../../models/api_model/provider_types.dart';
import '../../../models/api_model/register_model.dart';
import '../../home_screen/cubit/home_screen_cubit.dart';
import '../../home_screen/home_screen.dart';
import '../../splash_screen/route_engine.dart';
import '../sign_in_screen.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static AuthCubit get(context) => BlocProvider.of(context);

  CategoriesModel? platformCategory;
  MenaPlatform? selectedPlatform;

  List<MenaCategory>? selectedSpecialities;
  MenaCategory selectedMenaCategory = MenaCategory(id: -1);
  MenaCategory selectedSubMenaCategory = MenaCategory(id: -1);
  ProviderTypeItem selectedProviderType = ProviderTypeItem(id: -1);
  String selectedSignupUserType = 'provider';
  String? phone;
  String? resetPassPhone;
  String otpText = '';
  String passOtpText = '';
  RegisterModel? registerModel;
  UserInfoModel? userinfoModel;
  AutovalidateMode? autoValidateMode = AutovalidateMode.disabled;
  AutovalidateMode? resetPassAutoValidateMode = AutovalidateMode.disabled;

  bool confirmPassVisible = false;
  bool passVisible = false;

  ///
  /// filters functions
  ///
  void resetCategoriesFilters() {
    updateSelectedSpecialities([]);
    updateSelectedMenaCategory(MenaCategory(id: -1));
    updateSelectedSubMenaCategory(MenaCategory(id: -1));
  }

  void updateOtpVal(String val) {
    otpText = val;
  }

  void logout(BuildContext context) {
    removeToken();
    mainCubit.MainCubit.get(context).removeUserModel();
    navigateToAndFinishUntil(context, SignInScreen());
  }

  void updateSelectedUserType(String val) {
    selectedSignupUserType = val;
    emit(SignupUserTypeUpdated());
  }

  void updateSelectedPlatform(MenaPlatform platform, bool updateProviderTypes) {
    selectedPlatform = platform;

    /// when platform changed reset all
    resetCategoriesFilters();

    ///
    if (updateProviderTypes) {
      getPlatformCategories(selectedPlatform!.id.toString());
    }
    emit(SelectedPlatformUpdated());
  }

  void updateSelectedMenaCategory(MenaCategory menaCategory) {
    selectedMenaCategory = menaCategory;

    ///
    ///
    /// when category changed reset sub and specialists
    ///
    ///
    ///
    updateSelectedSubMenaCategory(MenaCategory(id: -1));
    // updateSelectedSpecialities([]);
    if (selectedMenaCategory.childs != null) {
      updateSelectedSubMenaCategory(selectedMenaCategory.childs![0]!);
    }
    emit(SelectedPlatformUpdated());
  }

  void updateSelectedSubMenaCategory(MenaCategory menaCategory) {
    selectedSubMenaCategory = menaCategory;

    ///
    ///
    /// when sub category changed reset  specialists
    ///
    ///
    ///
    emit(SelectedPlatformUpdated());
  }

  void updateSelectedSpecialities(List<MenaCategory> values) {
    // selectedSpecialities?.clear();
    // emit(SelectedPlatformUpdated());
    selectedSpecialities = values;
    // if (updateProviderTypes) {
    //   getPlatformCategories(selectedPlatform!.id.toString());
    // }
    emit(SelectedPlatformUpdated());
  }

  /// end filters functions
  ///
  void updatePhoneNum(String? val) {
    if (val != null) {
      phone = val;
    }
  }

  void updateResetPassPhoneNum(String? val) {
    if (val != null) {
      resetPassPhone = val;
    }
  }

  void togglePassVisibilityFalse() {
    passVisible = false;
    confirmPassVisible = false;
    emit(PassVisibilityChanged());
  }

  void toggleVisibility(String val) {
    if (val == 'pass') {
      passVisible = !passVisible;
    } else if (val == 'confirmPass') {
      confirmPassVisible = !confirmPassVisible;
    }
    emit(PassVisibilityChanged());
  }

  void toggleResetPassAutoValidate(bool val) {
    if (val == true) {
      resetPassAutoValidateMode = AutovalidateMode.always;
    } else {
      resetPassAutoValidateMode = AutovalidateMode.disabled;
    }
    emit(ChangeAutoValidateModeState());
  }

  void toggleAutoValidate(bool val) {
    if (val == true) {
      autoValidateMode = AutovalidateMode.always;
    } else {
      autoValidateMode = AutovalidateMode.disabled;
    }
    emit(ChangeAutoValidateModeState());
  }

  void changeSelectedProviderType(ProviderTypeItem val) {
    selectedProviderType = val;
    emit(ChangeAutoValidateModeState());
  }

  Future<bool> userRegister({
    required String fullName,
    required String email,
    required String userName,
    required String phone,
    required String? dateOfBirth,
    required String pass,
    required int? platformId,
    required List<int>? specialitiesList,
    required BuildContext context,
  }) async {
    emit(AuthLoadingState());

    bool result = false;

    MainDioHelper.postData(url: registerEnd, data: {
      'full_name': fullName,
      'user_name': userName,
      'email': email,
      'phone': phone,
      'password': pass,
      'password_confirmation': pass,
      // 'user_type': providerType ?? '-1',
      'specialities': specialitiesList.toString(),
      'platform_id': platformId,
      'date_of_birth': dateOfBirth,
    }).then((value) async {
      logg('#### sign up response: $value');
      // registerModel = RegisterModel.fromJson(value);
      saveCacheToken(value.data.token);
      logg('#### sssssssssssssssssssssss: ${value.data.token}');
      
      logg('registerModel is  : $value');
      logg('dddddddddddddddddddddd : $value');
      
      if (value.statusCode.toString() == "200") {
        result = true;
      } else {
        result = false;
      }

      
      // if (userSignUpModel != null) {
      //   userCacheProcess(userSignUpModel!).then((value) => checkUserAuth().then(
      //           (value) =>
      //           navigateToAndFinishUntil(context, const MainAppMaterialApp())));
      //   // navigateToAndFinishUntil(context, MainAppMaterialApp());
      //
      // }
      ///
      /// cache process and navigate due to status
      ///
      // await HomeScreenCubit.get(context)
      //   ..changeSelectedHomePlatform(registerModel?.data.user.platform?.id ??
      //       mainCubit.MainCubit.get(context)
      //           .configModel!
      //           .data
      //           .platforms[0]
      //           .id!);
      // userCacheProcessAndNavigate(context);
      //
      // userCacheProcessAndNavigate(context);
      // emit(SignUpSuccessState());
      // return result;
    }).catchError((error) {
      showMessageDialog(context: context, message: error.response.toString());
      logg(error.response.toString());
      emit(AuthErrorState(getErrorMessageFromErrorJsonResponse(error)));
      result = false;
      // return result;
    });
    return result;
  }

  Future<void> getPlatformCategories(String platformId) async {
    platformCategory = null;
    emit(AuthGetPlatformCategoriesLoadingState());
    await MainDioHelper.getData(
        url: '${platformCategoriesEnd}/${platformId.toString()}',
        query: {}).then((value) async {
      logg('getProviderTypes response: $value');
      platformCategory = CategoriesModel.fromJson(value.data);

      if (platformCategory!.data.isNotEmpty) {
        updateSelectedMenaCategory(platformCategory!.data[0]);
      } else {
        updateSelectedMenaCategory(MenaCategory(id: -1));
      }
      // if (platformCategory!.childs!.isNotEmpty) {
      //   changeSelectedProviderType(platformCategory!.data[0]);
      // }

      emit(SignUpSuccessState());
    }).catchError((error) {
      logg(error.response.toString());
      emit(AuthErrorState(getErrorMessageFromErrorJsonResponse(error)));
    });
  }

  Future<void> userLogin({
    required String email,
    required String pass,
    required BuildContext context,
  }) async {
    emit(AuthLoadingState());
    Map<String, dynamic> body = {};

    if (email.contains("@")) {
      //// email status
      body = {
        'email': email,
        'password': pass,
      };
    } else if (isNumeric(email)) {
      //// phone status
      body = {
        'phone': email,
        'password': pass,
      };
    } else {
      /// username statue
      body = {
        'username': email,
        'password': pass,
      };
    }

    MainDioHelper.postData(url: loginEnd, data: body).then((value) async {
      logg('### login response: $value');
      registerModel = RegisterModel.fromJson(value.data);
      userinfoModel = UserInfoModel.fromJson(value.data);
      mainCubit.MainCubit.get(context).userInfoModel = userinfoModel;
      print('userinfoModallllllll : ${userinfoModel}');
      
      await HomeScreenCubit.get(context)
        ..changeSelectedHomePlatform(
            registerModel?.data.user.platform?.id ??
                mainCubit.MainCubit.get(context).configModel!.data.platforms[0].id!
        );      userCacheProcessAndNavigate(context);
      emit(SignUpSuccessState());
    }).catchError((error, stack) {
      logg("# Error : ${error.toString()}");
      logg("# Error : ${stack.toString()}");
      print("# Error : ${stack.toString()}");
      emit(AuthErrorState(getErrorMessageFromErrorJsonResponse(error)));
    });
  }

  Future<bool> submitResetPass({
    required String pass,
    required String phone,
    required String code,
    required BuildContext context,
  }) async {
    log("# password : $pass");
    log("# phone : $phone");
    log("# code : $code");

    emit(SubmittingResetPass());

    bool finalStatue = false;

    await MainDioHelper.postData(url: submitResetPassEnd, data: {
      'phone': phone,
      'code': code,
      'password': pass,
      'password_confirmation': pass,
    }).then((value) {
      logg('Password reset successfully: ${value}');
      logg('Password status code: ${value.statusCode}');

      /// cache process and navigate due to status
      ///
      ///
      if (value.statusCode.toString() == '200') {
        finalStatue = true;
      } else {
        finalStatue = false;
      }
      emit(SignUpSuccessState());
    }).catchError((error) {
      logg(error.response.toString());
      emit(AuthErrorState(getErrorMessageFromErrorJsonResponse(error)));
      finalStatue = false;
    });
    return finalStatue;
  }

  Future<void> resetPasswordRequestOtp({
    required BuildContext context,
  }) async {
    var formKey = GlobalKey<FormState>();
    var inController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: formKey,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  'assets/back.png', // Replace with your image path
                  scale: 3,
                  alignment:
                      Alignment.centerRight, // Adjust the height as needed
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 18, right: 160),
                  child: Text(
                    'Forget Password',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PNfont',
                      color: Color(0xff152026),
                    ),
                  ),
                ),
              ],
            ),
            body: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                // TODO: implement listener
                log("# new state : $state");
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 25, top: 5, right: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(),
                          heightBox(15.h),
                          Text(
                            'Enter phone number or email or username',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'PNfont',
                              color: Color(0xff303840),
                            ),
                            // textAlign: TextAlign.center,
                          ),
                          heightBox(5.h),
                          Text(
                            textAlign: TextAlign.start,
                            "Can't reset your password?",
                            style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'PNfont',
                                color: Color(0xff0077FF),
                                fontWeight: FontWeight.w900),
                          ),
                          heightBox(10.h),
                          DefaultInputField(
                            fillColor: hasError
                                ? Color(0xffF2D5D5)
                                : Color(0xffF2F2F2),
                            focusedBorderColor: hasError
                                ? Color(0xffE72B1C)
                                : Color(0xff0077FF),
                            unFocusedBorderColor: Color(0xffC9CBCD),
                            label: 'Username, email or mobile number',
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Color(0xff152026),
                              ),
                              onPressed: () {
                                inController.clear();
                              },
                            ),
                            labelTextStyle: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PNfont',
                                color: Color(0xff999B9D)),
                            controller: inController,
                            validate: normalInputValidate,
                          ),
                          heightBox(10.h),
                          Text(
                            hasError
                                ? "Check your username, mobile or email address  and try again"
                                : "",
                            style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PNfont',
                                color: Color(0xffE72B1C)),
                          ),
                          heightBox(450.h),
                          state is ProceedingToResetPass
                              ? const DefaultLoaderGrey()
                              : Row(
                                  children: [
                                    Expanded(
                                      child: DefaultButton(
                                        text: "Find Account",
                                        onClick: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          if (formKey.currentState!
                                              .validate()) {
                                            resetPassRequest(inController.text)
                                                .then((value) {
                                              log("#value of reset :$value");
                                              if (value == false) {
                                                showUserNameErrorDialog(
                                                    context);
                                              } else {
                                                showConfirmationDialog(context);
                                                pinCode(
                                                    context: context,
                                                    phone: inController.text);
                                              }
                                            });
                                          } else {}
                                        },
                                      ),
                                    )
                                    // : Expanded(
                                    //     child: DefaultButton(
                                    //       text: "Send",
                                    //       onClick: () {
                                    //         FocusManager
                                    //             .instance.primaryFocus
                                    //             ?.unfocus();
                                    //         if (formKey.currentState!
                                    //             .validate()) {
                                    //           pinCode(
                                    //               context: context,
                                    //               phone: inController
                                    //                   .text);
                                    //         } else {}
                                    //       },
                                    //     ),
                                    //   ),
                                  ],
                                ),
                          state is VerifyingNumErrorState
                              ? Text(
                                  "Check your username, mobile or email address  and try again",
                                  style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'PNfont',
                                      color: Color(0xffE72B1C)),
                                  textAlign: TextAlign.center,
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> userCacheProcessAndNavigate(BuildContext context) async {
    final TextEditingController smsCodeEditingController =
        TextEditingController();
    mainCubit.MainCubit.get(context).getUserInfo();
    if (registerModel != null) {
      print('token in userCacheProcess : ${registerModel!.data.token}');
      saveCacheToken(registerModel!.data.token);
      print('the token isssssssssssss : ${registerModel!.data.user.fullName}');
      if (registerModel!.data.user.phoneVerifiedAt == null) {
        ///show otp alert dialog
        showConfirmationDialog(context);

        

      } else {
        navigateToAndFinishUntil(context, const RouteEngine());
      }
    }
  }

  Future<bool> verifyPhoneNumber(String currentPhone) async {
    emit(VerifyingNumState());
    await MainDioHelper.postData(url: verifyCodeEnd, data: {
      'phone': currentPhone,
      'code': otpText,
    }).then((value) {
      logg('Verify num response: $value');
      return true;
    }).catchError((error) {
      logg(error.response.toString());
      emit(VerifyingNumErrorState(getErrorMessageFromErrorJsonResponse(error)));
    });
    return false;
  }

  Future<bool?> resetPassRequest(String input) async {
    emit(ProceedingToResetPass());
    log("# input is : $input");
    Map<String, dynamic> body = {
      'phone': input,
    };
    bool resultState = false;
    await MainDioHelper.postData(url: requestResetPassOtpEnd, data: body)
        .then((value) {
      logg('Verify num response Reset Password: $value');
      resultState = true;
      return true;
    }).catchError((error) {
      logg("# Error  : ${error.response.toString()}");
      resultState = false;
      emit(VerifyingNumErrorState(getErrorMessageFromErrorJsonResponse(error)));
      return false;
    });
    return resultState;
  }

  //// check if code is correct
  Future<bool?> checkCodeValidateRequest(String email, String code) async {
    log("# code is : $code");
    log("# email is : $email");
    Map<String, dynamic> body = {
      'email': email,
      'code': code,
    };
    bool resultState = false;
    await MainDioHelper.postData(url: verifyCodeResetPassword, data: body)
        .then((value) {
      logg('Verify num response Reset Password: $value');
      resultState = true;
      return true;
    }).catchError((error) {
      logg("# Error  : ${error.response.toString()}");
      emit(VerifyingNumErrorState(getErrorMessageFromErrorJsonResponse(error)));
      resultState = false;
      return false;
    });
    return resultState;
  }

  Future showResetPassPopUp(
      BuildContext context, String phone, String identity) {
    final TextEditingController smsPassCodeEditingController =
        TextEditingController();
    var formKey = GlobalKey<FormState>();
    var newPassCont = TextEditingController();
    var newPassConfirmCont = TextEditingController();
    toggleResetPassAutoValidate(false);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: formKey,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  'assets/back.png', // Replace with your image path
                  scale: 4,
                  alignment:
                      Alignment.centerRight, // Adjust the height as needed
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 18, right: 90),
                  child: Text(
                    'Create a new Password',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PNfont',
                      color: Color(0xff152026),
                    ),
                  ),
                ),
              ],
            ),
            body: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 25, top: 5, right: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(),
                          heightBox(15.h),
                          Text(
                            'Please set a password that includes at least 8 letters and numbers. You will use this password to sign into your account',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'PNfont',
                              color: Color(0xff303840),
                            ),
                            // textAlign: TextAlign.center,
                          ),
                          heightBox(5.h),
                          heightBox(10.h),
                          DefaultInputField(
                            fillColor: hasError
                                ? Color(0xffF2D5D5)
                                : Color(0xffF2F2F2),
                            focusedBorderColor: hasError
                                ? Color(0xffE72B1C)
                                : Color(0xff0077FF),
                            unFocusedBorderColor: Color(0xffC9CBCD),
                            label: 'New password',
                            controller: newPassCont,
                            labelTextStyle: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PNfont',
                                color: Color(0xff999B9D)),
                            validate: normalInputValidate,
                          ),
                          heightBox(10.h),
                          DefaultInputField(
                            fillColor: Color(0xffF2F2F2),
                            focusedBorderColor: Color(0xff0077FF),
                            unFocusedBorderColor: Color(0xffC9CBCD),
                            controller: newPassConfirmCont,
                            label: 'Confirm new password',
                            labelTextStyle: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PNfont',
                                color: Color(0xff999B9D)),
                            validate: normalInputValidate,
                          ),
                          heightBox(410.h),
                          state is ProceedingToResetPass
                              ? const DefaultLoaderGrey()
                              : Row(
                                  children: [
                                    Expanded(
                                      child: DefaultButton(
                                          text: "Done",
                                          onClick: () async {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();

                                            toggleResetPassAutoValidate(true);

                                            toggleResetPassAutoValidate(true);
                                            log("# password : ${newPassCont.text}");
                                            log("# password confirm : ${newPassConfirmCont.text}");
                                            if (newPassCont.text !=
                                                newPassConfirmCont.text) {
                                              showMessageDialog(
                                                  context: context,
                                                  message:
                                                      "The two passwords do not match");
                                            } else if (newPassCont.text.length <
                                                6) {
                                              logg('password must be 6 digits');
                                              showMessageDialog(
                                                  context: context,
                                                  message:
                                                      "password must be 6 digits");
                                            } else {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                log("# code : $identity");
                                                var result =
                                                    await submitResetPass(
                                                        pass: newPassCont.text,
                                                        context: context,
                                                        phone: phone,
                                                        code: identity);

                                                if (result) {
                                                  showMessageDialog(
                                                      context: context,
                                                      message:
                                                          "Password reset Successfully");
                                                  navigateTo(
                                                      context, SignInScreen());
                                                } else {
                                                  pinCodeAlertDialog(context);
                                                }
                                              }
                                            }
                                          }),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    // showMyAlertDialog(
    //     context, getTranslatedStrings(context).enterConfirmationCode,
    //     alertDialogContent: BlocConsumer<AuthCubit, AuthState>(
    //       listener: (context, state) {
    //         // TODO: implement listener
    //       },
    //       builder: (context, state) {
    //         return SizedBox(
    //           width: double.maxFinite,
    //           child: Form(
    //             key: formKey,
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               mainAxisSize: MainAxisSize.min,
    //               children: [
    //                 Text(
    //                   getTranslatedStrings(context)
    //                       .enterConfirmationCodeWeSentTYourEmailPhone,
    //                   style: mainStyle(context, 13.0,
    //                       color: newDarkGreyColor, weight: FontWeight.w700),
    //                   textAlign: TextAlign.center,
    //                 ),
    //                 heightBox(10.h),
    //                 PinCodeTextField(
    //                   onChanged: (value) {
    //                     passOtpText = value;
    //                   },
    //                   keyboardType: TextInputType.number,
    //                   appContext: context,
    //                   length: 6,
    //                   obscureText: false,
    //                   textStyle: const TextStyle(
    //                     color: Colors.white,
    //                   ),
    //                   pinTheme: PinTheme(
    //                     selectedFillColor: softBlueColor,
    //                     inactiveColor: mainBlueColor,
    //                     activeColor: mainBlueColor,
    //                     inactiveFillColor: Colors.white,
    //                     selectedColor: mainBlueColor.withOpacity(0.5),
    //                     shape: PinCodeFieldShape.box,
    //                     borderRadius: BorderRadius.circular(5),
    //                     fieldHeight: 50,
    //                     fieldWidth: 40,
    //                     activeFillColor: Theme.of(context).backgroundColor,
    //                   ),
    //                   cursorColor: Theme.of(context).backgroundColor,
    //                   animationDuration: const Duration(milliseconds: 300),
    //                   //backgroundColor:  Theme.of(context).backgroundColor,
    //                   enableActiveFill: true,
    //                   controller: smsPassCodeEditingController,
    //                 ),
    //                 heightBox(10.h),
    //                 DefaultInputField(
    //                   obscureText: !passVisible,
    //                   autoValidateMode: resetPassAutoValidateMode,
    //                   controller: newPassCont,
    //                   validate: passwordValidate(context),
    //                   // labelWidget: IconLabelInputWidget(
    //                   //   svgAssetLink: 'assets/svg/icons/password key.svg',
    //                   //   labelText: '${getTranslatedStrings(context).newPassword}',
    //                   // ),
    //                   label: '${getTranslatedStrings(context).newPassword}',
    //                   suffixIcon: GestureDetector(
    //                     onTap: () {
    //                       toggleVisibility('pass');
    //                     },
    //                     child: SvgPicture.asset(
    //                       /// HERE ADD CONDITION IF VISIBLE ASSET LINK WILL BE DEIFFERENT
    //                       passVisible
    //                           ? 'assets/svg/icons/open_eye.svg'
    //                           : 'assets/svg/icons/closed eye.svg',
    //                       width: 18.w,
    //                       height: 18.w,
    //                     ),
    //                   ),
    //                 ),
    //                 heightBox(10.h),
    //                 DefaultInputField(
    //                   obscureText: !confirmPassVisible,
    //                   autoValidateMode: resetPassAutoValidateMode,
    //                   validate: (String? val) {
    //                     if (val!.isEmpty) {
    //                       return 'Please reType Password';
    //                     }
    //                     if (val != newPassCont.text) {
    //                       return 'password not match';
    //                     }
    //                     return null;
    //                   },
    //                   // labelWidget: IconLabelInputWidget(
    //                   //   svgAssetLink: 'assets/svg/icons/password key.svg',
    //                   //   labelText: '${getTranslatedStrings(context).retypePass}',
    //                   // ),
    //                   label: '${getTranslatedStrings(context).retypePass}',
    //                   suffixIcon: GestureDetector(
    //                     onTap: () {
    //                       toggleVisibility('confirmPass');
    //                     },
    //                     child: SvgPicture.asset(
    //                       /// HERE ADD CONDITION IF VISIBLE ASSET LINK WILL BE DIFFERENT
    //                       confirmPassVisible
    //                           ? 'assets/svg/icons/open_eye.svg'
    //                           : 'assets/svg/icons/closed eye.svg',
    //                       width: 18.w,
    //                       height: 18.w,
    //                     ),
    //                   ),
    //                 ),
    //                 heightBox(10.h),
    //                 state is SubmittingResetPass
    //                     ? const DefaultLoaderGrey()
    //                     : DefaultButton(
    //                         text: 'Reset password',
    //                         onClick: () {
    //                           toggleResetPassAutoValidate(true);
    //                           if (passOtpText.length < 6) {
    //                             logg('otp must be 6 digits');
    //                           } else {
    //                             if (formKey.currentState!.validate()) {
    //                               submitResetPass(
    //                                   pass: newPassCont.text,
    //                                   context: context,
    //                                   identity: identity);
    //                             }
    //                           }
    //                         }),
    //                 heightBox(10.h),
    //                 state is VerifyingNumErrorState
    //                     ? Text(
    //                         "Check your username, mobile or email address  and try again",
    //                         style: TextStyle(
    //                             fontSize: 13.0,
    //                             fontWeight: FontWeight.w500,
    //                             fontFamily: 'PNfont',
    //                             color: Color(0xffE72B1C)),
    //                         textAlign: TextAlign.center,
    //                       )
    //                     : const SizedBox()
    //               ],
    //             ),
    //           ),
    //         );
    //       },
    //     ));
  }

  Future<void> pinCode(
      {required BuildContext context, required String phone}) async {
    var formKey = GlobalKey<FormState>();
    var inController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: formKey,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: InkWell(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  'assets/back.png', // Replace with your image path
                  scale: 3,
                  alignment:
                      Alignment.centerRight, // Adjust the height as needed
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 18, right: 120),
                  child: Text(
                    'Confirm your account',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PNfont',
                      color: Color(0xff152026),
                    ),
                  ),
                ),
              ],
            ),
            body: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: 25, top: 5, right: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(),
                          heightBox(15.h),
                          Text(
                            'We sent a code to your email. Enter that code to confirm your account',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'PNfont',
                              color: Color(0xff303840),
                            ),
                            // textAlign: TextAlign.center,
                          ),
                          heightBox(5.h),
                          heightBox(10.h),
                          DefaultInputField(
                            fillColor: Color(0xffF2F2F2),
                            focusedBorderColor: Color(0xff0077FF),
                            unFocusedBorderColor: Color(0xffC9CBCD),
                            label: 'Enter code',
                            labelTextStyle: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PNfont',
                                color: Color(0xff999B9D)),
                            controller: inController,
                            validate: normalInputValidate,
                          ),
                          heightBox(10.h),
                          heightBox(470.h),
                          state is ProceedingToResetPass
                              ? const DefaultLoaderGrey()
                              : Row(
                                  children: [
                                    Expanded(
                                      child: DefaultButton(
                                        text: "Continue",
                                        onClick: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();

                                          toggleResetPassAutoValidate(true);

                                          if (inController.text.length < 6) {
                                            logg('otp must be 6 digits');
                                          } else {
                                            if (formKey.currentState!
                                                .validate()) {
                                              checkCodeValidateRequest(
                                                      phone, inController.text)
                                                  .then((value) {
                                                log("# code :$value");
                                                if (value == false) {
                                                  pinCodeAlertDialog(context);
                                                } else {
                                                  showResetPassPopUp(
                                                    context,
                                                    phone,
                                                    inController.text,
                                                  );
                                                }
                                              });
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                          state is VerifyingNumErrorState
                              ? Text(
                                  "Check your username, mobile or email address  and try again",
                                  style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'PNfont',
                                      color: Color(0xffE72B1C)),
                                  textAlign: TextAlign.center,
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 5),
      content: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          margin: EdgeInsets.symmetric(vertical: 100, horizontal: 0),
          decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(5)),
          child: const Text(
            'Code was sent',
            style: TextStyle(color: Colors.white, fontSize: 14),
          )),
    ));
  }
}
