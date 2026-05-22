DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'enotime_app') THEN
    CREATE ROLE enotime_app LOGIN PASSWORD 'EnovateTime2025*';
  END IF;
END$$;

