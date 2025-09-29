-- Crear tabla para códigos de verificación de contraseña
CREATE TABLE IF NOT EXISTS password_reset_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL,
  code TEXT NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE password_reset_codes ENABLE ROW LEVEL SECURITY;

-- Política para permitir inserción y lectura
CREATE POLICY "Allow password reset code operations" ON password_reset_codes
  FOR ALL USING (true);

-- Crear función para limpiar códigos expirados
CREATE OR REPLACE FUNCTION cleanup_expired_codes()
RETURNS void AS $$
BEGIN
  DELETE FROM password_reset_codes 
  WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para limpiar códigos expirados automáticamente
CREATE OR REPLACE FUNCTION trigger_cleanup_expired_codes()
RETURNS trigger AS $$
BEGIN
  PERFORM cleanup_expired_codes();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cleanup_expired_codes_trigger
  AFTER INSERT ON password_reset_codes
  FOR EACH ROW
  EXECUTE FUNCTION trigger_cleanup_expired_codes();
