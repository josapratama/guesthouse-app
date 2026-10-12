import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../rooms/domain/entities/room_entity.dart';

class NewReservationScreen extends ConsumerStatefulWidget {
  final RoomEntity? preselectedRoom;

  const NewReservationScreen({super.key, this.preselectedRoom});

  @override
  ConsumerState<NewReservationScreen> createState() =>
      _NewReservationScreenState();
}

class _NewReservationScreenState extends ConsumerState<NewReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _guestNameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _remarkCtrl = TextEditingController();

  DateTime? _checkIn;
  DateTime? _checkOut;
  RoomEntity? _selectedRoom;

  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.preselectedRoom;
  }

  @override
  void dispose() {
    _guestNameCtrl.dispose();
    _companyCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isCheckIn) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? (now) : (_checkIn ?? now).add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: isCheckIn ? 'Pilih Tanggal Check In' : 'Pilih Tanggal Check Out',
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        // Reset check out jika lebih awal dari check in baru
        if (_checkOut != null && !_checkOut!.isAfter(picked)) {
          _checkOut = null;
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  int get _totalDays {
    if (_checkIn == null || _checkOut == null) return 0;
    return _checkOut!.difference(_checkIn!).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservasi Baru')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Kamar ───────────────────────────────────────
            _sectionTitle('Kamar'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _selectedRoom != null
                    ? _SelectedRoomInfo(room: _selectedRoom!)
                    : OutlinedButton.icon(
                        onPressed: () {
                          // TODO: navigate to floor plan to pick room
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Pilih dari Denah'),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Tamu ─────────────────────────────────────────
            _sectionTitle('Data Tamu'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _guestNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Tamu *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nama tamu wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _companyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Perusahaan',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Tanggal ───────────────────────────────────────
            _sectionTitle('Tanggal Menginap'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _DatePicker(
                            label: 'Check In',
                            date: _checkIn,
                            onTap: () => _pickDate(true),
                            icon: Icons.login,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DatePicker(
                            label: 'Check Out',
                            date: _checkOut,
                            onTap: () => _pickDate(false),
                            icon: Icons.logout,
                          ),
                        ),
                      ],
                    ),
                    if (_totalDays > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.nights_stay_outlined,
                                size: 18, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '$_totalDays malam',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Keterangan ────────────────────────────────────
            _sectionTitle('Keterangan (opsional)'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _remarkCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Tambahkan catatan...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit ────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _canSubmit ? _onSubmit : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Buat Reservasi'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit =>
      _selectedRoom != null &&
      _checkIn != null &&
      _checkOut != null &&
      _guestNameCtrl.text.isNotEmpty;

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    // TODO: kirim data reservasi ke API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservasi berhasil dibuat!')),
    );
    Navigator.pop(context);
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.primary,
          ),
        ),
      );
}

class _SelectedRoomInfo extends StatelessWidget {
  final RoomEntity room;

  const _SelectedRoomInfo({required this.room});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.hotel, color: AppTheme.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kamar ${room.roomNumber}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(room.typeLabel,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
        const Spacer(),
        TextButton(
          onPressed: null, // TODO: ganti kamar
          child: const Text('Ganti'),
        ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final IconData icon;

  const _DatePicker({
    required this.label,
    this.date,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text(label,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? DateFormat('dd MMM yyyy').format(date!)
                  : 'Pilih tanggal',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: date != null ? Colors.black87 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
