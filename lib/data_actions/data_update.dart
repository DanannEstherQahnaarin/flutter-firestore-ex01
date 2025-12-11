import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex01/models/item.dart';

void showUpdateItemSheet(BuildContext parentContext, Item item) {
  // 이름/수량 입력용 컨트롤러 준비
  TextEditingController nameController = TextEditingController(text: item.name);
  TextEditingController quantityController = TextEditingController(
    text: item.quantity.toString(),
  );

  // 모달 바텀시트로 입력 폼 표시
  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    builder: (bottomSheetContext) {
      return Padding(
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
            Card(
              // 타이틀 카드 + 그림자
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Item Edit',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              // 아이템 이름 입력
              controller: nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              // 수량 숫자 입력
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 30,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 10,
                ),
                onPressed: () async {
                  // 저장 버튼 클릭 → 입력값 검증 후 추가
                  await _updateItem(
                    item.id,
                    nameController.text,
                    int.tryParse(quantityController.text) ?? 0,
                    bottomSheetContext,
                    parentContext,
                  );
                },
                child: Icon(Icons.save, size: 30, semanticLabel: 'Item Add...'),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

Future<void> _updateItem(
  String id,
  String name,
  int quantity,
  BuildContext bottomSheetContext,
  BuildContext parentContext,
) async {
  // 이름 미입력 시 알림
  if (name.isEmpty) {
    if (!bottomSheetContext.mounted) return;
    showDialog(
      context: bottomSheetContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('이름을 정확히 입력해 주십시오.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
    return;
  }

  // 수량 0 입력 시 알림
  if (quantity == 0) {
    if (!bottomSheetContext.mounted) return;
    showDialog(
      context: bottomSheetContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('수량을 정확히 입력해 주십시오.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
    return;
  }

  try {
    final updateItem = {
      'name': name,
      'quantity': quantity,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('items')
        .doc(id)
        .update(updateItem);

    // 성공 안내 다이얼로그
    if (!bottomSheetContext.mounted) return;
    // BottomSheet 닫기
    Navigator.of(bottomSheetContext).pop();
    // 다음 프레임까지 대기 (렌더링 트리 안정화)
    await Future.delayed(Duration.zero);
    // 성공 다이얼로그 표시
    if (!parentContext.mounted) return;
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('성공'),
          content: Text('아이템이 성공적으로 수정되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    // 실패 시 알림 다이얼로그
    if (!bottomSheetContext.mounted) return;
    showDialog(
      context: bottomSheetContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('실패'),
          content: Text('아이템 수정에 실패하였습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
