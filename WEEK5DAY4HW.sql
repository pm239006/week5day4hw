-- Stored Procedure
-- Simulate a late fee charge

CREATE OR REPLACE PROCEDURE late_fee(
	--procedure arguments --> argument name type
	customer INTEGER, -- customer_id
	late_payment INTEGER, -- payment_id
	late_fee_amount DECIMAL(5,2) -- amount of late fee
)
LANGUAGE plpgsql -- gets stored with the procedure to let other users know what language our procedure is written in
AS $$ -- literal string quoting, stores the body of the query, then runs when we call it
BEGIN -- start of the procedure query
	-- Add late fee to customer payment amount
	-- based on the customer_id that is passed in(customer) and the payment_id(late_payment)
	UPDATE payment
	SET amount = amount + late_fee_amount
	-- condition that the customer_id and payment_id matched in the passed arguments
	WHERE customer_id = customer and payment_id = late_payment;
	
	--Commit the above statement inside our transaction
	COMMIT;
END;
$$

-- procedures are stored in the column just above tables
SELECT *
FROM payment;


SELECT *
FROM rental;


SELECT *
FROM customer;

-- calling a procedure 
CALL late_fee(342, 17509, 5.00);


-- same thing without comments as first procedure
CREATE OR REPLACE PROCEDURE late_fee(	
	customer INTEGER, 
	late_payment INTEGER, 
	late_fee_amount DECIMAL(5,2) 
)
LANGUAGE plpgsql 
AS $$ 
BEGIN 
	
	UPDATE payment
	SET amount = amount + late_fee_amount	
	WHERE customer_id = customer and payment_id = late_payment;
	
	
	COMMIT;
END;
$$

CREATE OR REPLACE PROCEDURE get_rekt(
	late_fee_amount DECIMAL(5,2)
)
LANGUAGE plpgsql
AS $$
BEGIN
	ALTER TABLE payment
	ADD COLUMN late_fee NUMERIC(6,2),
	ADD COLUMN late_total NUMERIC(6,2);
	UPDATE payment
	SET late_fee = late_fee_amount
	WHERE rental_id IN (
		SELECT rental_id
		FROM rental
		WHERE return_date - rental_date > INTERVAL '9 Days');
		
	UPDATE payment	
	SET late_total = amount + late_fee_amount
	WHERE rental_id IN (
		SELECT rental_id
		FROM rental
		WHERE return_date - rental_date > INTERVAL '9 Days'
		
);
COMMIT;
END;
$$



CALL get_rekt(5.00);

SELECT *
FROM payment;



ALTER TABLE payment
DROP COLUMN late_fee;

ALTER TABLE payment
DROP COLUMN late_total;

SELECT *
FROM payment
WHERE rental_id IN
(SELECT rental_id
		FROM rental
		WHERE return_date - rental_date > INTERVAL '9 Days');
		

SELECT *
FROM payment;

--Stored functions
--difference between procedures and functions is that functions can return something
CREATE OR REPLACE FUNCTION add_actor(
	_actor_id INTEGER,
	_first_name VARCHAR,
	_last_name VARCHAR,
	_last_update TIMESTAMP
)
RETURNS void -- what datatype is going to be returned
AS $MAIN$ -- naming the body or string literal
BEGIN
	INSERT INTO actor
	VALUES(_actor_id, _first_name, _last_name, _last_update);
END;
$MAIN$
LANGUAGE plpgsql;

SELECT *
FROM actor
WHERE actor_id = 501;

-- DO NOT CALL A FUNCTION
-- SELECT A FUNCTION
SELECT add_actor(500, 'Orlando', 'Bloom', NOW()::timestamp);
SELECT add_actor(501, 'Elijah', 'Wood', NOW()::timestamp);


CREATE OR REPLACE FUNCTION get_discount(price NUMERIC, percentage INTEGER)
RETURNS INTEGER
AS $$
BEGIN
RETURN (price * (100-percentage)/100);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE apply_discount(percentage INTEGER, _payment_id INTEGER)
AS $$
BEGIN
UPDATE payment
SET amount = get_discount(payment.amount, percentage)
WHERE payment_id = _payment_id;
END;
$$
LANGUAGE plpgsql;

SELECT *
FROM payment
WHERE payment_id = 17506;

-- 17505, 341
CALL apply_discount(25, 17506);





----- HOMEWORK -------
CREATE OR REPLACE FUNCTION 
RETURNS BOOLEAN
AS $$
BEGIN
RETURN 
END;
$$
LANGUAGE plpgsql;

ALTER TABLE customer 
DROP COLUMN activebool CASCADE;






CREATE OR REPLACE PROCEDURE platinum_member()
LANGUAGE plpgsql
AS $$
BEGIN
	ALTER TABLE customer
	ADD COLUMN IF NOT EXISTS platinum_member BOOLEAN;
		UPDATE customer
		SET platinum_member = '1'
		WHERE customer_id  IN (
			SELECT customer_id
			FROM payment
			GROUP BY customer_id
			HAVING SUM(amount)> 200);
			
	UPDATE customer
	SET platinum_member = '0'
		WHERE customer_id  IN (
			SELECT customer_id
			FROM payment
			GROUP BY customer_id
			HAVING SUM(amount)< 200);
COMMIT;
END;
$$

CALL platinum_member()

SELECT *
FROM customer



-- CREATE OR REPLACE PROCEDURE platinum_member(customer INTEGER, first_name VARCHAR,last_name VARCHAR, activebool BOOLEAN)
-- LANGUAGE plpgsql 
-- AS $$
-- BEGIN 
-- UPDATE customer
-- SET 
-- WHERE customer_id IN(
-- 	SELECT customer_id
-- 	FROM payment
-- 	GROUP BY customer_id
-- 	HAVING SUM(amount) > 200
-- 	ORDER BY SUM(amount) DESC)
	
-- 	IF SUM(amount) > 200 
-- 	UPDATE customer 
-- 	SET activebool = 1
	
-- 	ELSE 
-- 		UPDATE customer
-- 		SET activebool = 0
-- 		WHERE SUM(amount) < 201
-- 		END if;
-- $$


























	
		