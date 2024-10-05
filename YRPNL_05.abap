*&---------------------------------------------------------------------*
*& Include          YRPNL_05
*&---------------------------------------------------------------------*
DATA:
  gt_fcat             TYPE lvc_t_fcat,
  gt_header           TYPE slis_t_listheader,
  gs_hierarchy_header TYPE treev_hhdr,
  gs_header           TYPE treev_hhdr,
  gs_node_key         TYPE lvc_nkey,
  gt_keys             TYPE lvc_t_nkey,
  gt_node_key         TYPE TABLE OF lvc_nkey.

DATA: gd_ok TYPE sy-ucomm.
*DATA: lo_tree TYPE REF TO cl_gui_alv_tree.
DATA: lo_tree TYPE REF TO cl_hrpayna_gui_alv_tree.

DATA: ls_fcat   TYPE lvc_s_fcat,
      ld_colpos TYPE i.

*&---------------------------------------------------------------------*
*& Module STATUS_9000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9000 OUTPUT.
  SET PF-STATUS 'PF9000'.
  SET TITLEBAR  'TL9000' WITH 'P&L Report'.

  IF lo_tree IS INITIAL.
    PERFORM f_build_fcat.
    PERFORM f_build_header.
    PERFORM f_create_tree_control.
    PERFORM f_build_hierarchy_header.
    PERFORM f_create_alv_tree.
    PERFORM f_create_hierarchy.
    CALL METHOD lo_tree->frontend_update.
  ENDIF.
  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2.
  IF sy-subrc NE 0.
    MESSAGE i006(aq) WITH 'Error when displaying tree control'
    DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9000 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CNCL'.
      CALL METHOD lo_tree->free.
      LEAVE TO SCREEN 0.

    WHEN 'EXL'.
*      CALL FUNCTION 'ZXLWB_FORM'
*        EXPORTING
*          iv_formname    = 'YPNL_EXP'
*          iv_context_ref = lo_tree.
      CALL FUNCTION 'ZXLWB_FORM'
        EXPORTING
          iv_formname    = 'YPNL_EXP'
          iv_context_ref = lo_tree.

    WHEN 'EXP'.
      DATA: w_node_key TYPE lvc_nkey,
            it_keys    TYPE lvc_t_nkey.

      FIELD-SYMBOLS <fs_data_node> TYPE lvc_nkey.
      FREE it_keys.
      LOOP AT gt_node_key ASSIGNING <fs_data_node>.
        CLEAR w_node_key.
        CALL METHOD lo_tree->get_first_child
          EXPORTING
            i_node_key       = <fs_data_node>
          IMPORTING
            e_child_node_key = w_node_key.
        IF w_node_key IS NOT INITIAL.
          APPEND <fs_data_node> TO it_keys.
        ENDIF.
      ENDLOOP.

      UNASSIGN <fs_data_node>.
      CALL METHOD lo_tree->expand_nodes( it_node_key = it_keys ).
    WHEN 'COL'.
      CALL METHOD lo_tree->collapse_all_nodes.
    WHEN OTHERS.
      CALL METHOD cl_gui_cfw=>dispatch.
  ENDCASE.

  CLEAR gd_ok.
  CALL METHOD cl_gui_cfw=>flush.
ENDMODULE.

FORM tree_view.

  CALL SCREEN 9000.
ENDFORM.

FORM f_build_fcat .
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

  PERFORM :
*  add_fieldcat USING 'PLDESC'   'Description'       'CHAR' '' '' '50' '' ' ' 'LT_PNL' 'L',
  add_fieldcat USING 'ACTVAL'   actual              'CHAR' '' '' '18' '' ' ' 'LT_PNL' 'R',
  add_fieldcat USING 'BUDVAL'   budget              'CHAR' '' '' '18' '' ' ' 'LT_PNL' 'R',
  add_fieldcat USING 'DIFVAL'   diffrn              'CHAR' '' '' '18' '' ' ' 'LT_PNL' 'R',
  add_fieldcat USING 'YTDACTVAL'   ytdactual           'CHAR' '' '' '18' '' ' ' 'LT_PNL' 'R',
  add_fieldcat USING 'YTDBUDVAL'   ytdbudget           'CHAR' '' '' '18' '' ' ' 'LT_PNL' 'R',
  add_fieldcat USING 'YTDDIFVAL'   ytddiffrn           'CHAR' '' '' '18' '' ' ' 'LT_PNL' 'R'.

ENDFORM.                    " F_BUILD_FCAT

FORM add_fieldcat USING p_fname p_fdesc p_dtype p_qfield p_cfield p_olen p_sum p_key p_tabname p_just.
  DATA irows TYPE i.
  CLEAR irows.
  DESCRIBE TABLE gt_fcat LINES irows.
  irows = irows + 1.
  CLEAR ls_fcat.
  ls_fcat-col_pos    = irows.
  ls_fcat-key        = p_key.
  ls_fcat-fieldname  = p_fname.
  ls_fcat-scrtext_l  = p_fdesc.
  ls_fcat-scrtext_m  = p_fdesc.
  ls_fcat-scrtext_s  = p_fdesc.
  ls_fcat-datatype   = p_dtype.
  ls_fcat-qfieldname = p_qfield.
  ls_fcat-cfieldname = p_cfield.
  ls_fcat-outputlen  = p_olen.
  ls_fcat-do_sum     = p_sum.
  ls_fcat-tabname    = p_tabname.
  ls_fcat-just       = p_just.

  APPEND ls_fcat TO gt_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_HEADER
*&---------------------------------------------------------------------*
FORM f_build_header .
  DATA: ls_line TYPE slis_listheader.
  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = sy-title.
  APPEND ls_line TO gt_header.
ENDFORM.                    " F_BUILD_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_TREE_CONTROL
*&---------------------------------------------------------------------*
FORM f_create_tree_control .
  DATA: ld_container(30)    TYPE c,
        lo_custom_container TYPE REF TO cl_gui_custom_container.
* create custom container
  ld_container = 'TREE_CNTR'.
  IF sy-batch IS INITIAL.
    CREATE OBJECT lo_custom_container
      EXPORTING
        container_name              = ld_container
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.
    IF sy-subrc <> 0.
      MESSAGE i208(00) WITH 'ERROR' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.
* create tree control
  CREATE OBJECT lo_tree
    EXPORTING
      parent              = lo_custom_container
      node_selection_mode = cl_gui_column_tree=>node_sel_mode_single
      item_selection      = 'X'
      no_html_header      = ''
      no_toolbar          = ''
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE x208(00) WITH 'ERROR'.                          "#EC NOTEXT
  ENDIF.
ENDFORM.                    " F_CREATE_TREE_CONTROL
*&---------------------------------------------------------------------*
*&      Form  F_BUILD_HIERARCHY_HEADER
*&---------------------------------------------------------------------*
FORM f_build_hierarchy_header .
  gs_header-heading   = 'Description'.
  gs_header-tooltip   = 'Description'.
  gs_header-width     = 60.
  gs_header-width_pix = ''.
ENDFORM.                    " F_BUILD_HIERARCHY_HEADER
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_ALV_TREE
*&---------------------------------------------------------------------*
FORM f_create_alv_tree .
  DATA: ls_variant  TYPE disvariant.
* repid for saving variants
  ls_variant-report = sy-repid.
* Creation of ALV
  CALL METHOD lo_tree->set_table_for_first_display
    EXPORTING
      is_hierarchy_header = gs_header
      it_list_commentary  = gt_header
    CHANGING
      it_outtab           = lt_tree "table must be empty !
      it_fieldcatalog     = gt_fcat.
ENDFORM.                    " F_CREATE_ALV_TREE
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_HIERARCHY
*&---------------------------------------------------------------------*
FORM f_create_hierarchy .
  DATA: lt_level1 TYPE TABLE OF ty_pnl,
        lt_level2 TYPE TABLE OF ty_pnl,
        lt_level3 TYPE TABLE OF ty_pnl.
  DATA: ls_level1 TYPE ty_pnl,
        ls_level2 TYPE ty_pnl,
        ls_level3 TYPE ty_pnl.
  DATA: ld_node_level0 TYPE lvc_nkey,
        ld_node_level1 TYPE lvc_nkey,
        ld_node_level2 TYPE lvc_nkey,
        ld_node_level3 TYPE lvc_nkey,
        ld_node        TYPE lvc_nkey,
        ld_node_text   TYPE lvc_value.

  DATA(lt_lvl1) = lt_pnl.
  DATA(lt_lvl2) = lt_pnl.
  DELETE lt_lvl1 WHERE zparent <> ''.
  DELETE lt_lvl2 WHERE zparent = ''.

  REFRESH gt_node_key.
  SORT lt_lvl2 BY keypl zparent.

  LOOP AT lt_lvl1 ASSIGNING FIELD-SYMBOL(<fs_lvl1>).
    CLEAR ls_level1.
    MOVE-CORRESPONDING <fs_lvl1> TO ls_level1.
    ld_node_text = <fs_lvl1>-pldesc.
    CALL METHOD lo_tree->add_node
      EXPORTING
        i_relat_node_key = ld_node_level0
        i_relationship   = cl_gui_column_tree=>relat_last_child
        i_node_text      = ld_node_text
        is_outtab_line   = ls_level1
      IMPORTING
        e_new_node_key   = ld_node_level1.

    gs_node_key = ls_level1.
    APPEND gs_node_key TO gt_node_key.

    READ TABLE lt_lvl2 ASSIGNING FIELD-SYMBOL(<fs_lvl2>)
      WITH KEY zparent = <fs_lvl1>-keypl.
    IF sy-subrc = 0.
      LOOP AT lt_lvl2 ASSIGNING <fs_lvl2>
        WHERE zparent = <fs_lvl1>-keypl.
        CLEAR ls_level2.
        MOVE-CORRESPONDING <fs_lvl2> TO ls_level2.
        ld_node_text = <fs_lvl2>-pldesc.
        CALL METHOD lo_tree->add_node
          EXPORTING
            i_relat_node_key = ld_node_level1
            i_relationship   = cl_gui_column_tree=>relat_last_child
            i_node_text      = ld_node_text
            is_outtab_line   = ls_level2
          IMPORTING
            e_new_node_key   = ld_node_level2.

        gs_node_key = ld_node_level1.
        APPEND gs_node_key TO gt_node_key.
      ENDLOOP.
    ELSE.
      ld_node_text = <fs_lvl1>-pldesc.
      CALL METHOD lo_tree->add_node
        EXPORTING
          i_relat_node_key = ld_node_level1
          i_relationship   = cl_gui_column_tree=>relat_last_child
          i_node_text      = ld_node_text
          is_outtab_line   = ls_level1
        IMPORTING
          e_new_node_key   = ld_node_level2.

      gs_node_key = ld_node_level1.
      APPEND gs_node_key TO gt_node_key.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CREATE_HIERARCHY
