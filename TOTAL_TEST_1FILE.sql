-- АДМИН

declare
    v_rest_id number;
    v_pos_id number;
    v_emp_id number;
begin
    db_developer.add_restaurant('Ролналдо-суши', 'ул. пушкина 10', '+375291112233', '10:00-23:00', '111222333', v_rest_id);--44
    db_developer.add_position('тестовый старший менеджер ресторана', 1500, v_pos_id);--44
    db_developer.hire_employee('Роналдо Роман Викторович', v_pos_id, v_rest_id, 2900, date '2025-01-15', null, v_emp_id);--84
end;
/

-- ошибка пустое имя ресторана
declare
    v_id number;
begin
    db_developer.add_restaurant(null, 'ул. тестовая', '+375291234567', null, null, v_id);
end;
/

-- ошибка отрицательная зарплата
declare
    v_id number;
begin
    db_developer.hire_employee('тест', 10, 4, -500, sysdate, null, v_id);
end;
/

declare
    v_cat_id number;
    v_dish_id number;
begin
    db_developer.add_category('футбольное меню', v_cat_id);
    db_developer.add_dish('коктель мячик', v_cat_id, 'водка, вода', 280, 29.99, 1, 1, v_dish_id);
end;
/

declare 
v_dish_id number;
begin
 db_developer.add_dish('второе', 81, 'водка, вода', 280, 29.99, 1, 1, v_dish_id);
 end;
 /

-- ошибка дубликат категории
declare
    v_id number;
begin
    db_developer.add_category('футбольное меню', v_id);
end;
/

begin
    db_developer.view_restaurants;
    db_developer.view_categories;
    db_developer.view_positions;
end;
/

-- обновление
begin
    db_developer.update_restaurant(44, 'защита обновленная- Роналдо', null, '+375297777777', '10:00-00:00', null);
    db_developer.update_category(63, 'Футбольный чемпионат');
    db_developer.update_position(44, 'старший тестовый менеджер ресторана ', 1800);
end;
/

begin
    db_developer.view_full_menu;
end;
/

begin
    db_developer.update_dish(303, 'футбольный лимонад', 61, 'лимонад', 320, 29.99, 1, 1);
    db_developer.view_all_dishes('Футбольный чемпионат');
    db_developer.view_full_menu;
end;
/

begin
db_developer.view_all_employees();
end;
/

begin
    --db_developer.assign_position(84, 13, 3000);
    db_developer.update_salary(101, 3500);
    --db_developer.view_all_employees();
end;
/


begin
    db_developer.fire_employee(30, sysdate);
    db_developer.update_employee(29, 'Пилиппова татьяна алексеевна', null, null, null, null, 'курсы повышения', null);
    db_developer.update_employee(30, null, null, null, null, null, null, 1);
end;
/
--ошибка
begin
    db_developer.fire_employee(20, sysdate);
end;
/

-- удаление блюда без заказов
begin
    db_developer.delete_dish(303);
end;
/

-- удаление категории без блюд
begin
    db_developer.delete_category(63);
end;
/


begin
    db_developer.export_menu_to_json('menu_export.json');
    db_developer.import_menu_from_json('menu_export.json');
end;
/

-- МЕНЕДЖЕР

-- смена сотруднику
declare
    v_shift_id number;
begin
    db_developer.create_shift(84, timestamp '2026-05-04 09:00:00', timestamp '2026-05-04 18:00:00', 44, v_shift_id);
end;
/


-- ошибка начало позже конца
declare
    v_id number;
begin
    db_developer.create_shift(84, timestamp '2025-05-01 18:00:00', timestamp '2025-05-01 09:00:00', 44, v_id);
end;
/

begin
    db_developer.assign_employee_to_shift(65, 26);
    db_developer.update_shift(65, timestamp '2026-06-01 10:00:00', timestamp '2026-06-01 19:00:00', null);
    db_developer.show_employee_shifts;
    db_developer.cancel_shift(65);
end;
/


-- инциденты
declare
    v_inc_id number;
begin
    db_developer.add_incident('гость поскользнулся на мокром полу', 81, null, sysdate, v_inc_id);
    db_developer.update_incident(v_inc_id, null, 'вызвали скорую, оказали помощь');
    db_developer.show_incidents;
end;
/

begin
db_developer.view_all_reservations;
end;
/

-- бронирования
begin
    db_developer.confirm_reservation(101);
    --db_developer.reschedule_reservation(8, timestamp '2026-06-15 20:00:00', 44);
    --db_developer.show_today_reservations;
    --db_developer.view_all_reservations('confirmed', date '2026-06-01', date '2026-06-30');
end;
/


-- клиенты
declare
    v_client_id number;
begin
    db_developer.add_client('сидоров иван петрович', '+375291234567', date '1990-01-01', v_client_id);
    db_developer.update_client(v_client_id, 'сидоров иван иванович', '+375297654321', date '1990-05-15');
    db_developer.show_clients_list;
    db_developer.delete_client(v_client_id);
end;
/

-- активные сотрудники
begin
    db_developer.show_active_employees('сакура');
end;
/

-- КЛИЕНТ

-- регистрация вход бронирование отзыв
declare
    v_client_id number;
    v_name nvarchar2(100);
    v_reserv_id number;
    v_review_id number;
begin
    db_developer.register_client('Юра Иновко', '+375290336655', 'yra@mail.com', '1111', date '1998-06-01', v_client_id);
    db_developer.login_client('yra@mail.com', '1111', v_client_id, v_name);
    db_developer.create_reservation(v_client_id, 44, timestamp '2026-06-01 19:00:00', 4, 'день рождения', v_reserv_id);
    db_developer.add_review(v_client_id, 44, 5, 'потрясающие роллы!', sysdate, v_review_id);
end;
/

declare
    v_id number;
begin
    db_developer.register_client('тест', '+375299999999', 'diana@mail.com', '5678', null, v_id);
end;
/

-- просмотр меню и блюд
begin
    db_developer.show_menu;
end;
/

-- просмотр своих броней, отзывов, заказов
begin
    db_developer.view_my_reservations(14);
    db_developer.view_my_reviews(14);
    db_developer.view_my_orders(14);
end;
/

-- профиль
begin
    db_developer.view_my_profile(66);
    db_developer.update_my_profile(66, 'Юрка РодныйЫ', '+375294445566', date '1998-08-20');
    db_developer.view_my_profile(66);
end;
/

-- смена пароля и вход с новым
declare
    v_id number;
    v_name nvarchar2(100);
begin
    db_developer.change_my_password(66, '1111', 'newpass');
    db_developer.login_client('yra@mail.com', 'newpass', v_id, v_name);
end;
/

declare 
v_review_id number;
begin
db_developer.add_review(10, 4, 5, 'потрясающие роллы!', sysdate, v_review_id);
end;
/


-- отзывы
begin
    db_developer.update_my_review(66, 64, 5, 'обслуживание на высоте!');
    db_developer.delete_my_review(66, 64);
    db_developer.show_published_reviews;
end;
/

-- отмена бронирования клиентом
declare
    v_reserv_id number;
begin
    db_developer.create_reservation(10, 4, timestamp '2026-06-10 19:00:00', 3, 'у окна', v_reserv_id);
    --db_developer.cancel_reservation_client(66, v_reserv_id);
end;
/

-- МЕНЕДЖЕР (заказы и отзывы)

-- полный цикл заказа
declare
    v_order_id number;
    v_item_id number;
    v_check_id number;
begin
    db_developer.create_order(22, 10, 'без соли', v_order_id);
    db_developer.add_order_item(v_order_id, 12, 2, null, v_item_id);
    db_developer.submit_order_to_kitchen(v_order_id);
    db_developer.close_order(v_order_id, 'card', 17, v_check_id);
end;
/


-- просмотр заказов и деталей
begin
    db_developer.view_open_orders;
    db_developer.view_kitchen_orders;
    db_developer.view_client_orders(66);
    db_developer.view_order_details(66);
end;
/
begin
db_developer.show_pending_reviews;
end;
/
-- модерация отзыва
begin
    db_developer.show_pending_reviews;
    db_developer.approve_review(81, 101, 1);
    --db_developer.delete_review(64, 22);
end;
/


-- АДМИН (финансы)

-- отчёт
begin
    db_developer.generate_monthly_report('2025-04', 4);
    db_developer.view_financial_reports;
end;
/


commit;