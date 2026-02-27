create or replace package PKG_CLIENTE is

  -- Author  : LAOLIVEIRA
  -- Created : 27/02/2026 07:17:57
  -- Purpose : Package da camada de negócio de Cadastro de Clientes
  
  -- Public type declarations
  TYPE T_TB_CLIENTE IS TABLE OF TB_CLIENTE%ROWTYPE INDEX BY BINARY_INTEGER;
  
  -- Define a ref cursor type for the query operation
  TYPE RC_TB_CLIENTE IS REF CURSOR RETURN TB_CLIENTE%rowtype;
  
  -- Funcao de validacao do E-mail
  FUNCTION FN_VALIDAR_EMAIL
    (P_EMAIL   IN  TB_CLIENTE.EMAIL%TYPE)
    RETURN NUMBER;
  
  -- Funcao de normalizacao do CEP
  FUNCTION FN_NORMALIZAR_CEP
    (P_CEP     IN  VARCHAR2)
    RETURN VARCHAR;
    
  -- Procedimento de inclusao
  PROCEDURE PRC_INSERIR_CLIENTE
    (P_TB_CLIENTE    IN OUT T_TB_CLIENTE);
  
  -- Procedimento de ateracao
  PROCEDURE PRC_UPDATE_CLIENTE
    (P_TB_CLIENTE    IN OUT T_TB_CLIENTE);

  -- Procedimento de exclusao
  PROCEDURE PRC_DELETAR_CLIENTE
    (P_TB_CLIENTE    IN  T_TB_CLIENTE);

  -- Procedimento de consulta
  PROCEDURE PRC_CONSULTA_CLIENTE
    (P_ID_CLIENTE    IN     TB_CLIENTE.ID_CLIENTE%TYPE
    ,P_TB_CLIENTE    IN OUT RC_TB_CLIENTE);
      
  -- Procedimento lista de clientes
  PROCEDURE PRC_LISTAR_CLIENTES
    (P_NOME           IN    TB_CLIENTE.NOME%TYPE DEFAULT NULL
    ,P_EMAIL          IN    TB_CLIENTE.EMAIL%TYPE DEFAULT NULL
    ,P_RC             OUT   SYS_REFCURSOR);
    
END PKG_CLIENTE;
/
create or replace package body PKG_CLIENTE is

  FUNCTION FN_VALIDAR_EMAIL
    (P_EMAIL   IN  TB_CLIENTE.EMAIL%TYPE)
    RETURN NUMBER IS
    
    V_EMAIL      TB_CLIENTE.EMAIL%TYPE := LOWER(TRIM(P_EMAIL));
    V_VALIDO     NUMBER(1) := 0;
    
  BEGIN
    
    IF REGEXP_LIKE(V_EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
      V_VALIDO := 1;
    ELSE
      V_VALIDO := 0;
    END IF;
    
    RETURN (V_VALIDO);
    
  END;
  
  -- Funcao de normalizacao do CEP
  FUNCTION FN_NORMALIZAR_CEP
    (P_CEP     IN  VARCHAR2)
    RETURN VARCHAR IS
    
    V_CEP_ORIG      VARCHAR2(20);
    
  BEGIN
    
    IF P_CEP IS NULL THEN
      RETURN (P_CEP);
    ELSE
      V_CEP_ORIG   :=  REGEXP_REPLACE(P_CEP, '[^0-9]', '');  
      
      IF LENGTH(V_CEP_ORIG) != 8 THEN
        RETURN (P_CEP); 
      ELSE
        RETURN (V_CEP_ORIG);
      END IF;
    END IF;
  END FN_NORMALIZAR_CEP;

  -- Procedimento de inclusao
  PROCEDURE PRC_INSERIR_CLIENTE
    (P_TB_CLIENTE    IN OUT T_TB_CLIENTE) IS
    
    E_NOME_NULL     EXCEPTION;
    E_UF_INVALIDA   EXCEPTION;
     
  BEGIN
    
    FOR IND IN 1..P_TB_CLIENTE.COUNT 
      LOOP
        
      IF P_TB_CLIENTE(IND).NOME IS NULL THEN
         RAISE E_NOME_NULL;
      END IF;
      
      IF P_TB_CLIENTE(IND).UF NOT IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO') THEN
        RAISE E_UF_INVALIDA;
      END IF;
      
      INSERT INTO TB_CLIENTE
             (NOME
             ,EMAIL
             ,CEP
             ,LOGRADOURO
             ,NUMERO_LOGR
             ,BAIRRO
             ,CIDADE
             ,UF
             ,ATIVO)
      VALUES (P_TB_CLIENTE(IND).NOME
             ,P_TB_CLIENTE(IND).EMAIL
             ,P_TB_CLIENTE(IND).CEP
             ,P_TB_CLIENTE(IND).LOGRADOURO
             ,P_TB_CLIENTE(IND).NUMERO_LOGR
             ,P_TB_CLIENTE(IND).BAIRRO
             ,P_TB_CLIENTE(IND).CIDADE
             ,P_TB_CLIENTE(IND).UF
             ,P_TB_CLIENTE(IND).ATIVO  )
      RETURNING ID_CLIENTE INTO P_TB_CLIENTE(IND).ID_CLIENTE;
      
    END LOOP;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20002, 'Não pode inserir valor duplicado.');
    WHEN E_NOME_NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'Nome de cliente é requerido.');
    WHEN E_UF_INVALIDA THEN
      RAISE_APPLICATION_ERROR(-20001, 'UF informada não é válida.');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20020, 'Erro inesperado:' || SQLERRM);
          
  END PRC_INSERIR_CLIENTE;
  
  -- Procedimento de ateracao
  PROCEDURE PRC_UPDATE_CLIENTE
    (P_TB_CLIENTE    IN OUT T_TB_CLIENTE) IS
    
    E_NOME_NULL     EXCEPTION;
    E_UF_INVALIDA   EXCEPTION;
    
  BEGIN
    
    FOR IND IN 1..P_TB_CLIENTE.COUNT 
      LOOP
      
      IF P_TB_CLIENTE(IND).NOME IS NULL THEN
         RAISE E_NOME_NULL;
      END IF;
      
      IF P_TB_CLIENTE(IND).UF NOT IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO') THEN
        RAISE E_UF_INVALIDA;
      END IF;  
      
      UPDATE TB_CLIENTE
         SET NOME         =  P_TB_CLIENTE(IND).NOME
            ,EMAIL        =  P_TB_CLIENTE(IND).EMAIL
            ,CEP          =  P_TB_CLIENTE(IND).CEP
            ,LOGRADOURO   =  P_TB_CLIENTE(IND).LOGRADOURO
            ,NUMERO_LOGR  =  P_TB_CLIENTE(IND).NUMERO_LOGR
            ,BAIRRO       =  P_TB_CLIENTE(IND).BAIRRO
            ,CIDADE       =  P_TB_CLIENTE(IND).CIDADE
            ,UF           =  P_TB_CLIENTE(IND).UF
            ,ATIVO        =  P_TB_CLIENTE(IND).ATIVO
       WHERE ID_CLIENTE   =  P_TB_CLIENTE(IND).ID_CLIENTE;
      
    END LOOP;
    
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      RAISE_APPLICATION_ERROR(-20002, 'Não pode inserir valor duplicado.');
    WHEN E_NOME_NULL THEN
      RAISE_APPLICATION_ERROR(-20001, 'Nome de cliente é requerido.');
    WHEN E_UF_INVALIDA THEN
      RAISE_APPLICATION_ERROR(-20001, 'UF informada não é válida.');
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20003, 'Registro não encontrado.');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20020, 'Erro inesperado:' || SQLERRM);
  
  END PRC_UPDATE_CLIENTE;
  
  -- Procedimento de exclusao
  PROCEDURE PRC_DELETAR_CLIENTE
    (P_TB_CLIENTE    IN  T_TB_CLIENTE) IS
  
  BEGIN
    
    FOR IND IN 1..P_TB_CLIENTE.COUNT 
      LOOP  
    
      IF P_TB_CLIENTE(IND).ID_CLIENTE IS NOT NULL THEN
        DELETE FROM TB_CLIENTE
        WHERE ID_CLIENTE   =  P_TB_CLIENTE(IND).ID_CLIENTE;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20003, 'Registro não encontrado.');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20020, 'Erro inesperado:' || SQLERRM);
  END PRC_DELETAR_CLIENTE;
  
  -- Procedimento de consulta
  PROCEDURE PRC_CONSULTA_CLIENTE
    (P_ID_CLIENTE    IN     TB_CLIENTE.ID_CLIENTE%TYPE
    ,P_TB_CLIENTE    IN OUT RC_TB_CLIENTE) IS
    
  BEGIN
    
    OPEN P_TB_CLIENTE FOR
      SELECT *
        FROM TB_CLIENTE
       WHERE ID_CLIENTE  =  P_ID_CLIENTE;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20003, 'Registro não encontrado.');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20020, 'Erro inesperado:' || SQLERRM);
  END PRC_CONSULTA_CLIENTE;
  
  -- Procedimento lista de clientes
  PROCEDURE PRC_LISTAR_CLIENTES
    (P_NOME           IN    TB_CLIENTE.NOME%TYPE DEFAULT NULL
    ,P_EMAIL          IN    TB_CLIENTE.EMAIL%TYPE DEFAULT NULL
    ,P_RC             OUT   SYS_REFCURSOR) IS
    
    V_QUERY           VARCHAR2(500);
    V_WHERE           VARCHAR2(200) := NULL;
    
  BEGIN
    
    V_QUERY := 'SELECT * ' ||
               '  FROM TB_CLIENTE ';
               
    IF P_NOME IS NOT NULL THEN
      V_WHERE := ' WHERE NOME  =  '||''''||P_NOME||'''';
    END IF;
    
    IF P_EMAIL IS NOT NULL THEN
      IF V_WHERE IS NULL THEN
        V_WHERE := ' WHERE EMAIL  =  '||''''||P_EMAIL||'''';
      ELSE
        V_WHERE := V_WHERE ||
                  '  AND EMAIL  =  '||''''||P_EMAIL||'''';
      END IF;
    END IF;
    
    IF V_WHERE IS NOT NULL THEN
      V_QUERY := V_QUERY || V_WHERE;
    END IF;
    
    OPEN P_RC FOR V_QUERY; 
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20003, 'Registro não encontrado.');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20020, 'Erro inesperado:' || SQLERRM);
  
  END PRC_LISTAR_CLIENTES;
  
end PKG_CLIENTE;
/
