create user db_developer identified by 123;
create user restaurant_admin identified by 123;
create user restaurant_manager identified by 123;
create user restaurant_client identified by 123;


grant developer_role to db_developer;
grant admin_role to restaurant_admin;
grant manager_role to restaurant_manager;
grant client_role to restaurant_client;

-- назначение профилей пользователям
alter user db_developer profile developer_profile;
alter user restaurant_admin profile admin_profile;
alter user restaurant_manager profile manager_profile;
alter user restaurant_client profile client_profile;


alter user db_developer quota unlimited on ts_rest_reference;
alter user db_developer quota unlimited on ts_rest_operational;
alter user db_developer quota unlimited on ts_rest_history;
alter user db_developer quota unlimited on ts_rest_reporting;
alter user db_developer quota unlimited on ts_rest_indexes;
alter user db_developer quota unlimited on ts_rest_lob;

commit;
-------------------------------------------------------------------------------------

-- рестораны
grant execute on db_developer.add_restaurant to restaurant_admin;
grant execute on db_developer.update_restaurant to restaurant_admin;
grant execute on db_developer.delete_restaurant to restaurant_admin;
grant execute on db_developer.view_restaurants to restaurant_admin;

-- блюда
grant execute on db_developer.add_dish to restaurant_admin;
grant execute on db_developer.update_dish to restaurant_admin;
grant execute on db_developer.delete_dish to restaurant_admin;
grant execute on db_developer.view_all_dishes to restaurant_admin;
grant execute on db_developer.view_full_menu to restaurant_admin;

-- категории
grant execute on db_developer.add_category to restaurant_admin;
grant execute on db_developer.update_category to restaurant_admin;
grant execute on db_developer.delete_category to restaurant_admin;
grant execute on db_developer.view_categories to restaurant_admin;

-- сотрудники
grant execute on db_developer.hire_employee to restaurant_admin;
grant execute on db_developer.assign_position to restaurant_admin;
grant execute on db_developer.fire_employee to restaurant_admin;
grant execute on db_developer.update_salary to restaurant_admin;
grant execute on db_developer.update_employee to restaurant_admin;
grant execute on db_developer.view_all_employees to restaurant_admin;
grant execute on db_developer.view_positions to restaurant_admin;

-- должности
grant execute on db_developer.add_position to restaurant_admin;
grant execute on db_developer.update_position to restaurant_admin;
grant execute on db_developer.delete_position to restaurant_admin;

-- финансовые отчёты
grant execute on db_developer.create_financial_report to restaurant_admin;
grant execute on db_developer.view_financial_reports to restaurant_admin;
grant execute on db_developer.generate_monthly_report to restaurant_admin;

-- права на json процедуры для управляющего
grant execute on db_developer.export_menu_to_json to restaurant_admin;
grant execute on db_developer.export_orders_to_json to restaurant_admin;
grant execute on db_developer.import_menu_from_json to restaurant_admin;
grant execute on db_developer.import_orders_from_json to restaurant_admin;
-----------------------------------------------------------------------------
-- смены
grant execute on db_developer.create_shift to restaurant_manager;
grant execute on db_developer.assign_employee_to_shift to restaurant_manager;
grant execute on db_developer.update_shift to restaurant_manager;
grant execute on db_developer.cancel_shift to restaurant_manager;
grant execute on db_developer.show_employee_shifts to restaurant_manager;

-- инциденты
grant execute on db_developer.add_incident to restaurant_manager;
grant execute on db_developer.update_incident to restaurant_manager;
grant execute on db_developer.show_incidents to restaurant_manager;

-- бронирования
grant execute on db_developer.confirm_reservation to restaurant_manager;
grant execute on db_developer.cancel_reservation to restaurant_manager;
grant execute on db_developer.reschedule_reservation to restaurant_manager;
grant execute on db_developer.show_today_reservations to restaurant_manager;
grant execute on db_developer.view_all_reservations to restaurant_manager;

-- отзывы
grant execute on db_developer.delete_review to restaurant_manager;
grant execute on db_developer.approve_review to restaurant_manager;
grant execute on db_developer.show_pending_reviews to restaurant_manager;

-- заказы
grant execute on db_developer.create_order to restaurant_manager;
grant execute on db_developer.add_order_item to restaurant_manager;
grant execute on db_developer.submit_order_to_kitchen to restaurant_manager;
grant execute on db_developer.close_order to restaurant_manager;
grant execute on db_developer.view_client_orders to restaurant_manager;
grant execute on db_developer.view_order_details to restaurant_manager;
grant execute on db_developer.view_open_orders to restaurant_manager;
grant execute on db_developer.view_kitchen_orders to restaurant_manager;

-- клиенты
grant execute on db_developer.add_client to restaurant_manager;
grant execute on db_developer.update_client to restaurant_manager;
grant execute on db_developer.delete_client to restaurant_manager;
grant execute on db_developer.show_clients_list to restaurant_manager;

-- сотрудники (только просмотр активных)
grant execute on db_developer.show_active_employees to restaurant_manager;
----------------------------------------------------------------------------------
-- бронирования
grant execute on db_developer.create_reservation to restaurant_client;
grant execute on db_developer.cancel_reservation_client to restaurant_client;

-- отзывы
grant execute on db_developer.add_review to restaurant_client;
grant execute on db_developer.update_my_review to restaurant_client;
grant execute on db_developer.delete_my_review to restaurant_client;

-- аккаунт
grant execute on db_developer.register_client to restaurant_client;
grant execute on db_developer.login_client to restaurant_client;
grant execute on db_developer.update_my_profile to restaurant_client;
grant execute on db_developer.change_my_password to restaurant_client;
grant execute on db_developer.delete_my_account to restaurant_client;

-- просмотр
grant execute on db_developer.view_my_profile to restaurant_client;
grant execute on db_developer.view_my_orders to restaurant_client;
grant execute on db_developer.view_my_reviews to restaurant_client;
grant execute on db_developer.view_my_reservations to restaurant_client;
grant execute on db_developer.show_menu to restaurant_client;
grant execute on db_developer.show_available_dishes to restaurant_client;
grant execute on db_developer.show_published_reviews to restaurant_client;

-----------------------------------------------------------------------------
create or replace directory json_export_dir as '/opt/oracle/oradata/json';
grant read, write on directory json_export_dir to db_developer;
grant read, write on directory json_export_dir to restaurant_admin;
---
create or replace directory REPORT_DIR as '/home/oracle/reports';
grant read, write on directory REPORT_DIR to db_developer;
-------------------------------------------------------------------------------


