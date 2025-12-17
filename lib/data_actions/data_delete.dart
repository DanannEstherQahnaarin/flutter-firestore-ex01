import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//Future<T>: Dart에서 비동기 작업의 결과를 나타내는 객체
//T가 void면 값이 반환값이 없으므로 본문에 return이 존재하지않음
Future<void> deleteItem(String id, BuildContext context) async {
  try {
    await FirebaseFirestore.instance.collection('items').doc(id).delete();
  } catch (e) {
    //위젯이 dispose된 경우 context 사용을 방지
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('알림'),
        content: const Text('삭제에 실패하였습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
