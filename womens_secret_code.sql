CREATE DATABASE IF NOT EXISTS WS;
USE WS;

-- -----------------------------------------------------
-- Table WS.categories - we keep categoies and subcatefories together since data is small
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.categories;

CREATE TABLE IF NOT EXISTS WS.categories (
  id CHAR(5) primary key,
  category_name VARCHAR(45) NOT NULL,
  parent_category_id CHAR(2) NOT NULL,
  parent_category_name VARCHAR(45) NULL,
  INDEX subfamily (category_name),
  INDEX parent_category_id (parent_category_id),
  INDEX family (parent_category_name)
);

-- -----------------------------------------------------
-- Table WS.colors. we define colors by subcategory and numeric size so as they correspond to specific cloths
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.colors;

CREATE TABLE IF NOT EXISTS WS.colors (
  id INT unsigned primary key,
  color_name VARCHAR(45) NOT NULL,
  INDEX color (color_name) 
);


-- -----------------------------------------------------
-- Table WS.products. Product is an option = model + color (see primary key). Sizes will be specified in EAns.
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.products ;

CREATE TABLE IF NOT EXISTS WS.products (
  model BIGINT UNSIGNED NOT NULL,
  model_description VARCHAR(255) NOT NULL,
  produced_in VARCHAR(45) NOT NULL,
  composition VARCHAR(45) NOT NULL,
  subfamily_id CHAR(5) NOT NULL,
  family_id CHAR(2) NOT NULL,
  color_id INT UNSIGNED NOT NULL,
  collection_name varchar(45),
  uploaded_at DATETIME default now(),
  original_price INT UNSIGNED NOT NULL,
  PRIMARY KEY `option` (model, color_id),
  INDEX model (model),
  INDEX model_description (model_description),
  FOREIGN KEY (subfamily_id) REFERENCES WS.categories (id),
  FOREIGN KEY (color_id) REFERENCES WS.colors (id),
);
 

-- -----------------------------------------------------
-- Table WS.accounts
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.accounts ;

CREATE TABLE IF NOT EXISTS WS.accounts (
  email VARCHAR(255) PRIMARY key NOT NULL,
  `password` CHAR(10) NOT NULL
);


-- -----------------------------------------------------
-- Table WS.users
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.users ;

CREATE TABLE IF NOT EXISTS WS.users (
  id SERIAL primary KEY,
  name VARCHAR(255) NOT NULL,
  surname VARCHAR(255) NOT NULL,
  gender ENUM('m', 'f') NOT NULL,
  birthday DATETIME NOT NULL,
  email VARCHAR(255) NOT NULL,
  INDEX user_name (name),
  INDEX user_surname (surname),
  INDEX name_surname (name, surname),
  FOREIGN KEY (email) REFERENCES WS.accounts (email)
);


-- -----------------------------------------------------
-- Table WS.payments
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.payments ;

CREATE TABLE IF NOT EXISTS WS.payments (
  id SERIAL primary key,
  status ENUM('paid', 'not paid') NOT NULL,
  paid_at DATETIME
);

-- -----------------------------------------------------
-- Table WS.deliveries
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.deliveries ;

CREATE TABLE IF NOT EXISTS WS.deliveries (
  id SERIAL primary key,
  address VARCHAR(255) NOT NULL,
  contact_phone BIGINT UNSIGNED NOT NULL,
  status VARCHAR(45),
  sent_at DATETIME,
  delivered_at DATETIME
 );


-- -----------------------------------------------------
-- Table WS.orders
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.orders ;

CREATE TABLE IF NOT EXISTS WS.orders (
  id SERIAL primary KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL,
  paiment_id BIGINT UNSIGNED,
  delivery_id BIGINT UNSIGNED,
  FOREIGN KEY (user_id) REFERENCES WS.users (id),
  FOREIGN KEY (paiment_id) REFERENCES WS.payments (id),
  FOREIGN KEY (delivery_id) REFERENCES WS.deliveries (id)
  );


-- -----------------------------------------------------
-- Table WS.product_discount
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.product_discount ;

CREATE TABLE IF NOT EXISTS WS.product_discount (
  id INT UNSIGNED NOT NULL auto_increment PRIMARY key,
  model_id BIGINT UNSIGNED NOT NULL,
  discount FLOAT unsigned not NULL,
  start_date DATETIME,
  end_date DATETIME,
  FOREIGN KEY (model_id) REFERENCES WS.products (model)
 );


-- -----------------------------------------------------
-- Table WS.sizes
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.sizes ;

CREATE TABLE IF NOT EXISTS WS.sizes (
  id INT UNSIGNED NOT NULL auto_increment PRIMARY key,
  subcategory_id INT UNSIGNED not NULL,
  numeric_size INT UNSIGNED NOT null,
  `size` VARCHAR(45) NOT null,
  index `size` (`size`),
  index numeric_size (numeric_size)
);


-- -----------------------------------------------------
-- Table WS.EANs
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.EANs ;

CREATE TABLE IF NOT EXISTS WS.EANs (
  EAN BIGINT UNSIGNED not null primary key,
  model BIGINT UNSIGNED NOT NULL,
  color_id INT UNSIGNED NOT NULL,
  num_size INT UNSIGNED NOT NULL,
  FOREIGN KEY (model) REFERENCES WS.products (model),
  FOREIGN KEY (num_size) REFERENCES WS.sizes (numeric_size),
  FOREIGN KEY (color_id) REFERENCES WS.colors (id)
 );

-- -----------------------------------------------------
-- Table WS.order_content
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.order_content ;

CREATE TABLE IF NOT EXISTS WS.order_content (
  order_id BIGINT UNSIGNED NOT NULL,
  EAN BIGINT UNSIGNED NOT NULL,
  quanity INT UNSIGNED NOT NULL,
  product_discount_id INT UNSIGNED NULL,
  PRIMARY KEY (order_id, EAN),
  FOREIGN KEY (order_id) REFERENCES WS.orders (id),
  FOREIGN KEY (product_discount_id) REFERENCES WS.product_discount (id),
  FOREIGN KEY (EAN) REFERENCES WS.EANs (EAN)
  );


-- -----------------------------------------------------
-- Table WS.saved_garments
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.saved_garments ;

CREATE TABLE IF NOT EXISTS WS.saved_garments (
  id SERIAL primary key,
  users_id BIGINT UNSIGNED NOT NULL,
  model_id BIGINT UNSIGNED NOT NULL,
  color_id INT UNSIGNED NOT NULL,
  FOREIGN KEY (users_id) REFERENCES WS.users (id),
  FOREIGN KEY (model_id) REFERENCES WS.products (model),
  FOREIGN KEY (color_id) REFERENCES WS.colors (id)
);


-- -----------------------------------------------------
-- Table WS.stocks
-- -----------------------------------------------------
DROP TABLE IF EXISTS WS.stocks ;

CREATE TABLE IF NOT EXISTS WS.stocks (
  EAN BIGINT UNSIGNED NOT null primary KEY,
  available INT NOT NULL,
  in_transit INT,
  on_delivery INT,
  FOREIGN KEY (EAN) REFERENCES WS.EANs (EAN)
 );

-- -----------------------------------------------------
-- data inserts
-- -----------------------------------------------------
--  fill up categories

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/categories.csv' 
INTO TABLE categories 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
ignore 1 rows;

--  fill up colors

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/colors.csv' 
INTO TABLE colors 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'


-- fill up products

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv' 
INTO TABLE products 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
ignore 1 rows
;

-- fill up product_discount 

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/discounts.csv' 
INTO TABLE product_discount 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
;
-- so we fill all the data with csv files--

-- ----------------------------------------------------------- --
-- using subqueries on update in order to fix an error - 
-- we can't set list of discounts for orders where models have no discount
-- ----------------------------------------------------------- --
update order_content oc set discount_list_id = null 
select count(*) from order_content oc
where oc.EAN in (select EAN from eans where eans.model not in (select model_id from product_discounts)) ;

-- ----------------------------------------------------------- --
-- TRIGGERS
-- ----------------------------------------------------------- --
-- ----------------------------------------------------------- --
-- 1. we will check if new price will be higher than previouse one on the insert in discounts table.
-- ----------------------------------------------------------- --
CREATE TRIGGER `discount_check` BEFORE INSERT ON `product_discounts` 
FOR EACH ROW 
	begin 
		IF NEW.discount < (select discount from product_discounts where model_id = new.model_id) 
		then SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'you can not increse prices';
		END if;
	end;
-- trigger check:
insert into product_discount (model_id, discount) values ('877018', '0,2') -- works

-- ----------------------------------------------------------- --
-- FUNCIONS and PROCEDURES
-- ----------------------------------------------------------- --


-- ----------------------------------------------------------- --
-- 1. function to find current dicount list
-- ----------------------------------------------------------- --

CREATE FUNCTION `ws`.`get_discount_list_by_date` (discount_date DATE) 
RETURNS int 
    DETERMINISTIC
begin
	declare current_discount_list int;
	set current_discount_list = (select id from discount_list 
		where discount_date between discount_list.start_date and discount_list.end_date);
	return current_discount_list;
end

-- ----------------------------------------------------------- --
-- 2. function to find current discount by date and model
-- ----------------------------------------------------------- --

CREATE FUNCTION `ws`.`get_discount` (model bigint, discount_list_id int) RETURNS float
    DETERMINISTIC
begin
	declare current_discount float;
	if discount_list_id is null or 
	not exists (select model_id from product_discounts where model_id = model)
	then 
		set current_discount = 0;
	else 
		set current_discount = (select discount from product_discounts
			where product_discounts.model_id = model and product_discounts.discount_list_id = discount_list_id);
	end if;
	return current_discount;
end

select get_discount(877018, get_discount_list_by_date(curdate());

-- ----------------------------------------------------------- --
-- 3. function to calculate final_price by date and model
-- if there's no actual discount final price = original price 
-- ----------------------------------------------------------- --

CREATE FUNCTION `ws`.`get_final_price`(model bigint, discount_list_id int) RETURNS int
    DETERMINISTIC
begin
	declare final_price int;
	if discount_list_id is null or 
	not exists (select model_id from product_discounts where model_id = model)
	then 
		set final_price = (select original_price from products where products.model = model);
	else 
		set final_price = (Select round(products.original_price * (1 - product_discounts.discount)) 
		from products 
		join product_discounts on products.model = product_discounts.model_id 
		join discount_list on discount_list.id = product_discounts.discount_list_id
		where products.model = model and discount_list.id = discount_list_id); 
	end if;
	return final_price;
end

select get_final_price(877018, get_discount_list_by_date(curdate()));


-- ------------------------------------------------------------------ --
-- VIEWS
-- ------------------------------------------------------------------ --
-- ------------------------------------------------------------------ --
-- 1. view = each product card for products with stocks available or stocks in transit 
-- ------------------------------------------------------------------ --

create view product_card as
select pr.model, pr.model_description, pr.composition, pr.produced_in, c.color_name, eans.`size`, pr.original_price, 
concat(round(get_discount(pr.model, get_discount_list_by_date(curdate() ))*100),'%') as current_dicount, get_final_price (pr.model, get_discount_list_by_date(curdate())) as final_price 
from stocks
join eans on  stocks.EAN = eans.EAN
join products pr on pr.model = eans.model 
join colors c on c.id = pr.color_id 
where stocks.available > 0 or stocks.in_transit > 0; 

select * from product_card where original_price != final_price;
select get_discount(4027752, get_discount_list_by_date(curdate()));

-- ------------------------------------------------------------------ --
-- 2. view = orders-deliveries info for customers
-- ------------------------------------------------------------------ --
drop view if exists user_orders_info;
create view user_orders_info as 
SELECT 
	o.user_id customer_id,
	concat(u.name, ' ', u.surname) as `customer`, 
	o.id as `order num`,
	pc.model_description, pc.color_name, pc.`size`, pc.original_price, 
	concat(round(get_discount(pc.model, oc.discount_list_id)*100),'%') as `your discount`, 
	get_final_price(pc.model, oc.discount_list_id) as `price with discount`,
	oc.quanity, 
	oc.quanity*get_final_price(pc.model, oc.discount_list_id) as total_summ,
	payments.status as `payment status`,
	CASE
 		WHEN (deliveries.delivered_at is not null)
 		THEN 'delivered'
 		WHEN (deliveries.sent_at is not null)
 		THEN 'on_delivery'
 		ELSE 'preparing for delivery'
	end as `delivery status`
FROM orders o
join users u on o.user_id = u.id
join order_content oc on o.id = oc.order_id
join eans on oc.EAN = eans.EAN 
join product_card pc on pc.model = eans.model
join payments on payments.id = o.paiment_id
join deliveries on deliveries.id = o.delivery_id;

-- we will check orders by ,the customer who bought the most using temporary tables and variables

drop temporary table users_by_orders;
create temporary table users_by_orders  
select user_id, sum(order_content.quanity) as total_quanity from orders 
join order_content on order_content.order_id = orders.id 
group by user_id;

set @max_quantity := (select max(total_quanity) from users_by_orders);

select * from user_orders_info where customer_id = (select user_id from users_by_orders 
where total_quanity = @max_quantity);
-- ------------------------------------------------------------------ --
-- 2. procedure. we will show to the customer all products from selected category
-- organised by "new first" or "bestsellers first" for catalogue page
-- and 
-- ------------------------------------------------------------------ --

create procedure page_view_by_catalogue (sort_option enum('by_date', 'by_sales'))
begin 
	if sort_option = 'by_date'	then
		-- organized by novelties
		select cat.parent_category_name, pc.model, pc.model_description, pc.color_name, pc.final_price 
			from product_card pc
		join products pr on pr.model = pc.model
		join categories cat on cat.id = pr.subfamily_id 
		order by pr.uploaded_at desc;
	else 
		-- organized by sales
		select cat.parent_category_name, pc.model, pc.model_description, pc.color_name, pc.final_price 
			from product_card pc
		join products pr on pr.model = pc.model
		join categories cat on cat.id = pr.subfamily_id 
		join order_content on order_content.EAN in (select ean from eans where eans.model = pc.model)
		order by order_content.quanity desc;
	end if;
end;

call page_view_by_catalogue('by_date');

-- --------------------------------------------------------------- --
-- TRANSACTIONS
-- --------------------------------------------------------------- --
-- --------------------------------------------------------------- --
-- 1. Transaction to decrease stock when perchaise 
-- --------------------------------------------------------------- --
start transaction;
set @orderNumber := ((select max(id) from orders)+1);
set @new_ean := 8433299958455; 
set @new_quantity := 2;
insert into orders (id, user_id, created_at) values (@orderNumber, '44', now());
insert into order_content (order_id, ean, quanity) values (@orderNumber, @new_ean, @new_quantity);
update stocks set available = available - @new_quantity where ean = @new_ean;
commit;
select * from orders where id = @orderNumber;
