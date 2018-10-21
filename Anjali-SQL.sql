use sakila;

select count(*) from city ;

-- 1a. Display the first and last names of all actors from the table actor.

select  first_name , last_name  from actor ;

--  1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

select   CONCAT(first_name  ,'  ',last_name) as   'Actor Name' 
	from actor ;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select actor_id ,first_name , last_name 
			from actor where first_name = "Joe";
            
 -- 2b. Find all actors whose last name contain the letters GEN:           
select * from actor
	where last_name like  '%GEN%' ;
 
 -- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor 
	where last_name like  '%LI%' order by  last_name,first_name ;
  
  -- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id , country  from country
		where country in ("Afghanistan", "Bangladesh", "China") ;
  
  -- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
  -- so create a column in the table actor named description and use the data type BLOB 
  -- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
  
Alter table actor add description mediumblob ;

desc actor ;
  
  -- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
Alter table actor  
	drop  column description;
  
  
  -- 4a. List the last names of actors, as well as how many actors have that last name.
select  last_name ,count(*) as total_count  
	from actor group by last_name  ;
  
  
  -- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors.
select last_name , total_count from   
	( select  last_name ,count(*) as total_count  from actor  group by last_name ) a  where a.total_count>=2 ;


-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update  actor set  first_name =  "HARPO"  
	where first_name  = "GROUCHO" and last_name = "Williams" ;


select * from actor where first_name  = "GROUCHO" and last_name = "Williams" ;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.
update  actor set  first_name =  "GROUCHO"  
	where first_name  = "HARPO" ;


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

CREATE TABLE IF NOT EXISTS address  (
  address_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT UNSIGNED NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL, 
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (address_id),
  KEY idx_fk_city_id (city_id),
  CONSTRAINT `fk_address_city` FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

									

--   6a Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

Select first_name,last_name,address
	From staff s  left join address a
	On s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
Select S.first_name,S.last_name, S.staff_id, Sum(P.amount) As total_amount
From staff  S right join payment P
On S.staff_id = P.staff_id
Where P.payment_date like'2005-08%'
Group by P.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

Select f.title, Count(fa.actor_id) As  num_actoors
From film  f Join film_actor fa
On f.film_id = fa.film_id
Group by f.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

Select f.title,Count(i.inventory_id)
From film  f join inventory i
On f.film_id = i.film_id
Where title = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
-- Total amount paid](Images/total_payment.png)

Select  c.first_name,c.last_name,Sum(p.amount) As total_paid
From customer  c left join payment  p
On c.customer_id = p.customer_id
Group by c.first_name,c.last_name
Order by c.last_name;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

Select title From film
Where language_id  IN(
                                     Select language_id 
								     From language 
									 Where name = 'English') ;
-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
 
 Select first_name, last_name 
 From actor
 Where actor_id in (Select actor_id 
                                 From film_actor
                                 Where film_id in (
                                                       Select film_id From film
                                                       Where title = 'Alone Trip'));
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
--  Use joins to retrieve this information.

Select last_name,first_name, email 
From customer inner join address
On customer.address_id = address.address_id
inner join  city On address.city_id = city.city_id
inner join country On city.country_id = country.country_id
Where country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

-- Join Query

Select title From film f Join film_category fc
On f.film_id = fc.film_id
Join category c
On fc.category_id = c.category_id
Where c.name ='Family'; 

#Sub-Query
Select title 
From film f
Where film_id IN
                        (Select film_id 
                         From film_category fc
					     Where category_id IN
                                                         (Select category_id 
														   From category
													                           Where name ='Family'));
                                                                               
-- 7e. Display the most frequently rented movies in descending order.


Select title , Count(rental.inventory_id) As times_rented
From film Join inventory
On film.film_id = inventory.film_id 
Join rental On inventory.inventory_id= rental.inventory_id
Group by title Order by times_rented desc, title asc;                                                                              


-- 7f. Write a query to display how much business, in dollars, each store brought in.

Select s.store_id, Sum(amount) As sum_amount_perstore
From store s
Join staff sf On s.store_id = sf.store_id
Join payment p On sf.staff_id = p.staff_id
Group by s.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.


Select store_id,city,country
From store  s  Join address a On s.address_id = a.address_id
Join city c On a.city_id = c.city_id
Join country cn On c.country_id = cn.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

Select name,sum(p.amount) As revenue_gross
From category c join film_category fc
On c.category_id = fc.category_id
Join inventory i On i.film_id = fc.film_id 
Join rental r On i.inventory_id =r.inventory_id
Join payment p On p.rental_id = r.rental_id
Group by name Order by revenue_gross desc Limit 5;


--  8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

Drop view if exists top_revenue_genres;

Create view top_revenue_genres As

Select name,sum(p.amount) As revenue_gross
From category c Join film_category fc
On c.category_id = fc.category_id
Join inventory  i On i.film_id = fc.film_id 
Join rental r On i.inventory_id =r.inventory_id
Join payment p On p.rental_id = r.rental_id
Group by name Order by revenue_gross desc  Limit 5;


-- 8b. How would you display the view that you created in 8a?


Select * From top_revenue_genres;


-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.


Drop  view top_revenue_genres;
