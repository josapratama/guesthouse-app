-- ============================================================
-- Fix Floor Plan Coordinates — sesuai denah asli Wisma Eucaliptus
-- 
-- Layout denah (sumbu X = kolom kiri ke kanan, Y = baris atas ke bawah):
--
-- BLOK A (atas):
--   Baris 1 (Y=0): [Kitchen][20i][21][22][23***][27***][31***][33]
--   Baris 0 (Y=1): [Lobby B][  ][21**][23***][27***][31***][33]  
--   Lebih tepatnya:
--   Y=0 (atas):  21** | 23*** | 27*** | 31*** | 33
--   Y=1 (bawah): Kitchen | 20i | 22** | 24*** | 30*** | Laundry
--
-- BLOK D ATAS (tengah kiri):
--   Kolom kiri  (X=0): 18,16,14,12,10,8,6,2   (atas ke bawah)
--   Kolom kanan (X=1): 19,17,15,11,7,5,3,1     (atas ke bawah)
--   [Koridor di antara Blok D kiri dan kanan]
--
-- BLOK D BAWAH (setelah Lobby/Office):
--   Kolom kiri  (X=0): 34,36,38,40,42,44,46,48
--   Kolom kanan (X=1): 35,37,39,41,43,45,47,49
--
-- BLOK G (bawah):
--   Baris atas (Y=0): Kitchen | 50* | 52* | 54*** | 60***| Laundry
--   Baris bawah(Y=1): Lobby F | 51* | 53* | 55*** | 61***| 62***
-- ============================================================

-- ─── Reset semua koordinat dulu ───────────────────────────────
UPDATE rooms SET floor_plan_x = NULL, floor_plan_y = NULL WHERE property = 'deluxe';

-- ─── BLOK A ───────────────────────────────────────────────────
-- Skala: setiap cell = 1 unit, mulai dari X=3 (setelah Blok D)
-- Baris Y=0 = paling atas Blok A
-- Baris Y=1 = baris kedua Blok A

-- Baris atas Blok A (Y=0): 21, 23, 27, 31, 33
UPDATE rooms SET floor_plan_x=3,  floor_plan_y=0, floor_plan_w=1, floor_plan_h=1 WHERE room_number='21'  AND property='deluxe';
UPDATE rooms SET floor_plan_x=4,  floor_plan_y=0, floor_plan_w=2, floor_plan_h=1 WHERE room_number='23'  AND property='deluxe';
UPDATE rooms SET floor_plan_x=6,  floor_plan_y=0, floor_plan_w=2, floor_plan_h=1 WHERE room_number='27'  AND property='deluxe';
UPDATE rooms SET floor_plan_x=8,  floor_plan_y=0, floor_plan_w=1, floor_plan_h=1 WHERE room_number='31'  AND property='deluxe';
UPDATE rooms SET floor_plan_x=9,  floor_plan_y=0, floor_plan_w=1, floor_plan_h=1 WHERE room_number='33'  AND property='deluxe';

-- Baris bawah Blok A (Y=1): 20i, 22, 24, 30
UPDATE rooms SET floor_plan_x=3,  floor_plan_y=1, floor_plan_w=1, floor_plan_h=1 WHERE room_number='20i' AND property='deluxe';
UPDATE rooms SET floor_plan_x=4,  floor_plan_y=1, floor_plan_w=1, floor_plan_h=1 WHERE room_number='22'  AND property='deluxe';
UPDATE rooms SET floor_plan_x=5,  floor_plan_y=1, floor_plan_w=2, floor_plan_h=1 WHERE room_number='24'  AND property='deluxe';
UPDATE rooms SET floor_plan_x=7,  floor_plan_y=1, floor_plan_w=2, floor_plan_h=1 WHERE room_number='30'  AND property='deluxe';

-- ─── BLOK D ATAS ─────────────────────────────────────────────
-- Kolom kiri X=0, kolom kanan X=1
-- Y mulai dari 1 (sejajar Blok A baris bawah ke bawah)

-- Kolom kiri (kamar genap): 18,16,14,12,10,8,6,2
UPDATE rooms SET floor_plan_x=0, floor_plan_y=1,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='18' AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=2,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='16' AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=3,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='14' AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=4,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='12' AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=5,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='10' AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=6,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='8'  AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=7,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='6'  AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=8,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='2'  AND property='deluxe';

-- Kolom kanan (kamar ganjil): 19,17,15,11,7,5,3,1
UPDATE rooms SET floor_plan_x=1, floor_plan_y=1,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='19' AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=2,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='17' AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=3,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='15' AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=4,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='11' AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=5,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='7'  AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=6,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='5'  AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=7,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='3'  AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=8,  floor_plan_w=1, floor_plan_h=1 WHERE room_number='1'  AND property='deluxe';

-- ─── GAP (Lobby Blok D + Office) Y=9 ─────────────────────────
-- Tidak ada kamar di Y=9, ini adalah area Lobby/Office

-- ─── BLOK D BAWAH ────────────────────────────────────────────
-- Y mulai dari 10

-- Kolom kiri: 34,36,38,40,42,44,46,48
UPDATE rooms SET floor_plan_x=0, floor_plan_y=10, floor_plan_w=1, floor_plan_h=1 WHERE room_number='34' AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=11, floor_plan_w=1, floor_plan_h=1 WHERE room_number='36' AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=12, floor_plan_w=1, floor_plan_h=1 WHERE room_number='38' AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=13, floor_plan_w=1, floor_plan_h=1 WHERE room_number='40' AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=14, floor_plan_w=1, floor_plan_h=1 WHERE room_number='42' AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=15, floor_plan_w=1, floor_plan_h=1 WHERE room_number='44' AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=16, floor_plan_w=1, floor_plan_h=1 WHERE room_number='46' AND property='deluxe';
UPDATE rooms SET floor_plan_x=0, floor_plan_y=17, floor_plan_w=1, floor_plan_h=1 WHERE room_number='48' AND property='deluxe';

-- Kolom kanan: 35,37,39,41,43,45,47,49
UPDATE rooms SET floor_plan_x=1, floor_plan_y=10, floor_plan_w=1, floor_plan_h=1 WHERE room_number='35' AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=11, floor_plan_w=1, floor_plan_h=1 WHERE room_number='37' AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=12, floor_plan_w=1, floor_plan_h=1 WHERE room_number='39' AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=13, floor_plan_w=1, floor_plan_h=1 WHERE room_number='41' AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=14, floor_plan_w=1, floor_plan_h=1 WHERE room_number='43' AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=15, floor_plan_w=1, floor_plan_h=1 WHERE room_number='45' AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=16, floor_plan_w=1, floor_plan_h=1 WHERE room_number='47' AND property='deluxe';
UPDATE rooms SET floor_plan_x=1, floor_plan_y=17, floor_plan_w=1, floor_plan_h=1 WHERE room_number='49' AND property='deluxe';

-- ─── GAP (Server MID + Panel Room) Y=18 ──────────────────────

-- ─── BLOK G ───────────────────────────────────────────────────
-- Baris atas (Y=19): 50, 52, 54, 60
-- Baris bawah (Y=20): 51, 53, 55, 61, 62

-- Baris atas
UPDATE rooms SET floor_plan_x=3, floor_plan_y=19, floor_plan_w=1, floor_plan_h=1 WHERE room_number='50' AND property='deluxe';
UPDATE rooms SET floor_plan_x=4, floor_plan_y=19, floor_plan_w=1, floor_plan_h=1 WHERE room_number='52' AND property='deluxe';
UPDATE rooms SET floor_plan_x=5, floor_plan_y=19, floor_plan_w=2, floor_plan_h=1 WHERE room_number='54' AND property='deluxe';
UPDATE rooms SET floor_plan_x=7, floor_plan_y=19, floor_plan_w=1, floor_plan_h=1 WHERE room_number='60' AND property='deluxe';

-- Baris bawah
UPDATE rooms SET floor_plan_x=2, floor_plan_y=20, floor_plan_w=1, floor_plan_h=1 WHERE room_number='51' AND property='deluxe';
UPDATE rooms SET floor_plan_x=3, floor_plan_y=20, floor_plan_w=1, floor_plan_h=1 WHERE room_number='53' AND property='deluxe';
UPDATE rooms SET floor_plan_x=4, floor_plan_y=20, floor_plan_w=2, floor_plan_h=1 WHERE room_number='55' AND property='deluxe';
UPDATE rooms SET floor_plan_x=6, floor_plan_y=20, floor_plan_w=1, floor_plan_h=1 WHERE room_number='61' AND property='deluxe';
UPDATE rooms SET floor_plan_x=7, floor_plan_y=20, floor_plan_w=1, floor_plan_h=1 WHERE room_number='62' AND property='deluxe';
