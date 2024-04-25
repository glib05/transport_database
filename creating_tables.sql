create table district(
	district_id int generated always as identity primary key,
	name varchar(30) unique not null,
	area float,
	population int
);

create table type(
	type_id int generated always as identity primary key,
	name varchar(30) unique not null,
	fare float,
	description text
);

create table depot(
	depot_id int generated always as identity primary key,
	address text,
	coordinate_x decimal(9,7) not null,
	coordinate_y decimal(9,7) not null,
	creation_date date,
	type_id int not null,
	district_id int,
	foreign key (type_id) references type(type_id),
	foreign key (district_id) references district(district_id)
);

create table driver (
	driver_id int generated always as identity primary key,
	first_name varchar(30) not null,
	last_name varchar(30) not null,
	gender varchar(15),
	date_of_birth date,
	phone_number char(13),
	email varchar(40)
);

create table model(
	model_id int generated always as identity primary key,
	name varchar(20) unique not null,
	description text,
	creation_year int
);

create table transport(
	transport_id int generated always as identity primary key,
	capacity int,
	depot_id int not null,
	model_id int not null,
	foreign key (depot_id) references depot(depot_id),
	foreign key (model_id) references model(model_id)
);

create table route(
	route_id int generated always as identity primary key,
	name varchar(30),
	start_time time not null,
	end_time time not null,
	type_id int,
	foreign key (type_id) references type(type_id)
);

create table stop(
	stop_id int generated always as identity primary key,
	name varchar(50),
	status bool not null,
	address text,
	coordinate_x decimal(9,7) not null,
	coordinate_y decimal(9,7) not null,
	district_id int,
	foreign key (district_id) references district(district_id)
);

create table stop_info(
	stop_info_id int generated always as identity primary key,
	time timestamp not null,
	enter_people_q int,
	exit_people_q int,
	stop_id int not null,
	foreign key (stop_id) references stop(stop_id)
);

create table route_stop(
	route_stop_id int generated always as identity primary key,
	route_id int not null,
	stop_id int not null,
	foreign key (stop_id) references stop(stop_id),
	foreign key (route_id) references route(route_id)
);

create table destination(
	destination_id int generated always as identity primary key,
	route_id int not null,
	stop_id int not null,
	foreign key (stop_id) references stop(stop_id),
	foreign key (route_id) references route(route_id)
);

create table route_info(
	route_info_id int generated always as identity primary key,
	date date not null,
	route_id int not null,
	foreign key (route_id) references route(route_id)
);

create table  driver_transport(
	driver_transport_id int generated always as identity primary key,
	date date,
	driver_id int not null,
	transport_id int not null,
	foreign key (driver_id) references driver(driver_id),
	foreign key (transport_id) references transport(transport_id)
);

create table transport_route_info(
	transport_route_info_id int generated always as identity primary key,
	transport_id int not null,
	route_info_id int not null,
	foreign key (route_info_id) references route_info(route_info_id),
	foreign key (transport_id) references transport(transport_id)
); 

drop table transport_route_info;
drop table driver_transport;
drop table route_info;
drop table destination;
drop table route_stop;
drop table stop_info;
drop table stop;
drop table route;
drop table transport;
drop table model;
drop table driver;
drop table depot;
drop table type;
drop table district;