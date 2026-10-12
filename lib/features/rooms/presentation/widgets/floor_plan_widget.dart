import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/room_entity.dart';

// ─────────────────────────────────────────────────────────────
// FloorPlanWidget — denah hardcoded persis seperti gambar asli
// Layout berupa U-shape:
//   - Blok A  : koridor horizontal di atas kanan
//   - Blok D  : dua kolom vertikal di kiri
//   - Blok G  : koridor horizontal di bawah kanan
// ─────────────────────────────────────────────────────────────
class FloorPlanWidget extends StatelessWidget {
  final List<RoomEntity> rooms;
  final RoomEntity? selectedRoom;
  final void Function(RoomEntity room)? onRoomTap;

  const FloorPlanWidget({
    super.key,
    required this.rooms,
    this.selectedRoom,
    this.onRoomTap,
  });

  @override
  Widget build(BuildContext context) {
    final byNumber = {for (final r in rooms) r.roomNumber: r};

    return Column(
      children: [
        _Legend(),
        Expanded(
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(120),
            minScale: 0.35,
            maxScale: 3.0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _GuestHouseDeluxeLayout(
                  byNumber: byNumber,
                  selectedRoom: selectedRoom,
                  onRoomTap: onRoomTap,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Layout utama: mereplikasi denah asli secara eksak
// ─────────────────────────────────────────────────────────────
class _GuestHouseDeluxeLayout extends StatelessWidget {
  final Map<String, RoomEntity> byNumber;
  final RoomEntity? selectedRoom;
  final void Function(RoomEntity)? onRoomTap;

  const _GuestHouseDeluxeLayout({
    required this.byNumber,
    required this.selectedRoom,
    required this.onRoomTap,
  });

  static const double _c = 52; // cell size
  static const double _g = 4; // gap
  static const double _u = _c + _g; // 1 unit

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ════ BLOK A (atas) ════════════════════════════════════
        _sectionLabel('Blok A — Koridor Atas'),
        const SizedBox(height: 4),
        _buildBlokA(),
        const SizedBox(height: _g * 2),

        // ════ AREA TENGAH: Blok D kiri + label + kosong ════════
        _buildBlokDArea(),

        // ════ BLOK G (bawah) ═══════════════════════════════════
        const SizedBox(height: _g * 2),
        _sectionLabel('Blok G — Koridor Bawah'),
        const SizedBox(height: 4),
        _buildBlokG(),
      ],
    );
  }

  // ── BLOK A ──────────────────────────────────────────────────
  // Denah asli:
  // Baris atas : [Lobby B] [   ] [21**] [23***] [27***] [31***] [33]
  // Baris bawah: [Storage] [Pantry] [Kitchen] [20i] [22**] [24***] [30***] [Laundry]
  Widget _buildBlokA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris atas Blok A
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _labelBox('Lobby B', w: _u * 2, h: _c),
            _gap(),
            _labelBox('', w: _u, h: _c * 0.5), // kosong di atas kitchen
            _gap(),
            _room('21', w: 1),
            _gap(),
            _room('23', w: 2),
            _gap(),
            _room('27', w: 2),
            _gap(),
            _room('31', w: 1),
            _gap(),
            _room('33', w: 1),
          ],
        ),
        const SizedBox(height: _g),
        // Baris bawah Blok A (Koridor Blok A label)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          margin: const EdgeInsets.only(bottom: 2),
          child: const Text(
            'Koridor Blok A',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Row(
          children: [
            _labelBox('Storage', w: _u, h: _c),
            _gap(),
            _labelBox('Pantry', w: _u, h: _c),
            _gap(),
            _labelBox('Kitchen', w: _u, h: _c),
            _gap(),
            _room('20i', w: 1),
            _gap(),
            _room('22', w: 1),
            _gap(),
            _room('24', w: 2),
            _gap(),
            _room('30', w: 2),
            _gap(),
            _labelBox('Laundry', w: _u, h: _c),
          ],
        ),
      ],
    );
  }

  // ── BLOK D (kiri vertikal) ───────────────────────────────────
  // Kolom kiri : 18,16,14,12,10,8,6,2  (atas→bawah)
  // [Koridor C di antara]
  // Kolom kanan: 19,17,15,11,7,5,3,1   (atas→bawah)
  Widget _buildBlokDArea() {
    // Pasangan kamar per baris (kiri, kanan)
    final rowsUpper = [
      ('18', '19'),
      ('16', '17'),
      ('14', '15'),
      ('12', '11'),
      ('10', '7'),
      ('8', '5'),
      ('6', '3'),
      ('2', '1'),
    ];
    final rowsLower = [
      ('34', '35'),
      ('36', '37'),
      ('38', '39'),
      ('40', '41'),
      ('42', '43'),
      ('44', '45'),
      ('46', '47'),
      ('48', '49'),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Blok D (dua kolom kamar + koridor di tengah)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Blok D'),
            const SizedBox(height: 4),
            // Bagian atas Blok D
            ...rowsUpper.map(
              (pair) => Padding(
                padding: const EdgeInsets.only(bottom: _g),
                child: Row(
                  children: [
                    _room(pair.$1, w: 1),
                    _gap(),
                    // Koridor C
                    Container(
                      width: _c * 0.4,
                      height: _c,
                      alignment: Alignment.center,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          'C',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    _gap(),
                    _room(pair.$2, w: 1),
                  ],
                ),
              ),
            ),
            // Main Lobby Blok D + Office
            Container(
              width: _u * 2 + _c * 0.4 + _g * 2,
              height: _c,
              margin: const EdgeInsets.only(bottom: _g),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Main Lobby Blok D\nOffice',
                style: TextStyle(fontSize: 9, color: Colors.deepOrange),
                textAlign: TextAlign.center,
              ),
            ),
            // Storage
            Container(
              width: _u * 2 + _c * 0.4 + _g * 2,
              height: _c,
              margin: const EdgeInsets.only(bottom: _g),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Storage',
                style: TextStyle(fontSize: 9, color: Colors.grey),
              ),
            ),
            // Bagian bawah Blok D
            ...rowsLower.map(
              (pair) => Padding(
                padding: const EdgeInsets.only(bottom: _g),
                child: Row(
                  children: [
                    _room(pair.$1, w: 1),
                    _gap(),
                    // Koridor
                    Container(
                      width: _c * 0.4,
                      height: _c,
                      alignment: Alignment.center,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          'C',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    _gap(),
                    _room(pair.$2, w: 1),
                  ],
                ),
              ),
            ),
            // Panel Room + Server MID
            Row(
              children: [
                Container(
                  width: _u,
                  height: _c,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    border: Border.all(color: Colors.blueGrey.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Panel\nRoom',
                    style: TextStyle(fontSize: 8, color: Colors.blueGrey),
                    textAlign: TextAlign.center,
                  ),
                ),
                _gap(),
                SizedBox(width: _c * 0.4, height: _c),
                _gap(),
                Container(
                  width: _u,
                  height: _c,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    border: Border.all(color: Colors.blueGrey.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Server\nMID',
                    style: TextStyle(fontSize: 8, color: Colors.blueGrey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ── BLOK G ───────────────────────────────────────────────────
  // Denah asli:
  // Baris atas : [Kitchen] [50*] [52*] [54***] [60***] [Laundry]
  // Baris bawah: [Lobby F] [51*] [53*] [55***] [61***] [62***]
  Widget _buildBlokG() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label koridor
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          margin: const EdgeInsets.only(bottom: 2),
          child: const Text(
            'Koridor Blok G',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Baris atas Blok G
        Row(
          children: [
            _labelBox('Kitchen', w: _u, h: _c),
            _gap(),
            _room('50', w: 1),
            _gap(),
            _room('52', w: 1),
            _gap(),
            _room('54', w: 2),
            _gap(),
            _room('60', w: 1),
            _gap(),
            _labelBox('Laundry', w: _u, h: _c),
          ],
        ),
        const SizedBox(height: _g),
        // Baris bawah Blok G
        Row(
          children: [
            _labelBox('Lobby\nBlok F', w: _u * 2, h: _c),
            _gap(),
            _room('51', w: 1),
            _gap(),
            _room('53', w: 1),
            _gap(),
            _room('55', w: 2),
            _gap(),
            _room('61', w: 1),
            _gap(),
            _room('62', w: 1),
          ],
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  // Render kamar berdasarkan nomor — cari di map, render sesuai status
  Widget _room(String number, {required double w}) {
    final room = byNumber[number];
    if (room == null) {
      // Kamar tidak ada di data, tampilkan placeholder
      return Container(
        width: _u * w - _g,
        height: _c,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
        ),
      );
    }

    final color = _colorOf(room);
    final isSelected = selectedRoom?.id == room.id;

    return GestureDetector(
      onTap: onRoomTap != null ? () => onRoomTap!(room) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: _u * w - _g,
        height: _c,
        decoration: BoxDecoration(
          color: color.withValues(alpha: isSelected ? 1.0 : 0.88),
          borderRadius: BorderRadius.circular(5),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : Border.all(color: color.withValues(alpha: 0.35), width: 1),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 5)]
              : null,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              room.roomNumber,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: w >= 2 ? 13 : 11,
              ),
              maxLines: 1,
            ),
            Text(
              _symbol(room.roomType),
              style: const TextStyle(color: Colors.white70, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  // Label box untuk area non-kamar (Lobby, Kitchen, Storage, dll)
  Widget _labelBox(String label, {required double w, required double h}) {
    return Container(
      width: w - _g,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _gap() => const SizedBox(width: _g);

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: AppTheme.primary,
      letterSpacing: 0.5,
    ),
  );

  // Warna kamar berdasarkan status + nomor kamar (Japan vs Local longstay)
  Color _colorOf(RoomEntity room) {
    switch (room.status) {
      case RoomStatus.available:
        return AppTheme.roomAvailable;
      case RoomStatus.occupied:
        return AppTheme.roomOccupied;
      case RoomStatus.maintenance:
        return AppTheme.roomMaintenance;
      case RoomStatus.longstay:
        const japanRooms = {'23', '27', '31', '33', '54', '55'};
        const localRooms = {'24', '30', '61', '62'};
        if (japanRooms.contains(room.roomNumber)) {
          return AppTheme.roomLongstayJapan;
        }
        if (localRooms.contains(room.roomNumber)) {
          return AppTheme.roomLongstayLocal;
        }
        return AppTheme.roomLongstayJapan;
    }
  }

  String _symbol(RoomType type) {
    switch (type) {
      case RoomType.doubleBed:
        return '*';
      case RoomType.familyRoom:
        return '**';
      case RoomType.longstayRoom:
        return '***';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Legend bar
// ─────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (color: AppTheme.roomAvailable, label: 'Tersedia'),
      (color: AppTheme.roomOccupied, label: 'Terisi'),
      (color: AppTheme.roomLongstayJapan, label: 'Long Stay Japan'),
      (color: AppTheme.roomLongstayLocal, label: 'Long Stay Lokal'),
      (color: AppTheme.roomMaintenance, label: 'Maintenance'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        children: items
            .map(
              (e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: e.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    e.label,
                    style: const TextStyle(fontSize: 10, color: Colors.black87),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
