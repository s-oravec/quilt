create or replace package ut_rt_iface_test_oracle12c_pkg is

  -- Author  : HENRY
  -- Created : 11.11.2015 14:43:16
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

end ut_rt_iface_test_oracle12c_pkg;
/
