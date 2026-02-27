-- Create table
create table TB_CLIENTE
(
  ID_CLIENTE       NUMBER(8) NOT NULL,
  NOME             VARCHAR2(70) NOT NULL,
  EMAIL            VARCHAR2(120),
  CEP              VARCHAR2(8),
  LOGRADOURO       VARCHAR2(80),
  NUMERO_LOGR      VARCHAR2(15),
  BAIRRO           VARCHAR2(40),
  CIDADE           VARCHAR2(40),
  UF               VARCHAR2(2),
  ATIVO            NUMBER(1) DEFAULT 1 NOT NULL,
  DT_CRIACAO       DATE DEFAULT SYSTIMESTAMP,
  USER_CRIACAO     VARCHAR2(40),
  DT_ATUALIZACAO   DATE,
  USER_ATUALIZACAO VARCHAR2(40)
)
/
-- Add comments to the table 
COMMENT ON TABLE TB_CLIENTE IS 'Cadastro de clientes'
/
-- Add comments to the columns 
COMMENT ON COLUMN TB_CLIENTE.ID_CLIENTE IS 'Id do cliente'
/
COMMENT ON COLUMN TB_CLIENTE.NOME IS 'Nome do cliente'
/
COMMENT ON COLUMN TB_CLIENTE.EMAIL IS 'E-mail do cliente'
/
COMMENT ON COLUMN TB_CLIENTE.CEP IS 'Código de endereçamento postal do enreço do cliente'
/
COMMENT ON COLUMN TB_CLIENTE.LOGRADOURO IS 'Logradouro do edenreço do cliente'
/
COMMENT ON COLUMN TB_CLIENTE.NUMERO_LOGR IS 'Numero do endereço do cliente'
/
COMMENT ON COLUMN TB_CLIENTE.BAIRRO IS 'Bairro do endereço do cliente'
/
COMMENT ON COLUMN TB_CLIENTE.CIDADE IS 'Cidade do endereço do cliente'
/
COMMENT ON COLUMN TB_CLIENTE.UF IS 'Unidade federativa do endereço do cliente'
/
COMMENT ON COLUMN TB_CLIENTE.ATIVO IS 'Status Ativo (1) / Inativo (0)'
/
-- Create/Recreate primary, unique and foreign key constraints 
ALTER TABLE TB_CLIENTE ADD CONSTRAINT PK_TB_CLIENTE PRIMARY KEY (ID_CLIENTE)
/
ALTER TABLE TB_CLIENTE ADD CONSTRAINT UK_TB_CLIENTE_EMAIL UNIQUE (EMAIL)
/
-- Create/Recreate check constraints 
ALTER TABLE TB_CLIENTE
  ADD CONSTRAINT CHK_TB_CLIENTE_UF
  CHECK (UF IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'))
/
