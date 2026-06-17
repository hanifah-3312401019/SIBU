import 'dart:convert';
import 'dart:io';
import 'package:universal_io/io.dart' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:excel/excel.dart' as excel;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api/api_base_url.dart';
import '../widgets/sidebar_penjual.dart';
import 'notifikasi_penjual.dart';
// ignore: deprecated_member_use
import 'dart:html' as html;

const _kPrimary4 = Color(0xFF803033);
const _kBg4 = Color(0xFFF5ECEA);

class LaporanPenjualan extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  const LaporanPenjualan({super.key, this.userName, this.userEmail});

  @override
  State<LaporanPenjualan> createState() => _LaporanPenjualanState();
}

class _LaporanPenjualanState extends State<LaporanPenjualan> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _periodIdx = 0;
  final List<String> _periods = ['Harian', 'Mingguan', 'Bulanan'];

  List<int> _getTransactionCounts() {
    final rawCounts = _laporanData!['transaction_counts'] as List;
    return rawCounts.map((v) => v is int ? v : int.tryParse(v.toString()) ?? 0).toList();
  }

  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _laporanData;
  List<Map<String, dynamic>> _produkTerlaris = [];
  bool _isLoading = true;
  String? _token;
  String? _errorMessage;
  int? _touchedBarIndex;
  bool _showTooltip = false;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  // ==================== FETCH DATA ====================
  Future<void> _loadTokenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    await _fetchLaporan();
    await _fetchProdukTerlaris();
  }

  Future<void> _fetchLaporan() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiBaseUrl.laporanPenjualan}?periode=${_periods[_periodIdx].toLowerCase()}&tanggal=${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _laporanData = data['data'];
            _isLoading = false;
            _errorMessage = null;
            _touchedBarIndex = null;
            _showTooltip = false;
          });
        }
      } else {
        setState(() { _isLoading = false; _errorMessage = 'Gagal memuat data laporan'; });
      }
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = 'Error: ${e.toString()}'; });
    }
  }

  Future<void> _fetchProdukTerlaris() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiBaseUrl.laporanProdukTerlaris}?periode=${_periods[_periodIdx].toLowerCase()}&tanggal=${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() => _produkTerlaris = List<Map<String, dynamic>>.from(data['data']));
        }
      }
    } catch (e) {
      debugPrint('Error fetching produk terlaris: $e');
    }
  }

  // ==================== NAVIGASI ====================
  void _changeDate(int direction) {
    setState(() {
      if (_periodIdx == 0) {
        _selectedDate = _selectedDate.add(Duration(days: direction));
      } else if (_periodIdx == 1) {
        _selectedDate = _selectedDate.add(Duration(days: direction * 7));
      } else {
        _selectedDate = direction == -1
            ? DateTime(_selectedDate.year, _selectedDate.month - 1, _selectedDate.day)
            : DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
      }
      _fetchLaporan();
      _fetchProdukTerlaris();
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fetchLaporan();
        _fetchProdukTerlaris();
      });
    }
  }

  void _navigateToNotifikasi() => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiPenjual()));

  // ==================== HELPER KONVERSI DATA ====================
  List<int> _getIntValues() => (_laporanData!['values'] as List).map((v) => v is int ? v : int.tryParse(v.toString()) ?? 0).toList();
  List<int> _getNormalizedValues() => (_laporanData!['normalized_values'] as List).map((v) => v is int ? v : v is double ? v.toInt() : int.tryParse(v.toString()) ?? 0).toList();
  List<String> _getLabels() => (_laporanData!['labels'] as List).map((e) => e.toString()).toList();

  // ==================== HELPER FILTER DATA ====================
  List<MapEntry<String, int>> _getFilteredData() {
    final labels = _getLabels();
    final values = _getIntValues();
    final result = <MapEntry<String, int>>[];

    if (_periodIdx == 0) {
      // Harian: hanya jam 07:00 - 23:00 dengan nilai > 0
      for (int i = 7; i < 17; i++) {
        if (values[i] > 0) {
          result.add(MapEntry(labels[i], values[i]));
        }
      }
    } else if (_periodIdx == 1) {
      // Mingguan: semua hari dengan nilai > 0
      for (int i = 0; i < labels.length; i++) {
        if (values[i] > 0) {
          result.add(MapEntry(labels[i], values[i]));
        }
      }
    } else {
      // Bulanan: semua tanggal dengan nilai > 0
      for (int i = 0; i < labels.length; i++) {
        if (values[i] > 0) {
          result.add(MapEntry(labels[i], values[i]));
        }
      }
    }

    return result;
  }

  // ==================== EXPORT TAHUNAN (SEMUA BULAN) ====================
  Future<void> _exportTahunanToExcel() async {
    setState(() => _isLoading = true);
    try {
      final tahun = _selectedDate.year;
      final response = await http.get(
        Uri.parse('${ApiBaseUrl.laporanPenjualanTahunan}?tahun=$tahun'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode != 200) { _showSnackbar('Gagal memuat data tahunan', Colors.red); return; }
      final data = jsonDecode(response.body);
      if (data['success'] != true) { _showSnackbar('Gagal memuat data tahunan', Colors.red); return; }

      final laporanTahunan = data['data'];
      final labels = List<String>.from(laporanTahunan['labels']);
      final values = List<int>.from(laporanTahunan['values']);

      final produkResponse = await http.get(
        Uri.parse('${ApiBaseUrl.laporanProdukTerlarisTahunan}?tahun=$tahun'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      List<Map<String, dynamic>> produkTahunan = [];
      if (produkResponse.statusCode == 200) {
        final prodData = jsonDecode(produkResponse.body);
        if (prodData['success'] == true) produkTahunan = List<Map<String, dynamic>>.from(prodData['data']);
      }

      var excelFile = excel.Excel.createExcel();
      var sheet = excelFile['Laporan Tahunan $tahun'];
      sheet.appendRow([excel.TextCellValue('LAPORAN PENJUALAN TAHUNAN $tahun')]);
      sheet.appendRow([excel.TextCellValue('')]);
      sheet.appendRow([excel.TextCellValue('Periode'), excel.TextCellValue('Tahunan $tahun')]);
      sheet.appendRow([excel.TextCellValue('Total Penjualan'), excel.TextCellValue(_rupiah(laporanTahunan['total_penjualan']))]);
      sheet.appendRow([excel.TextCellValue('Jumlah Transaksi'), excel.TextCellValue(laporanTahunan['jumlah_transaksi'].toString())]);
      sheet.appendRow([excel.TextCellValue('')]);
      sheet.appendRow([excel.TextCellValue('BULAN'), excel.TextCellValue('PENJUALAN')]);
      for (int i = 0; i < labels.length; i++) {
        sheet.appendRow([excel.TextCellValue(labels[i]), excel.TextCellValue(_rupiah(values[i]))]);
      }
      sheet.appendRow([excel.TextCellValue('')]);
      sheet.appendRow([excel.TextCellValue('PRODUK TERLARIS TAHUNAN')]);
      sheet.appendRow([excel.TextCellValue('No'), excel.TextCellValue('Nama Produk'), excel.TextCellValue('Terjual'), excel.TextCellValue('Total Penjualan')]);
      for (int i = 0; i < produkTahunan.length && i < 3; i++) {
        final p = produkTahunan[i];
        sheet.appendRow([
          excel.TextCellValue((i + 1).toString()),
          excel.TextCellValue(p['nama_produk']),
          excel.TextCellValue(_safeInt(p['total_terjual']).toString()),
          excel.TextCellValue(_rupiah(_safeInt(p['total_penjualan'])))
        ]);
      }
      final excelBytes = excelFile.encode()!;
      if (kIsWeb) {
        final blob = html.Blob([excelBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)..download = 'laporan_tahunan_$tahun.xlsx';
        anchor.click();
        html.Url.revokeObjectUrl(url);
        _showSnackbar('File Excel Tahunan berhasil dibuat', Colors.green);
      } else {
        final file = File('${(await getTemporaryDirectory()).path}/laporan_tahunan_$tahun.xlsx')..writeAsBytesSync(excelBytes);
        await OpenFile.open(file.path);
        _showSnackbar('File Excel Tahunan berhasil dibuat', Colors.green);
      }
    } catch (e) {
      _showSnackbar('Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportTahunanToPDF() async {
    setState(() => _isLoading = true);
    try {
      final tahun = _selectedDate.year;
      final response = await http.get(
        Uri.parse('${ApiBaseUrl.laporanPenjualanTahunan}?tahun=$tahun'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode != 200) { _showSnackbar('Gagal memuat data tahunan', Colors.red); return; }
      final data = jsonDecode(response.body);
      if (data['success'] != true) { _showSnackbar('Gagal memuat data tahunan', Colors.red); return; }

      final laporanTahunan = data['data'];
      final labels = List<String>.from(laporanTahunan['labels']);
      final values = List<int>.from(laporanTahunan['values']);

      final produkResponse = await http.get(
        Uri.parse('${ApiBaseUrl.laporanProdukTerlarisTahunan}?tahun=$tahun'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      List<Map<String, dynamic>> produkTahunan = [];
      if (produkResponse.statusCode == 200) {
        final prodData = jsonDecode(produkResponse.body);
        if (prodData['success'] == true) produkTahunan = List<Map<String, dynamic>>.from(prodData['data']);
      }

      final pdf = pw.Document();
      final maxValue = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 1;
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Header(level: 0, child: pw.Text('LAPORAN PENJUALAN TAHUNAN $tahun', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Container(padding: pw.EdgeInsets.all(10), decoration: pw.BoxDecoration(border: pw.Border.all(), borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Periode: Tahunan $tahun'),
              pw.Text('Total Penjualan: ${_rupiah(laporanTahunan['total_penjualan'])}'),
              pw.Text('Jumlah Transaksi: ${laporanTahunan['jumlah_transaksi']}'),
            ]),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Grafik Penjualan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Wrap(spacing: 8, runSpacing: 8, children: List.generate(12, (i) {
            final v = values[i] / maxValue;
            return pw.Column(children: [
              pw.Container(width: 25, height: (80 * v).clamp(5.0, 80.0), color: v >= 0.9 ? PdfColors.red : PdfColors.red100),
              pw.SizedBox(height: 5),
              pw.Text(labels[i], style: pw.TextStyle(fontSize: 7)),
            ]);
          })),
          pw.SizedBox(height: 30),
          pw.Text('Detail Penjualan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table(border: pw.TableBorder.all(), children: [
            pw.TableRow(children: [
              pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Bulan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Penjualan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
            ]),
            ...List.generate(12, (i) => pw.TableRow(children: [
              pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(labels[i])),
              pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_rupiah(values[i]), textAlign: pw.TextAlign.right)),
            ])),
          ]),
          if (produkTahunan.isNotEmpty) ...[
            pw.SizedBox(height: 30),
            pw.Text('Produk Terlaris Tahunan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(border: pw.TableBorder.all(), children: [
              pw.TableRow(children: [
                pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('#', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Nama Produk', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Terjual', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
              ]),
              ...List.generate(produkTahunan.length > 3 ? 3 : produkTahunan.length, (i) {
                final p = produkTahunan[i];
                return pw.TableRow(children: [
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text((i + 1).toString())),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(p['nama_produk'])),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_safeInt(p['total_terjual']).toString(), textAlign: pw.TextAlign.right)),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_rupiah(_safeInt(p['total_penjualan'])), textAlign: pw.TextAlign.right)),
                ]);
              }),
            ]),
          ],
          pw.SizedBox(height: 20),
          pw.Text('Dicetak: ${DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now().toLocal())}', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
        ],
      ));
      final pdfBytes = await pdf.save();
      if (kIsWeb) {
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)..download = 'laporan_tahunan_$tahun.pdf';
        anchor.click();
        html.Url.revokeObjectUrl(url);
        _showSnackbar('File PDF Tahunan berhasil dibuat', Colors.green);
      } else {
        final file = File('${(await getTemporaryDirectory()).path}/laporan_tahunan_$tahun.pdf')..writeAsBytesSync(pdfBytes);
        await OpenFile.open(file.path);
        _showSnackbar('File PDF Tahunan berhasil dibuat', Colors.green);
      }
    } catch (e) {
      _showSnackbar('Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showTahunanSheet() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Export Laporan Tahunan ${_selectedDate.year}', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: _kPrimary4)),
          const SizedBox(height: 6),
          Text('Export semua bulan dalam setahun', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _ExportBtn(icon: Icons.picture_as_pdf, label: 'PDF', color: Colors.red.shade600, onTap: () { Navigator.pop(context); _exportTahunanToPDF(); })),
            const SizedBox(width: 12),
            Expanded(child: _ExportBtn(icon: Icons.table_chart, label: 'Excel', color: Colors.green.shade600, onTap: () { Navigator.pop(context); _exportTahunanToExcel(); })),
          ]),
        ],
      ),
    ),
  );

  // ==================== EXPORT EXCEL ====================
  Future<void> _exportToExcel() async {
    if (_laporanData == null) { _showSnackbar('Data laporan belum tersedia'); return; }
    setState(() => _isLoading = true);
    try {
      var excelFile = excel.Excel.createExcel();
      var sheet = excelFile['Laporan Penjualan'];
      sheet.appendRow([excel.TextCellValue('LAPORAN PENJUALAN ${_periods[_periodIdx].toUpperCase()}')]);
      sheet.appendRow([excel.TextCellValue('')]);
      sheet.appendRow([excel.TextCellValue('Periode'), excel.TextCellValue(_formatDateRange())]);
      sheet.appendRow([excel.TextCellValue('Total Penjualan'), excel.TextCellValue(_rupiah(_safeInt(_laporanData!['total_penjualan'])))]);
      sheet.appendRow([excel.TextCellValue('Jumlah Transaksi'), excel.TextCellValue(_laporanData!['jumlah_transaksi'].toString())]);
      sheet.appendRow([excel.TextCellValue('')]);
      sheet.appendRow([excel.TextCellValue('TANGGAL/HARI'), excel.TextCellValue('PENJUALAN')]);

      final filteredData = _getFilteredData();
      for (var entry in filteredData) {
        sheet.appendRow([excel.TextCellValue(entry.key), excel.TextCellValue(_rupiah(entry.value))]);
      }

      sheet.appendRow([excel.TextCellValue('')]);
      sheet.appendRow([excel.TextCellValue('PRODUK TERLARIS')]);
      sheet.appendRow([excel.TextCellValue('No'), excel.TextCellValue('Nama Produk'), excel.TextCellValue('Terjual'), excel.TextCellValue('Total Penjualan')]);
      for (int i = 0; i < _produkTerlaris.length && i < 3; i++) {
        final p = _produkTerlaris[i];
        sheet.appendRow([
          excel.TextCellValue((i + 1).toString()),
          excel.TextCellValue(p['nama_produk']),
          excel.TextCellValue(_safeInt(p['total_terjual']).toString()),
          excel.TextCellValue(_rupiah(_safeInt(p['total_penjualan'])))
        ]);
      }

      final excelBytes = excelFile.encode()!;
      if (kIsWeb) {
        final blob = html.Blob([excelBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)..download = 'laporan_penjualan_${DateTime.now().millisecondsSinceEpoch}.xlsx';
        anchor.click();
        html.Url.revokeObjectUrl(url);
        _showSnackbar('File Excel berhasil dibuat', Colors.green);
      } else {
        final file = File('${(await getTemporaryDirectory()).path}/laporan_penjualan_${DateTime.now().millisecondsSinceEpoch}.xlsx')..writeAsBytesSync(excelBytes);
        await OpenFile.open(file.path);
        _showSnackbar('File Excel berhasil dibuat', Colors.green);
      }
    } catch (e) {
      _showSnackbar('Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ==================== EXPORT PDF ====================
  Future<void> _exportToPDF() async {
    if (_laporanData == null) { _showSnackbar('Data laporan belum tersedia'); return; }
    setState(() => _isLoading = true);
    try {
      // filteredData yang hanya menampilkan nilai > 0
      final filteredData = _getFilteredData();
      final filteredLabels = filteredData.map((e) => e.key).toList();
      final filteredValues = filteredData.map((e) => e.value).toList();
      final maxValue = filteredValues.isNotEmpty ? filteredValues.reduce((a, b) => a > b ? a : b) : 1;

      final pdf = pw.Document();
      pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Header(level: 0, child: pw.Text('LAPORAN PENJUALAN ${_periods[_periodIdx].toUpperCase()}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.Container(padding: pw.EdgeInsets.all(10), decoration: pw.BoxDecoration(border: pw.Border.all(), borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('Periode: ${_formatDateRange()}'),
              pw.Text('Total Penjualan: ${_rupiah(_safeInt(_laporanData!['total_penjualan']))}'),
              pw.Text('Jumlah Transaksi: ${_laporanData!['jumlah_transaksi']}'),
            ]),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Grafik Penjualan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          if (filteredLabels.isNotEmpty)
            pw.Wrap(spacing: 8, runSpacing: 8, children: List.generate(filteredLabels.length > 7 ? 7 : filteredLabels.length, (i) {
              final v = filteredValues[i] / maxValue;
              return pw.Column(children: [
                pw.Container(width: 30, height: (80 * v).clamp(5.0, 80.0), color: v >= 0.9 ? PdfColors.red : PdfColors.red100),
                pw.SizedBox(height: 5),
                pw.Text(filteredLabels[i], style: pw.TextStyle(fontSize: 8)),
              ]);
            })),
          pw.SizedBox(height: 30),
          pw.Text('Detail Penjualan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table(border: pw.TableBorder.all(), children: [
            pw.TableRow(children: [
              pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Tanggal/Hari', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Penjualan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
            ]),
            ...List.generate(filteredLabels.length > 14 ? 14 : filteredLabels.length, (i) => pw.TableRow(children: [
              pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(filteredLabels[i])),
              pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_rupiah(filteredValues[i]), textAlign: pw.TextAlign.right)),
            ])),
            if (filteredLabels.length > 14) pw.TableRow(children: [
              pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('...', textAlign: pw.TextAlign.center)),
              pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('...', textAlign: pw.TextAlign.right)),
            ]),
          ]),
          if (_produkTerlaris.isNotEmpty) ...[
            pw.SizedBox(height: 30),
            pw.Text('Produk Terlaris', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(border: pw.TableBorder.all(), children: [
              pw.TableRow(children: [
                pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('#', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Nama Produk', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Terjual', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
              ]),
              ...List.generate(_produkTerlaris.length > 3 ? 3 : _produkTerlaris.length, (i) {
                final p = _produkTerlaris[i];
                return pw.TableRow(children: [
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text((i + 1).toString())),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(p['nama_produk'])),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_safeInt(p['total_terjual']).toString(), textAlign: pw.TextAlign.right)),
                  pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_rupiah(_safeInt(p['total_penjualan'])), textAlign: pw.TextAlign.right)),
                ]);
              }),
            ]),
          ],
          pw.SizedBox(height: 20),
          pw.Text('Dicetak: ${DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now().toLocal())}', style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
        ],
      ));
      final pdfBytes = await pdf.save();
      if (kIsWeb) {
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)..download = 'laporan_penjualan_${DateTime.now().millisecondsSinceEpoch}.pdf';
        anchor.click();
        html.Url.revokeObjectUrl(url);
        _showSnackbar('File PDF berhasil dibuat', Colors.green);
      } else {
        final file = File('${(await getTemporaryDirectory()).path}/laporan_penjualan_${DateTime.now().millisecondsSinceEpoch}.pdf')..writeAsBytesSync(pdfBytes);
        await OpenFile.open(file.path);
        _showSnackbar('File PDF berhasil dibuat', Colors.green);
      }
    } catch (e) {
      _showSnackbar('Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _export(String tipe) => tipe == 'PDF' ? _exportToPDF() : _exportToExcel();

  void _showExportSheet() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Export Laporan', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: _kPrimary4)),
          const SizedBox(height: 6),
          Text('Pilih format export yang diinginkan', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade500)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _ExportBtn(icon: Icons.picture_as_pdf, label: 'PDF', color: Colors.red.shade600, onTap: () { Navigator.pop(context); _export('PDF'); })),
            const SizedBox(width: 12),
            Expanded(child: _ExportBtn(icon: Icons.table_chart, label: 'Excel', color: Colors.green.shade600, onTap: () { Navigator.pop(context); _export('Excel'); })),
          ]),
        ],
      ),
    ),
  );

  // ==================== HELPER ====================
  void _showSnackbar(String message, [Color color = _kPrimary4]) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating));

  int _safeInt(dynamic value) => value == null ? 0 : value is int ? value : value is double ? value.toInt() : int.tryParse(value.toString()) ?? 0;

  String _rupiah(int v) => v >= 1000000 ? 'Rp ${(v / 1000000) % 1 == 0 ? (v / 1000000).toInt() : (v / 1000000).toStringAsFixed(1)}jt' : 'Rp ${v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  String _formatDateRange() {
    if (_laporanData == null) return '';
    switch (_periodIdx) {
      case 0: return _laporanData!['tanggal'] ?? '';
      case 1: return '${_laporanData!['start_date'] ?? ''} - ${_laporanData!['end_date'] ?? ''}';
      case 2: return _laporanData!['bulan'] ?? '';
      default: return '';
    }
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) => Scaffold(
    key: _scaffoldKey,
    backgroundColor: _kBg4,
    drawer: SidebarWidget(userName: widget.userName ?? 'Ani Rani', userEmail: widget.userEmail ?? 'ani@gmail.com', selectedIndex: 3, onItemSelected: (_) => Navigator.pop(context)),
    body: Stack(children: [
      Container(color: _kBg4),
      Positioned(top: 0, left: 0, right: 0, height: MediaQuery.of(context).size.height * 0.28,
        child: Container(decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [Color(0xFF803033), Color(0xFFD8A5A8), Color(0xFFF5ECEA)]),
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        )),
      ),
      SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            IconButton(onPressed: () => _scaffoldKey.currentState?.openDrawer(), icon: const Icon(Icons.menu, color: Colors.white, size: 24), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
            const Spacer(),
            GestureDetector(onTap: _navigateToNotifikasi,
              child: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.notifications_none, color: Color(0xFF803033), size: 20),
              ),
            ),
          ]),
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Laporan Penjualan', style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Data laporan penjualan', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _isLoading ? const Center(child: CircularProgressIndicator(color: _kPrimary4))
              : _errorMessage != null ? Center(child: Text(_errorMessage!))
              : _laporanData == null ? const Center(child: Text('Tidak ada data'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // PERIODE SELECTOR
                    Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Row(children: List.generate(_periods.length, (i) {
                        final sel = _periodIdx == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () { setState(() { _periodIdx = i; _fetchLaporan(); _fetchProdukTerlaris(); }); },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(color: sel ? _kPrimary4 : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                              child: Text(_periods[i], textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : Colors.grey.shade500),
                              ),
                            ),
                          ),
                        );
                      })),
                    ),
                    const SizedBox(height: 12),

                    // DATE PICKER
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      IconButton(onPressed: () => _changeDate(-1), icon: const Icon(Icons.chevron_left, color: Color.fromARGB(255, 255, 255, 255))),
                      GestureDetector(onTap: _selectDate,
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _kPrimary4.withOpacity(0.3))),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.calendar_today, size: 16, color: _kPrimary4),
                            const SizedBox(width: 8),
                            Text(_formatDateRange(), style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                          ]),
                        ),
                      ),
                      IconButton(onPressed: () => _changeDate(1), icon: const Icon(Icons.chevron_right, color: Color.fromARGB(255, 255, 255, 255))),
                    ]),
                    const SizedBox(height: 8),

                    // SUMMARY CARD
                    Container(padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Total Penjualan', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade500)),
                            const SizedBox(height: 4),
                            Text(_rupiah(_safeInt(_laporanData!['total_penjualan'])), style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87)),
                          ]),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('Transaksi', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade500)),
                            const SizedBox(height: 4),
                            Text('${_laporanData!['jumlah_transaksi']}', style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87)),
                          ]),
                        ]),
                        const SizedBox(height: 20),
                        _buildChart(),
                      ]),
                    ),
                    const SizedBox(height: 24),

                    // PRODUK TERLARIS
                    if (_produkTerlaris.isNotEmpty) ...[
                      Text('Produk Terlaris', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
                      const SizedBox(height: 12),
                      ..._produkTerlaris.take(3).map((item) {
                        final index = _produkTerlaris.indexOf(item);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                          child: Row(children: [
                            Container(width: 36, height: 36, decoration: BoxDecoration(color: _kPrimary4.withOpacity(0.1), shape: BoxShape.circle),
                              child: Center(child: Text('#${index + 1}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: _kPrimary4))),
                            ),
                            const SizedBox(width: 12),
                            Container(width: 50, height: 50, decoration: BoxDecoration(color: _kBg4, borderRadius: BorderRadius.circular(10)),
                              child: ClipRRect(borderRadius: BorderRadius.circular(10),
                                child: item['gambar'] != null && item['gambar'].toString().isNotEmpty
                                    ? Image.network(ApiBaseUrl.getImageUrl(item['gambar']), width: 50, height: 50, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(Icons.image, color: _kPrimary4))
                                    : Icon(Icons.checkroom, color: _kPrimary4, size: 30),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item['nama_produk'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('Terjual ${_safeInt(item['total_terjual'])} pcs', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600)),
                            ])),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: _kPrimary4.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: Text('${_safeInt(item['total_terjual'])}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: _kPrimary4)),
                              ),
                              const SizedBox(height: 4),
                              Text(_rupiah(_safeInt(item['total_penjualan'])), style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: _kPrimary4)),
                            ]),
                          ]),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],

                    // EXPORT BUTTON
                    SizedBox(width: double.infinity,
                      child: ElevatedButton.icon(onPressed: _showExportSheet,
                        icon: const Icon(Icons.download, color: Colors.white, size: 18),
                        label: Text('Export Laporan (PDF / Excel)', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(backgroundColor: _kPrimary4, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),

                    // TOMBOL TAHUNAN
                    if (_periodIdx == 2) ...[
                      const SizedBox(height: 12),
                      SizedBox(width: double.infinity,
                        child: ElevatedButton.icon(onPressed: _showTahunanSheet,
                          icon: const Icon(Icons.calendar_month, color: _kPrimary4, size: 18),
                          label: Text('Export Laporan Tahunan ${_selectedDate.year} (PDF / Excel)',
                            style: GoogleFonts.plusJakartaSans(color: _kPrimary4, fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF5ECEA),
                            side: BorderSide(color: _kPrimary4, width: 1.5), elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ]),
                ),
        ),
      ])),
    ]),
  );

  // ==================== CHART BUILDER ====================
  Widget _buildChart() {
    final labels = _getLabels();
    final normalizedValues = _getNormalizedValues();
    final intValues = _getIntValues();
    return _periodIdx == 0
        ? _buildLineChartWithTooltip(labels, normalizedValues, intValues)
        : _buildBarChartWithTooltip(labels, normalizedValues, intValues);
  }

  // ==================== LINE CHART DENGAN TOOLTIP ====================
  Widget _buildLineChartWithTooltip(List<String> labels, List<int> normalizedValues, List<int> intValues) {
    final transactionCounts = _getTransactionCounts();
    final filteredLabels = <String>[];
    final filteredValues = <double>[];
    final filteredCounts = <int>[];

    for (int i = 0; i < labels.length; i++) {
      final hour = int.tryParse(labels[i].split(':')[0]) ?? 0;
      if (hour >= 7 && hour <= 23) {
        filteredLabels.add(labels[i].split(':')[0]);
        filteredValues.add(intValues[i].toDouble());
        filteredCounts.add(transactionCounts[i]);
      }
    }

    if (filteredValues.isEmpty) return const SizedBox(height: 150, child: Center(child: Text('Tidak ada data penjualan')));

    final maxValue = filteredValues.isNotEmpty ? filteredValues.reduce((a, b) => a > b ? a : b) : 1;

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: (filteredLabels.length * 34.0) + 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: LineChart(LineChartData(
              gridData: FlGridData(show: true, drawHorizontalLine: true, drawVerticalLine: false,
                horizontalInterval: maxValue / 4 > 0 ? maxValue / 4 : 1,
                getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1, dashArray: [5, 5])),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1,
                  getTitlesWidget: (v, m) {
                    final idx = v.toInt();
                    return idx >= 0 && idx < filteredLabels.length
                        ? Padding(padding: const EdgeInsets.only(top: 8),
                            child: Text(filteredLabels[idx], style: GoogleFonts.plusJakartaSans(fontSize: 9, color: Colors.grey.shade500)))
                        : const Text('');
                  },
                )),
              ),
              borderData: FlBorderData(show: false),
              minX: 0, maxX: (filteredLabels.length - 1).toDouble(),
              minY: 0, maxY: maxValue * 1.2,
              lineTouchData: LineTouchData(enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipColor: (_) => _kPrimary4,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final idx = spot.x.toInt();
                    final count = idx >= 0 && idx < filteredCounts.length ? filteredCounts[idx] : 0;
                    return LineTooltipItem('$count transaksi', const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white));
                  }).toList(),
                ),
                handleBuiltInTouches: true,
              ),
              lineBarsData: [LineChartBarData(
                spots: List.generate(filteredValues.length, (i) => FlSpot(i.toDouble(), filteredValues[i])),
                isCurved: true,
                color: _kPrimary4,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true,
                  getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 5, color: Colors.white, strokeWidth: 2.5, strokeColor: _kPrimary4)),
                belowBarData: BarAreaData(show: false),
              )],
            )),
          ),
        ),
      ),
    );
  }

  // ==================== BAR CHART & TOOLTIP ====================
  Widget _buildBarChartWithTooltip(List<String> labels, List<int> normalizedValues, List<int> intValues) {
    final transactionCounts = _getTransactionCounts();
    final displayLabels = labels;
    final displayValues = normalizedValues;
    final displayCounts = transactionCounts;
    final maxValue = displayValues.isNotEmpty ? displayValues.reduce((a, b) => a > b ? a : b) : 1;

    final dataWithValue = <int>[];
    for (int i = 0; i < displayValues.length; i++) {
      if (displayValues[i] > 0) dataWithValue.add(i);
    }
    if (dataWithValue.isEmpty) return const SizedBox(height: 150, child: Center(child: Text('Tidak ada data penjualan')));

    final barWidth = displayLabels.length <= 7 ? 28.0 : 22.0;
    final spacing = displayLabels.length <= 7 ? 16.0 : 10.0;

    return SizedBox(
      height: 180,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(displayLabels.length, (i) {
              final v = displayValues[i];
              final isHighest = v == maxValue && v > 0;
              final isTouched = _touchedBarIndex == i;
              final count = displayCounts[i];
              return GestureDetector(
                onTap: () => setState(() {
                  if (_touchedBarIndex == i) { _touchedBarIndex = null; _showTooltip = false; }
                  else { _touchedBarIndex = i; _showTooltip = true; }
                }),
                child: Container(
                  margin: EdgeInsets.only(right: spacing),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isTouched && _showTooltip && v > 0)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: _kPrimary4, borderRadius: BorderRadius.circular(8)),
                          child: Text('$count transaksi', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: barWidth,
                        height: v > 0 ? (100 * (v / 100)).clamp(5.0, 100.0) : 0,
                        decoration: BoxDecoration(
                          color: isTouched ? _kPrimary4 : (isHighest ? _kPrimary4 : _kPrimary4.withOpacity(0.25)),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(displayLabels[i],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: displayLabels.length <= 7 ? 11 : 9,
                          color: isTouched ? _kPrimary4 : Colors.grey.shade500,
                          fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _ExportBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ExportBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Column(children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.plusJakartaSans(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
      ]),
    ),
  );
}
