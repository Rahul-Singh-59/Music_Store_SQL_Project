-- Q1 - Senior most employee by title - ( Madan Mohan )
select employee_id, first_name, last_name,title from employee
order by levels desc
limit 3

-- Q2 - Top Country with most orders - (USA)
select count(invoice_id)as total_invoices , billing_country from invoice
group by billing_country
order by total_invoices desc
limit 1

-- Q3 Top 3 values of total invoices -(23.75,,19.8,,19.8)
select sum(total) as top_invoices  from invoice
group by invoice_id
order by top_invoices desc
limit 3

-- Q4 Top city with best customer - ( Prague )
select count(invoice_id) as total_invoices ,billing_city from invoice
group by billing_city
order by total_invoices desc
limit 1

-- Q5 Best customer ( cust_id - 5 )
select c.customer_id ,count(c.customer_id) as orders,sum(i.total) as total_value
from customer as c
join invoice as i
on c.customer_id=i.customer_id
group by 1
order by total_value desc
limit 3

-- Q6 Rock music listeners ( Aaron mitchel ...... wyatt girard )
select customer.email, customer.first_name, customer.last_name
from customer 
join invoice on customer.customer_id = invoice.customer_id 
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
order by email 

-- Q7 top 10 Artist total tracks created on rock genre ( Led Zeppelin [114] ..... Kiss[35])
select artist.name,count(track.track_id) as total_tracks
from artist
join album on artist.artist_id = album.artist_id
join track on track.album_id = album.album_id
join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
group by artist.name
order by total_tracks desc
limit 10

-- Q8 Tracks having more than avg duration ( Occupation/precipice...... wicked ways )
select name,milliseconds
from track
where milliseconds > (
	select avg(milliseconds) as avg_track_duration from track
	)
order by milliseconds desc

-- Q9 total amount spent by each customer on most sellig artist ( Artist Queen )
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- Q10 Most selling genre for each country ( Alternative & Punk ...... Rock )

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

--Q11 Top customer by country with highest spent ( Diego Gutierrez..... Jack Smith
WITH Customer_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,
        SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC)
SELECT * FROM Customer_with_country WHERE RowNo <= 1