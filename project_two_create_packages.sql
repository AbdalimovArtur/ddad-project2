CREATE OR REPLACE PACKAGE client_pkg IS

  PROCEDURE add_client(p_first_name IN B1_CLIENT.first_name%TYPE,
                       p_last_name IN B1_CLIENT.last_name%TYPE,
                       p_address IN B1_CLIENT.address%TYPE,
                       p_officer_id IN B1_CLIENT.officer_id%TYPE,
                       p_phone_number IN B1_CLIENT.phone_number%TYPE
  );
  PROCEDURE auth_add_client(p_client_id IN B1_CLIENT.client_id%TYPE,
                            p_auth_officer_id IN B1_CLIENT.auth_officer_id%TYPE
  );
  PROCEDURE update_client(p_client_id IN B1_CLIENT.client_id%TYPE,
                          p_first_name IN B1_CLIENT.first_name%TYPE,
                          p_last_name IN B1_CLIENT.last_name%TYPE,
                          p_address IN B1_CLIENT.address%TYPE,
                          p_officer_id IN B1_CLIENT.officer_id%TYPE,
                          p_credit_score IN B1_CLIENT.credit_score%TYPE,
                          p_phone_number IN B1_CLIENT.phone_number%TYPE
  );

  PROCEDURE delete_client(p_client_id IN B1_CLIENT.client_id%TYPE);
  PROCEDURE auth_delete_client(p_client_id IN B1_CLIENT.client_id%TYPE,
                               p_auth_officer_id IN B1_CLIENT.auth_officer_id%TYPE
  );
  PROCEDURE calculate_credit_score(p_client_id IN B1_CLIENT.client_id%TYPE);
  PROCEDURE check_credit_score(p_client_id IN B1_CLIENT.client_id%TYPE);
  PROCEDURE add_new_card(p_client_id IN B1_CLIENT.client_id%TYPE);

  END client_pkg;
  /

CREATE OR REPLACE PACKAGE card_pkg IS
    PROCEDURE check_credit_limit(p_client_id IN B1_CLIENT.client_id%TYPE);
    PROCEDURE print_balance(p_client_id IN B1_CLIENT.client_id%TYPE);
    PROCEDURE client_payment(p_client_id IN B1_CLIENT.client_id%TYPE, card_id IN B4_CREDIT_CARD.card_id%TYPE);
    PROCEDURE client_payment(card_id IN B4_CREDIT_CARD.card_id%TYPE);

  END card_pkg;
  /

CREATE OR REPLACE PACKAGE BODY client_pkg IS

  PROCEDURE add_client(p_first_name IN B1_CLIENT.first_name%TYPE,
                       p_last_name IN B1_CLIENT.last_name%TYPE,
                       p_address IN B1_CLIENT.address%TYPE,
                       p_officer_id IN B1_CLIENT.officer_id%TYPE,
                       p_phone_number IN B1_CLIENT.phone_number%TYPE) IS
  BEGIN
    INSERT INTO PROJECT_TWO.B1_CLIENT(client_id, FIRST_NAME, LAST_NAME, ADDRESS, OFFICER_ID, PHONE_NUMBER)
      VALUES (s_clients_seq.nextval, p_first_name, p_last_name,
              p_address, p_officer_id, p_phone_number);
  END;

  PROCEDURE auth_add_client(p_client_id IN B1_CLIENT.client_id%TYPE,
                            p_auth_officer_id IN B1_CLIENT.auth_officer_id%TYPE) IS
    v_auth_officer_department B7_DEPARTMENTS.department_name%TYPE;
    BEGIN
      SELECT B7_DEPARTMENTS.DEPARTMENT_NAME INTO v_auth_officer_department
      FROM B7_DEPARTMENTS d
      WHERE d.DEPARTMENT_ID = (SELECT DEPARTMENT_ID FROM B6_OFFICER WHERE OFFICER_ID = p_auth_officer_id);

      CASE v_auth_officer_department
        WHEN 'AUTH_DEP' THEN
            UPDATE B1_CLIENT
            SET AUTH_STATUS = 1, auth_officer_id = p_auth_officer_id
            WHERE CLIENT_ID = p_client_id;
        WHEN 'ADD_DEP' THEN
            DBMS_OUTPUT.PUT_LINE('Not enough privileges for authorizing');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Not enough privileges for authorizing');
        END CASE;
    END;

  PROCEDURE update_client(p_client_id IN B1_CLIENT.client_id%TYPE,
                          p_first_name IN B1_CLIENT.first_name%TYPE,
                          p_last_name IN B1_CLIENT.last_name%TYPE,
                          p_address IN B1_CLIENT.address%TYPE,
                          p_officer_id IN B1_CLIENT.officer_id%TYPE,
                          p_credit_score IN B1_CLIENT.credit_score%TYPE,
                          p_phone_number IN B1_CLIENT.phone_number%TYPE) IS
    v_client_record B1_CLIENT%ROWTYPE;
    BEGIN

      SELECT * INTO v_client_record
        FROM B1_CLIENT
      WHERE client_id = p_client_id;

      UPDATE B1_CLIENT
        SET first_name = p_first_name,
            last_name = p_last_name,
            address = p_address,
            officer_id = p_officer_id,
            phone_number = p_phone_number,
            credit_score = p_credit_score
      WHERE client_id = p_client_id;
    END;

  PROCEDURE delete_client(p_client_id IN B1_CLIENT.client_id%TYPE) IS
  BEGIN
      UPDATE B1_CLIENT SET auth_status = 2 WHERE client_id = p_client_id;
  END;

  PROCEDURE auth_delete_client(p_client_id IN B1_CLIENT.client_id%TYPE,
                            p_auth_officer_id IN B1_CLIENT.auth_officer_id%TYPE) IS
    v_auth_officer_department B7_DEPARTMENTS.department_name%TYPE;
    BEGIN
      SELECT B7_DEPARTMENTS.DEPARTMENT_NAME INTO v_auth_officer_department
      FROM B7_DEPARTMENTS d
      WHERE d.DEPARTMENT_ID = (SELECT DEPARTMENT_ID FROM B6_OFFICER WHERE OFFICER_ID = p_auth_officer_id);

      CASE v_auth_officer_department
        WHEN 'AUTH_DEP' THEN
            UPDATE B1_CLIENT
            SET AUTH_STATUS = 3, auth_officer_id = p_auth_officer_id
            WHERE CLIENT_ID = p_client_id;
        WHEN 'ADD_DEP' THEN
            DBMS_OUTPUT.PUT_LINE('Not enough privileges for authorizing');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Not enough privileges for authorizing');
        END CASE;
    END;

  PROCEDURE add_new_card(p_client_id IN B1_CLIENT.client_id%TYPE) IS
  BEGIN
    INSERT INTO B4_CREDIT_CARD(card_id, p_client_id, cvc2, holder_name, expiration_date,
                              creation_date, card_number, currency, credit_limit,
                              balance)
  END


  -- TODO: CREDIT SCORE

  END client_pkg;


CREATE OR REPLACE PACKAGE BODY card_pkg IS
    PROCEDURE check_credit_limit(p_client_id IN B1_CLIENT.client_id%TYPE);
    PROCEDURE print_balance(p_client_id IN B1_CLIENT.client_id%TYPE);
    PROCEDURE client_payment(p_client_id IN B1_CLIENT.client_id%TYPE, card_id IN B4_CREDIT_CARD.card_id%TYPE);
    PROCEDURE client_payment(card_id IN B4_CREDIT_CARD.card_id%TYPE);

  END card_pkg;
  /