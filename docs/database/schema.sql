-- 1. Кестелерді құру (ERD-мен сәйкес, 3NF)
CREATE TABLE districts (
    district_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    area_km2 DECIMAL(6,2) NOT NULL
);

CREATE TABLE road_segments (
    segment_id SERIAL PRIMARY KEY,
    district_id INT NOT NULL REFERENCES districts(district_id),
    street_name VARCHAR(150) NOT NULL,
    speed_limit INT NOT NULL
);

CREATE TABLE weather_records (
    weather_id SERIAL PRIMARY KEY,
    district_id INT NOT NULL REFERENCES districts(district_id),
    observed_at TIMESTAMP NOT NULL,
    temperature_c DECIMAL(4,1) NOT NULL,
    condition VARCHAR(50) NOT NULL
);

CREATE TABLE accidents (
    accident_id SERIAL PRIMARY KEY,
    segment_id INT NOT NULL REFERENCES road_segments(segment_id),
    weather_id INT NOT NULL REFERENCES weather_records(weather_id),
    occurred_at TIMESTAMP NOT NULL,
    severity VARCHAR(30) NOT NULL
);

CREATE TABLE predictions (
    prediction_id SERIAL PRIMARY KEY,
    segment_id INT NOT NULL REFERENCES road_segments(segment_id),
    target_time TIMESTAMP NOT NULL,
    risk_level VARCHAR(20) NOT NULL,
    color_code VARCHAR(20) NOT NULL,
    alert_message VARCHAR(255)
);

CREATE TABLE prediction_factors (
    prediction_id INT NOT NULL REFERENCES predictions(prediction_id),
    weather_id INT NOT NULL REFERENCES weather_records(weather_id),
    impact_weight DECIMAL(3,2) NOT NULL,
    PRIMARY KEY (prediction_id, weather_id)
);

-- 2. Тестілік деректер (әр кестеге 4 жазба)
INSERT INTO districts (name, area_km2) VALUES
('Медеу ауданы', 253.40),
('Бостандық ауданы', 99.43),
('Алмалы ауданы', 18.20),
('Әуезов ауданы', 23.50);

INSERT INTO road_segments (district_id, street_name, speed_limit) VALUES
(1, 'Әл-Фараби даңғылы (Достық қиылысы)', 80),
(2, 'Сәтбаев көшесі (Розыбакиев қиылысы)', 60),
(3, 'Төле би көшесі (Абылай хан қиылысы)', 60),
(4, 'Абай даңғылы (Алтынсарин қиылысы)', 60);

INSERT INTO weather_records (district_id, observed_at, temperature_c, condition) VALUES
(1, '2026-11-24 08:30:00', -4.5, 'Көктайғақ'),
(2, '2026-11-24 09:00:00', -2.0, 'Қар'),
(3, '2026-11-24 14:00:00', 1.5, 'Жаңбыр'),
(4, '2026-11-24 18:30:00', -5.0, 'Тұман');

INSERT INTO accidents (segment_id, weather_id, occurred_at, severity) VALUES
(1, 1, '2026-11-20 08:45:00', 'Жоғары'),
(1, 1, '2026-11-21 09:10:00', 'Орташа'),
(2, 2, '2026-11-22 18:20:00', 'Орташа'),
(4, 4, '2026-11-23 19:05:00', 'Жоғары');

INSERT INTO predictions (segment_id, target_time, risk_level, color_code, alert_message) VALUES
(1, '2026-11-25 08:30:00', 'Жоғары', 'Қызыл', 'Ескерту: Әл-Фараби даңғылында көктайғаққа байланысты апат қаупі жоғары!'),
(2, '2026-11-25 09:00:00', 'Орташа', 'Сары', 'Жылдамдықты 50 км/сағ дейін төмендету ұсынылады.'),
(3, '2026-11-25 14:00:00', 'Төмен', 'Жасыл', 'Қозғалыс қалыпты.'),
(4, '2026-11-25 18:30:00', 'Жоғары', 'Қызыл', 'Ескерту: Тұман және кептеліс, абай болыңыз!');

INSERT INTO prediction_factors (prediction_id, weather_id, impact_weight) VALUES
(1, 1, 0.85),
(2, 2, 0.60),
(3, 3, 0.25),
(4, 4, 0.80);

-- 3. Сұраныс №1: 4 кестені JOIN арқылы біріктіру
SELECT
    d.name AS district_name,
    rs.street_name,
    w.condition AS weather_condition,
    a.occurred_at,
    a.severity
FROM accidents a
JOIN road_segments rs ON a.segment_id = rs.segment_id
JOIN districts d ON rs.district_id = d.district_id
JOIN weather_records w ON a.weather_id = w.weather_id
ORDER BY a.occurred_at DESC;

-- 4. Сұраныс №2: GROUP BY арқылы әр аудан бойынша апаттар санын есептеу
SELECT
    d.name AS district_name,
    COUNT(a.accident_id) AS total_accidents
FROM districts d
LEFT JOIN road_segments rs ON d.district_id = rs.district_id
LEFT JOIN accidents a ON rs.segment_id = a.segment_id
GROUP BY d.name
ORDER BY total_accidents DESC;