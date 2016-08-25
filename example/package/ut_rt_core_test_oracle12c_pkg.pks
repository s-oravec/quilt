create or replace package ut_rt_core_test_oracle12c_pkg is

  -- Author  : HENRY
  -- Created : 15.01.2016 13:25:10
  -- Purpose : 
  
  -- Public type declarations
  type rec_item_type is record (
     idx number,
     dt  date,
     nt  varchar2(50)
     );
  
  type tab_item_type is table of rec_item_type;

  -- Public constant declarations


  -- Public variable declarations


  -- Public function and procedure declarations
  procedure getList(a_cnt_i  in number,
                    a_list_o out tab_item_type);

end ut_rt_core_test_oracle12c_pkg;
/
