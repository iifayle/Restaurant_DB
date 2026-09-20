--смены сотрудников с подстановкой фио и названий ресторанов
create or replace view v_employee_shifts as
    select s.shift_id,
           e.full_name as employee_name,
           r.name as restaurant_name,
           s.start_time,
           s.end_time,
           extract(hour from (s.end_time - s.start_time)) as duration_hours--извлечение часов
    from shifts s
    join employees e on s.employee_id = e.employee_id
    join restaurants r on s.restaurant_id = r.restaurant_id
    order by s.start_time desc;

--блюда, доступные к заказу
create or replace view v_available_dishes as
    select d.dish_id,
           d.dish_name,
           c.category_name,
           d.composition,
           d.weight,
           d.price,
           d.is_seasonal,
           d.popularity
    from dishes d
    join dish_categories c on d.category_id = c.category_id
    where d.is_available = 1
    order by c.category_name, d.dish_name;

--бронирования на текущую дату
create or replace view v_today_reservations as
    select r.reservation_id,
           r.restaurant_id,         
           c.full_name as client_name,
           c.phone as client_phone,
           rest.name as restaurant_name,
           r.reservation_time,
           r.guest_count,
           r.status,
           r.notes
    from reservations r
    join clients c on r.client_id = c.client_id
    join restaurants rest on r.restaurant_id = rest.restaurant_id
    where trunc(r.reservation_time) = trunc(sysdate)
    order by r.reservation_time;
--журнал инцидентов
create or replace view v_incidents as
    select i.incident_id,
           i.incident_date,
           i.description,
           i.resolution,
           e.full_name as employee_name,
           r.name as restaurant_name,
           case 
               when i.resolution is not null then 'решён'
               else 'в работе'
           end as status
    from incidents i
    join employees e on i.employee_id = e.employee_id
    join restaurants r on e.restaurant_id = r.restaurant_id
    order by i.incident_date desc;

--просмотр меню
create or replace view v_menu as
    select d.dish_id,
           d.dish_name,
           c.category_name,
           d.composition,
           d.weight,
           d.price,
           d.is_seasonal,
           case when d.is_seasonal = 1 then 'сезонное' else 'постоянное' end as availability_note
    from dishes d
    join dish_categories c on d.category_id = c.category_id
    where d.is_available = 1;

--активные сотрудники
create or replace view v_active_employees_for_manager as
    select e.employee_id,
           e.full_name,
           p.position_name,
           r.name as restaurant_name,
           e.hire_date,
           e.training_info,
           case when e.is_active = 1 then 'активен' else 'уволен' end as status
    from employees e
    join positions p on e.position_id = p.position_id
    join restaurants r on e.restaurant_id = r.restaurant_id
    where e.is_active = 1
    order by e.full_name;

--опубликованные отзывы
create or replace view v_published_reviews as
    select r.review_id,
           c.full_name as client_name,
           r.rating,
           r.review_text,
           r.review_date,
           r.visit_date
    from reviews r
    join clients c on r.client_id = c.client_id
    where r.status = 'published'
    order by r.review_date desc;

--отзывы на модерации
create or replace view v_pending_reviews as
    select r.review_id,
           c.full_name as client_name,
           c.phone as client_phone,
           c.email as client_email,
           r.rating,
           r.review_text,
           r.review_date,
           r.visit_date
    from reviews r
    join clients c on r.client_id = c.client_id
    where r.status = 'pending'
    order by r.review_date;