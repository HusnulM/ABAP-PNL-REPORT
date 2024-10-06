*&---------------------------------------------------------------------*
*& Include          YBS_PL_02
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
  SET PF-STATUS 'PF1000'.
  SET TITLEBAR  'TL1000'.

  PERFORM F_OPEN_DOCUMENT USING D_CLSNAM
        D_CLSTYP
        D_OBJKEY
        D_DESC.
  PERFORM F_DIS_TABLE.
  PERFORM F_UNPROTECT_SHEET.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'RW' OR '%EX' OR 'EXIT' OR 'CNCL'.

      LEAVE TO SCREEN 0.
      PERFORM f_close_document.

  ENDCASE.
ENDMODULE.
