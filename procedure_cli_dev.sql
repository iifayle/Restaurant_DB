-- 1. создание бронирования 
create or replace procedure create_reservation(
    p_client_id number,
    p_restaurant_id number,
    p_reservation_time timestamp,
    p_guest_count number,
    p_notes nvarchar2 default null,
    p_new_id out number
) as
    v_count number;
begin
    if client_exists(p_client_id) = 0 then
        raise_application_error(-20017, 'клиент с id ' || p_client_id || ' не найден');
    end if;
    
    select count(*) into v_count from restaurants where restaurant_id = p_restaurant_id;
    if v_count = 0 then
        raise_application_error(-20001, 'ресторан с id ' || p_restaurant_id || ' не найден');
    end if;
    
    if p_guest_count < 1 then
        raise_application_error(-20026, 'количество гостей должно быть не менее 1');
    end if;
    
    if p_reservation_time < systimestamp then
        raise_application_error(-20027, 'нельзя забронировать на прошедшее время');
    end if;
    
    insert into reservations (client_id, restaurant_id, reservation_time, guest_count, status, notes)
    values (p_client_id, p_restaurant_id, p_reservation_time, p_guest_count, 'new', p_notes)
    returning reservation_id into p_new_id;
    
    commit;
    dbms_output.put_line('бронирование создано. id: ' || p_new_id);
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end create_reservation;
/

-- 2. отмена бронирования клиентом
create or replace procedure cancel_reservation_client(
    p_client_id number,
    p_reservation_id number
) as
    v_client_id number;
    v_status varchar2(20);
    v_reservation_time timestamp;
begin
    begin
        select client_id, status, reservation_time 
        into v_client_id, v_status, v_reservation_time
        from reservations where reservation_id = p_reservation_id;
    exception
        when no_data_found then
            raise_application_error(-20015, 'бронирование с id ' || p_reservation_id || ' не найдено');
    end;
    
    if v_client_id != p_client_id then
        raise_application_error(-20028, 'это не ваше бронирование');
    end if;
    
    if v_status not in ('new', 'confirmed') then
        raise_application_error(-20029, 'нельзя отменить бронирование в статусе ' || v_status);
    end if;
    
    if v_reservation_time < (systimestamp + interval '1' hour) then
        raise_application_error(-20033, 'отмена возможна не позднее чем за 1 час до брони');
    end if;
    
    update reservations set status = 'cancelled' where reservation_id = p_reservation_id;
    
    commit;
    dbms_output.put_line('бронирование отменено');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end cancel_reservation_client;
/

--12. просмотр своих броней
create or replace procedure view_my_reservations(
    p_client_id number
) as
    v_count number := 0;
begin
    if client_exists(p_client_id) = 0 then
        raise_application_error(-20017, 'клиент с id ' || p_client_id || ' не найден');
    end if;
    
    dbms_output.put_line('мои бронирования');
    
    for rec in (
        select r.reservation_id,
               rest.name as restaurant_name,
               rest.address as restaurant_address,
               r.reservation_time,
               r.guest_count,
               r.status,
               r.notes,
               case 
                   when r.reservation_time > systimestamp and r.status in ('new', 'confirmed') then 'активно'
                   when r.status = 'cancelled' then 'отменено'
                   else 'завершено'
               end as status_desc
        from reservations r
        join restaurants rest on r.restaurant_id = rest.restaurant_id
        where r.client_id = p_client_id
        order by r.reservation_time desc
    ) loop
        dbms_output.put_line('id: ' || rec.reservation_id);
        dbms_output.put_line('ресторан: ' || rec.restaurant_name);
        dbms_output.put_line('адрес: ' || rec.restaurant_address);
        dbms_output.put_line('время: ' || to_char(rec.reservation_time, 'dd.mm.yyyy hh24:mi'));
        dbms_output.put_line('гостей: ' || rec.guest_count);
        dbms_output.put_line('статус: ' || rec.status_desc);
        dbms_output.put_line('примечания: ' || nvl(rec.notes, '-'));
        dbms_output.put_line('---');
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('у вас нет бронирований');
    end if;
exception
    when others then
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end view_my_reservations;
/
--------------------------------------------------------------------------------
-- 3. добавление отзыва
create or replace procedure add_review(
    p_client_id number,
    p_restaurant_id number,
    p_rating number,
    p_review_text nvarchar2,
    p_visit_date date default sysdate,
    p_new_id out number
) as
    v_count number;
begin
    if client_exists(p_client_id) = 0 then
        raise_application_error(-20017, 'клиент не найден');
    end if;
    
    select count(*) into v_count from restaurants where restaurant_id = p_restaurant_id;
    if v_count = 0 then
        raise_application_error(-20001, 'ресторан не найден');
    end if;
    
    if p_rating not between 1 and 5 then
        raise_application_error(-20034, 'оценка должна быть от 1 до 5');
    end if;
    
    if p_review_text is null or length(p_review_text) < 3 then
        raise_application_error(-20035, 'текст отзыва слишком короткий');
    end if;
    
    insert into reviews (client_id, rating, review_text, review_date, visit_date, status)
    values (p_client_id, p_rating, p_review_text, sysdate, p_visit_date, 'pending')
    returning review_id into p_new_id;
    
    commit;
    dbms_output.put_line('отзыв добавлен. id: ' || p_new_id || ' (ожидает модерации)');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end add_review;
/

--15. просмотр опубликованных отзывов
create or replace procedure show_published_reviews(
    p_min_rating number default null
) as
    v_count number := 0;
begin
    dbms_output.put_line(chr(10) || 'отзывы гостей');
    
    for rec in (
        select * from v_published_reviews
        where (p_min_rating is null or rating >= p_min_rating)
        order by review_date desc
    ) loop
        dbms_output.put_line('оценка: ' || rec.rating || '/5');
        dbms_output.put_line('гость: ' || rec.client_name);
        dbms_output.put_line('отзыв: ' || rec.review_text);
        dbms_output.put_line('---');
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('нет отзывов');
    end if;
end show_published_reviews;
/
--16. Изменение неопубликованных отзывов
create or replace procedure update_my_review(
    p_client_id number,
    p_review_id number,
    p_rating number default null,
    p_review_text nvarchar2 default null
) as
    v_client_id number;
    v_status varchar2(20);
begin
    if client_exists(p_client_id) = 0 then
        raise_application_error(-20017, 'клиент с id ' || p_client_id || ' не найден');
    end if;
    
    begin
        select client_id, status into v_client_id, v_status
        from reviews where review_id = p_review_id;
    exception
        when no_data_found then
            raise_application_error(-20016, 'отзыв с id ' || p_review_id || ' не найден');
    end;
    
    if v_client_id != p_client_id then
        raise_application_error(-20032, 'это не ваш отзыв');
    end if;
    
    if v_status != 'pending' then
        raise_application_error(-20033, 'нельзя изменить уже обработанный отзыв. текущий статус: ' || v_status);
    end if;
    
    update reviews set
        rating = nvl(p_rating, rating),
        review_text = nvl(p_review_text, review_text)
    where review_id = p_review_id;
    
    commit;
    dbms_output.put_line('отзыв изменён');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end update_my_review;
/
--17. удаление отзывов
create or replace procedure delete_my_review(
    p_client_id number,
    p_review_id number
) as
    v_client_id number;
    v_status varchar2(20);
begin
    if client_exists(p_client_id) = 0 then
        raise_application_error(-20017, 'клиент с id ' || p_client_id || ' не найден');
    end if;
    
    begin
        select client_id, status into v_client_id, v_status
        from reviews where review_id = p_review_id;
    exception
        when no_data_found then
            raise_application_error(-20016, 'отзыв с id ' || p_review_id || ' не найден');
    end;
    
    if v_client_id != p_client_id then
        raise_application_error(-20032, 'это не ваш отзыв');
    end if;
    
    if v_status != 'pending' then
        raise_application_error(-20033, 'нельзя удалить уже обработанный отзыв. текущий статус: ' || v_status);
    end if;
    
    delete from reviews where review_id = p_review_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20016, 'отзыв с id ' || p_review_id || ' не найден');
    end if;
    
    commit;
    dbms_output.put_line('отзыв удалён');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end delete_my_review;
/
--11. просмотр своих отзывов
create or replace procedure view_my_reviews(
    p_client_id number
) as
    v_count number := 0;
begin
    if client_exists(p_client_id) = 0 then
        raise_application_error(-20017, 'клиент с id ' || p_client_id || ' не найден');
    end if;
    
    dbms_output.put_line('мои отзывы');
    
    for rec in (
        select review_id,
               rating,
               review_text,
               review_date,
               visit_date,
               status,
               case 
                   when status = 'pending' then 'на модерации'
                   when status = 'published' then 'опубликован'
                   else 'отклонён'
               end as status_desc
        from reviews
        where client_id = p_client_id
        order by review_date desc
    ) loop
        dbms_output.put_line('id: ' || rec.review_id);
        dbms_output.put_line('оценка: ' || rec.rating || '/5');
        dbms_output.put_line('текст: ' || rec.review_text);
        dbms_output.put_line('дата посещения: ' || to_char(rec.visit_date, 'dd.mm.yyyy'));
        dbms_output.put_line('дата отзыва: ' || to_char(rec.review_date, 'dd.mm.yyyy'));
        dbms_output.put_line('статус: ' || rec.status_desc);
        dbms_output.put_line('---');
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('у вас нет отзывов');
    end if;
exception
    when others then
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end view_my_reviews;
/
--------------------------------------------------------------------------------

-- 4. регистрация нового клиента
create or replace procedure register_client(
    p_full_name nvarchar2,
    p_phone varchar2,
    p_email varchar2,
    p_password nvarchar2,
    p_birth_date date default null,
    p_new_id out number
) as
    v_hash nvarchar2(128);
begin
    if p_email is null then
        raise_application_error(-20036, 'email обязателен для регистрации');
    end if;
    
    if p_password is null or length(p_password) < 4 then
        raise_application_error(-20037, 'пароль должен быть не менее 4 символов');
    end if;
    
    v_hash := sha256_hash(p_password);
    
    insert into clients (full_name, phone, email, password_hash, birth_date, registration_date)
    values (p_full_name, p_phone, p_email, v_hash, p_birth_date, sysdate)
    returning client_id into p_new_id;
    
    commit;
    dbms_output.put_line('клиент зарегистрирован. id: ' || p_new_id);
exception
    when dup_val_on_index then
        rollback;
        dbms_output.put_line('ошибка: клиент с email ' || p_email || ' уже существует');
        raise_application_error(-20022, 'клиент с таким email уже существует');
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end register_client;
/

-- 5. вход клиента 
create or replace procedure login_client(
    p_email varchar2,
    p_password nvarchar2,
    p_client_id out number,
    p_full_name out nvarchar2
) as
    v_stored_hash nvarchar2(128);
    v_input_hash nvarchar2(128);
begin
    begin
        select client_id, full_name, password_hash 
        into p_client_id, p_full_name, v_stored_hash
        from clients 
        where email = p_email;
    exception
        when no_data_found then
            raise_application_error(-20039, 'клиент с email ' || p_email || ' не найден');
    end;
    
    v_input_hash := sha256_hash(p_password);
    
    if v_input_hash != v_stored_hash then
        raise_application_error(-20038, 'неверный пароль');
    end if;
    
    dbms_output.put_line('вход выполнен. добро пожаловать, ' || p_full_name);
exception
    when others then
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end login_client;
/
-- 6. редактирование профиля клиента
create or replace procedure update_my_profile(
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
        raise_application_error(-20017, 'клиент не найден');
    end if;
    
    commit;
    dbms_output.put_line('профиль обновлён');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end update_my_profile;
/

-- 7. изменение пароля клиента 
create or replace procedure change_my_password(
    p_client_id number,
    p_old_password nvarchar2,
    p_new_password nvarchar2
) as
    v_stored_hash nvarchar2(128);
    v_old_hash nvarchar2(128);
    v_new_hash nvarchar2(128);
begin
    select password_hash into v_stored_hash
    from clients where client_id = p_client_id;
    
    v_old_hash := sha256_hash(p_old_password);
    
    if v_old_hash != v_stored_hash then
        raise_application_error(-20038, 'неверный старый пароль');
    end if;
    
    if p_new_password is null or length(p_new_password) < 4 then
        raise_application_error(-20037, 'новый пароль должен быть не менее 4 символов');
    end if;
    
    v_new_hash := sha256_hash(p_new_password);
    
    update clients set password_hash = v_new_hash
    where client_id = p_client_id;
    
    commit;
    dbms_output.put_line('пароль изменён');
exception
    when no_data_found then
        rollback;
        raise_application_error(-20017, 'клиент не найден');
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end change_my_password;
/

-- 8. удаление учётной записи клиента
create or replace procedure delete_my_account(
    p_client_id number,
    p_password nvarchar2
) as
    v_stored_hash nvarchar2(128);
    v_input_hash nvarchar2(128);
    v_count number;
begin
    select password_hash into v_stored_hash
    from clients where client_id = p_client_id;
    
    v_input_hash := sha256_hash(p_password);
    
    if v_input_hash != v_stored_hash then
        raise_application_error(-20038, 'неверный пароль');
    end if;
    
    select count(*) into v_count
    from reservations
    where client_id = p_client_id
    and status in ('new', 'confirmed')
    and reservation_time > systimestamp;
    
    if v_count > 0 then
        raise_application_error(-20040, 'у вас есть активные бронирования. сначала отмените их');
    end if;
    
    update clients set
        full_name = 'deleted_user_' || to_char(sysdate, 'yyyymmddhh24miss'),
        phone = null,
        email = null,
        password_hash = 'deleted',
        birth_date = null
    where client_id = p_client_id;
    
    commit;
    dbms_output.put_line('учётная запись удалена');
exception
    when no_data_found then
        rollback;
        raise_application_error(-20017, 'клиент не найден');
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end delete_my_account;
/

--9. просмотр своей информации
create or replace procedure view_my_profile(
    p_client_id number
) as
    rec clients%rowtype;
begin
    begin
        select * into rec
        from clients
        where client_id = p_client_id;
    exception
        when no_data_found then
            raise_application_error(-20017, 'клиент с id ' || p_client_id || ' не найден');
    end;
    
    dbms_output.put_line('мой профиль');
    dbms_output.put_line('id: ' || rec.client_id);
    dbms_output.put_line('фио: ' || rec.full_name);
    dbms_output.put_line('телефон: ' || nvl(rec.phone, '-'));
    dbms_output.put_line('email: ' || nvl(rec.email, '-'));
    dbms_output.put_line('дата рождения: ' || nvl(to_char(rec.birth_date, 'dd.mm.yyyy'), '-'));
    dbms_output.put_line('дата регистрации: ' || to_char(rec.registration_date, 'dd.mm.yyyy'));
    dbms_output.put_line('статус: ' || case when rec.full_name like 'deleted_user%' then 'удалён' else 'активен' end);
exception
    when others then
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end view_my_profile;
/
--------------------------------------------------------------------------------
--10. просмотр своих заказов
create or replace procedure view_my_orders(p_client_id number) as
    v_count number := 0;
begin
    if client_exists(p_client_id) = 0 then
        raise_application_error(-20017, 'клиент с id ' || p_client_id || ' не найден');
    end if;
    
    dbms_output.put_line('мои заказы');
    
    for rec in (
        select o.order_id,
               o.order_date,
               o.status,
               calculate_order_total(o.order_id) as total_amount,
               nvl(c.discount_amount, 0) as discount_amount,
               calculate_order_total(o.order_id, nvl(c.discount_amount, 0)) as final_amount,
               c.payment_method,
               (select listagg(d.dish_name || ' (' || oi.quantity || ' шт.)', ', ') 
                from order_items oi 
                join dishes d on oi.dish_id = d.dish_id 
                where oi.order_id = o.order_id) as dishes_list
        from orders o
        left join checks c on o.order_id = c.order_id
        where o.client_id = p_client_id
        order by o.order_date desc
    ) loop
        dbms_output.put_line('заказ id: ' || rec.order_id);
        dbms_output.put_line('дата: ' || to_char(rec.order_date, 'dd.mm.yyyy hh24:mi'));
        dbms_output.put_line('статус: ' || rec.status);
        dbms_output.put_line('блюда: ' || rec.dishes_list);
        dbms_output.put_line('сумма: ' || rec.total_amount || ' руб.');
        dbms_output.put_line('скидка: ' || rec.discount_amount || ' руб.');
        dbms_output.put_line('к оплате: ' || rec.final_amount || ' руб.');
        dbms_output.put_line('оплата: ' || nvl(rec.payment_method, '-'));
        dbms_output.put_line('---');
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('у вас нет заказов');
    end if;
exception
    when others then
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end view_my_orders;
/
--------------------------------------------------------------------------------
--13. просмотр меню
create or replace procedure show_menu(
    p_category_name nvarchar2 default null
) as
    v_count number := 0;
begin
    dbms_output.put_line(chr(10) || 'меню ресторана');
    
    for rec in (
        select category_name, dish_name, price, composition, weight, is_seasonal
        from v_menu
        where (p_category_name is null or upper(category_name) = upper(p_category_name))
        order by category_name, dish_name
    ) loop
        dbms_output.put_line(rec.category_name || ' | ' || rec.dish_name);
        dbms_output.put_line('  состав: ' || nvl(rec.composition, 'не указан'));
        dbms_output.put_line('  цена: ' || rec.price || ' руб. | вес: ' || nvl(rec.weight, 0) || 'г');
        if rec.is_seasonal = 1 then
            dbms_output.put_line('  (сезонное)');
        end if;
        dbms_output.put_line('---');
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('блюда не найдены');
    end if;
end show_menu;
/
--14.  просмотр доступных блюд
create or replace procedure show_available_dishes(
    p_only_seasonal number default 0
) as
    v_count number := 0;
begin
    dbms_output.put_line(chr(10) || 'доступные блюда');
    
    for rec in (
        select * from v_available_dishes
        where (p_only_seasonal = 0 or is_seasonal = 1)
        order by category_name, dish_name
    ) loop
        dbms_output.put_line(rec.category_name || ' | ' || rec.dish_name || ' | ' || rec.price || ' руб.');
        if rec.is_seasonal = 1 and p_only_seasonal = 0 then
            dbms_output.put_line('  (сезонное)');
        end if;
        v_count := v_count + 1;
    end loop;
    
    if v_count = 0 then
        dbms_output.put_line('нет доступных блюд');
    end if;
end show_available_dishes;

