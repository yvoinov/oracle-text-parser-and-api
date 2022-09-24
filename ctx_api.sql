-------------------------------------------------------------------------------
-- PROJECT_NAME: CTX_API                                                     --
-- RELEASE_VERSION: 1.0.0.5                                                  --
-- RELEASE_STATUS: Release                                                   --
--                                                                           --
-- REQUIRED_ORACLE_VERSION: 10.1.0.x                                         --
-- MINIMUM_ORACLE_VERSION: 9.2.0.3                                           --
-- MAXIMUM_ORACLE_VERSION: 11.x.x.x                                          --
-- PLATFORM_IDENTIFICATION: Generic                                          --
--                                                                           --
-- IDENTIFICATION: ctx_api.sql                                               --
-- DESCRIPTION: CTX_API package. Contains ConText Search and thesaurus API.  --
-- ------------------------------------------------------------------------- --
-- Package table of contents, syntax and components descriptions:            --
-- ------------------------------------------------------------------------- --
-- function version return varchar2 deterministic;                           --
--                                                                           --
-- Function returns hardcoded API version for application alternative calls. --
-- No arguments.                                                             --
-- ------------------------------------------------------------------------- --
-- function phrase_exists (p_phrase in varchar2,                             --
--                         p_thes_name in varchar2                           --
--                         default 'default') return boolean                 --
--                         deterministic;                                    -- 
--                                                                           --
-- Function checks phrase exists in specified thesaurus.                     --
--                                                                           -- 
-- Arguments:                                                                --
-- p_phrase - specified term. Can be phrase and can contain qualifier.       --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
-- ------------------------------------------------------------------------- --
-- function phrase_relation_exists (p_phrase in varchar2,                    --
--                                  p_relation in varchar2                   --
--                                  default 'bt,btp,nt,ntp,rt,syn',          --
--                                  p_thes_name in varchar2                  --
--                                  default 'default') return boolean        --
--                                  deterministic;                           --
--                                                                           --
-- Function checks relations in thesaurus for specified term.                --
--                                                                           --
-- Arguments:                                                                --
-- p_phrase - specified term. Can be phrase and can contain qualifier.       --
-- p_relation - relations list. Can contain one or more standard relation    --
--              keywords with comma-separated list.                          --
--              Examples: 'bt,ntg','syn','rt','bt,btp,ntp' etc.              --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
-- ------------------------------------------------------------------------- --
-- function search_expansion_level (p_phrase in varchar2,                    --
--                                  p_thes_name in varchar2                  --
--                                  default 'default') return number         --
--                                  deterministic;                           --
--                                                                           --
-- Function returns BT/NT relations expansion level, which contains more     --
-- than c_nt_terms NT's for phrase subtree.                                  --
--                                                                           --
-- Arguments:                                                                --
-- p_phrase - specified term. Can be phrase and can contain qualifier.       --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
-- Known issues: Function returns 0 if phrase is Top Term or absent in thes. --
-- ------------------------------------------------------------------------- --
-- function search_expansion_term (p_phrase in varchar2,                     --
--                                 p_thes_name in varchar2                   --
--                                 default 'default') return varchar2        --
--                                 deterministic;                            --
--                                                                           --
-- Function returns BT subcategory for given phrase subtree, for which BT    --
-- contains more than c_nt_terms NT's.                                       --
--                                                                           --
-- Arguments:                                                                --
-- p_phrase - specified term. Can be phrase and can contain qualifier.       --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
--                                                                           --
-- Known issues: Function returns 0 if phrase is Top Term or absent in thes. --
-- ------------------------------------------------------------------------- --
-- function has_homographs (p_phrase in varchar2,                            -- 
--                          p_thes_name in varchar2                          --
--                          default 'default') return boolean                --
--                          deterministic;                                   --
--                                                                           --
-- Function checks therm for homographs. If homographs exists, returns true. --
--                                                                           --
-- Arguments:                                                                --
-- p_phrase - term for checking.                                             --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
-- ------------------------------------------------------------------------- --
-- procedure get_qualifiers ( p_qualifiers out ctx_api.term_tab,             --
--                            p_phrase in varchar2,                          --
--                            p_thes_name in varchar2 default 'default');    --
--                                                                           --
-- Procedure returns term qualifiers if they exists. If term not exists in   --
-- thesaurus, exception ORA-20151 raised.                                    --
--                                                                           --
-- Arguments:                                                                --
-- p_qualifiers - return structure (table of varchar2) by ctx_api.term_tab.  --
-- p_phrase - term for checking.                                             --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
--                                                                           --
-- Known issues: If term is only one (has no homograps), but defined with    --
-- qualifier, procedure returns this qualifier anyway.                       --
-- ------------------------------------------------------------------------- --
-- function get_note (p_phrase in varchar2,                                  --
--                    p_thes_name in varchar2                                --
--                    default 'default') return varchar2                     --
--                    deterministic;                                         --
--                                                                           --
-- Get scope note (SN) for phrase if it exists. Otherwise function returns   --
-- empty string.                                                             --
--                                                                           --
-- Arguments:                                                                --
-- p_phrase - specified term. Can be phrase and can contain qualifier.       --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
-- ------------------------------------------------------------------------- --
-- function get_bt (p_phrase in varchar2,                                    --
--                  p_level in number default 1,                             --
--                  p_thes_name in varchar2 default 'default')               --
--                  return varchar2 deterministic;                           -- 
--                                                                           --
-- Function returns single BT for term.                                      --
-- If term not exists in thesaurus, then returns themself.                   --
-- If term has homographs, but no qualifiers specified, returns exception    --
-- ORA-20152.                                                                -- 
-- If term has homographs, and qualifier specified, returns BT term with     --
-- specified level (p_level).                                                --
--                                                                           --
-- Arguments:                                                                --
-- p_phrase - term or phrase for BT.                                         --
-- p_level - expansion level for BT.                                         --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
-- Known issues: If term has only BTP hierarchical relation, it threats as   --
--               BT relation.                                                --
-- ------------------------------------------------------------------------- --
--  procedure get_bt (p_bt out ctx_api.term_tab,                             --
--                    p_phrase in varchar2,                                  --
--                    p_level in number default 1,                           --
--                    p_thes_name in varchar2 default 'default');            --
--                                                                           --
-- Procedure returns all BT's for term (BT subtree).                         --
-- If term not exists in thesaurus, then returns themself.                   --
-- If term has homographs, but no qualifiers specified, returns all BT's     --
-- subtrees, one by one, each starting with given term with qualifier.       --
-- If term has homographs and qualifier specified, procedure returns only it --
-- BT's subtree.                                                             --
-- Note: Output table contains BT's sorted by level in descending order.     --
-- Example:                                                                  --
--       cat       - lowest level                                            --
--       animals   - level up                                                --
--       zoology   - level up                                                --
--       science   - level up                                                --
--                                                                           --
-- Arguments:                                                                --
-- p_bt - return structure (table of varchar2) by ctx_api.term_tab.          --
-- p_phrase - term or phrase for BT.                                         --
-- p_level - expansion level for BT. Restricts expansion level.              --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
-- Known issues: If term has only BTP hierarchical relation, it threats as   --
--               BT relation.                                                --
-- ------------------------------------------------------------------------- --
-- procedure get_nt (p_nt out ctx_api.term_tab,                              --
--                   p_phrase in varchar2,                                   --
--                   p_level in number default 1,                            --
--                   p_thes_name in varchar2 default 'default');             --
--                                                                           --
-- Procedure returns NT's for term.                                          --
-- If term not exists in thesaurus, returns exception ORA-20151.             --
-- If term has homographs, but no qualifiers specified, returns exception    --
-- ORA-20152.                                                                --
-- If term has homographs, and qualifier specified, returns NT's for term    --
-- with specified level (p_level).                                           --
-- If term is lowest level (has no NT's), then return themself.              --
--                                                                           --
-- Arguments:                                                                --
-- p_nt - return structure (table of varchar2) by ctx_api.term_tab.          --
-- p_phrase - term or phrase for BT.                                         --
-- p_level - expansion level for BT.                                         --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
-- ------------------------------------------------------------------------- --
-- procedure get_ntp (p_ntp out ctx_api.term_tab,                            --
--                    p_phrase in varchar2,                                  --
--                    p_level in number default 1,                           --
--                    p_thes_name in varchar2 default 'default');            --
--                                                                           --
-- Procedure returns NTP's for term.                                         --
-- If term not exists in thesaurus, returns exception ORA-20151.             --
-- If term has homographs, but no qualifiers specified, returns exception.   --
-- If term has homographs, and qualifier specified, returns NTP's for term   --
-- with specified level (p_level).                                           --
-- If term is lowest level (has no NTP's), then return themself.             --
--                                                                           --
-- Arguments:                                                                --
-- p_ntp - return structure (table of varchar2) by ctx_api.term_tab.         --
-- p_phrase - term or phrase for BT.                                         --
-- p_level - expansion level for BT.                                         --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
-- ------------------------------------------------------------------------- --
-- procedure get_rt (p_rt out ctx_api.term_tab,                              --
--                  p_phrase in varchar2,                                    --
--                  p_thes_name in varchar2 default 'default');              --
--                                                                           --
-- Procedure returns RT's for term.                                          --
-- If term not exists in thesaurus, returns exception ORA-20151.             --
-- If term has homographs, but no qualifiers specified, returns exception    --
-- ORA-20152.                                                                --
-- If term has homographs, and qualifier specified, returns RT's for term.   --
-- If term has no RT's, then return themself.                                --
--                                                                           --
-- Arguments:                                                                --
-- p_rt - return structure (table of varchar2) by ctx_api.term_tab.          --
-- p_phrase - term or phrase for RT.                                         --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
-- ------------------------------------------------------------------------- --
-- procedure get_syn (p_syn out ctx_api.term_tab,                            --
--                   p_phrase in varchar2,                                   --
--                   p_thes_name in varchar2 default 'default');             --
--                                                                           --
-- Procedure returns SYN's for term.                                         --
-- If term not exists in thesaurus, returns exception ORA-20151.             --
-- If term has homographs, but no qualifiers specified, returns exception.   --
-- If term has homographs, and qualifier specified, returns SYN's for term.  --
-- If term has no SYN's, then return themself.                               --
--                                                                           --
-- Arguments:                                                                --
-- p_syn - return structure (table of varchar2) by ctx_api.term_tab.         --
-- p_phrase - term or phrase for SYN.                                        --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
-- ------------------------------------------------------------------------- --
-- function search_string_parser (p_search_str in varchar2,                  --
--                                p_query_mode in varchar2 default 'keyword',--
--                                p_logical_op in varchar2 default 'and',    --
--                                p_query_opt in varchar2                    --
--                                default ctx_api.c_query_op_about,          --
--                                p_expansion_level in number default 1,     --
--                                p_thes_name in varchar2 default 'default', --
--                                p_refine_on in number                      --
--                                default ctx_api.c_refine_off,              --
--                                p_exp_detail_on in number                  --
--                                default ctx_api.c_exp_detail_off)          --
--                                return varchar2 deterministic;             --
--                                                                           --
-- Function is universal parser, supports multiply thesauruses and main      --
-- ISO-2788 and ANSI Z39.19 relations. Also supports all logical operands    --
-- and composed phrases and qualifiers.                                      --
--                                                                           --
-- Arguments:                                                                --
-- p_search_string - incoming search string in varchar2 single-byte charset, --
--                   string length must not be greater than 4000 chars.      --
--                   When parameter value is null, function returns null.    --
-- p_query_mode - parameter controls parsing logic for two different modes:  --
--                - KEYWORD search (thesaurus functions not uses);           --
--                - CONCEPT search (thesaurus functions uses);               --
--                The parameters values are: 'keyword' or 'concept'.         --
--                Default value is 'keyword' (no thesaurus loaded or cannot  --
--                identify query mode from parameter).                       --
-- p_logical_op - controls how tokens will be joined in return string.       --
--                Having two values: and, or. Anyway, this is logical        --
--                operand for search tokens. Default value is AND.           --
-- p_query_opt - controls using thesaurus function in CONCEPT mode. Having   --
--               five possible values:                                       --
--               about, nt, bt, rt or syn. Default value is 'about'.         --
--               In keyword mode will be ommitted.                           -- 
-- p_expansion_level - expansion hierarchical functions (relations) level.   --
--                     Will be used only with nt and bt relations in concept --
--                     mode. In keyword mode and with syn, rt and about will --
--                     be ignored. If specified default value or 1,then will --
--                     be ommitted and default level 1 will be used.         --
-- p_thes_name - thesaurus name in concept mode. Default value is 'default'. --
--               In keyword mode, with about and if value is 'default', it   --
--               will be ommitted. Value can be <= 30 characters.            -- 
-- p_refine_on - Refine search flag.                                         -- 
--            If 0 (default), query will not be refined.                     --
--            If 1, context refiner subfunction is ON (only in CONCEPT query --
--            mode, when using thesaurus) and any words not satisfied main   --
--            query context will be dropped from result string.              --
--            See documentation to learn how context refiner function works. --
-- p_exp_detail_on - Expand NT/BT queries category level. If enabled,        --
--                   expansion level is set to subtree category, in which    --
--                   NT's more than c_nt_terms constant.                     --
-- NOTE: If this flag enabled, p_expansion_level WILL BE IGNORED.            --
-- ------------------------------------------------------------------------- --
-- Function parses search string using this RULES:                           --
-- 1. All punctuation removes from string.                                   --
-- 2. All garbage symbols (which can generate problems with ConText) removes.--
-- 3. String disassembles to the tokens, analyzes and assembles back.        --
-- 4. Before assembling, logical operators and thesaurus functions adds to   --
--    tokens.                                                                --
-- 5. When analyzes, some syntax uses as controls:                           --
--    - Words wrapped into "" threats as single token;                       --   
--    - Words having thesaurus qualifier (i.e. cat (animals) ) threats as    --
--      single token, qualifier remains;                                     --
--    - Words concatenated with qualifier (i.e. cat(animals) ) also threats  --
--      as single token, qualifier remains;                                  --
--    - Empty brackets removes from string (threats as no token);            --
--    - When "" not even in search string, last " will be ignored.           --
-- 6. All 'unsafe' constructions wrappes into escape symbols ({}).           --
-- 7. ConText reserved words removes from search string, or escapes depends  --
--    p_query_mode value.                                                    -- 
-- 8. If metasymbols '%' or '_' found in search string, they pass through in --
--    output string in KEYWORD mode, and will be removed in CONCEPT mode.    --
-- ------------------------------------------------------------------------- --                                                                          --
-- Usage example:                                                            --
-- SQL> declare                                                              --
--  2    v_str varchar2(50) := 'кот пес котопес (животные)';                 --
--  3    v_out varchar2(50);                                                 --
--  4  begin                                                                 --
--  5   v_out := ctx_api.search_string_parser(v_str,'concept','and','nt');   --
--  6   dbms_output.put_line(v_out);                                         --
--  7  end;                                                                  --
--  8  /                                                                     --
-- nt({кот}) and nt({пес}) and nt({котопес})                                 --
--                                                                           --
-- PL/SQL procedure successfully completed.                                  --
-- ------------------------------------------------------------------------- --
-- function term_counter (p_thes_name in varchar2 default 'default')         --
--                       return number;                                      --
--                                                                           --
-- Function counts distinct terms in specified thesaurus.                    --
--                                                                           --
-- Arguments:                                                                --
-- p_thes_name - thesaurus name. Default value is 'default'.                 --
-- If thesauri not found, returns exception ORA-20150.                       --
-- ------------------------------------------------------------------------- --
-- procedure thes_loaded (p_ths_list out ctx_api.thes_tab);                  --
--                                                                           --
-- Procedure returns loaded thesauri list. If no thesauri loaded, returns    --
-- exception ORA-20154.                                                      --
--                                                                           --
-- Arguments:                                                                --
-- p_ths_list has type ctx_api.thes_tab which is thesauri name list of       --
-- varchar2(30).                                                             --
-- ------------------------------------------------------------------------- --
-- Known issues:                                                             --
-- 1. p_thes_name cannot contain "_" symbols,                                --  
--    it will be removed from result string!                                 --
-- 2. If p_exp_detail_on is enabled,                                         --
--    p_expansion_level value will be ignored.                               --
-- 3. If p_query_opt in ('about','syn','rt') or                              --
--    p_query_mode = 'keyword',                                              --
--    p_exp_detail_on will be ignored.                                       --
-- ------------------------------------------------------------------------- --
--                                                                           --
-- INTERNAL_FILE_VERSION: 0.0.1.3                                            --
--                                                                           --
-- COPYRIGHT: Yuri Voinov (C) 2004, 2009                                     --
--                                                                           --
-- MODIFICATIONS:                                                            --
-- 29.03.2008 -Functions phrase_exists and get_note added.                   --
-- 10.08.2007 -Thesaurus content API added.                                  --
-- 28.12.2006 -Added overloaded proc get_bt for returning subtrees of BT's.  --
-- 19.12.2006 -Fix major bug in has_homographs function. Add get_rt, get_syn --
--             functions.                                                    --
-- 09.12.2006 -Rename all package constants.                                 --
-- 03.12.2006 -Type qual_tab and get_qualifiers procedure added. version and --
--             has_homographs functions added.                               --
-- 18.11.2006 -Query options constants added. Expansion level definer const  --
--             and related functions added. Relation exists function added.  --
-- 18.06.2006 -Refiner constants added.                                      --
-- 12.06.2006 -Refiner function added. Free memory call optimized. Exception --
--             TEXT_ERROR added (ORA-20150), also when no thesaurus.         -- 
-- 01.03.2006 -p_expansion_level and p_thes_name parameters added.           --
-- 18.02.2006 -Initial code written.                                         --
-------------------------------------------------------------------------------

create or replace package ctx_api authid current_user is

 -- API version
 function version return varchar2 deterministic;

 -- Thesaurus CTX API
 -- Package constants
 c_query_op_about constant varchar2(5) := 'about'; -- ABOUT query option
 c_query_op_bt constant varchar2(2) := 'bt'; -- BT query option
 c_query_op_nt constant varchar2(2) := 'nt'; -- NT query option
 c_query_op_rt constant varchar2(2) := 'rt'; -- RT query option
 c_query_op_syn constant varchar2(3) := 'syn'; -- SYN query option

 c_refine_on  constant number(1) := 1; -- Context refiner ON
 c_refine_off constant number(1) := 0; -- Context refiner OFF

 c_exp_detail_on constant number(1) := 1;  -- Context expansion ON
 c_exp_detail_off constant number(1) := 0; -- Context expansion OFF

 c_nt_terms constant number(2) := 5; -- Expansion level stop quantity.
                                     -- Stop expansion level if NT's
                                     -- in subtree more than that constant. 
 -- CTX API types
 type term_tab is table of varchar2(256) index by binary_integer;

 -- Check phrase exists in specified thesaurus
 function phrase_exists (p_phrase in varchar2,
                         p_thes_name in varchar2 
                         default 'default') return boolean
                         deterministic;

 -- Check relation exists
 function phrase_relation_exists (p_phrase in varchar2,
                                  p_relation in varchar2
                                  default 'bt,btp,nt,ntp,rt,syn',
                                  p_thes_name in varchar2 
                                  default 'default') return boolean
                                  deterministic;

 -- NT/BT Expansion level definer
 function search_expansion_level (p_phrase in varchar2,
                                  p_thes_name in varchar2 
                                  default 'default') return number
                                  deterministic;

 -- NT/BT Expansion level term
 function search_expansion_term (p_phrase in varchar2,
                                 p_thes_name in varchar2 
                                 default 'default') return varchar2
                                 deterministic;

 -- Check term homographs
 function has_homographs (p_phrase in varchar2,
                          p_thes_name in varchar2 
                          default 'default') return boolean
                          deterministic;

 -- Get homograph's term qualifiers
 procedure get_qualifiers (p_qualifiers out ctx_api.term_tab,
                           p_phrase in varchar2,
                           p_thes_name in varchar2 default 'default');

 -- Get scope note (SN) for phrase if it exists.
 -- Otherwise returns empty string.
 function get_note (p_phrase in varchar2,
                    p_thes_name in varchar2 
                    default 'default') return varchar2
                    deterministic;

 -- Get term BT
 function get_bt (p_phrase in varchar2,
                  p_level in number default 1,
                  p_thes_name in varchar2 default 'default') 
                  return varchar2 deterministic;

 -- Get all term BT's
 procedure get_bt (p_bt out ctx_api.term_tab,
                   p_phrase in varchar2,
                   p_level in number default 1,
                   p_thes_name in varchar2 default 'default');

 -- Get term NT's
 procedure get_nt (p_nt out ctx_api.term_tab,
                   p_phrase in varchar2,
                   p_level in number default 1,
                   p_thes_name in varchar2 default 'default');

 -- Get term NTP's
 procedure get_ntp (p_ntp out ctx_api.term_tab,
                    p_phrase in varchar2,
                    p_level in number default 1,
                    p_thes_name in varchar2 default 'default');

 -- Get term RT's
 procedure get_rt (p_rt out ctx_api.term_tab,
                   p_phrase in varchar2,
                   p_thes_name in varchar2 default 'default');

 -- Get term SYN's
 procedure get_syn (p_syn out ctx_api.term_tab,
                    p_phrase in varchar2,
                    p_thes_name in varchar2 default 'default');

 -- Universal parser 
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
                                return varchar2 deterministic;

 -- Thesaurus content API
 type thes_tab is table of varchar2(30) index by binary_integer;

 -- Specified thesaurus term counter
 function term_counter (p_thes_name in varchar2 default 'default')
                       return number deterministic;

 -- Get loaded thesauruses
 procedure thes_loaded (p_ths_list out ctx_api.thes_tab);

 pragma restrict_references (default, wnds, wnps, rnds, rnps, trust); 

end ctx_api;
/

show errors

-- Can be security issue.
-- Revoke exec privilege from public and grant
-- to only few users if you need.
-- Grant to public need only if package routines
-- calls from Web (modplsql).
grant execute on ctx_api to public
/
