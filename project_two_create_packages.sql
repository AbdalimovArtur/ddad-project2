-- ****************************************************
-- My Amazing Responsible Ideal Young Adorable Milady *
-- ****************************************************

CREATE OR REPLACE PACKAGE client_pkg IS

  PROCEDURE add_client(p_first_name   IN B1_CLIENT.first_name%TYPE,
                       p_last_name    IN B1_CLIENT.last_name%TYPE,
                       p_address      IN B1_CLIENT.address%TYPE,
                       p_officer_id   IN B1_CLIENT.officer_id%TYPE,
                       p_phone_number IN B1_CLIENT.phone_number%TYPE
  );
  PROCEDURE auth_add_client(p_client_id       IN B1_CLIENT.client_id%TYPE,
                            p_auth_officer_id IN B1_CLIENT.auth_officer_id%TYPE
  );
  PROCEDURE update_client(p_client_id    IN B1_CLIENT.client_id%TYPE,
                          p_first_name   IN B1_CLIENT.first_name%TYPE,
                          p_last_name    IN B1_CLIENT.last_name%TYPE,
                          p_address      IN B1_CLIENT.address%TYPE,
                          p_officer_id   IN B1_CLIENT.officer_id%TYPE,
                          p_credit_score IN B1_CLIENT.credit_score%TYPE,
                          p_phone_number IN B1_CLIENT.phone_number%TYPE
  );

  PROCEDURE add_client_score_info(p_client_id                  IN B8_CREDIT_SCORE_INFO.client_id%TYPE,
                                  p_credit_cards_amount        IN B8_CREDIT_SCORE_INFO.credit_cards_amount%TYPE,
                                  p_first_card_taken_date      IN B8_CREDIT_SCORE_INFO.first_card_taken_date%TYPE,
                                  p_first_loan_taken_date      IN B8_CREDIT_SCORE_INFO.first_loan_taken_date%TYPE,
                                  p_last_card_taken_date       IN B8_CREDIT_SCORE_INFO.last_card_taken_date%TYPE,
                                  p_active_cards               IN B8_CREDIT_SCORE_INFO.active_cards%TYPE,
                                  p_last_miss_payment_date     IN B8_CREDIT_SCORE_INFO.last_miss_payment_date%TYPE,
                                  p_total_amount_of_past_loans IN B8_CREDIT_SCORE_INFO.total_amount_of_past_loans%TYPE,
                                  p_current_past_due_loans     IN B8_CREDIT_SCORE_INFO.current_past_due_loans%TYPE);

  PROCEDURE delete_client(p_client_id IN B1_CLIENT.client_id%TYPE);
  PROCEDURE auth_delete_client(p_client_id       IN B1_CLIENT.client_id%TYPE,
                               p_auth_officer_id IN B1_CLIENT.auth_officer_id%TYPE
  );
  PROCEDURE calculate_credit_score(p_client_id IN B1_CLIENT.client_id%TYPE);
  PROCEDURE check_credit_score(p_client_id IN B1_CLIENT.client_id%TYPE);
  PROCEDURE add_new_card(p_client_id IN B1_CLIENT.client_id%TYPE,
                         p_currency  IN B4_CREDIT_CARD.currency%TYPE);

END client_pkg;
/

CREATE OR REPLACE PACKAGE card_pkg IS
  v_usd_to_kzt NUMBER := 332.005312;
  PROCEDURE check_credit_limit(p_client_id IN B1_CLIENT.client_id%TYPE);
  PROCEDURE print_balance(p_client_id IN B1_CLIENT.client_id%TYPE);
  PROCEDURE create_client_payment(p_card_id     IN B4_CREDIT_CARD.card_id%TYPE,
                                  p_monthly_fee IN B2_CLIENT_PAYMENT.monthly_fee%TYPE,
                                  p_payment_due IN B2_CLIENT_PAYMENT.payment_due%TYPE);
  PROCEDURE make_client_payment(p_card_id IN       B4_CREDIT_CARD.card_id%TYPE,
                                p_amount_been_paid B2_CLIENT_PAYMENT.PAID_FEE%TYPE);

END card_pkg;
/

CREATE OR REPLACE PACKAGE BODY client_pkg IS

  PROCEDURE add_client(p_first_name   IN B1_CLIENT.first_name%TYPE,
                       p_last_name    IN B1_CLIENT.last_name%TYPE,
                       p_address      IN B1_CLIENT.address%TYPE,
                       p_officer_id   IN B1_CLIENT.officer_id%TYPE,
                       p_phone_number IN B1_CLIENT.phone_number%TYPE) IS
    BEGIN
      INSERT INTO PROJECT_TWO.B1_CLIENT (client_id, FIRST_NAME, LAST_NAME, ADDRESS, OFFICER_ID, PHONE_NUMBER)
      VALUES (s_clients_seq.nextval, p_first_name, p_last_name,
              p_address, p_officer_id, p_phone_number);
    END;

  PROCEDURE auth_add_client(p_client_id       IN B1_CLIENT.client_id%TYPE,
                            p_auth_officer_id IN B1_CLIENT.auth_officer_id%TYPE) IS
    v_auth_officer_department B7_DEPARTMENTS.department_name%TYPE;
    BEGIN
      SELECT department_name
      INTO v_auth_officer_department
      FROM B7_DEPARTMENTS d
      WHERE d.DEPARTMENT_ID = (SELECT DEPARTMENT_ID
                               FROM B6_OFFICER
                               WHERE OFFICER_ID = p_auth_officer_id);

      CASE v_auth_officer_department
        WHEN 'AUTH_DEP'
        THEN
          UPDATE B1_CLIENT
          SET AUTH_STATUS = 1, auth_officer_id = p_auth_officer_id
          WHERE CLIENT_ID = p_client_id;
        WHEN 'ADD_DEP'
        THEN
          DBMS_OUTPUT.PUT_LINE('Not enough privileges for authorizing');
      ELSE
        DBMS_OUTPUT.PUT_LINE('Not enough privileges for authorizing');
      END CASE;
    END;

  PROCEDURE update_client(p_client_id    IN B1_CLIENT.client_id%TYPE,
                          p_first_name   IN B1_CLIENT.first_name%TYPE,
                          p_last_name    IN B1_CLIENT.last_name%TYPE,
                          p_address      IN B1_CLIENT.address%TYPE,
                          p_officer_id   IN B1_CLIENT.officer_id%TYPE,
                          p_credit_score IN B1_CLIENT.credit_score%TYPE,
                          p_phone_number IN B1_CLIENT.phone_number%TYPE) IS
    v_client_record B1_CLIENT%ROWTYPE;
    BEGIN

      SELECT *
      INTO v_client_record
      FROM B1_CLIENT
      WHERE client_id = p_client_id;

      UPDATE B1_CLIENT
      SET first_name = p_first_name,
        last_name    = p_last_name,
        address      = p_address,
        officer_id   = p_officer_id,
        phone_number = p_phone_number,
        credit_score = p_credit_score
      WHERE client_id = p_client_id;
    END;

  PROCEDURE delete_client(p_client_id IN B1_CLIENT.client_id%TYPE) IS
    BEGIN
      UPDATE B1_CLIENT
      SET auth_status = 2
      WHERE client_id = p_client_id;
    END;

  PROCEDURE auth_delete_client(p_client_id       IN B1_CLIENT.client_id%TYPE,
                               p_auth_officer_id IN B1_CLIENT.auth_officer_id%TYPE) IS
    v_auth_officer_department B7_DEPARTMENTS.department_name%TYPE;
    BEGIN
      SELECT DEPARTMENT_NAME
      INTO v_auth_officer_department
      FROM B7_DEPARTMENTS d
      WHERE d.DEPARTMENT_ID = (SELECT DEPARTMENT_ID
                               FROM B6_OFFICER
                               WHERE OFFICER_ID = p_auth_officer_id);

      CASE v_auth_officer_department
        WHEN 'AUTH_DEP'
        THEN
          UPDATE B1_CLIENT
          SET AUTH_STATUS = 3, auth_officer_id = p_auth_officer_id
          WHERE CLIENT_ID = p_client_id;
        WHEN 'ADD_DEP'
        THEN
          DBMS_OUTPUT.PUT_LINE('Not enough privileges for authorizing');
      ELSE
        DBMS_OUTPUT.PUT_LINE('Not enough privileges for authorizing');
      END CASE;
    END;

  PROCEDURE add_new_card(p_client_id IN B1_CLIENT.client_id%TYPE,
                         p_currency  IN B4_CREDIT_CARD.currency%TYPE) IS
    v_random_cvc2              B4_CREDIT_CARD.CVC2%TYPE;
    v_card_number_first_octet  NUMBER(4);
    v_card_number_second_octet NUMBER(4);
    v_card_number_third_octet  NUMBER(4);
    v_card_number_fourth_octet NUMBER(4);
    v_holder_name              B4_CREDIT_CARD.holder_name%TYPE;
    v_card_number              B4_CREDIT_CARD.card_number%TYPE;
    v_credit_limit             B4_CREDIT_CARD.credit_limit%TYPE;
    BEGIN
      SELECT dbms_random.value(100, 999)
      INTO v_random_cvc2
      FROM DUAL;
      SELECT dbms_random.value(1000, 9999)
      INTO v_card_number_first_octet
      FROM DUAL;
      SELECT dbms_random.value(1000, 9999)
      INTO v_card_number_second_octet
      FROM DUAL;
      SELECT dbms_random.value(1000, 9999)
      INTO v_card_number_third_octet
      FROM DUAL;
      SELECT dbms_random.value(1000, 9999)
      INTO v_card_number_fourth_octet
      FROM DUAL;
      CASE p_currency
        WHEN 'KZT'
        THEN
          v_credit_limit := 100 * card_pkg.v_usd_to_kzt;
        WHEN 'USD'
        THEN
          v_credit_limit := 100;
      END CASE;

      SELECT INITCAP(first_name) || ' ' || INITCAP(last_name)
      INTO v_holder_name
      FROM B1_CLIENT
      WHERE client_id = p_client_id;

      v_card_number := v_card_number_first_octet || '-' || v_card_number_second_octet
                       || '-' || v_card_number_third_octet || '-' || v_card_number_fourth_octet;

      INSERT INTO B4_CREDIT_CARD (card_id, client_id, cvc2, holder_name, expiration_date,
                                  creation_date, card_number, currency, credit_limit,
                                  balance)
      VALUES (s_card_seq.nextval, p_client_id, v_random_cvc2, v_holder_name,
              ADD_MONTHS(SYSDATE, 48), SYSDATE, v_card_number, p_currency, v_credit_limit, v_credit_limit);
    END;

  PROCEDURE add_client_score_info(p_client_id                  IN B8_CREDIT_SCORE_INFO.client_id%TYPE,
                                  p_credit_cards_amount        IN B8_CREDIT_SCORE_INFO.credit_cards_amount%TYPE,
                                  p_first_card_taken_date      IN B8_CREDIT_SCORE_INFO.first_card_taken_date%TYPE,
                                  p_first_loan_taken_date      IN B8_CREDIT_SCORE_INFO.first_loan_taken_date%TYPE,
                                  p_last_card_taken_date       IN B8_CREDIT_SCORE_INFO.last_card_taken_date%TYPE,
                                  p_active_cards               IN B8_CREDIT_SCORE_INFO.active_cards%TYPE,
                                  p_last_miss_payment_date     IN B8_CREDIT_SCORE_INFO.last_miss_payment_date%TYPE,
                                  p_total_amount_of_past_loans IN B8_CREDIT_SCORE_INFO.total_amount_of_past_loans%TYPE,
                                  p_current_past_due_loans     IN B8_CREDIT_SCORE_INFO.current_past_due_loans%TYPE) IS
    BEGIN
      INSERT INTO B8_CREDIT_SCORE_INFO (client_id,
                                        credit_cards_amount,
                                        first_card_taken_date,
                                        first_loan_taken_date,
                                        last_card_taken_date,
                                        active_cards,
                                        last_miss_payment_date,
                                        total_amount_of_past_loans,
                                        current_past_due_loans)
      VALUES (p_client_id,
        p_credit_cards_amount,
        p_first_card_taken_date,
        p_first_loan_taken_date,
        p_last_card_taken_date,
        p_active_cards,
        p_last_miss_payment_date,
        p_total_amount_of_past_loans,
        p_current_past_due_loans);
    END;

  -- TODO: WILL BE DONE LATER
  -- https://www.youtube.com/watch?v=_UfyrhHqPkM
  PROCEDURE calculate_credit_score(p_client_id IN B1_CLIENT.client_id%TYPE) IS
    owner_record B8_CREDIT_SCORE_INFO%ROWTYPE;
    v_credit_utilization NUMBER := 0;
    v_credit_history NUMBER := 0;
    v_payment_history NUMBER := 0;
    v_credit_score_percent NUMBER := 0;
    v_credit_score NUMBER := 0;
    BEGIN

      SELECT *
      INTO owner_record
      FROM B8_CREDIT_SCORE_INFO
      WHERE client_id = p_client_id;

      IF owner_record.FIRST_LOAN_TAKEN_DATE IS NOT NULL THEN
        IF owner_record.FIRST_LOAN_TAKEN_DATE > ADD_MONTHS(SYSDATE, -60) THEN
          v_credit_history := 0.25;
        ELSIF owner_record.FIRST_LOAN_TAKEN_DATE > ADD_MONTHS(SYSDATE, -24) THEN
          v_credit_history := 0.15;
        ELSE
          v_credit_history := 0;
        END IF;
      END IF;

      IF owner_record.FIRST_CARD_TAKEN_DATE IS NOT NULL THEN
        IF owner_record.FIRST_CARD_TAKEN_DATE > ADD_MONTHS(SYSDATE, -60) THEN
          v_credit_history := v_credit_history + 0.25;
        ELSIF owner_record.FIRST_CARD_TAKEN_DATE > ADD_MONTHS(SYSDATE, -24) THEN
          v_credit_history := v_credit_history + 0.15;
        ELSE
          v_credit_history := v_credit_history + 0;
        END IF;
      END IF;

      IF owner_record.LAST_CARD_TAKEN_DATE IS NOT NULL THEN
        IF owner_record.LAST_CARD_TAKEN_DATE > ADD_MONTHS(SYSDATE, -12) THEN
          v_credit_history := v_credit_history + 0.50;
        ELSIF owner_record.LAST_CARD_TAKEN_DATE > ADD_MONTHS(SYSDATE, -24) THEN
          v_credit_history := v_credit_history + 0.25;
        ELSE
          v_credit_history := v_credit_history + 0.10;
        END IF;
      END IF;

      IF owner_record.CREDIT_CARDS_AMOUNT IS NOT NULL THEN
        IF owner_record.CREDIT_CARDS_AMOUNT >= 10 THEN
          v_credit_utilization := v_credit_utilization + 0.25;
        ELSIF owner_record.CREDIT_CARDS_AMOUNT >= 4 THEN
          v_credit_utilization := v_credit_utilization + 0.10;
        ELSIF owner_record.CREDIT_CARDS_AMOUNT >= 1 THEN
          v_credit_utilization := v_credit_utilization + 0.05;
        END IF;
      END IF;

      IF owner_record.ACTIVE_CARDS IS NOT NULL THEN
        IF owner_record.ACTIVE_CARDS >= 5 THEN
          v_credit_utilization := v_credit_utilization + 0.25;
        ELSIF owner_record.ACTIVE_CARDS >= 2 THEN
          v_credit_utilization := v_credit_utilization + 0.10;
        ELSIF owner_record.ACTIVE_CARDS >= 1 THEN
          v_credit_utilization := v_credit_utilization + 0.5;
        END IF;
      END IF;

      IF owner_record.SALARY IS NOT NULL THEN
        IF owner_record.SALARY >= 100000 THEN
          v_credit_utilization := v_credit_utilization + 0.50;
        ELSIF owner_record.SALARY >= 50000 THEN
          v_credit_utilization := v_credit_utilization + 0.25;
        ELSIF owner_record.SALARY >= 25000 THEN
          v_credit_utilization := v_credit_utilization + 0.15;
        ELSIF owner_record.SALARY >= 5000 THEN
          v_credit_utilization := v_credit_utilization + 0.1;
        ELSE
          v_credit_utilization := v_credit_utilization + 0.05;
        END IF;
      END IF;

      IF owner_record.CURRENT_PAST_DUE_LOANS IS NOT NULL THEN
        IF owner_record.CURRENT_PAST_DUE_LOANS = 0 THEN
          v_payment_history := v_payment_history + 0.25;
        ELSIF owner_record.CURRENT_PAST_DUE_LOANS <= 1000 THEN
          v_payment_history := v_payment_history + 0.15;
        ELSIF owner_record.CURRENT_PAST_DUE_LOANS <= 5000 THEN
          v_payment_history := v_payment_history + 0.1;
        ELSIF owner_record.CURRENT_PAST_DUE_LOANS <= 10000 THEN
          v_payment_history := v_payment_history + 0.05;
        END IF;
      END IF;

      IF owner_record.TOTAL_AMOUNT_OF_PAST_LOANS IS NOT NULL THEN
        IF owner_record.TOTAL_AMOUNT_OF_PAST_LOANS = 0 THEN
          v_payment_history := v_payment_history + 0.25;
        ELSIF owner_record.TOTAL_AMOUNT_OF_PAST_LOANS <= 1000 THEN
          v_payment_history := v_payment_history + 0.20;
        ELSIF owner_record.TOTAL_AMOUNT_OF_PAST_LOANS <= 5000 THEN
          v_payment_history := v_payment_history + 0.15;
        ELSIF owner_record.TOTAL_AMOUNT_OF_PAST_LOANS <= 10000 THEN
          v_payment_history := v_payment_history + 0.1;
        END IF;
      END IF;


      IF owner_record.last_miss_payment_date IS NOT NULL THEN
        IF owner_record.last_miss_payment_date >= ADD_MONTHS(SYSDATE, -24) THEN
          v_payment_history := v_payment_history + 0.05;
        ELSIF owner_record.last_miss_payment_date >= ADD_MONTHS(SYSDATE, -12) THEN
          v_payment_history := v_payment_history + 0.15;
        ELSIF owner_record.last_miss_payment_date >= ADD_MONTHS(SYSDATE, -6) THEN
          v_payment_history := v_payment_history + 0.25;
        END IF;
      END IF;

      v_credit_score_percent := (v_payment_history * 35 / 100) + (v_credit_utilization * 30 / 100) + (v_credit_history * 35 / 100);
      v_credit_score := v_credit_score * 900;

      IF v_credit_score < 500 THEN
        DBMS_OUTPUT.PUT_LINE('Can not calculate credit score for client ' || p_client_id);
      ELSE
        UPDATE B1_CLIENT SET CREDIT_SCORE = v_credit_score WHERE client_id = p_client_id;
      END IF;
    END;

  -- TODO: WILL BE DONE LATER
  PROCEDURE check_credit_score(p_client_id IN B1_CLIENT.client_id%TYPE) IS
    v_credit_score B1_CLIENT.credit_score%TYPE;
    BEGIN
      calculate_credit_score(p_client_id);
      SELECT credit_score INTO v_credit_score from B1_client WHERE client_id = p_client_id;
      DBMS_OUTPUT.PUT_LINE('Credit score for client ' || p_client_id || ' is ' || v_credit_score);
    END;


END client_pkg;
/

CREATE OR REPLACE PACKAGE BODY card_pkg IS

  PROCEDURE check_credit_limit(p_client_id IN B1_CLIENT.client_id%TYPE) IS
    BEGIN
      FOR card IN (SELECT *
                   FROM B4_CREDIT_CARD
                   WHERE client_id = p_client_id)
      LOOP
        DBMS_OUTPUT.PUT_LINE('Credit limit for card ' || card.CARD_NUMBER || ' Is '
                             || card.credit_limit);
      END LOOP;
    END;

  PROCEDURE print_balance(p_client_id IN B1_CLIENT.client_id%TYPE) IS
    BEGIN
      FOR card IN (SELECT *
                   FROM B4_CREDIT_CARD
                   WHERE client_id = p_client_id)
      LOOP
        DBMS_OUTPUT.PUT_LINE('Available balance for card ' || card.CARD_NUMBER || ' Is '
                             || card.balance);
      END LOOP;
    END;

  PROCEDURE create_client_payment(p_card_id     IN B4_CREDIT_CARD.card_id%TYPE,
                                  p_monthly_fee IN B2_CLIENT_PAYMENT.monthly_fee%TYPE,
                                  p_payment_due IN B2_CLIENT_PAYMENT.payment_due%TYPE) IS
    BEGIN
      INSERT INTO B2_CLIENT_PAYMENT (payment_id, card_id, monthly_fee, paid_fee,
                                     overdue_interest, payment_due, payment_date, status)
      VALUES (s_payment_seq.nextval, p_card_id, p_monthly_fee,
              0, 0.5, p_payment_due,
              NULL, 0);
    END;


  PROCEDURE make_client_payment(p_card_id IN       B4_CREDIT_CARD.card_id%TYPE,
                                p_amount_been_paid B2_CLIENT_PAYMENT.PAID_FEE%TYPE) IS
    v_unpaid_payment             B2_CLIENT_PAYMENT%ROWTYPE;
    v_overpayment                NUMBER := 0;
    v_interest_m                 NUMBER := 0;
    v_unpaid_money_with_interest NUMBER := 0;
    BEGIN
      SELECT *
      INTO v_unpaid_payment
      FROM B2_CLIENT_PAYMENT
      WHERE status = 0 AND card_id = p_card_id;

      IF SYSDATE <= v_unpaid_payment.PAYMENT_DUE
      THEN
        IF p_amount_been_paid + v_unpaid_payment.PAID_FEE > v_unpaid_payment.MONTHLY_FEE
        THEN
          UPDATE B2_CLIENT_PAYMENT
          SET PAID_FEE   = p_amount_been_paid + v_unpaid_payment.PAID_FEE,
            status       = 1,
            PAYMENT_DATE = SYSDATE
          WHERE payment_id = v_unpaid_payment.PAYMENT_ID;

          v_overpayment := p_amount_been_paid + v_unpaid_payment.PAID_FEE - v_unpaid_payment.MONTHLY_FEE;
          IF v_overpayment < 0
          THEN
            v_overpayment := 0;
          END IF;

          INSERT INTO B2_CLIENT_PAYMENT (payment_id, card_id, monthly_fee, paid_fee,
                                         overdue_interest, payment_due, payment_date, status)
          VALUES (s_payment_seq.nextval, p_card_id, v_unpaid_payment.monthly_fee,
                  v_overpayment, 0.5, ADD_MONTHS(v_unpaid_payment.PAYMENT_DUE, 1),
                  NULL, 0);
        ELSE
          UPDATE B2_CLIENT_PAYMENT d
          SET PAID_FEE = d.PAID_FEE + p_amount_been_paid, PAYMENT_DATE = SYSDATE
          WHERE d.PAYMENT_ID = v_unpaid_payment.PAYMENT_ID;
        END IF;
      ELSE
        v_unpaid_money_with_interest :=
        (v_unpaid_payment.MONTHLY_FEE - v_unpaid_payment.PAID_FEE) * (SYSDATE - v_unpaid_payment.PAYMENT_DUE) *
        v_unpaid_payment.OVERDUE_INTEREST;
        IF p_amount_been_paid + v_unpaid_payment.PAID_FEE > v_unpaid_payment.MONTHLY_FEE + v_unpaid_money_with_interest
        THEN
          UPDATE B2_CLIENT_PAYMENT
          SET PAID_FEE   = p_amount_been_paid + v_unpaid_payment.PAID_FEE,
            status       = 1,
            PAYMENT_DATE = SYSDATE
          WHERE payment_id = v_unpaid_payment.PAYMENT_ID;

          v_overpayment := p_amount_been_paid + v_unpaid_payment.PAID_FEE - v_unpaid_payment.MONTHLY_FEE -
                           v_unpaid_money_with_interest;
          IF v_overpayment < 0
          THEN
            v_overpayment := 0;
          END IF;

          INSERT INTO B2_CLIENT_PAYMENT (payment_id, card_id, monthly_fee, paid_fee,
                                         overdue_interest, payment_due, payment_date, status)
          VALUES (s_payment_seq.nextval, p_card_id, v_unpaid_payment.monthly_fee,
                  v_overpayment, 0.5, ADD_MONTHS(v_unpaid_payment.PAYMENT_DUE, 1),
                  NULL, 0);
        ELSE
          UPDATE B2_CLIENT_PAYMENT d
          SET PAID_FEE = d.PAID_FEE + p_amount_been_paid, PAYMENT_DATE = SYSDATE
          WHERE d.PAYMENT_ID = v_unpaid_payment.PAYMENT_ID;
        END IF;
      END IF;

    END;

END card_pkg;
/