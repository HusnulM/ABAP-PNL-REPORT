*&---------------------------------------------------------------------*
*& Include          YRPNL_01
*&---------------------------------------------------------------------*
TABLES: bkpf, t001.

TYPES:
  BEGIN OF ty_pnl,
    node         TYPE seu_id,
    node_parent  TYPE seu_id,
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
    keypl	       TYPE ykeypl,
    zparent	     TYPE ykeypl,
    linecolor(4),
  END OF ty_pnl.

DATA: lt_structure TYPE TABLE OF yplstr.

DATA:
  lt_pnl  TYPE TABLE OF ty_pnl,
  lt_tree TYPE TABLE OF ty_pnl,
  ls_pnl  TYPE ty_pnl.

DATA:
  lt_fieldcat  TYPE slis_t_fieldcat_alv,
  lt_fieldcatd TYPE slis_t_fieldcat_alv,
  lt_header    TYPE slis_t_listheader,
  lt_sort      TYPE slis_t_sortinfo_alv,
  lt_events    TYPE slis_t_event,
  ls_variant1	 TYPE disvariant,
  ls_variant2	 TYPE disvariant.

DATA :
  ls_fieldcat TYPE slis_fieldcat_alv,
  ls_layout   TYPE slis_layout_alv,
  ls_sort     TYPE slis_sortinfo_alv,
  ls_header   TYPE slis_listheader,
  ls_key      TYPE slis_keyinfo_alv.
