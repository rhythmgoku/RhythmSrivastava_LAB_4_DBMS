-- Pre Setup 

show databases;

-- check if databse "dbo" is present else run the create database command
CREATE DATABASE dbo;
use dbo;

-- supplier table
CREATE TABLE supplier (
   SUPP_ID INT PRIMARY KEY,
   SUPP_NAME VARCHAR(50) NOT NULL,
   SUPP_CITY VARCHAR(50) NOT NULL,
   SUPP_PHONE VARCHAR(50) NOT NULL
);

-- customer table
CREATE TABLE customer (
   CUS_ID INT PRIMARY KEY,
   CUS_NAME VARCHAR(20) NOT NULL,
   CUS_PHONE VARCHAR(10) NOT NULL,
   CUS_CITY VARCHAR(30) NOT NULL,
   CUS_GENDER CHAR
);

-- category table
CREATE TABLE category (
   CAT_ID INT PRIMARY KEY,
   CAT_NAME VARCHAR(20) NOT NULL
);

-- product table
CREATE TABLE product (
   PRO_ID INT PRIMARY KEY,
   PRO_NAME VARCHAR(20) NOT NULL DEFAULT 'Dummy',
   PRO_DESC VARCHAR(60),
   CAT_ID INT,
   CONSTRAINT FK_product_category FOREIGN KEY (CAT_ID) REFERENCES category(CAT_ID)
);

-- supplier_pricing table
CREATE TABLE supplier_pricing (
   PRICING_ID INT PRIMARY KEY,
   PRO_ID INT,
   SUPP_ID INT,
   SUPP_PRICE INT DEFAULT 0,
   CONSTRAINT FK_pricing_product FOREIGN KEY (PRO_ID) REFERENCES product(PRO_ID),
   CONSTRAINT FK_pricing_supplier FOREIGN KEY (SUPP_ID) REFERENCES supplier(SUPP_ID)
);

-- customer_order table
-- used customer_order in place or "order" as its a reserved keyword
CREATE TABLE customer_order (
   ORD_ID INT PRIMARY KEY,
   ORD_AMOUNT INT NOT NULL,
   ORD_DATE DATE NOT NULL,
   CUS_ID INT,
   PRICING_ID INT,
   CONSTRAINT FK_order_customer FOREIGN KEY (CUS_ID) REFERENCES customer(CUS_ID),
   CONSTRAINT FK_order_pricing FOREIGN KEY (PRICING_ID) REFERENCES supplier_pricing(PRICING_ID)
);

-- rating table
CREATE TABLE rating (
   RAT_ID INT PRIMARY KEY,
   ORD_ID INT,
   RAT_RATSTARS INT NOT NULL,
   CONSTRAINT FK_rating_order FOREIGN KEY (ORD_ID) REFERENCES customer_order (ORD_ID)
);
