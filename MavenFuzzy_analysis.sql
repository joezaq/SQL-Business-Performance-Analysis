USE mavenfuzzyfactory;

/*
1. First, I’d like to show our volume growth. Can you pull overall session and order volume, 
trended by quarter for the life of the business? Since the most recent quarter is incomplete, 
you can decide how to handle it.
*/ 

SELECT
	YEAR(website_sessions.created_at) as yr, 			-- Year from website session table.
	QUARTER(website_sessions.created_at) as qtr,		-- Month from website session table
	COUNT(DISTINCT website_sessions.website_session_id) as total_sessions,
	COUNT(DISTINCT orders.order_id) as total_orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1, 2
ORDER BY 1, 2;

/*
2. Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures 
since we launched, for session-to-order conversion rate, revenue per order, and revenue per session. 

*/

SELECT
	YEAR(website_sessions.created_at) as yr,
	QUARTER(website_sessions.created_at) as qtr,
	COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) as session_to_order_Convr, -- A distinct count of conversion rate, website to order.
	SUM(orders.price_usd)/Count(DISTINCT orders.order_id) as order_rate, -- Revenue per order growth
	SUM(orders.price_usd)/Count(DISTINCT website_sessions.website_session_id) as Session_rate -- Revenue per session growth

FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;


/*
3. I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders 
from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in?
*/

SELECT
YEAR(website_sessions.created_at) as yr,
QUARTER(website_sessions.created_at) as Qtr,
COUNT(DISTINCT CASE WHEN  utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand, -- Filtering order_id for gsearch and nonbrand intersection.
COUNT(DISTINCT CASE WHEN  utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand, -- Filtering order_id for bsearch and nonbrand intersection.
COUNT(DISTINCT CASE WHEN  utm_campaign = 'brand' then orders.order_id ELSE NULL END) AS brand_search_overall, -- Filtering order_id for brand.
COUNT(DISTINCT CASE WHEN  utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS organic_search, -- Filtering order_id for utmsource and referer.
COUNT(DISTINCT CASE WHEN  utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS direct_typein -- Filtering order_id for utmsource and non-referer.

FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

/*
4. Next, let’s show the overall session-to-order conversion rate trends for those same channels, 
by quarter. Please also make a note of any periods where we made major improvements or optimizations.
*/

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
ORDER BY 1,2;


/*
5. We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue 
and margin by product, along with total sales and revenue. Note anything you notice about seasonality.
*/


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
ORDER BY 1,2;

/*
6. Let’s dive deeper into the impact of introducing new products. Please pull monthly sessions to 
the /products page, and show how the % of those sessions clicking through another page has changed 
over time, along with a view of how conversion from /products to placing an order has improved.
*/
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

GROUP BY 1,2;

/*
7. We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item). 
Could you please pull sales data since then, and show how well each product cross-sells from one another?
*/

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
		COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id ELSE NULL END)/count(DISTINCT order_id) AS xsold_p1_rt,
		COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id ELSE NULL END)/ count(DISTINCT order_id) AS xsold_p2_rt,
		COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id ELSE NULL END)/ count(DISTINCT order_id) AS xsold_p3_rt,
		COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id ELSE NULL END)/ count(DISTINCT order_id) AS xsold_p4_rt

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



