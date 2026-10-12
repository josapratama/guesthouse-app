-- ============================================================
-- Auth Functions — Login via PostgREST RPC
-- ============================================================

-- JWT signing key (harus sama dengan PGRST_JWT_SECRET di docker-compose)
CREATE EXTENSION IF NOT EXISTS pgjwt;

-- Function: login
-- Dipanggil via POST /rpc/login
-- Mengembalikan JWT token yang berisi user info
CREATE OR REPLACE FUNCTION login(email TEXT, password TEXT)
RETURNS JSON AS $$
DECLARE
  v_user users;
  v_token TEXT;
BEGIN
  SELECT * INTO v_user
  FROM users u
  WHERE u.email = login.email
    AND u.is_active = true;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Email atau password salah' USING ERRCODE = 'invalid_password';
  END IF;

  IF NOT (v_user.password = crypt(login.password, v_user.password)) THEN
    RAISE EXCEPTION 'Email atau password salah' USING ERRCODE = 'invalid_password';
  END IF;

  -- Generate JWT
  v_token := sign(
    json_build_object(
      'sub',   v_user.id::TEXT,
      'email', v_user.email,
      'name',  v_user.name,
      'role',  v_user.role::TEXT,
      'iat',   EXTRACT(EPOCH FROM NOW())::INTEGER,
      'exp',   EXTRACT(EPOCH FROM NOW() + INTERVAL '8 hours')::INTEGER
    )::JSON,
    'super-secret-jwt-token-guesthouse-2026'
  );

  RETURN json_build_object('token', v_token);

EXCEPTION
  WHEN invalid_password THEN
    RAISE EXCEPTION '%', SQLERRM USING HINT = 'invalid_credentials';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant akses ke anon role (diperlukan agar PostgREST bisa eksekusi tanpa token)
GRANT EXECUTE ON FUNCTION login(TEXT, TEXT) TO anon;

-- Function: get_reservations_report
-- Untuk fitur export laporan per periode
CREATE OR REPLACE FUNCTION get_reservations_report(
  start_date DATE,
  end_date DATE,
  p_property TEXT DEFAULT NULL
)
RETURNS TABLE (
  no              INTEGER,
  guest_name      TEXT,
  company_name    TEXT,
  room_number     TEXT,
  room_name       TEXT,
  check_in_date   DATE,
  check_out_date  DATE,
  total_days      INTEGER,
  occupied_room   INTEGER,
  status          TEXT,
  remark          TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    ROW_NUMBER() OVER (ORDER BY r.check_in_date, g.name)::INTEGER AS no,
    g.name::TEXT                    AS guest_name,
    COALESCE(c.name, '')::TEXT      AS company_name,
    rm.room_number::TEXT            AS room_number,
    COALESCE(rm.room_name, rm.room_number)::TEXT AS room_name,
    r.check_in_date,
    r.check_out_date,
    r.total_days,
    r.occupied_room,
    r.status::TEXT,
    COALESCE(r.remark, '')::TEXT    AS remark
  FROM reservations r
  JOIN guests g      ON g.id = r.guest_id
  JOIN rooms rm      ON rm.id = r.room_id
  LEFT JOIN companies c ON c.id = r.company_id
  WHERE r.check_in_date >= start_date
    AND r.check_in_date <= end_date
    AND (p_property IS NULL OR rm.property::TEXT = p_property)
  ORDER BY r.check_in_date, g.name;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION get_reservations_report(DATE, DATE, TEXT) TO authenticated;
