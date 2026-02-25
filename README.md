# SQL-Business-Performance-Analysis
This project uses SQL to analyse website and e-commerce performance data.

## Project Overview
The project focuses on key business metrics, including traffic, click-through rate, cross-sell, conversion rate, revenue, and customer behaviour. It demonstrates how raw transactional and session data can be transformed into actionable insights to support business and operational decision-making.

This project reflects the practical responsibilities of a data analyst role, including data validation, performance reporting, and insight generation. It demonstrates how structured SQL analysis can be used to support stakeholders and inform evidence-based decision-making

## Project Objectives
- Create a structured MySQL database for Mavenfuzzy records.
- Analyse quarterly session and order volume to measure long-term business growth.
- Evaluate quarterly efficiency metrics, including conversion rate, revenue per order, and revenue per session, to assess performance improvements.
- Track quarterly order growth across key acquisition channels to understand marketing effectiveness.
- Compare quarterly conversion trends by channel and identify periods of major optimisation or improvement.
- Examine monthly revenue and margin by product to assess performance and identify seasonal patterns.
- Measure engagement and conversion from the products page to evaluate the impact of product discovery.
- Analyse post-2014 cross-sell performance to understand how effectively products drive additional sales.

### Technologies Used
- **SQL**

## Data Dictionary
The MavenFuzzyFactory database consists of six main tables: website_sessions, which records each user visit and its traffic source; website_pageviews, which tracks every page a user views within a session; orders, which stores completed purchases; order_items, which details the individual products within each order along with pricing and costs; order_item_refunds, which captures refunded items and amounts; and products, which contains the product catalogue and related information.

## SQL analysis & Queries
#### 1. First, I’d like to show our volume growth. Can you pull the overall session and order volume, trended by quarter, for the life of the business? Since the most recent quarter is incomplete.
```sql
SELECT
	YEAR(website_sessions.created_at) AS yr,	-- Year from website session table.
	QUARTER(website_sessions.created_at) AS qtr,	-- Month from website session table.
	  COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
	  COUNT(DISTINCT orders.order_id) AS total_orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1, 2
ORDER BY 1, 2;
```
*First quarter of 2012 had 60 orders, fourth quarter of 2014 had 5908 orders. Showing orders increased by approximately **9,747%**.*

#### 2. Next, let’s showcase all of our efficiency improvements. I'd love to show quarterly figures since we launched, for session-to-order conversion rate, revenue per order, and revenue per session. 
```sql
SELECT
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr,
	  COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_Convr,	-- A distinct count of conversion rate, website to order.
	  SUM(orders.price_usd)/Count(DISTINCT orders.order_id) AS order_rate,	-- Revenue per order growth
	  SUM(orders.price_usd)/Count(DISTINCT website_sessions.website_session_id) AS Session_rate	-- Revenue per session growth

FROM website_sessions
  LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;
```
*Conversion rate increased from **0.0320 (0.3%)** in Q1 2012 to **0.0844 (0.8%)** in Q1 2015. Revenue per order also rose from £50 in 2012 (when only one product was sold) to £63 in 2015 (with four products available). Similarly, revenue per session grew significantly, increasing from £1.59 in Q1 2012 to £5.31 in 2015, reflecting great overall improvements in sales performance.*

#### 3. I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?
```sql
SELECT
    YEAR(website_sessions.created_at) as yr,
    QUARTER(website_sessions.created_at) as Qtr,
      COUNT(DISTINCT CASE WHEN  utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand, -- Filtering order_id for gsearch and nonbrand intersection.
      COUNT(DISTINCT CASE WHEN  utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand, -- Filtering order_id for bsearch and nonbrand intersection.
      COUNT(DISTINCT CASE WHEN  utm_campaign = 'brand' then orders.order_id ELSE NULL END) AS brand_search_overall, -- Filtering order_id for brand.
      COUNT(DISTINCT CASE WHEN  utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS organic_search, -- Filtering order_id for utmsource and referer.
      COUNT(DISTINCT CASE WHEN  utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS direct_typein	-- Filtering order_id for utmsource and non-referer.

FROM website_sessions
  LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2
```
- *In Q3 2012, gsearch nonbrand orders (482) far exceeded bsearch nonbrand orders (82), reflecting a **6:1** ratio and highlighting a strong dependence on paid campaigns. Organic engagement was relatively low at the time, with only 32 direct type-in orders.*

- *By Q4 2014, this ratio had declined to **2:1**, with brand search orders (615), organic search orders (605), and direct type-in traffic rising to 532. This shift indicates reduced reliance on paid advertising and increased strength in organic and direct traffic channels.*

#### 4.  Next, let’s show the overall session-to-order conversion rate trends for those same channels, by quarter. Please also make a note of any periods where we made major improvements or optimisations.
```sql
SELECT
	YEAR(website_sessions.created_at) as yr,
	QUARTER(website_sessions.created_at) as tr,
		COUNT(DISTINCT CASE WHEN  utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)
			/COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_convr,
		COUNT(DISTINCT CASE WHEN  utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)
			/COUNT(DISTINCT CASE WHEN  utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_convr,
		COUNT(DISTINCT CASE WHEN  utm_campaign = 'brand' THEN orders.order_id else null end)
			/COUNT(DISTINCT CASE WHEN  utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS brand_convr,
		COUNT(DISTINCT CASE WHEN  utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END)
			/COUNT(DISTINCT CASE WHEN  utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id  ELSE NULL END) AS organic_convr,
		COUNT(DISTINCT CASE WHEN  utm_source IS NULL AND  http_referer IS NULL THEN orders.order_id ELSE NULL END)
			/COUNT(DISTINCT CASE WHEN  utm_source IS NULL AND  http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_convr

FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2
```
- *gsearch nonbrand conversion rate increased from 0.0324 in Q1 2012 to 0.0861 in Q1 2015, representing a 165.7% increase.*
- *bsearch nonbrand conversion rate rose from 0.0409 in Q3 2012 to 0.0850 in Q1 2015, showing a 107.9% increase.*
- *brand search conversion rate grew from 0.0536 in Q2 2012 to 0.0852 in Q1 2015, reflecting a 58.9% increase.*
- *organic search conversion rate increased from 0.0359 in Q2 2012 to 0.0821 in Q1 2015, showing a 128.7% increase.*
- *direct type-in conversion rate improved from 0.0536 in Q2 2012 to 0.0775 in Q1 2015, representing a 44.6% increase.*

#### 5. We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
```sql
SELECT 
	YEAR(created_at) AS yr,
	MONTH(created_at) AS mth, 
		SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy,
		SUM(CASE WHEN  product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS margin_mrfuzzy,
		SUM(CASE WHEN  product_id = 2 THEN price_usd ELSE NULL END) as Love_bear,
		SUM(CASE WHEN  product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS M_Love_bear,
		SUM(CASE WHEN  product_id = 3 THEN price_usd ELSE NULL END) as Sugar_panda,
		SUM(CASE WHEN  product_id = 3 THEN price_usd - cogs_usd ELSE NULL END)  AS M_Sugar_panda,
		SUM(CASE WHEN  product_id = 4 THEN price_usd ELSE NULL END) as river_mini,
		SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS M_river_mini,
		SUM(price_usd) AS total_revenue,
		SUM(price_usd - cogs_usd) AS total_margin
FROM order_items
GROUP BY 1,2
ORDER BY 1,2
```
- *In Q4 2012, with only one product available, total revenue reached **£30,893**, and margin revenue was **£18,849**. By Q4 2014, following the expansion to four products, total revenue had increased significantly to **£144,823**, while margin revenue rose to **£91,857**, reflecting strong business growth and improved profitability.*

#### 6. Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to the products page, and show how the % of those sessions clicking through another page has changed over time, along with a view of how conversion from products to placing an order has improved.
```sql
-- IDENTIFYING THE VIEWS OF THE PRODUCT PAGE
CREATE TEMPORARY TABLE product_pageviews
SELECT
	website_pageview_id,
    website_session_id,
    created_at AS Saw_product_page_at
FROM website_pageviews
WHERE pageview_url = '/products';

SELECT * FROM product_pageviews; -- VIEW PRODUCT PAGEVIEWS TABLE, UNDERSTANDING THE TABLE DIMENSION

SELECT 
	YEAR(Saw_product_page_at) AS yr,
    MONTH(Saw_product_page_at) AS mth,
      COUNT(DISTINCT product_pageviews.website_session_id) AS session_to_product,
      COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_page,
      COUNT(DISTINCT website_pageviews.website_session_id)/ COUNT(DISTINCT product_pageviews.website_session_id) AS click_through_rate,
      COUNT(DISTINCT orders.order_id) AS orders,
      COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT product_pageviews.website_session_id) AS product_order_convr
FROM product_pageviews
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = product_pageviews.website_session_id
AND website_pageviews.website_pageview_id > product_pageviews.website_pageview_id
LEFT JOIN orders
ON orders.website_session_id = product_pageviews.website_session_id

GROUP BY 1,2
```
- *At the start of the business in Q1 2012, the click-through rate was **0.71 (71%)**, which increased to **0.8560 (85.6%)** by Q3 2015, indicating improved user engagement over time.*
- *At the product-to-order rate rose from **0.0081 (0.8%)** in Q1 2012 to **0.0139 (1.3%)** in Q3 2015, reflecting a steady improvement in product purchase performance.*

#### 7. 7. We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item). Could you please pull sales data since then, and show how well each product cross-sells with the others?
```sql
CREATE TEMPORARY TABLE primary_products
SELECT
	order_id
    primary_product_id,
    created_at AS ordered_at
    FROM orders
    WHERE created_at > 2014-12-05; -- SPECIFIED DATE OF 4TH PRODUCT AVAILABILITY

SELECT
	primary_product_id,
		COUNT(DISTINCT order_id) AS total_orders,
		COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END) AS xsold_p1,
		COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END) AS xsold_p2,
		COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END) AS xsold_p3,
		COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END) AS xsold_p4,
		COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS xsold_p1_rt,
		COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS xsold_p2_rt,
		COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS xsold_p3_rt,
		COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id) AS xsold_p4_rt

FROM (
SELECT
	primary_products.*, 
    order_items.product_id AS cross_sell_product_id
FROM primary_products
	LEFT JOIN order_items 
		ON order_items.order_id = primary_products.order_id
        AND order_items.is_primary_item = 0 -- RETURN ONLY CROSS SELL PRODUCTS
) AS primary_x_cross_sell
GROUP BY 1
```

- *The cross-sell analysis shows that Product 1 (P1) was most frequently cross-sold with Product 4 (P4), recording 933 cross-sales. The cross-sell rate also reflected a consistent pattern, with P1 and P4 showing a rate of **0.208 (21%)**. Similar relationships were observed between P1 and P2 and P3, and vice versa.*
*Note: The cross-sell matrix is hollow, as a product cannot be cross-sold with itself (e.g., P1 cannot be cross-sold with P1)*


## Conclusion
Overall, the analysis shows strong business growth and operational improvement over time. The company experienced significant increases in revenue, margin, conversion rates, and customer engagement across all channels. Performance improvements were driven by better conversion efficiency, reduced reliance on paid campaigns, stronger organic and direct traffic, and the expansion from one to multiple products. Additionally, cross-selling strategies contributed to higher order value and product performance.

