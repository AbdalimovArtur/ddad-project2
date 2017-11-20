CREATE OR REPLACE TRIGGER client_archive
  BEFORE UPDATE OR DELETE ON B1_CLIENT
  FOR EACH ROW
  BEGIN
    INSERT INTO B9_CLIENT_ARCHIVE(client_id,
                                  first_name,
                                  last_name,
                                  address,
                                  officer_id,
                                  auth_officer_id,
                                  status,
                                  UPDATE_DATE)
    VALUES(:OLD.CLIENT_ID, :OLD.FIRST_NAME, :OLD.LAST_NAME,
           :OLD.ADDRESS, :OLD.OFFICER_ID, :OLD.AUTH_OFFICER_ID,
           :OLD.AUTH_STATUS, SYSDATE);
  END;