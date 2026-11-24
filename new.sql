CREATE DATABASE new_shop;
USE new_shop;

create table Suppliers(                                                                                     -- ПОСТАЧАЛЬНИКИ     
	number int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    supplier_last_name VARCHAR(50),   -- Прізвище
    supplier_first_name VARCHAR(50),  -- Ім'я
    supplier_middle_name VARCHAR(50), -- По-батькові
    brand_name varchar(50) UNIQUE,
               -- name_company varchar(15),
    supplier_phone char(13),
    supplier_gmail varchar(50),
    country varchar(15),
    supplier_start_work date,
    supplier_salary DECIMAL(10,2) NOT NULL,
    
		CONSTRAINT chk_suppliers_salary CHECK (supplier_salary >= 0)
);

create table Shop_storage(                                                                                  -- СКЛАД
	product_id int NOT NULL AUTO_INCREMENT PRIMARY KEY ,
    barcode char(13) UNIQUE,
    category ENUM('Шорти', 'Спідниця', 'Штани', 'Футболка', 'Светр','Блузка','Кофта','Сорочка','Піджак', 'Куртка', 'Плаття'),
    brand_name_id varchar(50),
    human ENUM ('Чоловічий', 'Жіночий'),
    color ENUM ('Червоний', 'Оранжевий', 'Жовтий', 'Зелений','Голубий', 'Синій', 'Розовий', 'Сірий', 'Чорний', 'Білий', 'Коричневий'),
    size ENUM ('XXS', 'XS', 'S', 'M', 'L', 'XL'),
    amount int,
    price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,            
    status ENUM ('Акційний', 'Новий', 'Продано'),
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
		
        CONSTRAINT fk_storage_brand
		FOREIGN KEY (brand_name_id) REFERENCES Suppliers(brand_name)
		ON DELETE RESTRICT ON UPDATE CASCADE,
		
        CONSTRAINT chk_products_price CHECK (price >= 0),  
        
		CONSTRAINT chk_products_cost_price  CHECK (cost_price >= 0),
        
		CONSTRAINT chk_products_amount CHECK (amount >= 0)
);

CREATE TABLE Roles (                                                     -- права в системі (що показувати в меню)
    role_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(30) NOT NULL UNIQUE
);

create table Positions (                                                                                      -- ПОСАДА 
    position_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    position_name VARCHAR(40) NOT NULL UNIQUE,
    role_id INT NOT NULL,     
    
		CONSTRAINT fk_positions_role
        FOREIGN KEY (role_id) REFERENCES roles(role_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

create table Workers(                                                                                       -- ПРАЦІВНИКИ МАГАЗИНУ
	worker_id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	worker_last_name VARCHAR(50) NOT NULL,   -- Прізвище
    worker_first_name VARCHAR(50) NOT NULL,  -- Ім'я
    worker_middle_name VARCHAR(50) NOT NULL, -- По-батькові
    position_id int,
    worker_phone char(13),
    worker_gmail varchar(50),
    worker_address VARCHAR(150) NULL,
    worker_start_work date,
    worker_finish_work date,
    worker_salary DECIMAL(10,2) NOT NULL, 
    
		CONSTRAINT chk_workers_salary CHECK (worker_salary >= 0),
        
		CONSTRAINT chk_worker_start_work  CHECK (worker_finish_work IS NULL OR worker_finish_work >= worker_start_work),
        
		CONSTRAINT fk_workers_position
		FOREIGN KEY (position_id) REFERENCES positions(position_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Accounts (                                                                                     -- вхід у систему (Е1)
    account_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    worker_id INT NOT NULL UNIQUE,        
    login VARCHAR(50) NOT NULL UNIQUE,         
    password VARCHAR(255) NOT NULL,                
    is_active BOOLEAN NOT NULL DEFAULT TRUE,  
    
		CONSTRAINT fk_accounts_worker
        FOREIGN KEY (worker_id) REFERENCES 	Workers(worker_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

create table Product_return(                                                                                -- ЗАЯВА НА ПОВЕРНЕННЯ ТОВАРУ
	return_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    receipt_number_id INT NOT NULL,                                                      -- прив'язка до номера чеку 
	last_name VARCHAR(50) NOT NULL,   -- Прізвище
    first_name VARCHAR(50) NOT NULL,  -- Ім'я
    middle_name VARCHAR(50) NOT NULL, -- По-батькові
    address VARCHAR(100) NOT NULL,
    birthday date NOT NULL,
    number_passport CHAR(9) NOT NULL,
    phone char(13) NOT NULL,
    description_return VARCHAR(100) NOT NULL,
    admin_name VARCHAR(50) DEFAULT 'Андріїшин Діана Василівна' NOT NULL,
    cost DECIMAL(10,2) NOT NULL,                                                                 -- прив'язка до чеку
    cost_date DATETIME UNIQUE,                                                              -- прив'язка до чеку 
    return_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ,
    payment ENUM ('Готівка', 'Картка'),
    number_card VARCHAR(19) NULL,                                                             -- ПРИВ'ЗКА ДО ЧЕКУ
        
		CONSTRAINT chk_cost CHECK (cost >= 0),
        
		CONSTRAINT chk_payment CHECK (payment = 'Готівка' OR number_card IS NOT NULL),
    
		CONSTRAINT fk_return_receipt
        FOREIGN KEY (receipt_number_id) REFERENCES Cash_register_receipt(receipt_number)
        ON DELETE RESTRICT ON UPDATE CASCADE,
        
        CONSTRAINT fk_cost_date
        FOREIGN KEY (cost_date) REFERENCES Cash_register_receipt(sale_date)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Cash_register (                                                                                -- КАСА
	number int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    barcode_id char(13),
    category_id ENUM('Шорти', 'Спідниця', 'Штани', 'Футболка', 'Светр','Блузка','Кофта','Сорочка','Піджак', 'Куртка', 'Плаття'),
	brand_name_id varchar(50),
    human_id ENUM ('Чоловічий', 'Жіночий'),
    color_id ENUM ('Червоний', 'Оранжевий', 'Жовтий', 'Зелений','Голубий', 'Синій', 'Розовий', 'Сірий', 'Чорний', 'Білий', 'Коричневий'),
    size_id ENUM ('XXS', 'XS', 'S', 'M', 'L', 'XL'),
    amount_id int,                                         -- кількість позицій одного виду
    price_id DECIMAL(10,2),                                       -- ціна за одну позицію одного виду(без знижки)
    new_price DECIMAL(10,2),                                      -- "Сума" 
    status_id ENUM ('Акційний', 'Новий', 'Продано'),
    total_amount int,                                      -- загальна кількість позицій
    discount int,                                          -- знижка(у відсотках)
    total_discount DECIMAL(10,2),                                    -- знижка(у гривнях, з  мінусом мб)
    card ENUM ('Присутня','Немає'),                        -- є/нема картки на знижку
    discount_existence ENUM ('Є','Немає'),                 -- є/нема знижки
    total_cost DECIMAL(10,2),                                     -- загальна сума (з знижкою)
        
		CONSTRAINT fk_cash_barcode
        FOREIGN KEY (barcode_id) REFERENCES Shop_storage(barcode)
        ON DELETE RESTRICT ON UPDATE CASCADE,
        
		CONSTRAINT fk_cash_brand
        FOREIGN KEY (brand_name_id) REFERENCES Suppliers(brand_name)
        ON DELETE RESTRICT ON UPDATE CASCADE
        
        -- CONSTRAINT fk_cash_brand
        -- FOREIGN KEY (brand_name_id) REFERENCES Shop_storage(brand_name_id)
        -- ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Сash_register_receipt (                                                                        -- ЧЕК
    receipt_number INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    sale_date DATETIME DEFAULT CURRENT_TIMESTAMP,  
    -- barcode_id char(13) UNIQUE,
    -- category_id VARCHAR(50),
    -- brand_name_id VARCHAR(50),
    -- human_id ENUM ('Man', 'Woman'),
    -- size_id VARCHAR(50),
	-- price_id double,                                            -- ціна за одну позицію одного виду(без знижки)
	-- discount_id int,                                            -- знижка(у відсотках)
    -- new_price_id double,                                        -- ціна зі знижкою за 1 товар
    total_cost_id DOUBLE NOT NULL,                              -- загальна сума (з знижкою)
	-- amount_id int,
    total_amount_id int not null,
    payment_method ENUM('Готівка', 'Картка') DEFAULT "Готівка" NULL, 
    discount_card ENUM("Пристуня","Немає") NOT NULL DEFAULT "Немає",               -- «Карта на знижку: присутня / немає»
    worker_id INT NOT NULL,                 
    
		-- CONSTRAINT fk_receipt_number
        -- FOREIGN KEY (receipt_number) REFERENCES Cash_register(number)
        -- ON DELETE RESTRICT ON UPDATE CASCADE,
    
		-- CONSTRAINT fk_receipt_brand
        -- FOREIGN KEY (brand_name_id) REFERENCES Suppliers(brand_name)
        -- ON DELETE RESTRICT ON UPDATE CASCADE,
        
		CONSTRAINT fk_receipt_worker
        FOREIGN KEY (worker_id) REFERENCES Workers(number)
        ON DELETE RESTRICT ON UPDATE CASCADE
        
);

CREATE TABLE History_receipts (                                                                             -- ІСТОРІЯ ЧЕКІВ
	receipt_number_id INT NOT NULL,
    sale_date_id DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_cost_id DECIMAL(10,2) NOT NULL,                               -- загальна сума (з знижкою)
    status_product ENUM("Оплачено", "Повернено") DEFAULT "Оплачено",
    -- КНОПКА "ПЕРЕГЛЯНУТИ":
    worker_id INT NOT NULL,
	payment_method_id ENUM('Готівка', 'Картка') NOT NULL,
	number int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    product_id int NOT NULL,
    barcode_id char(13), -- каса
    category_id VARCHAR(50), -- чек
	brand_name_id VARCHAR(50), -- чек
	human_id ENUM ('Чоловічий', 'Жіночий'), -- чек
    size_id VARCHAR(50), -- чек
    amount_id int,
    price_id DECIMAL(10,2) NOT NULL,                                    -- ціна за одну позицію одного виду
	new_price_id DECIMAL(10,2) NOT NULL,                                -- ціна зі знижкою за 1 товар
    
		-- «Сума» у чеку = (ціна - знижка) * кількість; бізнес-правило 12
		line_total DECIMAL(12,2) GENERATED ALWAYS AS (ROUND(amount_id * new_price_id, 2)) STORED,
    
		CONSTRAINT uq_receipt_product UNIQUE (receipt_number_id, product_id),
		CONSTRAINT chk_item_amount CHECK (amount > 0),
		CONSTRAINT chk_item_price    CHECK (price_id >= 0),
        CONSTRAINT chk_item_discount CHECK (new_price_id >= 0 AND new_price_id <= price_id),
    
		CONSTRAINT fk_history_receipt
        FOREIGN KEY (receipt_number_id) REFERENCES Cash_register_receipt(receipt_number)
        ON DELETE RESTRICT ON UPDATE CASCADE,
        
		CONSTRAINT fk_history_barcode
        FOREIGN KEY (barcode_id) REFERENCES Сash_register_receipt(barcode_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
        
		CONSTRAINT fk_history_brand
        FOREIGN KEY (brand_name_id) REFERENCES Suppliers(brand_name)
        ON DELETE RESTRICT ON UPDATE CASCADE
        
        CONSTRAINT fk_worker_id
        FOREIGN KEY (worker_id) REFERENCES Workers(worker_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
    
		-- FOREIGN KEY (receipt_number_id) REFERENCES  Сash_register_receipt(receipt_number) ON DELETE RESTRICT ON UPDATE CASCADE, 
        -- FOREIGN KEY (sale_date_id) REFERENCES  Сash_register_receipt(sale_date) ON DELETE RESTRICT ON UPDATE CASCADE, 
		-- FOREIGN KEY (total_cost_id) REFERENCES Сash_register_receipt(total_cost) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (worker_last_name_id)  REFERENCES Workers(worker_last_name) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (worker_first_name_id) REFERENCES Workers(worker_first_name) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (worker_middle_name_id) REFERENCES Workers(worker_middle_name) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (payment_method_id) REFERENCES Сash_register_receipt(payment_method) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (barcode_id) REFERENCES Cash_register(barcode)  ON DELETE RESTRICT ON UPDATE CASCADE,
       --  FOREIGN KEY (category_id) REFERENCES Cash_register_receipt(category) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (brand_name_id) REFERENCES Suppliers(brand_name) ON DELETE RESTRICT ON UPDATE CASCADE,
		-- FOREIGN KEY (brand_name_id) REFERENCES Cash_register_receipt(brand_name) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (human_id) REFERENCES Cash_register_receipt(human) ON DELETE RESTRICT ON UPDATE CASCADE,
       --  FOREIGN KEY (size_id) REFERENCES Cash_register_receipt(size) ON DELETE RESTRICT ON UPDATE CASCADE,
       --  FOREIGN KEY (amount_id) REFERENCES Cash_register_receipt(amount) ON DELETE RESTRICT ON UPDATE CASCADE,
       --  FOREIGN KEY (price_id) REFERENCES Cash_register_receipt(price) ON DELETE RESTRICT ON UPDATE CASCADE,
		-- FOREIGN KEY (new_price_id) REFERENCES Сash_register_receipt(new_price) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Purchase_list (                                                                                -- СПИСОК ЗАКУПІВЕЛЬ       
	number int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    date_purchase DATETIME DEFAULT CURRENT_TIMESTAMP,            -- дата створення закупівлі
    supplier_last_name_id VARCHAR(50),   -- Прізвище 
    supplier_first_name_id VARCHAR(50),  -- Ім'я
    supplier_middle_name_id VARCHAR(50), -- По-батькові
    finish_price double,                                         -- загальна сума, на яку закупились нового товару
    brand_name_id varchar(50),
    status ENUM("Очікується","Отримано") DEFAULT "Отримано",
    -- КНОПКА "СТВОРИТИ ЗАКУПІВЛЮ: "
    category_id ENUM('Шорти', 'Спідниця', 'Штани', 'Футболка', 'Светр','Блузка','Кофта','Сорочка','Піджак', 'Куртка', 'Плаття'),
    size_id ENUM ('XXS', 'XS', 'S', 'M', 'L', 'XL'),
    color_id ENUM ('Червоний', 'Оранжевий', 'Жовтий', 'Зелений','Голубий', 'Синій', 'Розовий', 'Сірий', 'Чорний', 'Білий', 'Коричневий'),
    human_id ENUM ('Чоловічий', 'Жіночий'),
    amount_products int,
    price_id double,                                             -- ціна за одну позицію одного виду
    
		CONSTRAINT fk_purchase_supplier
        FOREIGN KEY (supplier_id) REFERENCES Suppliers(number)
        ON DELETE RESTRICT ON UPDATE CASCADE,
        
		CONSTRAINT fk_purchase_brand
        FOREIGN KEY (brand_name_id) REFERENCES Suppliers(brand_name)
        ON DELETE RESTRICT ON UPDATE CASCADE
        
		-- FOREIGN KEY (supplier_last_name_id) REFERENCES Suppliers(supplier_last_name) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (supplier_first_name_id) REFERENCES Suppliers(supplier_first_name) ON DELETE RESTRICT ON UPDATE CASCADE,
       --  FOREIGN KEY (supplier_middle_name_id) REFERENCES Suppliers(supplier_middle_name) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (brand_name_id) REFERENCES Suppliers(brand_name) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (category_id) REFERENCES Shop_storage(category) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (size_id) REFERENCES Shop_storage(size) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (color_id) REFERENCES Shop_storage(color) ON DELETE RESTRICT ON UPDATE CASCADE,
        -- FOREIGN KEY (human_id) REFERENCES Shop_storage(human) ON DELETE RESTRICT ON UPDATE CASCADE,
		-- FOREIGN KEY (price_id) REFERENCES Shop_storage(price) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Statistic ( 
	statistic_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    stat_month DATE NOT NULL DEFAULT '2026-11-01' UNIQUE,								-- СТАТИСТИКА МАГАЗИНУ
	total_revenue double,                       -- Загальний виторг
    amount_receipts int,                        -- кількість чеків
    average_receipt double,                    
    saled_products int,                         -- всього продано позицій 
    product_returns int,
    cost_of_sold double,                        -- Собівартість проданого (грн)
    profit double,                              -- Валовий прибуток (грн)
    clean_profit double,                        -- Чистий прибуток (грн)
    total_products int,                         -- Усього товарних позицій
    products_in_stock int,                      -- Товарів у наявності
    products_not_in_stock int,                  -- Товарів немає в наявності
    the_biggest_receipt double, 
    amount_workers int,
    amount_of_shifts_per_month int,             -- Загальна кількість змін за місяць
	pays_cash int,                              -- Усього оплат готівкою
    pays_card int                               -- Усього оплат карткою
);

CREATE TABLE Promotions (                                                                                -- АКЦІЇ
    promotion_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    promotion_name VARCHAR(100) NOT NULL,
    discount_type ENUM('Відсоток','Фіксована сума') NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    category_id ENUM('Шорти', 'Спідниця', 'Штани', 'Футболка', 'Светр','Блузка','Кофта','Сорочка','Піджак', 'Куртка', 'Плаття') NULL,
    supplier_id INT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    
		CONSTRAINT chk_promo_value CHECK (
        (discount_type = 'Відсоток' AND discount_value BETWEEN 1 AND 90)
        OR (discount_type = 'Фіксована сума' AND discount_value > 0)),
        
		CONSTRAINT chk_promo_target CHECK (category_id IS NOT NULL OR supplier_id IS NOT NULL),
    
		CONSTRAINT chk_promo_dates  CHECK (end_date >= start_date),
    
		-- CONSTRAINT fk_promo_category FOREIGN KEY (category_id) REFERENCES Shop_storage(category) ON DELETE RESTRICT ON UPDATE RESTRICT
        
		CONSTRAINT fk_promo_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)  ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE Store_hours (                   
    weekday INT NOT NULL PRIMARY KEY,
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    
		CONSTRAINT chk_store_weekday CHECK (weekday BETWEEN 1 AND 7),
		CONSTRAINT chk_store_time    CHECK (close_time > open_time)
);

CREATE TABLE Expenses (                                                                                  -- ВИТРАТИ
    expense_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    expense_date DATE NOT NULL,
    description VARCHAR(100) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    
		CONSTRAINT chk_expense_amount CHECK (amount >= 0)
);

CREATE TABLE Work_shifts (                                                                          -- Робочий графік 
    shift_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    worker_id INT NOT NULL,
    shift_date DATE NOT NULL,    
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    
		CONSTRAINT uq_shift UNIQUE (worker_id, shift_date),
        
		CONSTRAINT chk_shift_time CHECK (end_time > start_time),
        
		CONSTRAINT fk_shifts_worker
        FOREIGN KEY (worker_id) REFERENCES Workers(worker_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Purchases (                                                                                     -- ЗАКУПІВЛІ
    purchase_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,         -- №
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,    -- Дата
    supplier_id INT NOT NULL,                                    -- Постачальни/Бренд
    -- created_by INT NOT NULL,
    status ENUM('Очікується','Отримано') NOT NULL DEFAULT 'Очікується',
    
    CONSTRAINT fk_purchases_supplier FOREIGN KEY (supplier_id) REFERENCES Suppliers(number) ON DELETE RESTRICT ON UPDATE CASCADE
    -- CONSTRAINT fk_purchases_worker FOREIGN KEY (created_by) REFERENCES workers(worker_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE purchase_items (                                                                            -- "ДОДАТИ ЗАКУПІВЛЮ"
    purchase_item_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    purchase_id INT NOT NULL,
    barcode_id CHAR(13) NOT NULL,                                -- «Шукати товар по штрихкоду»
    category_id ENUM('Шорти', 'Спідниця', 'Штани', 'Футболка', 'Светр','Блузка','Кофта','Сорочка','Піджак', 'Куртка', 'Плаття') NULL,                                    -- «Назва товару»
    human ENUM ('Чоловічий', 'Жіночий'),
    color ENUM ('Червоний', 'Оранжевий', 'Жовтий', 'Зелений','Голубий', 'Синій', 'Розовий', 'Сірий', 'Чорний', 'Білий', 'Коричневий'),
    size ENUM ('XXS', 'XS', 'S', 'M', 'L', 'XL'),
    quantity INT NOT NULL,                                      
    price_id DECIMAL(10,2) NOT NULL,                        
    line_total DECIMAL(12,2) GENERATED ALWAYS AS (ROUND(quantity * unit_cost, 2)) STORED,  -- Загальна ціна
    
		CONSTRAINT chk_pi_qty  CHECK (quantity > 0),
        
		CONSTRAINT chk_pi_price_id CHECK (price_id >= 0),
        
		CONSTRAINT fk_pi_purchase FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id)  ON DELETE CASCADE  ON UPDATE CASCADE,
		
)

insert into Shop_storage(barcode ,category, brand_name_id, human, color, size, amount, price ,cost_price, status, added_at ) values
	(2049763927100, 'Штани', 'Bershka', 'Чоловічий', 'Чорний', 'M', 20, 799.00,'Акційний'),
    (2057830282225, 'Футболка', 'Nike', 'Жіночий', 'Розовий', 'S', 12, 799.00, 'Акційний'),
    (2615493293404, 'Кофта', 'Lacoste', 'Жіночий', 'Розовий', 'S', 12, 799.00, 'Акційний'),
    (6583729038372, 'Піджак', 'Zara', 'Чоловічий', 'Коричневий', 'L', 5, 1599.00, 'Новий'),
    (8649372947362, 'Плаття', 'Bershka', 'Жіночий', 'Червоний', 'XS', 11, 699.00, 'Акційний'),
    (6749274927648, 'Светр', 'Oysho', 'Чоловічий', 'Зелений', 'XS', 7, 999.00, 'Акційний'),
    (6342840264842, 'Шорти', 'Zara', 'Чоловічий', 'Синій', 'S', 4, 1399.00, 'Акційний'),
    (2163926490472, 'Сорочка', 'Massimo Dutti', 'Білий', 'Розовий', 'XL', 13, 1299.00, 'Акційний'),
    (1478394726483, 'Спідниця', 'Stradivarius', 'Жіночий', 'Голубий', 'XXS', 2, 999.00, 'Новий'),
    (9262745274932, 'Куртка', 'Stradivarius', 'Чоловічий', 'Чорний', 'M', 6, 1799.00, 'Новий'),
    (0267647641552, 'Блузка', 'Zara', 'Жіночий', 'Чорний', 'M', 1, 599.00, 'Продано'),
    (6785674534587, 'Кофта', 'Massimo Dutti', 'Чоловічий', 'Сірий', 'L', 2, 1899.00, 'Продано'),
    (1321321432546, 'Светр', 'Bershka', 'Жіночий', 'Розовий', 'S', 3, 799.00, 'Продано'
);

INSERT INTO Suppliers (supplier_last_name, supplier_first_name, supplier_middle_name, brand_name, supplier_phone, supplier_gmail, country, supplier_start_work, supplier_salary) VALUES
 ('Бондаренко','Олексій','Тарасович',     'Stradivarius', '+380987654321','oleksiy.bond@gmail.com',       'Іспанія',   '2025-09-21', 17000),
 ('Ковальчук', 'Олена',  'Ігорівна',      'Nike',         '+380671234567','o.kovalchuk@nike-supply.com',  'В''єтнам',  '2025-07-07', 18000),
 ('Шевченко',  'Андрій', 'Володимирович', 'Zara',         '+380934567890','a.shevchenko@inditex.ua',      'Португалія','2020-06-05', 17700),
 ('Мельник',   'Ірина',  'Василівна',     'Bershka',      '+380683216549','i.melnyk@fashion-logistics.com','Туреччина','2021-08-04', 13000),
 ('Ткаченко',  'Дмитро', 'Олександрович', 'Lacoste',      '+380951472583','d.tkachenko@lacoste.fr',       'Франція',   '2024-11-23', 20000),
 ('Кравченко', 'Наталія','Миколаївна',    'Oysho',        '+380738529630','n.kravchenko@oysho-trade.com', 'Китай',     '2023-12-12', 19000),
 ('Бойко',     'Сергій', 'Петрович',      'Massimo Dutti','+380976543210','s.boyko@dutti-group.com',      'Італія',    '2026-05-11', 22000),
 ('Лисенко',   'Марія',  'Сергіївна',     'Puma',         '+380683216549','m.lysenko@puma-distrib.com',   'Бангладеш', '2024-08-31', 18000);


INSERT INTO Cash_register (
    barcode_id,
    brand_name_id,
    amount_id,
    discount,
    card,
    discount_existence
) VALUES
    ('2057830282225','Nike', 1 , 15 , 'Присутня', 'Є'),
    ('1478394726483','Stradivarius', 1, 15, 'Присутня', 'Є');








