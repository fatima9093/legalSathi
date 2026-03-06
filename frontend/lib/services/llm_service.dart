import 'dart:convert';
import 'package:http/http.dart' as http;

class LlmService {
  // 🔥 NEW: Backend RAG API endpoint
  // Change this to your backend URL
  // - For local development: http://localhost:8000/api/ask
  // - For production: https://your-backend-url.com/api/ask
  static const String _backendUrl = 'http://localhost:8000/api/ask';
  
  // For checking backend health
  static const String _healthUrl = 'http://localhost:8000';

  /// Send message to RAG backend and get response
  /// 
  /// Flow:
  /// 1. Backend searches Vector DB (your PDFs) first
  /// 2. If good match found → returns answer from documents
  /// 3. If no match → uses Groq as fallback
  Future<String> sendMessage(String userMessage, {String? module}) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'question': userMessage,
          if (module != null) 'module': module, // Optional: filter by module
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['answer'] as String;
        final source = data['source'] as String;
        final confidence = data['confidence'] as double;
        
        // Add source indicator for transparency
        String sourceIndicator = '';
        if (source == 'vector_db') {
          final module = data['module'];
          final file = data['file'];
          sourceIndicator = '\n\n📚 Source: $file (${_formatModuleName(module)})';
        } else if (source == 'groq_fallback') {
          sourceIndicator = '\n\n⚠️ Note: No specific documents found. This is general legal information.';
        }
        
        return answer + sourceIndicator;
      } else if (response.statusCode == 500) {
        return '❌ Backend error. Please make sure the backend server is running.\n\nRun: python main.py in the backend folder';
      } else {
        return '❌ Error: ${response.statusCode}\n\nResponse: ${response.body}';
      }
    } catch (e) {
      // Connection error - backend not running
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Connection refused')) {
        return '''❌ Cannot connect to Legal Sathi backend.

Please start the backend server:

1. Open terminal in backend folder
2. Run: python main.py
3. Wait for "🚀 Starting Legal Sathi RAG API..."
4. Then try again

Error: $e''';
      }
      
      return 'Error connecting to Legal Sathi backend.\n\nError: $e';
    }
  }
  
  /// Check if backend is running
  Future<Map<String, dynamic>> checkBackendHealth() async {
    try {
      final response = await http.get(Uri.parse(_healthUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'status': 'online',
          'vector_db_loaded': data['vector_db_loaded'] ?? false,
          'total_documents': data['total_documents'] ?? 0,
        };
      }
      return {'status': 'error', 'message': 'Backend returned ${response.statusCode}'};
    } catch (e) {
      return {'status': 'offline', 'message': e.toString()};
    }
  }
  
  /// Format module name for display
  String _formatModuleName(String? module) {
    if (module == null) return 'General';
    
    final names = {
      'women_harassment': 'Women Harassment',
      'labour_rights': 'Labour Rights',
      'cyber_law': 'Cyber Law',
      'road_laws': 'Road Laws',
    };
    
    return names[module] ?? module;
  }
}

