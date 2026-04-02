import 'package:get/get.dart';
import 'package:epesi_crm_app/Services/notebooks/NotebooksService.dart';
import 'package:epesi_crm_app/models/notebooks/NotebookModel.dart';

import 'package:epesi_crm_app/models/notebooks/NoteModel.dart';

class NotebooksController extends GetxController {
  final NotebooksService _notebooksService = NotebooksService();
  
  var isLoading = false.obs;
  var notebooks = <NotebookModel>[].obs;
  
  // View-related state
  var isGridView = false.obs;
  
  // Note-related state
  var isNotesLoading = false.obs;
  var notes = <NoteModel>[].obs;
  var currentNotebookId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotebooks();
  }

  Future<void> fetchNotebooks() async {
    isLoading(true);
    try {
      final result = await _notebooksService.getNotebooks();
      notebooks.value = result;
    } finally {
      isLoading(false);
    }
  }

  Future<void> addNotebook(String name, {String? description}) async {
    isLoading(true);
    try {
      final newNotebook = await _notebooksService.createNotebook(name, description);
      if (newNotebook != null) {
        notebooks.add(newNotebook);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateNotebook(String notebookId, String name, {String? description}) async {
    isLoading(true);
    try {
      final updated = await _notebooksService.updateNotebook(notebookId, name, description);
      if (updated != null) {
        final index = notebooks.indexWhere((n) => n.id == notebookId);
        if (index != -1) {
          notebooks[index] = updated;
        }
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteNotebook(String notebookId) async {
    final success = await _notebooksService.deleteNotebook(notebookId);
    if (success) {
      notebooks.removeWhere((n) => n.id == notebookId);
    }
  }

  // Note-related methods
  Future<void> fetchNotes(String notebookId) async {
    currentNotebookId.value = notebookId;
    isNotesLoading(true);
    try {
      final result = await _notebooksService.getNotes(notebookId);
      notes.value = result;
    } finally {
      isNotesLoading(false);
    }
  }

  Future<void> addNote(String name, String content) async {
    if (currentNotebookId.isEmpty) return;
    isNotesLoading(true);
    try {
      final newNote = await _notebooksService.createNote(currentNotebookId.value, name, content);
      if (newNote != null) {
        notes.add(newNote);
        // Also refresh notebooks to update document count
        fetchNotebooks();
      }
    } finally {
      isNotesLoading(false);
    }
  }

  Future<bool> addNoteToNotebook(String notebookId, String title, String content) async {
    isLoading(true);
    try {
      final newNote = await _notebooksService.createNote(notebookId, title, content);
      if (newNote != null) {
        // If the notebookId is the current one, update notes list
        if (currentNotebookId.value == notebookId) {
          notes.add(newNote);
        }
        // Refresh notebooks list to update counts
        await fetchNotebooks();
        return true;
      }
      return false;
    } catch (e) {
      print("Error adding note to notebook: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateNote(String noteId, String name, String content) async {
    if (currentNotebookId.isEmpty) return;
    isNotesLoading(true);
    try {
      final updated = await _notebooksService.updateNote(currentNotebookId.value, noteId, name, content);
      if (updated != null) {
        final index = notes.indexWhere((n) => n.id == noteId);
        if (index != -1) {
          notes[index] = updated;
        }
      }
    } finally {
      isNotesLoading(false);
    }
  }

  Future<void> deleteNote(String noteId) async {
    if (currentNotebookId.isEmpty) return;
    final success = await _notebooksService.deleteNote(currentNotebookId.value, noteId);
    if (success) {
      notes.removeWhere((n) => n.id == noteId);
      // Refresh notebooks to update count
      fetchNotebooks();
    }
  }
}
