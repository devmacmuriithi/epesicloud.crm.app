import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:epesi_crm_app/models/notebooks/NotebookModel.dart';
import 'package:epesi_crm_app/models/notebooks/NoteModel.dart';
import 'package:epesi_crm_app/controllers/notebooks/NotebooksController.dart';
import 'package:epesi_crm_app/applets/notebooks/views/NotebookEditor.dart';
import 'package:epesi_crm_app/widgets/SnappyAppBar.dart';

class NotebookNotesList extends StatefulWidget {
  final NotebookModel notebook;

  const NotebookNotesList({Key? key, required this.notebook}) : super(key: key);

  @override
  _NotebookNotesListState createState() => _NotebookNotesListState();
}

class _NotebookNotesListState extends State<NotebookNotesList> {
  final NotebooksController _controller = Get.find<NotebooksController>();

  @override
  void initState() {
    super.initState();
    _controller.fetchNotes(widget.notebook.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SnappyAppBar(
        title: widget.notebook.title ?? "Notebook",
        actions: [
          IconButton(
            icon: Obx(() => Icon(
              _controller.isGridView.value ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: const Color(0xFF64748B),
            )),
            onPressed: () => _controller.isGridView.toggle(),
            tooltip: "Switch View",
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
            onPressed: () => _controller.fetchNotes(widget.notebook.id!),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isNotesLoading.value && _controller.notes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.notes.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => _controller.fetchNotes(widget.notebook.id!),
          child: _controller.isGridView.value ? _buildGrid() : _buildNotesList(),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => NotebookEditor(notebookId: widget.notebook.id!));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey[300]),
            ),
            const SizedBox(height: 24),
            Text(
              "Empty Notebook",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              "Start capturing your ideas and knowledge by adding your first note.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blueGrey[400],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: _controller.notes.length,
      itemBuilder: (context, index) {
        final note = _controller.notes[index];
        return InkWell(
          onTap: () {
            Get.to(() => NotebookEditor(
                  notebookId: widget.notebook.id!,
                  note: note,
                ));
          },
          onLongPress: () => _showDeleteDialog(note),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.description_outlined,
                            color: Theme.of(context).colorScheme.primary, size: 18),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF94A3B8)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteDialog(note);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    note.name ?? "Untitled",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      note.content ?? "No content",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blueGrey[300],
                            fontSize: 11,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.notes.length,
      itemBuilder: (context, index) {
        final note = _controller.notes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.sticky_note_2_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
            ),
            title: Text(
              note.name ?? "Untitled Note",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  note.content != null && note.content!.isNotEmpty
                      ? note.content!
                          .substring(0, note.content!.length > 80 ? 80 : note.content!.length)
                          .replaceAll('\n', ' ')
                      : "No content yet...",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blueGrey[400],
                        height: 1.4,
                      ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog(note);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Text("Delete Note", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            onTap: () {
              Get.to(() => NotebookEditor(
                notebookId: widget.notebook.id!,
                note: note,
              ));
            },
          ),
        );
      },
    );
  }

  void _showDeleteDialog(NoteModel note) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Note"),
        content: Text("Are you sure you want to delete \"${note.name}\"?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () {
              _controller.deleteNote(note.id!);
              Get.back();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
