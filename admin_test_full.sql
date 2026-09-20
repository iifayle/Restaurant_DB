-- 1. добавление ресторана (успешно)
declare
    v_id number;
begin
    db_developer.add_restaurant('японский сад', 'ул. захарова 10, минск', '+375291112233', '10:00-23:00', '111222333', v_id);
end;
/

-- 1.1 добавление ресторана с ошибкой (пустое имя)
declare
    v_id number;
begin
    db_developer.add_restaurant(null, 'ул. тестовая', '+375291234567', null, null, v_id);
end;
/

-- 2. просмотр всех ресторанов
begin
    db_developer.view_restaurants;
end;
/

-- 3. обновление ресторана
begin
    db_developer.update_restaurant(4, 'азия-хаус', null, '+375297777777', '10:00-00:00', null);
end;
/

-- 3.1 обновление несуществующего ресторана
begin
    db_developer.update_restaurant(999, 'тест', null, null, null, null);
end;
/

-- 4. добавление категории
declare
    v_id number;
begin
    db_developer.add_category('закуски', v_id);
end;
/

-- 4.1 добавление дубликата категории
declare
    v_id number;
begin
    db_developer.add_category('закуски', v_id);
end;
/

-- 5. просмотр всех категорий
begin
    db_developer.view_categories;
end;
/

-- 6. обновление категории
begin
    db_developer.update_category(21, 'холодные закуски');
end;
/

-- 6.1 обновление несуществующей категории
begin
    db_developer.update_category(999, 'тест');
end;
/

-- 7. удаление категории (если нет блюд)
begin
    db_developer.delete_category(21);
end;
/

-- 7.1 удаление категории с блюдами
begin
    db_developer.delete_category(9);
end;
/

-- 8. добавление блюда
declare
    v_id number;
begin
    db_developer.add_dish('брускетта', 9, 'хлеб, помидоры, базилик', 150, 12.99, 1, 0, v_id);
end;
/

-- 8.1 добавление блюда с отрицательной ценой
declare
    v_id number;
begin
    db_developer.add_dish('тест', 9, null, null, -100, 1, 0, v_id);
end;
/

-- 9. просмотр всех блюд
begin
    db_developer.view_all_dishes;
end;
/

begin
    db_developer.view_all_dishes('суши');
end;
/

-- 10. просмотр полного меню
begin
    db_developer.view_full_menu;
end;
/

-- 11. обновление блюда
begin
    db_developer.update_dish(41, 'брускетта с лососем', 9, 'хлеб, лосось, творожный сыр', 180, 18.99, 1, 1);
end;
/

-- 11.1 обновление несуществующего блюда
begin
    db_developer.update_dish(999, 'тест', null, null, null, null, null, null);
end;
/

-- 12. удаление блюда (которого нет в заказах)
begin
    db_developer.delete_dish(41);
end;
/

-- 12.1 удаление блюда, которое есть в активных заказах
begin
    db_developer.delete_dish(2);
end;
/

-- 13. добавление должности
declare
    v_id number;
begin
    db_developer.add_position('сомелье', 1100, v_id);
end;
/

-- 13.1 добавление дубликата должности
declare
    v_id number;
begin
    db_developer.add_position('сомелье', 1100, v_id);
end;
/

-- 14. просмотр всех должностей
begin
    db_developer.view_positions;
end;
/

-- 15. обновление должности
begin
    db_developer.update_position(21, 'старший сомелье', 1300);
end;
/

-- 15.1 обновление несуществующей должности
begin
    db_developer.update_position(999, 'тест', 1000);
end;
/

-- 16. удаление должности (без сотрудников)
begin
    db_developer.delete_position(21);
end;
/

-- 16.1 удаление должности с сотрудниками
begin
    db_developer.delete_position(8);
end;
/

-- 17. просмотр всех сотрудников
begin
    db_developer.view_all_employees;
end;
/

begin
    db_developer.view_all_employees(4);
end;
/

-- 18. приём сотрудника
declare
    v_id number;
begin
    db_developer.hire_employee('смирнова анна алексеевна', 10, 4, 1100, date '2025-04-01', 'стажировка пройдена', v_id);
end;
/

-- 18.1 приём сотрудника с отрицательной зарплатой
declare
    v_id number;
begin
    db_developer.hire_employee('тестовый тест', 10, 4, -500, sysdate, null, v_id);
end;
/

-- 19. назначение новой должности сотруднику
begin
    db_developer.assign_position(41, 11, 1200);
end;
/

-- 19.1 назначение должности несуществующему сотруднику
begin
    db_developer.assign_position(999, 10, 1000);
end;
/

-- 20. изменение зарплаты
begin
    db_developer.update_salary(41, 1300);
end;
/

-- 20.1 изменение зарплаты на отрицательное значение
begin
    db_developer.update_salary(41, -1000);
end;
/

-- 21. увольнение сотрудника
begin
    db_developer.fire_employee(41, sysdate);
end;
/

-- 21.1 увольнение уже уволенного сотрудника
begin
    db_developer.fire_employee(41, sysdate);
end;
/

-- 22. обновление данных сотрудника
begin
    db_developer.update_employee(20, 'петров петр иванович', null, null, null, null, 'курсы английского', null);
end;
/

-- 22.1 обновление несуществующего сотрудника
begin
    db_developer.update_employee(999, 'тест', null, null, null, null, null, null);
end;
/

-- 23. восстановление уволенного сотрудника
begin
    db_developer.update_employee(41, null, null, null, null, null, null, 1);
end;
/


-- просмотр финансовых отчётов 
begin
    db_developer.view_financial_reports;
end;
/

-- генерация отчёта по ресторану 4 (азия-хаус) за апрель 2025
begin
    db_developer.generate_monthly_report('2025-04', 4);
end;
/

-- генерация отчёта за несуществующий месяц
begin
    db_developer.generate_monthly_report('2025-13', 4);
end;
/

-- генерация отчёта по несуществующему ресторану
begin
    db_developer.generate_monthly_report('2025-04', 999);
end;
/

-- просмотр финансовых отчётов после генерации
begin
    db_developer.view_financial_reports;
end;
/

-- просмотр отчётов по ресторану 4
begin
    db_developer.view_financial_reports(4, 'sales');
end;
/

-- 1. экспорт меню
begin
    db_developer.export_menu_to_json('menu_export.json');
end;
/


-- 2. импорт меню из файла 
begin
    db_developer.import_menu_from_json('menu_export.json');
end;
/

commit;