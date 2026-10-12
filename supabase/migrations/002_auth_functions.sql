-- ============================================================
-- Auth Functions — Login via PostgREST RPC
-- JWT dibuat di sisi Flutter, bukan PostgreSQL
-- (menghindari dependency pgjwt yang tidak tersedia di Alpine)
-- ============================================================

-- Function: login
-- Dipanggil via POST /rpc/login
-- Verifikasi email + password, return user data
-- Flutter kemudian membuat JWT lokal dari data ini
CREATE OR REPLACE FUNCTION login(email TEXT, password TEXT)
RETURNS JSON AS $$
DECLARE
  v_user users;
BEGIN
  SELECT * INTO v_user
  FROM users u
  WHERE u.email = login.email
    AND u.is_active = true;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Email atau password salah'
      USING ERRCODE = 'P0001';
  END IF;

  IF NOT (v_user.password = crypt(login.password, v_user.password)) THEN
    RAISE EXCEPTION 'Email atau password salah'
      USING ERRCODE = 'P0001';
  END IF;

  -- Return user data (JWT dibuat di Flutter)
  RETURN json_build_object(
    'id',    v_user.id::TEXT,
    'name',  v_user.name,
    'email', v_user.email,
    'role',  v_user.role::TEXT
  );

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant akses ke anon role
GRANT EXECUTE ON FUNCTION login(TEXT, TEXT) TO anon;

-- Function: get_reservations_report
CREATE OR REPLACE FUNCTION get_reservations_report(
  start_date DATE,
  end_date   DATE,
  p_property TEXT DEFAULT NULL
)
RETURNS TABLE (
  no             INTEGER,
  guest_name     TEXT,
  company_name   TEXT,
  room_number    TEXT,
  room_name      TEXT,
  check_in_date  DATE,
  check_out_date DATE,
  total_days     INTEGER,
  occupied_room  INTEGER,
  status         TEXT,
  remark         TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    ROW_NUMBER() OVER (ORDER BY r.check_in_date, g.name)::INTEGER,
    g.name::TEXT,
    COALESCE(c.name, '')::TEXT,
    rm.room_number::TEXT,
    COALESCE(rm.room_name, rm.room_number)::TEXT,
    r.check_in_date,
    r.check_out_date,
    r.total_days,
    r.occupied_room,
    r.status::TEXT,
    COALESCE(r.remark, '')::TEXT
  FROM reservations r
  JOIN guests g      ON g.id = r.guest_id
  JOIN rooms  rm     ON rm.id = r.room_id
  LEFT JOIN companies c ON c.id = r.company_id
  WHERE r.check_in_date >= start_date
    AND r.check_in_date <= end_date
    AND (p_property IS NULL OR rm.property::TEXT = p_property)
  ORDER BY r.check_in_date, g.name;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION get_reservations_report(DATE, DATE, TEXT) TO authenticated;
