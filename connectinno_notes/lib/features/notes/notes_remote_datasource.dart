import 'package:connectinno_notes/core/failures/app_failure.dart';
import 'package:connectinno_notes/core/network/api_constants.dart';
import 'package:connectinno_notes/features/notes/models/note.dart';
import 'package:dio/dio.dart';

/// Remote API for notes — [Dio] is configured in [DioClient].
class NotesRemoteDataSource {
  NotesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Note>> fetchNotes() async {
    try {
      final res = await _dio.get<dynamic>(ApiConstants.notes);
      final data = res.data;
      if (data is! List) {
        throw const AppFailure('Invalid notes response');
      }
      return data
          .map((e) => Note.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      if (e.error is AppFailure) {
        throw e.error! as AppFailure;
      }
      rethrow;
    }
  }

  Future<Note> createNote(Note note) async {
    try {
      final res = await _dio.post<dynamic>(ApiConstants.notes, data: note.toJson());
      return Note.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      if (e.error is AppFailure) {
        throw e.error! as AppFailure;
      }
      rethrow;
    }
  }

  Future<Note> updateNote(Note note) async {
    try {
      final res = await _dio.put<dynamic>(
        '${ApiConstants.notes}/${note.id}',
        data: note.toJson(),
      );
      return Note.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      if (e.error is AppFailure) {
        throw e.error! as AppFailure;
      }
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _dio.delete<void>('${ApiConstants.notes}/$id');
    } on DioException catch (e) {
      if (e.error is AppFailure) {
        throw e.error! as AppFailure;
      }
      rethrow;
    }
  }
}
