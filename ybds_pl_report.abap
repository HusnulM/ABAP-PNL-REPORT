*&---------------------------------------------------------------------*
*& Report YBDS_PL_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ybds_pl_report.

INCLUDE ybs_pl_01.
INCLUDE ybs_pl_02.
INCLUDE ybs_pl_03.
INCLUDE ybs_pl_04.

START-OF-SELECTION.
  PERFORM get_data.
  CALL SCREEN 9000.
