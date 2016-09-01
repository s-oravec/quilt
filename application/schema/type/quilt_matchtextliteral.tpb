CREATE OR REPLACE Type BODY quilt_matchtextliteral AS

    ----------------------------------------------------------------------------  
    CONSTRUCTOR FUNCTION quilt_matchtextliteral RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END;

    ----------------------------------------------------------------------------  
    OVERRIDING MEMBER FUNCTION isMatchImpl RETURN quilt_token IS
        APOSTROPHE CONSTANT VARCHAR2(1) := '''';
        -- TODO: add info about nModifier to token
        l_nModifier VARCHAR2(1);
        -- TODO: add info about qModifier to token
        l_qModifier         VARCHAR2(1);
        l_qClosingDelimiter VARCHAR2(2);
        l_Text              VARCHAR2(4000);
        PROCEDURE consumeCurrentItemAndAppend IS
        BEGIN
            l_Text := l_Text || quilt_lexer.currentItem;
            quilt_lexer.consume;
        END;
    BEGIN
        -- consume modifiers if present and 
        -- TODO: set modifier flags into token
        IF quilt_lexer.currentItem IN ('n', 'N') THEN
            l_nModifier := quilt_lexer.currentItem;
            quilt_lexer.consume;
        END IF;
        IF quilt_lexer.currentItem IN ('q', 'Q') THEN
            l_qModifier := quilt_lexer.currentItem;
            quilt_lexer.consume;
        END IF;
        IF quilt_lexer.currentItem = APOSTROPHE THEN
            consumeCurrentItemAndAppend;
            -- match qModifier opening delimiter
            IF l_qModifier IS NOT NULL THEN
                CASE quilt_lexer.currentItem
                    WHEN '[' THEN
                        l_qClosingDelimiter := ']';
                    WHEN '{' THEN
                        l_qClosingDelimiter := '}';
                    WHEN '<' THEN
                        l_qClosingDelimiter := '>';
                    WHEN '(' THEN
                        l_qClosingDelimiter := ')';
                    ELSE
                        l_qClosingDelimiter := quilt_lexer.currentItem;
                END CASE;
                consumeCurrentItemAndAppend;
            END IF;
            --
            WHILE NOT quilt_lexer.eof LOOP
                -- consume not '
                IF (l_qModifier IS NULL AND quilt_lexer.currentItem != APOSTROPHE) OR
                   (l_qModifier IS NOT NULL AND quilt_lexer.currentItem != l_qClosingDelimiter) THEN
                    consumeCurrentItemAndAppend;
                ELSIF l_qModifier IS NULL AND quilt_lexer.currentItem = APOSTROPHE THEN
                    -- if ' and next 1 is also ' - consume both
                    IF quilt_lexer.peek(1) = APOSTROPHE THEN
                        consumeCurrentItemAndAppend;
                        consumeCurrentItemAndAppend;
                    ELSE
                        consumeCurrentItemAndAppend;
                        EXIT;
                    END IF;
                ELSIF l_qModifier IS NOT NULL AND quilt_lexer.currentItem = l_qClosingDelimiter THEN
                    -- if closing delimiter is followed by ' - consume both and exit
                    IF quilt_lexer.peek(1) = APOSTROPHE THEN
                        consumeCurrentItemAndAppend;
                        consumeCurrentItemAndAppend;
                        EXIT;
                    ELSE
                        -- closing delimiter is not followed by ' - consume and continue in loop
                        consumeCurrentItemAndAppend;
                    END IF;
                END IF;
            END LOOP;
        END IF;
        --
        IF length(l_Text) > 0 THEN
            RETURN NEW quilt_token(quilt_lexer.tk_TextLiteral, l_nModifier || l_qModifier || l_Text);
        ELSE
            RETURN NULL;
        END IF;
    END;

END;
/
