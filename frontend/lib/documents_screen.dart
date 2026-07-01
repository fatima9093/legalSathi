import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'package:front_end/services/http_client_wrapper.dart';
import 'package:front_end/services/documents_service.dart';
import 'package:front_end/services/auth_service.dart';
import 'package:front_end/notifications_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late DocumentsService _documentsService;
  late AuthService _authService;
  Future<UserDocumentsResponse>? _documentsFuture;
  String? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();

    final httpClient = HttpClientWrapper();
    _documentsService = DocumentsService(httpClient);
    _authService = AuthService();

    final currentUser = _authService.currentUser;
    _documentsFuture = currentUser == null
        ? Future.value(
            UserDocumentsResponse(
              userId: '',
              documents: const [],
              totalCount: 0,
            ),
          )
        : _fetchUserDocuments();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGuestAccess();
    });
  }

  void _checkGuestAccess() {
    final loc = AppLocalizations.of(context)!;
    final isGuest = Supabase.instance.client.auth.currentUser == null;

    if (isGuest && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.signInToViewDocs),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<UserDocumentsResponse> _fetchUserDocuments() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final result = await _documentsService.getUserDocuments(currentUser.id);
    return result.when(
      success: (data) => data,
      error: (message) => throw Exception(message),
    );
  }

  void _openDocument(BuildContext context, UserDocument doc) async {
    final loc = AppLocalizations.of(context)!;
    final isGuest = Supabase.instance.client.auth.currentUser == null;

    if (isGuest && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.signInToDownloadDocs)),
      );
      return;
    }

    if (doc.fileUrl.startsWith('http')) {
      if (await canLaunchUrl(Uri.parse(doc.fileUrl))) {
        await launchUrl(
          Uri.parse(doc.fileUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.couldNotOpenDocument)),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.openingDocument(doc.displayTitle))),
        );
      }
    }
  }

  void _deleteDocument(BuildContext context, UserDocument doc) {
    final loc = AppLocalizations.of(context)!;
    final isGuest = Supabase.instance.client.auth.currentUser == null;

    if (isGuest && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.signInToManageDocs)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(loc.deleteDocument),
          content: Text(loc.deleteConfirm(doc.displayTitle)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final currentUser = _authService.currentUser;
                if (currentUser != null) {
                  final result = await _documentsService.deleteUserDocument(
                    userId: currentUser.id,
                    documentId: doc.id,
                  );

                  result.when(
                    success: (_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.documentDeleted)),
                        );
                        setState(() {
                          _documentsFuture = _fetchUserDocuments();
                        });
                      }
                    },
                    error: (message) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.errorMessage(message))),
                        );
                      }
                    },
                  );
                }
              },
              child: Text(loc.delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          loc.myDocuments,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<UserDocumentsResponse>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(loc.errorMessage(snapshot.error.toString())),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _documentsFuture = _fetchUserDocuments();
                      });
                    },
                    child: Text(loc.retry),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(child: Text(loc.noDocumentsAvailable));
          }

          final response = snapshot.data!;

          if (response.documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(loc.noDocumentsYet,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    loc.documentsEmptyHint,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final types = <String>{};
          for (var doc in response.documents) {
            types.add(doc.documentType);
          }

          final filteredDocs = _selectedTypeFilter == null
              ? response.documents
              : response.documents
                  .where((d) => d.documentType == _selectedTypeFilter)
                  .toList();

          return ListView(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(loc.allDocuments(response.documents.length)),
                        selected: _selectedTypeFilter == null,
                        onSelected: (_) {
                          setState(() => _selectedTypeFilter = null);
                        },
                      ),
                    ),
                    ...types.map((type) {
                      final count = response.documents
                          .where((d) => d.documentType == type)
                          .length;

                      final isSelected = _selectedTypeFilter == type;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text('${_getTypeLabel(loc, type)} ($count)'),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedTypeFilter =
                                  isSelected ? null : type;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              if (filteredDocs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text(loc.noDocumentsOfType))
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    return _buildDocumentCard(filteredDocs[index], loc);
                  },
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildDocumentCard(UserDocument doc, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(doc.displayTitle),
        subtitle: Text(doc.displayType),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(
              onTap: () => _openDocument(context, doc),
              child: Text(loc.download),
            ),
            PopupMenuItem(
              onTap: () => _deleteDocument(context, doc),
              child: Text(loc.delete),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(AppLocalizations loc, String type) {
    switch (type) {
      case 'complaint':
        return loc.complaints;
      case 'template':
        return loc.templates;
      case 'generated_pdf':
        return loc.generatedPdfs;
      case 'uploaded':
        return loc.uploaded;
      case 'evidence':
        return loc.evidence;
      default:
        return type;
    }
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      currentIndex: 2,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: loc.bottomNavHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble_outline),
          label: loc.bottomNavChat,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.folder_outlined),
          label: loc.bottomNavDocuments,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          label: loc.bottomNavProfile,
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}