/*1. List all vehicles with their model, year, and engine type*/
SELECT vehicle_id, model, year, engine_type
FROM vehicle_info;

/*2. Average engine temperature for each vehicle*/
SELECT vehicle_id, ROUND(AVG(engine_temp), 2) AS avg_engine_temp
FROM sensor_readings
GROUP BY vehicle_id;

/*3. Vehicles with engine temperature above 110°C*/
SELECT vehicle_id, timestamp, engine_temp
FROM sensor_readings
WHERE engine_temp > 110;

/*4. Count of maintenance visits per vehicle*/
SELECT vehicle_id, COUNT(*) AS total_services
FROM maintenance_logs
GROUP BY vehicle_id;

/*5. Most common alert types*/
SELECT alert_type, COUNT(*) AS occurrences
FROM alerts
GROUP BY alert_type
ORDER BY occurrences DESC;

/*6. High severity unresolved alerts*/
SELECT *
FROM alerts
WHERE severity = 'High' AND resolved = 'No';

/*List breakdowns along with model and component failed*/
SELECT b.breakdown_date, b.vehicle_id, v.model, b.component_failed
FROM breakdowns b
JOIN vehicle_info v ON b.vehicle_id = v.vehicle_id;

/*8. Time between each service (in days) for each vehicle*/
INSERT INTO maintenance_logs (log_id, vehicle_id, service_date, service_type, cost, service_center) VALUES
('M003', 'V001', '2024-06-10', 'Brake Check', 3000, 'Benz Hub - Pune'),
('M004', 'V003', '2024-06-15', 'Oil Change', 4500, 'Benz Auto Delhi');

SELECT vehicle_id,
       service_date,
       LEAD(service_date) OVER (PARTITION BY vehicle_id ORDER BY service_date) AS next_service_date,
       DATEDIFF(LEAD(service_date) OVER (PARTITION BY vehicle_id ORDER BY service_date), service_date) AS days_between_services
FROM maintenance_logs;

/*9. Average brake wear level by model*/
SELECT v.model, ROUND(AVG(s.brake_wear), 2) AS avg_brake_wear
FROM sensor_readings s
JOIN vehicle_info v ON s.vehicle_id = v.vehicle_id
GROUP BY v.model;

/*10. Total maintenance cost per vehicle*/
SELECT vehicle_id, SUM(cost) AS total_maintenance_cost
FROM maintenance_logs
GROUP BY vehicle_id;

/*11. Vehicles with more than 2 alerts in the last 7 days*/
SELECT vehicle_id, COUNT(*) AS alert_count
FROM alerts
WHERE timestamp >= CURDATE() - INTERVAL 7 DAY
GROUP BY vehicle_id
HAVING alert_count > 2;

/*12. List vehicles that have never broken down*/
SELECT vehicle_id
FROM vehicle_info
WHERE vehicle_id NOT IN (SELECT DISTINCT vehicle_id FROM breakdowns);

/*13. Find the earliest maintenance date for each vehicle*/
SELECT vehicle_id, MIN(service_date) AS first_service_date
FROM maintenance_logs
GROUP BY vehicle_id;

/* 14. Average oil temperature before each breakdown*/
SELECT b.vehicle_id, ROUND(AVG(s.oil_temp), 2) AS avg_oil_temp
FROM breakdowns b
JOIN sensor_readings s ON b.vehicle_id = s.vehicle_id
WHERE s.timestamp < b.breakdown_date
GROUP BY b.vehicle_id;

/*Identify patterns: Are high brake wear values causing breakdowns?*/
SELECT s.vehicle_id, MAX(s.brake_wear) AS max_brake_wear, COUNT(b.breakdown_id) AS breakdowns
FROM sensor_readings s
LEFT JOIN breakdowns b ON s.vehicle_id = b.vehicle_id
GROUP BY s.vehicle_id
ORDER BY max_brake_wear DESC;