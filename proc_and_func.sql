create or replace function get_rush_hour(date date, out rush_hour int) as $$
	select EXTRACT(HOUR FROM time) as hour
	from stop_info
	where date(time) = date
	group by hour
	order by sum(enter_people_q+exit_people_q) desc
	limit 1;
$$ language sql;

create or replace procedure insert_data_into_stop_info(enter_people_q int,
													   exit_people_q int, 
													   stop_id int, 
													   info_time timestamp default current_timestamp) as $$
	insert into stop_info(enter_people_q, exit_people_q, stop_id, time)
	values
	(enter_people_q, exit_people_q, stop_id, info_time);
$$ language sql;

create or replace function get_route_len(route_id int) returns float as $$
declare
	coord1 record;
	coord2 record;
	cur cursor for (select coordinate_x x, coordinate_y y from stop
				 join route_stop r using(stop_id)
				 where r.route_id = $1
				 order by (coordinate_x+coordinate_y) desc);
	result float = 0;
begin
	open cur;
	
	fetch cur into coord1;
	fetch cur into coord2;
	
	loop
		result = result + sqrt((coord1.x-coord2.x)^2+(coord2.y-coord1.y)^2)*85;
		coord1 = coord2;
		fetch cur into coord2;
		exit when not found;
	end loop;
	
	close cur;
	
	return result;
end;
$$ language plpgsql;

create or replace function get_route_len(route_name varchar(30)) returns float as $$
declare
	coord1 record;
	coord2 record;
	cur cursor for (select coordinate_x x, coordinate_y y from stop
				 join route_stop rs using(stop_id)
				 join route r using(route_id)
				 where r.name = $1
				 order by (coordinate_x+coordinate_y) desc);
	result float = 0;
begin
	open cur;
	
	fetch cur into coord1;
	fetch cur into coord2;
	
	loop
		result = result + sqrt((coord1.x-coord2.x)^2+(coord2.y-coord1.y)^2)*85;
		coord1 = coord2;
		fetch cur into coord2;
		exit when not found;
	end loop;
	
	close cur;
	
	return result;
end;
$$ language plpgsql;

create or replace function is_route_circular(route_id int) returns bool as $$
begin
	if (select count(d.destination_id) from route r
		left join destination d using(route_id)
		where r.route_id = $1) = 0
	then
		return 'true';
	else
		return 'false';
	end if;
end;
$$ language plpgsql;

create or replace function get_stop_count_on_route(route_id int) returns int as $$
	select count(*) from route_stop rs where rs.route_id = $1;
$$ language sql;

-- SELECT r.route_id, rs.stop_id, s.name, COUNT(si.enter_people_q) AS enter_count, COUNT(si.exit_people_q) AS exit_count
-- FROM route r
-- JOIN route_stop rs ON r.route_id = rs.route_id
-- JOIN stop s ON rs.stop_id = s.stop_id
-- LEFT JOIN stop_info si ON rs.stop_id = si.stop_id
-- WHERE r.route_id IN (SELECT route_id FROM route_info WHERE date BETWEEN start_time AND )
-- GROUP BY r.route_id, rs.stop_id, s.name;

create or replace function get_avg_passenger_on_route(route_id int) returns float as $$
	select avg(si.enter_people_q) from stop_info si
	join route_stop rs using(stop_id)
	where rs.route_id = $1;
$$ language sql;

create or replace function count_income(date date, route_id int) returns float as $$
<<l1>>
declare 
	fare float;
	result float;
begin
	select t.fare
	into l1.fare
	from type t
	where type_id = (select type_id from route r
					where r.route_id = $2);

	select sum(enter_people_q)*fare
	into result
	from stop_info si
	join route_stop rs using(stop_id)
	join route r using(route_id)
	where r.route_id = $2 and date(time) = $1;
	
	return result;
end;
$$ language plpgsql;

create or replace function count_income(date date, out result float) as $$
begin
	select sum(count_income($1, route_id))
	into result
	from route;
end;
$$ language plpgsql;
-------------------------------------------------------

create or replace function get_worst_route(out worst_route record, out income float) as $$
declare
	dates date;
	routes record;
	inc float;
begin
	income = 2000000000;
	for routes in(select * from route) loop
		inc = 0;
		for dates in (select distinct(date(time)) from stop_info) loop
			inc = inc + count_income(dates, routes.route_id);
		end loop;
		if inc < income then
			income = inc;
			worst_route = routes;
		end if;
	end loop;
end;
$$ language plpgsql;

select get_rush_hour('2023-12-30');

call insert_data_into_stop_info(20, 15, 99);
select * from stop_info
where stop_id = 99;

select get_route_len(99);

select get_route_len('Салтівська лінія');

select is_route_circular(1);
select is_route_circular(10);

select get_stop_count_on_route(75);

select get_avg_passenger_on_route(112);

select count_income('2023-12-30', 657)

select count_income('2023-12-31')

select * from get_worst_route();
