-- all stops and their districts
CREATE OR REPLACE VIEW StopDistrictInfo AS
SELECT s.stop_id, s.name AS stop_name, s.status, s.address, s.coordinate_x, s.coordinate_y, d.name AS district_name
FROM stop s
JOIN district d ON s.district_id = d.district_id;



--statistics of entry and exit at stops
CREATE OR REPLACE VIEW StopStatistics AS
SELECT
    s.stop_id,
    s.name AS stop_name,
    COUNT(si.stop_info_id) AS total_entries,
    SUM(si.enter_people_q) AS total_entered,
    SUM(si.exit_people_q) AS total_exited
FROM stop s
LEFT JOIN stop_info si ON s.stop_id = si.stop_id
GROUP BY s.stop_id;

--drivers and the transport they drive
CREATE OR REPLACE VIEW DriverTransportInfo AS
SELECT dt.driver_transport_id, d.first_name, d.last_name, d.gender, d.date_of_birth, d.phone_number, d.email, t.transport_id
FROM driver_transport dt
JOIN driver d ON dt.driver_id = d.driver_id
JOIN transport t ON dt.transport_id = t.transport_id;


select * from DriverTransportInfo;

select * from StopDistrictInfo;

select * from StopStatistics;