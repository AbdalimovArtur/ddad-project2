CREATE SCHEMA AUTHORIZATION PROJECT_TWO

  CREATE TABLE B7_DEPARTMENTS (
    department_id   NUMBER(2),
    department_name VARCHAR2(20),
    CONSTRAINT department_id_pk PRIMARY KEY (department_id)
  )

  CREATE TABLE B6_OFFICER (
    officer_id    NUMBER(6),
    fisrt_name    VARCHAR2(50),
    last_name     VARCHAR2(50),
    department_id NUMBER(2),
    CONSTRAINT officer_id_pk PRIMARY KEY (officer_Id),
    FOREIGN KEY (department_id) REFERENCES B7_DEPARTMENTS (department_id)
  )

  CREATE TABLE B1_CLIENT(
    client_id NUMBER(6),
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    address VARCHAR2(50),
    officer_id NUMBER(6),
    auth_officer_id NUMBER(6),
    auth_status NUMBER(1),
    phone_number VARCHAR2(20),
    credit_score NUMBER(3),
    CONSTRAINT client_id_pk PRIMARY KEY (client_id),
    FOREIGN KEY (officer_id) REFERENCES B6_OFFICER (officer_id),
    FOREIGN KEY (auth_officer_id) REFERENCES B6_OFFICER (officer_id)
  )

  CREATE TABLE B4_CREDIT_CARD(
    card_id NUMBER(6),
    client_id NUMBER(6),
    CVC2 VARCHAR2(3),
    holder_name VARCHAR2(50),
    expiration_date DATE,
    creation_date DATE,
    card_number VARCHAR2(20),
    currency VARCHAR2(5),
    credit_limit NUMBER(8, 2),
    balance NUMBER(8, 2),
    CONSTRAINT account_id_pk PRIMARY KEY (card_id),
    FOREIGN KEY (client_id) REFERENCES B1_CLIENT(client_id)
  )

  CREATE TABLE B3_TRANSACTION(
    transaction_id NUMBER(6),
    card_id NUMBER(6),
    amount_transferred NUMBER(8, 2),
    dest_card_id NUMBER(6),
    transfer_date DATE,
    CONSTRAINT transaction_id_pk PRIMARY KEY (transaction_id),
    FOREIGN KEY (dest_card_id) REFERENCES B4_CREDIT_CARD(card_id),
    FOREIGN KEY (card_id) REFERENCES B4_CREDIT_CARD(card_id)
  )

  CREATE TABLE B2_CLIENT_PAYMENT(
    payment_id NUMBER(6),
    card_id NUMBER(6),
    monthly_fee NUMBER(8, 2),
    paid_fee NUMBER(8, 2),
    overpayment NUMBER(8, 2),
    overdue_interest NUMBER(1, 1),
    payment_due DATE,
    payment_date DATE,
    FOREIGN KEY (card_id) REFERENCES B4_CREDIT_CARD(card_id)
  )

  CREATE TABLE B8_CREDIT_SCORE_INFO(
    client_id NUMBER(6),
    credit_cards_amount NUMBER(3),
    first_card_taken_date DATE,
    first_loan_taken_date DATE,
    last_card_taken_date DATE,
    active_cards NUMBER(3),
    last_miss_payment_date DATE,
    total_amount_of_loans NUMBER(10),
    total_amount_of_past_loans NUMBER(10),
    current_past_due_loans NUMBER(6),
    FOREIGN KEY (client_id) REFERENCES B1_CLIENT(client_id)
  )

  CREATE TABLE B9_CLIENT_BACKLOG(
    client_id NUMBER(6),
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    address VARCHAR2(50),
    officer_id NUMBER(6),
    auth_officer_id NUMBER(6),
    status NUMBER(1),
    UPDATE_DATE DATE default SYSDATE,
    FOREIGN KEY (client_id) REFERENCES B1_CLIENT(client_id)
  );

  CREATE SEQUENCE s_clients_seq
    START WITH 1
    INCREMENT BY 1
    CACHE 100
    NOCYCLE;

  CREATE SEQUENCE s_transactions_seq
    START WITH 1
    INCREMENT BY 1
    CACHE 100
    NOCYCLE;

  CREATE SEQUENCE s_payment_seq
    START WITH 1
    INCREMENT BY 1
    CACHE 100
    NOCYCLE;
