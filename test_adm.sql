set serveroutput on;

declare
    v_id number;
begin
    db_developer.add_restaurant('азия-хаус', 'ул. советская 15, минск', '+375291234567', '09:00-23:00', '123456789', v_id);
    db_developer.add_restaurant('восточный экспресс', 'пр. независимости 42, минск', '+375292345678', '10:00-22:00', '987654321', v_id);
    db_developer.add_restaurant('золотой дракон', 'ул. кирова 8, гомель', '+375293456789', '11:00-23:00', '456123789', v_id);
end;
/


declare
    v_id number;
begin
    db_developer.add_position('директор', 2500, v_id);
    db_developer.add_position('шеф-повар', 2000, v_id);
    db_developer.add_position('повар', 1200, v_id);
    db_developer.add_position('официант', 900, v_id);
    db_developer.add_position('администратор', 1500, v_id);
    db_developer.add_position('менеджер', 1700, v_id);
    db_developer.add_position('уборщик', 700, v_id);
end;
/


declare
    v_id number;
begin
    -- ресторан 4 (азия-хаус)
    db_developer.hire_employee('иванов иван иванович', 8, 4, 2500, date '2023-01-15', 'высшее образование', v_id);
    db_developer.hire_employee('петров петр петрович', 9, 4, 2000, date '2023-02-01', 'курсы повышения квалификации', v_id);
    db_developer.hire_employee('сидорова анна сергеевна', 10, 4, 1200, date '2023-03-10', 'стажировка пройдена', v_id);
    db_developer.hire_employee('козлов дмитрий алексеевич', 11, 4, 900, date '2023-04-15', null, v_id);
    db_developer.hire_employee('морозова елена владимировна', 12, 4, 1500, date '2023-05-20', 'английский язык', v_id);
    
    -- ресторан 5 (восточный экспресс)
    db_developer.hire_employee('соколов андрей николаевич', 8, 5, 2500, date '2023-06-10', 'высшее образование', v_id);
    db_developer.hire_employee('лебедева мария игоревна', 9, 5, 2000, date '2023-07-01', null, v_id);
    db_developer.hire_employee('павлов алексей владимирович', 10, 5, 1200, date '2023-08-15', 'стажировка', v_id);
    db_developer.hire_employee('новая анна петровна', 11, 5, 900, date '2023-09-01', null, v_id);
    
    -- ресторан 6 (золотой дракон)
    db_developer.hire_employee('васильева ольга ивановна', 8, 6, 2500, date '2024-01-10', 'высшее образование', v_id);
    db_developer.hire_employee('никитин сергей сергеевич', 13, 6, 1700, date '2024-02-15', 'управление персоналом', v_id);
    db_developer.hire_employee('филиппова татьяна алексеевна', 10, 6, 1200, date '2024-03-01', null, v_id);
    db_developer.hire_employee('егоров максим дмитриевич', 11, 6, 900, date '2024-03-20', null, v_id);
end;
/

declare
    v_id number;
begin
    db_developer.add_category('суши', v_id);
    db_developer.add_category('роллы', v_id);
    db_developer.add_category('супы', v_id);
    db_developer.add_category('горячие блюда', v_id);
    db_developer.add_category('салаты', v_id);
    db_developer.add_category('десерты', v_id);
    db_developer.add_category('напитки', v_id);
    db_developer.add_category('wok', v_id);
end;
/

declare
    v_id number;
begin
    -- суши (category_id = 9)
    db_developer.add_dish('суши филадельфия', 9, 'лосось, сыр, огурец', 250, 18.99, 1, 0, v_id);
    db_developer.add_dish('суши калифорния', 9, 'краб, авокадо, огурец', 250, 16.99, 1, 0, v_id);
    db_developer.add_dish('суши с угрем', 9, 'угорь, огурец, соус', 200, 19.99, 1, 0, v_id);
    
    -- роллы (category_id = 10)
    db_developer.add_dish('ролл дракон', 10, 'угорь, авокадо, огурец', 300, 22.99, 1, 0, v_id);
    db_developer.add_dish('ролл калифорния', 10, 'краб, авокадо, икра', 280, 20.99, 1, 0, v_id);
    db_developer.add_dish('темпура ролл', 10, 'креветка, сыр, огурец', 280, 21.99, 1, 0, v_id);
    
    -- супы (category_id = 11)
    db_developer.add_dish('рамэн', 11, 'лапша, свинина, яйцо', 400, 15.50, 1, 0, v_id);
    db_developer.add_dish('мисо суп', 11, 'тофу, водоросли', 250, 8.90, 1, 0, v_id);
    db_developer.add_dish('том ям', 11, 'креветки, грибы, лемонграсс', 350, 17.50, 1, 0, v_id);
    
    -- горячие блюда (category_id = 12)
    db_developer.add_dish('свинина по-пекински', 12, 'свинина, овощи, соус', 300, 24.99, 1, 0, v_id);
    db_developer.add_dish('курица с овощами', 12, 'курица, брокколи, морковь', 280, 19.99, 1, 0, v_id);
    db_developer.add_dish('утка по-пекински', 12, 'утка, блинчики, огурец', 350, 32.99, 1, 0, v_id);
    
    -- салаты (category_id = 13)
    db_developer.add_dish('салат чука', 13, 'водоросли, кунжут', 150, 7.99, 1, 0, v_id);
    db_developer.add_dish('салат с лососем', 13, 'лосось, микс салата, соус', 180, 14.99, 1, 0, v_id);
    db_developer.add_dish('салат кимчи', 13, 'пекинская капуста, специи', 120, 6.99, 1, 0, v_id);
    
    -- десерты (category_id = 14)
    db_developer.add_dish('моти', 14, 'рисовая лепешка, начинка', 80, 5.99, 1, 0, v_id);
    db_developer.add_dish('чуррос', 14, 'пончики, шоколад', 120, 7.99, 1, 0, v_id);
    
    -- напитки (category_id = 15)
    db_developer.add_dish('зеленый чай', 15, null, 250, 3.99, 1, 0, v_id);
    db_developer.add_dish('саке', 15, null, 150, 8.99, 1, 0, v_id);
    db_developer.add_dish('мохито', 15, null, 300, 6.99, 1, 1, v_id);
    
    -- wok (category_id = 16)
    db_developer.add_dish('лапша удон', 16, 'лапша, овощи, соус', 350, 14.99, 1, 0, v_id);
    db_developer.add_dish('рис с овощами', 16, 'рис, овощи, яйцо', 300, 11.99, 1, 0, v_id);
end;
/

begin
    db_developer.update_salary(21, 1300);
    db_developer.update_salary(22, 1000);
end;
/

commit;
Ы

-------------------------------------------------------------------
begin
    db_developer.generate_monthly_report('2025-04');
end;
/