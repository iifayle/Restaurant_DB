-- 1. вычисление итоговой суммы заказа (с учётом скидки)
create or replace function calculate_order_total(
    p_order_id number,
    p_discount_amount number default 0
) return number as
    v_subtotal number;
    v_final_total number;
begin
    -- считаем сумму всех позиций
    select sum(quantity * price_at_moment) into v_subtotal
    from order_items
    where order_id = p_order_id;
    
    v_subtotal := nvl(v_subtotal, 0);
    
    -- применяем скидку
    if p_discount_amount > v_subtotal then
        v_final_total := 0;
    else
        v_final_total := v_subtotal - p_discount_amount;
    end if;
    
    return v_final_total;
exception
    when others then
        dbms_output.put_line('ошибка при расчёте суммы заказа: ' || sqlerrm);
        return 0;
end calculate_order_total;
/

-- 2. получение текущей цены блюда
create or replace function get_dish_price(
    p_dish_id number
) return number as
    v_price number;
begin
    select price into v_price
    from dishes
    where dish_id = p_dish_id;
    
    return v_price;
exception
    when no_data_found then
        return null;
    when others then
        dbms_output.put_line('ошибка при получении цены блюда: ' || sqlerrm);
        return null;
end get_dish_price;
/

-- 3. проверка, свободен ли сотрудник в указанный период
create or replace function is_employee_available(
    p_employee_id number,
    p_start_time timestamp,
    p_end_time timestamp
) return number as
    v_count number;
begin
    select count(*)
    into v_count
    from shifts
    where employee_id = p_employee_id
    and ((p_start_time between start_time and end_time)
         or (p_end_time between start_time and end_time)
         or (start_time between p_start_time and p_end_time));
    --пересечения
    if v_count = 0 then
        return 1;  -- свободен
    else
        return 0;  -- занят
    end if;
exception
    when others then
        dbms_output.put_line('ошибка при проверке доступности сотрудника: ' || sqlerrm);
        return 0;
end is_employee_available;
/

-- 4. проверка существования клиента
create or replace function client_exists(
    p_client_id number
) return number as
    v_count number;
begin
    select count(*) into v_count
    from clients
    where client_id = p_client_id;
    
    if v_count > 0 then
        return 1;  -- существует
    else
        return 0;  -- не существует
    end if;
exception
    when others then
        dbms_output.put_line('ошибка при проверке клиента: ' || sqlerrm);
        return 0;
end client_exists;
/

-- 5. проверка существования блюда и его доступности
create or replace function dish_exists(
    p_dish_id number
) return number as
    v_count number;
begin
    select count(*) into v_count
    from dishes
    where dish_id = p_dish_id
    and is_available = 1;
    
    if v_count > 0 then
        return 1;  -- существует и доступно
    else
        return 0;  -- не существует или недоступно
    end if;
exception
    when others then
        dbms_output.put_line('ошибка при проверке блюда: ' || sqlerrm);
        return 0;
end dish_exists;
/

create or replace function sha256_hash(p_password varchar2) return varchar2 as
    v_hash raw(32);
begin
    v_hash := dbms_crypto.hash(utl_raw.cast_to_raw(p_password), dbms_crypto.hash_sh256);
    return rawtohex(v_hash);
end sha256_hash;
/
