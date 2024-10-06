*&---------------------------------------------------------------------*
*& Include          YBS_PL_04
*&---------------------------------------------------------------------*
FORM get_data.
  REFRESH : lt_pnl, lt_structure.
  DATA: lv_wrbtr TYPE wrbtr.
  DATA: lv_menge TYPE menge_d.
  DATA: xfieldval TYPE char50.
*  DATA: xfieldval TYPE dec11_4.
  SELECT * FROM yplstr
  INTO TABLE lt_structure
  WHERE bukrs = p_bukrs.

  LOOP AT lt_structure ASSIGNING FIELD-SYMBOL(<fs_str>).
    CLEAR : xfieldval, ls_pnl.
    ls_pnl-pldesc = <fs_str>-zdesc.
    IF <fs_str>-zvalue_type = 'QUAN'.
      lv_menge = '7899.893'.
      ls_pnl-meins = <fs_str>-zvalue_ref_field.
      WRITE lv_menge TO xfieldval UNIT ls_pnl-meins.
      CONDENSE xfieldval.
      ls_pnl-actval = xfieldval.
      ls_pnl-refval = <fs_str>-zvalue_ref_field.
    ELSE.
      lv_wrbtr = '10000'.
      lv_wrbtr = lv_wrbtr / 100.
      ls_pnl-waers = 'IDR'.
      WRITE lv_wrbtr TO xfieldval CURRENCY ls_pnl-waers.
      CONDENSE xfieldval.
      ls_pnl-actval = xfieldval.
      ls_pnl-refval = 'IDR'.
    ENDIF.

    IF <fs_str>-zparent IS INITIAL.
*      ls_pnl-linecolor = 'C511'. "Green
*      ls_pnl-linecolor = 'C100'.
      ls_pnl-linecolor = 'C410'.
    ELSE.
*      ls_pnl-linecolor = 'C511'.
      ls_pnl-linecolor = 'C211'.
    ENDIF.

    ls_pnl-keypl   = <fs_str>-keypl.
    ls_pnl-zparent = <fs_str>-zparent.
    APPEND ls_pnl TO lt_pnl.
  ENDLOOP.
ENDFORM.
