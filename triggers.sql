-------------------------------------------------------------------------------
create or replace function stop_repeat_insert_into_route_stop_func() returns trigger as $$
begin
	if exists(select route_stop_id from route_stop rs
			 where rs.route_id = new.route_id and rs.stop_id = new.stop_id)
	then
		raise notice 'can`t insert ';
		return null;
	else
		return new;
	end if;
end;
$$ language plpgsql;

create trigger stop_repeat_insert
before insert on route_stop
for each row
execute procedure stop_repeat_insert_into_route_stop_func();

insert into route_stop(route_id, stop_id)
values
(5,7)
-----------------------------------------------------------
create or replace function cant_delete_update() returns trigger as $$
begin
	raise notice 'U can`t update or delete table %', tg_table_name;
	return null;
end;
$$ language plpgsql;

-- stops deleting from the district table
create trigger stop_delete
before delete on district
for each row
execute procedure cant_delete_update();

delete from district;

select * from district;

--stops changes to the model table
create trigger stop_update
before update on model
for each row
execute procedure cant_delete_update();

update model
set name = 'oooooooo' 
where name = 'Explorer Sport';

select * from model;

--displays information about inserted records in the stop_info table
create or replace function describe_trigger() returns trigger as $$
declare
	rec record;
	str text = '';
begin
	if tg_level = 'ROW' then 
		case tg_op
			when 'DELETE' then 
				rec = old;
				str = old::text;
			when 'UPDATE' then 
				rec = new;
				str = old||'->'||new;
			when 'INSERT' then
				rec = new;
				str = new::text;
		end case;
	end if;
	raise notice '% % % % %', tg_table_name, tg_when, tg_op, tg_level, str;
	return rec;
end;
$$ language plpgsql;

create trigger info_for_stop_info
before insert on stop_info
for each row
execute procedure describe_trigger();

call insert_data_into_stop_info(60, 20, 2);


-- a trigger that will prevent you from inserting more than two end stops for a single route
create or replace function no_more_then_two() returns trigger as $$
begin
	if (select count(*) from destination d
	   where d.route_id = new.route_id) = 2
	then
		raise notice 'no more than 2 end stop for each route';
		return null;
	else
		return new;
	end if;
end;
$$ language plpgsql;

create trigger no_more_then_two
before insert on destination
for each row
execute procedure no_more_then_two();

insert into destination(route_id, stop_id)
values 
(1,99);