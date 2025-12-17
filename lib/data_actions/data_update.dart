import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex01/models/item.dart';

/// 하단에서 선택된 아이템 수정 폼을 모달 바텀시트로 띄우는 함수
/// [parentContext] : 부모 위젯의 BuildContext (모달 및 알림용)
/// [item] : 수정할 Item 객체
void showUpdateItemSheet(BuildContext parentContext, Item item) {
  // 1. 초기값 포함 입력 필드 컨트롤러 생성 (기존 아이템의 정보로 초기화)
  final TextEditingController nameController = TextEditingController(text: item.name);
  final TextEditingController quantityController = TextEditingController(
    text: item.quantity.toString(),
  );

  // 2. 모달 바텀시트 표시 (키보드 대응 & 폼 레이아웃)
  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    builder: (bottomSheetContext) => Padding(
      // 키보드 올라올 때 하단 여백 확보
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
          // 3. 타이틀 카드 (Item Edit)
          Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            margin: const EdgeInsets.all(10),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Item Edit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 4. 이름 입력 필드
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Item Name'),
          ),
          // 5. 수량 입력 필드 (숫자만)
          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
          const SizedBox(height: 20),
          // 6. 저장 버튼 : 입력값 검증 후 업데이트 트리거
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
                // 저장 버튼 클릭 시 입력값 검증 후 Firestore에 업데이트
                await _updateItem(
                  item.id,
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

/// Firestore에서 아이템 수정 로직 & 유효성 검증
/// [id]            : 수정 대상 Firestore 문서의 ID
/// [name]          : 입력받은 이름
/// [quantity]      : 입력받은 수량
/// [bottomSheetContext] : 바텀시트 context (닫기/에러 알림용)
/// [parentContext] : 부모 context (성공 알림용)
Future<void> _updateItem(
  String id,
  String name,
  int quantity,
  BuildContext bottomSheetContext,
  BuildContext parentContext,
) async {
  // 1. [유효성 검증] 이름이 비었을 때 경고 다이얼로그
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

  // 2. [유효성 검증] 수량이 0이거나 비정상 입력일 때 경고 다이얼로그
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
    // 3. 수정 데이터 맵 구성 (serverTimestamp 사용)
    final updateItem = {
      'name': name,
      'quantity': quantity,
      'timestamp': FieldValue.serverTimestamp(), // 수정 시각 반영
    };

    // 4. Firestore의 'items' 컬렉션에서 id 문서 업데이트
    await FirebaseFirestore.instance.collection('items').doc(id).update(updateItem);

    // 5. 성공 시: 바텀시트 닫기 → success 다이얼로그 parentContext에서 표출
    if (!bottomSheetContext.mounted) return;
    Navigator.of(bottomSheetContext).pop(); // 모달 닫기
    await Future.delayed(Duration.zero); // 프레임 안정화

    if (!parentContext.mounted) return;
    showDialog(
      context: parentContext,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('성공'),
        content: const Text('아이템이 성공적으로 수정되었습니다.'),
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
    // 6. 실패 시 : 바텀시트 context에서 에러 다이얼로그
    if (!bottomSheetContext.mounted) return;
    showDialog(
      context: bottomSheetContext,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('실패'),
        content: const Text('아이템 수정에 실패하였습니다.'),
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
