(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSDiffResources.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2004/11/12  USchuster - new unit
2007/05/01  USchuster - SynEdit 2.0.5

-----------------------------------------------------------------------------*)

unit JVCSDiffResources;

{$I jedi.inc}
{$I compopt.inc}

interface

resourcestring
  //DiffAbout.pas
  JVCSRES_Beta_Version = 'Beta Version';
  JVCSRES_Based_on_FreeVCS_Diff47Merge_Utility_source_by_Thomas_Hensle =
    'Based on FreeVCS Diff/Merge Utility source by Thomas Hensle';
  JVCSRES_Compare_engine_based_on_code_by_Armin_L46_Biernaczyk46 =
    'Compare engine based on code by Armin L. Biernaczyk.';
  JVCSRES_Edit_controls47_Syntax_Highlighter58_Opensource_TSynEdit_146146 =
    'Edit controls/ Syntax Highlighter: Opensource TSynEdit 2.0.5';
  JVCSRES_JEDI_VCS_Diff47Merge_Utility_ = 'JEDI VCS Diff/Merge Utility ';
  JVCSRES_Beta = 'Beta';
  JVCSRES_Filedate58_37s = 'Filedate: %s';

  //DiffCustomKW.pas
  JVCSRES_Add_Reserved_Word = 'Add Reserved Word';
  JVCSRES_Reserved_Word58 = 'Reserved Word:';
  JVCSRES_Edit_Reserved_Word = 'Edit Reserved Word';

  //DiffHLProp.pas
  JVCSRES_40none41 = '(none)';
  JVCSRES_Success = 'Success';
  JVCSRES_Failure = 'Failure';

  //DiffMain.pas
  JVCSRES_Deltas58_0 = 'Deltas: 0';
  JVCSRES_None = 'None';
  JVCSRES_All_known_files12437s = 'All known files|%s';
  JVCSRES_All_files_4042464241124424642 = 'All files (*.*)|*.*';
  JVCSRES_Nothing_to_do46 = 'Nothing to do.';
  JVCSRES_JVCS_Diff_Compare_result_45_37s = 'JVCS Diff Compare result - %s';
  JVCSRES_Base58_37s = 'Base: %s';
  JVCSRES_Compare_to58_37s = 'Compare to: %s';
  JVCSRES_40New_or_changed_lines58_37d41 = '(New or changed lines: %d)';
  JVCSRES_____file58_37s = '    file: %s';
  JVCSRES_______archive58_37s = '      archive: %s';
  JVCSRES_Error = 'Error';
  JVCSRES_Left_editor_view58 = 'Left editor view:';
  JVCSRES_You_have_made_changes_that_have_not_been_applied46 =
    'You have made changes that have not been applied.';
  JVCSRES_Do_you_want_to_apply_these_now63 = 'Do you want to apply these now?';
  JVCSRES_Right_editor_view58 = 'Right editor view:';
  JVCSRES_You_must_enter_a_file_name_first46 = 'You must enter a file name first.';
  JVCSRES_File_6037s_and47or_37s62_not_found46 = 'File <%s and/or %s> not found.';
  JVCSRES_Could_not_open_file_for_reading58 = 'Could not open file for reading:';
  JVCSRES_This_is_a_binary_file46_Unable_to_do_visual_compare46 =
    'This is a binary file. Unable to do visual compare.';
  JVCSRES_CRC32_Base58_37s_45_CRC32_CompareTo58_37s = 'CRC32 Base: %s - CRC32 CompareTo: %s';
  JVCSRES_The_files_are_equal46 = 'The files are equal.';
  JVCSRES_The_files_are_different46 = 'The files are different.';
  JVCSRES_Base58_37s_47_37s_bytes_124_Compare_to58_37s_47_37s_bytes =
    'Base: %s / %s bytes | Compare to: %s / %s bytes';
  JVCSRES_The_files_differ_by_37d_lines_4037d_Blocks4146 =
    'The files differ by %d lines (%d Blocks).';
  JVCSRES_Delta_37d_Lines47_37d_Blocks = 'Delta %d Lines/ %d Blocks';
  JVCSRES_The_files_are_equal = 'The files are equal';
  JVCSRES__or_differ_by_ = ' or differ by ';
  JVCSRES_white_space_ = 'white space ';
  JVCSRES_case_ = 'case ';
  JVCSRES_only46 = 'only.';
  JVCSRES__45_Case58_ignored = ' - Case: ignored';
  JVCSRES__45_LFCR58_stripped = ' - LFCR: stripped';
  JVCSRES__45_Whitespace58_stripped = ' - Whitespace: stripped';
  JVCSRES__45_Hard_space58_stripped = ' - Hard space: stripped';
  JVCSRES__45_HTML_Tags58_stripped = ' - HTML Tags: stripped';
  JVCSRES_Delta58_4547_45 = 'Delta: -/ -';
  JVCSRES__File58_37s_4037s41_9137s93 = ' File: %s (%s) [%s]';
  JVCSRES_Base_version = 'Base version';
  JVCSRES_Compare_to_version = 'Compare to version';
  JVCSRES_Unable_to_save58_37s = 'Unable to save: %s';
  JVCSRES_Exception58_37s = 'Exception: %s';
  JVCSRES_Save_left_editor_view = 'Save left editor view';
  JVCSRES_Save_right_editor_view = 'Save right editor view';
  JVCSRES__Modified = ' Modified';
  JVCSRES__ReadOnly = ' ReadOnly';
  JVCSRES_This_is_a_read45only_file_or_just_a_temporary_file_copy_created_by_JEDI_VCS =
    'This is a read-only file or just a temporary file copy created by JEDI VCS';
  JVCSRES_40probably_the_file_is_curently_checked_in4146 =
    '(probably the file is curently checked in).';
  JVCSRES_Therefore_this_file_cannot_be_edited46 = 'Therefore this file cannot be edited.';
  JVCSRES_MRU_items_are_blank46 = 'MRU items are blank.';
  JVCSRES_Can39t_search_for_empty_text33 = 'Can''t search for empty text!';
  JVCSRES_SearchText_3937s39_not_found33 = 'SearchText ''%s'' not found!';
  JVCSRES_Can39t_replace_an_empty_text33 = 'Can''t replace an empty text!';
  JVCSRES_SearchText_3437s34_could_not_be_replaced33 = 'SearchText "%s" could not be replaced!';
  JVCSRES_Are_you_sure_you_want_to_delete_the_file = 'Are you sure you want to delete the file';
  JVCSRES_Remember_that_you_are_about_to_delete_the_file_on_disk33 =
    'Remember that you are about to delete the file on disk!';
  JVCSRES_Unable_to_delete_the_file = 'Unable to delete the file';
  JVCSRES_Hex_View = 'Hex View';
  JVCSRES__Base___ASCII62 = ' Base   ASCII>';
  JVCSRES__Base_____Hex62 = ' Base     Hex>';
  JVCSRES__Target_ASCII62 = ' Target ASCII>';
  JVCSRES__Target___Hex62 = ' Target   Hex>';

  //DiffSimpleReport.pas
  JVCSRES_Pr38int_report_4012637d_lines41 = 'Pr&int report (~%d lines)';
  JVCSRES_Preview = 'Preview';
  JVCSRES_Cannot_access_clipboard46 = 'Cannot access clipboard.';
  JVCSRES_Save_report_to_file = 'Save report to file';
  JVCSRES_Text_files_404246txt411244246txt124All_files_4042464241124424642 =
    'Text files (*.txt)|*.txt|All files (*.*)|*.*';
  JVCSRES_Parsing_the_ListView_content_raised_exception58_ =
    'Parsing the ListView content raised exception: ';
  JVCSRES_Error_while_trying_to_save_the_file_37s = 'Error while trying to save the file %s';
  JVCSRES_ShellExecute_Error_6037s62 = 'ShellExecute Error <%s>';
  JVCSRES_You_do_not_have_a_default_printer_defined33 = 'You do not have a default printer defined!';
  JVCSRES_JVCS_Diff_Report = 'JVCS Diff Report';
  JVCSRES_Save_report_to_HTML_file = 'Save report to HTML file';
  JVCSRES_HTML_files_404246htm594246html411244246htm594246html124All_files_4042464241124424642 =
    'HTML files (*.htm;*.html)|*.htm;*.html|All files (*.*)|*.*';
  JVCSRES_Reading_file_6037s62 = 'Reading file <%s>';
  JVCSRES_raised_exception58 = 'raised exception:';
  JVCSRES_JVCS_Diff_HTML_Report = 'JVCS Diff HTML Report';
  JVCSRES_Save_report_to_RTF_file = 'Save report to RTF file';
  JVCSRES_RTF_files_404246rtf411244246rtf124All_files_4042464241124424642 =
    'RTF files (*.rtf)|*.rtf|All files (*.*)|*.*';

implementation

end.
