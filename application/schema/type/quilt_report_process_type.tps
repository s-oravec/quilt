CREATE OR REPLACE TYPE quilt_report_process_type  AS OBJECT
(
    idx      NUMBER,
    tag_tn   VARCHAR2(4000),
    tag_sf   VARCHAR2(4000),
    tag_fn   quilt_report_type,
    tag_fnda quilt_report_type,
    tag_fnf  NUMBER,
    tag_fnh  NUMBER,
    tag_brda quilt_report_type,
    tag_brf  NUMBER,
    tag_brh  NUMBER,
    tag_da   quilt_report_type,
    tag_lh   NUMBER,
    tag_lf   NUMBER,
    tag_eor  VARCHAR2(15),
--
    CONSTRUCTOR FUNCTION quilt_report_process_type RETURN SELF AS Result,
--
    CONSTRUCTOR FUNCTION quilt_report_process_type
    (
        idx NUMBER,
        eor VARCHAR2
    ) RETURN SELF AS Result
)
/
