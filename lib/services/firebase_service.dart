import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/contract_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Auth Methods
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Update display name
    await credential.user?.updateDisplayName(displayName);
    
    // Create user document in Firestore
    await createUserDocument(credential.user!, displayName);
    
    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // User Document Methods
  Future<void> createUserDocument(User user, String displayName) async {
    final userModel = UserModel(
      id: user.uid,
      email: user.email!,
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());
  }

  Future<UserModel?> getUserDocument(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserDocument(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .update(user.toMap());
  }

  // Contract Methods
  Future<String> createContract(ContractModel contract) async {
    final docRef = await _firestore
        .collection('contracts')
        .add(contract.toMap());
    
    // Update contract with the generated ID
    await docRef.update({'id': docRef.id});
    return docRef.id;
  }

  Future<void> updateContract(ContractModel contract) async {
    await _firestore
        .collection('contracts')
        .doc(contract.id)
        .update(contract.toMap());
  }

  Future<ContractModel?> getContract(String contractId) async {
    final doc = await _firestore
        .collection('contracts')
        .doc(contractId)
        .get();
    
    if (doc.exists) {
      return ContractModel.fromMap(doc.data()!);
    }
    return null;
  }

  Stream<List<ContractModel>> getUserContracts(String userId) {
    return _firestore
        .collection('contracts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContractModel.fromMap(doc.data()))
            .toList());
  }

  // Storage Methods
  Future<String> uploadPdfFile({
    required String fileName,
    required List<int> fileBytes,
    required String userId,
  }) async {
    final ref = _storage
        .ref()
        .child('contracts')
        .child(userId)
        .child('$fileName.pdf');

    final uploadTask = ref.putData(fileBytes);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  // Usage tracking
  Future<void> decrementUserContracts(String userId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      if (snapshot.exists) {
        final user = UserModel.fromMap(snapshot.data()!);
        final newCount = user.contractsRemaining - 1;
        transaction.update(userDoc, {'contractsRemaining': newCount});
      }
    });
  }

  Future<bool> canUserCreateContract(String userId) async {
    final user = await getUserDocument(userId);
    if (user == null) return false;
    
    return user.contractsRemaining > 0 || user.hasActiveSubscription;
  }
}