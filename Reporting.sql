create or replace procedure generate_monthly_report(
    p_month varchar2,
    p_restaurant_id number
) as
    v_file utl_file.file_type;
    v_total_revenue number := 0;
    v_total_orders number := 0;
    v_avg_check number := 0;
    v_month_name varchar2(50);
    v_start_date date;
    v_end_date date;
    v_report_id number;
    v_restaurant_name varchar2(100);
begin
    -- проверка существования ресторана
    begin
        select name into v_restaurant_name
        from restaurants
        where restaurant_id = p_restaurant_id;
    exception
        when no_data_found then
            raise_application_error(-20001, 'ресторан с id ' || p_restaurant_id || ' не найден');
    end;
    
    v_month_name := to_char(to_date(p_month || '-01', 'yyyy-mm-dd'), 'Month yyyy');
    v_start_date := to_date(p_month || '-01', 'yyyy-mm-dd');
    v_end_date := last_day(v_start_date);
    
    -- проверка корректности месяца
    if v_start_date is null then
        raise_application_error(-20008, 'неверный формат месяца, используйте гггг-мм');
    end if;

    select count(distinct o.order_id),
       nvl(sum(calculate_order_total(o.order_id)), 0)
        into v_total_orders, v_total_revenue
        from orders o
        join employees e on o.employee_id = e.employee_id
        where o.status = 'closed'
          and to_char(o.order_date, 'yyyy-mm') = p_month
          and e.restaurant_id = p_restaurant_id;

    if v_total_orders > 0 then
        v_avg_check := v_total_revenue / v_total_orders;
    end if;

    -- запись в таблицу financial_reports
    insert into financial_reports (restaurant_id, report_period_start, report_period_end, report_type)
    values (p_restaurant_id, v_start_date, v_end_date, 'sales')
    returning report_id into v_report_id;
    
    commit;

    v_file := utl_file.fopen('REPORT_DIR', 'official_report_' || p_month || '_rest_' || p_restaurant_id || '.txt', 'w', 32767);

    utl_file.put_line(v_file, 'отчёт о результатах деятельности ресторана ' || v_restaurant_name || ' за ' || upper(trim(v_month_name)));
    utl_file.put_line(v_file, '');

    utl_file.put_line(v_file,
        'за отчётный период было закрыто ' || v_total_orders ||
        ' заказов на общую сумму ' || to_char(v_total_revenue, '999G999G990D00') ||
        ' руб. средний чек составил ' || to_char(v_avg_check, '999G999G990D00') || ' руб.'
    );
    utl_file.put_line(v_file, '');

    for rec in (
        select c.category_name,
               sum(oi.quantity) as total_qty,
               sum(oi.quantity * oi.price_at_moment) as revenue
        from order_items oi
        join orders o on oi.order_id = o.order_id --позиция с заказом
        join employees e on o.employee_id = e.employee_id --заказ с сотрудником
        join dishes d on oi.dish_id = d.dish_id --блюдо с заказом
        join dish_categories c on d.category_id = c.category_id --блюдо с категорией
        where o.status = 'closed'
          and to_char(o.order_date, 'yyyy-mm') = p_month
          and e.restaurant_id = p_restaurant_id
        group by c.category_name
        order by revenue desc
    ) loop
        utl_file.put_line(v_file,
            'по категории "' || rec.category_name || '" реализовано ' ||
            rec.total_qty || ' единиц продукции на сумму ' ||
            to_char(rec.revenue, '999G999G990D00') || ' руб.'
        );
    end loop;

    utl_file.put_line(v_file, '');
    utl_file.put_line(v_file,
        'наибольшим спросом пользовались:'
    );

    for rec in (
        select d.dish_name,
               sum(oi.quantity) as total_quantity
        from order_items oi
        join orders o on oi.order_id = o.order_id
        join employees e on o.employee_id = e.employee_id
        join dishes d on oi.dish_id = d.dish_id
        where o.status = 'closed'
          and to_char(o.order_date, 'yyyy-mm') = p_month
          and e.restaurant_id = p_restaurant_id
        group by d.dish_name
        order by total_quantity desc
        fetch first 5 rows only
    ) loop
        utl_file.put_line(v_file,
            rec.dish_name || ' — реализовано ' || rec.total_quantity || ' порций.'
        );
    end loop;

    utl_file.put_line(v_file, '');
    utl_file.put_line(v_file,
        'отчёт сформирован ' || to_char(sysdate, 'dd.mm.yyyy hh24:mi') || '.'
    );

    utl_file.fclose(v_file);

    dbms_output.put_line('отчёт за ' || trim(v_month_name) || ' по ресторану ' || v_restaurant_name || ' сформирован. id записи: ' || v_report_id);
exception
    when others then
        if utl_file.is_open(v_file) then
            utl_file.fclose(v_file);
        end if;
        rollback;
        dbms_output.put_line('ошибка: ' || sqlerrm);
        raise;
end generate_monthly_report;
/