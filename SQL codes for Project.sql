Q1. We want to understand more about the movies that families are watching. The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.

Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.

-- Knowing the number of times a particular family category of film was rented

WITH t1 AS

	(SELECT f.film_id film_id, f.title film_title, c.category_id cat_id, c.name film_cat
		FROM film f
			JOIN film_category f_c
			ON f.film_id = f_c.film_id
			JOIN category c
			ON c.category_id = f_c.category_id
		where c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))

	SELECT film_title, film_cat film_category, count(r.rental_id) rental_count
		FROM t1
			JOIN inventory i
			ON t1.film_id = i.film_id
			JOIN rental r
			ON r.inventory_id = i.inventory_id
		GROUP BY 1,2
		ORDER BY 2,1

-- Comparing all categories to know which category families loves the most

WITH t1 AS

	(SELECT f.film_id film_id, f.title film_title, c.category_id cat_id, c.name film_cat
		FROM film f
			JOIN film_category f_c
			ON f.film_id = f_c.film_id
			JOIN category c
			ON c.category_id = f_c.category_id
		where c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')),

	t2 AS

		(SELECT film_title, film_cat film_category, count(r.rental_id) rental_count
			FROM t1
				JOIN inventory i
				ON t1.film_id = i.film_id
				JOIN rental r
				ON r.inventory_id = i.inventory_id
			GROUP BY 1,2
			ORDER BY 2,1)

	SELECT  film_category, SUM(rental_count)  count_by_category
		FROM t2 
		group by 1
		order by 2 desc
		

Q2. Finally, provide a table with the family-friendly film category, each of the quartiles, and the corresponding count of movies within each combination of film category for each corresponding rental duration category.
	
	SELECT category_name, standard_quartile, COUNT(*) AS total_count
		FROM(
			SELECT f.title film_title, c.name category_name, f.rental_duration, 
					NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
				FROM film f
					JOIN film_category fc
					ON f.film_id = fc.film_id
					JOIN category c
					ON c.category_id = fc.category_id
				WHERE c.name IN ('Animation','Children','Classics','Comedy','Family','Music'))sub
		GROUP BY 1, 2
		ORDER BY 1


Q3. We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for. Write a query that returns the store ID for the store, the year and month and the number of rental orders each store has fulfilled for that month. Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during that month.

	SELECT DATE_PART('year', rental_date) rented_year, DATE_PART('month', rental_date) rented_month, 
			s.store_id store_id, count(r.rental_id) rental_count
		FROM rental r
			JOIN staff sf
			ON r.staff_id = sf.staff_id
			JOIN store s
			ON s.store_id = sf.store_id
		GROUP BY 1,2,3
	    ORDER BY 3 -- Order by the store_id, so i can easily separate figures for each store rentals and compare it aginst the year


 Q4. We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and what was the amount of the monthly payments. Can you write a query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers?

 	SELECT concat(first_name,' ',last_name) fullname, date_trunc('month', p.payment_date) as date,
					 	 sum(p.amount) total_monthly_amount, count(r.rental_id) rental_monthly_count
			FROM customer c
				JOIN payment p
				ON c.customer_id = p.customer_id
				JOIN rental r
				ON r.rental_id = p.rental_id
			WHERE c.customer_id IN
				 	(SELECT customer_id
				 		FROM(
				 		SELECT c.customer_id, concat(first_name,' ',last_name) fullname,  sum(p.amount) amount
						FROM customer c
							JOIN payment p
							ON c.customer_id = p.customer_id
						GROUP BY 1,2
						ORDER BY 3 desc
						LIMIT 10)sub) 
				 AND p.payment_date BETWEEN '2007-01-01' and '2007-12-31'
		GROUP BY 1, 2
        ORDER By 1, 2

-- Extracting a general aggregated value for graphical representation 
 
WITH agg AS
		(SELECT concat(first_name,' ',last_name) fullname, date_trunc('month', p.payment_date) as date,
					 	 sum(p.amount) total_monthly_amount, count(r.rental_id) rental_monthly_count
			FROM customer c
				JOIN payment p
				ON c.customer_id = p.customer_id
				JOIN rental r
				ON r.rental_id = p.rental_id
			WHERE c.customer_id IN
				 	(SELECT customer_id
				 		FROM(
				 		SELECT c.customer_id, concat(first_name,' ',last_name) fullname,  sum(p.amount) amount
						FROM customer c
							JOIN payment p
							ON c.customer_id = p.customer_id
						GROUP BY 1,2
						ORDER BY 3 desc
						LIMIT 10)sub) 
				 AND p.payment_date BETWEEN '2007-01-01' and '2007-12-31'
		GROUP BY 1, 2
        ORDER By 1, 2)

 	SELECT fullname, SUM(total_monthly_amount) total_monthly_pay, SUM(rental_monthly_count) total_count
 		FROM agg
 		GROUP BY 1
 		ORDER BY 1

