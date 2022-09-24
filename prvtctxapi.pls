--------------------------------------------
--   PRIVATE IMPLEMENTATION (INTERNALS)   --
--       Yuri Voinov  (C) 2004, 2009      --
--------------------------------------------
create or replace package body ctx_api is
 -- --------------------------------------------------------------
 type ReservedWordList is table of varchar2(8);
 v_reserved ReservedWordList := ReservedWordList('ABOUT','ACCUM','BT','BTG','BTI','BTP','FUZZY','HASPATH',
                                  'INPATH','MDATA','MINUS','NEAR','NT','NTG','NTI','NTP','PT','RT','SQE',
                                  'SYN','TR','TRSYN','TT','WITHIN');

 c_version constant varchar2(30) := '1.0.0.5'; -- API version

 v_restab ctx_thes.exp_tab;  -- BT's result table
 v_restab2 ctx_thes.exp_tab; -- NT's result table

 v_qualifier varchar2(256); -- Qualifier buffer
 v_phrase varchar2(256);    -- Global phrase buffer

 text_error exception; -- Uses for specified thesaurus exists check
 term_has_homographs exception; -- Exception if term or phrase has homographs
 pragma exception_init(text_error, -20000); -- Raised when specified thesaurus not loaded
 phrase_error exception;
 pragma exception_init(phrase_error, -20151); -- Phrase not found or thes not loaded.
 -- --------------------------------------------------------------
 procedure free_exp_memory is
 /* INTERNAL USE */
 /* Uses for clean out PL/SQL tables in expansion functions */
 begin
  v_restab.delete;
  v_restab2.delete;
 end free_exp_memory;
 -- --------------------------------------------------------------
 -- Return hardcoded API version
 function version return varchar2 deterministic is
 begin
  return c_version;
 end version;
 -- --------------------------------------------------------------
 function phrase_exists (p_phrase in varchar2,
                         p_thes_name in varchar2 
                         default 'default') return boolean
                         deterministic is
 v_phrase varchar2(512);     -- Phrase refine buffer
 v_phrase_get varchar2(256); -- Get phrase buffer
 begin
  -- Refine p_phrase if contain qualifier
  if instr(p_phrase,'(') > 0 and instr(p_phrase,')') > 0 then
   v_phrase := trim(substr(p_phrase, 1, instr(p_phrase,'(')-1));
  else
   v_phrase := p_phrase;
  end if;

  select thp_phrase
  into v_phrase_get
  from ctx_thes_phrases
  where thp_thesaurus = upper(p_thes_name)
    and thp_phrase = upper(v_phrase);

  return true;
 exception
  when too_many_rows then return true;
  when no_data_found then return false;
  when others then
   raise_application_error(-20150,'Oracle Text error. Possible specified thesaurus not loaded.');
 end phrase_exists;
 -- --------------------------------------------------------------
 function phrase_relation_exists (p_phrase in varchar2,
                                  p_relation in varchar2
                                  default 'bt,btp,nt,ntp,rt,syn',
                                  p_thes_name in varchar2 default 'default') 
                                  return boolean deterministic is
  v_result boolean;
  v_relation varchar2(50);
 begin
  v_relation := upper(p_relation);
  return ctx_thes.has_relation(p_phrase, v_relation, p_thes_name);
 exception
  when text_error then
   raise_application_error(-20150,'Oracle Text error. Possible specified thesaurus not loaded.');
  when others then
   raise_application_error(-20155,'Error ORA' || SQLCODE || ' raised.');
 end phrase_relation_exists;
 -- --------------------------------------------------------------
 function search_expansion_level (p_phrase in varchar2,
                                  p_thes_name in varchar2 default 'default') 
                                  return number deterministic is
  v_init_level number := 0; -- Initial expansion level
  v_top_bt varchar2(255);   -- BT term buffer
  v_nts pls_integer;        -- NT's counter
 begin
  v_phrase := trim(p_phrase); -- Trim leading and trailing spaces
  loop
   v_init_level := v_init_level + 1; -- Increment level
   ctx_thes.bt(v_restab, v_phrase, v_init_level, p_thes_name); -- Get top BT for current level
   v_top_bt := v_restab(v_restab.last).xphrase; -- Get category for current level
   ctx_thes.nt(v_restab2, v_top_bt, v_init_level, p_thes_name); -- Check NT's
   v_nts := v_restab2.count; -- Count NT's for current BT level
  exit when v_nts >= ctx_api.c_nt_terms or v_restab(v_restab.last).xlevel = 0;
  end loop;
  return v_restab(v_restab.last).xlevel; -- Return xlevel
  free_exp_memory; -- Clean out PL/SQL tables
 exception
  when text_error then
   free_exp_memory; -- Clean out PL/SQL tables
   raise_application_error(-20150,'Oracle Text error. Possible specified thesaurus not loaded.');
  when others then
   free_exp_memory; -- Clean out PL/SQL tables
   raise_application_error(-20155,'Error ORA' || SQLCODE || ' raised.');
 end search_expansion_level;
 -- --------------------------------------------------------------
 function search_expansion_term (p_phrase in varchar2,
                                 p_thes_name in varchar2 default 'default') 
                                 return varchar2 deterministic is
  v_init_level number := 0; -- Initial expansion level
  v_top_bt varchar2(255);  -- BT term buffer
  v_nts pls_integer;       -- NT's counter
 begin
  v_phrase := trim(p_phrase); -- Trim leading and trailing spaces
  loop
   v_init_level := v_init_level + 1; -- Increment level
   ctx_thes.bt(v_restab, v_phrase, v_init_level, p_thes_name); -- Get top BT for current level
   v_top_bt := v_restab(v_restab.last).xphrase; -- Get category for current level
   ctx_thes.nt(v_restab2, v_top_bt, v_init_level, p_thes_name); -- Check NT's
   v_nts := v_restab2.count; -- Count NT's for current BT level
  exit when v_nts >= ctx_api.c_nt_terms or v_restab(v_restab.last).xlevel = 0;
  end loop;
  return v_top_bt; -- Return BT term
  free_exp_memory; -- Clean out PL/SQL tables
 exception
  when text_error then
   free_exp_memory; -- Clean out PL/SQL tables
   raise_application_error(-20150,'Oracle Text error. Possible specified thesaurus not loaded.');
  when others then
   free_exp_memory; -- Clean out PL/SQL tables
   raise_application_error(-20155,'Error ORA' || SQLCODE || ' raised.');
 end search_expansion_term;
 -- --------------------------------------------------------------
 function has_homographs (p_phrase in varchar2,
                          p_thes_name in varchar2 default 'default') 
                          return boolean deterministic is
 v_phrase_tmp varchar2(256);
 v_qualifier varchar2(256);
 begin
  if instr(p_phrase,'(') = 0 and instr(p_phrase,')') = 0 then
   -- If p_phrase not contains qualifiers, get it as is.
  v_phrase := trim(p_phrase); -- Trim leading and trailing spaces
  else
   -- If p_phrase contains qualifiers, lets remove qualifier
   -- from open "(" to the end of line.
   v_phrase := substr(trim(p_phrase), 1, instr(trim(p_phrase),'(') - 2);
  end if;
  select ctxsys.ctx_thes_phrases.thp_phrase,
          ctxsys.ctx_thes_phrases.thp_qualifier -- Get phrase and qualifier from thesauri
  into v_phrase_tmp, v_qualifier
  from ctxsys.ctx_thes_phrases -- View ctx_thes_phrase in schema CTXSYS
  where ctxsys.ctx_thes_phrases.thp_thesaurus = upper(p_thes_name)
    and ctxsys.ctx_thes_phrases.thp_phrase = upper(v_phrase);
  if v_phrase_tmp is not null or v_qualifier is null 
   then return false; -- Return false if term only one or has no qualifiers
  end if; -- (but if no qualifiers and term more than once, raises exception)
 exception
  when too_many_rows then
   return true; -- If select returns more than one rows, homographs exists
  when no_data_found then
   raise_application_error(-20151,'Phrase "'||
                           upper(p_phrase)||'" not exist or specified thesaurus "'||
                           upper(p_thes_name)||'" not loaded.');
  when others then
   raise_application_error(-20155,'Error ORA' || SQLCODE || ' raised.');
 end has_homographs;
 -- --------------------------------------------------------------
 function get_note (p_phrase in varchar2,
                    p_thes_name in varchar2 
                    default 'default') return varchar2
                    deterministic is
 -- Get scope note (SN) for phrase if SN exists.
 -- Otherwise returns empty string.
 v_phrase varchar2(512);     -- Phrase buffer
 v_qualifier varchar2(256);  -- Qualifier buffer
 v_note varchar2(2000) := '';
 phrase_not_exists exception;
 begin
  -- Check phrase existence
  if not ctx_api.phrase_exists(p_phrase, p_thes_name) then
   raise phrase_not_exists;
  end if;
  -- Refine p_phrase if contain qualifier
  if instr(p_phrase,'(') > 0 and instr(p_phrase,')') > 0 then
   v_phrase := trim(substr(p_phrase, 1, instr(p_phrase,'(')-1));
   v_qualifier := trim(substr(p_phrase, instr(p_phrase,'('), instr(p_phrase,')')-1));
   -- Selet note for phrase with qualifier
   select thp_scope_note
   into v_note
   from ctx_thes_phrases
   where thp_thesaurus = upper(p_thes_name)
     and thp_phrase = upper(v_phrase)
     and (thp_qualifier is not null 
          and thp_qualifier = upper(v_qualifier));
  else
   v_phrase := p_phrase;
   -- Selet note for phrase without qualifier
   select thp_scope_note
   into v_note
   from ctx_thes_phrases
   where thp_thesaurus = upper(p_thes_name)
     and thp_phrase = upper(v_phrase);
  end if;
  return v_note;  -- Return SN
 exception
  -- Catch both exceptions. Function produces too_many_rows
  -- exception on some thesauri data.
  when no_data_found or too_many_rows then return null;
  when phrase_not_exists then
   raise_application_error(-20151,'Phrase "'||
                           upper(p_phrase)||'" not exist or specified thesaurus "'||
                           upper(p_thes_name)||'" not loaded.');
 end get_note;
 -- --------------------------------------------------------------
 procedure get_qualifiers (p_qualifiers out ctx_api.term_tab,
                           p_phrase in varchar2,
                           p_thes_name in varchar2 default 'default') is
  v_qualifiers ctx_api.term_tab;
  not_found exception;
 begin
  if instr(p_phrase,'(') = 0 and instr(p_phrase,')') = 0 then
   -- If p_phrase not contains qualifiers, get it as is.
  v_phrase := trim(p_phrase); -- Trim leading and trailing spaces
  else
   -- If p_phrase contains qualifiers, lets remove qualifier
   -- from open "(" to the end of line.
   v_phrase := substr(trim(p_phrase), 1, instr(trim(p_phrase),'(') - 2);
  end if;
  select ctxsys.ctx_thes_phrases.thp_qualifier -- Bulk collect qualifiers for term p_phrase
  bulk collect into v_qualifiers
  from ctxsys.ctx_thes_phrases
  where ctxsys.ctx_thes_phrases.thp_thesaurus = upper(p_thes_name)
    and ctxsys.ctx_thes_phrases.thp_phrase = upper(v_phrase);
  if sql%notfound then raise not_found; end if; -- If phrase not found, raise exception
  p_qualifiers := v_qualifiers; -- Return qualifiers
  v_qualifiers.delete;          -- Free memory
 exception
  when not_found then
   v_qualifiers.delete; -- Free memory
   raise_application_error(-20151,'Phrase "'||
                           upper(p_phrase)||'" not exist or specified thesaurus "'||
                           upper(p_thes_name)||'" not loaded.');
  when others then
   v_qualifiers.delete; -- Free memory
   raise_application_error(-20155,'Error ORA' || SQLCODE || ' raised.');
 end get_qualifiers;
 -- --------------------------------------------------------------
 function get_bt (p_phrase in varchar2,
                  p_level in number default 1,
                  p_thes_name in varchar2 default 'default') 
                  return varchar2 deterministic is
 v_res ctx_thes.exp_tab; -- ctx_thes.bt result buffer
 v_ret varchar2(256); -- Return buffer
 begin -- Check phrase for homographs if qualifier is absent
  v_phrase := trim(p_phrase); -- Trim leading and trailing spaces
  if instr(v_phrase,'(') = 0 and instr(v_phrase,')') = 0 then
   if ctx_api.has_homographs (v_phrase, p_thes_name) then
    raise term_has_homographs;
   end if;
  end if;
  ctx_thes.bt(v_res, v_phrase, p_level, p_thes_name); -- Get BT's level p_level
  for i in v_res.last..v_res.last -- Extract only LAST BT
  loop
   v_ret := v_res(i).xphrase;
  end loop;
  return v_ret; -- Return BT
  v_res.delete; -- Free memory
 exception 
  when term_has_homographs then
   raise_application_error(-20152,'Phrase "'||upper(p_phrase)||'" has homographs.');
  when phrase_error then
   raise_application_error(-20151,'Phrase "'||
                           upper(p_phrase)||'" not exist or specified thesaurus "'||
                           upper(p_thes_name)||'" not loaded.');
  when others then
   v_res.delete; -- Free memory
   raise_application_error(-20155,'Error ORA' || SQLCODE || ' raised.');
 end get_bt;
 -- --------------------------------------------------------------
 procedure get_bt (p_bt out ctx_api.term_tab,
                   p_phrase in varchar2,
                   p_level in number default 1,
                   p_thes_name in varchar2 default 'default') is
 v_res ctx_thes.exp_tab; -- ctx_thes.bt result buffer
 begin
  v_phrase := trim(p_phrase); -- Trim leading and trailing spaces
  ctx_thes.bt(v_res, v_phrase, p_level, p_thes_name); -- Get BT's level p_level
  if v_res.count = 1 then p_bt(1) := v_res(1).xphrase; -- If BT's absent, return phrase.
  else -- If phrase has BT's, then return them all, exclude top - original phrase
   for i in 2..v_res.last -- Extract only BT's
   loop
    p_bt(i-1) := v_res(i).xphrase; -- Let's count return array from 1
   end loop;
  end if;
  v_res.delete; -- Free memory
 exception 
  when phrase_error then
   raise_application_error(-20151,'Phrase "'||
                           upper(p_phrase)||'" not exist or specified thesaurus "'||
                           upper(p_thes_name)||'" not loaded.');
  when others then
   v_res.delete; -- Free memory
   raise_application_error(-20155,'Error ORA' || SQLCODE || ' raised.');
 end get_bt;
 -- --------------------------------------------------------------
 procedure get_nt (p_nt out ctx_api.term_tab,
                   p_phrase in varchar2,
                   p_level in number default 1,
                   p_thes_name in varchar2 default 'default') is
 v_res ctx_thes.exp_tab; -- ctx_thes.nt result buffer
 begin -- Check phrase for homographs if qualifier is absent
  v_phrase := trim(p_phrase); -- Trim leading and trailing spaces
  if instr(v_phrase,'(') = 0 and instr(v_phrase,')') = 0 then
   if ctx_api.has_homographs (v_phrase, p_thes_name) then
    raise term_has_homographs;
   end if;
  end if;
  ctx_thes.nt(v_res, v_phrase, p_level, p_thes_name);  -- Get NT's level p_level
  if v_res.count = 1 then p_nt(1) := v_res(1).xphrase; -- If NT's absent, return phrase.
  else -- If phrase has NT's, then return them all, exclude top - original phrase
   for i in 2..v_res.last -- Extract only NT's
   loop
    p_nt(i-1) := v_res(i).xphrase; -- Let's count return array from 1
   end loop;
  end if;
  v_res.delete; -- Free memory
 exception 
  when term_has_homographs then
   raise_application_error(-20152,'Phrase "'||upper(p_phrase)||'" has homographs.');
  when phrase_error then
   raise_application_error(-20151,'Phrase "'||
                           upper(p_phrase)||'" not exist or specified thesaurus "'||
                           upper(p_thes_name)||'" not loaded.');
  when others then
   v_res.delete; -- Free memory
   raise_application_error(-20155,'Error ORA' || SQLCODE || ' raised.');
 end get_nt;
 -- --------------------------------------------------------------
 procedure get_ntp (p_ntp out ctx_api.term_tab,
                    p_phrase in varchar2,
                    p_level in number default 1,
                    p_thes_name in varchar2 default 'default') is
 v_res ctx_thes.exp_tab; -- ctx_thes.ntp result buffer
 begin -- Check phrase for homographs if qualifier is absent
  v_phrase := trim(p_phrase); -- Trim leading and trailing spaces
  if instr(v_phrase,'(') = 0 and instr(v_phrase,')') = 0 then
   if ctx_api.has_homographs (v_phrase, p_thes_name) then
    raise term_has_homographs;
   end if;
  end if;
  ctx_thes.ntp(v_res, v_phrase, p_level, p_thes_name);  -- Get NTP's level p_level
  if v_res.count = 1 then p_ntp(1) := v_res(1).xphrase; -- If NTP's absent, return phrase.
  else -- If phrase has NTP's, then return them all, exclude top - original phrase
   for i in 2..v_res.last -- Extract only NTP's
   loop
    p_ntp(i-1) := v_res(i).xphrase; -- Let's count return array from 1
   end loop;
  end if;
  v_res.delete; -- Free memory
 exception 
  when term_has_homographs then
   raise_application_error(-20152,'Phrase "'||upper(p_phrase)||'" has homographs.');
  when phrase_error then
   raise_application_error(-20151,'Phrase "'||
                           upper(p_phrase)||'" not exist or specified thesaurus "'||
                           upper(p_thes_name)||'" not loaded.');
  when others then
   v_res.delete; -- Free memory
   raise_application_error(-20155,'Error ORA' || SQLCODE || ' raised.');
 end get_ntp;
 -- --------------------------------------------------------------
 procedure get_rt (p_rt out ctx_api.term_tab,
                   p_phrase in varchar2,
                   p_thes_name in varchar2 default 'default') is
 v_res ctx_thes.exp_tab; -- ctx_thes.rt result buffer
 begin -- Check phrase for homographs if qualifier is absent
  v_phrase := trim(p_phrase); -- Trim leading and trailing spaces
  if instr(v_phrase,'(') = 0 and instr(v_phrase,')') = 0 then
   if ctx_api.has_homographs (v_phrase, p_thes_name) then
    raise term_has_homographs;
   end if;
  end if;
  ctx_thes.rt(v_res, v_phrase, p_thes_name); -- Get RT's
  if v_res.count = 1 then p_rt(1) := v_res(1).xphrase; -- If RT's absent, return phrase.
  else -- If phrase has RT's, then return them all, exclude top - original phrase
   for i in 2..v_res.last -- Extract only RT's
   loop
    p_rt(i-1) := v_res(i).xphrase; -- Let's count return array from 1
   end loop;
  end if;
  v_res.delete; -- Free memory
 exception 
  when term_has_homographs then
   raise_application_error(-20152,'Phrase "'||upper(p_phrase)||'" has homographs.');
  when phrase_error then
   raise_application_error(-20151,'Phrase "'||
                           upper(p_phrase)||'" not exist or specified thesaurus "'||
                           upper(p_thes_name)||'" not loaded.');
  when others then
   v_res.delete; -- Free memory
   raise_application_error(-20155,'Error ORA' || SQLCODE || ' raised.');
 end get_rt;
 -- --------------------------------------------------------------
 procedure get_syn (p_syn out ctx_api.term_tab,
                    p_phrase in varchar2,
                    p_thes_name in varchar2 default 'default') is
 v_res ctx_thes.exp_tab; -- ctx_thes.syn result buffer
 begin -- Check phrase for homographs if qualifier is absent
  v_phrase := trim(p_phrase); -- Trim leading and trailing spaces
  if instr(v_phrase,'(') = 0 and instr(v_phrase,')') = 0 then
   if ctx_api.has_homographs (v_phrase, p_thes_name) then
    raise term_has_homographs;
   end if;
  end if;
  ctx_thes.syn(v_res, v_phrase, p_thes_name); -- Get SYN's
  if v_res.count = 1 then p_syn(1) := v_res(1).xphrase; -- If SYN's absent, return phrase.
  else -- If phrase has SYN's, then return them all, exclude top - original phrase
   for i in 2..v_res.last -- Extract only SYN's
   loop
    p_syn(i-1) := v_res(i).xphrase; -- Let's count return array from 1
   end loop;
  end if;
  v_res.delete; -- Free memory
 exception 
  when term_has_homographs then
   raise_application_error(-20152,'Phrase "'||upper(p_phrase)||'" has homographs.');
  when phrase_error then
   raise_application_error(-20151,'Phrase "'||
                           upper(p_phrase)||'" not exist or specified thesaurus "'||
                           upper(p_thes_name)||'" not loaded.');
  when others then
   v_res.delete; -- Free memory
   raise_application_error(-20155,'Error ORA' || SQLCODE || ' raised.');
 end get_syn;
 -- --------------------------------------------------------------
 function search_string_parser (p_search_str in varchar2,
                                p_query_mode in varchar2 default 'keyword',
                                p_logical_op in varchar2 default 'and',
                                p_query_opt in varchar2 
                                default ctx_api.c_query_op_about,
                                p_expansion_level in number default 1,
                                p_thes_name in varchar2 default 'default',
                                p_refine_on in number 
                                default ctx_api.c_refine_off,
                                p_exp_detail_on in number
                                default ctx_api.c_exp_detail_off) 
                                return varchar2 deterministic is
 -- --------------------------------------------
 -- p_query_opt must be:
 -- about (c_query_op_about)
 -- bt (c_query_op_bt)
 -- nt (c_query_op_nt)
 -- rt (c_query_op_rt)
 -- syn (c_query_op_syn)
 -- p_expansion_level must be positive when 
 --                   specified.
 -- p_thes_name can be <= 30 characters.
 -- Known issues:
 -- 1. p_thes_name cannot contain "_" symbols, 
 --    it will be removed from result string!
 -- 2. If p_exp_detail_on is enabled,
 --    p_expansion_level value will be ignored.
 -- 3. If p_query_opt in ('about','syn','rt') or
 --    p_query_mode = 'keyword',
 --    p_exp_detail_on will be ignored.
 -- --------------------------------------------
 type token_tab is table of varchar2(4000) index by binary_integer;
 v_token token_tab; -- Token table

 type exp_lvl_tab is table of number index by binary_integer;
 v_exp_lvl exp_lvl_tab; -- Expansion levels table
 
 type v_tt_rec is record (v_tt_token varchar2(4000), 
                          v_tt_cnt number); -- TT record type
 type v_tt_tab is table of v_tt_rec index by binary_integer; -- TT table type

 v_tt v_tt_tab;           -- TT table
 v_count pls_integer;     -- TT tokens counter
 v_count2 pls_integer;    -- TT tokens counter 2
 c_refine_level constant pls_integer := 1; -- Refine level constant. Higher value
                                           -- means more supercategories occurences.
                                           -- Minimum value is 1!
 /* Note: TT is the Top Term abbreviation */
 -- v_temp varchar2(4000); -- DEBUG
 -- v_temp2 number;        -- DEBUG

 v_buffer varchar2(4000); -- Search string buffer

 v_temp_value varchar2(4000); -- Parser variables
 v_temp_value2 varchar2(4000);
 v_quotes pls_integer;        -- Quotation variable
 n pls_integer;               -- Quotation parser counter
 i pls_integer;               -- Common parser counter
 j pls_integer;               -- Common final string forming counter

 -- Note: Cannot call procedure hr_show_doc from javascript 
 -- when pass symbolic logical operators into parsed string
 v_query_mode varchar2(10); -- Query mode buffer
 c_or_operator constant varchar2(5) := ' or ';   -- OR operator
 c_and_operator constant varchar2(5) := ' and '; -- AND operator
 v_operator varchar2(5) := c_and_operator; -- Operator buffer, default AND
 v_op_fin varchar2(5);                     -- Final op buffer
 v_exp_detail_on number(1) := p_exp_detail_on; -- Expansion detail flag buffer

 v_ext1 varchar2(6);  -- Open thes extension
 v_ext2 varchar2(50); -- Close thes extension (including level and
                      -- thesaurus name)
 v_expansion_level varchar2(10); -- Expansion functions level
 v_thes_name varchar2(30);       -- Thesaurus name buffer

 -- --------------------------------------------------------------
 -- Delete unneeded delimiters in whole token
 function del_delm(p_str in varchar2) return varchar2 is
  v_str varchar2(4000);
 begin
  v_str := replace(p_str,',','');
  while instr(v_str,'  ') > 0 loop  -- Remove unneeded spaces
   v_str := replace(v_str,'  ',' ');
  end loop;
  return v_str;
 end del_delm;

 ---- Escape key word in search string
 function escape_key_word(p_str in varchar2) return varchar2 is
  v_str varchar2(4000) := p_str;  -- Init variable with parameter
 begin
  -- Escape all keywords
  for i in v_reserved.first..v_reserved.last loop
   v_str := replace(v_str,lower(v_reserved(i)),'{'||lower(v_reserved(i))||'}');
  end loop;
  return v_str;
 end escape_key_word;

 -- Remove key word in search string
 function remove_key_word(p_str in varchar2) return varchar2 is
  v_str varchar2(4000) := p_str;  -- Init variable with parameter
 begin
  -- Remove all keywords
  for i in v_reserved.first..v_reserved.last loop
   v_str := replace(v_str,lower(v_reserved(i)),'');
  end loop;
  return v_str;
 end remove_key_word;

 -- Free tokens memory
 procedure free_memory is
 /* Uses for clean out PL/SQL tables in parser function */
 begin
  v_token.delete;
  v_tt.delete;
  if v_exp_detail_on = ctx_api.c_exp_detail_on then
   v_exp_lvl.delete;
  end if;
 exception
  when others then null;
 end free_memory;

 ----
 begin  /* MAIN BLOCK */
  -- -----------------------------------------
  -- Threat null search string
  if nvl(length(p_search_str),0) = 0 then return null; end if;
  -- Lowercase and trim spaces
  v_buffer := trim(lower(p_search_str));
  -- -----------------------------------------
  -- Check query mode. If cannot identify, set KEYWORD by default.
  if lower(p_query_mode) = 'keyword' or 
     lower(p_query_mode) = 'concept' then
   v_query_mode := lower(p_query_mode);
  else v_query_mode := 'keyword';
  end if;
  -- -----------------------------------------
  -- Threat query mode
  if v_query_mode = 'concept' then  -- Check search string for keywords
   v_buffer := escape_key_word(v_buffer); -- In CONCEPT mode ESCAPE keywords
  else 
   v_buffer := remove_key_word(v_buffer); -- In KEYWORD mode REMOVE keywords
   v_exp_detail_on := ctx_api.c_exp_detail_off; -- Turn off exp_detail in KEYWORD mode
  end if;
  -- -----------------------------------------
  -- Threat logical operator
  if lower(p_logical_op) = 'and' or instr(p_logical_op,'&') > 0 then
   v_operator := c_and_operator;
  elsif lower(p_logical_op) = 'or' or instr(p_logical_op,'|') > 0 then
   v_operator := c_or_operator;
  else                          
   v_operator := c_or_operator;
  end if;
  -- -----------------------------------------
  -- Threat ABOUT, RT, SYN and Expansion level flag
  if (substr(lower(p_query_opt),1,2) = 'ab' or 
      substr(lower(p_query_opt),1,2) = 'rt' or 
      substr(lower(p_query_opt),1,2) = 'sy') then
   v_exp_detail_on := ctx_api.c_exp_detail_off; -- Turn off exp_detail in ABOUT,RT,SYN mode
  end if;
  -- -----------------------------------------
  /* First and last symbol check and clean */
  if substr(v_buffer,1,1) = '|' then v_buffer := trim(both '|' from v_buffer);
   elsif substr(v_buffer,1,1) = '&' then v_buffer := trim(both '&' from v_buffer);
   elsif substr(v_buffer,1,1) = '~' then v_buffer := trim(both '~' from v_buffer);
   elsif substr(v_buffer,1,1) = ',' then v_buffer := trim(both ',' from v_buffer);
   elsif substr(v_buffer,1,1) = '=' then v_buffer := trim(both '=' from v_buffer);
  end if;
  -- -----------------------------------------
  -- Clean search string from punctuation, garbage and DR engine keywords
  v_buffer := trim(replace(v_buffer,'|', ' ')); -- Replace any search meta to space
  v_buffer := trim(replace(v_buffer,'~', ' '));
  v_buffer := trim(replace(v_buffer, '`', ' '));
  v_buffer := trim(replace(v_buffer, '$', ' ')); -- STEM op
  v_buffer := trim(replace(v_buffer, '>', ' ')); -- threshold op
  v_buffer := trim(replace(v_buffer, '*', ' ')); -- weight op

  v_buffer := trim(replace(v_buffer,':',' '));
  v_buffer := trim(replace(v_buffer,';',' '));
  v_buffer := trim(replace(v_buffer,':'',',' '));
  v_buffer := trim(replace(v_buffer,'!',' ')); -- SOUNDEX op
  v_buffer := trim(replace(v_buffer,'()','')); -- Suppress empty parenthes
  v_buffer := trim(replace(v_buffer,'[]','')); -- Suppress empty parenthes
  v_buffer := trim(replace(v_buffer,'{}','')); -- Suppress empty parenthes
  v_buffer := trim(replace(v_buffer,'?',' ')); -- FUZZY equiv
  v_buffer := trim(replace(v_buffer,'&',' ')); -- Must be before ',' threat
  v_buffer := trim(replace(v_buffer,'+',' ')); -- ACCUM equiv
  v_buffer := trim(replace(v_buffer,'\',' '));
  --v_buffer := trim(replace(v_buffer,'-',' ')); -- This is printjoin char 
  v_buffer := trim(replace(v_buffer,',',' ')); -- Threat ','
  v_buffer := trim(replace(v_buffer,'.',' '));
  v_buffer := trim(replace(v_buffer,' and ',' ')); -- Remove logical ops
  v_buffer := trim(replace(v_buffer,' or ',' ')); -- Remove logical ops
  v_buffer := trim(replace(v_buffer,'""','" "')); -- Correct double quotation
  -- -----------------------------------------

  -- Parse '"' pairs
  v_quotes := length(v_buffer)-length(replace(v_buffer,'"', ''));
  -- if there are quotes and the quotes are balanced, we'll extract that
  -- terms "as is" and save them into a phrases array
  if (v_quotes > 0 or mod(v_quotes,2) = 0) then
   -- If this predicate be AND, odd '"' will be
   -- ignored all '"' pairs in next parsing stage
   v_temp_value2 := v_buffer;
    for i in 1..v_quotes/2 loop
     n := instr(v_temp_value2,'"');
     v_temp_value := v_temp_value || substr(v_temp_value2,1,n-1);
     v_temp_value2 := substr(v_temp_value2,n+1);
     n := instr(v_temp_value2,'"');
     v_token(i) := trim(substr(v_temp_value2,1,n-1));
     v_temp_value2 := substr(v_temp_value2,n+1);
    end loop;
     v_temp_value := v_temp_value || v_temp_value2;
  else
   v_temp_value := v_buffer;
  end if;

  v_buffer := v_temp_value; -- Let's parse next...
   
  -- dbms_output.put_line('Rest string: '||v_temp_value); -- Debug output

  -- Threat single phrase exception
  if trim(v_buffer) is null and v_token.count > 0 then
   goto Final;
  end if;

  -- Parse and get tokens in the rest string ...
  if instr(v_buffer,' ') > 0 then -- Look ' ' delimiters
   if v_token.count = 0 then i := 1;
    else i := v_token.last + 1; -- Continue parsing
   end if;
   while instr(v_buffer,' ') > 0 loop
    v_token(i) := substr(v_buffer,1,instr(v_buffer,' ')-1);
    i := i + 1; -- Increment counter
    v_buffer := substr(v_buffer,instr(v_buffer,' ')+1);
    v_buffer := trim(v_buffer);
   end loop;
   -- Get the last token
   if substr(v_buffer,length(v_buffer))='\' or
      substr(v_buffer,length(v_buffer))='?' or
      substr(v_buffer,length(v_buffer))=';' then
    v_buffer :=
      substr(v_buffer,1,length(v_buffer)-1)||'\'||
      substr(v_buffer,length(v_buffer));
   end if;
   v_token(i):=v_buffer;
  else
   -- Only one word was in search string
   if substr(v_buffer,length(v_buffer))='\' or
      substr(v_buffer,length(v_buffer))='?' or
      substr(v_buffer,length(v_buffer))=';' then
    v_buffer := substr(v_buffer,1,length(v_buffer)-1)||'\'||
                substr(v_buffer,length(v_buffer));
   end if;
   v_token(1) := v_buffer;
  end if;
  -- Parsing complete!

  /* ====================== */
  /* Query Expansion Detail */
  /* ====================== */
  -- Check and assign expansion level depends query option
  -- (not used when ABOUT, SYN or RT specified)
  -- Note: Only hierarchical relations has expansion levels!
  if substr(lower(p_query_opt),1,2) <> 'ab' then
   -- Check and assign thesaurus name
   if substr(p_thes_name,1,30) = 'default' then
    v_thes_name := null;
   else
    v_thes_name := ','||p_thes_name;
   end if;
   if (substr(lower(p_query_opt),1,2) = 'nt' or   -- If p_exp_detail_on is ON
       substr(lower(p_query_opt),1,2) = 'bt') and -- and uses NT/BT query option
       v_exp_detail_on = ctx_api.c_exp_detail_on  -- and query expansion is ON...
   then                                           -- ... then expansion level up.
    for v_count in v_token.first..v_token.last loop -- Init expansion levels array
     v_exp_lvl(v_count) := ctx_api.search_expansion_level(v_token(v_count), p_thes_name);
    end loop;
   elsif (p_expansion_level = 0 or -- Also check zero (TT level) expansion level
          p_expansion_level = 1 or
          p_expansion_level < 0) or
         (substr(lower(p_query_opt),1,2) <> 'nt' and
          substr(lower(p_query_opt),1,2) <> 'bt') and
          v_exp_detail_on = ctx_api.c_exp_detail_off
   then v_expansion_level := null; -- Default expansion level
   else
    v_expansion_level := ','||to_char(p_expansion_level); -- set the same expansion level
   end if;
  elsif substr(lower(p_query_opt),1,2) = 'ab' then
   -- ABOUT option not uses thesaurus and level
   v_expansion_level := null;
   v_thes_name := null;
  end if;
  /* ====================== */
  /* Query Expansion Detail */
  /* ====================== */

  /* ===================== */
  /* Query Context Refiner */
  /* ===================== */
  -- Refine query context using specified thesaurus
  -- If query mode is CONCEPT and refine is enabled...
  if v_query_mode = 'concept' and p_refine_on = 1 then
   -- Get top terms for tokens in CONCEPT mode ...
   for v_count in v_token.first..v_token.last loop
    v_tt(v_count).v_tt_token := ctx_thes.tt(v_token(v_count), p_thes_name);
   end loop;
   -- Count TT's
   for v_count in v_tt.first..v_tt.last loop
    v_tt(v_count).v_tt_cnt := 0;
    for v_count2 in v_tt.first..v_tt.last loop
     if v_tt(v_count).v_tt_token = v_tt(v_count2).v_tt_token then
      v_tt(v_count).v_tt_cnt := v_tt(v_count).v_tt_cnt + 1;
     end if;
    end loop;
   end loop;
   -- Check if all TT's unique and refine result if not
   for v_count in v_tt.first..v_tt.last loop
   -- For category counter=c_refine_level...
    if v_tt(v_count).v_tt_cnt = c_refine_level then
     v_token(v_count) := ''; -- ...delete source token!
    end if;
   end loop;
  end if;
  /* ===================== */
  /* Query Context Refiner */
  /* ===================== */

 -- DEBUG output
 -- dbms_output.put_line('TT''s:');
 -- for v_count in v_token.first..v_token.last loop
 --  v_temp := v_tt(v_count).v_tt_token;
 --  v_temp2 := v_tt(v_count).v_tt_cnt;
 --  dbms_output.put_line(v_temp||' '||v_temp2);
 -- end loop;
 -- dbms_output.put_line('TT Tokens in array:'||v_tt.count); -- Debug output
 -- dbms_output.put_line('Tokens in array:'||v_token.count); -- Debug output
 -- dbms_output.put_line('Exp levels in array:'||v_exp_lvl.count); -- Debug output

  <<Final>>
  loop
  if v_query_mode = 'keyword' then
   v_ext1 := '';
   v_ext2 := '';
  else
   v_ext1 := 
   case substr(lower(p_query_opt),1,2)
    when 'ab' then 'about('
    when 'bt' then 'bt('
    when 'nt' then 'nt('
    when 'rt' then 'rt('
    when 'sy' then 'syn('
   end; -- End case
   if v_exp_detail_on = ctx_api.c_exp_detail_off then
    v_ext2 := v_expansion_level||v_thes_name||')';
   end if;
  end if;
  -- Threat final string
  v_buffer := null;
  for j in v_token.first..v_token.last loop
   if substr(v_token(j),1,1) = '(' then
    -- If token is single word in () (i.e.(cat)),
    -- we'll ignore this token
    v_token(j) := null;
   end if;
   if instr(v_token(j),'(') > 0 then -- Threat parenthes in qualifiers
    v_token(j) := replace(v_token(j),'(',' (');
   end if;
   v_op_fin := v_operator;
   if v_buffer is null then v_op_fin := null; end if; -- Start line?
   -- Skip empty token entries. This also remove tokens cutted with context refiner.
   if v_token(j) is not null then
    if v_exp_detail_on = ctx_api.c_exp_detail_off then   -- Expansion OFF
     v_buffer := v_buffer||v_op_fin||v_ext1||'{'||del_delm(v_token(j))||'}'||v_ext2;
    elsif v_exp_detail_on = ctx_api.c_exp_detail_on then -- Expansion ON
     v_buffer := v_buffer||v_op_fin||v_ext1||'{'||del_delm(v_token(j))||'}'||','||v_exp_lvl(j)||v_thes_name||')';
    end if;
   end if; 
  end loop;
  exit when 1=1; -- Only one labeled loop
  end loop;

 -- Finally release token tables memory
 free_memory;

 -- -----------------------------------------
 -- Wildcards must be removed in CONCEPT mode
 if (instr(v_buffer,'%') > 0 or instr(v_buffer,'_') > 0)
     and v_query_mode = 'concept' then
  v_buffer := replace(v_buffer,'%','');
  v_buffer := replace(v_buffer,'_','');
 -- Workaround bug 10029.1
 elsif (instr(v_buffer,'%') > 0 or instr(v_buffer,'_') > 0)
        and v_query_mode = 'keyword' then
  v_buffer := replace(v_buffer,'{','');
  v_buffer := replace(v_buffer,'}','');
 end if;
 -- -----------------------------------------

 return v_buffer;

 exception
  when text_error then
   free_memory; -- Release memory and exit if text_error exception occurs
   raise_application_error(-20150,'Oracle Text error. Possible specified thesaurus not loaded.');
  when others then 
   free_memory; -- When any others error, let's release memory
   return null; -- and exit from function with null return
 end search_string_parser;  /* END MAIN BLOCK */
 -- --------------------------------------------------------------
 function term_counter (p_thes_name in varchar2 default 'default')
                       return number deterministic is
 -- Specified thesaurus term counter
 v_count number;
 begin
  select count(*)
  into v_count
  from ctx_thes_phrases
  where thp_thesaurus = upper(p_thes_name)
  group by thp_thesaurus;
 return v_count;
 exception
  when no_data_found then
   raise_application_error(-20150,'Oracle Text error. Possible specified thesaurus not loaded.');
 end term_counter;
 -- --------------------------------------------------------------
 procedure thes_loaded (p_ths_list out ctx_api.thes_tab) is
 -- Get loaded thesauruses
 begin
  select ths_name
  bulk collect into p_ths_list
  from ctx_thesauri;
 exception
  when no_data_found then
   raise_application_error(-20154,'No thesaurus found.');
 end thes_loaded;
 -- --------------------------------------------------------------
end ctx_api;
/

show errors
