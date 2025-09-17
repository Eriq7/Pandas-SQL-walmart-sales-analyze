-- What are the different payment methods, and how many transactions 
-- and items were sold with each method?
select payment_method, count(invoice_id) as number_of_sales
from walmart
group by 1

-- Which category received the highest average rating in each branch?
select * from
	(SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		rank()over(partition by branch order by AVG(rating) DESC)
	FROM walmart
	GROUP BY 1, 2)
	where rank = 1
	
-- What is the busiest day of the week for each branch based on transaction volume?
select * from
(select 
	branch,
	TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
	count(invoice_id) as transaction_volume,
	rank() over (partition by branch order by count(invoice_id) desc)
from walmart
group by 1,2
)
where rank = 1

-- How many items were sold through each payment method?
select payment_method,sum(quantity)
from walmart
group by 1

-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

select city, avg(rating),min(rating),max(rating)
from walmart
group by 1

-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.
select 
	category,
	sum(unit_price * quantity * profit_margin) as total_profit
	from walmart
	group by 1
	order by 2 DESC
	
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
select * from(
select 
	branch,
	payment_method,
	count(*),
	rank() over(partition by branch order by count(*) desc)
	from walmart
	group by 1,2)
where rank = 1
	
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices
select
CASE
	when EXTRACT(hour from time::time) < 12 then 'MORNING'
	when EXTRACT(hour from time::time) between 12 and 17 then 'AFTERNOON'
	else 'EVENING'
	end case,
count(*)
from walmart
group by 1
order by 2 DESC
-- Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)
-- rdr == last_rev-cr_rev/ls_rev*100
select * from walmart
with revenue_2022
as
(select branch, 
sum(total_price)
from walmart
where (extract(year from date::date)) = 2022
group by 1

)
-- this small query change the date from DDMMYY to MMDDYY
SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total_price) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 

	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total_price) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5


