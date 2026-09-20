--управляющий
declare
    v_rest_id number;
    v_pos_id number;
    v_emp_id number;
begin
    db_developer.add_restaurant('самурай', 'ул. пушкина 10', '+375291112233', '10:00-23:00', '111222333', v_rest_id);
    db_developer.add_position('старший официант', 1500, v_pos_id);
    db_developer.hire_employee('демо Ирина Олеговна', v_pos_id, v_rest_id, 2500, date '2025-01-15', null, v_emp_id);
end;
/

declare
    v_cat_id number;
    v_dish_id number;
begin
    db_developer.add_category('фирменные роллы', v_cat_id);
    db_developer.add_dish('ролл сакура', v_cat_id, 'лосось, авокадо, сыр', 280, 24.99, 1, 1, v_dish_id);
end;
/

--менеджер
declare
    v_shift_id number;
begin
    db_developer.create_shift(82, timestamp '2026-05-05 09:00:00', timestamp '2026-05-05 18:00:00', 42, v_shift_id);
end;
/

--клиент
declare
    v_client_id number;
    v_name nvarchar2(100);
    v_reserv_id number;
begin
    db_developer.register_client('Кирилл Смирнов', '+375293335755', 'kirsmir@mail.com', '1111', date '1998-08-20', v_client_id);
    db_developer.login_client('kirsmir@mail.com', '1111', v_client_id, v_name);
    db_developer.create_reservation(v_client_id,42, timestamp '2026-06-01 19:00:00', 4, 'день рождения', v_reserv_id);
end;
/

--ошибка
declare
    v_id number;
begin
    db_developer.create_reservation(62, 4, timestamp '2026-06-06 19:00:00', 2, null, v_id);
end;
/

--менеджер
declare
    v_order_id number;
    v_item_id number;
    v_check_id number;
begin
    db_developer.confirm_reservation(62);
    db_developer.create_order(82, 62, 'без соли', v_order_id);
    db_developer.add_order_item(v_order_id, 21, 2, null, v_item_id);
    db_developer.add_order_item(v_order_id, 20, 1, null, v_item_id);
    db_developer.submit_order_to_kitchen(v_order_id);
    db_developer.close_order(v_order_id, 'card', 10, v_check_id);
end;
/

--ошибка
declare
    v_check_id number;
begin
    db_developer.close_order(999999, 'cash', 0, v_check_id);
end;
/

--клиент
declare
    v_review_id number;
begin
    db_developer.add_review(62, 42, 5, 'потрясающие роллы!', sysdate, v_review_id);
end;
/

--ошибка
declare
    v_id number;
begin
    db_developer.add_review(62, 42, 5, '', sysdate, v_id);
end;
/

--менеджер
declare
    v_inc_id number;
begin
    db_developer.show_pending_reviews;
    db_developer.approve_review(61, 82, 1);
    db_developer.add_incident('опоздание на смену', 82, 'предупреждение', sysdate, v_inc_id);
end;
/

begin
    db_developer.show_today_reservations;
end;
/

--клиент
begin
    db_developer.show_published_reviews;
end;
/
--ошибка
declare
    v_id number;
    v_name nvarchar2(100);
begin
    db_developer.login_client('diana@mail.com', 'wrong', v_id, v_name);
end;
/

--управляющий
begin
    db_developer.update_salary(82, 3000);
    db_developer.fire_employee(61, sysdate);
    db_developer.generate_monthly_report('2026-06', 42);
    db_developer.view_financial_reports;
end;
/

--ошибка
begin
    db_developer.fire_employee(61, sysdate);
end;
/

--ошибка
begin
    db_developer.generate_monthly_report('2026-06', 999);
end;
/

commit;