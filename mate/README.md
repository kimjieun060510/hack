# mate (Flutter · 안드로이드 / 아이폰 / 웹)

새내기의 하루를 한 곳에서 — 시간표·과제·학과 소식을 한 달력에 모으고, 밥약·과팅·놀기까지 이어주는 앱 프로토타입이에요.
(해커톤 주제: "새내기의 하루를 구제해줄 서비스")

웹으로 만들었던 프로토타입(`../index.html`)을 **Flutter 앱으로 그대로 옮긴** 버전이에요.
모든 이름·일정·마감일은 **예시 데이터**이고, 학생증 인증·에브리타임 연결·푸시 알림은 **화면으로 보여주는 데모**예요(진짜 서버 연결은 없어요).

## 터미널에 이렇게 치면 돼요

먼저 [Flutter](https://docs.flutter.dev/get-started/install) 를 설치한 뒤, 터미널에서 이 폴더로 들어가요.

```bash
cd mate
flutter pub get
```

그다음 **쓰는 시뮬레이터에 맞춰** 하나만 치면 돼요.

### 아이폰 시뮬레이터 (맥)

```bash
open -a Simulator
flutter run -d ios
```

시뮬레이터가 이미 켜져 있으면 `flutter run -d ios` 만 해도 돼요.

### 안드로이드 에뮬레이터

Android Studio에서 에뮬레이터를 켠 다음:

```bash
flutter run -d android
```

에뮬레이터 목록을 보고 직접 켜려면:

```bash
flutter emulators
flutter emulators --launch <에뮬레이터_id>
flutter run
```

### 크롬에서 폰처럼 보기 (맥 / 윈도우 / 리눅스)

시뮬레이터가 아직 없으면 이 명령이 제일 빨라요.

```bash
flutter run -d chrome
```

### 연결된 기기가 여러 개일 때

```bash
flutter devices
flutter run -d <기기_id>
```

예: 아이폰 시뮬레이터만 고르려면 `flutter run -d iPhone`, 안드로이드면 `flutter run -d emulator`.

---

설치가 잘 됐는지는 `flutter doctor` 로 확인해요. 안드로이드는 Android Studio, 아이폰은 **맥 + Xcode** 가 필요해요. 윈도우에서는 iOS 시뮬레이터를 켤 수 없어요.

## 들어 있는 기능

- **처음 시작**: 학생증 인증(모의) → 관심사 한 번만 고르기
- **달력**: 주간/월간 보기, 날짜 칸 안에 일정 글씨가 보임, AI 건강 챙기기, 일정 추가(날짜 직접 입력 · 종류 직접 추가), 다가오는 마감
- **추천**: 관심사에 맞는 소식 → "달력에 추가", 누르면 원문 사이트로 이동, 친구와 함께 신청
- **사회생활**
  - 밥약: 날짜·시간 스크롤 선택, "지금 바로", 한마디 남기기, 익명, 친구에게 보내기 / 파티 열기
  - 과팅: 우리 팀 3명 · 날짜/시간 스크롤 선택 · 비슷한 시간대의 팀 매칭 · 익명 경고(3번이면 정지)
  - 놀기: 모임 참여하기 / 새 모임 만들기
- 받는 사람 화면(푸시 알림 미리보기), 알림 배너, 다크 모드 자동 대응

## 폰에 설치할 파일 만들기

```bash
# 안드로이드 APK
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

아이폰은 맥에서 `ios/Runner.xcworkspace` 를 Xcode로 열어 Signing & Capabilities 에서 Apple ID를 Team으로 고른 뒤 `flutter run` 하면 돼요.

홈 화면 이름은 `mate`예요. 바꾸려면 안드로이드는 `android/app/src/main/AndroidManifest.xml` 의 `android:label`, iOS는 `ios/Runner/Info.plist` 의 `CFBundleDisplayName` 을 고치면 돼요.

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

- 제목 글꼴은 주아체(Jua, OFL 라이선스)예요. 라이선스 파일은 `assets/fonts/OFL.txt`.
- 진짜 푸시 알림, 로그인/학생증 인증, 에브리타임 연동은 아직 구현하지 않았어요 (서버가 필요해요).
- 안드로이드 뒤로가기 버튼은 앱 안의 이전 화면으로 돌아가도록 되어 있어요. 아이폰에는 뒤로가기 버튼이 없어서 화면 왼쪽 위 `<` 버튼으로 이동해요.
