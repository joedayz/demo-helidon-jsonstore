-- Initialization script for Oracle Database 23c Free
-- This script runs automatically when starting the container

-- Wait for database to be completely ready
DECLARE
  v_status VARCHAR2(20);
BEGIN
  LOOP
    SELECT status INTO v_status FROM v$instance;
    EXIT WHEN v_status = 'OPEN';
    DBMS_LOCK.SLEEP(5);
  END LOOP;
END;
/

-- Create user for Helidon application
CREATE USER C##helidon_user IDENTIFIED BY helidon123;

-- Grant basic necessary privileges
GRANT CONNECT, RESOURCE TO C##helidon_user;
GRANT CREATE SESSION TO C##helidon_user;
GRANT CREATE TABLE TO C##helidon_user;
GRANT CREATE SEQUENCE TO C##helidon_user;
GRANT CREATE VIEW TO C##helidon_user;
GRANT UNLIMITED TABLESPACE TO C##helidon_user;

-- Otorgar privilegios para JSON (Oracle 23c)
GRANT EXECUTE ON DBMS_JSON TO C##helidon_user;

-- Create a dedicated tablespace for the application
CREATE TABLESPACE helidon_data
DATAFILE 'helidon_data.dbf' SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE 500M;

-- Asignar tablespace por defecto al usuario
ALTER USER C##helidon_user DEFAULT TABLESPACE helidon_data;

-- Crear un esquema de ejemplo (opcional)
CREATE TABLE C##helidon_user.welcome_message (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    message VARCHAR2(200),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO C##helidon_user.welcome_message (message) 
VALUES ('Oracle Database 23c Free inicializado correctamente para Helidon JSON Store');

COMMIT;

-- Show confirmation
SELECT 'Usuario C##helidon_user creado exitosamente' AS status FROM dual;
SELECT username, account_status, default_tablespace 
FROM dba_users 
WHERE username = 'C##HELIDON_USER';
