import 'package:cloud_firestore/cloud_firestore.dart';
import '../dto/user_dto.dart';

class UserDatabase {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection("userx");

  void save(UserDto obj) {
    //journalCollection.add(entry.toMap());
    collection.doc(obj.id).set(obj.toMap());
  }

  void update(UserDto obj) {
    var options = SetOptions(merge: true);
    collection.doc(obj.id).set(obj.toMap(), options);
  }

  Future<void> remove(String id) {
    return collection.doc(id).delete();
  }

  Stream<QuerySnapshot> getStream() {
    return collection.snapshots();
  }

  Stream<QuerySnapshot> getLastestStream() {
    return collection
        .where('date',
            isGreaterThan:
                DateTime.now().add(const Duration(days: -10)).toIso8601String())
        .snapshots();
  }
}
