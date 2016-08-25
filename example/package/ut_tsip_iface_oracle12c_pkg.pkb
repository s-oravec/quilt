create or replace package body ut_tsip_iface_oracle12c_pkg is

  -- Private type declarations

  
  -- Private constant declarations
  

  -- Private variable declarations
  

  -- Function and procedure implementations
  function getDate return date
  is
    
  begin
      
      return sysdate;
  end getDate;
  
  function getList(a_cnt_i in number) return sys_refcursor
  is
    l_list    sys_refcursor;
    l_r_list  ut_rt_iface_test_oracle12c_pkg.tab_item_type;
    l_t_item  rec_item_type;
    l_t_list  tab_item_type; -- := tab_item_type();
  begin
    
    ut_rt_iface_test_oracle12c_pkg.getList(a_cnt_i  => a_cnt_i,
                                           a_list_o => l_r_list);
    if l_r_list is not null and l_r_list.count > 0
    then
      for i in 1 .. l_r_list.count
      loop
        --l_t_list.extend;
        l_t_item.idx := l_r_list(i).idx;
        l_t_item.dt  := l_r_list(i).dt;
        l_t_item.nt  := l_r_list(i).nt;
        l_t_list(i) := l_t_item;
      end loop;
    end if;
    open l_list
      for select * from table(l_t_list);
    
    return l_list;
  end getList;

  function getList1(a_cnt_i in number) return sys_refcursor
  is
    l_list    sys_refcursor;
    --l_list1   sys_refcursor;
    l_r_list  ut_rt_iface_test_oracle12c_pkg.tab_item_type;
    l_t_item  rec_item_type;
    l_t_list  tab_item_type1; -- := tab_item_type();
  begin
    
    ut_rt_iface_test_oracle12c_pkg.getList(a_cnt_i  => a_cnt_i,
                                           a_list_o => l_r_list);
    if l_r_list is not null and l_r_list.count > 0
    then
      for i in 1 .. l_r_list.count
      loop
        --l_t_list.extend;
        l_t_item.idx := l_r_list(i).idx;
        l_t_item.dt  := l_r_list(i).dt;
        l_t_item.nt  := l_r_list(i).nt;
        l_t_list(i) := l_t_item;
      end loop;
    end if;
    open l_list --1
      for 'select * from table( :a1 )'
        using l_t_list;
    
    
    return l_list;
  end getList1;

begin
  -- Initialization
  null;
end ut_tsip_iface_oracle12c_pkg;
/
