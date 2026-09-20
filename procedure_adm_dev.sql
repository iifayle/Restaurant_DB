--новый ресторан
create or replace procedure add_restaurant(
    p_name nvarchar2,
    p_address nvarchar2,
    p_phone varchar2,
    p_work_hours varchar2 default null,
    p_unp varchar2 default null,
    p_new_id out number
) as
begin
    insert into restaurants (name, address, phone, work_hours, unp)
    values (p_name, p_address, p_phone, p_work_hours, p_unp)
    returning restaurant_id into p_new_id;
    
    commit;
    dbms_output.put_line('ресторан добавлен. id: ' || p_new_id);
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end add_restaurant;
/
-- изменение данных ресторана
create or replace procedure update_restaurant(
    p_restaurant_id number,
    p_name nvarchar2 default null,
    p_address nvarchar2 default null,
    p_phone varchar2 default null,
    p_work_hours varchar2 default null,
    p_unp varchar2 default null
) as
begin
    update restaurants set
        name = nvl(p_name, name),
        address = nvl(p_address, address),
        phone = nvl(p_phone, phone),
        work_hours = nvl(p_work_hours, work_hours),
        unp = nvl(p_unp, unp)
    where restaurant_id = p_restaurant_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20001, 'ресторан с id ' || p_restaurant_id || ' не найден');
    end if;
    
    commit;
    dbms_output.put_line('ресторан обновлён');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end update_restaurant;
/
-- удаление ресторана из сети
create or replace procedure delete_restaurant(
    p_restaurant_id number
) as
begin
    -- есть ли у ресторана сотрудники
    declare
        v_count number;
    begin
        select count(*) into v_count from employees where restaurant_id = p_restaurant_id;
        if v_count > 0 then
            raise_application_error(-20002, 'нельзя удалить ресторан: есть сотрудники');
        end if;
    end;
    
    delete from restaurants where restaurant_id = p_restaurant_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20001, 'ресторан с id ' || p_restaurant_id || ' не найден');
    end if;
    
    commit;
    dbms_output.put_line('ресторан удалён');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end delete_restaurant;
/
--просмотр ресторанов
create or replace procedure view_restaurants as
begin
    dbms_output.put_line('список ресторанов');
    for rec in (select restaurant_id, name, address, phone, work_hours from restaurants) loop
        dbms_output.put_line(rec.restaurant_id || ' | ' || rec.name || ' | ' || rec.address);
    end loop;
end view_restaurants;
/
---------------------------------------------------------------------------------
--новое блюдо
create or replace procedure add_dish(
    p_dish_name nvarchar2,
    p_category_id number,
    p_composition nvarchar2 default null,
    p_weight number default null,
    p_price number,
    p_is_available number default 1,
    p_is_seasonal number default 0,
    p_new_id out number
) as
begin
    insert into dishes (dish_name, category_id, composition, weight, price, is_available, is_seasonal)
    values (p_dish_name, p_category_id, p_composition, p_weight, p_price, p_is_available, p_is_seasonal)
    returning dish_id into p_new_id;
    
    commit;
    dbms_output.put_line('блюдо добавлено. id: ' || p_new_id);
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end add_dish;
/
-- изменение параметров существующего блюда
create or replace procedure update_dish(
    p_dish_id number,
    p_dish_name nvarchar2 default null,
    p_category_id number default null,
    p_composition nvarchar2 default null,
    p_weight number default null,
    p_price number default null,
    p_is_available number default null,
    p_is_seasonal number default null
) as
begin
    if dish_exists(p_dish_id) = 0 then
        raise_application_error(-20001, 'блюдо с id ' || p_dish_id || ' не найдено или недоступно');
    end if;
    
    update dishes set
        dish_name = nvl(p_dish_name, dish_name),
        category_id = nvl(p_category_id, category_id),
        composition = nvl(p_composition, composition),
        weight = nvl(p_weight, weight),
        price = nvl(p_price, price),
        is_available = nvl(p_is_available, is_available),
        is_seasonal = nvl(p_is_seasonal, is_seasonal)
    where dish_id = p_dish_id;
    
    commit;
    dbms_output.put_line('блюдо обновлено');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end update_dish;
/
--удаление блюда из меню
create or replace procedure delete_dish(
    p_dish_id number
) as
    v_count number;
begin
    if dish_exists(p_dish_id) = 0 then
        raise_application_error(-20001, 'блюдо с id ' || p_dish_id || ' не найдено');
    end if;
    
    -- есть ли блюдо в незакрытых заказах
    select count(*) into v_count
    from order_items oi
    join orders o on oi.order_id = o.order_id
    where oi.dish_id = p_dish_id
    and o.status != 'closed';
    
    if v_count > 0 then
        raise_application_error(-20003, 'нельзя удалить блюдо: оно есть в активных заказах');
    end if;
    
    delete from dishes where dish_id = p_dish_id;
    
    commit;
    dbms_output.put_line('блюдо удалено');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end delete_dish;
/
--просмотр всех блюд с краткой инфой + возможность фильтровать по блюдам
create or replace procedure view_all_dishes(
    p_category_name nvarchar2 default null
) as
begin
    dbms_output.put_line('все блюда');
    for rec in (
        select d.dish_id, d.dish_name, c.category_name, d.price, 
               case when d.is_available = 1 then 'доступно' else 'недоступно' end as status
        from dishes d
        join dish_categories c on d.category_id = c.category_id
        where (p_category_name is null or upper(c.category_name) = upper(p_category_name))
        order by c.category_name, d.dish_name
    ) loop
        dbms_output.put_line(rec.dish_id || ' | ' || rec.dish_name || ' | ' || rec.category_name || ' | ' || rec.price || ' руб. | ' || rec.status);
    end loop;
end view_all_dishes;
/
--сухой просмотр всего меню 
create or replace procedure view_full_menu as
begin
    dbms_output.put_line('полное меню');
    for rec in (
        select d.dish_id,
               c.category_name, 
               d.dish_name, 
               d.price, 
               d.composition,      
               d.weight,
               d.is_available, 
               d.is_seasonal, 
               d.popularity
        from dishes d
        join dish_categories c on d.category_id = c.category_id
        order by c.category_name, d.dish_name
    ) loop
        dbms_output.put_line(rec.dish_id || ' | ' || rec.category_name || ' | ' || rec.dish_name);
        dbms_output.put_line('  состав: ' || nvl(rec.composition, 'не указан'));
        dbms_output.put_line('  цена: ' || rec.price || ' руб. | вес: ' || nvl(rec.weight, 0) || 'г');
        dbms_output.put_line('  доступно: ' || case when rec.is_available = 1 then 'да' else 'нет' end);
        dbms_output.put_line('  сезонное: ' || case when rec.is_seasonal = 1 then 'да' else 'нет' end);
        dbms_output.put_line('  популярность: ' || nvl(rec.popularity, 0));
        dbms_output.put_line('---');
    end loop;
end view_full_menu;
----------------------------------------------------------------------------
--добавить категорию
create or replace procedure add_category(
    p_category_name nvarchar2,
    p_new_id out number
) as
begin
    insert into dish_categories (category_name)
    values (p_category_name)
    returning category_id into p_new_id;
    
    commit;
    dbms_output.put_line('категория добавлена. id: ' || p_new_id);
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end add_category;
/
--изменение названия категории
create or replace procedure update_category(
    p_category_id number,
    p_category_name nvarchar2
) as
begin
    update dish_categories set
        category_name = p_category_name
    where category_id = p_category_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20001, 'категория с id ' || p_category_id || ' не найдена');
    end if;
    
    commit;
    dbms_output.put_line('категория обновлена');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end update_category;
/
--удаление категории
create or replace procedure delete_category(
    p_category_id number
) as
begin
    -- есть ли блюда в этой категории
    declare
        v_count number;
    begin
        select count(*) into v_count from dishes where category_id = p_category_id;
        if v_count > 0 then
            raise_application_error(-20004, 'нельзя удалить категорию: в ней есть блюда');
        end if;
    end;
    
    delete from dish_categories where category_id = p_category_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20001, 'категория с id ' || p_category_id || ' не найдена');
    end if;
    
    commit;
    dbms_output.put_line('категория удалена');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end delete_category;
/
--просмотр категорий
create or replace procedure view_categories as
begin
    dbms_output.put_line('категории блюд');
    for rec in (select category_id, category_name from dish_categories order by category_name) loop
        dbms_output.put_line(rec.category_id || ' | ' || rec.category_name);
    end loop;
end view_categories;
/
-------------------------------------------------------------------------------------
-- добавление нового сотрудника
create or replace procedure hire_employee(
    p_full_name nvarchar2,
    p_position_id number,
    p_restaurant_id number,
    p_salary number,
    p_hire_date date,
    p_training_info nvarchar2 default null,
    p_new_id out number
) as
begin
    if p_salary < 0 then
        raise_application_error(-20006, 'зарплата не может быть отрицательной');
    end if;
    
    if p_hire_date > sysdate then
        raise_application_error(-20041, 'дата приёма не может быть позже текущей даты');
    end if;
    
    insert into employees (full_name, position_id, restaurant_id, salary, hire_date, is_active, training_info)
    values (p_full_name, p_position_id, p_restaurant_id, p_salary, p_hire_date, 1, p_training_info)
    returning employee_id into p_new_id;
    
    commit;
    dbms_output.put_line('сотрудник принят. id: ' || p_new_id);
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end hire_employee;
/
--назначение должности
create or replace procedure assign_position(
    p_employee_id number,
    p_new_position_id number,
    p_new_salary number default null
) as
begin
    update employees set
        position_id = p_new_position_id,
        salary = nvl(p_new_salary, salary)
    where employee_id = p_employee_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20001, 'сотрудник с id ' || p_employee_id || ' не найден');
    end if;
    
    commit;
    dbms_output.put_line('должность сотрудника изменена');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end assign_position;
/
--просмотр должностей
create or replace procedure view_positions as
begin
    dbms_output.put_line('список должностей');
    for rec in (select position_id, position_name, default_salary from positions order by position_name) loop
        dbms_output.put_line(rec.position_id || ' | ' || rec.position_name || ' | ' || rec.default_salary || ' руб.');
    end loop;
end view_positions;
/
--увольнение сотрудника
create or replace procedure fire_employee(
    p_employee_id number,
    p_termination_date date
) as
    v_is_active number;
    v_count number;
begin
    --существует ли сотрудник и активен ли он
    select is_active into v_is_active
    from employees
    where employee_id = p_employee_id;
    
    if v_is_active = 0 then
        raise_application_error(-20007, 'сотрудник уже уволен');
    end if;
    
    --есть ли у сотрудника будущие смены
    select count(*) into v_count
    from shifts
    where employee_id = p_employee_id
    and start_time > systimestamp;
    
    if v_count > 0 then
        raise_application_error(-20005, 'нельзя уволить сотрудника: у него есть будущие смены');
    end if;
    
    update employees set
        termination_date = p_termination_date,
        is_active = 0
    where employee_id = p_employee_id;
    
    commit;
    dbms_output.put_line('сотрудник уволен');
exception
    when no_data_found then
        rollback;
        raise_application_error(-20001, 'сотрудник с id ' || p_employee_id || ' не найден');
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end fire_employee;
/
--обновление зарплаты
create or replace procedure update_salary(
    p_employee_id number,
    p_new_salary number
) as
begin
    if p_new_salary < 0 then
        raise_application_error(-20006, 'зарплата не может быть отрицательной');
    end if;
    
    update employees set
        salary = p_new_salary
    where employee_id = p_employee_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20001, 'сотрудник с id ' || p_employee_id || ' не найден');
    end if;
    
    commit;
    dbms_output.put_line('зарплата изменена');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end update_salary;
/
--обновление сотрудника
create or replace procedure update_employee(
    p_employee_id number,
    p_full_name nvarchar2 default null,
    p_position_id number default null,
    p_restaurant_id number default null,
    p_salary number default null,
    p_hire_date date default null,
    p_training_info nvarchar2 default null,
    p_is_active number default null
) as
    v_old_is_active number;
    v_old_hire_date date;
begin
    --существует ли сотрудник
    begin
        select is_active, hire_date 
        into v_old_is_active, v_old_hire_date
        from employees 
        where employee_id = p_employee_id;
    exception
        when no_data_found then
            raise_application_error(-20001, 'сотрудник с id ' || p_employee_id || ' не найден');
    end;
    
    -- проверка зарплаты
    if p_salary is not null and p_salary < 0 then
        raise_application_error(-20006, 'зарплата не может быть отрицательной');
    end if;
    
    -- проверка даты приёма
    if p_hire_date is not null and p_hire_date > sysdate then
        raise_application_error(-20041, 'дата приёма не может быть позже текущей даты');
    end if;
    
    -- если увольняют, то нужно заполнить termination_date
    if p_is_active = 0 and v_old_is_active = 1 then
        update employees set
            full_name = nvl(p_full_name, full_name),
            position_id = nvl(p_position_id, position_id),
            restaurant_id = nvl(p_restaurant_id, restaurant_id),
            salary = nvl(p_salary, salary),
            hire_date = nvl(p_hire_date, hire_date),
            training_info = nvl(p_training_info, training_info),
            is_active = p_is_active,
            termination_date = sysdate
        where employee_id = p_employee_id;
    
    -- если восстанавливают уволенного
    elsif p_is_active = 1 and v_old_is_active = 0 then
        update employees set
            full_name = nvl(p_full_name, full_name),
            position_id = nvl(p_position_id, position_id),
            restaurant_id = nvl(p_restaurant_id, restaurant_id),
            salary = nvl(p_salary, salary),
            hire_date = nvl(p_hire_date, hire_date),
            training_info = nvl(p_training_info, training_info),
            is_active = p_is_active,
            termination_date = null
        where employee_id = p_employee_id;
    
    -- обычное обновление без изменения статуса
    else
        update employees set
            full_name = nvl(p_full_name, full_name),
            position_id = nvl(p_position_id, position_id),
            restaurant_id = nvl(p_restaurant_id, restaurant_id),
            salary = nvl(p_salary, salary),
            hire_date = nvl(p_hire_date, hire_date),
            training_info = nvl(p_training_info, training_info),
            is_active = nvl(p_is_active, is_active)
        where employee_id = p_employee_id;
    end if;
    
    commit;
    dbms_output.put_line('данные сотрудника обновлены');
    
    -- дополнительный вывод информации при смене статуса
    if p_is_active = 0 and v_old_is_active = 1 then
        dbms_output.put_line('сотрудник уволен');
    elsif p_is_active = 1 and v_old_is_active = 0 then
        dbms_output.put_line('сотрудник восстановлен');
    end if;
    
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end update_employee;
/
--просмотр всех сотрудников
create or replace procedure view_all_employees(
    p_restaurant_id number default null
) as
begin
    dbms_output.put_line('список сотрудников');
    for rec in (
        select e.employee_id, e.full_name, p.position_name, r.name as restaurant_name,
               e.salary, e.hire_date, case when e.is_active = 1 then 'активен' else 'уволен' end as status
        from employees e
        join positions p on e.position_id = p.position_id
        join restaurants r on e.restaurant_id = r.restaurant_id
        where (p_restaurant_id is null or e.restaurant_id = p_restaurant_id)
        order by e.full_name
    ) loop
        dbms_output.put_line(rec.employee_id || ' | ' || rec.full_name || ' | ' || rec.position_name || ' | ' || rec.status);
    end loop;
end view_all_employees;
/
---------------------------------------------------------------------------------
create or replace procedure add_position(
    p_position_name nvarchar2,
    p_default_salary number,
    p_new_id out number
) as
begin
    insert into positions (position_name, default_salary)
    values (p_position_name, p_default_salary)
    returning position_id into p_new_id;
    
    commit;
    dbms_output.put_line('должность добавлена. id: ' || p_new_id);
exception
    when dup_val_on_index then
        rollback;
        dbms_output.put_line('ошибка: должность уже существует');
        raise;
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end add_position;
/

create or replace procedure update_position(
    p_position_id number,
    p_position_name nvarchar2 default null,
    p_default_salary number default null
) as
begin
    update positions set
        position_name = nvl(p_position_name, position_name),
        default_salary = nvl(p_default_salary, default_salary)
    where position_id = p_position_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20051, 'должность с id ' || p_position_id || ' не найдена');
    end if;
    
    commit;
    dbms_output.put_line('должность обновлена');
exception
    when dup_val_on_index then
        rollback;
        raise_application_error(-20052, 'должность с таким названием уже существует');
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end update_position;
/
-- удаление должности
create or replace procedure delete_position(
    p_position_id number
) as
    v_count number;
begin
    -- проверка: есть ли сотрудники с этой должностью
    select count(*) into v_count
    from employees
    where position_id = p_position_id;
    
    if v_count > 0 then
        raise_application_error(-20053, 'нельзя удалить должность: есть сотрудники с этой должностью');
    end if;
    
    delete from positions where position_id = p_position_id;
    
    if sql%rowcount = 0 then
        raise_application_error(-20051, 'должность с id ' || p_position_id || ' не найдена');
    end if;
    
    commit;
    dbms_output.put_line('должность удалена');
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end delete_position;
/
--------------------------------------------------------------------------------
create or replace procedure create_financial_report(
    p_restaurant_id number,
    p_report_period_start date,
    p_report_period_end date,
    p_report_type varchar2,
    p_new_id out number
) as
begin
    insert into financial_reports (restaurant_id, report_period_start, report_period_end, report_type)
    values (p_restaurant_id, p_report_period_start, p_report_period_end, p_report_type)
    returning report_id into p_new_id;
    
    commit;
    dbms_output.put_line('финансовый отчёт создан. id: ' || p_new_id);
exception
    when others then
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end create_financial_report;
/

create or replace procedure view_financial_reports(
    p_restaurant_id number default null,
    p_report_type varchar2 default null
) as
    cursor c_reports is
        select fr.report_id, r.name as restaurant_name, fr.report_period_start,
               fr.report_period_end, fr.generation_date, fr.report_type
        from financial_reports fr
        join restaurants r on fr.restaurant_id = r.restaurant_id
        where (p_restaurant_id is null or fr.restaurant_id = p_restaurant_id)
          and (p_report_type is null or fr.report_type = p_report_type)
        order by fr.generation_date desc;
begin
    dbms_output.put_line('список финансовых отчётов');
    for rec in c_reports loop
        dbms_output.put_line('id: ' || rec.report_id ||
                           ' | ресторан: ' || rec.restaurant_name ||
                           ' | период: ' || to_char(rec.report_period_start, 'dd.mm.yyyy') || ' - ' || to_char(rec.report_period_end, 'dd.mm.yyyy') ||
                           ' | тип: ' || rec.report_type ||
                           ' | создан: ' || to_char(rec.generation_date, 'dd.mm.yyyy hh24:mi'));
    end loop;
    
    if c_reports%notfound then
        dbms_output.put_line('отчёты не найдены');
    end if;
end view_financial_reports;
/







