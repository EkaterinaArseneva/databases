-- Практическое задание по теме “Транзакции, переменные, представления
-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

 
start transaction; 
insert into sampledtb.products
	select * from shop.products where id = 1;
commit;

--  не могу удалить из shop т.к. связи

-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products 
-- и соответствующее название каталога name из таблицы catalogs.

create view prod_cat as 
select p.name as product_name, c.name as catalogue_name from shop.products p
join shop.catalogs c
on p.catalog_id = c.id
order by p.id;

select * from prod_cat; 

-- 3. по желанию) Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года 
-- '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
-- Составьте запрос, который выводит полный список дат за август, 
-- выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует. 
-- создаем таблицу с нашими данными
create table august_dates (
	created_at datetime);
insert into august_dates values
('2018-08-01'), ('2016-08-04'), ('2018-08-16'), ('2018-08-17');

-- создаем таблицу с датами августа 2018
create table august_total (
	`date` datetime); 

INSERT INTO august_total
 (`date`)
SELECT '2018-08-01' + INTERVAL (id - 1) DAY
FROM products 
WHERE id BETWEEN 1 AND 31;

-- делаем запрос.
select `date`, case 
	when `date` in (select created_at from august_dates) then 1 else 0 end as date_check
from august_total;

-- Практическое задание по теме “Хранимые процедуры и функции, триггеры"

-- 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, 
-- в зависимости от текущего времени суток. С 6:00 до 12:00 
-- функция должна возвращать фразу "Доброе утро", 
-- с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", 
-- с 00:00 до 6:00 — "Доброй ночи".

create function hello ()
returns varchar(255) deterministic
begin
	declare hours tinyint;
	set hours = EXTRACT(HOUR FROM now());
	if (hours between 6 and 11) then
		return "доброе утро!";
	elseif (hours between 12 and 17) then
		return "добрый день!";
	elseif (hours between 18 and 23) then 
		return "добрый вечер";
	else return "доброй ночи";
	end if;
end;

select shop.hello();


-- 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
-- Допустимо присутствие обоих полей или одно из них. 
-- Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.


-- делаем то же самое только с name и price
drop trigger if exists fill_check;
CREATE TRIGGER fill_check before insert on products
for each row 
begin
  IF (new.name is null and new.price is null) THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'one of name and desciption must be not null';
  END IF;
end;
-- триггер на insert добавился

insert into shop.products (name, catalog_id, price) values
(null, 1, null);
-- проверка работает

drop trigger if exists update_check;
CREATE TRIGGER update_check before update on products
for each row 
begin
  IF ((new.name is null and old.price is null) 
  	or (old.name is null and new.price is null)
  	or (new.name is null and new.price is null))
  THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'one of name and desciption must be not null';
  END IF;
end;
-- триггер на update добавился

update products set price = null where name is null;
-- проверка работает