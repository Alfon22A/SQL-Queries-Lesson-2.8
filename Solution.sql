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

SELECT
	a1.first_name AS "Name1",
    a1.last_name AS "Surname1",
    a2.first_name AS "Name2",
    a2.last_name AS "Surname2"
FROM actor AS a1
LEFT JOIN film_actor as f1
ON a1.actor_id = f1.actor_id
LEFT JOIN film_actor AS f2
ON f1.film_id = f2.film_id
LEFT JOIN actor AS a2
ON f2.actor_id = a2.actor_id
WHERE a1.actor_id != f2.actor_id
ORDER BY Surname1, Name1, Surname2, Name2;

-- 8. Get all pairs of customers that have rented the same film more than 3 times.

WITH CTE AS(
SELECT
	r.customer_id,
    c.first_name AS "Name",
    c.last_name AS "Surname",
    i.film_id, COUNT(i.film_id) AS Rentals
FROM rental AS r
INNER JOIN inventory AS i
ON r.inventory_id = i.inventory_id
INNER JOIN customer AS c
ON r.customer_id = c.customer_id
GROUP BY r.customer_id, i.film_id
HAVING Rentals >1
ORDER BY Rentals DESC
)
SELECT *
FROM CTE AS c1
INNER JOIN CTE AS c2
ON c1.film_id = c2.film_id
WHERE c1.customer_id != c2.customer_id
HAVING c1.Rentals > 1
ORDER BY c1.Rentals DESC, c1.film_id, c1.customer_id;
-- There are no pairs with 3 or more, but there are some with 2 or more.

-- 9. For each film, list actor that has acted in more films.

WITH CTE AS(
SELECT title, film_id, actor_id, Films, Rank() OVER
(PARTITION BY film_id ORDER BY Films DESC) AS "Ranking"
FROM (
	SELECT f.film_id, fa.actor_id, f.title, a.first_name, a.last_name, MAX(Films) AS "Films"
	FROM(
		SELECT actor_id, COUNT(film_id) AS "Films"
		FROM film_actor
		GROUP BY actor_id
		) AS T1
        LEFT JOIN film_actor AS fa
ON T1.actor_id = fa.actor_id
LEFT JOIN actor AS a
ON T1.actor_id = a.actor_id
LEFT JOIN film AS f
ON fa.film_id = f.film_id
GROUP BY fa.film_id, T1.actor_id
) AS T2
)
SELECT title, a.first_name, a.last_name, Films
FROM CTE
INNER JOIN actor AS a
ON CTE.actor_id = a.actor_id
WHERE Ranking = 1;
/* In this case we had to use a subquery of a subquery to make this work,
first we calculated the films for each actor,
then we ranked the actors that worked for each movie,
and finally we picked the highest ranked actor.*/