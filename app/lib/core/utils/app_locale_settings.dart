import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// 앱 언어 설정 원본: 고정 언어(한국어), 지원 언어, 시스템 위젯 번역 묶음
/// 앱 엔진·잠금화면 엔진 MaterialApp 2곳이 같은 값을 씀 (#995)
abstract final class AppLocaleSettings {
  // 한국 대상 출시라 기기 언어와 무관하게 한국어 고정
  static const Locale locale = Locale('ko');

  static const List<Locale> supportedLocales = [Locale('ko'), Locale('en')];

  // 라이선스 화면·복사 메뉴·날짜 선택 등 Material·Cupertino 기본 문구
  static const List<LocalizationsDelegate<Object>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
