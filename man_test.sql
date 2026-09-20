set serveroutput on;

declare
    v_id number;
begin
    -- смены для ресторана 4 (азия-хаус)
    db_developer.create_shift(19, timestamp '2025-04-25 09:00:00', timestamp '2025-04-25 18:00:00', 4, v_id);
    db_developer.create_shift(20, timestamp '2025-04-25 10:00:00', timestamp '2025-04-25 19:00:00', 4, v_id);
    db_developer.create_shift(21, timestamp '2025-04-25 11:00:00', timestamp '2025-04-25 20:00:00', 4, v_id);
    db_developer.create_shift(22, timestamp '2025-04-25 12:00:00', timestamp '2025-04-25 21:00:00', 4, v_id);
    db_developer.create_shift(23, timestamp '2025-04-25 10:00:00', timestamp '2025-04-25 19:00:00', 4, v_id);
    
    -- смены для ресторана 5 (восточный экспресс)
    db_developer.create_shift(24, timestamp '2025-04-25 09:00:00', timestamp '2025-04-25 18:00:00', 5, v_id);
    db_developer.create_shift(25, timestamp '2025-04-25 10:00:00', timestamp '2025-04-25 19:00:00', 5, v_id);
    db_developer.create_shift(26, timestamp '2025-04-25 11:00:00', timestamp '2025-04-25 20:00:00', 5, v_id);
    db_developer.create_shift(27, timestamp '2025-04-25 12:00:00', timestamp '2025-04-25 21:00:00', 5, v_id);
    
    -- смены для ресторана 6 (золотой дракон)
    db_developer.create_shift(28, timestamp '2025-04-25 09:00:00', timestamp '2025-04-25 18:00:00', 6, v_id);
    db_developer.create_shift(29, timestamp '2025-04-25 10:00:00', timestamp '2025-04-25 19:00:00', 6, v_id);
    db_developer.create_shift(30, timestamp '2025-04-25 11:00:00', timestamp '2025-04-25 20:00:00', 6, v_id);
    db_developer.create_shift(31, timestamp '2025-04-25 12:00:00', timestamp '2025-04-25 21:00:00', 6, v_id);
end;
/

declare
    v_id number;
begin
    db_developer.add_incident('гость поскользнулся на мокром полу', 23, 'вызвали скорую, оказали помощь', sysdate, v_id);
    db_developer.add_incident('жалоба на холодное блюдо', 27, 'заменили блюдо, принесли извинения', sysdate, v_id);
    db_developer.add_incident('конфликт с гостем', 29, 'предложили скидку, уладили конфликт', sysdate, v_id);
    db_developer.add_incident('опоздание сотрудника на смену', 26, 'вынесено предупреждение', sysdate, v_id);
end;
/

begin
    db_developer.confirm_reservation(1);
    db_developer.confirm_reservation(2);
    db_developer.confirm_reservation(3);
    db_developer.confirm_reservation(4);
    db_developer.confirm_reservation(5);
    db_developer.confirm_reservation(6);
    db_developer.confirm_reservation(7);
end;
/

declare
    v_order_id number;
    v_item_id number;
    v_check_id number;
begin
    -- заказ 1 (клиент 9, сотрудник 22)
    db_developer.create_order(22, 9, 'без лука', v_order_id);
    db_developer.add_order_item(v_order_id, 2, 2, null, v_item_id);   -- суши филадельфия
    db_developer.add_order_item(v_order_id, 8, 1, null, v_item_id);   -- рамэн
    db_developer.submit_order_to_kitchen(v_order_id);
    
    -- заказ 2 (клиент 10, сотрудник 26)
    db_developer.create_order(26, 10, null, v_order_id);
    db_developer.add_order_item(v_order_id, 5, 1, null, v_item_id);   -- ролл дракон
    db_developer.add_order_item(v_order_id, 3, 2, null, v_item_id);   -- суши калифорния
    db_developer.submit_order_to_kitchen(v_order_id);
    
    -- заказ 3 (клиент 11, сотрудник 22)
    db_developer.create_order(22, 11, 'острое блюдо', v_order_id);
    db_developer.add_order_item(v_order_id, 10, 1, null, v_item_id);  -- том ям
    db_developer.add_order_item(v_order_id, 12, 1, null, v_item_id);  -- курица с овощами
    db_developer.submit_order_to_kitchen(v_order_id);
    
    -- заказ 4 (клиент 12, сотрудник 30)
    db_developer.create_order(30, 12, null, v_order_id);
    db_developer.add_order_item(v_order_id, 2, 1, null, v_item_id);   -- суши филадельфия
    db_developer.add_order_item(v_order_id, 15, 1, null, v_item_id);  -- салат с лососем
    db_developer.submit_order_to_kitchen(v_order_id);
    
    -- заказ 5 (клиент 13, сотрудник 26)
    db_developer.create_order(26, 13, 'десерт сразу', v_order_id);
    db_developer.add_order_item(v_order_id, 16, 2, null, v_item_id);  -- лапша удон (если есть)
    db_developer.add_order_item(v_order_id, 17, 1, null, v_item_id);  -- рис с овощами (если есть)
    db_developer.submit_order_to_kitchen(v_order_id);
    
    -- заказ 6 (клиент 14, сотрудник 22)
    db_developer.create_order(22, 14, 'без глютена', v_order_id);
    db_developer.add_order_item(v_order_id, 5, 1, null, v_item_id);   -- ролл дракон
    db_developer.add_order_item(v_order_id, 15, 1, null, v_item_id);  -- салат с лососем
    db_developer.submit_order_to_kitchen(v_order_id);
    
    -- заказ 7 (клиент 15, сотрудник 30)
    db_developer.create_order(30, 15, null, v_order_id);
    db_developer.add_order_item(v_order_id, 6, 1, null, v_item_id);   -- ролл калифорния
    db_developer.add_order_item(v_order_id, 14, 2, null, v_item_id);  -- салат чука
    db_developer.submit_order_to_kitchen(v_order_id);
    
    -- закрываем заказы
    db_developer.close_order(8, 'card', 0, v_check_id);
    db_developer.close_order(2, 'cash', 0, v_check_id);
    db_developer.close_order(3, 'card', 5, v_check_id);
    db_developer.close_order(4, 'cash', 0, v_check_id);
    db_developer.close_order(5, 'card', 10, v_check_id);
    db_developer.close_order(6, 'card', 0, v_check_id);
    db_developer.close_order(7, 'cash', 5, v_check_id);
end;
/

declare
    v_order_id number;
    v_item1_id number;
    v_item2_id number;
begin
    db_developer.create_order(22, 9, 'без лука', v_order_id);
    dbms_output.put_line('заказ создан, id: ' || v_order_id);
    
    db_developer.add_order_item(v_order_id, 2, 2, null, v_item1_id);
    dbms_output.put_line('позиция 1 добавлена, id: ' || v_item1_id);
    
    db_developer.add_order_item(v_order_id, 8, 1, null, v_item2_id);
    dbms_output.put_line('позиция 2 добавлена, id: ' || v_item2_id);
    
    db_developer.submit_order_to_kitchen(v_order_id);
    dbms_output.put_line('заказ отправлен на кухню');
end;
/

begin
    db_developer.view_client_orders(11);
end;
/

begin
    db_developer.view_order_details(100023);
end;
/
begin
    db_developer.view_open_orders;
end;
/
begin
    db_developer.view_kitchen_orders;
end;
/
declare
    v_check_id number;
begin
    db_developer.close_order(100022, 'card', 10, v_check_id);
    dbms_output.put_line('чек id: ' || v_check_id);
end;
/
--------------------------------------------------------------------------------
