create role developer_role;
create role ADMIN_ROLE;
create role MANAGER_ROLE;
create role CLIENT_ROLE;

grant create session to developer_role;
grant create session to admin_role;
grant create session to manager_role;
grant create session to client_role;

grant create table to developer_role;
grant create view to developer_role;
grant create procedure to developer_role;
grant create trigger to developer_role;
grant alter any table to developer_role;
grant drop any table to developer_role;
grant select any table to developer_role;
grant insert any table to developer_role;
grant update any table to developer_role;
grant delete any table to developer_role;
grant create SEQUENCE to developer_role;

commit;



