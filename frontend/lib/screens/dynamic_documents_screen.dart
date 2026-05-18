import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:front_end/models/unified_document_model.dart';
import 'package:front_end/services/document_aggregation_service.dart';
import 'package:front_end/services/http_client_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';

class DynamicDocumentsScreen extends StatefulWidget {
  const DynamicDocumentsScreen({super.key});

  @override
  State<DynamicDocumentsScreen> createState() => _DynamicDocumentsScreenState();
}

class _DynamicDocumentsScreenState extends State<DynamicDocumentsScreen>
    with SingleTickerProviderStateMixin {
  late DocumentAggregationService _documentService;
  late TabController _tabController;
  late Future<AggregatedDocumentsResponse> _documentsFuture;
  String _searchQuery = '';
  List<UnifiedDocument> _filteredDocuments = [];
  AggregatedDocumentsResponse? _cachedResponse;

  final List<DocumentSourceModule> _modules = [
    DocumentSourceModule.personalDocuments,
    DocumentSourceModule.womenHarassment,
    DocumentSourceModule.cyberLaw,
    DocumentSourceModule.labourRights,
    DocumentSourceModule.trafficLaws,
  ];

  @override
  void initState() {
    super.initState();

    final httpClient = HttpClientWrapper();

    _documentService = DocumentAggregationService(httpClient);

    _tabController = TabController(length: _modules.length + 1, vsync: this);

    _documentsFuture = _documentService.getAllDocuments().then((result) {
      return result.when(
        success: (data) {
          _cachedResponse = data;
          return data;
        },
        error: (message) {
          throw Exception(message);
        },
      );
    });

    // FIXED PART
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGuestAccess();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (_cachedResponse != null) {
        if (query.isEmpty) {
          _filteredDocuments = [];
        } else {
          _filteredDocuments = _cachedResponse!.search(query);
        }
      }
    });
  }

  void _refreshDocuments() {
    setState(() {
      _documentsFuture = _documentService.getAllDocuments().then((result) {
        return result.when(
          success: (data) {
            _cachedResponse = data;
            return data;
          },
          error: (message) {
            throw Exception(message);
          },
        );
      });
      _searchQuery = '';
      _filteredDocuments = [];
    });
  }

  void _openDocument(UnifiedDocument doc) async {
    if (!doc.isDownloadable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This document is not available for download'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      if (doc.fileUrl.isNotEmpty && doc.fileUrl.startsWith('http')) {
        if (await canLaunchUrl(Uri.parse(doc.fileUrl))) {
          await launchUrl(
            Uri.parse(doc.fileUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening: ${doc.title}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening document: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteDocument(UnifiedDocument doc) {
    if (!doc.isDeleteable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This document cannot be deleted'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${doc.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _refreshDocuments();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDocumentDetails(UnifiedDocument doc) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(doc.getIcon(), style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doc.getTypeLabel(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Module', doc.getModuleName()),
              _buildDetailRow('Type', doc.getTypeLabel()),
              _buildDetailRow('Created', doc.getFormattedDate()),
              if (doc.fileSize != null)
                _buildDetailRow('Size', doc.getFormattedSize()),
              if (doc.description != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  doc.description!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
              if (doc.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Tags',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: doc.tags
                      .map(
                        (tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: Color(
                            doc.getColorValue(),
                          ).withValues(alpha: 0.2),
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (doc.isDownloadable)
                    SizedBox(
                      width: doc.isDeleteable
                          ? (MediaQuery.of(context).size.width - 80) / 2
                          : double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                        onPressed: () {
                          Navigator.pop(context);
                          _openDocument(doc);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(doc.getColorValue()),
                        ),
                      ),
                    ),
                  if (doc.isDownloadable && doc.isDeleteable)
                    const SizedBox.shrink(),
                  if (doc.isDeleteable)
                    SizedBox(
                      width: doc.isDownloadable
                          ? (MediaQuery.of(context).size.width - 80) / 2
                          : double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteDocument(doc);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(UnifiedDocument doc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(doc.getColorValue()).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(doc.getIcon(), style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          doc.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  doc.getModuleName(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(doc.getColorValue()),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  doc.getRelativeTime(),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (doc.isDownloadable)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Download'),
                  ],
                ),
                onTap: () => _openDocument(doc),
              ),
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.info),
                  SizedBox(width: 8),
                  Text('Details'),
                ],
              ),
              onTap: () => _showDocumentDetails(doc),
            ),
            if (doc.isDeleteable)
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () => _deleteDocument(doc),
              ),
          ],
        ),
        onTap: () => _showDocumentDetails(doc),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No documents found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Start by uploading a document or filing a complaint',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(AggregatedDocumentsResponse response, int tabIndex) {
    List<UnifiedDocument> documents;

    if (_searchQuery.isNotEmpty) {
      documents = _filteredDocuments;
    } else if (tabIndex == 0) {
      // All tab
      documents = response.allDocuments;
    } else {
      // Module-specific tab
      final moduleIndex = tabIndex - 1;
      if (moduleIndex < _modules.length) {
        documents = response.getByModule(_modules[moduleIndex]);
      } else {
        documents = [];
      }
    }

    if (documents.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _refreshDocuments();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        itemCount: documents.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '${documents.length} document${documents.length != 1 ? 's' : ''} found',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return _buildDocumentTile(documents[index - 1]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Documents',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshDocuments,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search documents...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF00401A),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF00401A),
                tabs: [
                  const Tab(text: 'All'),
                  ...List.generate(
                    _modules.length,
                    (index) => Tab(text: _getModuleTabLabel(_modules[index])),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<AggregatedDocumentsResponse>(
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
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading documents',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    onPressed: _refreshDocuments,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return _buildEmptyState();
          }

          final response = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(response, 0),
              ...List.generate(
                _modules.length,
                (index) => _buildTabContent(response, index + 1),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getModuleTabLabel(DocumentSourceModule module) {
    switch (module) {
      case DocumentSourceModule.personalDocuments:
        return 'Personal';
      case DocumentSourceModule.womenHarassment:
        return 'Harassment';
      case DocumentSourceModule.cyberLaw:
        return 'Cyber Law';
      case DocumentSourceModule.labourRights:
        return 'Labour';
      case DocumentSourceModule.trafficLaws:
        return 'Traffic';
      default:
        return 'Other';
    }
  }
}
