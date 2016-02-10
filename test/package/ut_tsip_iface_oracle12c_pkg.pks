create or replace package ut_tsip_iface_oracle12c_pkg is

  -- Author  : HENRY
  -- Created : 11.11.2015 14:42:51
  -- Purpose : 
  
  -- Public type declarations
  type rec_item_type is record (
    idx number,
    dt  date,
    nt  varchar2(100)
    );

  type tab_item_type is table of rec_item_type index by pls_integer;
  type tab_item_type1 is table of rec_item_type;
  
  -- Public constant declarations
  

  -- Public variable declarations
  

  -- Public function and procedure declarations
  function getList(a_cnt_i in number) return sys_refcursor;

  function getList1(a_cnt_i in number) return sys_refcursor;

end ut_tsip_iface_oracle12c_pkg;
/
