-- 1. регистрация новых клиентов
declare
    v_id number;
begin
    db_developer.register_client('иванов иван иванович', '+375291234567', 'ivanchick@mail.com', '1234', date '1990-05-15', v_id);
end;
/

declare
    v_id number;
begin
    db_developer.register_client('петрова анна сергеевна', '+375297654321', 'anna@mail.com', '4567', date '1995-10-20', v_id);
end;
/

declare
    v_id number;
begin
    db_developer.register_client('соколов дмитрий алексеевич', '+375293331122', 'dima@mail.com', '7890', date '1988-03-07', v_id);
end;
/

-- 1.1 регистрация с существующим email (ошибка)
declare
    v_id number;
begin
    db_developer.register_client('тестовый тест', '+375299999999', 'ivan@mail.com', '1234', null, v_id);
end;
/

-- 1.2 регистрация с коротким паролем (ошибка)
declare
    v_id number;
begin
    db_developer.register_client('тестовый тест', '+375299999999', 'test@mail.com', '123', null, v_id);
end;
/

-- 1.3 регистрация без email (ошибка)
declare
    v_id number;
begin
    db_developer.register_client('тестовый тест', '+375299999999', null, '1234', null, v_id);
end;
/

-- 2. вход клиентов
declare
    v_id number;
    v_name nvarchar2(100);
begin
    db_developer.login_client('ivan@mail.com', '1234', v_id, v_name);
    dbms_output.put_line('вошли как: ' || v_name || ', id: ' || v_id);
end;
/

declare
    v_id number;
    v_name nvarchar2(100);
begin
    db_developer.login_client('anna@mail.com', '4567', v_id, v_name);
    dbms_output.put_line('вошли как: ' || v_name || ', id: ' || v_id);
end;
/

declare
    v_id number;
    v_name nvarchar2(100);
begin
    db_developer.login_client('ivan@mail.com', 'wrong', v_id, v_name);
end;
/

-- 2.2 вход с несуществующим email (ошибка)
declare
    v_id number;
    v_name nvarchar2(100);
begin
    db_developer.login_client('noexist@mail.com', '1234', v_id, v_name);
end;
/

-- 3. просмотр меню
begin
    db_developer.show_menu;
end;
/

begin
    db_developer.show_menu('суши');
end;
/

begin
    db_developer.show_menu('напитки');
end;
/

-- 4. просмотр доступных блюд
begin
    db_developer.show_available_dishes;
end;
/

begin
    db_developer.show_available_dishes(1);
end;
/

-- 5. просмотр опубликованных отзывов
begin
    db_developer.show_published_reviews;
end;
/

begin
    db_developer.show_published_reviews(4);
end;
/

-- 6. создание бронирования 
declare
    v_id number;
begin
    db_developer.create_reservation(21, 4, timestamp '2026-06-10 19:00:00', 4, 'столик у окна', v_id);
end;
/

-- 6.1 создание бронирования с несуществующим клиентом
declare
    v_id number;
begin
    db_developer.create_reservation(999, 4, timestamp '2026-06-10 19:00:00', 4, null, v_id);
end;
/

-- 6.2 создание бронирования с несуществующим рестораном
declare
    v_id number;
begin
    db_developer.create_reservation(21, 999, timestamp '2026-06-10 19:00:00', 4, null, v_id);
end;
/

-- 6.3 создание бронирования с количеством гостей 0 (ошибка)
declare
    v_id number;
begin
    db_developer.create_reservation(21, 4, timestamp '2026-06-10 19:00:00', 0, null, v_id);
end;
/

-- 6.4 создание бронирования на прошедшее время (ошибка)
declare
    v_id number;
begin
    db_developer.create_reservation(17, 4, timestamp '2024-01-01 19:00:00', 4, null, v_id);
end;
/

-- 7. просмотр своих бронирований
begin
    db_developer.view_my_reservations(21);
end;
/



-- 8. отмена бронирования клиентом
begin
    db_developer.cancel_reservation_client(21, 21);
end;
/

-- 8.1 отмена чужого бронирования (ошибка)
begin
    db_developer.cancel_reservation_client(18, 2);
end;
/

-- 8.2 отмена несуществующего бронирования
begin
    db_developer.cancel_reservation_client(17, 999);
end;
/

-- 9. добавление отзыва (клиент 17)
declare
    v_id number;
begin
    db_developer.add_review(21, 4, 5, 'всё отлично, очень вкусно!', date '2025-05-10', v_id);
end;
/

declare
    v_id number;
begin
    db_developer.add_review(21, 5, 4, 'хороший ресторан, но долго ждали', date '2025-05-15', v_id);
end;
/

-- 9.1 добавление отзыва с оценкой 6 (ошибка)
declare
    v_id number;
begin
    db_developer.add_review(21, 4, 6, 'тест', sysdate, v_id);
end;
/

-- 9.2 добавление отзыва с пустым текстом (ошибка)
declare
    v_id number;
begin
    db_developer.add_review(21, 4, 5, '', sysdate, v_id);
end;
/

-- 10. просмотр своих отзывов
begin
    db_developer.view_my_reviews(21);
end;
/

-- 11. просмотр своих заказов 
begin
    db_developer.view_my_orders(21);
end;
/

-- 12. изменение своего отзыва (пока в статусе pending)
begin
    db_developer.update_my_review(21, 21, 5, 'всё отлично, очень вкусно! обслуживание на высоте');
end;
/

-- 12.1 изменение не своего отзыва (ошибка)
begin
    db_developer.update_my_review(21, 2, 4, 'попытка изменить чужой отзыв');
end;
/

-- 13. удаление своего отзыва
begin
    db_developer.delete_my_review(21, 21);
end;
/

-- 13.1 удаление не своего отзыва (ошибка)
begin
    db_developer.delete_my_review(21,21);
end;
/

-- 14. просмотр профиля
begin
    db_developer.view_my_profile(22);
end;
/

-- 14.1 просмотр несуществующего профиля (ошибка)
begin
    db_developer.view_my_profile(999);
end;
/

-- 15. редактирование профиля
begin
    db_developer.update_my_profile(22, 'иванов иван петрович', '+375291234568', date '1990-05-15');
end;
/

-- 15.1 редактирование несуществующего профиля 
begin
    db_developer.update_my_profile(999, 'тест', null, null);
end;
/

-- 16. просмотр профиля после изменений
begin
    db_developer.view_my_profile(22);
end;
/

-- 17. изменение пароля
begin
    db_developer.change_my_password(9, '1234', 'newpass123');
end;
/

-- 17.1 изменение пароля с неверным старым паролем (ошибка)
begin
    db_developer.change_my_password(9, 'wrong', 'newpass123');
end;
/

-- 17.2 изменение пароля с коротким новым паролем (ошибка)
begin
    db_developer.change_my_password(9, 'newpass123', '123');
end;
/

-- 18. вход с новым паролем
declare
    v_id number;
    v_name nvarchar2(100);
begin
    db_developer.login_client('ivan@mail.com', '1234', v_id, v_name);
end;
/


-- 20. просмотр своих заказов после добавления
begin
    db_developer.view_my_orders(9);
end;
/

begin
    db_developer.view_my_reservations(9);
end;
/

begin
    db_developer.cancel_reservation_client(9, 1);
end;
/

-- 21.1 удаление аккаунта с неверным паролем (ошибка)
begin
    db_developer.delete_my_account(9, 'wrong');
end;
/

-- 21.2 удаление аккаунта с правильным паролем
begin
    db_developer.delete_my_account(9, 'newpass123');
end;
/

-- 22. попытка входа в удалённый аккаунт (ошибка или пометка удалён)
declare
    v_id number;
    v_name nvarchar2(100);
begin
    db_developer.login_client('ivan@mail.com', 'newpass123', v_id, v_name);
end;
/

-- 23. просмотр удалённого профиля
begin
    db_developer.view_my_profile(9);
end;
/

commit;