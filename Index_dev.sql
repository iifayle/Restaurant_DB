create index idx_orders_client_perf on orders (client_id, order_date, status, order_id) tablespace ts_rest_indexes;
create index idx_order_items_order on order_items(order_id, dish_id, quantity, price_at_moment) tablespace ts_rest_indexes;
create index idx_dishes_id_name on dishes(dish_id, dish_name) tablespace ts_rest_indexes;

commit;