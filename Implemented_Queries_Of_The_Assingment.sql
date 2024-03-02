-- Pre Setup 

show databases;
-- check if databse "dbo" is present else run the DDL_Table_Creation_Commands.sql and then DML_Data_Insertion_Commands.sql

use dbo;
SET sql_mode = '';


-- Questions
------------------------------

-- Question 4) Total number of customers based on gender who have placed individual orders of worth at least Rs.3000:

-- Note => this query will fetch based on gender can contain duplicate customers 

		SELECT CUS_GENDER, COUNT(*) AS customer_count
		FROM customer c
		JOIN customer_order o ON o.CUS_ID = c.CUS_ID
		-- as its mentioned at least 3000 then it can be read as equal to 3000 and above so used ">=" 
		WHERE o.ORD_AMOUNT >= 3000
		GROUP BY CUS_GENDER;

-- Note => this is the enhanced query will fetch based on gender will NOT contain duplicate customers 

		SELECT CUS_GENDER, COUNT(DISTINCT o.CUS_ID) AS customer_count
		FROM customer_order o 
		JOIN customer c ON c.CUS_ID = o.CUS_ID
		-- as its mentioned at least 3000 then it can be read as equal to 3000 and above so used ">=" 
		WHERE o.ORD_AMOUNT >= 3000
		GROUP BY CUS_GENDER;



-- Question 5) Display all the orders along with product name ordered by a customer having Customer_Id=2:

		SELECT o.ORD_ID, p.PRO_NAME 
		FROM customer_order o
		JOIN supplier_pricing sp ON o.PRICING_ID = sp.PRICING_ID
		JOIN product p ON sp.PRO_ID = p.PRO_ID
		WHERE o.CUS_ID = 2;


-- Question 6) Display the Supplier details who can supply more than one product:

		SELECT DISTINCT s.SUPP_ID, s.SUPP_NAME, s.SUPP_CITY, s.SUPP_PHONE
		FROM supplier s
		JOIN supplier_pricing sp ON s.SUPP_ID = sp.SUPP_ID
		GROUP BY s.SUPP_ID, s.SUPP_NAME, s.SUPP_CITY, s.SUPP_PHONE
		HAVING COUNT(DISTINCT sp.PRO_ID) > 1;


-- Question 7) Find the least expensive product from each category:


-- Query used in the live lab session
-- Note => This query fetches the record but it has some bug as it fetches the min vlaue but the Product Name mapped to it is incorrect.
-- Example =>  This Shows cat=BOOKS	pro_name=HARRY POTTER min_price=780 but in reality the correct record should be cat=BOOKS pro_name=Train Your Brain min_price=780
		
        SELECT cat_name, pro_name, PRO_DESC, min(supp_price)
		FROM category
		JOIN product
		USING ( cat_id )
		JOIN supplier_pricing
		USING ( pro_id )
		group by cat_name;

-- Enhanced query for getting the least expensive product by  category
		
        SELECT CAT_ID, CAT_NAME, PRO_NAME, Min_Price
		FROM (
			SELECT CAT_ID, CAT_NAME, PRO_NAME, Min_Price,
			-- To extract the min price product we partition them and rank them using the row_number function so we can filetr the cheapest one by select rownumber as 1 as its in ASC order
				   ROW_NUMBER() OVER (PARTITION BY CAT_ID ORDER BY Min_Price ASC ) as rowNumber 
			FROM (
			SELECT c.CAT_ID, c.CAT_NAME, p.PRO_NAME, MIN(sp.SUPP_PRICE) AS Min_Price FROM category c JOIN product p ON c.CAT_ID = p.CAT_ID JOIN supplier_pricing sp ON p.PRO_ID = sp.PRO_ID GROUP BY c.CAT_ID, c.CAT_NAME , p.PRO_NAME
			) AS lookup
		)  AS subquery
		WHERE rowNumber = 1;


-- Question 8) Display the Id and Name of the Product ordered after "2021-10-05":

		SELECT p.PRO_ID, p.PRO_NAME
		FROM product p
		JOIN supplier_pricing sp ON sp.PRO_ID = p.PRO_ID
		JOIN customer_order o ON o.PRICING_ID = sp.PRICING_ID
		WHERE o.ORD_DATE > '2021-10-05';


-- Question 9) Display customer name and gender whose names start or end with character 'A'.

		SELECT CUS_NAME, CUS_GENDER
		FROM customer
		WHERE CUS_NAME LIKE 'A%' OR CUS_NAME LIKE '%A';

-- Question 10) Stored procedure to display supplier details with average rating and service type:

		DELIMITER &&
		CREATE PROCEDURE display_supplier_ratings()
		BEGIN
			SELECT s.SUPP_ID, s.SUPP_NAME, AVG(r.RAT_RATSTARS) AS rating,
				   CASE 
					   WHEN AVG(r.RAT_RATSTARS) = 5 THEN 'Excellent Service'
					   WHEN AVG(r.RAT_RATSTARS) > 4 THEN 'Good Service'
					   WHEN AVG(r.RAT_RATSTARS) > 2 THEN 'Average Service'
					   ELSE 'Poor Service'
				   END AS Type_of_Service
			FROM supplier s
			JOIN supplier_pricing sp ON sp.SUPP_ID = s.SUPP_ID
			JOIN customer_order o ON o.PRICING_ID = sp.PRICING_ID
			JOIN rating r ON r.ORD_ID = o.ORD_ID
			GROUP BY s.SUPP_ID, s.SUPP_NAME
			ORDER BY s.SUPP_ID;
		END &&
		DELIMITER ;

		-- calling the Stored Procedure
		CALL display_supplier_ratings(); 