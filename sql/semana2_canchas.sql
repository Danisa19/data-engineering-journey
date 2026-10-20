-- ==========================================
-- 1. LIMPIEZA Y CREACIÓN DE TABLAS (DDL)
-- ==========================================
DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS canchas;

CREATE TABLE canchas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    precio_hora INT NOT NULL CHECK (precio_hora > 0)
);

CREATE TABLE reservas (
    id SERIAL PRIMARY KEY,
    cliente VARCHAR(100) NOT NULL,
    horas INT NOT NULL CHECK (horas >= 1 AND horas <= 5),
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    cancha_id INT NOT NULL REFERENCES canchas(id)
);

-- ==========================================
-- 2. CARGA DE DATOS (DML)
-- ==========================================
INSERT INTO canchas (nombre, precio_hora) VALUES
('Cancha 1 Fraternidad', 25000),
('Cancha 2 techada', 30000),
('Cancha 3 rosario', 20000);

INSERT INTO reservas (cliente, horas, fecha, cancha_id) VALUES
('Daniel Figueroa', 2, '2026-10-15', 1),
('Fernanda Pedrero', 1, '2026-10-16', 2),
('Cosme Fulanito', 2, '2026-10-18', 1),
('Juan Perez', 3, '2026-10-19', 2);

-- ==========================================
-- 3. REPORTES ANALÍTICOS (QUERIES)
-- ==========================================

-- Reporte 1: Recaudación histórica total por cancha (Día 1)
SELECT 
    canchas.nombre, 
    COALESCE(SUM(reservas.horas * canchas.precio_hora), 0) AS recaudacion_total
FROM canchas
LEFT JOIN reservas ON canchas.id = reservas.cancha_id
GROUP BY canchas.nombre
ORDER BY recaudacion_total DESC;

-- Reporte 2: Canchas con recaudación > $60.000 desde el 16 de oct (WHERE + HAVING)
SELECT 
    canchas.nombre,
    COALESCE(SUM(canchas.precio_hora * reservas.horas), 0) AS recaudacion_total
FROM canchas
LEFT JOIN reservas ON reservas.cancha_id = canchas.id
WHERE reservas.fecha >= '2026-10-16'
GROUP BY canchas.nombre
HAVING SUM(canchas.precio_hora * reservas.horas) > 60000;

-- Reporte 3: Todas las canchas (incluyendo $0) filtrando fecha dentro del ON
SELECT 
    canchas.nombre,
    COALESCE(SUM(canchas.precio_hora * reservas.horas), 0) AS recaudacion_total
FROM canchas
LEFT JOIN reservas ON reservas.cancha_id = canchas.id AND reservas.fecha >= '2026-10-16'
GROUP BY canchas.nombre
ORDER BY recaudacion_total DESC;
