-- Limpiar tablas previas
DROP TABLE IF EXISTS jugadores;
DROP TABLE IF EXISTS equipos;

-- Crear tablas
CREATE TABLE equipos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    ciudad VARCHAR(100)
);

CREATE TABLE jugadores (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    posicion VARCHAR(50),
    goles INT,
    equipo_id INT
);

-- Insertar datos
INSERT INTO equipos (nombre, ciudad) VALUES
('Deportes Concepción', 'Concepción'),
('Colo-Colo', 'Santiago'),
('Real Madrid', 'Madrid'),
('Equipo Fantasma FC', 'Sin Ciudad');

INSERT INTO jugadores (nombre, posicion, goles, equipo_id) VALUES
('Joaquín Larrivey', 'Delantero', 15, 1),
('Gabriel Vargas', 'Delantero', 10, 1),
('Brayan Cortés', 'Arquero', 0, 2),
('Arturo Vidal', 'Mediocampista', 7, 2),
('Carlos Palacios', 'Delantero', 12, 2),
('Kylian Mbappé', 'Delantero', 22, 3),
('Jude Bellingham', 'Mediocampista', 14, 3);

-- Consulta de goles totales por equipo
SELECT equipos.nombre, SUM(jugadores.goles) AS total_goles
FROM equipos
INNER JOIN jugadores ON equipos.id = jugadores.equipo_id
GROUP BY equipos.nombre
ORDER BY total_goles DESC;
