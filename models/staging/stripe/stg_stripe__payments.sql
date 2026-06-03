select
    id as payment_id,
    orderid AS order_id,
    paymentmethod as payment_method,
    amount / 100 AS amount,
    status,
    created as created_at
from {{source('stripe', 'payment')}}

