*&---------------------------------------------------------------------*
*& Include          YBS_PL_01
*&---------------------------------------------------------------------*
TYPE-POOLS: soi, sbdst.
TYPES :
  BEGIN OF t_bukrs,
    bukrs TYPE t001-bukrs,
    butxt TYPE t001-butxt,
  END OF t_bukrs,

  BEGIN OF t_werks,
    werks TYPE t001w-werks,
    name1 TYPE t001w-name1,
  END OF t_werks,

  BEGIN OF t_matkl,
*    MATNR TYPE MATNR,
    matkl TYPE matkl,
  END OF t_matkl,

  BEGIN OF t_grdata,
    werks TYPE werks_d,
    matnr TYPE matnr,
    menge TYPE menge_d,
    menis TYPE meins,
  END OF t_grdata,

  BEGIN OF ty_str,
    matnr TYPE matnr,
  END OF ty_str.

TYPES:
  BEGIN OF ty_pnl,
    pldesc       TYPE char50,
    actval       TYPE char50,
    budval       TYPE char50,
    difval       TYPE char50,
    ytdactval    TYPE char50,
    ytdbudval    TYPE char50,
    ytddifval    TYPE char50,
    refval       TYPE char50,
    waers        TYPE waers,
    meins        TYPE meins,
    keypl        TYPE ykeypl,
    zparent      TYPE ykeypl,
    linecolor(4),
  END OF ty_pnl.

DATA: lt_structure TYPE TABLE OF yplstr,
      lt_pnl       TYPE TABLE OF ty_pnl,
      lt_tree      TYPE TABLE OF ty_pnl,
      ls_pnl       TYPE ty_pnl.

DATA:
  r_document  TYPE REF TO cl_bds_document_set,
  r_excel     TYPE REF TO i_oi_spreadsheet,
  r_container TYPE REF TO cl_gui_custom_container,
  r_control   TYPE REF TO i_oi_container_control,
  r_proxy     TYPE REF TO i_oi_document_proxy,
  r_error     TYPE REF TO i_oi_error,
  wf_retcode  TYPE soi_ret_string,
  count       TYPE i.

DATA :
  d_clsnam TYPE sbdst_classname  VALUE 'SOFFICEINTEGRATION',
  d_clstyp TYPE sbdst_classtype  VALUE  'OT',
  d_objkey TYPE sbdst_object_key VALUE 'ZPL',
  d_desc   TYPE char255          VALUE 'Template Report PL-V2'.

DATA :
  BEGIN OF t_air OCCURS 0,
    name1 TYPE name1,
  END OF t_air,

  BEGIN OF t_per OCCURS 0,
    period TYPE name1,
  END OF t_per.

DATA : d_lines TYPE i.

DATA it_str TYPE TABLE OF ty_str.



*PARAMETERS:
*  p_bukrs TYPE bukrs OBLIGATORY.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
    p_bukrs TYPE bukrs,
    p_perio TYPE jahrper,
    p_prctr TYPE cepc-prctr.
SELECTION-SCREEN END OF BLOCK b1.
