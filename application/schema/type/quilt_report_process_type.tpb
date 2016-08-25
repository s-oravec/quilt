CREATE OR REPLACE TYPE BODY quilt_report_process_type AS
    --
    CONSTRUCTOR FUNCTION quilt_report_process_type RETURN SELF AS Result IS
    BEGIN
        RETURN;
    END quilt_report_process_type;
    --
    CONSTRUCTOR FUNCTION quilt_report_process_type
    (
        idx NUMBER,
        eor VARCHAR2
    ) RETURN SELF AS Result IS
    BEGIN
        SELF.idx     := idx;
        SELF.tag_eor := eor;
    
        RETURN;
    END quilt_report_process_type;
END;
/
