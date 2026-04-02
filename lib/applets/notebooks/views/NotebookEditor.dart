
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:epesi_crm_app/models/notebooks/NoteModel.dart';
import 'package:epesi_crm_app/controllers/notebooks/NotebooksController.dart';

class NotebookEditor extends StatefulWidget {
  final String notebookId;
  final NoteModel? note;

  const NotebookEditor({Key? key, required this.notebookId, this.note}) : super(key: key);

  @override
  _NotebookEditorState createState() => _NotebookEditorState();
}

class _NotebookEditorState extends State<NotebookEditor> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final NotebooksController _controller = Get.find<NotebooksController>();
  bool _isSaving = false;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.name ?? "";
      _contentController.text = widget.note!.content ?? "";
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.isEmpty) {
      Get.snackbar("Error", "Title cannot be empty", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red.withOpacity(0.1), 
          colorText: Colors.red);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.note == null) {
        await _controller.addNote(_titleController.text, _contentController.text);
      } else {
        await _controller.updateNote(widget.note!.id!, _titleController.text, _contentController.text);
      }
      
      Get.back();
      Get.snackbar("Success", "Note saved successfully", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.green.withOpacity(0.1), 
          colorText: Colors.green);
    } catch (e) {
      Get.snackbar("Error", "Failed to save note: $e", 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: Colors.red.withOpacity(0.1), 
          colorText: Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: "Untitled Note",
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF64748B)),
        actions: [
          IconButton(
            icon: Icon(_isPreviewMode ? Icons.edit_outlined : Icons.remove_red_eye_outlined),
            onPressed: () {
              setState(() {
                _isPreviewMode = !_isPreviewMode;
              });
            },
            tooltip: _isPreviewMode ? "Edit" : "Preview",
          ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
            onPressed: _isSaving ? null : _save,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: _isPreviewMode ? _buildPreview() : _buildEditor(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _contentController,
        decoration: const InputDecoration(
          hintText: "Start typing your note... (Markdown supported)",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF334155)),
      ),
    );
  }

  Widget _buildPreview() {
    if (_contentController.text.isEmpty) {
      return const Center(
        child: Text(
          "Nothing to preview",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Markdown(
        data: _contentController.text,
        selectable: true,
        padding: const EdgeInsets.all(16),
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF334155)),
          h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          blockquote: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
          code: TextStyle(
            backgroundColor: Colors.grey[200],
            fontFamily: 'monospace',
            fontSize: 14,
            color: const Color(0xFFD946EF),
          ),
          codeblockDecoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }
}
