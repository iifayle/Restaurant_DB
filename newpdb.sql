create pluggable database kurs_pdb
Admin user pdbadmin IDENTIFIED by "123"
FILE_NAME_CONVERT = ('/opt/oracle/oradata/ORCLCDB/pdbseed/','/opt/oracle/oradata/ORCLCDB/kurs_pdb/');

ALTER PLUGGABLE DATABASE kurs_pdb OPEN;
ALTER PLUGGABLE DATABASE kurs_pdb SAVE STATE;

GRANT DBA TO C##REST_SYS_DBA WITH ADMIN OPTION;

ALTER SESSION SET CONTAINER = kurs_pdb;

CREATE USER rest_sys_dba IDENTIFIED BY 123;
GRANT DBA TO rest_sys_dba;
GRANT CREATE TABLESPACE, DROP TABLESPACE TO rest_sys_dba;
alter session set container = ORCLPDB1;
grant execute on sys.dbms_crypto to db_developer;
grant execute on sys.utl_raw to db_developer;