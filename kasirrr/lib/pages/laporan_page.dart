import 'package:apotek/models/laporan_keuangan_response.dart';
import 'package:apotek/services/api_service.dart';
import 'package:apotek/utils/export_util.dart';
import 'package:apotek/widgets/button.dart';
import 'package:apotek/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String _selectedPeriode = 'Harian';
  String _selectedFormat = 'PDF';
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final apiService = ApiService();
  final exportUtil = ExportUtil();
  bool isLoading = false;
  LaporanKeuanganResponse laporan = const LaporanKeuanganResponse();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Filter Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedPeriode,
                    decoration: const InputDecoration(
                      labelText: 'Periode',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Harian', 'Bulanan', 'Tahunan'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriode = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDateSelector(),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedFormat,
                    decoration: const InputDecoration(
                      labelText: 'Format',
                      border: OutlineInputBorder(),
                    ),
                    items: ['PDF', 'Excel'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFormat = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Button(
                      isLoading: isLoading,
                      label: 'Export',
                      onPressed: () async {
                        await _getReports();
                        _selectedFormat == 'PDF' ? _exportPDF() : _exportExcel();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------ START API
  Future<void> _getReports() async {
    setState(() {
      isLoading = true;
      laporan = const LaporanKeuanganResponse();
    });

    DateTime date;
    if (_selectedPeriode == 'Harian') {
      date = _selectedDate;
    } else if (_selectedPeriode == 'Bulanan') {
      date = DateTime(_selectedYear, _selectedMonth, 1);
    } else {
      date = DateTime(_selectedYear, 1, 1);
    }

    final result = await apiService.getLaporan(periode: _selectedPeriode, date: DateFormat('yyyy-MM-dd').format(date));
    setState(() => isLoading = false);

    result.fold(
      (l) => showToastError(context, e: l),
      (r) => setState(() => laporan = r),
    );
  }
  // ------ END API

  // -------------------------------------------------

  Widget _buildDateSelector() {
    switch (_selectedPeriode) {
      case 'Harian':
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Tanggal',
              border: OutlineInputBorder(),
            ),
            child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
          ),
        );
      case 'Bulanan':
        return Column(
          children: [
            DropdownButtonFormField<int>(
              value: _selectedMonth,
              decoration: const InputDecoration(
                labelText: 'Bulan',
                border: OutlineInputBorder(),
              ),
              items: List.generate(12, (index) => index + 1)
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(DateFormat('MMMM').format(DateTime(2024, e))),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Tahun',
                border: OutlineInputBorder(),
              ),
              items: List.generate(10, (index) => DateTime.now().year - index)
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedYear = value!;
                });
              },
            ),
          ],
        );
      case 'Tahunan':
        return DropdownButtonFormField<int>(
          value: _selectedYear,
          decoration: const InputDecoration(
            labelText: 'Tahun',
            border: OutlineInputBorder(),
          ),
          items: List.generate(10, (index) => DateTime.now().year - index)
              .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedYear = value!;
            });
          },
        );
      default:
        return Container();
    }
  }

  String _getPeriodeText() {
    String periodText = '';
    switch (_selectedPeriode) {
      case 'Harian':
        periodText = DateFormat('dd MMMM yyyy').format(_selectedDate);
        break;
      case 'Bulanan':
        periodText = DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth));
        break;
      case 'Tahunan':
        periodText = _selectedYear.toString();
        break;
    }
    return periodText;
  }

  Future<void> _exportPDF() async {
    try {
      await exportUtil.generatePDF(laporan, dateTimeStr: _getPeriodeText());
      if (!mounted) return;
    } catch (e) {
      showToastError(context, e: 'Gagal membuat PDF: $e');
    }
  }

  Future<void> _exportExcel() async {
    try {
      await exportUtil.generateExcel(laporan, dateTimeStr: _getPeriodeText());
      if (!mounted) return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat Excel: $e')),
      );
    }
  }
}
