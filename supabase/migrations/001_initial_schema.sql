-- ============================================================
-- Guest House Deluxe & VIIP — Initial Schema
-- ============================================================

-- ─── Extensions ──────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─── Roles untuk PostgREST ───────────────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated NOLOGIN;
  END IF;
END
$$;

-- ─── ENUM Types ───────────────────────────────────────────────
CREATE TYPE user_role AS ENUM ('admin', 'receptionist', 'guest');

CREATE TYPE room_type AS ENUM (
  'double_bed',    -- * (1-2 person)
  'family_room',   -- ** (1-3 person)
  'longstay_room'  -- *** (Longstay / Big room)
);

CREATE TYPE room_status AS ENUM (
  'available',
  'occupied',
  'longstay',
  'maintenance'
);

CREATE TYPE property_type AS ENUM (
  'deluxe',  -- Guest House Deluxe
  'viip'     -- Guest House Accasia (VIIP)
);

CREATE TYPE reservation_status AS ENUM (
  'pending',
  'confirmed',
  'checked_in',
  'checked_out',
  'cancelled'
);

-- ─── USERS ───────────────────────────────────────────────────
CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        VARCHAR(150) NOT NULL,
  email       VARCHAR(150) UNIQUE NOT NULL,
  password    TEXT NOT NULL, -- bcrypt hash
  role        user_role NOT NULL DEFAULT 'guest',
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── ROOMS ───────────────────────────────────────────────────
CREATE TABLE rooms (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_number   VARCHAR(10) NOT NULL,        -- e.g. "1", "36", "VIP 01"
  room_name     VARCHAR(100),                -- e.g. "Double Bed", "Family Room"
  room_type     room_type NOT NULL,
  property      property_type NOT NULL DEFAULT 'deluxe',
  floor         INTEGER,
  capacity      INTEGER NOT NULL DEFAULT 2,  -- max occupancy
  price_per_night NUMERIC(12,2) NOT NULL DEFAULT 0,
  status        room_status NOT NULL DEFAULT 'available',
  -- Posisi di denah (grid koordinat untuk interactive floor plan)
  floor_plan_x  NUMERIC(6,2),
  floor_plan_y  NUMERIC(6,2),
  floor_plan_w  NUMERIC(6,2) DEFAULT 1,
  floor_plan_h  NUMERIC(6,2) DEFAULT 1,
  notes         TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (room_number, property)
);

-- ─── COMPANIES ───────────────────────────────────────────────
CREATE TABLE companies (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        VARCHAR(200) NOT NULL UNIQUE,
  address     TEXT,
  phone       VARCHAR(30),
  email       VARCHAR(150),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── GUESTS ──────────────────────────────────────────────────
CREATE TABLE guests (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          VARCHAR(150) NOT NULL,
  id_number     VARCHAR(50),              -- No KTP / Passport
  phone         VARCHAR(30),
  email         VARCHAR(150),
  company_id    UUID REFERENCES companies(id) ON DELETE SET NULL,
  address       TEXT,
  nationality   VARCHAR(50) DEFAULT 'Indonesia',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ─── RESERVATIONS ────────────────────────────────────────────
CREATE TABLE reservations (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reservation_no  VARCHAR(30) UNIQUE NOT NULL, -- e.g. "RSV-2026-0001"
  guest_id        UUID NOT NULL REFERENCES guests(id),
  room_id         UUID NOT NULL REFERENCES rooms(id),
  company_id      UUID REFERENCES companies(id) ON DELETE SET NULL,
  receptionist_id UUID REFERENCES users(id) ON DELETE SET NULL,
  -- Tanggal
  check_in_date   DATE NOT NULL,
  check_out_date  DATE NOT NULL,
  actual_check_in   TIMESTAMPTZ,
  actual_check_out  TIMESTAMPTZ,
  total_days      INTEGER GENERATED ALWAYS AS (check_out_date - check_in_date) STORED,
  -- Kamar
  occupied_room   INTEGER NOT NULL DEFAULT 1,
  -- Status & Catatan
  status          reservation_status NOT NULL DEFAULT 'pending',
  remark          TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT check_dates CHECK (check_out_date > check_in_date)
);

-- ─── AUTO INCREMENT reservation_no ───────────────────────────
CREATE SEQUENCE reservation_seq START 1;

CREATE OR REPLACE FUNCTION generate_reservation_no()
RETURNS TRIGGER AS $$
BEGIN
  NEW.reservation_no := 'RSV-' || TO_CHAR(NOW(), 'YYYY') || '-' ||
                        LPAD(NEXTVAL('reservation_seq')::TEXT, 4, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_reservation_no
  BEFORE INSERT ON reservations
  FOR EACH ROW
  WHEN (NEW.reservation_no IS NULL OR NEW.reservation_no = '')
  EXECUTE FUNCTION generate_reservation_no();

-- ─── AUTO UPDATE updated_at ───────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_rooms_updated_at
  BEFORE UPDATE ON rooms FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_guests_updated_at
  BEFORE UPDATE ON guests FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_reservations_updated_at
  BEFORE UPDATE ON reservations FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ─── INDEXES ──────────────────────────────────────────────────
CREATE INDEX idx_rooms_status ON rooms(status);
CREATE INDEX idx_rooms_property ON rooms(property);
CREATE INDEX idx_reservations_guest ON reservations(guest_id);
CREATE INDEX idx_reservations_room ON reservations(room_id);
CREATE INDEX idx_reservations_dates ON reservations(check_in_date, check_out_date);
CREATE INDEX idx_reservations_status ON reservations(status);

-- ─── SEED: Default Users ──────────────────────────────────────
INSERT INTO users (name, email, password, role) VALUES
  ('Administrator', 'admin@guesthouse.com',
   crypt('admin123', gen_salt('bf')), 'admin'),
  ('Resepsionis 1', 'resep1@guesthouse.com',
   crypt('resep123', gen_salt('bf')), 'receptionist');

-- ─── SEED: Companies ─────────────────────────────────────────
INSERT INTO companies (name) VALUES
  ('PT Mega Karya Analitika'),
  ('PT Tei Standby'),
  ('PT Marsh Insurance Broker Ind'),
  ('PT Marsh Insurance Local'),
  ('PT Ansuransi MSIG Indo'),
  ('PT Marnic Corporation'),
  ('PT Marubeni Indonesia'),
  ('PT Kresindo MP'),
  ('PT Andika Utama Mandiri'),
  ('PT Tei Jakarta'),
  ('PT Efasindo Primantara'),
  ('PT SMBC Indonesia'),
  ('PT Valmet'),
  ('PT Yokogawa'),
  ('PT Sei Liput');

-- ─── SEED: Rooms — Guest House Deluxe ────────────────────────
-- Berdasarkan denah: Block A, Block D, Block G
-- Tipe: * Double Bed, ** Family Room, *** Longstay
INSERT INTO rooms (room_number, room_name, room_type, property, capacity, floor_plan_x, floor_plan_y, floor_plan_w, floor_plan_h, price_per_night, status) VALUES
  -- Blok D Kiri (kamar 2, 6, 8, 10, 12, 14, 16, 18)
  ('2',  'Double Bed', 'double_bed',    'deluxe', 2, 1, 8,  1, 1, 250000, 'available'),
  ('6',  'Double Bed', 'double_bed',    'deluxe', 2, 1, 7,  1, 1, 250000, 'available'),
  ('8',  'Double Bed', 'double_bed',    'deluxe', 2, 1, 6,  1, 1, 250000, 'available'),
  ('10', 'Double Bed', 'double_bed',    'deluxe', 2, 1, 5,  1, 1, 250000, 'available'),
  ('12', 'Double Bed', 'double_bed',    'deluxe', 2, 1, 4,  1, 1, 250000, 'available'),
  ('14', 'Double Bed', 'double_bed',    'deluxe', 2, 1, 3,  1, 1, 250000, 'available'),
  ('16', 'Double Bed', 'double_bed',    'deluxe', 2, 1, 2,  1, 1, 250000, 'available'),
  ('18', 'Double Bed', 'double_bed',    'deluxe', 2, 1, 1,  1, 1, 250000, 'available'),
  -- Blok D Kanan (kamar 1, 3, 5, 7, 11, 15, 17, 19)
  ('1',  'Double Bed', 'double_bed',    'deluxe', 2, 2, 8,  1, 1, 250000, 'available'),
  ('3',  'Double Bed', 'double_bed',    'deluxe', 2, 2, 7,  1, 1, 250000, 'available'),
  ('5',  'Double Bed', 'double_bed',    'deluxe', 2, 2, 6,  1, 1, 250000, 'available'),
  ('7',  'Double Bed', 'double_bed',    'deluxe', 2, 2, 5,  1, 1, 250000, 'available'),
  ('11', 'Double Bed', 'double_bed',    'deluxe', 2, 2, 4,  1, 1, 250000, 'available'),
  ('15', 'Double Bed', 'double_bed',    'deluxe', 2, 2, 3,  1, 1, 250000, 'available'),
  ('17', 'Double Bed', 'double_bed',    'deluxe', 2, 2, 2,  1, 1, 250000, 'available'),
  ('19', 'Double Bed', 'double_bed',    'deluxe', 2, 2, 1,  1, 1, 250000, 'available'),
  -- Blok D Bawah Kiri (34, 36, 38, 40, 42, 44, 46, 48)
  ('34', 'Family Room', 'family_room',  'deluxe', 3, 1, 10, 1, 1, 350000, 'available'),
  ('36', 'Family Room', 'family_room',  'deluxe', 3, 1, 11, 1, 1, 350000, 'available'),
  ('38', 'Family Room', 'family_room',  'deluxe', 3, 1, 12, 1, 1, 350000, 'available'),
  ('40', 'Double Bed',  'double_bed',   'deluxe', 2, 1, 13, 1, 1, 250000, 'available'),
  ('42', 'Family Room', 'family_room',  'deluxe', 3, 1, 14, 1, 1, 350000, 'available'),
  ('44', 'Family Room', 'family_room',  'deluxe', 3, 1, 15, 1, 1, 350000, 'available'),
  ('46', 'Family Room', 'family_room',  'deluxe', 3, 1, 16, 1, 1, 350000, 'available'),
  ('48', 'Family Room', 'family_room',  'deluxe', 3, 1, 17, 1, 1, 350000, 'available'),
  -- Blok D Bawah Kanan (35, 37, 39, 41, 43, 45, 47, 49)
  ('35', 'Family Room', 'family_room',  'deluxe', 3, 2, 10, 1, 1, 350000, 'available'),
  ('37', 'Family Room', 'family_room',  'deluxe', 3, 2, 11, 1, 1, 350000, 'available'),
  ('39', 'Family Room', 'family_room',  'deluxe', 3, 2, 12, 1, 1, 350000, 'available'),
  ('41', 'Family Room', 'family_room',  'deluxe', 3, 2, 13, 1, 1, 350000, 'available'),
  ('43', 'Family Room', 'family_room',  'deluxe', 3, 2, 14, 1, 1, 350000, 'available'),
  ('45', 'Family Room', 'family_room',  'deluxe', 3, 2, 15, 1, 1, 350000, 'available'),
  ('47', 'Family Room', 'family_room',  'deluxe', 3, 2, 16, 1, 1, 350000, 'available'),
  ('49', 'Double Bed',  'double_bed',   'deluxe', 2, 2, 17, 1, 1, 250000, 'available'),
  -- Blok A (20i, 21, 22, 23, 24, 27, 30, 31, 33)
  ('20i','Double Bed',  'double_bed',   'deluxe', 2, 4, 1,  1, 1, 250000, 'available'),
  ('21', 'Double Bed',  'double_bed',   'deluxe', 2, 5, 1,  1, 1, 250000, 'available'),
  ('22', 'Family Room', 'family_room',  'deluxe', 3, 4, 2,  1, 1, 350000, 'available'),
  ('23', 'Longstay Room','longstay_room','deluxe', 4, 5, 2,  2, 1, 500000, 'longstay'),
  ('24', 'Longstay Room','longstay_room','deluxe', 4, 4, 3,  2, 1, 500000, 'longstay'),
  ('27', 'Longstay Room','longstay_room','deluxe', 4, 6, 2,  2, 1, 500000, 'longstay'),
  ('30', 'Longstay Room','longstay_room','deluxe', 4, 6, 3,  2, 1, 500000, 'longstay'),
  ('31', 'Longstay Room','longstay_room','deluxe', 4, 8, 2,  1, 1, 500000, 'longstay'),
  ('33', 'Longstay Room','longstay_room','deluxe', 4, 9, 2,  1, 1, 500000, 'longstay'),
  -- Blok G (50, 51, 52, 53, 54, 55, 60, 61, 62)
  ('50', 'Double Bed',  'double_bed',   'deluxe', 2, 4, 19, 1, 1, 250000, 'available'),
  ('51', 'Double Bed',  'double_bed',   'deluxe', 2, 3, 20, 1, 1, 250000, 'available'),
  ('52', 'Double Bed',  'double_bed',   'deluxe', 2, 5, 19, 1, 1, 250000, 'available'),
  ('53', 'Double Bed',  'double_bed',   'deluxe', 2, 4, 20, 1, 1, 250000, 'available'),
  ('54', 'Longstay Room','longstay_room','deluxe', 4, 6, 19, 2, 1, 500000, 'longstay'),
  ('55', 'Longstay Room','longstay_room','deluxe', 4, 6, 20, 2, 1, 500000, 'longstay'),
  ('60', 'Longstay Room','longstay_room','deluxe', 4, 8, 19, 1, 1, 500000, 'longstay'),
  ('61', 'Longstay Room','longstay_room','deluxe', 4, 8, 20, 1, 1, 500000, 'longstay'),
  ('62', 'Longstay Room','longstay_room','deluxe', 4, 9, 20, 1, 1, 500000, 'longstay');

-- ─── SEED: Rooms — Guest House VIIP ──────────────────────────
INSERT INTO rooms (room_number, room_name, room_type, property, capacity, price_per_night, status) VALUES
  ('VIP 01', 'VIP 01', 'longstay_room', 'viip', 4, 750000, 'available'),
  ('VIP 02', 'VIP 02', 'longstay_room', 'viip', 4, 750000, 'available'),
  ('VIP 03', 'VIP 03', 'longstay_room', 'viip', 4, 750000, 'available'),
  ('VIP 04', 'VIP 04', 'longstay_room', 'viip', 4, 750000, 'available'),
  ('VIP 05', 'VIP 05', 'longstay_room', 'viip', 4, 750000, 'available'),
  ('VIP 06', 'VIP 06', 'longstay_room', 'viip', 4, 750000, 'available');

-- ─── GRANT Permissions (PostgREST) ───────────────────────────
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
