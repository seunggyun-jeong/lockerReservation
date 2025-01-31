import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:locker_reservation_system/main.dart';
import 'package:locker_reservation_system/user_service/login.dart';
import 'package:locker_reservation_system/user_service/signup.dart';

// 라우터 클래스
class MyRouter {
  static FluroRouter router = FluroRouter();

  static const String main = '/';
  static const String login = '/login';
  static const String register = '/register';

  /*
    핸들러
   */
  // 메인 페이지 핸들러
  static final Handler _homePageHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) =>
          MainPage(
            title: '컴퓨터공학과 사물함 예약 시스템',
          ));
  // 로그인 페이지 핸들러
  static final Handler _loginPageHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) =>
          LoginPage());
  // 회원가입 페이지 핸들러
  static final Handler _registerPageHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) =>
          SignUpPage());

  static void setupRouters() {
    router.define(main,
        handler: _homePageHandler, transitionType: TransitionType.fadeIn);
    router.define(login,
        handler: _loginPageHandler, transitionType: TransitionType.fadeIn);
    router.define(register,
        handler: _registerPageHandler, transitionType: TransitionType.fadeIn);
  }
}
