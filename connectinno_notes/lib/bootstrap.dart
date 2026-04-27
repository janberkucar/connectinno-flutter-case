import 'package:connectinno_notes/core/network/dio_client.dart';
import 'package:connectinno_notes/features/notes/models/note.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Wires up async initialization before [runApp]: Hive, adapters, boxes, DI.
class AppBootstrap {
  const AppBootstrap._({
    required this.secureStorage,
    required this.dioClient,
    required this.notesBox,
    required this.connectivity,
  });

  static const _notesBoxName = 'notes';

  final FlutterSecureStorage secureStorage;
  final DioClient dioClient;
  final Box<Note> notesBox;
  final Connectivity connectivity;

  static Future<AppBootstrap> create() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }
    final notesBox = await Hive.openBox<Note>(_notesBoxName);
    const secure = FlutterSecureStorage();
    final dio = DioClient(secureStorage: secure);
    return AppBootstrap._(
      secureStorage: secure,
      dioClient: dio,
      notesBox: notesBox,
      connectivity: Connectivity(),
    );
  }
}
