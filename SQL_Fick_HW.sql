-- Part 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column `Actor Name`.
-- Run each out individually

UPDATE sakila.actor SET first_name = upper(first_name);
UPDATE sakila.actor SET last_name = upper(last_name);
select concat(first_name, ' ', last_name) AS "Actor Name" from sakila.actor;


-- 2a.  You need to find the ID number, first name, and last name of an actor, of whom you 
-- know only the first name, "Joe." What is one query would you use to obtain this information?

select actor_id, first_name, last_name from sakila.actor

where first_name like 'joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:

select actor_id, first_name, last_name from sakila.actor

where last_name like '%gen%';

-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:

select   last_name, first_name from sakila.actor

where last_name like '%li%';

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:

select country_id, country from sakila.country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing 
-- queries on a description, so create a column in the table `actor` named `description` and 
-- use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between 
-- it and `VARCHAR` are significant).
alter table sakila.actor
	add description blob Null;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the `description` column.
alter table sakila.actor
	drop description;
    
-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, COUNT(*) as count 
from sakila.actor 
group by last_name;
-- 4b.List last names of actors and the number of actors who have that last name, but only 
-- for names that are shared by at least two actors

select last_name, COUNT(*) as count 
from sakila.actor 
group by last_name 
having count > 1
order by count DESC;

-- 4c.The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record.
update sakila.actor 
set first_name = 'HARPO'
where first_name='GROUCHO';

-- 4d.Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` 
-- was the correct name after all! In a single query, if the first name of the actor is currently 
-- `HARPO`, change it to `GROUCHO`.
update sakila.actor 
set first_name = 'GROUCHO'
where first_name='HARPO';

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

describe sakila.address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`:
select address.address_id, address.address, staff.first_name, staff.last_name
from address
inner join staff
on address.address_id = staff.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
-- Use tables `staff` and `payment`.
select staff.first_name, staff.last_name, sum(payment.amount)
from payment
join staff
on payment.staff_id= staff.staff_id
WHERE (payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-08-31 23:59:59')
group by staff.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables 
-- `film_actor` and `film`. Use inner join.

select count(*) as 'Total_Actors', film.film_id, film.title
from film_actor
inner join film
on film_actor.film_id = film.film_id
Group by film_actor.film_id, film.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select count(*) as 'Movie_Count', film.film_id, film.title, inventory.film_id
from film
inner join inventory
on inventory.film_id = film.film_id
where film.title = 'Hunchback Impossible'
Group by inventory.film_id, film.title;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total 
-- paid by each customer. List the customers alphabetically by last name:
select customer.first_name, customer.last_name, sum(payment.amount)
from customer
inner join payment
on customer.customer_id = payment.customer_id
Group by payment.customer_id
order by customer.last_name;

-- 7a.The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also 
-- soared in popularity. Use subqueries to display the titles of movies starting with the 
-- letters `K` and `Q` whose language is English.
select title
from film
where title like 'K%' or title like 'Q%'
 and title in (select title
	from film
	where language_id =1);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

select first_name, last_name
from actor
where actor_id in (
select actor_id
from film_actor
where film_id = (select film_id
    from film
    where title = 'Alone Trip'));
    
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names 
-- and email addresses of all Canadian customers. Use joins to retrieve this information.

select email, first_name, last_name
from customer
join address
on address.address_id = customer.address_id
where address.city_id in (
select city_id
from city
where country_id = 20);

-- 7d. Sales have been lagging among young families, and you wish to target all family movies 
-- for a promotion. Identify all movies categorized as _family_ films.
select title
from film 
join film_category
on film.film_id = film_category.film_id
where film_category.category_id = 8;

-- 7e. Display the most frequently rented movies in descending order.
select title, count(*) as 'total'
from film
join inventory

on inventory.film_id = film.film_id
join rental on inventory.inventory_id = rental.inventory_id
group by title
order by total desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select store_id, sum(payment.amount)
from payment
join staff
on staff.staff_id = payment.staff_id
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city, country
from store
join address
on address.address_id = store.address_id
join city
on address.city_id = city.city_id
join country
on city.country_id = country.country_id;

-- 7h.List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, 
-- inventory, payment, and rental.)
select name, sum(payment.amount) as 'Gross'
from category
join film_category
on film_category.category_id = category.category_id
join inventory
on inventory.film_id = film_category.film_id
join rental
on inventory.inventory_id = rental.inventory_id
join payment
on payment.rental_id = rental.rental_id
group by name order by Gross limit 5;

-- 8a.In your new role as an executive, you would like to have an easy way of viewing the Top five
-- genres by gross revenue. Use the solution from the problem above to create a view. If you haven't 
-- solved 7h, you can substitute another query to create a view.

CREATE VIEW total_Movie_sales AS 
select name, sum(payment.amount) as 'Gross'
from category
join film_category
on film_category.category_id = category.category_id
join inventory
on inventory.film_id = film_category.film_id
join rental
on inventory.inventory_id = rental.inventory_id
join payment
on payment.rental_id = rental.rental_id
group by name order by Gross limit 5;

-- 8b.
SELECT * FROM sakila.total_movie_sales;

-- 8 c. 
DROP VIEW total_Movie_sales;