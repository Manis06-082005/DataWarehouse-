select top 5 * from silver.crm_cust_info
select top 5 * from silver.crm_prd_info
select top 5 * from silver.crm_sales_details
select top 5 * from silver.erp_cust_az12
select top 5 * from silver.erp_loc_a101
select top 5 * from silver.erp_px_cat_g1v2


create view gold.dim_customer as 
select
	ROW_NUMBER() over(order by cst_id) as customer_key,
	ci.cst_id AS customer_id
	, ci.cst_key as customer_num,
	ci.cst_firstname as first_name, 
	ci.cst_lastname as last_name,
	cc.cntry as country,
	ci.cst_marital_status as marital_status,

	CASE WHEN ci.cst_gndr!='n/a' then ci.cst_gndr
	else coalesce(ca.gen,'n/a')
	end as gender
		,ca.bdate as birthdate,
	ci.cst_create_date as create_date   
	
from silver.crm_cust_info as ci 
left join silver.erp_cust_az12 as ca 
on ci.cst_key=ca.cid
left join silver.erp_loc_a101 as cc
on ci.cst_key=cc.cid;



create or alter view gold.dim_products as
select 
ROW_NUMBER() over(order by pn.prd_start_dt , pn.prd_key) as product_key,
	pn.prd_id as product_id,
	pn.cat_id as category_id
	,pn.prd_key as product_number,
	pn.prd_start_dt as start_date,
	pn.prd_nm as product_name,
	pc.cat as category,
	pc.subcat as subcategory,
	 
	pn.prd_cost as product_cost, 
	pn.prd_line as product_line,
	pc.maintenance
from silver.crm_prd_info as pn
left join silver.erp_px_cat_g1v2 as pc
on pn.cat_id=pc.id
where pn.prd_end_dt is null

create view gold.fact_sales as 
select 
	sd.sls_ord_num as order_number,
	dm.product_key,
	dc.customer_key,
	sd.sls_order_dt as order_date ,
	sd.sls_ship_dt as ship_date,
	sd.sls_due_dt as due_date ,
	sd.sls_sales as sales,
	sd.sls_quantity as qunatity,
	sd.sls_price as price
from silver.crm_sales_details as sd
left join gold.dim_products as dm
on sd.sls_prd_key=dm.product_number
left join gold.dim_customer as dc
on sd.sls_cust_id=dc.customer_id