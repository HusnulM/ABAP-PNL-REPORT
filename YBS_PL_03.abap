*&---------------------------------------------------------------------*
*& Include          YBS_PL_03
*&---------------------------------------------------------------------*
FORM f_open_document USING l_clsnam TYPE sbdst_classname
      l_clstyp TYPE sbdst_classtype
      l_objkey TYPE sbdst_object_key
      l_desc   TYPE char255.

  DATA: locint_signature TYPE sbdst_signature,
        locint_uris      TYPE sbdst_uri,
        locwa_signature  LIKE LINE OF locint_signature,
        locwa_uris       LIKE LINE OF locint_uris.

  IF NOT r_document IS INITIAL.
    RETURN.
  ENDIF.

* Create container control
  CALL METHOD c_oi_container_control_creator=>get_container_control
    IMPORTING
      control = r_control
      retcode = wf_retcode.

  IF wf_retcode NE c_oi_errors=>ret_ok.
    CALL METHOD c_oi_errors=>raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

* Initialize Custom Control
  CREATE OBJECT r_container
    EXPORTING
      container_name = 'EXCEL_CONTROL'. "Custom Control Name

  CALL METHOD r_control->init_control
    EXPORTING
      r3_application_name      = 'EXCEL INPLACE BDS'
      inplace_enabled          = abap_true
      inplace_scroll_documents = abap_true
      parent                   = r_container
      inplace_show_toolbars    = 'X'
    IMPORTING
      retcode                  = wf_retcode.

  IF wf_retcode NE c_oi_errors=>ret_ok.
    CALL METHOD c_oi_errors=>raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

* Create object for cl_bds_document_set
  CREATE OBJECT r_document.

* Get Document with URL
  locwa_signature-prop_name  = 'DESCRIPTION'.
* Description of the table template in OAOR
  locwa_signature-prop_value = l_desc.
  APPEND locwa_signature TO locint_signature.

  CALL METHOD r_document->get_with_url
    EXPORTING
      classname       = l_clsnam
      classtype       = l_clstyp
      object_key      = l_objkey
    CHANGING
      uris            = locint_uris
      signature       = locint_signature
    EXCEPTIONS
      nothing_found   = 1
      error_kpro      = 2
      internal_error  = 3
      parameter_error = 4
      not_authorized  = 5
      not_allowed     = 6.

  IF sy-subrc NE 0.
    MESSAGE 'Error Retrieving Document' TYPE 'E'.
  ENDIF.

  READ TABLE locint_uris INTO locwa_uris INDEX 1.

  CALL METHOD r_control->get_document_proxy
    EXPORTING
      document_type  = 'Excel.Sheet'
    IMPORTING
      document_proxy = r_proxy
      retcode        = wf_retcode.

  IF wf_retcode NE c_oi_errors=>ret_ok.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.
  ENDIF.

* Open Document
  CALL METHOD r_proxy->open_document
    EXPORTING
      document_url     = locwa_uris-uri
      open_inplace     = abap_true
      protect_document = abap_true "Protect Document initially
    IMPORTING
      retcode          = wf_retcode.

  IF wf_retcode NE c_oi_errors=>ret_ok.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.
  ENDIF.

* Get Excel Interface
  CALL METHOD r_proxy->get_spreadsheet_interface
    IMPORTING
      sheet_interface = r_excel
      retcode         = wf_retcode.

  IF wf_retcode NE c_oi_errors=>ret_ok.
    CALL METHOD c_oi_errors=>show_message
      EXPORTING
        type = 'E'.
  ENDIF.

  CALL METHOD r_excel->add_sheet
    EXPORTING
      name    = 'B206'
    IMPORTING
      error   = r_error
      retcode = wf_retcode.
ENDFORM. " F_OPEN_DOCUMENT

FORM f_create_range USING l_top TYPE i
      l_left   TYPE i
      l_row    TYPE i
      l_column TYPE i
      l_range  TYPE char255.

  CALL METHOD r_excel->select_sheet
    EXPORTING
      name    = 'B201'
    IMPORTING
      error   = r_error
      retcode = wf_retcode.

*  IF COUNT = 1. DELETE_SHEET
*
*    CALL METHOD R_EXCEL->SELECT_SHEET
*      EXPORTING
*        NAME    = 'B201'
*      IMPORTING
*        ERROR   = R_ERROR
*        RETCODE = WF_RETCODE.
*  ELSE.
*    CALL METHOD R_EXCEL->SELECT_SHEET
*      EXPORTING
*        NAME    = 'B202'
*      IMPORTING
*        ERROR   = R_ERROR
*        RETCODE = WF_RETCODE.
*  ENDIF.
* Select area for entries to be displayed
  CALL METHOD r_excel->set_selection
    EXPORTING
      top     = l_top
      left    = l_left
      rows    = l_row
      columns = l_column.

  CALL METHOD r_excel->insert_range_dim
    EXPORTING
      name    = l_range
      left    = l_left
      top     = l_top
      rows    = l_row
      columns = l_column
*     updating = 1
    IMPORTING
      error   = r_error.
  IF r_error->has_failed = abap_true.
    CALL METHOD r_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.


ENDFORM. " F_CREATE_RANGE

FORM f_dis_table.
  DATA: locint_fields TYPE TABLE OF rfc_fields.
  DATA : ld_rowt TYPE i.
*====================== Plant =============================
*  PERFORM f_create_range USING 2    " start -n- row in MS Excel
*        2    " start -n- column in MS Excel
*        1    " total row in MS Excel
*        1    " total column in MS Excel
*        'AGENTS1'.     "Range name

*  IF r_error->has_failed = abap_true.
*    CALL METHOD r_error->raise_message
*      EXPORTING
*        type = 'E'.
*  ENDIF.
*
** Get field attributes of the table to be displayed
*  CALL FUNCTION 'DP_GET_FIELDS_FROM_TABLE'
*    TABLES
*      data             = t_air
*      fields           = locint_fields
*    EXCEPTIONS
*      dp_invalid_table = 1
*      OTHERS           = 2.
*
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
** Insert the table entries into Excel
*  CALL METHOD r_excel->insert_one_table
*    EXPORTING
*      fields_table = locint_fields[]  "Defn of fields
*      data_table   = t_air[]     "Data
*      rangename    = 'AGENTS1'         "Range Name
*    IMPORTING
*      error        = r_error
*      retcode      = wf_retcode.
*
*  IF r_error->has_failed = abap_true.
*    CALL METHOD r_error->raise_message
*      EXPORTING
*        type = 'E'.
*  ENDIF.
*
**======================= Append Periode ===============================
*  PERFORM f_create_range USING 4    " start -n- row in MS Excel
*        2    " start -n- column in MS Excel
*        1    " total row in MS Excel
*        1    " total column in MS Excel
*        'AGENTS1'.     "Range name
*
*  IF r_error->has_failed = abap_true.
*    CALL METHOD r_error->raise_message
*      EXPORTING
*        type = 'E'.
*  ENDIF.
*
** Get field attributes of the table to be displayed
*  CALL FUNCTION 'DP_GET_FIELDS_FROM_TABLE'
*    TABLES
*      data             = t_per
*      fields           = locint_fields
*    EXCEPTIONS
*      dp_invalid_table = 1
*      OTHERS           = 2.
*
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
** Insert the table entries into Excel
*  CALL METHOD r_excel->insert_one_table
*    EXPORTING
*      fields_table = locint_fields[]  "Defn of fields
*      data_table   = t_per[]     "Data
*      rangename    = 'AGENTS1'         "Range Name
*    IMPORTING
*      error        = r_error
*      retcode      = wf_retcode.
*
*  IF r_error->has_failed = abap_true.
*    CALL METHOD r_error->raise_message
*      EXPORTING
*        type = 'E'.
*  ENDIF.
*======================= data (internal table) ========================
  DESCRIBE TABLE lt_pnl LINES d_lines.

  PERFORM f_create_range USING 7         " start -n- row in MS Excel
        1         " start -n- column in MS Excel
        d_lines   " total row in MS Excel
        7         " total column in MS Excel
        'AGENTS3'.     "Range name
* menggambar cell
* typ -> biner
* 0 -> margin kiri
* 1 -> margin atas
* 2 -> margin bawah
* 3 -> kanan
* 4 -> horizontal
* 5 -> kiri
* 6 -> garinsya tipis
* 7 -> garisnya tebal
*  7 6 5 4 3 2 1 0
*  0 1 1 1 1 1 1 1 = 127
  CALL METHOD r_excel->set_frame
    EXPORTING
      rangename = 'AGENTS3'
      typ       = 127
      color     = 1
    IMPORTING
      error     = r_error
      retcode   = wf_retcode.

*  CALL METHOD R_EXCEL->SET_FONT
*    EXPORTING
*      RANGENAME = 'AGENTS3'
*      FAMILY    = 'Cambria'
*      SIZE      = 9
*      BOLD      = 1
*      ITALIC    = 0
*      ALIGN     = 0
*    IMPORTING
*      ERROR     = R_ERROR
*      RETCODE   = WF_RETCODE.

  IF r_error->has_failed = abap_true.
    CALL METHOD r_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

* Get field attributes of the table to be displayed
  CALL FUNCTION 'DP_GET_FIELDS_FROM_TABLE'
    TABLES
      data             = lt_pnl
      fields           = locint_fields
    EXCEPTIONS
      dp_invalid_table = 1
      OTHERS           = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* Insert the table entries into Excel
  CALL METHOD r_excel->insert_one_table
    EXPORTING
      fields_table = locint_fields[]  "Defn of fields
      data_table   = lt_pnl[]     "Data
      rangename    = 'AGENTS3'         "Range Name
    IMPORTING
      error        = r_error
      retcode      = wf_retcode.

  IF r_error->has_failed = abap_true.
    CALL METHOD r_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

*  DATA totaldt TYPE i.
*  totaldt = d_lines + 15.
**================Total Per Material Group=====================================
*  PERFORM f_create_range USING totaldt   " start -n- row in MS Excel
*        1         " start -n- column in MS Excel
*        d_lines   " total row in MS Excel
*        5         " total column in MS Excel
*        'AGENTS6'.     "Range name
*
*
*  IF r_error->has_failed = abap_true.
*    CALL METHOD r_error->raise_message
*      EXPORTING
*        type = 'E'.
*  ENDIF.
*
*  CALL METHOD r_excel->set_frame
*    EXPORTING
*      rangename = 'AGENTS6'
*      typ       = 127
*      color     = 1
*    IMPORTING
*      error     = r_error
*      retcode   = wf_retcode.
*
** GET FIELD ATTRIBUTES OF THE TABLE TO BE DISPLAYED
*  CALL FUNCTION 'DP_GET_FIELDS_FROM_TABLE'
*    TABLES
*      data             = it_str
*      fields           = locint_fields
*    EXCEPTIONS
*      dp_invalid_table = 1
*      OTHERS           = 2.
*
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
** Insert the table entries into Excel
*  CALL METHOD r_excel->insert_one_table
*    EXPORTING
*      fields_table = locint_fields[]  "Defn of fields
*      data_table   = it_str[]     "Data
*      rangename    = 'AGENTS6'         "Range Name
*    IMPORTING
*      error        = r_error
*      retcode      = wf_retcode.
*
*  IF r_error->has_failed = abap_true.
*    CALL METHOD r_error->raise_message
*      EXPORTING
*        type = 'E'.
*  ENDIF.

ENDFORM. " F_DIS_TABLE

FORM f_unprotect_sheet .
  DATA: loc_protect   TYPE c,
        loc_sheetname TYPE char31.

* Check whether the sheet is protected
*  in case it's unprotected manually
  CALL METHOD r_excel->get_active_sheet
    IMPORTING
      sheetname = loc_sheetname
      error     = r_error
      retcode   = wf_retcode.

  IF r_error->has_failed = abap_true.
    CALL METHOD r_error->raise_message
      EXPORTING
        type = 'E'.
  ENDIF.

  CALL METHOD r_excel->get_protection
    EXPORTING
      sheetname = loc_sheetname   "Active sheet name
    IMPORTING
      error     = r_error
      retcode   = wf_retcode
      protect   = loc_protect.

  IF r_error->has_failed = abap_true.
    CALL METHOD r_error->raise_message
      EXPORTING
        type = 'E'.
  ELSE.
* If not protected, protect the sheet
    CLEAR loc_protect.
    IF loc_protect NE abap_true.
      CALL METHOD r_excel->protect
        EXPORTING
          protect = abap_false
        IMPORTING
          error   = r_error
          retcode = wf_retcode.

      IF r_error->has_failed = abap_true.
        CALL METHOD r_error->raise_message
          EXPORTING
            type = 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

* The user should not be allowed to change the primary fields.
* The sheet is protected against change and a particular range will
* be unprotected for editing

* yang bisa di edit
* Create a range to enable editing for non key fields
*  PERFORM F_CREATE_RANGE USING 8          " Begin on 8th row
*                               7          " Begin on 7th col
*                               D_LINES    " No of rows reqd
*                               1          " Only 1 columns are editable
*                               'EDIT'.    " Range name

* Unprotect the range for editing
*  CALL METHOD R_EXCEL->PROTECT_RANGE
*    EXPORTING
*      NAME    = 'EDIT'
*      PROTECT = 'X'
*    IMPORTING
*      ERROR   = R_ERROR
*      RETCODE = WF_RETCODE.
*
*  IF R_ERROR->HAS_FAILED = ABAP_TRUE.
*    CALL METHOD R_ERROR->RAISE_MESSAGE
*      EXPORTING
*        TYPE = 'E'.
*  ENDIF.
ENDFORM. " F_UNPROTECT_SHEET

FORM f_close_document .
* Close document
  IF NOT r_proxy IS INITIAL.
    CALL METHOD r_proxy->close_document
      IMPORTING
        error   = r_error
        retcode = wf_retcode.

    IF r_error->has_failed = abap_true.
      CALL METHOD r_error->raise_message
        EXPORTING
          type = 'E'.
    ENDIF.
  ENDIF.
ENDFORM. " F_CLOSE_DOCUMENT
