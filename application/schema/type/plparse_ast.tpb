CREATE OR REPLACE Type BODY plparse_ast AS

    ----------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION plparse_ast(token plex_token) RETURN SELF AS Result IS
    BEGIN
        self.token       := token;
        self.symbol_type := NULL;
        self.children    := plparse_AstChildren();
        RETURN;
    END;

    ----------------------------------------------------------------------------
    MEMBER PROCEDURE addChild(child plparse_ast) IS
    BEGIN
        IF child IS NOT NULL THEN
            children.extend;
            children(children.count) := child.id_registry;
        END IF;
    END;

    ----------------------------------------------------------------------------
    MEMBER FUNCTION toString RETURN VARCHAR2 IS
        l_Result VARCHAR2(32767);
        l_child  plparse_ast;
    BEGIN
        IF self.children.count > 0 THEN
            FOR idx IN 1 .. self.children.count LOOP
                l_child := plparse_ast_util.get_by_id(self.children(idx));
                IF idx = 1 THEN
                    l_Result := l_Result || l_child.toString;
                ELSE
                    l_Result := l_Result || ',' || l_child.toString;
                END IF;
            END LOOP;
            RETURN self.token.token || '(' || l_Result || ')';
        END IF;
        RETURN self.token.token;
    END;

END;
/
