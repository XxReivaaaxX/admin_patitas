/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class PDFViewerScreen extends StatefulWidget {
  final String assetPath;
  final String title;

  const PDFViewerScreen({
    super.key,
    required this.assetPath,
    required this.title,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final ByteData data = await rootBundle.load(widget.assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading PDF asset: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar el archivo: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromRGBO(55, 148, 194, 1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _pdfBytes != null
                ? PdfPreview(
                    build: (format) => _pdfBytes!,
                    useActions:
                        false, // Ocultar botones de imprimir/compartir si no se desean
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    scrollViewDecoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                  )
                : const Center(child: Text('No se pudo cargar el PDF')),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(55, 148, 194, 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'He leído y acepto los términos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/