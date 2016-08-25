CREATE OR REPLACE PACKAGE quilt_const IS

    -- PL/SQL code coverage tool - Constanst

    /** max length test name */
    TEST_NAME_MAX_LEN CONSTANT NUMBER := 2000;

    /** date and time string format */
    DATE_TIME_FM CONSTANT VARCHAR2(30) := 'DD.MM.YYYY HH24:MI:SS';

    -- lcov format tags
    --TN:<test name>
    /** TN tag */
    TAG_TN CONSTANT VARCHAR2(5) := 'TN:';
    --SF:<absolute path to the source file>
    /** SF tag */
    TAG_SF CONSTANT VARCHAR2(5) := 'SF:';
    --FN:<line number of function start>,<function name>
    /** FN tag */
    TAG_FN CONSTANT VARCHAR2(5) := 'FN:';
    --FNDA:<execution count>,<function name>
    /** FNDA tag */
    TAG_FNDA CONSTANT VARCHAR2(5) := 'FNDA:';
    --FNF:<number of functions found>
    /** FNF tag */
    TAG_FNF CONSTANT VARCHAR2(5) := 'FNF:';
    --FNH:<number of function hit>
    /** FNH tag */
    TAG_FNH CONSTANT VARCHAR2(5) := 'FNH:';
    --BRDA:<line number>,<block number>,<branch number>,<taken>
    /** BRDA tag */
    TAG_BRDA CONSTANT VARCHAR2(5) := 'BRDA:';
    --BRF:<number of branches found>
    /** BRF tag */
    TAG_BRF CONSTANT VARCHAR2(5) := 'BRF:';
    --BRH:<number of branches hit>
    /** BRH tag */
    TAG_BRH CONSTANT VARCHAR2(5) := 'BRH:';
    --DA:<line number>,<execution count>[,<checksum>]
    /** DA tag */
    TAG_DA CONSTANT VARCHAR2(5) := 'DA:';
    --LH:<number of lines with a non-zero execution count>
    /** LH tag */
    TAG_LH CONSTANT VARCHAR2(5) := 'LH:';
    --LF:<number of instrumented lines>
    /** LF tag */
    TAG_LF CONSTANT VARCHAR2(5) := 'LF:';
    --end_of_record
    /** EOR tag */
    TAG_EOR CONSTANT VARCHAR2(15) := 'end_of_record';

END quilt_const;
/
