create or replace procedure load_large_data(p_count number default 100000) as
    v_order_id number;
    v_item_id number;
    v_check_id number;
    v_client_id number;
    v_employee_id number;
    v_dish_id number;
    v_quantity number;
    v_start_time timestamp;
    v_end_time timestamp;
    v_orders_loaded number := 0;
begin
    v_start_time := systimestamp;
    
    for i in 1..p_count loop
        -- случайные данные
        v_client_id := round(dbms_random.value(9, 15));
        v_employee_id := round(dbms_random.value(19, 31));
        v_dish_id := round(dbms_random.value(2, 15));
        v_quantity := round(dbms_random.value(1, 4));
        
        -- создаём заказ
        insert into orders (employee_id, client_id, order_date, status, notes)
        values (v_employee_id, v_client_id, sysdate - round(dbms_random.value(1, 365)), 'closed', 'тестовый заказ ' || i)
        returning order_id into v_order_id;
        
        -- добавляем позицию
        insert into order_items (order_id, dish_id, quantity, price_at_moment)
        values (v_order_id, v_dish_id, v_quantity, (select price from dishes where dish_id = v_dish_id));
        
        -- добавляем чек
        insert into checks (order_id, total_amount, discount_amount, payment_method, employee_id)
        values (v_order_id, (select price from dishes where dish_id = v_dish_id) * v_quantity, 0, 'card', v_employee_id);
        
        v_orders_loaded := v_orders_loaded + 1;
        
        -- коммит каждые 1000 записей
        if mod(i, 1000) = 0 then
            commit;
            dbms_output.put_line('загружено заказов: ' || v_orders_loaded);
        end if;
    end loop;
    
    commit;
    v_end_time := systimestamp;    
    dbms_output.put_line('Загружено заказов: ' || v_orders_loaded);
    dbms_output.put_line('Время выполнения: ' || extract(second from (v_end_time - v_start_time)) || ' секунд');
end load_large_data;
/

set serveroutput on;
begin
    load_large_data(100000);
end;
/

-- сначала удали индекс, чтобы увидеть стоимость БЕЗ него
drop index idx_orders_client;

select o.order_id,
       o.order_date,
       o.status,
       sum(oi.quantity * oi.price_at_moment) as total_amount,
       listagg(d.dish_name || ' (' || oi.quantity || ' шт.)', ', ') 
           within group (order by oi.order_item_id) as dishes_list
from orders o
join order_items oi on o.order_id = oi.order_id
join dishes d on oi.dish_id = d.dish_id
where o.client_id = 12
group by o.order_id, o.order_date, o.status
order by o.order_date desc;