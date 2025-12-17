# Firestore CRUD Example

## 프로젝트 소개
이 프로젝트는 Flutter와 Firebase Firestore를 활용하여 실시간 CRUD(생성, 읽기, 수정, 삭제) 기능을 구현한 모바일 앱 예제입니다. 사용자는 Firestore 데이터베이스 내의 데이터를 실시간으로 확인하고, 추가/수정/삭제할 수 있습니다.

## 기술 스택
- [Flutter](https://flutter.dev/)
- [Firebase Firestore](https://firebase.google.com/docs/firestore)
- [Dart](https://dart.dev/)

## 주요 기능
- Firestore 데이터 스트림 실시간 구독
- 데이터 목록 조회 및 실시간 UI 반영
- 데이터 추가/수정/삭제 지원
- 에러 및 빈 데이터 처리

## 프로젝트 구조

```
lib/
├── main.dart            # 앱 진입점 및 전체 위젯 트리 구성
├── firebase_options.dart # Firebase 초기화 옵션 (자동 생성 파일)
├── data_actions/
│   ├── data_create.dart # item Data firebase 추가기능
│   ├── data_delete.dart # item Data firebase 삭제기능
│   └── data_update.dart # item Data firebase 수정기능
└── models/
    └── item.dart # 기본데이터 모델델
```

- `main.dart`: 앱의 실행 시작점이며, Firebase 초기화와 루트 위젯 (`MyApp`)을 설정합니다.
- `firebase_options.dart`: Firebase CLI로 자동 생성되는 파일로, 각 플랫폼별 Firebase 설정을 포함합니다.
- `data_actions/data_create.dart`: 데이터 추가 화면을 구성하고 Firestore와 연동하여 데이터를 생성하고 저장하는 기능을 담당.
- `data_actions/data_delete.dart`: 데이터 삭제 팝업을 구성하고 Firestore와 연동하여 선택된 데이터를 삭제하는 기능을 담당.
- `data_actions/data_update.dart`: 데이터 수정 화면을 구성하고 Firestore와 연동하여 선택된 데이터를 수정하는 기능을 담당.
- `models/item.dart`: 데이터 구조를 설정정.


## 프로젝트 진행하며 습득한 주요 기술

- **Flutter의 위젯 트리 구성과 네비게이션**  
  MaterialApp, Scaffold, AppBar 등으로 레이아웃 구축 및 위젯 트리 설계 방법 습득

- **Firebase Firestore 연동**  
  Firebase CLI를 통한 프로젝트 연동, Firestore의 실시간 데이터베이스 구조 및 활용법 학습

- **비동기 프로그래밍 (Future, async/await)**  
  Firestore 데이터 처리, UI 동기화 등을 위한 비동기 코드 작성법 이해

- **상태 관리 및 실시간 데이터 반영**  
  StreamBuilder와 setState 등으로 실시간 데이터 반영 및 상태 관리 기법 습득

- **모달 및 다이얼로그 활용법**  
  showDialog, showModalBottomSheet 등 Flutter에서 입력/알림 창 구현 경험

- **에러 핸들링 및 사용자 피드백**  
  예외 처리와 사용자 알림(UI) 구현법 체득

- **Dart 자료형 및 컬렉션 사용법**  
  Map, List, TextEditingController 등 다양한 Dart 클래스 활용 경험

- **플랫폼별 설정 파일과 초기화 과정 이해**  
  firebase_options.dart 등 플랫폼별 자동 생성 파일과 초기화 흐름 파악

- **실습 기반으로 CRUD 아키텍처 설계**  
  코드 분리(data_create.dart, data_update.dart, data_delete.dart), 모델 정의(item.dart) 방법 습득

