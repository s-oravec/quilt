CREATE OR REPLACE TYPE quilt_report_process_type  AS OBJECT
(
    idx      NUMBER,
    tag_tn   VARCHAR2(4000),
    tag_sf   VARCHAR2(4000),
    tag_fn   quilt_lcov_lines,
    tag_fnda quilt_lcov_lines,
    tag_fnf  NUMBER,
    tag_fnh  NUMBER,
    tag_brda quilt_lcov_lines,
    tag_brf  NUMBER,
    tag_brh  NUMBER,
    tag_da   quilt_lcov_lines,
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
