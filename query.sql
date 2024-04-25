-- select all ring routes
select route_id, r.name, r.type_id from route r
left join destination d using(route_id)
group by route_id, r.name, r.type_id
having count(d.destination_id) = 0

-- to derive the ratio of the number of public transport stops to the population of the city districts
select district.name, count(stop_id) stops, population, (cast(count(stop_id) as float)/population) rel from stop s
join district using(district_id)
group by population, district.name
order by rel;

--Get all routes that have stops in all areas
select r.*
from route r
where not exists (
    select d.district_id
    from district d
    where d.district_id not in (
        select s.district_id
        from route_stop rs
        join stop s on rs.stop_id = s.stop_id
        where rs.route_id = r.route_id
    )
);

-- withdraw the depot according to the decrease in the number of transport in them
select depot_id, type_id, count(transport_id) transport_count from depot
join transport using(depot_id)
group by depot_id, type_id
order by transport_count desc;

-- display the types of transport most often driven by drivers
select driver_id, first_name, last_name, name from driver
join driver_transport using(driver_id)
join transport using(transport_id)
join depot using(depot_id)
join type using(type_id)
---------------------------------------------------------------
-- display closed stops that belong to several routes
select stop_id, name, status, count(route_id) from stop s
join route_stop using(stop_id)
where status = 'false'
group by stop_id, name, status
having count(route_id) > 1;

--count the number of depots for each district
select district_id, d.name, d.area, d.population, count(depot_id) count_depot from district d
join depot using(district_id)
group by district_id, d.name, d.area, d.population;

--print the transport that was on the routes
select route_id, transport_id, date from route
join route_info using(route_id)
join transport_route_info using(route_info_id);

-- Find the most popular type of transport in the last month
SELECT d.type_id, COUNT(t.transport_id) AS total_transport
FROM transport t
JOIN transport_route_info tri ON t.transport_id = tri.transport_id
join route_info ri using(route_info_id)
join depot d using(depot_id)
WHERE ri.date >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY d.type_id
ORDER BY total_transport DESC
LIMIT 1;

--Get the average number of passengers for each stop for a given day:
SELECT si.stop_id, AVG(si.enter_people_q) AS avg_entered, AVG(si.exit_people_q) AS avg_exited
FROM stop_info si
WHERE DATE(si.time) = '2023-12-31'
GROUP BY si.stop_id;

--Get a list of stops at which the number of passengers leaving is higher than average
SELECT s.*, AVG(si.exit_people_q) AS avg_exited
FROM stop s
JOIN stop_info si ON s.stop_id = si.stop_id
GROUP BY s.stop_id
HAVING AVG(si.exit_people_q) > (select avg(exit_people_q) from stop_info)
order by avg_exited desc;

--Find drivers who have not worked in the last month
SELECT d.*
FROM driver d
WHERE NOT EXISTS (
    SELECT dt.driver_transport_id
    FROM driver_transport dt
    WHERE dt.driver_id = d.driver_id AND dt.date >= CURRENT_DATE - INTERVAL '1 month'
);

-- Get the two most popular routes
SELECT r.route_id, r.name, COUNT(tri.transport_id) AS total_trips
FROM route r
join route_info using(route_id)
LEFT JOIN transport_route_info tri using(route_info_id)
GROUP BY r.route_id, r.name
ORDER BY total_trips DESC
LIMIT 2;

--------------------------------------------------------

--Get a list of transport that does not run on the routes
SELECT t.*
FROM transport t
LEFT JOIN transport_route_info tri ON t.transport_id = tri.transport_id
WHERE tri.transport_id IS NULL;

--find the times at which the stops operate
select stop_id, s.name, min(start_time), max(end_time) from stop s
join route_stop using(stop_id)
join route using(route_id)
group by stop_id, s.name;

--Get the average age of drivers for each type of transport
SELECT type.name, AVG(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM d.date_of_birth)) AS avg_age
FROM transport t
join depot de using(depot_id)
join type using(type_id)
JOIN driver_transport dt ON t.transport_id = dt.transport_id
JOIN driver d ON dt.driver_id = d.driver_id
GROUP BY type.name;

-- output the number of non-working stops for each district
SELECT d.name, count(stop_id) unworking_count
FROM district d
JOIN stop s ON d.district_id = s.district_id
WHERE s.status = FALSE
group by d.name
order by unworking_count;

--display the type of each route
select r.route_id, r.name, t.name from route r
join type t using(type_id);

--count the number of vehicles by type
select type.name, count(transport_id) from type
join depot using(type_id)
join transport using(depot_id)
group by type.name;

-- get stops sorted by passenger flow
select stop_id, name, avg(exit_people_q+ enter_people_q) pass_count from stop
join stop_info using(stop_id)
group by stop_id, name
order by pass_count desc;