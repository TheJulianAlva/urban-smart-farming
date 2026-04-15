import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/bloc/ai_diagnosis_bloc.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/bloc/ai_diagnosis_event.dart';
import 'package:urban_smart_farming/features/ai_diagnosis/presentation/bloc/ai_diagnosis_state.dart';

class AiDiagnosisPage extends StatefulWidget {
  final String cropId;

  const AiDiagnosisPage({super.key, required this.cropId});

  @override
  State<AiDiagnosisPage> createState() => _AiDiagnosisPageState();
}

class _AiDiagnosisPageState extends State<AiDiagnosisPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _analyzeImage(BuildContext context) {
    if (_image != null) {
      context.read<AiDiagnosisBloc>().add(
            AnalyzeImageEvent(image: _image!, cropId: widget.cropId),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico IA Gemini'),
        backgroundColor: const Color(0xFF598e70),
      ),
      body: BlocConsumer<AiDiagnosisBloc, AiDiagnosisState>(
        listener: (context, state) {
          if (state is AiDiagnosisError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_image != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_image!, height: 250, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: const Center(
                      child: Text('Ninguna imagen seleccionada',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cámara'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF598e70),
                  ),
                  onPressed: (_image != null && state is! AiDiagnosisLoading)
                      ? () => _analyzeImage(context)
                      : null,
                  child: state is AiDiagnosisLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Analizar Planta',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                
                const SizedBox(height: 30),
                
                if (state is AiDiagnosisSuccess) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Resultados del Análisis',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF598e70))),
                          const Divider(),
                          const SizedBox(height: 10),
                          _buildResultRow('Diagnóstico:', state.analysis.diagnosis),
                          _buildResultRow(
                              'Confianza:',
                              '${state.analysis.confidencePercentage.toStringAsFixed(1)}%'),
                          const SizedBox(height: 10),
                          const Text(
                            'Tratamiento Sugerido:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(state.analysis.suggestedTreatment),
                        ],
                      ),
                    ),
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
