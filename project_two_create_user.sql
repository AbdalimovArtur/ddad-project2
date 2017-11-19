CREATE TABLESPACE project_two_table_space
  DATAFILE 'project_two_table_space.dat'
  SIZE 10M AUTOEXTEND ON;

CREATE TEMPORARY TABLESPACE project_two_table_space_temp
  TEMPFILE 'project_two_table_space_temp.date'
  SIZE 5M AUTOEXTEND ON;

CREATE USER project_two
  IDENTIFIED by project_two
  DEFAULT TABLESPACE project_two_table_space
  TEMPORARY TABLESPACE project_two_table_space_temp;

GRANT ALL PRIVILEGES TO project_two IDENTIFIED BY project_two;