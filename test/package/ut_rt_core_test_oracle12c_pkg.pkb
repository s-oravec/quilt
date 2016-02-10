create or replace package body ut_rt_core_test_oracle12c_pkg is

  -- Private type declarations
  --type <TypeName> is <Datatype>;
  
  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  function t_rec_item_type(a_id_i in number,
                           a_dt_i in date,
                           a_nt_i in varchar2)
    return rec_item_type
  is
    l_rec rec_item_type;
  begin
    l_rec.idx := a_id_i;
    l_rec.dt := a_dt_i;
    l_rec.nt := a_nt_i;
    return l_rec;
  
  end t_rec_item_type;

  procedure getList(a_cnt_i  in number,
                    a_list_o out tab_item_type)
  is
    l_tab   tab_item_type := tab_item_type();
    l_rec   rec_item_type;
    l_count number;
  begin
    if a_cnt_i is null or a_cnt_i < 0
    then
      l_count := 1;
    else
      l_count := a_cnt_i;
    end if;
    l_tab.extend(l_count);
    for i in 1 .. l_count
    loop
      l_rec := t_rec_item_type(i,sysdate,i ||' - '|| to_char(sysdate,'rrrrmmdd'));
      l_tab(i) := l_rec;
    end loop;
    a_list_o := l_tab;
  end getList;

begin
  -- Initialization
  null;
end ut_rt_core_test_oracle12c_pkg;
/
