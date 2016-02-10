CREATE OR REPLACE TYPE BODY quilt_report_process AS
    --
    CONSTRUCTOR FUNCTION quilt_report_process RETURN SELF AS RESULT
    IS
    BEGIN
        RETURN;
    END quilt_report_process;
    --
    CONSTRUCTOR FUNCTION quilt_report_process(idx NUMBER, eor VARCHAR2) RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.idx := idx;
        SELF.tag_eor := eor;

        RETURN;
    END quilt_report_process;
END;
/
