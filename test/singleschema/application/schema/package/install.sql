rem ----------------------------------------------------------------------------  
rem -- Quilt
rem ---------------------------------------------------------------------------- 
prompt .. Creating test package UT_QUILT_LOGGER
@@ut_quilt_logger.pkg

prompt .. Creating test package UT_QUILT_REPORTED_OBJECTS
@@ut_quilt_reported_objects.pkg

prompt .. Creating test package UT_QUILT_UTIL
@@ut_quilt_util.pkg

prompt .. Creating test package UT_QUILT_COVERAGE
@@ut_quilt_coverage.pkg

rem ----------------------------------------------------------------------------  
rem -- PLex
rem ---------------------------------------------------------------------------- 
prompt .. Creating test package UT_PLEX_LEXER
@@ut_plex_lexer.pkg

rem ----------------------------------------------------------------------------  
rem -- PLParse
rem ---------------------------------------------------------------------------- 
prompt .. Creating package UT_PLPARSE_PARSER
@@ut_plparse_parser.pkg

prompt .. Creating test package UT_PLPARSE_TOKEN_STREAM
@@ut_plparse_token_stream.pkg

prompt .. Creating test package UT_PLPARSE_AST_REGISTRY
@@ut_plparse_ast_registry.pkg


