import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex01/firebase_options.dart';
import 'package:flutter_firestore_ex01/models/item.dart';
import 'package:flutter_firestore_ex01/data_actions/data_create.dart';

void main() async {
  // Flutter 엔진과 위젯 바인딩이 초기화될 때까지 기다립니다.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 앱 전체의 루트 위젯
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firestore CRUD Example')),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore items 컬렉션을 최신 timestamp 순으로 스트림 구독
        stream: FirebaseFirestore.instance
            .collection('items')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // 에러 발생 시 에러 메시지 출력
          if (snapshot.hasError) {
            return Center(child: Text('Error:${snapshot.error}'));
          }

          // 최초 연결 시 로딩 인디케이터 표시
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 스트림에서 실제 문서 데이터 꺼내기
          final data = snapshot.requireData;

          // 컬렉션이 비어 있으면 안내 문구 표시
          if (data.docs.isEmpty) {
            return const Center(child: Text('Empty Data'));
          }

          // 문서 목록을 리스트로 렌더링
          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              final doc = data.docs[index];
              // Firestore 문서 → Item 모델 변환
              final item = Item.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );

              return ListTile(
                title: Text(item.name),
                subtitle: Text('수량 : ${item.quantity}'),
                trailing: Text(
                  'ID : ${item.id.substring(0, 5)}...',
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        showAddItemSheet(context);
      },
      child: const Icon(Icons.add),),
    );
  }
}


