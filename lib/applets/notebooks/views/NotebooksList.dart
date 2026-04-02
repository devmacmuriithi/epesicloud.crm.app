
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:epesi_crm_app/models/notebooks/NotebookModel.dart';
import 'package:epesi_crm_app/applets/notebooks/views/NotebookEditor.dart';
import 'package:epesi_crm_app/controllers/notebooks/NotebooksController.dart';
import 'package:epesi_crm_app/applets/notebooks/views/NotebookNotesList.dart';
import 'package:epesi_crm_app/widgets/SnappyAppBar.dart';

class NotebooksList extends StatefulWidget {
  const NotebooksList({Key? key}) : super(key: key);

  @override
  _NotebooksListState createState() => _NotebooksListState();
}

class _NotebooksListState extends State<NotebooksList> {
  final NotebooksController _controller = Get.put(NotebooksController());

  @override
  void initState() {
    super.initState();
    _controller.fetchNotebooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: SnappyAppBar(
        title: "Digital Notebooks",
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
            onPressed: () => _controller.fetchNotebooks(),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value && _controller.notebooks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.notebooks.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => _controller.fetchNotebooks(),
          child: _controller.isGridView.value ? _buildGrid() : _buildList(),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNotebookDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddNotebookDialog() {
    final TextEditingController nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text("New Notebook"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: "Notebook Name",
            hintText: "e.g. Science, My Project...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _controller.addNotebook(nameController.text);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Create", style: TextStyle(color: Colors.white)),
          ),
        ],
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
              child: Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey[300]),
            ),
            const SizedBox(height: 24),
            Text(
              "No notebooks yet",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              "Organize your thoughts and study materials into dedicated notebooks.",
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

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _controller.notebooks.length,
      itemBuilder: (context, index) {
        final notebook = _controller.notebooks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildNotebookListTile(notebook),
        );
      },
    );
  }

  Widget _buildNotebookListTile(NotebookModel notebook) {
    return InkWell(
      onTap: () {
        Get.to(() => NotebookNotesList(notebook: notebook));
      },
      onLongPress: () => _showOptions(notebook),
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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.folder_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notebook.title ?? "Untitled",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notebook.updatedAt != null
                          ? "Updated ${DateFormat('MMM d, yyyy').format(notebook.updatedAt!)}"
                          : "New Notebook",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blueGrey[300],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, size: 24, color: Color(0xFF94A3B8)),
                onPressed: () => _showOptions(notebook),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemCount: _controller.notebooks.length,
      itemBuilder: (context, index) {
        final notebook = _controller.notebooks[index];
        return InkWell(
          onTap: () {
            Get.to(() => NotebookNotesList(notebook: notebook));
          },
          onLongPress: () => _showOptions(notebook),
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.folder_rounded, color: Colors.white, size: 20),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF94A3B8)),
                        onPressed: () => _showOptions(notebook),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notebook.title ?? "Untitled",
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    notebook.updatedAt != null
                        ? "Updated ${DateFormat('MMM d').format(notebook.updatedAt!)}"
                        : "New",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blueGrey[300],
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

  void _showOptions(NotebookModel notebook) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Color(0xFF64748B)),
                title: const Text("Rename Notebook"),
                onTap: () {
                  Get.back();
                  _showRenameDialog(notebook);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Delete Notebook", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  _showDeleteDialog(notebook);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(NotebookModel notebook) {
    final TextEditingController nameController = TextEditingController(text: notebook.title);
    Get.dialog(
      AlertDialog(
        title: const Text("Rename Notebook"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: "New Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _controller.updateNotebook(notebook.id!, nameController.text);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(NotebookModel notebook) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Notebook"),
        content: Text("Delete \"${notebook.title}\"? All notes inside will be permanently lost."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () {
              _controller.deleteNotebook(notebook.id!);
              Get.back();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
