import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/room_entity.dart';

// ─────────────────────────────────────────────────────────────
// FloorPlanWidget — layout persis denah asli Wisma Eucaliptus
//
// Struktur (sama seperti gambar denah):
//
//  [Lobby B][    ][21**][  23***  ][  27***  ][31***][33]
//           [    ][20i ][22**][  24***  ][  30***  ][Laundry]
//  [18*][C][19*]
//  [16*][C][17*]
//  [14*][C][15*]
//  [12*][C][11*]
//  [10*][C][ 7*]
//  [ 8*][C][ 5*]
//  [ 6*][C][ 3*]
//  [ 2*][C][ 1*]
//  [  Office  ]
//  [Main Lobby Blok D]
//  [Storage]
//  [34**][C][35**]
//  ...
//  [48**][C][49*]
//  [PanelRoom][ServerMID]
//           [Kitchen][50*][52*][54***][60***][Laundry]
//  [Lobby F][51* ][53*][  55***  ][61***][62***]
//
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
        _buildLegend(),
        Expanded(
          child: InteractiveViewer(
            constrained: false,
            boundaryMargin: const EdgeInsets.all(80),
            minScale: 0.3,
            maxScale: 3.0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _DeluxeLayout(
                byNumber: byNumber,
                selectedRoom: selectedRoom,
                onRoomTap: onRoomTap,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    final items = [
      (color: AppTheme.roomAvailable, label: 'Tersedia'),
      (color: AppTheme.roomOccupied, label: 'Terisi'),
      (color: AppTheme.roomLongstayJapan, label: 'Long Stay Japan ***'),
      (color: AppTheme.roomLongstayLocal, label: 'Long Stay Lokal ***'),
      (color: Color(0xFF27AE60), label: 'Long Stay Lokal *'),
      (color: AppTheme.roomMaintenance, label: 'Maintenance'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Wrap(
        spacing: 10,
        runSpacing: 5,
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

// ─────────────────────────────────────────────────────────────
// Konstanta ukuran
// ─────────────────────────────────────────────────────────────
const double _cs = 50.0; // cell size
const double _g = 3.0; // gap antar sel
const double _u = _cs + _g; // 1 unit grid

// ─────────────────────────────────────────────────────────────
// Layout utama — Row besar: [Blok D kiri] + [Blok A + Blok G kanan]
// ─────────────────────────────────────────────────────────────
class _DeluxeLayout extends StatelessWidget {
  final Map<String, RoomEntity> byNumber;
  final RoomEntity? selectedRoom;
  final void Function(RoomEntity)? onRoomTap;

  const _DeluxeLayout({
    required this.byNumber,
    required this.selectedRoom,
    required this.onRoomTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Kolom kiri: Blok D (vertikal) ─────────────────────
        _buildBlokDColumn(),
        const SizedBox(width: _g * 2),
        // ── Kolom kanan: Blok A (atas) + Blok G (bawah) ───────
        _buildRightColumn(),
      ],
    );
  }

  // ── BLOK D — dua kolom kamar + koridor C di tengah ──────────
  Widget _buildBlokDColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Lobby B di baris paling atas (sejajar Blok A)
        _area('Lobby B', w: _u * 2 + 10, h: _cs * 2 + _g),
        const SizedBox(height: _g),

        // Kamar Storage + Pantry (sejajar Koridor Blok A)
        Row(
          children: [
            _area('Storage', w: _u, h: _cs),
            const SizedBox(width: _g),
            _area('Pantry', w: _u, h: _cs),
          ],
        ),
        const SizedBox(height: _g),

        // Blok D atas: kamar 18/19 sampai 2/1
        ..._blokDPairs([
          ('18', '19'),
          ('16', '17'),
          ('14', '15'),
          ('12', '11'),
          ('10', '7'),
          ('8', '5'),
          ('6', '3'),
          ('2', '1'),
        ]),
        const SizedBox(height: _g),

        // Office
        _area('Office', w: _u * 2 + 10, h: _cs),
        const SizedBox(height: _g),

        // Main Lobby Blok D
        _area('Main Lobby\nBlok D', w: _u * 2 + 10, h: _cs),
        const SizedBox(height: _g),

        // Storage (antara blok D atas dan bawah)
        _area('Storage', w: _u * 2 + 10, h: _cs),
        const SizedBox(height: _g),

        // Blok D bawah: kamar 34/35 sampai 48/49
        ..._blokDPairs([
          ('34', '35'),
          ('36', '37'),
          ('38', '39'),
          ('40', '41'),
          ('42', '43'),
          ('44', '45'),
          ('46', '47'),
          ('48', '49'),
        ]),
        const SizedBox(height: _g),

        // Panel Room + Server MID
        Row(
          children: [
            _area('Panel\nRoom', w: _u, h: _cs),
            const SizedBox(width: _g),
            _area('Server\nMID', w: _u, h: _cs),
          ],
        ),

        // Lobby Blok F (di bawah kiri, sejajar Blok G)
        const SizedBox(height: _g),
        _area('Lobby\nBlok F', w: _u * 2 + 10, h: _cs * 2 + _g),
      ],
    );
  }

  // Pasangan kamar kiri-kanan dengan koridor di tengah
  List<Widget> _blokDPairs(List<(String, String)> pairs) {
    return pairs
        .map(
          (pair) => Padding(
            padding: const EdgeInsets.only(bottom: _g),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _room(pair.$1),
                // Koridor C
                Container(
                  width: 10,
                  height: _cs,
                  alignment: Alignment.center,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Text(
                      'C',
                      style: TextStyle(
                        fontSize: 7,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _room(pair.$2),
              ],
            ),
          ),
        )
        .toList();
  }

  // ── Kolom kanan: Blok A atas + Blok G bawah ─────────────────
  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBlokA(),
        // Spacer besar — sejajar dengan Blok D tengah (kamar 18 s/d 1 + office + lobby)
        // Tinggi = (8 baris kamar + office + lobby + storage) * unit
        SizedBox(
          height:
              (8 * (_cs + _g)) + // kamar atas
              (_cs + _g) * 3 + // office + lobby + storage
              (8 * (_cs + _g)) + // kamar bawah
              (_cs + _g), // panel row
        ),
        _buildBlokG(),
      ],
    );
  }

  // ── BLOK A ───────────────────────────────────────────────────
  Widget _buildBlokA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris atas: 21 | 23*** | 27*** | 31*** | 33
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _room('21'),
            const SizedBox(width: _g),
            _roomWide('23', w: 2),
            const SizedBox(width: _g),
            _roomWide('27', w: 2),
            const SizedBox(width: _g),
            _room('31'),
            const SizedBox(width: _g),
            _room('33'),
          ],
        ),
        const SizedBox(height: 2),
        // Label "Koridor Blok A"
        Container(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Text(
            'Koridor Blok A',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 2),
        // Baris bawah: Kitchen | 20i | 22** | 24*** | 30*** | Laundry
        Row(
          children: [
            _area('Kitchen', w: _u, h: _cs),
            const SizedBox(width: _g),
            _room('20i'),
            const SizedBox(width: _g),
            _room('22'),
            const SizedBox(width: _g),
            _roomWide('24', w: 2),
            const SizedBox(width: _g),
            _roomWide('30', w: 2),
            const SizedBox(width: _g),
            _area('Laundry', w: _u, h: _cs),
          ],
        ),
      ],
    );
  }

  // ── BLOK G ───────────────────────────────────────────────────
  Widget _buildBlokG() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label "Koridor Blok G"
        Text(
          'Koridor Blok G',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        // Baris atas: Kitchen | 50* | 52* | 54*** | 60*** | Laundry
        Row(
          children: [
            _area('Kitchen', w: _u, h: _cs),
            const SizedBox(width: _g),
            _room('50'),
            const SizedBox(width: _g),
            _room('52'),
            const SizedBox(width: _g),
            _roomWide('54', w: 2),
            const SizedBox(width: _g),
            _roomWide('60', w: 1),
            const SizedBox(width: _g),
            _area('Laundry', w: _u, h: _cs),
          ],
        ),
        const SizedBox(height: _g),
        // Baris bawah: 51* | 53* | 55*** | 61*** | 62***
        Row(
          children: [
            _room('51'),
            const SizedBox(width: _g),
            _room('53'),
            const SizedBox(width: _g),
            _roomWide('55', w: 2),
            const SizedBox(width: _g),
            _room('61'),
            const SizedBox(width: _g),
            _room('62'),
            const SizedBox(width: _g),
            // padding agar sejajar dengan baris atas (Kitchen + Laundry)
            SizedBox(width: _u),
          ],
        ),
      ],
    );
  }

  // ── Kamar 1 unit ─────────────────────────────────────────────
  Widget _room(String number) => _roomWide(number, w: 1);

  // ── Kamar dengan lebar variabel ───────────────────────────────
  Widget _roomWide(String number, {required double w}) {
    final room = byNumber[number];
    final width = _cs * w + _g * (w - 1);

    if (room == null) {
      return Container(
        width: width,
        height: _cs,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
        ),
      );
    }

    final color = _colorOf(room);
    final isSelected = selectedRoom?.id == room.id;

    return GestureDetector(
      onTap: onRoomTap != null ? () => onRoomTap!(room) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        height: _cs,
        decoration: BoxDecoration(
          color: color.withValues(alpha: isSelected ? 1.0 : 0.88),
          borderRadius: BorderRadius.circular(5),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2.5)
              : Border.all(color: color.withValues(alpha: 0.3), width: 1),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 5)]
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
              overflow: TextOverflow.ellipsis,
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

  // ── Area label (non-kamar) ───────────────────────────────────
  Widget _area(String label, {required double w, required double h}) {
    return Container(
      width: w,
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

  // ── Warna kamar ──────────────────────────────────────────────
  Color _colorOf(RoomEntity room) {
    switch (room.status) {
      case RoomStatus.available:
        return AppTheme.roomAvailable;
      case RoomStatus.occupied:
        return AppTheme.roomOccupied;
      case RoomStatus.maintenance:
        return AppTheme.roomMaintenance;
      case RoomStatus.longstay:
        // Oranye = Japan (8 kamar ***)
        const japan = {'23', '27', '31', '33', '54', '55'};
        // Biru = Local *** (kamar 24, 30, 61, 62)
        const localBig = {'24', '30', '61', '62'};
        // Hijau tua = Local * (kamar 2*, tidak ada di data saat ini)
        if (japan.contains(room.roomNumber)) {
          return AppTheme.roomLongstayJapan;
        }
        if (localBig.contains(room.roomNumber)) {
          return AppTheme.roomLongstayLocal;
        }
        return const Color(0xFF27AE60); // hijau tua untuk local *
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
