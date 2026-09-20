-- 1. проверка даты приёма сотрудника (не позднее текущей даты)
create or replace trigger trg_employee_hire_date
    before insert or update of hire_date on employees
    for each row
begin
    if :new.hire_date > sysdate then
        raise_application_error(-20041, 'дата приёма не может быть позже текущей даты');
    end if;
end trg_employee_hire_date;
/

-- 2. проверка времени смены (начало раньше окончания)
create or replace trigger trg_shift_time
    before insert or update of start_time, end_time on shifts
    for each row
begin
    if :new.start_time >= :new.end_time then
        raise_application_error(-20011, 'время начала должно быть раньше времени окончания');
    end if;
end trg_shift_time;
/

-- 3. проверка количества порций в позиции заказа (больше нуля)
create or replace trigger trg_order_item_quantity
    before insert or update of quantity on order_items
    for each row
begin
    if :new.quantity <= 0 then
        raise_application_error(-20042, 'количество порций должно быть больше нуля');
    end if;
end trg_order_item_quantity;
/

-- 4. запрет удаления блюда, если оно есть в незакрытых заказах
create or replace trigger trg_prevent_dish_delete
    before delete on dishes
    for each row
declare
    v_count number;
begin
    select count(*)
    into v_count
    from order_items oi
    join orders o on oi.order_id = o.order_id
    where oi.dish_id = :old.dish_id
      and o.status != 'closed';
    
    if v_count > 0 then
        raise_application_error(-20003, 'нельзя удалить блюдо: оно есть в активных заказах');
    end if;
end trg_prevent_dish_delete;
/

-- 5. запрет удаления сотрудника, если у него есть будущие смены
create or replace trigger trg_prevent_employee_delete
    before delete on employees
    for each row
declare
    v_count number;
begin
    select count(*)
    into v_count
    from shifts
    where employee_id = :old.employee_id
      and start_time > systimestamp;
    
    if v_count > 0 then
        raise_application_error(-20005, 'нельзя удалить сотрудника: у него есть будущие смены');
    end if;
end trg_prevent_employee_delete;
/

-- 6. обновление счётчика популярности блюда после добавления позиции в заказ
create or replace trigger trg_popularity_update
    after insert on order_items
    for each row
begin
    update dishes
    set popularity = nvl(popularity, 0) + :new.quantity
    where dish_id = :new.dish_id;
end trg_popularity_update;
/

-- 7. проверка, что скидка в чеке не больше суммы заказа
create or replace trigger trg_check_discount
    before insert or update of discount_amount, total_amount on checks
    for each row
begin
    if :new.discount_amount > :new.total_amount then
        raise_application_error(-20024, 'скидка не может быть больше суммы заказа');
    end if;
    
    if :new.discount_amount < 0 then
        raise_application_error(-20025, 'скидка не может быть отрицательной');
    end if;
end trg_check_discount;
/