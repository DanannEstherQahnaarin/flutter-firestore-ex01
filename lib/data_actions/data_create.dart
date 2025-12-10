import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firestore_ex01/models/item.dart';

void showAddItemSheet(BuildContext context) {
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              // 그림자
              elevation: 10,
              // 모양
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Item Add',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
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
                onPressed: () {
                  _addItem(
                    nameController.text,
                    int.tryParse(quantityController.text) ?? 0,
                    context,
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

void _addItem(String name, int quantity, BuildContext context) {
  if (name.isEmpty) {
    showDialog(
      context: context,
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

  if (quantity == 0) {
        showDialog(
      context: context,
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
    final newItem = Item(id: '', name: name, quantity: quantity, timestamp: DateTime.now());
    FirebaseFirestore.instance.collection('items').add(newItem.toFirestore());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('성공'),
          content: Text('아이템이 성공적으로 추가되었습니다.'),
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
        showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('실패'),
          content: Text('아이템 추가에 실패하였습니다.'),
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
