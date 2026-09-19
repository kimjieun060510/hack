# mate (Flutter · Android / iOS)

새내기의 하루를 한 곳에서 — 시간표·과제·학과 소식을 한 달력에 모으고, 밥약·과팅·놀기까지 이어주는 앱 프로토타입이에요.
(해커톤 주제: "새내기의 하루를 구제해줄 서비스")

웹으로 만들었던 프로토타입(`index.html`)을 **Flutter 앱으로 그대로 옮긴** 버전이에요.
모든 이름·일정·마감일은 **예시 데이터**이고, 학생증 인증·에브리타임 연결·푸시 알림은 **화면으로 보여주는 데모**예요(진짜 서버 연결은 없어요).

## 들어 있는 기능

- **처음 시작**: 학생증 인증(모의) → 관심사 한 번만 고르기
- **달력**: 주간/월간 보기, 날짜 칸 안에 일정 글씨가 보임, AI 건강 챙기기, 일정 추가(날짜 직접 입력 · 종류 직접 추가), 다가오는 마감
- **추천**: 관심사에 맞는 소식 → "달력에 추가", 누르면 원문 사이트로 이동, 친구와 함께 신청
- **사회생활**
  - 밥약: 날짜·시간 스크롤 선택, "지금 바로", 한마디 남기기, 익명, 친구에게 보내기 / 파티 열기
  - 과팅: 우리 팀 3명 · 날짜/시간 스크롤 선택 · 비슷한 시간대의 팀 매칭 · 익명 경고(3번이면 정지)
  - 놀기: 모임 참여하기 / 새 모임 만들기
- 받는 사람 화면(푸시 알림 미리보기), 알림 배너, 다크 모드 자동 대응

## 실행하는 방법 (처음 한 번만 준비)

같은 코드로 **안드로이드와 아이폰(iOS) 둘 다** 돼요. 폴더에 `android/`, `ios/` 가 아직 없으니 처음에 한 번 만들어 줘요.

1. [Flutter](https://docs.flutter.dev/get-started/install) 를 설치하고 `flutter doctor` 로 항목이 초록색인지 확인해요.
2. 이 폴더에서 아래를 차례로 실행해요.

```bash
# 안드로이드·iOS 폴더를 만들어요 — 처음 한 번만 (맥이 아니면 --platforms=android 만)
flutter create --platforms=android,ios --org com.mate --project-name mate .

flutter pub get
flutter run
```

`flutter create` 는 이미 있는 `lib/`, `pubspec.yaml` 은 건드리지 않고, 없는 `android/`, `ios/` 만 채워줘요.

### 안드로이드
- Android Studio를 설치하면 에뮬레이터도 같이 생겨요. 실제 폰은 USB 디버깅을 켜면 돼요.
- 폰에 설치할 파일: `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk` (카톡 등으로 보내서 설치 가능)

### 아이폰 (iOS)
- **맥 + Xcode + CocoaPods 가 꼭 필요해요** (윈도우에서는 iOS 빌드가 안 돼요).
- 시뮬레이터: `open -a Simulator` 로 켠 뒤 `flutter run`. 무료예요.
- 내 아이폰에서 돌리기: 아이폰에서 개발자 모드를 켜고(설정 › 개인정보 보호 및 보안 › 개발자 모드), `ios/Runner.xcworkspace` 를 Xcode로 열어 Signing & Capabilities 에서 내 Apple ID(무료 계정)를 Team 으로 고른 뒤 `flutter run`. 무료 계정으로 깐 앱은 일정 기간(보통 7일)이 지나면 다시 설치해야 해요.
- 다른 사람 아이폰에 나눠주기(TestFlight)나 앱스토어 출시는 Apple Developer Program(연 $99)이 필요해요. 안드로이드처럼 파일 하나를 보내서 설치하는 방식은 안 돼요.

홈 화면 이름이 `mate`(또는 `Mate`)로 나와요. 바꾸려면 안드로이드는 `android/app/src/main/AndroidManifest.xml` 의 `android:label`, iOS는 `ios/Runner/Info.plist` 의 `CFBundleDisplayName` 을 고치면 돼요.

## 파일 설명 — 어디를 고치면 되나요?

| 바꾸고 싶은 것 | 파일 |
| --- | --- |
| 앱 이름, 예시 일정/추천 소식/친구 이름, 추천 소식 링크 주소 | `lib/data.dart` |
| 색깔, 글꼴, 아이콘 | `lib/theme.dart` (`Pal.light` / `Pal.dark`) |
| 버튼을 눌렀을 때 일어나는 일, 예시 일정, 알림 문구 | `lib/state.dart` |
| 공통 부품(버튼, 칩, 카드, 스크롤 선택) | `lib/widgets.dart` |
| 아래에서 올라오는 창(일정 추가, 알림, 내 정보 …) | `lib/sheets.dart` |
| 화면 뼈대, 배너, 받는 사람 화면 | `lib/shell.dart` |
| 각 탭 화면 | `lib/screens/` (`onboarding` · `calendar` · `reco` · `social`) |

## 알아두세요

- 이 코드는 Dart 분석기(`dart analyze`)의 타입 검사는 통과했지만, **제가 있던 환경에서는 Flutter로 직접 빌드·실행해 보지는 못했어요.** (iOS도 마찬가지예요.)
  처음 `flutter run` 했을 때 오류가 나거나 화면이 어색하면 오류 메시지를 알려주세요. 바로 고칠 수 있어요.
- `url_launcher` 로 추천 소식의 원문 사이트를 열어요. 안 열리면 `android/app/src/main/AndroidManifest.xml` 의 `<manifest>` 안에 아래를 넣어보세요.

```xml
<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
</queries>
```

- 제목 글꼴은 주아체(Jua, OFL 라이선스)예요. 라이선스 파일은 `assets/fonts/OFL.txt`.
- 진짜 푸시 알림, 로그인/학생증 인증, 에브리타임 연동은 아직 구현하지 않았어요 (서버가 필요해요).
- 안드로이드 뒤로가기 버튼은 앱 안의 이전 화면으로 돌아가도록 되어 있어요. 아이폰에는 뒤로가기 버튼이 없어서 화면 왼쪽 위 `<` 버튼으로 이동해요.
