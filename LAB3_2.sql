-- In this lab, you will be using the Sakila database of movie rentals. Create appropriate joins wherever necessary.
Use sakila;
-- Instructions
-- How many copies of the film Hunchback Impossible exist in the inventory system?
/*inventory: inventory_id, film_id, store_id
film: film_id, title*/
SeLECT film_id, title from film;
SELECT f.film_id, f.title, COUNT(i.inventory_id) as "Number of copies"
FROM sakila.inventory as i
JOIN sakila.film as f
ON i.film_id = f.film_id
Where f.title = 'Hunchback Impossible'
Group by f.film_id;
-- List all films whose length is longer than the average of all the films.
-- Let's find the Avg. value first:
SELECT avg(length) from film;
-- 115.27
SELECT film_id, title, length FROM sakila.film
WHERE length > (
  SELECT round(avg(length),2)
  FROM sakila.film
);
-- Use subqueries to display all actors who appear in the film Alone Trip.
-- #brainstorm:
select * from sakila.film
WHERE title='ALONE TRIP';
select COUNT(actor_id) as "Number of Actors" from sakila.film_actor
WHERE film_id=17;
-- film_actor: actor_id, film_id
-- film: film_id, title
-- actor: actor_id, first_name, last_name
-- #final:
SELECT * FROM (
 SELECT f.film_id, f.title, a.actor_id, a.first_name, a.last_name
 FROM sakila.film_actor as fa
 JOIN sakila.film as f
 ON fa.film_id = f.film_id
 JOIN sakila.actor as a
 ON fa.actor_id = a.actor_id) as sub1
Where title = 'ALONE TRIP';

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- #brainstorm: film: film_id, title
-- category: category_id, name
-- film_category: film_id, category_id
SELECT * from category;
-- Final:
SELECT * FROM (
SELECT f.title, c.name as genre
FROM film as f
JOIN film_category as fa
On f.film_id = fa.film_id
JOIN category as c
ON fa.category_id = c.category_id
WHERE c.name = 'Family') as sub1;
-- Get name and email from customers from Canada using subqueries. Do the same with joins.
-- Note that to create a join, you will have to identify the correct tables with their primary keys 
-- and foreign keys, that will help you get the relevant information.
-- Brainstorm:
SELECT * from country;
-- country_id, country, co
SELECT * FROM city;
-- city_id, city, ct
SELECT * FROM address;
-- address_id, city_id, district, a
SELECT * from customer;
-- customer_id, store_id, address_id, first_name, last_name, email, c
-- With JOIN:
SELECT c.first_name, c.last_name, co.country, a.district as State, c.email
FROM customer as c
JOIN address as a
ON c.address_id = a.address_id
JOIN city as ct
ON a. city_id = ct.city_id
JOIN country as co
ON ct.country_id= co.country_id
WHERE co.country = 'Canada';
-- With Subqueries:
SELECT * FROM
(SELECT c.first_name, c.last_name, co.country, a.district as State
FROM customer as c
JOIN address as a
ON c.address_id = a.address_id
JOIN city as ct
ON a. city_id = ct.city_id
JOIN country as co
ON ct.country_id= co.country_id) as sub1
WHERE country = 'Canada';
-- Another way??:
-- SELECT country, first_name, last_name, email FROM
-- (SELECT city_id, country_id FROM city
-- 	WHERE city_id IN
--        (SELECT address_id, city_id FROM address 
--        WHERE address_id IN 
--          (SELECT address_id, first_name, last_name, email FROM customer) as sub1) as sub2) as sub3
--          WHERE country= 'Canada';



-- Which are films starred by the most prolific actor? Most prolific actor is defined as
-- the actor that has acted in the most number of films. First you will have to find the most prolific
-- actor and then use that actor_id to find the different films that he/she starred.
-- Brain storm: actor: actor_id,first_name,last_name
-- film_actor: actor_id, film_id
-- film: film_id, title
-- child subquery:
SELECT actor_id, COUNT(film_id) as "Number of starred films" FROM film_actor
GROUP BY actor_id
ORDER BY COUNT(film_id) desc;

-- Most prolific actor id is: 107 with 42 films.

SELECT title FROM film
WHERE film_id IN (
	SELECT film_id FROM film_actor
	WHERE actor_id = 107);

-- #Films rented by most profitable customer. You can use the customer table and payment table to 
-- find the most profitable customer ie the customer that has made the largest sum of payments
SELECT * from payment;
-- here: customer_id, payment_id,  staff_id, rental_id, amount, payment_date
SELECT * from customer;
-- customer_id, store_id, address_id, first_name, last_name, email
CREATE TEMPORARY TABLE sum_amount_per_customer AS (
SELECT customer_id, SUM(amount) FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC);

SELECT customer_id, first_name, last_name FROM customer
WHERE customer_id IN (
	SELECT customer_id FROM payment
    WHERE customer_id = 526);
-- Most profitable customer is KARL SEAL, customer_id=526 who paid 221.55 bucks.   
SELECT title FROM film
WHERE film_id IN (
	SELECT film_id FROM inventory
    WHERE store_id IN(
		SELECT store_id  FROM customer
        WHERE customer_id=526));
-- #Customers who spent more than the average payments.
SELECT avg(amount) FROM payment;
-- average payment is 4.20 amount.
SELECT customer_id, first_name, last_name FROM customer
WHERE customer_id IN (
	SELECT customer_id FROM payment
    WHERE amount > 4.20);
