*&---------------------------------------------------------------------*
*& Include          YRPNL_03
*&---------------------------------------------------------------------*
FORM set_fieldcat.
  DATA monthNm TYPE char20.
  DATA actual TYPE char30.
  DATA budget TYPE char30.
  DATA diffrn TYPE char30.
  DATA ytdactual TYPE char30.
  DATA ytdbudget TYPE char30.
  DATA ytddiffrn TYPE char30.
  CLEAR : actual, budget, diffrn, ytdactual, ytdbudget, ytddiffrn, monthNm.
  PERFORM month_name USING p_perio+5(2) CHANGING monthNm.
  actual = |Actual { monthNm } { p_perio(4) }|.
  budget = |Budget { monthNm } { p_perio(4) }|.
  diffrn = |Different { monthNm } { p_perio(4) }|.

  ytdactual = |Actual { p_perio(4) }|.
  ytdbudget = |Budget { p_perio(4) }|.
  ytddiffrn = |Different { p_perio(4) }|.

  REFRESH : lt_fieldcat.
  PERFORM :
  append_fieldcat USING 'PLDESC'      'Description'       'CHAR' '' '' '50' '' ' ' 'LT_PNL' 'L',
  append_fieldcat USING 'ACTVAL'      actual              'CHAR' '' '' '18' '' ' ' 'LT_PNL' 'R',
  append_fieldcat USING 'BUDVAL'      budget              'CHAR' '' '' '18' '' ' ' 'LT_PNL' 'R',
  append_fieldcat USING 'DIFVAL'      diffrn              'CHAR' '' '' '18' '' ' ' 'LT_PNL' 'R',
  append_fieldcat USING 'YTDACTVAL'   ytdactual           'CHAR' '' '' '18' '' ' ' 'LT_PNL' 'R',
  append_fieldcat USING 'YTDBUDVAL'   ytdbudget           'CHAR' '' '' '18' '' ' ' 'LT_PNL' 'R',
  append_fieldcat USING 'YTDDIFVAL'   ytddiffrn           'CHAR' '' '' '18' '' ' ' 'LT_PNL' 'R'.
*  append_fieldcat USING 'REFVAL'   'Currency/Unit'     'CHAR' '' '' '15' '' ' ' 'LT_PNL' 'L'.
*  append_fieldcat USING 'WAERS'    'Currency'          'CUKY' '' '' '50' '' ' ' 'LT_PNL' ''.
ENDFORM.


FORM append_fieldcat USING p_fname p_fdesc p_dtype p_qfield p_cfield p_olen p_sum p_key p_tabname p_just.
  DATA irows TYPE i.
  CLEAR irows.
  DESCRIBE TABLE lt_fieldcat LINES irows.
  irows = irows + 1.
  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos    = irows.
  ls_fieldcat-key        = p_key.
  ls_fieldcat-fieldname  = p_fname.
  ls_fieldcat-seltext_l  = p_fdesc.
  ls_fieldcat-seltext_m  = p_fdesc.
  ls_fieldcat-seltext_s  = p_fdesc.
  ls_fieldcat-datatype   = p_dtype.
  ls_fieldcat-qfieldname = p_qfield.
  ls_fieldcat-cfieldname = p_cfield.
  ls_fieldcat-outputlen  = p_olen.
  ls_fieldcat-do_sum     = p_sum.
  ls_fieldcat-tabname    = p_tabname.
  ls_fieldcat-just       = p_just.

  APPEND ls_fieldcat TO lt_fieldcat.

*  IF rad1 = 'X'.
*
*  ELSE.
*    APPEND ls_fieldcat TO lt_fieldcatd.
*  ENDIF.

ENDFORM.

FORM display_alv.
  CLEAR ls_layout.
  ls_layout-info_fieldname    = 'LINECOLOR'.
*  ls_layout-colwidth_optimize = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_bypassing_buffer      = 'X'
      i_callback_user_command = 'USER_COMMAND'
      i_callback_top_of_page  = 'TOP-OF-PAGE'
      is_layout               = ls_layout
      it_fieldcat             = lt_fieldcat
      it_sort                 = lt_sort
      is_variant              = ls_variant1
*     I_DEFAULT               = 'X'
      i_save                  = 'A'
      i_html_height_top       = 10
*     i_html_height_end       = 150
    TABLES
      t_outtab                = lt_pnl
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
ENDFORM.

FORM top-of-page.

  DATA:
    lv_text LIKE sy-title,
    gs_line TYPE slis_listheader,
    vtime   TYPE char12,
    vtitle  TYPE char50,
    vtitle1 TYPE char50,
    vtgl1   TYPE char10,
    vtgl2   TYPE char10,
    zmonth  TYPE char30,
    zagedas TYPE char50,
    zpctr   TYPE char50,
    zperner TYPE char50,
    vbukrs  TYPE char70,
    vname1  TYPE ad_name1,
    vname2  TYPE ad_name1,
    vname3  TYPE ad_name1,
    vname4  TYPE ad_name1.

  CLEAR : vname1, vname2, vname3, vname4.
  SELECT SINGLE adrc~name1 adrc~name2 adrc~name3 adrc~name4
  FROM adrc
  INNER JOIN t001 ON adrc~addrnumber EQ t001~adrnr
  INTO (vname1, vname2, vname3, vname4)
  WHERE t001~bukrs = p_bukrs.

  CONCATENATE vname1 vname2 vname3 vname4 INTO vtitle SEPARATED BY space.
  CONCATENATE   p_bukrs '-' vtitle
  INTO vbukrs
  SEPARATED BY ' '.

  REFRESH lt_header.
*  CLEAR ls_header.
*  ls_header-typ  = 'H'.
*  ls_header-info = vtitle.
*  APPEND ls_header TO lt_header.
*
*  CLEAR ls_header.
*  ls_header-typ  = 'S'.
*  ls_header-key  = 'Company Code'.
*  ls_header-info = |: { p_bukrs }|.
*  APPEND ls_header TO lt_header.

  CLEAR ls_header.
  ls_header-typ = 'S'.
  ls_header-key = 'Period/Year'.

  PERFORM month_name USING p_perio+5(2) CHANGING ls_header-info.
  ls_header-info = |: { ls_header-info } { p_perio(4) }|.
*  ls_header-info = |: { p_year }|.
  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.

*  CLEAR ls_t023t.
ENDFORM.

FORM user_command USING l_ucomm LIKE sy-ucomm
      l_selfield TYPE slis_selfield.

*  CLEAR ls_data.
*  READ TABLE lt_data INDEX l_selfield-tabindex INTO ls_data.

ENDFORM.

FORM status_set USING rt_extab TYPE slis_t_extab.
  DATA: l_status(20) TYPE c.
  SET PF-STATUS 'STANDARD' EXCLUDING rt_extab.
ENDFORM.

FORM month_name USING p_month CHANGING month_name.

  CASE p_month.
    WHEN '01'. month_name = 'Jan'.
    WHEN '02'. month_name = 'Feb'.
    WHEN '03'. month_name = 'Mar'.
    WHEN '04'. month_name = 'Apr'.
    WHEN '05'. month_name = 'May'.
    WHEN '06'. month_name = 'Jun'.
    WHEN '07'. month_name = 'Jul'.
    WHEN '08'. month_name = 'Aug'.
    WHEN '09'. month_name = 'Sep'.
    WHEN '10'. month_name = 'Oct'.
    WHEN '11'. month_name = 'Nov'.
    WHEN '12'. month_name = 'Des'.
  ENDCASE.

ENDFORM.
