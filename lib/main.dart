import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Price Tag Generator / مولد بطاقات الأسعار',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TagGeneratorScreen(),
    );
  }
}

class TagGeneratorScreen extends StatefulWidget {
  const TagGeneratorScreen({super.key});

  @override
  State<TagGeneratorScreen> createState() => _TagGeneratorScreenState();
}

class _TagGeneratorScreenState extends State<TagGeneratorScreen> {
  final TextEditingController _brandController = TextEditingController(text: 'MY Bake');
  final TextEditingController _itemController = TextEditingController(text: 'Chocolate');
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  DateTime _prodDate = DateTime.now();
  DateTime _expDate = DateTime.now().add(const Duration(days: 30));

  static const double labelWidthMm = 55.0;
  static const double labelHeightMm = 40.0;

  Future<void> _selectDate(BuildContext context, bool isProdDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isProdDate ? _prodDate : _expDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        if (isProdDate) {
          _prodDate = picked;
          if (_expDate.isBefore(_prodDate)) {
             _expDate = _prodDate.add(const Duration(days: 30));
          }
        } else {
          _expDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Future<void> _printTag() async {
    final doc = pw.Document();

    final labelFormat = PdfPageFormat(
        labelWidthMm * PdfPageFormat.mm, 
        labelHeightMm * PdfPageFormat.mm,
        marginAll: 1.5 * PdfPageFormat.mm
    );

    final font = await PdfGoogleFonts.amiriBold();

    doc.addPage(
      pw.Page(
        pageFormat: labelFormat,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(1),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // 1. Brand Name
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(vertical: 1),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.8)),
                  ),
                  child: pw.Text(
                    _brandController.text,
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                ),

                // 2. Item Name
                pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(vertical: 1),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(width: 0.8)),
                  ),
                  child: pw.Text(
                    _itemController.text,
                    style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                  ),
                ),

                // 3. Grid Details
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      // English Side
                      pw.Expanded(
                        flex: 6,
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Date: ${_formatDate(_prodDate)}', style: const pw.TextStyle(fontSize: 6.5)),
                            pw.Text('EXP: ${_formatDate(_expDate)}', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                            pw.Text('Weight: ${_weightController.text} Kg', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                            pw.Text('Price: QAR ${_priceController.text}', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ),
                      
                      pw.Container(width: 0.8, color: PdfColors.black),

                      // Arabic Side
                      pw.Expanded(
                        flex: 5,
                        child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('تاريخ الإنتاج', style: pw.TextStyle(font: font, fontSize: 6.5)),
                            pw.Text('الصلاحية', style: pw.TextStyle(font: font, fontSize: 6.5)),
                            pw.Text('الوزن', style: pw.TextStyle(font: font, fontSize: 6.5)),
                            pw.Text('السعر', style: pw.TextStyle(font: font, fontSize: 6.5)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Tag Generator / بطاقة الأسعار'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _brandController, 
                      decoration: const InputDecoration(
                        labelText: 'Brand Name / اسم العلامة التجارية', 
                        border: OutlineInputBorder()
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _itemController, 
                      decoration: const InputDecoration(
                        labelText: 'Item Name / اسم المنتج', 
                        border: OutlineInputBorder()
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: const Text('Prod. Date / الإنتاج', style: TextStyle(fontSize: 11)),
                      subtitle: Text(_formatDate(_prodDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.calendar_today, size: 18),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: const Text('Exp. Date / الصلاحية', style: TextStyle(fontSize: 11)),
                      subtitle: Text(_formatDate(_expDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.calendar_today, size: 18),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                    decoration: const InputDecoration(
                      labelText: 'Weight (Kg) / الوزن', 
                      suffixText: 'Kg', 
                      border: OutlineInputBorder()
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _priceController, 
                    keyboardType: const TextInputType.numberWithOptions(decimal: true), 
                    decoration: const InputDecoration(
                      labelText: 'Price (QAR) / السعر', 
                      prefixText: 'QAR ', 
                      border: OutlineInputBorder()
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _printTag,
              icon: const Icon(Icons.print, size: 24),
              label: const Text('PRINT TAG / طباعة البطاقة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Label Size: 55 mm x 40 mm (5.5 cm x 4 cm)',
              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
