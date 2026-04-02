import 'dart:convert';
import 'package:epesi_crm_app/Services/base_service.dart';
import 'package:epesi_crm_app/models/notebooks/NotebookModel.dart';
import 'package:epesi_crm_app/constants/app.dart';

import 'package:epesi_crm_app/models/notebooks/NoteModel.dart';

class NotebooksService extends BaseService {
  static String baseUrl = BASE_API_URL.url;

  Future<List<NotebookModel>> getNotebooks() async {
    try {
      final response = await get(baseUrl, '/notebooks');
      if (response != null) {
        final List<dynamic> decoded = json.decode(response);
        return decoded.map((item) => NotebookModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notebooks: $e');
      return [];
    }
  }

  Future<NotebookModel?> createNotebook(String name, String? description) async {
    try {
      final response = await post(baseUrl, '/notebooks', {
        'name': name,
        'description': description,
      });
      if (response != null) {
        return NotebookModel.fromJson(json.decode(response));
      }
      return null;
    } catch (e) {
      print('Error creating notebook: $e');
      return null;
    }
  }

  Future<bool> deleteNotebook(String notebookId) async {
    try {
      final response = await delete(baseUrl, '/notebooks/$notebookId', {});
      return response != null;
    } catch (e) {
      print('Error deleting notebook: $e');
      return false;
    }
  }

  Future<NotebookModel?> updateNotebook(String notebookId, String name, String? description) async {
    try {
      final response = await patch(baseUrl, '/notebooks/$notebookId', {
        'name': name,
        'description': description,
      });
      if (response != null) {
        return NotebookModel.fromJson(json.decode(response));
      }
      return null;
    } catch (e) {
      print('Error updating notebook: $e');
      return null;
    }
  }

  // Note-related operations
  Future<List<NoteModel>> getNotes(String notebookId) async {
    try {
      final response = await get(baseUrl, '/notebooks/$notebookId/notes');
      if (response != null) {
        final List<dynamic> decoded = json.decode(response);
        return decoded.map((item) => NoteModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notes: $e');
      return [];
    }
  }

  Future<NoteModel?> createNote(String notebookId, String name, String content) async {
    try {
      final response = await post(baseUrl, '/notebooks/$notebookId/notes', {
        'name': name,
        'content': content,
      });
      if (response != null) {
        return NoteModel.fromJson(json.decode(response));
      }
      return null;
    } catch (e) {
      print('Error creating note: $e');
      return null;
    }
  }

  Future<NoteModel?> updateNote(String notebookId, String noteId, String name, String content) async {
    try {
      final response = await patch(baseUrl, '/notebooks/$notebookId/notes/$noteId', {
        'name': name,
        'content': content,
      });
      if (response != null) {
        return NoteModel.fromJson(json.decode(response));
      }
      return null;
    } catch (e) {
      print('Error updating note: $e');
      return null;
    }
  }

  Future<bool> deleteNote(String notebookId, String noteId) async {
    try {
      final response = await delete(baseUrl, '/notebooks/$notebookId/notes/$noteId', {});
      return response != null;
    } catch (e) {
      print('Error deleting note: $e');
      return false;
    }
  }
}
