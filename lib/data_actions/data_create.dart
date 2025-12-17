import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex01/models/item.dart';

/// 하단에서 아이템 추가 폼을 모달 형태로 보여주는 함수
/// [parentContext] : 바텀시트 오픈을 위한 부모 컨텍스트
void showAddItemSheet(BuildContext parentContext) {
  // 1. 입력 필드 컨트롤러 생성 (사용자 이름/수량 입력 추적)
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  // 2. 모달 바텀시트로 폼 레이아웃 표출
  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true, // 키보드로 인한 overflow 방지
    builder: (bottomSheetContext) => Padding(
      // 키보드 올라오면 그만큼 하단에 여백 부여
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 입력 폼 타이틀 카드
          Card(
            elevation: 10, // 그림자 깊이
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            margin: const EdgeInsets.all(10),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Item Add',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // [이름 입력 필드] (text)
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Item Name'),
          ),
          // [수량 입력 필드] (number)
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
          const SizedBox(height: 20),
          // [저장 버튼] 누르면 입력 검증 및 DB 저장
          SizedBox(
            height: 30,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                elevation: 10,
              ),
              onPressed: () async {
                // 입력값 검증 및 저장 트리거
                await _addItem(
                  nameController.text,
                  int.tryParse(quantityController.text) ?? 0,
                  bottomSheetContext,
                  parentContext,
                );
              },
              child: const Icon(Icons.save, size: 30, semanticLabel: 'Item Add...'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

/// 입력 검증 및 Firestore DB에 아이템 추가 로직
/// [name] : 아이템 이름
/// [quantity] : 아이템 수량
/// [bottomSheetContext] : 모달 컨텍스트 (알림 및 닫기 등)
/// [parentContext] : 부모 컨텍스트 (성공 시 다이얼로그)
Future<void> _addItem(
  String name,
  int quantity,
  BuildContext bottomSheetContext,
  BuildContext parentContext,
) async {
  // 입력값 검증 1 : 이름 미입력 시
  if (name.isEmpty) {
    if (!bottomSheetContext.mounted) return;
    showDialog(
      context: bottomSheetContext,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('알림'),
        content: const Text('이름을 정확히 입력해 주십시오.'),
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
    return;
  }

  // 입력값 검증 2 : 수량이 0이거나 숫자 아님
  if (quantity == 0) {
    if (!bottomSheetContext.mounted) return;
    showDialog(
      context: bottomSheetContext,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('알림'),
        content: const Text('수량을 정확히 입력해 주십시오.'),
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
    return;
  }

  try {
    // ① 신규 아이템 모델 생성 (Firestore 문서 구조에 맞게)
    final newItem = Item(id: '', name: name, quantity: quantity, timestamp: DateTime.now());
    // ② Firestore 'items' 컬렉션에 추가 요청
    await FirebaseFirestore.instance.collection('items').add(newItem.toFirestore());

    // ③ 성공 프로세스 : (1) 바텀시트 닫기 → (2) 다음 프레임에서 성공 다이얼로그
    if (!bottomSheetContext.mounted) return;
    Navigator.of(bottomSheetContext).pop(); // 모달 폼 닫기
    await Future.delayed(Duration.zero); // 렌더링 안정화

    if (!parentContext.mounted) return;
    showDialog(
      context: parentContext,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('성공'),
        content: const Text('아이템이 성공적으로 추가되었습니다.'),
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
  } catch (e) {
    // ④ 실패 시: 에러 안내 알림만 표출 (바텀시트에서)
    if (!bottomSheetContext.mounted) return;
    showDialog(
      context: bottomSheetContext,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('실패'),
        content: const Text('아이템 추가에 실패하였습니다.'),
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
