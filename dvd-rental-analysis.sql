-- DVD Rental Performance Analysis (PostgreSQL / PL/pgSQL)
CREATE OR REPLACE FUNCTION get_rental_status(return_date TIMESTAMP)
RETURNS VARCHAR(20) LANGUAGE plpgsql AS $$
BEGIN
    IF return_date IS NULL THEN RETURN 'Not Returned';
    ELSE RETURN 'Returned'; END IF;
END; $$;

CREATE TABLE detailed_most_rented_movies (
    rental_id INT, rental_date TIMESTAMP, film_id INT, film_title VARCHAR(255),
    category_name VARCHAR(25), store_id INT, customer_id INT,
    customer_full_name VARCHAR(100), rental_year INT, rental_month INT,
    rental_status VARCHAR(20)
);

CREATE TABLE summary_most_rented_movies (
    film_title VARCHAR(255), category_name VARCHAR(25), total_rentals INT,
    unique_customers INT, first_rental_date TIMESTAMP, last_rental_date TIMESTAMP
);

INSERT INTO detailed_most_rented_movies
SELECT r.rental_id, r.rental_date, f.film_id, f.title, c.name, i.store_id,
       cu.customer_id, cu.first_name || ' ' || cu.last_name,
       EXTRACT(YEAR FROM r.rental_date), EXTRACT(MONTH FROM r.rental_date),
       get_rental_status(r.return_date)
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN customer cu ON r.customer_id = cu.customer_id
WHERE r.rental_date >= (SELECT MAX(rental_date) - INTERVAL '3 years' FROM rental);

CREATE OR REPLACE FUNCTION update_summary_most_rented_movies()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM summary_most_rented_movies;
    INSERT INTO summary_most_rented_movies
    SELECT film_title, category_name, COUNT(*), COUNT(DISTINCT customer_id),
           MIN(rental_date), MAX(rental_date)
    FROM detailed_most_rented_movies
    GROUP BY film_title, category_name;
    RETURN NULL;
END; $$;

CREATE TRIGGER trg_update_summary AFTER INSERT ON detailed_most_rented_movies
FOR EACH STATEMENT EXECUTE FUNCTION update_summary_most_rented_movies();

CREATE OR REPLACE PROCEDURE refresh_most_rented_movies_report()
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM detailed_most_rented_movies;
    DELETE FROM summary_most_rented_movies;
    INSERT INTO detailed_most_rented_movies
    SELECT r.rental_id, r.rental_date, f.film_id, f.title, c.name, i.store_id,
           cu.customer_id, cu.first_name || ' ' || cu.last_name,
           EXTRACT(YEAR FROM r.rental_date), EXTRACT(MONTH FROM r.rental_date),
           get_rental_status(r.return_date)
    FROM rental r
    JOIN inventory i ON r.inventory_id = i.inventory_id
    JOIN film f ON i.film_id = f.film_id
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    JOIN customer cu ON r.customer_id = cu.customer_id
    WHERE r.rental_date >= (SELECT MAX(rental_date) - INTERVAL '3 years' FROM rental);
END; $$;

-- pgAgent can schedule: CALL refresh_most_rented_movies_report();
