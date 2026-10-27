with stg_orders as (
    select
        orderid,
        {{ dbt_utils.generate_surrogate_key(['customerid']) }} as customerkey,
        {{ dbt_utils.generate_surrogate_key(['employeeid']) }} as employeekey,
        replace(to_date(orderdate)::varchar, '-', '')::int as orderdatekey
    from {{ source('northwind', 'Orders') }}
),

stg_order_details as (
    select
        orderid,
        productid,
        quantity,
        unitprice,
        discount
    from {{ source('northwind', 'Order_Details') }}
)

select
    o.orderid,
    o.customerkey,
    o.employeekey,
    o.orderdatekey,

    {{ dbt_utils.generate_surrogate_key(['od.productid']) }} as productkey,

    od.quantity,

    od.quantity * od.unitprice as extendedpriceamount,

    (od.quantity * od.unitprice) * od.discount as discountamount,

    (od.quantity * od.unitprice) * (1 - od.discount) as soldamount

from stg_orders o
    inner join stg_order_details od
        on o.orderid = od.orderid