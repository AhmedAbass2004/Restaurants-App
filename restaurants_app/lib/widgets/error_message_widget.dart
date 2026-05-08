import 'package:flutter/material.dart';

class ErrorMessageWidget extends StatelessWidget {
  const ErrorMessageWidget({super.key, required this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) return SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
    );
  }
}
