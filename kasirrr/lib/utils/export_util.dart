import 'package:apotek/models/laporan_keuangan_response.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

class ExportUtil {
  Future<void> generatePDF(LaporanKeuanganResponse data, {required String dateTimeStr}) async {
    final datas = data.laporanKeuangan;
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('APOTEK ALIDA FARMA', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text('JURNAL KEUANGAN', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('Periode: $dateTimeStr', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['No', 'Tanggal', 'No Transaksi', 'Keterangan', 'Petugas', 'Debit', 'Kredit'],
            data: List.generate(datas.length, (i) {
              final dt = datas[i];

              return [
                i + 1,
                dt.createdAt,
                dt.buktiTransaksi,
                dt.keterangan,
                dt.petugas,
                NumberFormat('#,###').format(dt.debit),
                NumberFormat('#,###').format(dt.kredit),
              ];
            }),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {
              0: pw.Alignment.center,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Total Debit: Rp ${NumberFormat('#,###').format(data.totalPemasukan)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(width: 20),
              pw.Text('Total Kredit: Rp ${NumberFormat('#,###').format(data.totalPengeluaran)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );

    final fileName = await _genPath('pdf');
    final file = File(fileName);
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  Future<void> generateExcel(LaporanKeuanganResponse data, {required String dateTimeStr}) async {
    final datas = data.laporanKeuangan;
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    List<String> headers = ['No', 'Tanggal', 'No Transaksi', 'Keterangan', 'Petugas', 'Debit', 'Kredit'];
    for (int i = 0; i < headers.length; i++) {
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(headers[i]);
    }

    for (int i = 0; i < datas.length; i++) {
      final dt = datas[i];

      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = TextCellValue('${i + 1}');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value =
          TextCellValue(dt.createdAt.toString());
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value =
          TextCellValue(dt.buktiTransaksi ?? '-');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = TextCellValue(dt.keterangan ?? '-');
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = TextCellValue(dt.petugas);
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value =
          TextCellValue(NumberFormat('#,###').format(dt.debit));
      sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value =
          TextCellValue(NumberFormat('#,###').format(dt.kredit));
    }

    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      String filePath = await _genPath('xlsx');
      final file = File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      // ..writeAsBytes(fileBytes);

      OpenFile.open(file.path);
    }
  }

  Future<String> _genPath(String format) async {
    // Pengecekan perizinan storage
    final permission = await perm.Permission.storage.request();
    if (!permission.isGranted) await perm.Permission.storage.request();

    final permission1 = await perm.Permission.manageExternalStorage.request();
    if (!permission1.isGranted) await perm.Permission.manageExternalStorage.request();

    // Pembuatan nama file berdasarkan waktu saat mengekspor
    final nowStr = DateTime.now().toString();
    String now = nowStr.substring(0, nowStr.indexOf('.'));
    now = now.replaceAll('-', '');
    now = now.replaceAll(' ', '_');
    now = now.replaceAll(':', '');
    final fileName = 'jurnal_keuangan_$now.$format';

    // Mendapatkan direktori memory (eksternal / internal)
    // final dirs = await getExternalStorageDirectories();
    // Directory dir = (dirs == null || dirs.isEmpty)
    //     ? (await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory())
    //     : dirs.last;
    // return '${dir.path}/$fileName';

    return '/storage/emulated/0/Download/$fileName';
  }
}
