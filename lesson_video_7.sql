use shop;
-- Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
-- мои все с заказами, так что будем делать выборку от 5 заказов

select user_id, user_name, total_orders from(
select u.id as user_id, u.name as user_name, count(*) as total_orders
from users u
join orders o
	on u.id = o.buyer
group by u.id) as orders_count
where total_orders > 4
; 

-- Выведите список товаров products и разделов catalogs, который соответствует товару.
select p.id product_id, p.name product_name, c.id catalogue_id, c.name catalogue_name
from products p
join catalogs c 
	on p.catalog_id = c.id
order by p.id; 

-- (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). 
-- Поля from, to и label содержат английские названия городов, поле name — русское. 
-- Выведите список рейсов flights с русскими названиями городов.
create database aero;
use aero;

create table flights(
	id serial primary key,
	`from` varchar(50),
	`to` varchar(50)
)

create table cities(
	label varchar(50),
	name varchar(50)
)
insert into flights values
('1', 'moscow', 'spb'),
('2', 'omsk', 'tomsk'),
('3', 'moscow', 'tomsk'),
('4', 'spb', 'omsk'),
('5', 'tomsk', 'novgorod');

insert into cities values
('moscow', 'москва'),
('omsk', 'омск'),
('tomsk', 'томск'),
('spb', 'спб'),
('novgorod', 'новгород');

select id, from_city, name as to_city from 
(select id, name as from_city, `to`
from flights
join cities on 
`from` = cities.label 
group by id) as from_tbl
join cities on 
`to` = cities.label 
order by id;


