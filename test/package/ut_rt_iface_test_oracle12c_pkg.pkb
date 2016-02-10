create or replace package body ut_rt_iface_test_oracle12c_pkg is

  -- Private type declarations
  
  
  -- Private constant declarations
  

  -- Private variable declarations
  

  -- Function and procedure implementations

  
  -- Public function and procedure declarations
  procedure getList(a_cnt_i  in number,
                    a_list_o out tab_item_type)
  is
     l_list   ut_rt_core_test_oracle12c_pkg.tab_item_type;
     l_item   rec_item_type;
  begin
    
    a_list_o := tab_item_type();
    ut_rt_core_test_oracle12c_pkg.getList(a_cnt_i => a_cnt_i,
                                          a_list_o => l_list);

    if l_list is not null and l_list.count > 0 then
      for i in l_list.first .. l_list.last loop
        l_item.idx := l_list(i).idx;
        l_item.dt := l_list(i).dt;
        l_item.nt := l_list(i).nt;
        
        a_list_o.extend;
        a_list_o(a_list_o.last) := l_item;
      end loop;
    end if;
  end getList;

begin
  -- Initialization
  null;
end ut_rt_iface_test_oracle12c_pkg;
/
