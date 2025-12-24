-- LPI Production Database Initialization
CREATE TABLE IF NOT EXISTS menu_prod (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(255) NOT NULL,
    link TEXT,
    banner TEXT,
    icon TEXT,
    category VARCHAR(50) DEFAULT 'production'
);

INSERT INTO menu_prod (nama, link, banner, category) VALUES
('QLA Monitoring System', 'https://script.google.com/a/macros/abata.sch.id/s/AKfycbwDB6v2DsGrO0nEEwxyBPSUCRgIF2sr1VNVLbB3Wsgl6VrHAkqyH4qZfNAypfirRHor9g/exec', 'https://i.imgur.com/Oq7RoIb.jpeg', 'transport'),
('Lunch Management', 'https://script.google.com/a/macros/abata.sch.id/s/AKfycbztcbsItJKdgnxihqZKVgdYd_F-wdMhqucro8Nw_kcDRcthmlz70b90zGknvdOJzkPW/exec', 'https://i.imgur.com/tJXF5xq.jpeg', 'facility'),
('PMB Monitoring System', 'https://script.google.com/a/macros/abata.sch.id/s/AKfycbzbwMrImXypExAnKH8jOri-MOOfO4QIWkwOOqnXHjrXXoEw-Gm7XJohBtYR7TkY21C-/exec', 'https://i.imgur.com/dG3DAcK.jpeg', 'service');

SELECT '✅ Production database initialized successfully' as status;
