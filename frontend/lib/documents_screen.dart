import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'package:front_end/services/http_client_wrapper.dart';
import 'package:front_end/services/documents_service.dart';
import 'package:front_end/services/auth_service.dart';
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
  String? _selectedTypeFilter; // null = show all, or specific document type

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
    final isGuest = Supabase.instance.client.auth.currentUser == null;
    if (isGuest && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to view and manage your documents'),
          duration: Duration(seconds: 4),
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
    // Check if guest
    final isGuest = Supabase.instance.client.auth.currentUser == null;
    if (isGuest && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to download documents'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (doc.fileUrl.startsWith('http')) {
      // Open external link
      if (await canLaunchUrl(Uri.parse(doc.fileUrl))) {
        await launchUrl(
          Uri.parse(doc.fileUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open document')),
          );
        }
      }
    } else {
      // For local files, show a message (actual implementation would download)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening: ${doc.displayTitle}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _deleteDocument(BuildContext context, UserDocument doc) {
    // Check if guest
    final isGuest = Supabase.instance.client.auth.currentUser == null;
    if (isGuest && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to manage documents'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Document'),
          content: Text(
            'Are you sure you want to delete "${doc.displayTitle}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
                    success: (data) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Document deleted successfully'),
                          ),
                        );
                        setState(() {
                          _documentsFuture = _fetchUserDocuments();
                        });
                      }
                    },
                    error: (message) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $message')),
                        );
                      }
                    },
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Documents',
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
              // Navigate to notifications
            },
          ),
        ],
      ),
      body: FutureBuilder<UserDocumentsResponse>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (_documentsFuture == null) {
            return const Center(child: CircularProgressIndicator());
          }
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _documentsFuture = _fetchUserDocuments();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No documents available'));
          }

          final response = snapshot.data!;

          if (response.documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No documents yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Documents you generate or download will appear here',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Get unique document types
          final types = <String>{};
          for (var doc in response.documents) {
            types.add(doc.documentType);
          }

          // Filter documents
          final filteredDocs = _selectedTypeFilter == null
              ? response.documents
              : response.documents
                    .where((d) => d.documentType == _selectedTypeFilter)
                    .toList();

          return ListView(
            children: [
              // Document Type Filter Tabs
              if (types.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // "All Documents" tab
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text('All (${response.documents.length})'),
                          selected: _selectedTypeFilter == null,
                          onSelected: (_) {
                            setState(() {
                              _selectedTypeFilter = null;
                            });
                          },
                          selectedColor: const Color(0xFF00401A),
                          labelStyle: TextStyle(
                            color: _selectedTypeFilter == null
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Document type tabs
                      ...types.map((type) {
                        final count = response.documents
                            .where((d) => d.documentType == type)
                            .length;
                        final isSelected = _selectedTypeFilter == type;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text('${_getTypeLabel(type)} ($count)'),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedTypeFilter = isSelected ? null : type;
                              });
                            },
                            selectedColor: const Color(0xFF00401A),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              // Documents List
              if (filteredDocs.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No documents of this type',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    return _buildDocumentCard(context, doc);
                  },
                ),
              // Storage Usage Bar
              if (response.storageQuotaBytes > 0)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildStorageUsageBar(context, response),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildDocumentCard(BuildContext context, UserDocument doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Document Icon with color coding
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(doc.badgeColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(doc.icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            // Document Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.displayTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeBadgeColor(doc.badgeColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          doc.displayType,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (doc.fileSize != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatFileSize(doc.fileSize!),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      if (doc.tags != null && doc.tags!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          doc.tags!.first,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(doc.createdAt),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Action Icons
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.download, size: 18),
                      SizedBox(width: 8),
                      Text('Download'),
                    ],
                  ),
                  onTap: () => _openDocument(context, doc),
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  onTap: () => _deleteDocument(context, doc),
                ),
              ],
              child: const Icon(
                Icons.more_vert,
                color: Color(0xFF00401A),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageUsageBar(
    BuildContext context,
    UserDocumentsResponse response,
  ) {
    final usagePercent = response.usagePercentage;
    final usageColor = usagePercent > 80 ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Storage Usage',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                '${usagePercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: usageColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: usagePercent / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(usageColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatFileSize(response.usedBytes)} of ${_formatFileSize(response.storageQuotaBytes)}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'complaint':
        return 'Complaints';
      case 'template':
        return 'Templates';
      case 'generated_pdf':
        return 'Generated PDFs';
      case 'uploaded':
        return 'Uploaded';
      case 'evidence':
        return 'Evidence';
      default:
        return type;
    }
  }

  Color _getTypeBadgeColor(String badgeColor) {
    switch (badgeColor) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getIconBackgroundColor(String badgeColor) {
    switch (badgeColor) {
      case 'red':
        return const Color(0xFFFFEBEE);
      case 'blue':
        return const Color(0xFFE3F2FD);
      case 'purple':
        return const Color(0xFFF3E5F5);
      case 'green':
        return const Color(0xFFE8F5E9);
      case 'orange':
        return const Color(0xFFFFE0B2);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final docDate = DateTime(date.year, date.month, date.day);

      if (docDate == today) {
        return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (docDate == yesterday) {
        return 'Yesterday';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return isoDate;
    }
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2, // Documents tab is selected
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home_screen');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/chat');
            break;
          case 2:
            // Already on Documents screen
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: AppLocalizations.of(context)!.bottomNavHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble_outline),
          label: AppLocalizations.of(context)!.bottomNavChat,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.folder_outlined),
          label: AppLocalizations.of(context)!.bottomNavDocuments,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          label: AppLocalizations.of(context)!.bottomNavProfile,
        ),
      ],
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00401A),
      unselectedItemColor: Colors.grey,
    );
  }
}
