--DVD Rental Dataset Exploration--


--What are the most rented movies with their rental rates and total sales--

with t1 as (
			select film.film_id,film.title,film.rental_rate,count (distinct rental.rental_id) as TotalRent
			from film
				join inventory 
				using(film_id)
				join rental
				using(inventory_id)
				group by film_id
				order by TotalRent desc
			),
t2 as		(
			select film.film_id,film.title, sum(payment.amount) as Total_Sales
			from film
			join inventory
			using(film_id)
			join rental
			using (inventory_id)
			join payment
			using(rental_id)
			group by film_id
			)
			select t1.title,t1.TotalRent,t1.rental_rate,t2.Total_Sales
			from t1
		 	join t2
		 	using (film_id)
		order by t1.TotalRent desc

--What are the top and least rented genres in United States?--

--creating temp table--
drop table if exists temp_custadd;
create temp table temp_custadd (customer_id int,address varchar(250),city varchar(250),country varchar(250))

--insertig data to temp table--
insert into temp_custadd (
		select cus.customer_id,ad.address,city.city,country.country
		from customer as cus
					join address as ad	
					using (address_id)
					join city 
					using (city_id)
					join country
					using (country_id)
					)
---Counnting distinc rental ID in US--
select cat.name,count (distinct rental.rental_id) as TotalRentinUS
from category as cat
			join film_category 
			using(category_id)
			join film
			using(film_id)
			join inventory
			using(film_id)
			join rental
			using(inventory_id)
			join temp_custadd
			using (customer_id)
where temp_custadd.country = 'United States'
			group by cat.category_id
			order by 1,2


--FInd the information,shortest,longgest, and avg rental time of customers with customer_id 356 from rental date to return date--

with t1 as(
select customer_id,rental_id,rental_date,return_date,age(return_date,rental_date)as rentaltime
from rental
		where customer_id='356'
			)
select concat(customer.first_name,' ',customer.last_name)as fullname ,add.address,
	   min(t1.rentaltime)as shortestrenttime,max(t1.rentaltime)as longgestrentaltime,avg(t1.rentaltime) as avgrenttime
from  customer 

		join address as add
		using (address_id)
		join t1
		using (customer_id)
	where customer_id = '356'
		group by customer_id,add.address


--Group films by their rental_cost as 'Cheap','Average',and 'Expensive' and count how many movies in each group--


with t1 as (
select title,rental_rate,
	case
	when rental_rate <2 then 'Cheap'
	when rental_rate <3 then 'Average'
	else  'Expensive'
	end as rental_cost
from  film
order by title
			)
select distinct (rental_cost),count (title) over (partition by rental_cost) as movies_count
from t1

--Count the total Movies made by each actor--

select act.actor_id,concat(first_name,' ',last_name) as fullname,count(film.title) as total_movies
from actor as act
inner join film_actor 
on film_actor.actor_id = act.actor_id
inner join film
on film_actor.film_id = film.film_id
group by act.actor_id
order by total_movies desc

--Find the Most rented Movies by customers--

select count(rental.customer_id) as no_rentals,film.title
from rental
inner join inventory as inv
on rental.inventory_id = inv.inventory_id
inner join film
on inv.film_id = film.film_id
group by film.title
order by no_rentals desc

