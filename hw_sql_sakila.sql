USE sakila;
SHOW tables;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b.  Display the first and last name of each actor in a single column name "Actor Name" 
-- in upper case letters. 
SELECT UPPER(CONCAT(first_name, ' ',  last_name)) AS "Actor Name" FROM actor;

-- 2a. To find the ID, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe."
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";

-- 2b.Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE  "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- Order the rows by last name and first name, in that order:

SELECT first_name, last_name FROM actor WHERE last_name LIKE  "%LI%" 
ORDER BY last_name , first_name ;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
select * from country;
SELECT country_id, country FROM country WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
select * from actor;
ALTER TABLE actor
ADD Description BlOB
AFTER last_name;
select * from actor;

-- 3b. Deleting the Description column
ALTER TABLE actor 
DROP COLUMN Description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) as count FROM actor
GROUP BY last_name DESC;

-- -- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS last_name_count
FROM actor
GROUP BY last_name
HAVING last_name_count > 1 ;


-- 4c. HARPO WILLIAMS was accidentally entered  as GROUCHO WILLIAMS, fix the record.
UPDATE actor
SET first_name = "HARPO" 
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- checking how many first_name = groucho is there
SELECT * FROM actor WHERE first_name = 'HARPO';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
SET first_name = 
CASE 
WHEN first_name = 'HARPO' 
THEN 'GROUCHO'
END
WHERE actor_id = 172;
-- using the actor_id to turn off the safe mode
select * from actor WHERE actor_id = 172;


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:

SELECT first_name, last_name, address
FROM staff
INNER JOIN address
ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables 
-- staff and payment.
SELECT * FROM staff;
SELECT * FROM payment;
SELECT staff.first_name, staff.last_name, SUM(payment.amount) as total_sales
FROM payment
INNER JOIN staff
ON payment.staff_id = staff.staff_id
-- WHERE payment_date BETWEEN  2005-08-01 AND 2005-09-01
WHERE payment_date BETWEEN  "2005-08-01" AND "2005-09-01"
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. 
-- Use inner join.
SELECT * FROM film_actor;
SELECT * FROM film;
SELECT  film.title, COUNT(film_actor.actor_id) As number_of_actors
FROM film 
INNER JOIN film_actor 
ON film.film_id = film_actor.film_id
GROUP BY title
ORDER BY number_of_actors desc;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM inventory;
SELECT title, COUNT(inventory.inventory_id) As copies
FROM film 
INNER JOIN inventory  
ON film.film_id = inventory.film_id
WHERE title = "Hunchback Impossible"
GROUP BY film.title;

-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT * FROM payment;
SELECT * FROM customer;
SELECT customer.first_name, customer.last_name, sum(payment.amount) AS total_payment 
FROM customer 
INNER JOIN payment  
ON customer.customer_id = payment.customer_id
GROUP BY customer.first_name, customer.last_name
ORDER BY customer.last_name, customer.first_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q 
-- whose language is English.
select * from language;
SELECT * FROM film;
SELECT title FROM film
WHERE title LIKE "Q%" OR title LIKE "K%"
	AND language_id = (
	SELECT language_id 
	FROM language
	WHERE name = "English" );
    
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT * FROM film;
SELECT * FROM actor;
SELECT * FROM film_actor;

SELECT first_name, last_name FROM actor
WHERE actor_id IN (
	SELECT actor_id FROM film_actor 
    WHERE film_id = (
		SELECT film_id FROM film 
        WHERE title = "Alone Trip"));
        
-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.
select * from country;
select * from city;
SELECT * FROM address;
select * from customer;
SELECT customer.first_name, customer.last_name, customer.email, country.country
FROM customer
INNER JOIN address
    ON customer.address_id = address.address_id
INNER JOIN city
    ON address.city_id = city.city_id
INNER JOIN country
    ON city.country_id = country.country_id
WHERE country.country = "Canada";

-- 7d. Sales have been lagging among young families, 
-- and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select * from film;
select * from film_category;
select * from film_text;
select * from category;
SELECT film.title, category.name
FROM film
INNER JOIN film_category
    ON film.film_id = film_category.film_id
INNER JOIN category
    ON film_category.category_id = category.category_id
WHERE category.name = "Family";

-- 7e. Display the most frequently rented movies in descending order.
select * from film;
select * from rental;
select * from inventory;
SELECT film.title, COUNT(rental.inventory_id) As rental_count
FROM film
INNER JOIN inventory
    ON film.film_id = inventory.film_id
INNER JOIN rental
    ON inventory.inventory_id = rental.inventory_id
GROUP BY film.title
ORDER BY rental_count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from customer;
select * from payment;
select * from store;
SELECT s.store_id, SUM(amount) AS Gross_Amount
FROM payment p
INNER JOIN rental r
ON (p.rental_id = r.rental_id)
INNER JOIN inventory i
ON (i.inventory_id = r.inventory_id)
INNER JOIN store s
ON (s.store_id = i.store_id)
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT * FROM store;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;
SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN address
ON store.address_id = address.address_id
INNER JOIN city 
ON address.city_id = city.city_id
INNER JOIN country 
ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables:
-- category, film_category, inventory, payment, and rental.)
SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM inventory;
SELECT * FROM payment;
select * from rental;
SELECT c.name As Genre, SUM(p.amount) As gross_revenue
FROM payment p
INNER JOIN rental r
ON (p.rental_id = r.rental_id)
INNER JOIN inventory i
ON (r.inventory_id = i.inventory_id)
INNER JOIN film_category fc
ON (i.film_id = fc.film_id)
INNER JOIN category c
ON (fc.category_id = c.category_id)
GROUP BY c.name
ORDER BY SUM(amount) DESC
LIMIT 5;

-- 8a. In your new role as an executive, 
-- you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view
CREATE VIEW top5_genre_gross_revenue AS
SELECT c.name As Genre, SUM(p.amount) As gross_revenue
FROM payment p
INNER JOIN rental r
ON (p.rental_id = r.rental_id)
INNER JOIN inventory i
ON (r.inventory_id = i.inventory_id)
INNER JOIN film_category fc
ON (i.film_id = fc.film_id)
INNER JOIN category c
ON (fc.category_id = c.category_id)
GROUP BY c.name
ORDER BY SUM(amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top5_genre_gross_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW IF EXISTS top5_genre_gross_revenue;















	













