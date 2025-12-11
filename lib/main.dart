// ============================================================================
// 패키지 임포트
// ============================================================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex01/data_actions/data_delete.dart';
import 'package:flutter_firestore_ex01/data_actions/data_update.dart';
import 'package:flutter_firestore_ex01/firebase_options.dart';
import 'package:flutter_firestore_ex01/models/item.dart';
import 'package:flutter_firestore_ex01/data_actions/data_create.dart';

// ============================================================================
// 앱 진입점 (Entry Point)
// ============================================================================
void main() async {
  // Flutter 엔진과 위젯 바인딩이 초기화될 때까지 기다립니다.
  // 비동기 작업(예: Firebase 초기화) 전에 반드시 호출해야 합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  // 플랫폼별 설정 파일(firebase_options.dart)을 사용하여 Firebase 앱을 초기화합니다.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 앱 실행
  runApp(const MyApp());
}

// ============================================================================
// 앱 루트 위젯 (Root Widget)
// ============================================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 앱 전체의 루트 위젯
  // MaterialApp을 반환하여 Material Design 테마와 네비게이션을 제공합니다.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // 테마 설정: 시드 컬러로부터 전체 색상 스키마를 자동 생성
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // 홈 화면 설정
      home: HomeScreen(),
    );
  }
}

// ============================================================================
// 홈 화면 위젯 (StatefulWidget)
// ============================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ============================================================================
// 홈 화면 상태 관리 클래스
// ============================================================================
class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================================
      // 앱바 (AppBar)
      // ========================================================================
      appBar: AppBar(title: Text('Firestore CRUD Example')),

      // ========================================================================
      // 본문 (Body): Firestore 데이터 스트림 구독 및 표시
      // ========================================================================
      body: StreamBuilder<QuerySnapshot>(
        // Firestore items 컬렉션을 최신 timestamp 순으로 스트림 구독
        // 실시간으로 데이터 변경사항을 감지하여 UI를 자동 업데이트합니다.
        stream: FirebaseFirestore.instance
            .collection('items')
            .orderBy('timestamp', descending: true)
            .snapshots(),

        // 스트림 데이터를 기반으로 UI를 빌드하는 콜백
        builder: (context, snapshot) {
          // ====================================================================
          // 에러 처리: 스트림에서 에러가 발생한 경우
          // ====================================================================
          if (snapshot.hasError) {
            return Center(child: Text('Error:${snapshot.error}'));
          }

          // ====================================================================
          // 로딩 상태: 최초 연결 시 로딩 인디케이터 표시
          // ====================================================================
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ====================================================================
          // 데이터 추출: 스트림에서 실제 문서 데이터 가져오기
          // ====================================================================
          final data = snapshot.requireData;

          // ====================================================================
          // 빈 데이터 처리: 컬렉션이 비어 있으면 안내 문구 표시
          // ====================================================================
          if (data.docs.isEmpty) {
            return const Center(child: Text('Empty Data'));
          }

          // ====================================================================
          // 리스트 뷰: 문서 목록을 리스트로 렌더링
          // ====================================================================
          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              // 현재 인덱스의 Firestore 문서 가져오기
              final doc = data.docs[index];

              // ================================================================
              // 데이터 변환: Firestore 문서 → Item 모델 변환
              // ================================================================
              final item = Item.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );

              // ================================================================
              // 리스트 타일: 각 아이템을 표시하는 위젯
              // ================================================================
              return ListTile(
                // 아이템 이름 표시
                title: Text(item.name),
                // 아이템 수량 표시
                subtitle: Text('수량 : ${item.quantity}'),

                // ============================================================
                // 트레일링 위젯: 리스트 타일 오른쪽에 표시되는 위젯들
                // ============================================================
                trailing: Row(
                  // mainAxisSize: MainAxisSize.min 설정이 필요한 이유:
                  // - Row의 기본값은 MainAxisSize.max로, 가능한 모든 가로 공간을 차지
                  // - trailing 영역은 제한된 공간을 가지므로,
                  //   Row가 ListTile의 trailing 영역을 넘어서 확장되려고 하면
                  //   "RenderFlex overflowed" 오류가 발생.
                  // - MainAxisSize.min을 사용하면 Row가 자식 위젯들의 실제 크기만큼만
                  //   공간을 차지하여 오버플로우 오류를 방지.
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 아이템 ID 표시 (5자 이상이면 앞 5자만 표시)
                    Text(
                      'ID : ${item.id.length > 5 ? item.id.substring(0, 5) : item.id}...',
                      style: const TextStyle(fontSize: 10),
                    ),

                    // ========================================================
                    // 수정 버튼: 아이템 수정 기능
                    // ========================================================
                    IconButton(
                      onPressed: () {
                        // 수정 바텀시트 표시
                        showUpdateItemSheet(context, item);
                      },
                      icon: Icon(Icons.edit),
                    ),

                    // ========================================================
                    // 삭제 버튼: 아이템 삭제 기능
                    // ========================================================
                    IconButton(
                      onPressed: () {
                        // 삭제 확인 다이얼로그 표시
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Delete'),
                              content: Text('${item.name}을 삭제하시겠습니까?'),
                              actions: [
                                // 취소 버튼
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                // 삭제 확인 버튼
                                TextButton(
                                  onPressed: () async {
                                    // 다이얼로그 닫기
                                    Navigator.of(context).pop();
                                    // 아이템 삭제 실행
                                    await deleteItem(item.id, context);
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // ========================================================================
      // 플로팅 액션 버튼 (FAB): 새 아이템 추가 기능
      // ========================================================================
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 아이템 추가 바텀시트 표시
          showAddItemSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
