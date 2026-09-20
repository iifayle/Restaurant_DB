set serveroutput on;
declare
    v_id number;
begin
    db_developer.register_client('иванов иван иванович', '+375291234567', 'ivan@mail.com', '1234', date '1990-05-15', v_id);
    db_developer.register_client('петрова анна сергеевна', '+375297654321', 'anna@mail.com', '4546', date '1995-10-20', v_id);
    db_developer.register_client('сидоров сергей алексеевич', '+375293331122', 'sergey@mail.com', '4789', date '1988-03-07', v_id);
    db_developer.register_client('козлова елена владимировна', '+375294441133', 'elena@mail.com', '3421', date '2000-07-25', v_id);
    db_developer.register_client('морозов алексей дмитриевич', '+375295551144', 'alex@mail.com', '6544', date '1992-12-01', v_id);
    db_developer.register_client('новая татьяна игоревна', '+375296661155', 'tatiana@mail.com', '9874', date '1998-04-18', v_id);
    db_developer.register_client('павлов дмитрий николаевич', '+375297771166', 'dmitry@mail.com', '1549', date '1985-09-30', v_id);
end;
/

declare
    v_id number;
begin
    -- клиент 9 бронирует ресторан 4
    db_developer.create_reservation(9, 4, timestamp '2026-05-10 19:00:00', 4, 'столик у окна', v_id);
    db_developer.create_reservation(9, 5, timestamp '2026-05-15 18:30:00', 2, null, v_id);
    
    -- клиент 10 бронирует ресторан 5
    db_developer.create_reservation(10, 5, timestamp '2026-05-11 20:00:00', 6, 'день рождения', v_id);
    
    -- клиент 11 бронирует ресторан 4
    db_developer.create_reservation(11, 4, timestamp '2026-05-12 19:00:00', 2, null, v_id);
    
    -- клиент 12 бронирует ресторан 6
    db_developer.create_reservation(12, 6, timestamp '2026-05-13 18:00:00', 3, null, v_id);
    
    -- клиент 13 бронирует ресторан 5
    db_developer.create_reservation(13, 5, timestamp '2026-05-14 19:30:00', 4, null, v_id);
    
    -- клиент 14 бронирует ресторан 4
    db_developer.create_reservation(14, 4, timestamp '2026-05-16 18:00:00', 2, 'вегетарианское меню', v_id);
    
    -- клиент 15 бронирует ресторан 6
    db_developer.create_reservation(15, 6, timestamp '2026-05-17 19:00:00', 4, null, v_id);
end;
/

declare
    v_id number;
begin
    db_developer.add_review(9, 4, 5, 'всё отлично, очень вкусно!', date '2025-04-10', v_id);
    db_developer.add_review(10, 5, 4, 'хороший ресторан, но долго ждали', date '2025-04-11', v_id);
    db_developer.add_review(11, 4, 5, 'суши великолепные, персонал вежливый', date '2025-04-12', v_id);
    db_developer.add_review(12, 6, 3, 'не понравился суп, слишком соленый', date '2025-04-13', v_id);
    db_developer.add_review(13, 5, 5, 'отличное обслуживание!', date '2025-04-14', v_id);
    db_developer.add_review(14, 4, 4, 'хорошо, но дороговато', date '2025-04-15', v_id);
    db_developer.add_review(15, 6, 5, 'wok просто бомба!', date '2025-04-16', v_id);
end;
/


-- просмотр своего профиля
set serveroutput on size unlimited;
begin
    db_developer.view_my_profile(9);
end;
/

-- просмотр своих заказов
begin
    db_developer.view_my_orders(13);
end;
/

-- просмотр своих отзывов
begin
    db_developer.view_my_reviews(9);
end;
/

-- просмотр своих бронирований
begin
    db_developer.view_my_reservations(9);
end;
/

------------------------------------------------------------
