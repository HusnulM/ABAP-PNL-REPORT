*&---------------------------------------------------------------------*
*& Include          YRPNL_02
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS:
    p_bukrs TYPE bukrs,
    p_perio TYPE jahrper,
    p_prctr TYPE cepc-prctr.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS:
    rb_1 RADIOBUTTON GROUP rb USER-COMMAND ucm DEFAULT 'X',
    rb_2 RADIOBUTTON GROUP rb.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.
  PARAMETERS:
    dsp_1 RADIOBUTTON GROUP dsp USER-COMMAND dsp DEFAULT 'X',
    dsp_2 RADIOBUTTON GROUP dsp,
    dsp_3 RADIOBUTTON GROUP dsp.
SELECTION-SCREEN END OF BLOCK b3.
