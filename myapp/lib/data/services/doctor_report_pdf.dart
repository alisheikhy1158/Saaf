import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:saaf/domain/entities/doctor_report.dart';

/// The report as an A4 PDF, made on the phone (the `pdf` package): a title,
/// the latest front photo when there is one, then the report's lines.
Future<Uint8List> buildDoctorReportPdf(DoctorReport report) async {
  final doc = pw.Document(title: 'Skin summary', creator: 'Saaf');
  final photo = report.frontPhoto;
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Header(level: 0, text: 'Skin summary for my dermatologist'),
        if (photo != null)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Image(pw.MemoryImage(photo), height: 220),
          ),
        for (final line in report.lines)
          line.isEmpty ? pw.SizedBox(height: 8) : pw.Paragraph(text: line),
      ],
    ),
  );
  return doc.save();
}
