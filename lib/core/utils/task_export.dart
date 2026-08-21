import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/wedding_task.dart';
import 'formatters.dart';

/// Bölüm: Alışveriş listesini metin veya PDF olarak dışa aktarma.
/// Sadece "Alınacak" durumundaki görevleri içerir (çarşı/AVM'de kullanım için).
class TaskExport {
  static List<WeddingTask> _toBuyTasks(List<WeddingTask> tasks) =>
      tasks.where((t) => t.status == WeddingTaskStatus.toBuy).toList();

  static String buildPlainText(String categoryName, List<WeddingTask> tasks) {
    final toBuy = _toBuyTasks(tasks);
    final buffer = StringBuffer();
    buffer.writeln('🛍️ $categoryName - Alınacaklar Listesi');
    buffer.writeln();

    if (toBuy.isEmpty) {
      buffer.writeln('Bu kategoride alınacak bir şey yok 🎉');
    } else {
      for (final task in toBuy) {
        buffer.writeln('☐ ${task.title}${task.estimatedPrice != null ? ' (${formatCurrency(task.estimatedPrice)})' : ''}');
      }
      final total = toBuy.fold<double>(0, (sum, t) => sum + (t.estimatedPrice ?? 0));
      if (total > 0) {
        buffer.writeln();
        buffer.writeln('Tahmini toplam: ${formatCurrency(total)}');
      }
    }

    buffer.writeln();
    buffer.writeln('Bridely ile hazırlandı 💍');
    return buffer.toString();
  }

  static Future<void> shareAsText(String categoryName, List<WeddingTask> tasks) async {
    final text = buildPlainText(categoryName, tasks);
    await Share.share(text, subject: '$categoryName - Alınacaklar Listesi');
  }

  static Future<void> shareAsPdf(String categoryName, List<WeddingTask> tasks) async {
    final toBuy = _toBuyTasks(tasks);
    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '$categoryName - Alınacaklar Listesi',
              style: pw.TextStyle(font: boldFont, fontSize: 20),
            ),
            pw.SizedBox(height: 16),
            if (toBuy.isEmpty)
              pw.Text('Bu kategoride alınacak bir şey yok.', style: pw.TextStyle(font: font))
            else
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  for (final task in toBuy)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text('☐ ${task.title}', style: pw.TextStyle(font: font, fontSize: 13)),
                          ),
                          pw.Text(
                            formatCurrency(task.estimatedPrice),
                            style: pw.TextStyle(font: font, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: '$categoryName-alinacaklar.pdf');
  }
}
