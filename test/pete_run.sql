disconnect
connect QUILT_000100_DEV/QUILT_000100_DEV@local
set serveroutput on size unlimited format wrap
set trimspool on

/*begin
  pete.run(user);
end;
/
*/

DECLARE
    l_token quilt_token;
BEGIN
    quilt_lexer.initialize(p_owner => 'QUILT_000100_DEV', p_name => 'QUILT_LEXER');
    LOOP
        l_token := quilt_lexer.nextToken;
        dbms_output.put_line(l_token.TokenType || ' : ' || l_token.text);
        EXIT WHEN l_token.tokenType = quilt_lexer.tk_EOF;
    END LOOP;
END;
/
