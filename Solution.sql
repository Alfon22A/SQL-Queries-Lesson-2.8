-- 1. Write a query to display for each store its store ID, city, and country.

USE sakila;

SELECT s.store_id AS "Store", ci.city AS "City", co.country AS "Country"
FROM store AS s
LEFT JOIN address AS a
ON s.address_id = a.address_id
LEFT JOIN city AS ci
ON a.city_id = ci.city_id
LEFT JOIN country AS co
ON ci.country_id = co.country_id;

-- 2. Write a query to display how much business, in dollars, each store brought in.

SELECT s.store_id AS "Store", SUM(p.amount) AS "Business"
FROM staff AS s
LEFT JOIN payment AS p
ON s.staff_id = p.staff_id
GROUP BY Store
ORDER BY Business DESC;

-- 3. Which film categories are longest?

SELECT c.name AS "Category", AVG(fi.length) AS "Avg_Duration"
FROM category AS c
LEFT JOIN film_category AS fc
ON c.category_id = fc.category_id
LEFT JOIN film AS fi
ON fc.film_id = fi.film_id
GROUP BY Category
ORDER BY Avg_Duration DESC;

-- 4. Display the most frequently rented movies in descending order.

SELECT f.title AS "Title", COUNT(r.rental_id) AS "Times_rented"
FROM film AS f
LEFT JOIN inventory AS i
ON f.film_id = i.film_id
LEFT JOIN rental AS r
ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY Times_rented DESC;

-- 5. List the top five genres in gross revenue in descending order.

SELECT c.name AS "Category", SUM(p.amount) AS "Gross_revenue"
FROM category AS c
LEFT JOIN film_category AS f
ON c.category_id = f.category_id
LEFT JOIN inventory AS i
ON f.film_id = i.film_id
LEFT JOIN rental AS r
ON i.inventory_id = r.inventory_id
LEFT JOIN payment AS p
ON r.rental_id = p.rental_id
GROUP BY Category
ORDER BY Gross_revenue DESC;

-- 6. Is "Academy Dinosaur" available for rent from Store 1?

SELECT i.store_id AS "Store", IF((f.title = "Academy Dinosaur"), "Yes", "No") AS "Academy_Dinosaur"
FROM film AS f
INNER JOIN inventory AS i
ON f.film_id = i.film_id
GROUP BY Store;

SELECT i.store_id AS "Store", COUNT(f.title) AS "Academy_Dinosaur"
FROM film AS f
INNER JOIN inventory AS i
ON f.film_id = i.film_id
WHERE (f.title = "Academy Dinosaur") AND (i.store_id = 1);

-- 7. Get all pairs of actors that worked together.

SELECT a1.first_name AS "Name1", a1.last_name AS "Surname1", a2.first_name AS "Name2", a2.last_name AS "Surname2"
FROM film_actor AS f1
LEFT JOIN film_actor AS f2
ON f1.film_id = f2.film_id
INNER JOIN actor AS a1
ON f1.actor_id = a1.actor_id
INNER JOIN actor AS a2
ON f2.actor_id = a2.actor_id
WHERE (f1.film_id = f2.film_id) AND (f1.actor_id != f2.actor_id) AND (a1.actor_id NOT IN (SELECT a2.actor_id))
ORDER BY Surname1, Name1, Surname2, Name2;

-- 8. Get all pairs of customers that have rented the same film more than 3 times.

SELECT f.title AS "Title", c.first_name AS "Name", c.last_name AS "Surname", COUNT(r.inventory_id) AS Rentals
FROM customer AS c
INNER JOIN rental AS r
ON c.customer_id = r.customer_id
INNER JOIN inventory AS i
ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
ON i.film_id = f.film_id
GROUP BY i.film_id, c.customer_id
HAVING Rentals >= 3
ORDER BY Title, Rentals;

-- 9. For each film, list actor that has acted in more films.

SELECT
	f.title AS "Title",
	a.first_name AS "Name",
    a.last_name AS "Surname",
    COUNT(fa.film_id) OVER (PARTITION BY fa.actor_id) AS "Films"
FROM film_actor AS fa
INNER JOIN actor AS a
ON fa.actor_id = a.actor_id
INNER JOIN film AS f
ON fa.film_id = f.film_id
GROUP BY f.film_id;