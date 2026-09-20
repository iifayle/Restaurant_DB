--создание смены для сотрудника
create or replace procedure create_shift(
    p_employee_id number,
    p_start_time timestamp,
    p_end_time timestamp,
    p_restaurant_id number,
    p_new_id out number
) as
begin
    if is_employee_available(p_employee_id, p_start_time, p_end_time) = 0 then
        raise_application_error(-20012, 'сотрудник уже занят в это время');
    end if;
    
    insert into shifts (employee_id, start_time, end_time, restaurant_id)
    values (p_employee_id, p_start_time, p_end_time, p_restaurant_id)
    returning shift_id into p_new_id;
    
    commit;
    dbms_output.put_line('смена создана. id: ' || p_new_id);
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end create_shift;
/

--назначение сотрудника на существующую смену
create or replace procedure assign_employee_to_shift(
    p_shift_id number,
    p_employee_id number
) as
    v_start_time timestamp;
    v_end_time timestamp;
begin
    select start_time, end_time into v_start_time, v_end_time
    from shifts where shift_id = p_shift_id;
    
    if is_employee_available(p_employee_id, v_start_time, v_end_time) = 0 then
        raise_application_error(-20012, 'у сотрудника уже есть смена в это время');
    end if;
    
    update shifts set employee_id = p_employee_id
    where shift_id = p_shift_id;
    
    commit;
    dbms_output.put_line('сотрудник назначен на смену');
exception
    when no_data_found then
        rollback;
        dbms_output.put_line('ошибка: смена с id ' || p_shift_id || ' не найдена');
        raise;
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end assign_employee_to_shift;
/

-- изменение параметров смены
create or replace procedure update_shift(
    p_shift_id number,
    p_start_time timestamp default null,
    p_end_time timestamp default null,
    p_restaurant_id number default null
) as
    v_employee_id number;
    v_new_start timestamp;
    v_new_end timestamp;
    v_current_start timestamp;
    v_current_end timestamp;
begin
    select employee_id, start_time, end_time 
    into v_employee_id, v_current_start, v_current_end
    from shifts where shift_id = p_shift_id;
    
    v_new_start := nvl(p_start_time, v_current_start);--проверка на нулл
    v_new_end := nvl(p_end_time, v_current_end);
    
    if v_new_start >= v_new_end then
        raise_application_error(-20011, 'время начала должно быть раньше времени окончания');
    end if;
    
    if is_employee_available(v_employee_id, v_new_start, v_new_end) = 0 then
        raise_application_error(-20012, 'смена пересекается с другой сменой сотрудника');
    end if;
    
    update shifts set
        start_time = v_new_start,
        end_time = v_new_end,
        restaurant_id = nvl(p_restaurant_id, restaurant_id)
    where shift_id = p_shift_id;
    
    commit;
    dbms_output.put_line('смена обновлена');
exception
    when no_data_found then
        rollback;
        dbms_output.put_line('ошибка: смена с id ' || p_shift_id || ' не найдена');
        raise;
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end update_shift;
/

--отмена смены
create or replace procedure cancel_shift(
    p_shift_id number
) as
begin
    delete from shifts where shift_id = p_shift_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20013, 'смена с id ' || p_shift_id || ' не найдена');
    end if;
    
    commit;
    dbms_output.put_line('смена отменена');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end cancel_shift;
/

--отоброжение смен сотрудников
create or replace procedure show_employee_shifts(
    p_employee_name nvarchar2 default null,
    p_days_ahead number default 7
) as
    v_count number := 0;
begin
    dbms_output.put_line(chr(10) || 'смены сотрудников');
    
    for rec in (
        select * from v_employee_shifts
        where (p_employee_name is null or upper(employee_name) like '%' || upper(p_employee_name) || '%')
          and start_time <= systimestamp + p_days_ahead
        order by start_time
    ) loop
        dbms_output.put_line(rec.employee_name || ' | ' || rec.restaurant_name);
        dbms_output.put_line('  ' || to_char(rec.start_time, 'dd.mm.yyyy hh24:mi') || ' - ' || to_char(rec.end_time, 'hh24:mi'));
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('смены не найдены');
    end if;
end show_employee_shifts;
/

--просмотр активных сотрудников
create or replace procedure show_active_employees(
    p_restaurant_name nvarchar2 default null
) as
    v_count number := 0;
begin
    dbms_output.put_line(chr(10) || 'активные сотрудники');
    
    for rec in (
        select * from v_active_employees_for_manager 
        where (p_restaurant_name is null 
               or upper(restaurant_name) like '%' || upper(p_restaurant_name) || '%')
        order by restaurant_name, full_name
    ) loop
        dbms_output.put_line(rec.restaurant_name || ' | ' || rec.full_name || ' | ' || rec.position_name);
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('сотрудники не найдены');
    end if;
end show_active_employees;
/
--------------------------------------------------------------------------------
-- добавление инцидента
create or replace procedure add_incident(
    p_description nvarchar2,
    p_employee_id number,
    p_resolution nvarchar2 default null,
    p_incident_date date default sysdate,
    p_new_id out number
) as
    v_count number;
begin
    -- существует ли сотрудник
    select count(*) into v_count
    from employees where employee_id = p_employee_id;
    
    if v_count = 0 then
        raise_application_error(-20010, 'сотрудник не найден');
    end if;
    
    insert into incidents (incident_date, description, resolution, employee_id)
    values (p_incident_date, p_description, p_resolution, p_employee_id)
    returning incident_id into p_new_id;
    
    commit;
    dbms_output.put_line('инцидент зарегистрирован. id: ' || p_new_id);
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end add_incident;
/

-- редактирование инцидента
create or replace procedure update_incident(
    p_incident_id number,
    p_description nvarchar2 default null,
    p_resolution nvarchar2 default null
) as
begin
    update incidents set
        description = nvl(p_description, description),
        resolution = nvl(p_resolution, resolution)
    where incident_id = p_incident_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20014, 'инцидент с id ' || p_incident_id || ' не найден');
    end if;
    
    commit;
    dbms_output.put_line('инцидент обновлён');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end update_incident;
/

--просмотр инцидентов
create or replace procedure show_incidents(
    p_status nvarchar2 default null
) as
    v_count number := 0;
begin
    dbms_output.put_line(chr(10) || 'журнал инцидентов');
    
    for rec in (
        select * from v_incidents
        where (p_status is null or upper(status) = upper(p_status))
        order by incident_date desc
    ) loop
        dbms_output.put_line(to_char(rec.incident_date, 'dd.mm.yyyy') || ' | ' || rec.restaurant_name);
        dbms_output.put_line('описание: ' || rec.description);
        dbms_output.put_line('статус: ' || rec.status);
        dbms_output.put_line('---');
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('инциденты не найдены');
    end if;
end show_incidents;
/
--------------------------------------------------------------------------------
-- подтверждение бронирования
create or replace procedure confirm_reservation(
    p_reservation_id number
) as
begin
    update reservations set status = 'confirmed'
    where reservation_id = p_reservation_id
    and status = 'new';
    
    if sql%rowcount = 0 then
        raise_application_error(-20015, 'бронирование не найдено или уже не в статусе new');
    end if;
    
    commit;
    dbms_output.put_line('бронирование подтверждено');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end confirm_reservation;
/

--отмена бронирования
create or replace procedure cancel_reservation(
    p_reservation_id number
) as
begin
    update reservations set status = 'cancelled'
    where reservation_id = p_reservation_id
    and status in ('new', 'confirmed');
    
    if sql%rowcount = 0 then
        raise_application_error(-20015, 'бронирование не найдено или его нельзя отменить');
    end if;
    
    commit;
    dbms_output.put_line('бронирование отменено');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end cancel_reservation;
/

-- перенос бронирования
create or replace procedure reschedule_reservation(
    p_reservation_id number,
    p_new_time timestamp,
    p_new_guest_count number default null
) as
begin
    update reservations set
        reservation_time = p_new_time,
        guest_count = nvl(p_new_guest_count, guest_count),
        status = 'new'
    where reservation_id = p_reservation_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20015, 'бронирование не найдено');
    end if;
    
    commit;
    dbms_output.put_line('бронирование перенесено на ' || to_char(p_new_time, 'dd.mm.yyyy hh24:mi'));
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end reschedule_reservation;
/

--отобр бронирования на сегодня
create or replace procedure show_today_reservations(
    p_restaurant_id number default null
) as
    v_count number := 0;
begin
    dbms_output.put_line(chr(10) || 'бронирования на сегодня');
    
    for rec in (select * from v_today_reservations 
    where (p_restaurant_id is null or restaurant_id = p_restaurant_id) 
    order by reservation_time) 
    loop
        dbms_output.put_line(to_char(rec.reservation_time, 'hh24:mi') || ' | ' || rec.client_name || ' | ' || rec.guest_count || ' гостей');
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('нет бронирований');
    end if;
end show_today_reservations;
/
--отображ всех бронирований
create or replace procedure view_all_reservations(
    p_status nvarchar2 default null,
    p_date_from date default null,
    p_date_to date default null,
    p_restaurant_id number default null
) as
    v_count number := 0;
begin
    dbms_output.put_line('список бронирований');
    
    for rec in (
        select r.reservation_id, 
               c.full_name as client_name,
               rest.name as restaurant_name,
               r.reservation_time, 
               r.guest_count, 
               r.status
        from reservations r
        join clients c on r.client_id = c.client_id
        join restaurants rest on r.restaurant_id = rest.restaurant_id
        where (p_status is null or r.status = p_status)
          and (p_date_from is null or trunc(r.reservation_time) >= p_date_from)
          and (p_date_to is null or trunc(r.reservation_time) <= p_date_to)
          and (p_restaurant_id is null or r.restaurant_id = p_restaurant_id)
        order by r.reservation_time desc
    ) loop
        dbms_output.put_line(rec.reservation_id || ' | ' || rec.client_name || ' | ' || rec.restaurant_name || ' | ' || to_char(rec.reservation_time, 'dd.mm.yyyy hh24:mi') || ' | ' || rec.status);
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('бронирования не найдены');
    end if;
exception
    when others then
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end view_all_reservations;
/
-------------------------------------------------------------------------------
--удаления отзыва, что не прошел модерацию
create or replace procedure delete_review(
    p_review_id number,
    p_employee_id number
) as
    v_status varchar2(20);
begin
    select status into v_status from reviews where review_id = p_review_id;
    
    if v_status not in ('pending', 'rejected') then
        raise_application_error(-20030, 'можно удалить только отзыв в статусе pending или rejected. текущий статус: ' || v_status);
    end if;
    
    delete from reviews where review_id = p_review_id;
    
    commit;
    dbms_output.put_line('отзыв удалён');
exception
    when no_data_found then
        rollback;
        dbms_output.put_line('ошибка: отзыв с id ' || p_review_id || ' не найден');
        raise_application_error(-20016, 'отзыв с id ' || p_review_id || ' не найден');
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end delete_review;
/
--одоброение отзыва
create or replace procedure approve_review(
    p_review_id number,
    p_employee_id number,
    p_approve number
) as
    v_new_status varchar2(20);
begin
    if p_approve = 1 then
        v_new_status := 'published';
    else
        v_new_status := 'rejected';
    end if;
    
    update reviews set 
        status = v_new_status,
        employee_id = p_employee_id,
        handled_date = sysdate
    where review_id = p_review_id and status = 'pending';
    
    if sql%rowcount = 0 then
        raise_application_error(-20031, 'отзыв с id ' || p_review_id || ' не найден или уже обработан');
    end if;
    
    commit;
    dbms_output.put_line('отзыв ' || case when p_approve = 1 then 'опубликован' else 'отклонён' end);
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end approve_review;
/
--просмотр отзывов на модерации
create or replace procedure show_pending_reviews as
    v_count number := 0;
begin
    dbms_output.put_line(chr(10) || 'отзывы на модерации');
    
    for rec in (select * from v_pending_reviews) loop
        dbms_output.put_line('клиент: ' || rec.client_name);
        dbms_output.put_line('оценка: ' || rec.rating || '/5');
        dbms_output.put_line('текст: ' || rec.review_text);
        dbms_output.put_line('---');
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('нет отзывов на модерации');
    end if;
end show_pending_reviews;
/
--------------------------------------------------------------------------------
--создание нового заказа
create or replace procedure create_order(
    p_employee_id number,
    p_client_id number default null,
    p_notes nvarchar2 default null,
    p_new_id out number
) as
begin
    if p_client_id is not null then
        if client_exists(p_client_id) = 0 then
            raise_application_error(-20017, 'клиент не найден');
        end if;
    end if;
    
    insert into orders (employee_id, client_id, status, notes)
    values (p_employee_id, p_client_id, 'open', p_notes)
    returning order_id into p_new_id;
    
    commit;
    dbms_output.put_line('заказ создан. id: ' || p_new_id);
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end create_order;
/

-- добавление позиции в заказ
create or replace procedure add_order_item(
    p_order_id number,
    p_dish_id number,
    p_quantity number,
    p_notes nvarchar2 default null,
    p_new_id out number
) as
    v_price number;
    v_order_status varchar2(20);
begin
    begin
        select status into v_order_status from orders where order_id = p_order_id;
    exception
        when no_data_found then
            raise_application_error(-20018, 'заказ с id ' || p_order_id || ' не найден');
    end;
    
    if v_order_status != 'open' then
        raise_application_error(-20018, 'заказ уже закрыт или передан на кухню');
    end if;
    
    if dish_exists(p_dish_id) = 0 then
        raise_application_error(-20019, 'блюдо не найдено или недоступно');
    end if;
    
    if p_quantity <= 0 then
        raise_application_error(-20042, 'количество должно быть больше нуля');
    end if;
    
    v_price := get_dish_price(p_dish_id);
    
    insert into order_items (order_id, dish_id, quantity, price_at_moment, notes)
    values (p_order_id, p_dish_id, p_quantity, v_price, p_notes)
    returning order_item_id into p_new_id;
    
    commit;
    dbms_output.put_line('позиция добавлена. id: ' || p_new_id);
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end add_order_item;
/

--передача заказа на кухню
create or replace procedure submit_order_to_kitchen(
    p_order_id number
) as
    v_count number;
begin
    -- проверка: есть ли позиции в заказе
    select count(*) into v_count
    from order_items where order_id = p_order_id;
    
    if v_count = 0 then
        raise_application_error(-20020, 'нельзя отправить пустой заказ');
    end if;
    
    update orders set status = 'in_kitchen'
    where order_id = p_order_id and status = 'open';
    
    if sql%rowcount = 0 then
        raise_application_error(-20018, 'заказ не найден или уже передан');
    end if;
    
    commit;
    dbms_output.put_line('заказ передан на кухню');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end submit_order_to_kitchen;
/

--закрытие заказа и формирование чека 
create or replace procedure close_order(
    p_order_id number,
    p_payment_method varchar2,
    p_discount_amount number default 0,
    p_check_id out number
) as
    v_total number;
    v_employee_id number;
    v_final_amount number;
begin
    begin
        select employee_id into v_employee_id
        from orders 
        where order_id = p_order_id and status = 'in_kitchen';
    exception
        when no_data_found then
            raise_application_error(-20021, 'заказ с id ' || p_order_id || ' не найден или не на кухне');
    end;
    
    v_total := calculate_order_total(p_order_id, 0);
    
    if v_total = 0 then
        raise_application_error(-20020, 'нельзя закрыть пустой заказ');
    end if;
    
    if p_discount_amount > v_total then
        raise_application_error(-20024, 'скидка не может быть больше суммы заказа');
    end if;
    
    if p_discount_amount < 0 then
        raise_application_error(-20025, 'скидка не может быть отрицательной');
    end if;
    
    v_final_amount := calculate_order_total(p_order_id, p_discount_amount); 
    
    insert into checks (order_id, total_amount, discount_amount, payment_method, employee_id)
    values (p_order_id, v_total, p_discount_amount, p_payment_method, v_employee_id)
    returning check_id into p_check_id;
    
    update orders set status = 'closed' where order_id = p_order_id;
    
    commit;
    dbms_output.put_line('заказ закрыт. чек id: ' || p_check_id ||
                       ' | сумма: ' || v_total ||
                       ' | скидка: ' || p_discount_amount ||
                       ' | к оплате: ' || v_final_amount);
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end close_order;
/

--просмотр деталей заказа
create or replace procedure view_order_details(p_order_id number) as
    v_exists number;
begin
    select count(*) into v_exists from orders where order_id = p_order_id;
    
    if v_exists = 0 then
        raise_application_error(-20018, 'заказ с id ' || p_order_id || ' не найден');
    end if;
    
    dbms_output.put_line('детали заказа id: ' || p_order_id);
    
    for rec in (
        select d.dish_name, oi.quantity, oi.price_at_moment, oi.notes
        from order_items oi
        join dishes d on oi.dish_id = d.dish_id
        where oi.order_id = p_order_id
    ) loop
        dbms_output.put_line(rec.dish_name || ' | ' || rec.quantity || ' шт. | ' || rec.price_at_moment || ' руб. | ' || nvl(rec.notes, '-'));
    end loop;
    
    if sql%notfound then
        dbms_output.put_line('в заказе нет позиций');
    end if;
exception
    when others then
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end view_order_details;
/
--просмотр открытых заказов
create or replace procedure view_open_orders as
begin
    dbms_output.put_line('ОТКРЫТЫЕ ЗАКАЗЫ');
    
    for rec in (
        select 
               o.order_id,
               o.order_date,
               c.full_name as client_name,
               e.full_name as employee_name,
               calculate_order_total(o.order_id) as total_amount
        from orders o
        left join clients c on o.client_id = c.client_id
        join employees e on o.employee_id = e.employee_id
        where o.status = 'open'
        order by o.order_date
    ) loop
        dbms_output.put_line('заказ id: ' || rec.order_id ||
                           ' | клиент: ' || nvl(rec.client_name, 'гость') ||
                           ' | продавец: ' || rec.employee_name ||
                           ' | сумма: ' || nvl(rec.total_amount, 0));
    end loop;
end view_open_orders;
/
--просмотр заказов на кухне
create or replace procedure view_kitchen_orders as
begin
    dbms_output.put_line('ЗАКАЗЫ НА КУХНЕ ');
    
    for rec in (
        select 
               o.order_id,
               o.order_date,
               c.full_name as client_name,
               (select listagg(d.dish_name || ' (' || oi.quantity || ' шт.)', ', ')
                from order_items oi
                join dishes d on oi.dish_id = d.dish_id
                where oi.order_id = o.order_id) as dishes
        from orders o
        left join clients c on o.client_id = c.client_id
        where o.status = 'in_kitchen'
        order by o.order_date
    ) loop
        dbms_output.put_line('заказ id: ' || rec.order_id ||
                           ' | клиент: ' || nvl(rec.client_name, 'гость') ||
                           ' | блюда: ' || rec.dishes);
    end loop;
end view_kitchen_orders;
/
--------------------------------------------------------------------------------
--добавление нового клиента менеджером
create or replace procedure add_client(
    p_full_name nvarchar2,
    p_phone varchar2 default null,
    p_birth_date date default null,
    p_new_id out number
) as
begin
    insert into clients (full_name, phone, email, password_hash, birth_date, registration_date)
    values (p_full_name, p_phone, null, 'GUEST_ACCOUNT', p_birth_date, sysdate)
    returning client_id into p_new_id;
    
    commit;
    dbms_output.put_line('клиент-гость добавлен. id: ' || p_new_id);
exception
    when dup_val_on_index then
        rollback;
        raise_application_error(-20022, 'клиент с таким email уже существует');
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end add_client;
/
--редактирование данных клиента
create or replace procedure update_client(
    p_client_id number,
    p_full_name nvarchar2 default null,
    p_phone varchar2 default null,
    p_birth_date date default null
) as
begin
    update clients set
        full_name = nvl(p_full_name, full_name),
        phone = nvl(p_phone, phone),
        birth_date = nvl(p_birth_date, birth_date)
    where client_id = p_client_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20017, 'клиент с id ' || p_client_id || ' не найден');
    end if;
    
    commit;
    dbms_output.put_line('данные клиента обновлены');
exception
       when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end update_client;
/

--удаление/блокировка клиента 
create or replace procedure delete_client(
    p_client_id number,
    p_hard_delete number default 0
) as
    v_count number;
begin
    if p_hard_delete = 1 then
        select count(*) into v_count from reservations where client_id = p_client_id;
        if v_count > 0 then
            raise_application_error(-20023, 'у клиента есть бронирования, удаление невозможно');
        end if;
        
        select count(*) into v_count from orders where client_id = p_client_id;
        if v_count > 0 then
            raise_application_error(-20023, 'у клиента есть заказы, удаление невозможно');
        end if;
        
        delete from clients where client_id = p_client_id;
    else
        update clients set
            full_name = 'deleted_user',
            phone = null,
            email = null,
            password_hash = 'deleted'
        where client_id = p_client_id;
    end if;
    
    if sql%rowcount = 0 then
        raise_application_error(-20017, 'клиент с id ' || p_client_id || ' не найден');
    end if;
    
    commit;
    dbms_output.put_line('клиент удалён');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end delete_client;
/

--просмотр заказов клиента
create or replace procedure view_order_details(p_order_id number) as
    v_exists number;
begin
    select count(*) into v_exists from orders where order_id = p_order_id;
    
    if v_exists = 0 then
        raise_application_error(-20018, 'заказ с id ' || p_order_id || ' не найден');
    end if;
    
    dbms_output.put_line('детали заказа id: ' || p_order_id);
    
    for rec in (
        select d.dish_name, oi.quantity, oi.price_at_moment, oi.notes
        from order_items oi
        join dishes d on oi.dish_id = d.dish_id
        where oi.order_id = p_order_id
    ) loop
        dbms_output.put_line(rec.dish_name || ' | ' || rec.quantity || ' шт. | ' || 
                           rec.price_at_moment || ' руб. | ' || nvl(rec.notes, '-'));
    end loop;
    
    dbms_output.put_line('---');
    dbms_output.put_line('итого: ' || calculate_order_total(p_order_id) || ' руб.');
    
    if sql%notfound then
        dbms_output.put_line('в заказе нет позиций');
    end if;
exception
    when others then
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end view_order_details;
/
--просмотр клиентов
create or replace procedure show_clients_list(
    p_min_orders number default null
) as
    v_count number := 0;
begin
    dbms_output.put_line('список клиентов');
    
    for rec in (
        select c.client_id, c.full_name, c.phone, c.email, c.registration_date,
               (select count(*) from orders o where o.client_id = c.client_id) as total_orders,
               (select count(*) from reservations r where r.client_id = c.client_id) as total_reservations,
               (select count(*) from reviews r where r.client_id = c.client_id) as total_reviews
        from clients c
        where c.full_name not like 'deleted_user%'
          and (p_min_orders is null or 
               (select count(*) from orders o where o.client_id = c.client_id) >= p_min_orders)
        order by c.registration_date desc
    ) loop
        dbms_output.put_line(rec.client_id || ' | ' || rec.full_name || ' | ' || nvl(rec.phone, '-') || ' | заказов: ' || rec.total_orders || ' | броней: ' || rec.total_reservations);
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('клиенты не найдены');
    end if;
exception
    when others then
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end show_clients_list;
/
