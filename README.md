# MATE

새내기의 하루를 구제해줄 서비스 — 해커톤 디자인 프로토타입

시간표·과제·학과 공지를 한 달력에 모으고, 밥약·과팅·놀기로 사람도 이어주는 새내기용 앱입니다.

## 시뮬레이터에서 실행 (Flutter 앱)

터미널에 아래를 그대로 치면 돼요.

```bash
cd mate-flutter
flutter pub get
```

그다음 쓰는 환경에 맞춰 **한 줄만** 더 치면 됩니다.

```bash
# 아이폰 시뮬레이터 (맥)
open -a Simulator
flutter run -d ios

# 안드로이드 에뮬레이터 (에뮬레이터를 먼저 켠 뒤)
flutter run -d android

# 시뮬레이터가 없으면 크롬에서 보기
flutter run -d chrome
```

자세한 설명은 [`mate-flutter/README.md`](mate-flutter/README.md) 에 있어요. Flutter가 아직 없으면 [설치 가이드](https://docs.flutter.dev/get-started/install)를 먼저 따라가면 됩니다. 설치 확인은 `flutter doctor` 입니다.

## 브라우저에서 바로 보기 (HTML 프로토타입)

`index.html` 을 더블클릭해도 되고, 터미널에서는:

```bash
python3 -m http.server 8080
```

브라우저에서 http://localhost:8080 을 열면 됩니다. 설치가 필요 없어요.

## 화면 구성

| 탭 | 내용 |
|---|---|
| 추천 | 관심 분야에 맞는 소식 추천, 누르면 원문으로 이동, "달력에 추가" |
| 달력 | 주간·월간 보기, 일정 종류 필터, 직접 일정 추가, AI 건강 챙기기 |
| 사회생활 | 밥약(익명·한마디), 과팅(3명 팀·매너 경고), 놀기, 푸시·배너 알림 |

## 참고

- 화면에 나오는 이름, 일정, 공지는 모두 예시 데이터입니다. 실제 학교 시스템과 연동되어 있지 않습니다.
- 웹 프로토타입은 `index.html` 한 파일에 들어 있습니다. 앱 이름은 `APP_NAME`, 추천 소식은 `OPPS`에서 바꿀 수 있습니다.
- Flutter 앱 코드는 `mate-flutter/` 폴더에 있습니다.
