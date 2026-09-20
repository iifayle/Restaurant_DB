-- 1. создание смены для сотрудника
declare
    v_id number;
begin
    db_developer.create_shift(19, timestamp '2025-05-01 09:00:00', timestamp '2025-05-01 18:00:00', 4, v_id);
end;
/

declare
    v_id number;
begin
    db_developer.create_shift(20, timestamp '2025-05-01 10:00:00', timestamp '2025-05-01 19:00:00', 4, v_id);
end;
/

declare
    v_id number;
begin
    db_developer.create_shift(24, timestamp '2025-05-02 09:00:00', timestamp '2025-05-02 18:00:00', 5, v_id);
end;
/

-- 1.1 создание смены с пересечением (ошибка)
declare
    v_id number;
begin
    db_developer.create_shift(19, timestamp '2025-05-01 10:00:00', timestamp '2025-05-01 20:00:00', 4, v_id);
end;
/

-- 1.2 создание смены с несуществующим сотрудником
declare
    v_id number;
begin
    db_developer.create_shift(999, timestamp '2025-05-01 09:00:00', timestamp '2025-05-01 18:00:00', 4, v_id);
end;
/

-- 1.3 создание смены с некорректным временем (начало позже конца)
declare
    v_id number;
begin
    db_developer.create_shift(18, timestamp '2025-05-01 18:00:00', timestamp '2025-05-01 09:00:00', 4, v_id);
end;
/

-- 2. назначение сотрудника на существующую смену
begin
    db_developer.assign_employee_to_shift(23, 23);
end;
/

-- 2.1 назначение на несуществующую смену
begin
    db_developer.assign_employee_to_shift(999, 19);
end;
/

-- 2.2 назначение сотрудника, который уже занят в это время
begin
    db_developer.assign_employee_to_shift(2, 19);
end;
/

-- 3. изменение параметров смены
begin
    db_developer.update_shift(1, timestamp '2025-05-01 10:00:00', timestamp '2025-05-01 19:00:00', null);
end;
/

-- 3.1 изменение несуществующей смены
begin
    db_developer.update_shift(999, null, null, null);
end;
/

-- 3.2 изменение смены с пересечением
begin
    db_developer.update_shift(1, timestamp '2025-05-01 08:00:00', timestamp '2025-05-01 20:00:00', null);
end;
/

-- 4. отмена смены
begin
    db_developer.cancel_shift(3);
end;
/

-- 4.1 отмена несуществующей смены
begin
    db_developer.cancel_shift(999);
end;
/

-- 5. просмотр смен сотрудников
begin
    db_developer.show_employee_shifts;
end;
/

begin
    db_developer.show_employee_shifts('иванов', 14);
end;
/

-- 6. добавление инцидента
declare
    v_id number;
begin
    db_developer.add_incident('гость поскользнулся на мокром полу', 23, null, sysdate, v_id);
end;
/

declare
    v_id number;
begin
    db_developer.add_incident('жалоба на холодное блюдо', 27, null, sysdate, v_id);
end;
/

-- 6.1 добавление инцидента с несуществующим сотрудником
declare
    v_id number;
begin
    db_developer.add_incident('тестовый инцидент', 999, null, sysdate, v_id);
end;
/

-- 7. редактирование инцидента (добавление решения)
begin
    db_developer.update_incident(1, null, 'вызвали скорую, оказали помощь');
end;
/

-- 7.1 редактирование несуществующего инцидента
begin
    db_developer.update_incident(999, 'новое описание', 'решение');
end;
/

-- 8. просмотр инцидентов
begin
    db_developer.show_incidents;
end;
/

begin
    db_developer.show_incidents('в работе');
end;
/

-- 9. подтверждение бронирования
begin
    db_developer.confirm_reservation(1);
end;
/

-- 9.1 подтверждение уже подтверждённого бронирования
begin
    db_developer.confirm_reservation(1);
end;
/

-- 9.2 подтверждение несуществующего бронирования
begin
    db_developer.confirm_reservation(999);
end;
/

-- 10. отмена бронирования
begin
    db_developer.cancel_reservation(2);
end;
/

-- 10.1 отмена уже отменённого бронирования
begin
    db_developer.cancel_reservation(2);
end;
/

-- 11. перенос бронирования
begin
    db_developer.reschedule_reservation(3, timestamp '2026-05-20 20:00:00', 5);
end;
/

-- 11.1 перенос несуществующего бронирования
begin
    db_developer.reschedule_reservation(999, timestamp '2026-05-20 20:00:00', null);
end;
/

-- 12. просмотр бронирований на сегодня
begin
    db_developer.show_today_reservations;
end;
/

-- 13. просмотр всех бронирований
begin
    db_developer.view_all_reservations;
end;
/

begin
    db_developer.view_all_reservations('confirmed', date '2026-05-01', date '2026-05-31');
end;
/

-- 14. создание заказа
declare
    v_id number;
begin
    db_developer.create_order(22, 9, 'без лука', v_id);
end;
/

declare
    v_id number;
begin
    db_developer.create_order(26, null, null, v_id);
end;
/

-- 14.1 создание заказа с несуществующим сотрудником
declare
    v_id number;
begin
    db_developer.create_order(999, 10, null, v_id);
end;
/

-- 14.2 создание заказа с несуществующим клиентом
declare
    v_id number;
begin
    db_developer.create_order(22, 999, null, v_id);
end;
/

-- 15. добавление позиции в заказ
declare
    v_id number;
begin
    db_developer.add_order_item(123520, 2, 2, null, v_id);
end;
/

declare
    v_id number;
begin
    db_developer.add_order_item(123519, 8, 1, null, v_id);
end;
/

-- 15.1 добавление позиции в закрытый заказ
declare
    v_id number;
begin
    db_developer.add_order_item(2, 2, 1, null, v_id);
end;
/

-- 15.2 добавление несуществующего блюда
declare
    v_id number;
begin
    db_developer.add_order_item(123520, 999, 1, null, v_id);
end;
/

-- 15.3 добавление позиции с нулевым количеством
declare
    v_id number;
begin
    db_developer.add_order_item(123520, 2, 0, null, v_id);
end;
/

-- 16. передача заказа на кухню
begin
    db_developer.submit_order_to_kitchen(123520);
end;
/

-- 16.1 передача пустого заказа
declare
    v_id number;
begin
    db_developer.create_order(123523, 10, null, v_id);
    db_developer.submit_order_to_kitchen(2);
end;
/

-- 16.2 передача уже переданного заказа
begin
    db_developer.submit_order_to_kitchen(123519);
end;
/

-- 17. закрытие заказа и формирование чека
declare
    v_check_id number;
begin
    db_developer.close_order(123520, 'card', 0, v_check_id);
end;
/

declare
    v_check_id number;
begin
    db_developer.close_order(123522, 'cash', 10, v_check_id);
end;
/

-- 17.2 закрытие заказа со скидкой больше суммы
declare
    v_check_id number;
begin
    db_developer.close_order(123519, 'card', 1000, v_check_id);
end;
/

-- 18. просмотр заказов клиента
begin
    db_developer.view_client_orders(9);
end;
/

begin
    db_developer.view_client_orders(10);
end;
/

-- 18.1 просмотр заказов несуществующего клиента
begin
    db_developer.view_client_orders(999);
end;
/

-- 19. просмотр деталей заказа
begin
    db_developer.view_order_details(32272);
end;
/

-- 19.1 просмотр деталей несуществующего заказа
begin
    db_developer.view_order_details(99999999999);
end;
/

-- 20. просмотр открытых заказов
begin
    db_developer.view_open_orders;
end;
/

-- 21. просмотр заказов на кухне
begin
    db_developer.view_kitchen_orders;
end;
/

-- 22. добавление клиента-гостя (менеджером)
declare
    v_id number;
begin
    db_developer.add_client('сидоров иван петрович', '+375291234567', date '1990-01-01', v_id);
end;
/

-- 22.1 добавление клиента с пустым фио 
declare
    v_id number;
begin
    db_developer.add_client(null, '+375291234568', null, v_id);
end;
/

-- 23. редактирование данных клиента
begin
    db_developer.update_client(21, 'сидоров иван иванович', '+375297654321', 'iva7n@mail.com', date '1990-05-15');
end;
/

-- 23.1 редактирование несуществующего клиента
begin
    db_developer.update_client(999, 'тест', null, null, null);
end;
/

-- 24. удаление клиента (мягкое)
begin
    db_developer.delete_client(21, 0);
end;
/

-- 24.1 удаление несуществующего клиента
begin
    db_developer.delete_client(999, 0);
end;
/

-- 25. просмотр списка клиентов
begin
    db_developer.show_clients_list;
end;
/

begin
    db_developer.show_clients_list(1);
end;
/

-- 26. просмотр активных сотрудников
begin
    db_developer.show_active_employees;
end;
/

begin
    db_developer.show_active_employees('азия');
end;
/

-- 27. просмотр отзывов на модерации
begin
    db_developer.show_pending_reviews;
end;
/

-- 28. одобрение отзыва
begin
    db_developer.approve_review(1, 23, 1);
end;
/

-- 28.1 отклонение отзыва
begin
    db_developer.approve_review(2, 23, 0);
end;
/

-- 28.2 одобрение уже обработанного отзыва
begin
    db_developer.approve_review(1, 23, 1);
end;
/

-- 29. удаление отзыва (можно только pending или rejected)
begin
    db_developer.delete_review(2, 23);
end;
/

-- 29.1 удаление опубликованного отзыва (ошибка)
begin
    db_developer.delete_review(1, 23);
end;
/

-- 29.2 удаление несуществующего отзыва
begin
    db_developer.delete_review(999, 23);
end;
/

commit;