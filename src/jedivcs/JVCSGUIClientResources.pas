(*-----------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/MPL-1.1.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: JVCSGUIClientResources.pas

The Initial Developer of the original code (JEDI VCS) is:
  Uwe Schuster (jedivcs@bitcommander.de)

Componentes and used code which is used in this code are explictly stated to
be copyright of the respective author(s).

Last Modified: see History

Known Issues:
-----------------------------------------------------------------------------

Unit history:

2004/02/04  USchuster - new unit
2004/02/19  USchuster - new strings
2004/02/27  USchuster - new strings
2004/04/17  USchuster - new strings
2004/09/28  USchuster - new strings
2004/10/08  THuber    - new strings
2004/10/09  THuber    - new strings
2004/10/10  THuber    - new strings
2004/10/31  USchuster - new strings
2004/11/02  USchuster - new strings
2004/11/03  USchuster - new strings
2004/11/03  THuber    - new strings
2004/11/05  USchuster - new strings
2004/11/07  USchuster - new strings
2004/11/27  USchuster - new strings
2005/01/06  THuber    - new strings
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC1 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/02/26  THuber    - changed resstring, deleted one, added one
2005/03/26  USchuster - new strings
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC2 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/05/22  USchuster - new strings
2005/06/22  CSchuette - new strings
2005/06/30  CSchuette - new strings
2005/07/03  CSchuette - new strings
2005/07/15  THuber    #3091 added hints for LastComment & CommentFromToDo
2005/07/24  USchuster - new strings
2005/10/16  USchuster - new strings
2005/11/28  USchuster - new strings for mantis #3291
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 2.40 RC3 was released ^^^^^^^^^^^^^^^^^^^^^^^^^^^
2005/12/30  USchuster - new strings for mantis #3381
2007/01/21  USchuster - typos
2008/02/16  USchuster - new strings
2008/03/15  USchuster - new strings
2008/07/01  USchuster - new strings
2010/01/24  USchuster - new strings

-----------------------------------------------------------------------------*)

unit JVCSGUIClientResources;

{$I jedi.inc}
{$I compopt.inc}

interface

resourcestring
  //VerSet.pas
  JVCSRES_The_version_info_resource_JVCSVer46res_was_not_found_in_the_current_project_37s46 =
    'The version info resource JVCSVer.res was not found in the current project %s.';
  JVCSRES_An_old_version_40FVCSVer46res41_of_the_version_info_resource_was_found_in_the_current_project46 =
    'An old version (FVCSVer.res) of the version info resource was found in the current project.';
  JVCSRES_Remove_FVCSVer46res_from_37s_and_follow_this_steps58 =
    'Remove FVCSVer.res from %s and follow this steps:';
  JVCSRES_37s_resource_compiler = '%s resource compiler';
  JVCSRES_Programs_404246exe594246com594246bat411244246exe594246com594246bat124All_files_4042464241124424642 =
    'Programs (*.exe;*.com;*.bat)|*.exe;*.com;*.bat|All files (*.*)|*.*';
  JVCSRES_146_Disable_39Include_version_information46464639_in_Project124Options46 =
    '1. Disable ''Include version information...'' in Project|Options.';
  JVCSRES_246_Delete_all_version_informations_in_37s_to_prevent_39Duplicate_Resource39_errors46 =
    '2. Delete all version informations in %s to prevent ''Duplicate Resource'' errors.';
  JVCSRES_346_Include_12336R_JVCSVER46RES125_in_37s46 = '3. Include {$R JVCSVER.RES} in %s.';

  //ProjAdmin.pas
  JVCSRES_Do_you_want_to_abort_opening_project_6037s62_63 =
    'Do you want to abort opening project <%s>?';
  JVCSRES_Fatal_Error33_Unable_to_open_the_file_storage_object33 =
    'Fatal Error! Unable to open the file storage object!';
  JVCSRES_Will_use_Registry_for_configuration_storage46 =
    'Will use Registry for configuration storage.';
  JVCSRES_Storage_Object_update_failed33 = 'Storage Object update failed!';
  JVCSRES_Custom_view_filter_is_inactiv33_Activate_now63 =
    'Custom view filter is inactiv! Activate now?';
  JVCSRES_Password_successfully_changed46 = 'Password successfully changed.';
  JVCSRES_Rename_module = 'Rename module';
  JVCSRES_Enter_a_new_module_name58_40same_extension3341 =
    'Enter a new module name: (same extension!)';
  JVCSRES_You_dropped_37d_files_onto_the_project_manager46 =
    'You dropped %d files onto the project manager.';
  JVCSRES_Would_you_like_to_add_them_to_the_current_project63 =
    'Would you like to add them to the current project?';
  JVCSRES_E38xit = 'E&xit';
  JVCSRES_Internal_Notify58_Server58_914693_47_Mailslot58_91FVCSMail93_45_Init58_37s =
    'Internal Notify: Server: [.] / Mailslot: [FVCSMail] - Init: %s';
  JVCSRES_Success = 'Success';
  JVCSRES_Warning33_Notify_services_may_not_be_available = 'Warning! Notify services may not be available';
  JVCSRES_Internal_Notify_Init_raised_exception58_37s = 'Internal Notify Init raised exception: %s';
  JVCSRES_not_active = 'not active';
  JVCSRES_A38uto_Refresh_4037dmin41 = 'A&uto Refresh (%dmin)';
  JVCSRES_37s47_Current_Project = '%s/ Current Project';
  JVCSRES_37s47_All_Projects = '%s/ All Projects';
  JVCSRES_JEDI_VCS_runs_currently_in_34Beginners34_mode46 =
    'JEDI VCS runs currently in "Beginners" mode.';
  JVCSRES_To_access_all_functionality_go_to_menu_34Options34_and =
    'To access all functionality go to menu "Options" and';
  JVCSRES_check_the_menu_item_34Enable_Expert_Menu3446 =
    'check the menu item "Enable Expert Menu".';
  JVCSRES_You_have_37s_SMTP_mail_records_4037n_k41_in_your_SMTP_out_folder46 =
    'You have %s SMTP mail records (%n k) in your SMTP out folder.';
  JVCSRES_Make_sure_that_the_JEDI_VCS_forwarder_34FVCSSMTP46exe34_is_up_and_running46 =
    'Make sure that the JEDI VCS forwarder "FVCSSMTP.exe" is up and running.';
  JVCSRES_more_than_37d = 'more than %d';
  JVCSRES_Server58_34Global_settings34_flag_is_set_by_Admin_on_37s =
    'Server: "Global settings" flag is set by Admin on %s';
  JVCSRES_IDE_Topmost_view58_37s = 'IDE Topmost view: %s';
  JVCSRES_Selected58_37d = 'Selected: %d';
  JVCSRES_Project_name_is_invalid58_37s = 'Project name is invalid: %s';
  JVCSRES_New_project58_37s = 'New project: %s';
  JVCSRES_Not_connected = 'Not connected';
  JVCSRES_Transfer58_37sk = 'Transfer: %sk';
  JVCSRES_Core58_37d = 'Core: %d';
  JVCSRES_Forms58_37d = 'Forms: %d';
  JVCSRES_37d_404337d41_modules_45_37s_k = '%d (+%d) modules - %s k';
  JVCSRES_37d_modules_45_37s_k = '%d modules - %s k';
  JVCSRES_No_project = 'No project';
  JVCSRES_Server_request58_40Project_ID_for58_37s41 = 'Server request: (Project ID for: %s)';
  JVCSRES_Guest = 'Guest';
  JVCSRES_Archive_Admin = 'Archive Admin';
  JVCSRES_Server_reports_a_known_project44_ID_37s = 'Server reports a known project, ID %s';
  JVCSRES_Access_level_granted_to_37s58_37s = 'Access level granted to %s: %s';
  JVCSRES_Project_administrator = 'Project administrator';
  JVCSRES_Archive_administrator = 'Archive administrator';
  JVCSRES_default_rights = 'default rights';
  JVCSRES_Would_you_like_to_assign_the_project_to_a_group63 =
    'Would you like to assign the project to a group?';
  JVCSRES_Server_reports_a_known_project46_Created58_37s_by_37s_ID58_37d_45_Last_write_access58_37s_by_37s =
    'Server reports a known project. Created: %s by %s ID: %d - Last write access: %s by %s';
  JVCSRES_Server_request58_40Shared_modules_assigned_to58_37s41 =
    'Server request: (Shared modules assigned to: %s)';
  JVCSRES_Server_request58_40Module_bug_list41 = 'Server request: (Module bug list)';
  JVCSRES_Server_request58_40Labels_assigned_to58_37s41 = 'Server request: (Labels assigned to: %s)';
  JVCSRES_N47A = 'N/A';
  JVCSRES_Out = 'Out';
  JVCSRES_In = 'In';
  JVCSRES_Yes = 'Yes';
  JVCSRES_No = 'No';
  JVCSRES_37s_on_37s = '%s on %s';
  JVCSRES_37s_910s93 = '%s [0s]';
  JVCSRES_Server_request58_40Reload_latest_global_settings41 =
    'Server request: (Reload latest global settings)';
  JVCSRES_IDE_request58_40Core_modules_assigned_to58_37s41 =
    'IDE request: (Core modules assigned to: %s)';
  JVCSRES_IDE_reports_37d_core_modules = 'IDE reports %d core modules';
  JVCSRES_Adding_configuration_4046cfg41_file_to_core_modules =
    'Adding configuration (.cfg) file to core modules';
  JVCSRES_Adding_desktop_4046dsk41_file_to_core_modules =
    'Adding desktop (.dsk) file to core modules';
  JVCSRES_Local58_40Custom_view_filter_file58_37s41 = 'Local: (Custom view filter file: %s)';
  JVCSRES_Custom_view_filter_contains58_37d_modules = 'Custom view filter contains: %d modules';
  JVCSRES_Custom_view_filter58_Not_defined = 'Custom view filter: Not defined';
  JVCSRES_Server_request58_40Modules_38_revisions_assigned_to58_37s41 =
    'Server request: (Modules & revisions assigned to: %s)';
  JVCSRES_Local58_40File_size_38_attributes41 = 'Local: (File size & attributes)';
  JVCSRES_Server_request58_40Modules_without_revision_assigned_to58_37s41 =
    'Server request: (Modules without revision assigned to: %s)';
  JVCSRES_Server_reports_37d_modules_38_37d_revisions = 'Server reports %d modules & %d revisions';
  JVCSRES_37s_40w47o_hidden_modules41 = '%s (w/o hidden modules)';
  JVCSRES_6037s62_4037d4737d41 = '<%s> (%d/%d)';
  JVCSRES_is_not_a_member_of_the_version_archive46 = 'is not a member of the version archive.';
  JVCSRES_Do_you_wish_to_add_it_now63 = 'Do you wish to add it now?';
  JVCSRES__match_4037s41 = ' match (%s)';
  JVCSRES_37s_45_Bug_filter_406261_37s41 = '%s - Bug filter (>= %s)';
  JVCSRES_Currently_visible58_37d_modules = 'Currently visible: %d modules';
  JVCSRES_No_revisions_of_6037s62_in_the_archive46 = 'No revisions of <%s> in the archive.';
  JVCSRES_This_command_is_only_available_for_archived_files46 = 'This command is only available for archived files.';
  JVCSRES_This_module_is_already_a_member_of_the_current_project46 =
    'This module is already a member of the current project.';
  JVCSRES_Probably_you39ve_tried_to_add_one_of_his_file_family_members46 =
    'Probably you''ve tried to add one of his file family members.';
  JVCSRES__40Skip_such_files41 = ' (Skip such files)';
  JVCSRES_Already_a_member44_skipped58_37s = 'Already a member, skipped: %s';
  JVCSRES_38Don39t_show_this_message_again_in_the_current_queue46 =
    '&Don''t show this message again in the current queue.';
  JVCSRES_This_module_is_already_used_by_37d_other_projects58 =
    'This module is already used by %d other projects:';
  JVCSRES_Added_to_project58_37s_45_Success = 'Added to project: %s - Success';
  JVCSRES_Add_new_modules = 'Add new modules';
  JVCSRES_38Add_new_modules_by_folder58 = '&Add new modules by folder:';
  JVCSRES_38Remove_all_revisions_from_the_archive46 = '&Remove all revisions from the archive.';
  JVCSRES_37d_modules_selected46 = '%d modules selected.';
  JVCSRES_VC_project58_37s = 'VC project: %s';
  JVCSRES_Are_you_sure_you_want_to_remove_all_revisions_from_the_archive63 =
    'Are you sure you want to remove all revisions from the archive?';
  JVCSRES_This_module_is_already_used_by_other_projects_in_the_archive46 =
    'This module is already used by other projects in the archive.';
  JVCSRES_Shared_link_removed46 = 'Shared link removed.';
  JVCSRES_Removed_from_project58_37s_45_Success = 'Removed from project: %s - Success';
  JVCSRES_Are_you_sure_you_want_to_load_all_source_files_into_the_IDE63 =
    'Are you sure you want to load all source files into the IDE?';
  JVCSRES_This_may_consume_a_lot_of_system_resources_on_big_projects46 =
    'This may consume a lot of system resources on big projects.';
  JVCSRES_Load_module58_37s_45_Success = 'Load module: %s - Success';
  JVCSRES_Load_module58_37s_45_Failed = 'Load module: %s - Failed';
  JVCSRES_Are_you_sure_you_want_to_unload_all_source_files_40except_of_the_project41_from_the_IDE63 =
    'Are you sure you want to unload all source files (except of the project) from the IDE?';
  JVCSRES_Log_out_user_6037s62_and_terminate_program63 = 'Log out user <%s> and terminate program?';
  JVCSRES_38Synchronize47_Restore464646 = '&Synchronize/ Restore...';
  JVCSRES_Synchronize47_Restore = 'Synchronize/ Restore';
  JVCSRES_38Create_from_DB464646 = '&Create from DB...';
  JVCSRES_JEDI_Version_Control_System_45_IDE_Project_Manager_37s =
    'JEDI Version Control System - IDE Project Manager %s';
  JVCSRES_JEDI_Version_Control_System_45_Project_Manager_37s =
    'JEDI Version Control System - Project Manager %s';
  JVCSRES_Search_for_3437s34_45_Success = 'Search for "%s" - Success';
  JVCSRES_Search_for_3437s34_45_not_found = 'Search for "%s" - not found';
  JVCSRES_The_module_is_checked_out46 = 'The module is checked out.';
  JVCSRES_You_cannot_hide_modules_while_they_are_checked_out46 =
    'You cannot hide modules while they are checked out.';
  JVCSRES_Check_In58_module91s93_not_available_for_check_in =
    'Check In: module[s] not available for check in';
  JVCSRES_Check_In58_37d_module91s93_selected_45_Working464646 =
    'Check In: %d module[s] selected - Working...';
  JVCSRES_Check_In58_Not_all_modules_could_be_checked_in464646 =
    'Check In: Not all modules could be checked in...';
  JVCSRES_Check_In58_37s_45_Success = 'Check In: %s - Success';
  JVCSRES_Check_In58_Operation_canceled = 'Check In: Operation canceled';
  JVCSRES_Check_Out58_37d_module91s93_selected_45_Working464646 =
    'Check Out: %d module[s] selected - Working...';
  JVCSRES_Check_Out58_Not_all_modules_could_be_checked_out464646 =
    'Check Out: Not all modules could be checked out...';
  JVCSRES_Check_Out58_37s_45_Success = 'Check Out: %s - Success';
  JVCSRES_Check_Out58_Operation_canceled = 'Check Out: Operation canceled';
  JVCSRES_You_are_currently_not_the_owner_of_this_module46 =
    'You are currently not the owner of this module.';
  JVCSRES_Module_cannot_be_changed46 = 'Module cannot be changed.';
  JVCSRES_Change_labels58_37s_45_Success = 'Change labels: %s - Success';
  JVCSRES_Selection58_All_modules_45_37d_hits = 'Selection: All modules - %d hits';
  JVCSRES_Selection58_None = 'Selection: None';
  JVCSRES_Selection58_All_user_modules_45_37d_hits = 'Selection: All user modules - %d hits';
  JVCSRES_Selection58_All_checked_out_modules_45_37d_hits = 'Selection: All checked out modules - %d hits';
  JVCSRES_Selection58_All_checked_in_modules_45_37d_hits = 'Selection: All checked in modules - %d hits';
  JVCSRES_Selection58_All_checked_out_by_37s_45_37d_hits = 'Selection: All checked out by %s - %d hits';
  JVCSRES_Selection58_All_unregistered_modules_45_37d_hits = 'Selection: All unregistered modules - %d hits';
  JVCSRES_37d_KBytes_in_37d_temporary_file91s93_40QRPxx46tmp41_left_by_QRPreview =
    '%d KBytes in %d temporary file[s] (QRPxx.tmp) left by QRPreview';
  JVCSRES_Are_you_sure_you_want_to_cancel_your_work_on =
    'Are you sure you want to cancel your work on';
  JVCSRES_6037s62_and_unlock_the_module63 = '<%s> and unlock the module?';
  JVCSRES_This_module_is_locked_by_another_user46 = 'This module is locked by another user.';
  JVCSRES_Use_your_administrator_right_to_unlock_anyway63 =
    'Use your administrator right to unlock anyway?';
  JVCSRES_Warning33_All_changes_to_this_file_will_be_lost46 =
    'Warning! All changes to this file will be lost.';
  JVCSRES_Undo_Check_Out = 'Undo Check Out';
  JVCSRES_Undo_Checkout_success46_Module_unlocked46 = 'Undo Checkout success. Module unlocked.';
  JVCSRES_Restore_original_file_state_on_local_disk63 = 'Restore original file state on local disk?';
  JVCSRES_Undo_Checkout_complete46 = 'Undo Checkout complete.';
  JVCSRES_Selection58_Custom_45_37s_4037s41_45_37d_hits = 'Selection: Custom - %s (%s) - %d hits';
  JVCSRES_This_function_is_only_available_for_libraries_or_applications46 =
    'This function is only available for libraries or applications.';
  JVCSRES_Module_is_checked_out_by_you_and_cannot_be_added_at_this_time46 =
    'Module is checked out by you and cannot be added at this time.';
  JVCSRES_Module_added_to_custom_view_filter58_37s =
    'Module added to custom view filter: %s';
  JVCSRES_Parameters_changed46_Refresh_View63 = 'Parameters changed. Refresh View?';
  JVCSRES_Show_message_window = 'Show message window';
  JVCSRES_Show_own_ToDo45List = 'Show own ToDo-List';
  JVCSRES_Show_Bug45List = 'Show Bug-List';
  JVCSRES_Show_Module_History45List = 'Show Module History-List';
  JVCSRES_Show_own_Locked_Modules45List = 'Show own Locked Modules-List';
  JVCSRES_Hide_message_window = 'Hide message window';
  JVCSRES_Hide_own_ToDo45List = 'Hide own ToDo-List';
  JVCSRES_Hide_Bug45List = 'Hide Bug-List';
  JVCSRES_Hide_Module_History45List = 'Hide Module History-List';
  JVCSRES_Hide_own_Locked_Modules45List = 'Hide own Locked Modules-List';
  JVCSRES_Save_message_log = 'Save message log';
  JVCSRES_You_must_restart_the_IDE47_the_program_for_this_change_to_take_effect46 =
    'You must restart the IDE/ the program for this change to take effect.';
  JVCSRES_Sorry46 = 'Sorry.';
  JVCSRES_Log_file_access_error58_ = 'Log file access error: ';
  JVCSRES_Archive_space_45_all_projects = 'Archive space - all projects';
  JVCSRES_Revisions = 'Revisions';
  JVCSRES_Modules_91Bytes93 = 'Modules [Bytes]';
  JVCSRES_Zip_91Bytes93 = 'Zip [Bytes]';
  JVCSRES_Last_write_access = 'Last write access';
  JVCSRES_SUM58_37s_Revisions44_37s_4037s41_Bytes44_37d_3737 = 'SUM: %s Revisions, %s (%s) Bytes, %d %%';
  JVCSRES_count_space = 'count space';
  JVCSRES_Archive_space_45_37s = 'Archive space - %s';
  JVCSRES_C_Files = 'Files';
  JVCSRES_Files_91Bytes93 = 'Files [Bytes]';
  JVCSRES_SUM58_37s_Files44_37s_4037s41_Bytes44_37d_3737 = 'SUM: %s Files, %s (%s) Bytes, %d %%';
  JVCSRES_Move_modules = 'Move modules';
  JVCSRES_Project_tree = 'Project tree';
  JVCSRES_Server_request_timed_out46 = 'Server request timed out.';
  JVCSRES_Auto_refresh_timer_45_Server_reports_error58_37s = 'Auto refresh timer - Server reports error: %s';
  JVCSRES_Auto_refresh_timer_45_Server_exception58_37s = 'Auto refresh timer - Server exception: %s';
  JVCSRES_Deserted_Modules = 'Deserted Modules';
  JVCSRES_Modul_ID = 'Modul ID';
  JVCSRES_Path = 'Path';
  JVCSRES_You_do_not_have_a_double_click_action_defined46 =
    'You do not have a double click action defined.';
  JVCSRES_Deleted_Projects = 'Deleted Projects';
  JVCSRES_History = 'History';
  JVCSRES_Server_reports_an_already_known_project_name_6037s6246 =
    'Server reports an already known project name <%s>.';
  JVCSRES_Probably_there_is_a__formerly_deleted_project_with_the_same_name_in_the_version_archive46 =
    'Probably there is a  formerly deleted project with the same name in the version archive.';
  JVCSRES_Check_34Server124Deleted_Projects34_and_restore_the_project_or_select_a_different_name46 =
    'Check "Server|Deleted Projects" and restore the project or select a different name.';
  JVCSRES_Project_closed58_37s = 'Project closed: %s';
  JVCSRES_37d_selected_entries46 = '%d selected entries.';
  JVCSRES_37d_modules_locked_by_37s = '%d modules locked by %s';
  JVCSRES_All_Users47_37s = 'All Users/ %s';
  JVCSRES_37d_modules_locked_by_All_Users = '%d modules locked by All Users';
  JVCSRES_All_Users47_All_projects = 'All Users/ All projects';
  JVCSRES_WARNING33_This_is_a_high45risk_function_and_not_recommended_for_beginners33 =
    'WARNING! This is a high-risk function and not recommended for beginners!';
  JVCSRES_Inproper_use_of_direct_SQL_commands_may_cause_corrupted_archive_tables =
    'Inproper use of direct SQL commands may cause corrupted archive tables';
  JVCSRES_and47or_unreversible_loss_of_data33 = 'and/or unreversible loss of data!';
  JVCSRES_Do_NOT_use_this_function_until_you_are_really_sure_what_you_are_doing33 =
    'Do NOT use this function until you are really sure what you are doing!';
  JVCSRES_You_have_been_warned33_Continue_anyway63 = 'You have been warned! Continue anyway?';
  JVCSRES_You_cannot_change_the_module_extension46 = 'You cannot change the module extension.';
  JVCSRES_6037s62_Access_denied46 = '<%s> Access denied.';
  JVCSRES_You_cannot_change_the_name_of_a_locked_module46 = 'You cannot change the name of a locked module.';
  JVCSRES_Renamed58_37s_45_Success = 'Renamed: %s - Success';
  JVCSRES_Loading_Plug45in58_37s = 'Loading Plug-in: %s';
  JVCSRES_Plug45in_folder58_37s = 'Plug-in folder: %s';
  JVCSRES_Searching_for_available_Plug45ins464646 = 'Searching for available Plug-ins...';
  JVCSRES_Selection58_All_module_changes_not_yet_applied_to_the_archive_45_37d_hits =
    'Selection: All module changes not yet applied to the archive - %d hits';
  JVCSRES_Remember_that_the_filter_is_related_only_to_files_checked_out_by_you46 =
    'Remember that the filter is related only to files checked out by you.';
  JVCSRES_Hide_project_tree = 'Hide project tree';
  JVCSRES_Show_project_tree = 'Show project tree';
  JVCSRES_37s_60open62 = '%s <open>';
  JVCSRES_Adding_command58_37s = 'Adding command: %s';
  JVCSRES_Finished_loading_Plug45in58_37s = 'Finished loading Plug-in: %s';
  JVCSRES_Finished_loading_Plug45ins_40loaded58_37d41 = 'Finished loading Plug-ins (loaded: %d)';
  JVCSRES_Remove_Module_37d4737d_45_37s = 'Remove Module %d/%d - %s';
  JVCSRES_Line_History_37s = 'Line History %s';
  JVCSRES_VCS_Browser = 'VCS Browser';
  JVCSRES_Remove_branch_6037s6263 = 'Remove branch <%s>?';
  JVCSRES_Removing_the_branch_from_the_version_archive_will_remove_all_revisions_checked_in_in_this_branch46 =
    'Removing the branch from the version archive will remove all revisions checked in in this branch.';
  JVCSRES_Are_you_sure_you_want_to_do_this63 = 'Are you sure you want to do this?';
  JVCSRES_Branch_6037s62_successfully_removed46 = 'Branch <%s> successfully removed.';
  JVCSRES_Branch_6037s62_removal_failed46 = 'Branch <%s> removal failed.';

  //Syncronice.pas  
  JVCSRES_Do_you_want_to_abort_verifying_project_6037s62_63 =
    'Do you want to abort verifying project <%s>?';
  JVCSRES_6037s62_is_checked_out_by_you46 = '<%s> is checked out by you.';
  JVCSRES_Do_you_still_want_to_synchronize_this_file_63 =
    'Do you still want to synchronize this file?';
  JVCSRES_Unable_to_delete_6037s62_in_target_folder46 =
    'Unable to delete <%s> in target folder.';
  JVCSRES_Exception_37s_in_37s = 'Exception %s in %s';
  JVCSRES_6037s62_is_marked_as_hidden_and_exists_in_target_folder46 =
    '<%s> is marked as hidden and exists in target folder.';
  JVCSRES_Should_it_be_removed_in_target_folder_63 =
    'Should it be removed in target folder?';
  JVCSRES_Would_you_like_to_ignore_6037s62_in_this_revision_63 =
    'Would you like to ignore <%s> in this revision?';
  JVCSRES_This_module_will_be_ignored_in_the_syncronice_process_until_the_RevisionID44_the_hidden_state_or_the_path_changes_33 =
    'This module will be ignored in the syncronice process until the RevisionID, the hidden state or the path changes!';
  JVCSRES_C38reate = 'C&reate';
  JVCSRES_Create_via_version47date = 'Create via version/date';
  JVCSRES_Create_from_DB = 'Create from DB';
  JVCSRES_Root_4037s41 = 'Root (%s)';
  JVCSRES_VCS_Synchronize_Query_45_37s = 'VCS Synchronize Query - %s';
  JVCSRES_VCS_Create_from_DB = 'VCS Create from DB';
  JVCSRES_Scanning464646 = 'Scanning...';
  JVCSRES_Ready = 'Ready';
  JVCSRES_Server_reports_37d_revision_members = 'Server reports %d revision members';
  JVCSRES_VCS_Synchronize47_Restore_ = 'VCS Synchronize/ Restore ';
  JVCSRES_Compare464646 = 'Compare...';
  JVCSRES_Target_folder_cannot_be_blank46_Define_a_target_folder_and_retry46 =
    'Target folder cannot be blank. Define a target folder and retry.';
  JVCSRES_Origin_folders = 'Origin folders';
  JVCSRES_VCS_Synchronize_45_All_files_up_to_date = 'VCS Synchronize - All files up to date';
  JVCSRES_Verify_37s_to_6037s6258 = 'Verify %s to <%s>:';
  JVCSRES_37d_files_in_the_target_folder91s93_not_up_to_date46 =
    '%d files in the target folder[s] not up to date.';
  JVCSRES_newer_files = 'newer files';
  JVCSRES_VCS_Synchronize47_Restore_45_37d_files_not_up_to_date =
    'VCS Synchronize/ Restore - %d files not up to date';
  JVCSRES_Verify_different_files_to_6037s6258 = 'Verify different files to <%s>:';
  JVCSRES_37d_different_files46 = '%d different files.';
  JVCSRES_VCS_Synchronize47_Restore_45_37d_different_files =
    'VCS Synchronize/ Restore - %d different files';
  JVCSRES_All_files_up45to45date_or_unchanged46 = 'All files up-to-date or unchanged.';
  JVCSRES_VCS_Synchronize47_Restore_45_All_files_up45to45date_or_unchanged =
    'VCS Synchronize/ Restore - All files up-to-date or unchanged';
  JVCSRES_skipped_in_verify_process58 = 'skipped in verify process:';
  JVCSRES_37d_modules4037d_files41_are_checked_out_by_you46 =
    '%d modules(%d files) are checked out by you.';
  JVCSRES_37d_modules4037d_files41_were_ignored46 = '%d modules(%d files) were ignored.';
  JVCSRES_37d_files_assigned_to_project_6037s62 = '%d files assigned to project <%s>';
  JVCSRES_37d_files_assigned_to_selected_projects = '%d files assigned to selected projects';
  JVCSRES_Select_a_module_first46 = 'Select a module first.';
  JVCSRES_Are_you_sure_to_synchronize_the_working_directory_with_the_archive63 =
    'Are you sure to synchronize the working directory with the archive?';
  JVCSRES_This_may_overwrite_changes_in_your_working_directory46 =
    'This may overwrite changes in your working directory.';
  JVCSRES_Are_you_sure_to_synchronize_6037s62_with_the_archive63 =
    'Are you sure to synchronize <%s> with the archive?';
  JVCSRES_This_may_overwrite_files_on_your_local_disk46 =
    'This may overwrite files on your local disk.';
  JVCSRES_Are_you_sure_you_want_to_restore_37s_of_this_project_in =
    'Are you sure you want to restore %s of this project in';
  JVCSRES_This_may_overwrite_files_in_the_target_folders46 =
    'This may overwrite files in the target folders.';
  JVCSRES_version_37d4637d = 'version %d.%d';
  JVCSRES_your_working_directory = 'your working directory';
  JVCSRES_folder_6037s62 = 'folder <%s>';
  JVCSRES_the_labeled_version = 'the labeled version';
  JVCSRES_this_development_state = 'this development state';
  JVCSRES_40All_files_with_a_different_37s_will_be_overwritten_with_the_version_stored_in_the_archive4641 =
    '(All files with a different %s will be overwritten with the version stored in the archive.)';
  JVCSRES_checksum = 'checksum';
  JVCSRES_date = 'date';
  JVCSRES_Are_you_sure_you_want_to_create_a_new_working_directory_with_the_selected_modules63 =
    'Are you sure you want to create a new working directory with the selected modules?';
  JVCSRES_Working464646 = 'Working...';
  JVCSRES_removed = 'removed';
  JVCSRES_91Get_FileAttributes93 = '[Get FileAttributes]';
  JVCSRES_91Set_FileAttributes93 = '[Set FileAttributes]';
  JVCSRES_91Delete_File93 = '[Delete File]';
  JVCSRES_Synchronize = 'Synchronize';
  JVCSRES_Exception58_37s_in_37s46_ = 'Exception: %s in %s. ';
  JVCSRES_Synchronize_results = 'Synchronize results';
  JVCSRES_Base_module = 'Base module';
  JVCSRES_VCS_Synchronize47_Restore_45_37d_files_updated46 =
    'VCS Synchronize/ Restore - %d files updated.';
  JVCSRES_Synchronize_complete46_37d_files_updated46 =
    'Synchronize complete. %d files updated.';
  JVCSRES_38Sync = '&Sync';
  JVCSRES_Re38store = 'Re&store';
  JVCSRES_Rollb38ack = 'Rollb&ack';
  JVCSRES_37d_files_assigned_to_label_6037s62 = '%d files assigned to label <%s>';
  JVCSRES_37d_files_available_for_Rollback = '%d files available for Rollback';
  JVCSRES_You_cannot_search_for_negative_version47revision_numbers46 =
    'You cannot search for negative version/revision numbers.';
  JVCSRES_37d_modules_assigned_to_V_37d4637d = '%d modules assigned to V %d.%d';
  JVCSRES_This_change_will_not_take_effect_until_you_reopen_the_37s46 =
    'This change will not take effect until you reopen the %s.';
  JVCSRES_dialog = 'dialog';
  JVCSRES_All_unchecked_items_will_be_invisible_until_you_hit_the_34Refresh34_button46 =
    'All unchecked items will be invisible until you hit the "Refresh" button.';
  JVCSRES_Synchronize_to_latest_4037s41 = 'Synchronize to latest (%s)';
  JVCSRES_Restore_version_number_40V37d4637d41 = 'Restore version number (V%d.%d)';
  JVCSRES_Restore_labeled_version_4037s41 = 'Restore labeled version (%s)';
  JVCSRES_Rollback_4037s41 = 'Rollback (%s)';
  JVCSRES_Root_40 = 'Root (';
  JVCSRES_Search_38Files = 'Search &Files';
  JVCSRES_38Verify = '&Verify';
  JVCSRES_Cancel = 'Cancel';
  JVCSRES_Sync_process_ready46 = 'Sync process ready.';
  JVCSRES_Synched58_37d_files_in_37d_projects46 = 'Synched: %d files in %d projects.';
  JVCSRES_JEDI_VCS_will_synchronize_all_referenced_projects_in_the_list =
    'JEDI VCS will synchronize all referenced projects in the list';
  JVCSRES_without_further_prompting46_Once_started44_you_cannot_cancel_the_process46 =
    'without further prompting. Once started, you cannot cancel the process.';
  JVCSRES_Activate_34Sync_all_at_once3463 = 'Activate "Sync all at once"?';
  JVCSRES_AppSrvClient46Request_timed_Out_91GET95REVISION95STATUS93 =
    'AppSrvClient.Request timed Out [GET_REVISION_STATUS]';
  JVCSRES_AppSrvClient46Request_Error_91GET95REVISION95STATUS93 =
    'AppSrvClient.Request Error [GET_REVISION_STATUS]';
  JVCSRES_Could_not_set_attributes_of58_6037s62_Windowserrorcode58_37d_4037s41 =
    'Could not set attributes of: <%s> Windowserrorcode: %d (%s)';
  JVCSRES_Could_not_get_attributes_of_6037s62_4037s41 = 'Could not get attributes of <%s> (%s)';
  JVCSRES_Could_not_delete_6037s62_4037s41 = 'Could not delete <%s> (%s)';
  JVCSRES_Check_All = 'Check All';
  JVCSRES_Uncheck_All = 'Uncheck All';
  JVCSRES_Check_Branch = 'Check Branch';
  JVCSRES_Uncheck_Branch = 'Uncheck Branch';
  JVCSRES_Full_Expand = 'Full Expand';
  JVCSRES_Full_Collapse = 'Full Collapse';
  JVCSRES_Possible_circular_reference_bug46_Continue63 = 'Possible circular reference bug. Continue?';
  JVCSRES_Projectfile_6037s62_synchronized46 = 'Projectfile <%s> synchronized.';
  JVCSRES_Module_6037s62_was_synchronized_but_is_still_cached_by_Delphi = 'Module <%s> was synchronized but is still cached Read-Only by Delphi. You have to close and re-open your project to load the new version.';

  //AddNewFamily.pas
  JVCSRES_Child_extensions = 'Child extensions';

  //CrossRefList.pas
  JVCSRES_Select_project_group = 'Select project group';
  JVCSRES_Project_groups_404246bpg411244246bpg = 'Project groups (*.bpg)|*.bpg';
  JVCSRES_All_files_4042464241124424642 = 'All files (*.*)|*.*';
  JVCSRES_List_34Available_projects34_contains_no_entries_to_add46_ =
    'List "Available projects" contains no entries to add. ';

  //FileFamilies.pas
  JVCSRES_Enter_caption = 'Enter caption';
  JVCSRES_Edit_select_filter_extensions = 'Edit select filter extensions';
  JVCSRES_Max46_37d_entries_in_the_current_version46_Sorry46 =
    'Max. %d entries in the current version. Sorry.';
  JVCSRES_Are_you_sure_you_want_to_delete_all_items63 =
    'Are you sure you want to delete all items?';

  //MoveModules.pas
  JVCSRES_60enter_the_new_path62 = '<enter the new path>';
  JVCSRES_60part_to_exchange62 = '<part to exchange>';
  JVCSRES_60new_part62 = '<new part>';
  JVCSRES_This_is_a_37s46 = 'This is a %s.'; //example This is a checked out module.
  JVCSRES_Access_denied46 = 'Access denied.';
  JVCSRES_New_38module_path58 = 'New &module path:';
  JVCSRES_old_part47new_part = 'old part/new part';
  JVCSRES_Module_6037s62_not_found_in = 'Module <%s> not found in';
  JVCSRES_First_move_the_modules44_then_update_the_archive46 =
    'First move the modules, then update the archive.';
  JVCSRES_Are_you_sure_you_want_to_move_6037s62 = 'Are you sure you want to move <%s>';
  JVCSRES_to_6037s6263 = 'to <%s>?';

  // AssignLabels
  JVCSRES_Label_6037s62_is_already_assigned_to_V_37s4637s_of_this_module46 = 'Label <%s> is already assigned to V %s.%s of this module.';
  JVCSRES_Only_one_version_of_a_module_can_be_assigned_with_the_same_label46 = 'Only one version of a module can be assigned with the same label.';
  JVCSRES_Move_the_label_to_the_current_revision63 = 'Move the label to the current revision?';
  JVCSRES_38Don39t_show_this_message_again46 = '&Don''t show this message again.';
  JVCSRES_Are_you_sure_you_want_to_remove_label_6037s62 = 'Are you sure you want to remove label <%s>';
  JVCSRES_from_6037s6263 = 'from <%s>?';
  JVCSRES_MRU_item_6037s62_is_blank46 = 'MRU item <%s> is blank.';
  JVCSRES_Last_Label = 'Last Label';
  JVCSRES_Labels_assigned_to_37s = 'Labels assigned to %s';

  // About
  JVCSRES_Beta_37s = 'Beta %s';
  JVCSRES_This_is_a_beta_version_for_test_and_debug_purposes33 = 'This is a beta version for test and debug purposes!';
  JVCSRES_Do_NOT_publish_or_distribute_this_version33 = 'Do NOT publish or distribute this version!';
  JVCSRES_This_version_expires_after_37s33 = 'This version expires after %s!';
  JVCSRES_JEDI_VCS_Beta_Version = 'JEDI VCS Beta Version';
  JVCSRES_Installed_versions58 = 'Installed versions:';
  JVCSRES_Required_server47service_versions58 = 'Required server/service versions:';
    
  // AddNewFamily
  JVCSRES_The_value_you_have_entered_is_invalid46 = 'The value you have entered is invalid.';
  JVCSRES_Required58_One_leading_dot44_different_child_extensions_seperated_with_semicolons46 = 'Required: One leading dot, different child extensions seperated with semicolons.';
  JVCSRES_Wildcards_not_allowed46 = 'Wildcards not allowed.';
  JVCSRES_Select_the_dialog39s_help_button_for_more_information46 = 'Select the dialog''s help button for more information.';

  // AddNewUser
  JVCSRES_User_names_must_be_at_least_2_characters46 = 'User names must be at least 2 characters.';
  JVCSRES_Please_enter_a_valid_user_name46 = 'Please enter a valid user name.';
  JVCSRES_Passwords_must_be_at_least_5_characters46 = 'Passwords must be at least 5 characters.';
  JVCSRES_Please_re45enter_the_password46 = 'Please re-enter the password.';
  JVCSRES_Password_does_not_match_confirmation46 = 'Password does not match confirmation.';

  // AddShareModule
  JVCSRES_38Back_60 = '&Back <';
  JVCSRES_38Next_62 = '&Next >';
  JVCSRES_Share_a_module_45_146_Select_project = 'Share a module - 1. Select project';
  JVCSRES_Project = 'Project';
  JVCSRES_Share_a_module_45_246_Select_module = 'Share a module - 2. Select module';
  JVCSRES_Modules_in_37s = 'Modules in %s';

  // AssignBugs
  JVCSRES_Last_Bug = 'Last Bug';
  JVCSRES_Module_related_Bugs = 'Module related Bugs';
  JVCSRES_Project_related_Bugs = 'Project related Bugs';
  JVCSRES_Bugs_assigned_to_37s = 'Bugs assigned to %s';
  JVCSRES_Are_you_sure_you_want_to_remove_bug_6037s62 = 'Are you sure you want to remove bug <%s>';

  // AssignMilestones
  JVCSRES_6037s6246_This_value_cannot_be_blank46 = '<%s>. This value cannot be blank.';
  JVCSRES_Confirm_by = 'Confirm by';
  JVCSRES_38Milestone58_37s = '&Milestone: %s';
  JVCSRES_Project_has_reached_milestone58_ = 'Project has reached milestone: ';
  JVCSRES_Are_you_sure_to_remove_milestone_6037s6263 = 'Are you sure to remove milestone <%s>?';
  JVCSRES_Milestones_assigned_to_37s = 'Milestones assigned to %s';

  // Backup
  JVCSRES_UnzDLL46dll_Exception58_Cannot_access_zip_file_6037s62 = 'UnzDLL.dll Exception: Cannot access zip file <%s>';
  JVCSRES_Unable_to_add_backup_files_to_6037s6246 = 'Unable to add backup files to <%s>';
  JVCSRES_Perhaps_the_ZIP_is_corrupt46 = 'Perhaps the ZIP is corrupt.';
  JVCSRES_You_do_not_have_a_valid_backup_path_defined46 = 'You do not have a valid backup path defined.';
  JVCSRES_Would_you_like_to_do_this_now63 = 'Would you like to do this now?';
  JVCSRES_Unknown = 'Unknown';
  JVCSRES_Request_server_for_project_files464646 = 'Request server for project files...';
  JVCSRES_6037s62_This_project_is_not_registered_by_JEDI_VCS46 = '<%s> This project is not registered by JEDI VCS.';
  JVCSRES_You_must_add_the_project_to_the_version_archive_first46 = 'You must add the project to the version archive first.';
  JVCSRES_Warning33_Sequentiel_backup_runs_out_of_free_numbers46 = 'Warning! Sequential backup runs out of free numbers.';
  JVCSRES_You_have_more_than_900_recent_backupfiles_in_6037s62 = 'You have more than 900 recent backupfiles in <%s>';
  JVCSRES_Please_remove_some_older_ones46 = 'Please remove some older ones.';
  JVCSRES_Nothing_to_do46 = 'Nothing to do.';
  JVCSRES_Backup_complete46_37d_files_added47replaced46 = 'Backup complete. %d files added/replaced.';
  JVCSRES_JEDI_VCS_cannot_find_the_Zip_file58_6037s6246 = 'JEDI VCS cannot find the Zip file: <%s>.';
  JVCSRES_There_is_no_recent_backup_available_for_this_project_to_restore_files46 = 'There is no recent backup available for this project to restore files.';
  JVCSRES_JEDI_VCS_cannot_find_the_directory58_6037s6246 = 'JEDI VCS cannot find the directory: <%s>.';
  JVCSRES_Are_you_sure_you_want_to_restore_the_selected_files63 = 'Are you sure you want to restore the selected files?';
  JVCSRES_Warning33_Existing_files_will_be_overwritten_without_prompting46 = 'Warning! Existing files will be overwritten without prompting.';
  JVCSRES_37d_files_successfully_restored46 = '%d files successfully restored.';
  JVCSRES_Cannot_access_clipboard46 = 'Cannot access clipboard.';
  JVCSRES_VCS_Backup_45_37s_9137d_files93 = 'VCS Backup - %s [%d files]';
  JVCSRES_Scan_directories_for_changed_files464646 = 'Scan directories for changed files...';
  JVCSRES_37d_files_to_backup44_37d_old_archives44_37d_outdated_4562_37d_just_removed46 = '%d files to backup, %d old archives, %d outdated -> %d just removed.';
  JVCSRES_37d_files_changed_or_new_since_37s = '%d files changed or new since %s';
  JVCSRES_Enter_Password = 'Enter Password';
  JVCSRES_38Close = '&Close';
  JVCSRES_Preparing_Backup464646Please_wait = 'Preparing Backup...Please wait';
  JVCSRES_Target_file_name58_37s = 'Target file name: %s';
  JVCSRES_Mode58_Add_4038_Replace41 = 'Mode: Add (& Replace)';
  JVCSRES_AddCompLevel58_37d = 'AddCompLevel: %d';
  JVCSRES_Encryption58_37s = 'Encryption: %s';
  JVCSRES_On = 'On';
  JVCSRES_Off = 'Off';
  JVCSRES_Zip_size58_37s_Bytes = 'Zip size: %s Bytes';
  JVCSRES__day44_ = ' day, ';
  JVCSRES__days44_ = ' days, ';
  JVCSRES_Clean_up44_please_wait464646 = 'Clean up, please wait...';
  JVCSRES_Select_All = 'Select All';
  JVCSRES_Unselect_All = 'Unselect All';
  JVCSRES_VCS_Restore_45_37s = 'VCS Restore - %s';
  JVCSRES_All_unchecked_items_will_be_invisible_until_you_reopen_the_dialog46 = 'All unchecked items will be invisible until you reopen the dialog.';
  JVCSRES_Are_you_sure_you_want_to_remove_unchecked_items_from_the_list63 = 'Are you sure you want to remove unchecked items from the list?';

  // Branch
  JVCSRES_There_is_already_a_project_named_6037s62_in_the_archive46 = 'There is already a project named <%s> in the archive.';
  JVCSRES_You_cannot_have_different_projects_with_the_same_name_in_the_archive46 = 'You cannot have different projects with the same name in the archive.';
  JVCSRES_You_cannot_select_an_existing_project_name46_Select_a_new44_unused_name_and_retry46 = 'You cannot select an existing project name. Select a new, unused name and retry.';
  JVCSRES_Target_directory_must_be_empty46 = 'Target directory must be empty.';
  JVCSRES_Branch_target_project_file_name = 'Branch target project file name';
  JVCSRES_37s_projects_40424637s41124424637s = '%s projects (*.%s)|*.%s';
  JVCSRES_Create_branch_project_6037s62 = 'Create branch project <%s>';
  JVCSRES_in_6037s62_with_all_selected_modules63 = 'in <%s> with all selected modules?';
  JVCSRES_JEDI_VCS_is_unable_to_create_a_local_copy_of_this_file46 = 'JEDI VCS is unable to create a local copy of this file.';
  JVCSRES_Exception58_37s_in_37s46 = 'Exception: %s in %s.';
  JVCSRES_91CreateTargetDir93 = '[CreateTargetDir]';
  JVCSRES_91AppSrvClient46Request93 = '[AppSrvClient.Request]';
  JVCSRES_91GET95CHECKOUT95MODULE93 = '[GET_CHECKOUT_MODULE]';
  JVCSRES_91Get_compressed_size93 = '[Get compressed size]';
  JVCSRES_91TFileStream_access93 = '[TFileStream access]';
  JVCSRES_91Extract_zip_file93 = '[Extract zip file]';
  JVCSRES_91Set_original_timestamp93 = '[Set original timestamp]';
  JVCSRES_91Replace_local_copy93 = '[Replace local copy]';
  JVCSRES_91Unknown93 = '[Unknown]';
  JVCSRES_38Module58_37s = '&Module: %s';
  JVCSRES_Branch_result = 'Branch result';
  JVCSRES_Branch_module = 'Branch module';
  JVCSRES_Affected_files = 'Affected files';
  JVCSRES_Reading_file_6037s62 = 'Reading file <%s>';
  JVCSRES_raised_exception58_37s46 = 'raised exception: %s.';
  JVCSRES_JEDI_VCS_cannot_save_the_file_6037s6246 = 'JEDI VCS cannot save the file <%s>.';
  JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application44 = 'Be sure that the file is not opened by another application,';
  JVCSRES_that_there_is_enough_free_space_on_the_disk = 'that there is enough free space on the disk';
  JVCSRES_and_that_you_have_the_required_access_rights46 = 'and that you have the required access rights.';
  JVCSRES_Both_40share41 = 'Both (share)';
  JVCSRES_None_40skip41 = 'None (skip)';
  JVCSRES_38Project58_37s = '&Project: %s';
  JVCSRES_Project_successfully_created46_Project_ID58_37s = 'Project successfully created. Project ID: %s';
  JVCSRES_Projectname_is_already_in_use46 = 'Projectname is already in use.';
  JVCSRES_VCS_Branch_45_37s_45_Share58_37d_47Branch58_37d_47Skip58_37d = 'VCS Branch - %s - Share: %d /Branch: %d /Skip: %d';

  // BugWindow
  JVCSRES_Minor = 'Minor';
  JVCSRES_Awkward = 'Awkward';
  JVCSRES_Significant = 'Significant';
  JVCSRES_Serious = 'Serious';
  JVCSRES_Fatal = 'Fatal';

  // ChangeUserPW
  JVCSRES_User58_37s = 'User: %s';

  // CheckfBuild
  JVCSRES_Project_references_for_37s58 = 'Project references for %s:';
  JVCSRES_Check_for_Build58 = 'Check for Build:';
  JVCSRES_62_Checked_Out58 = '> Checked Out:';
  JVCSRES__by_ = ' by ';
  JVCSRES_62_Checked_Out58_37s_V37s4637s_by_37s = '> Checked Out: %s V%s.%s by %s';
  JVCSRES_37s_45_37d_warnings = '%s - %d warnings';
  JVCSRES_37s_45_project_ready = '%s - project ready';
  JVCSRES_Project58_37s_is_not_ready_for_Build = 'Project: %s is not ready for Build';
  JVCSRES_currently_in_work58_37d_modules = 'currently in work: %d modules';
  JVCSRES_by_yourself58_37d = 'by yourself: %d';
  JVCSRES_by_others__58_37d = 'by others  : %d';
  JVCSRES_Other_users_working_on_these_projects58 = 'Other users working on these projects:';
  JVCSRES_Project58_37s_is_ready_for_Build = 'Project: %s is ready for Build';
  JVCSRES_37s124User = '%s|User'; // no spaces!
  JVCSRES_37s124locked_by_37s = '%s|locked by %s';  // no spaces!
  JVCSRES_Source58_ = 'Source: ';
  JVCSRES_Please_finish_your_work_and_re45check_in_the_modules_locked_by_you46_Related_projects58_ = 'Please finish your work and re-check in the modules locked by you. Related projects: ';

  // ChkInSingle
  JVCSRES_Please_wait464646 = 'Please wait...';
  JVCSRES_4545_None_4545 = '-- None --';
  JVCSRES_Check_In_45_14737d = 'Check In - 1/%d';
  JVCSRES_VCS_Check_In_45_14737d = 'VCS Check In - 1/%d';
  JVCSRES_Searching464646Please_wait = 'Searching...Please wait';
  JVCSRES_Locked_ = 'Locked ';
  JVCSRES_Unlocked_ = 'Unlocked ';
  JVCSRES_by_37s_ = 'by %s ';
  JVCSRES_No_revisions_in_the_archive = 'No revisions in the archive';
  JVCSRES_JEDI_VCS_expects_the_local_file_to_be_37s44_but_the_file_is_37s46 = 'JEDI VCS expects the local file to be %s, but the file is %s.';
  JVCSRES_Continue_anyway63 = 'Continue anyway?';
  JVCSRES_Check_In = 'Check In';
  JVCSRES_writeable = 'writeable';
  JVCSRES_read45only = 'read-only';
  JVCSRES_Label_6037s62_is_already_assigned_to_V_37s46_37s_of_this_module46_ = 'Label <%s> is already assigned to V %s. %s of this module. ';
  JVCSRES_Module_6037s62_successfully_checked_in46 = 'Module <%s> successfully checked in.';
  JVCSRES_Module_6037s62_successfully_updated46 = 'Module <%s> successfully updated.';
  JVCSRES_Affected_files58_37s = 'Affected files: %s';
  JVCSRES_6037s62_not_added46 = '<%s> not added.';
  JVCSRES_No_path_information_available46 = 'No path information available.';
  JVCSRES_JEDI_VCS_cannot_add_or_checkin_the_module_without_path_information46 = 'JEDI VCS cannot add or checkin the module without path information.';
  JVCSRES_JEDI_VCS_cannot_find_the_file58 = 'JEDI VCS cannot find the file:';
  JVCSRES_Could_not_open_the_file_as_ShareExclusive46 = 'Could not open the file as ShareExclusive.';
  JVCSRES_Probably_the_file_is_locked_by_another_application46 = 'Probably the file is locked by another application.';
  JVCSRES_38Don3939t_show_this_message_again_in_the_current_queue = '&Don''t show this message again in the current queue';
  JVCSRES_Module_is_unchanged46_Nothing_to_do46 = 'Module is unchanged. Nothing to do.';
  JVCSRES_Module_is_checked_out_by_37s = 'Module is checked out by %s';
  JVCSRES_Module_is_unchanged_and_not_checked_out46 = 'Module is unchanged and not checked out.';
  JVCSRES_Module_is_unchanged46_Just_unlocked_the_latest_revision46 = 'Module is unchanged. Just unlocked the latest revision.';
  JVCSRES_40to58_All41_undo_check_out58_4037d4637d41_37s = '(to: All) undo check out: (%d.%d) %s';
  JVCSRES_undo_check_out58_4037d4637d41_37s = 'undo check out: (%d.%d) %s';
  JVCSRES_Scanning_file_for_keywords464646 = 'Scanning file for keywords...';
  JVCSRES_Calculating_CRC_checksum_for_6037s62 = 'Calculating CRC checksum for <%s>';
  JVCSRES_raised_exception58 = 'raised exception:';
  JVCSRES_Exception58_37s46 = 'Exception: %s.';
  JVCSRES_Access_denied_in_object_9137s9346 = 'Access denied in object [%s].';
  JVCSRES_Blowfisch_encode_failed = 'Blowfisch encode failed';
  JVCSRES_BLOB_transfer_into_request_stream_raised_exception58 = 'BLOB transfer into request stream raised exception:';
  JVCSRES_JEDI_VCS_cannot_check_in_this_file46 = 'JEDI VCS cannot check in this file.';
  JVCSRES_Last_Check_In_Comment = 'Last Check In Comment';
  JVCSRES_ToDo_list_contains_no_entries_for_this_project46 = 'ToDo list contains no entries for this project.';
  JVCSRES_New_module58_37s = 'New module: %s';
  JVCSRES_Check_In_45_37d4737d = 'Check In - %d/%d';
  JVCSRES_Missing_description_40check_in_memo4146 = 'Missing description (check in memo).';
  JVCSRES_Check_in_anyway63 = 'Check in anyway?';
  JVCSRES_Checked_in_from_37s_41 = 'Checked in from %s )';
  JVCSRES__45_33Encrypted33 = ' - !Encrypted!';
  JVCSRES_40to58_All41_checked_in58_4037d4637d41_37s = '(to: All) checked in: (%d.%d) %s';
  JVCSRES_40to58_All41_updated_40Put4158_4037d4637d41_37s = '(to: All) updated (Put): (%d.%d) %s';
  JVCSRES_checked_in58_4037d4637d41_37s = 'checked in: (%d.%d) %s';
  JVCSRES_updated_40Put4158_4037d4637d41_37s = 'updated (Put): (%d.%d) %s';
  JVCSRES_Adding_file_6037s62 = 'Adding file <%s>';
  JVCSRES_to_temporary_Zip_file6037s62 = 'to temporary Zip file<%s>';
  JVCSRES_File_6037s62 = 'File <%s>';
  JVCSRES_could_not_be_added_to_temporary_Zip_file = 'could not be added to temporary Zip file';
  JVCSRES_Select_ToDo_item = 'Select ToDo item';
  JVCSRES_38Put = '&Put';
  JVCSRES_Check_38In = 'Check &In';
  JVCSRES_Check_In_comment_cannot_be_empty = 'Check In comment cannot be empty';

  //ChkOutSingle
  JVCSRES_Check_Out_45_14737d = 'Check Out - 1/%d';
  JVCSRES_VCS_Check_Out_45_14737d = 'VCS Check Out - 1/%d';
  JVCSRES_Available_ = 'Available ';
  JVCSRES_Check_38Out = 'Check &Out';
  JVCSRES_38Skip = '&Skip';
  JVCSRES_Check_Out_45_37d4737d = 'Check Out - %d/%d';
  JVCSRES_Missing_description_40check_out_memo4146 = 'Missing description (check out memo).';
  JVCSRES_Check_out_anyway63 = 'Check out anyway?';
  JVCSRES_Check_Out = 'Check Out';
  JVCSRES_Request_check_in_from_the_current_module_owner63 = 'Request check in from the current module owner?';
  JVCSRES_40Checked_out_to_37s41 = '(Checked out to %s)';
  JVCSRES_123_37s_62_9137s93_checked_out_4737s125 = '{ %s > [%s] checked out /%s}';
  JVCSRES_Exception_in_Check_Out46_Step58_37d = 'Exception in Check Out. Step: %d';
  JVCSRES_Last_Check_Out_Comment = 'Last Check Out Comment';
  JVCSRES_Please_finish_your_work_and_re45check_in_module58_37s = 'Please finish your work and re-check in module: %s';
  JVCSRES_Projectfile_6037s62_checked_out46 = 'Projectfile <%s> checked out.';
  JVCSRES_You_have_to_close_and_reload_the_project_for_this_change_to_take_effect46 = 'You have to close and reload the project for this change to take effect.';
  JVCSRES_Don39t_overwrite_local_files = 'Don''t overwrite local files';
  JVCSRES_This_is_a_potentially_dangerous_option_and_only_recommended_for_rexperienced_users46 = 'This is a potentially dangerous option and only recommended for experienced users.';
  JVCSRES_Inproper_use_may_cause_data_loss33 = 'Inproper use may cause data loss!';
  JVCSRES_Enable_3437s34_anyway63 = 'Enable "%s" anyway?';
  JVCSRES_Module_6037s62_successfully_checked_out46 = 'Module <%s> successfully checked out.';
  JVCSRES_Module_6037s62_was_checked_out_but_is_still_cached_by_Delphi = 'Module <%s> was checked out but is still cached Read-Only by Delphi. You have to close and re-open your project to load the new version.';
  JVCSRES_Get_last_comment_4037s41 = 'Get last comment (%s)';
  JVCSRES_Get_comment_from_ToDo_list_4037s41 = 'Get comment from ToDo list (%s)';

  //jedivcs.dpr
  JVCSRES_Program_is_already_started33_Only_one_instance_allowed46 =
    'Program is already started! Only one instance allowed.';
  JVCSRES_There_are_still_running_instances_of_the_JEDI_VCS_or_FreeVCS_Client46 =
    'There are still running instances of the JEDI VCS or FreeVCS Client.';
  JVCSRES_It_is_not_possible_to_login_on_a_server_more_than_once_with_the_same_login_at_the_same_time46 =
    'It is not possible to login on a server more than once with the same login at the same time.';

  //Yes2allDlg.pas
  JVCSRES_38Don39t_ask_me_further_about_this_file46 =
    '&Don''t ask me further about this file.';

  //Whoami.pas
  JVCSRES_NA = 'NA';
  JVCSRES_40none41 = '(none)';
  JVCSRES_37d_min46 = '%d min.';
  JVCSRES_not_active46 = 'not active.';
  JVCSRES_37d_requests_transfered_37s_bytes_of_data_between_server_and_client46 =
    '%d requests transfered %s bytes of data between server and client.';
  JVCSRES_Log_in_time58_37s = 'Log in time: %s';
  JVCSRES_Log_started_at_37s46 = 'Log started at %s.';

  //WCViewFilter.pas
  JVCSRES_37s_source_files_4037s41 = '%s source files (%s)';
  JVCSRES_Other_source_files_4037s41 = 'Other source files (%s)';

  //VCSProcBase.pas
  JVCSRES_60On62 = '<On>';
  JVCSRES_60Off62 = '<Off>';
  JVCSRES_This_option_is_forced_to_be_37s_on_the_current_application_server46 =
    'This option is forced to be %s on the current application server.';
  JVCSRES_Your_changes_will_not_take_effect_as_long_as_you_are_connected_to_this_server46 =
    'Your changes will not take effect as long as you are connected to this server.';
  JVCSRES_Contact_your_archive_administrator_for_details46 =
    'Contact your archive administrator for details.';
  JVCSRES_37d_d44_37d_h44_37d_m46 = '%d d, %d h, %d m.';
  JVCSRES_37s_compiler_options = '%s compiler options';
  JVCSRES_37s_desktop_file = '%s desktop file';
  JVCSRES_Resource_file = 'Resource file';
  JVCSRES_Resource_script = 'Resource script';
  JVCSRES_Include_file = 'Include file';
  JVCSRES_FVCS_data_file = 'FVCS data file';
  JVCSRES_JVCS_data_file = 'JVCS data file';
  JVCSRES_JVCS_backup_file = 'JVCS backup file';
  JVCSRES_37s45File = '%s-File';
  JVCSRES_Request_timed_out46 = 'Request timed out.';
  JVCSRES_The_server_didn39t_answer_within_the_timeout_delay_4037d_sec4146 =
    'The server didn''t answer within the timeout delay (%d sec).';
  JVCSRES_Probably_the_server_connection_is_broken_or_too_slow =
    'Probably the server connection is broken or too slow';
  JVCSRES_or_you_need_to_increase_the_timeout_value46_40Properties_dialog41 =
    'or you need to increase the timeout value. (Properties dialog)';
  JVCSRES_Access_denied46_4037s41 = 'Access denied. (%s)';
  JVCSRES_unknown_or_expired_user_account = 'unknown or expired user account';
  JVCSRES_Probably_the_server_has_you_logged_out_due_to_an_idle_timer_overflow46 =
    'Probably the server has you logged out due to an idle timer overflow.';
  JVCSRES_Select_34JEDI_VCS124Connect_Server34_and_try_to_re45connect46 =
    'Select "JEDI VCS|Connect Server" and try to re-connect.';
  JVCSRES_Select_34Server124Disconnect_Server34_and_try_to_re45connect46 =
    'Select "Server|Disconnect Server" and try to re-connect.';
  JVCSRES_Server_exception_4037s41_in_object_37s = 'Server exception (%s) in object %s';
  JVCSRES_No_such_object_available46 = 'No such object available.';
  JVCSRES_JEDI_VCS_Application_Server = 'JEDI VCS Application Server';
  JVCSRES_38Don39t_show_this_message_again = '&Don''t show this message again';
  JVCSRES_Ctrl43_shortcuts_for_graphic_buttons_are_disabled46 =
    'Ctrl+ shortcuts for graphic buttons are disabled.';
  JVCSRES_You_may_re45enable_them_by_Options124Properties124Shortcut_Keys46 =
    'You may re-enable them by Options|Properties|Shortcut Keys.';
  JVCSRES_Default_User = 'Default User';
  JVCSRES_Project_names_cannot_be_blank46 = 'Project names cannot be blank.';
  JVCSRES_Project_names_cannot_be_one_of_the_following58 =
    'Project names cannot be one of the following:';
  JVCSRES_Project_names_cannot_contain_any_of_the_following_characters58 =
    'Project names cannot contain any of the following characters:';
  JVCSRES_37s44_or_the_tab_character46 = '%s, or the tab character.';
  JVCSRES_Module_names_cannot_be_blank46 = 'Module names cannot be blank.';
  JVCSRES_File_extensions_can_be_up_to_20_characters_max46 =
    'File extensions can be up to 20 characters max.';
  JVCSRES_Module_names_cannot_be_one_of_the_following58 =
    'Module names cannot be one of the following:';
  JVCSRES_Module_names_cannot_contain_any_of_the_following_characters58 =
    'Module names cannot contain any of the following characters:';
  JVCSRES_Error_37d_in_95CopyFile4041 = 'Error %d in _CopyFile()';
  JVCSRES_Error = 'Error';
  JVCSRES_Unable_to_determine_IDE_version = 'Unable to determine IDE version';
  JVCSRES_Standalone_version_9137s93 = 'Standalone version [%s]';
  JVCSRES_Wrong_product_version_resource_40needs_format_n46n46n9146n9333 =
    'Wrong product version resource (needs format n.n.n[.n]!';

  //Touch.pas
  JVCSRES_37d_files_changed_to_37s46 = '%d files changed to %s.';
  JVCSRES_37d_files_not_changed58_Access_denied46 = '%d files not changed: Access denied.';
  JVCSRES_38Target_folder58 = '&Target folder:';

  //ToDoFilter.pas
  JVCSRES_All_categories = 'All categories';
  JVCSRES_You_have_selected_option_6037s6246 = 'You have selected option <%s>.';
  JVCSRES_The_coresponding_value_cannot_be_blank46 = 'The coresponding value cannot be blank.';
  JVCSRES_User = 'User';

  //ToDoEdit.pas
  JVCSRES_Add_ToDo_item = 'Add ToDo item';
  JVCSRES_Edit_ToDo_item = 'Edit ToDo item';
  JVCSRES_ToDo_text = 'ToDo text';
  JVCSRES_Are_you_sure_you_want_to_remove_all_categories_from_the_history_list63 =
    'Are you sure you want to remove all categories from the history list?';
  JVCSRES_40This_will_not_affect_already_created_ToDo_items41 =
    '(This will not affect already created ToDo items)';
  JVCSRES_Warning33_This_process_is_not_reversible46 =
    'Warning! This process is not reversible.';

  //ToDo.pas
  JVCSRES_VCS_ToDo_45_37d_items = 'VCS ToDo - %d items';
  JVCSRES_There_were_no_records_located_that_match_your_search_criteria46 =
    'There were no records located that match your search criteria.';
  JVCSRES_Re45check_your_criterias_and_retry46 = 'Re-check your criterias and retry.';
  JVCSRES_Are_you_sure_you_want_to_delete_the_selected_items63 =
    'Are you sure you want to delete the selected items?';
  JVCSRES_Are_you_sure_you_want_to_delete_all_done_items63 =
    'Are you sure you want to delete all done items?';
  JVCSRES_You_have_made_changes_that_have_not_been_applied46 =
    'You have made changes that have not been applied.';
  JVCSRES_Do_you_want_to_apply_these_now63 = 'Do you want to apply these now?';
  JVCSRES_This_feature_is_currently_not_supported_by_the_C4343_Builder_version46_Sorry46 =
    'This feature is currently not supported by the C++ Builder version. Sorry.';
  JVCSRES_Parsing_the_source_files464646 = 'Parsing the source files...';
  JVCSRES_Building_Listview464646 = 'Building Listview...';
  JVCSRES_Source_scan = 'Source scan';
  JVCSRES_JEDI_VCS_cannot_save_the_file = 'JEDI VCS cannot save the file';
  JVCSRES_JEDI_VCS_cannot_open_the_file46_40Invalid_path_or_access_denied4158 =
    'JEDI VCS cannot open the file. (Invalid path or access denied):';
  JVCSRES_Make_sure_that_the_file_exists44_that_it_is_not_opened_by_another_application =
    'Make sure that the file exists, that it is not opened by another application';
  JVCSRES_JEDI_VCS_cannot_detect_the_name_of_Delphi39s_base_installation_folder46 =
    'JEDI VCS cannot detect or does not know your IDE product (Delphi/BCB).';
  JVCSRES_This_function_is_only_supported_for_known_IDE_products46 =
  'This function is only supported for known IDE products.';
//###  JVCSRES_You_must_define_the_folder_manually_in_34Properties124Folders3446 =
//###    'You must define the folder manually in "Properties|Folders".';
  JVCSRES_Source_code_template_34jvcstodo_124_JEDI_VCS_Todo_Code_Comment34_successfully_added46
    = 'Source code template "jvcstodo | JEDI VCS Todo Code Comment" successfully added.';
  JVCSRES_Hit_60Ctrl43J62_to_insert_the_template_into_your_source_files46 =
    'Hit <Ctrl+J> to insert the template into your source files.';
  JVCSRES_Requested_result_set_is_blank46_Nothing_to_do46 =
    'Requested result set is blank. Nothing to do.';
  JVCSRES_37d_entries46 = '%d entries.';
  JVCSRES_JEDI_VCS_ = 'JEDI VCS ';
  JVCSRES_Select_D5_ToDo_file = 'Select D5 ToDo file';
  JVCSRES_D5_ToDo_files_404246todo411244246todo124All_files_4042464241124424642 =
    'D5 ToDo files (*.todo)|*.todo|All files (*.*)|*.*';
  JVCSRES_Select_the_related_project = 'Select the related project';
  JVCSRES_VCS_ToDo_45_request_server_for_filter_items464646 =
    'VCS ToDo - request server for filter items...';
  JVCSRES_VCS_ToDo = 'VCS ToDo';

  //TextComp.pas
  JVCSRES_Visual_compare_is_only_available_for_text_files46 =
    'Visual compare is only available for text files.';
  JVCSRES_Known_text_files58_4037s41 = 'Known text files: (%s)';
  JVCSRES_No_CRC32_checksum_stored_for_this_module46 =
    'No CRC32 checksum stored for this module.';
  JVCSRES_Probably_the_module_was_checked_in_with_a_version_60_1462460 =
    'Probably the module was checked in with a version < 1.2.0';
  JVCSRES_Binary_compare58_6037s6246 = 'Binary compare: <%s>.';
  JVCSRES_Archive58_3637s = 'Archive: $%s';
  JVCSRES_File58________3637s = 'File:        $%s';
  JVCSRES_The_modules_are_37s46 = 'The modules are %s.';
  JVCSRES_equal = 'equal';
  JVCSRES_Binary_compare58_37s_45_equal = 'Binary compare: %s - equal';
  JVCSRES_not_equal = 'not equal';
  JVCSRES_Binary_compare58_37s_45_not_equal = 'Binary compare: %s - not equal';
  JVCSRES_JEDI_VCS_cannot_find_the_source_file58 = 'JEDI VCS cannot find the source file:';
  JVCSRES_Unable_to_Binary_compare46 = 'Unable to Binary compare.';
  JVCSRES_JEDI_VCS_cannot_find_this_file_on_the_local_disk46_ =
    'JEDI VCS cannot find this file on the local disk. ';
  JVCSRES_JEDI_VCS_cannot_compare_the_selected_versions46 =
    'JEDI VCS cannot compare the selected versions.';
  JVCSRES_ShellExecute_Error_6037s62 = 'ShellExecute Error <%s>';
  JVCSRES_Invalid_parameter_string_for_external_compare_utility33 =
    'Invalid parameter string for external compare utility!';
  JVCSRES_Visual_Compare_45_37s = 'Visual Compare - %s';
  JVCSRES_JEDI_VCS_cannot_delete_the_file = 'JEDI VCS cannot delete the file';
  JVCSRES_Be_sure_that_the_file_is_not_opened_by_another_application =
    'Be sure that the file is not opened by another application';
  JVCSRES_No_file_object_returned_by_server46 = 'No file object returned by server.';
  JVCSRES_TFileStream_Error40form4158_37s = 'TFileStream Error(form): %s';
  JVCSRES_Error_extract40form4158_37s = 'Error extract(form): %s';
  JVCSRES_FileSetDate_Error40form4158_37s = 'FileSetDate Error(form): %s';
  JVCSRES_JEDI_VCS_cannot_convert_the_form_4046dfm41_file58 =
    'JEDI VCS cannot convert the form (.dfm) file:';
  JVCSRES_No_Blob_returned_by_server46 = 'No Blob returned by server.';
  JVCSRES_TFileStream_Error40module4158_37s = 'TFileStream Error(module): %s';
  JVCSRES_Error_extract40module4158_37s = 'Error extract(module): %s';
  JVCSRES_FileSetDate_Error40module4158_37s = 'FileSetDate Error(module): %s';
  JVCSRES_38Local = '&Local';
  JVCSRES_38Archive = '&Archive';
  JVCSRES_Archive_381 = 'Archive &1';
  JVCSRES_Archive_382 = 'Archive &2';
  JVCSRES_JEDI_VCS_Diff = 'JEDI VCS Diff';

  //Std_ListView.pas
  JVCSRES_You_must_refresh_40F541_the_project_manager_view_to_see_the_changes46 =
    'You must refresh (F5) the project manager view to see the changes.';
  JVCSRES_Are_you_sure_you_want_to_remove_6037s62_4037s41_from_the_archive63 =
    'Are you sure you want to remove <%s> (%s) from the archive?';
  JVCSRES_all_versions = 'all versions';
  JVCSRES_Restore_project_6037s6263 = 'Restore project <%s>?';
  JVCSRES_Remember_that_JEDI_VCS_cannot_restore_the_links_between_this_project =
    'Remember that JEDI VCS cannot restore the links between this project';
  JVCSRES_and_the_modules_recently_used_by_them46 = 'and the modules recently used by them.';
  JVCSRES_38Copy_selected_modules_to = '&Copy selected modules to';
  JVCSRES_37d_selected_projects47modules = '%d selected projects/modules';
  JVCSRES_Shared_by_project__ = 'Shared by project  ';
  JVCSRES_Project_ID = 'Project ID';
  JVCSRES_Are_you_sure_you_want_to_move_the_selected_backup_files =
    'Are you sure you want to move the selected backup files';
  JVCSRES_to_the_recycle_bin63 = 'to the recycle bin?';
  JVCSRES_Are_you_sure_you_want_to_delete_the_selected_backup_files63 =
    'Are you sure you want to delete the selected backup files?';

  //SimpleReport.pas
  JVCSRES_Pr38int_report_4012637d_lines41 = 'Pr&int report (~%d lines)';
  JVCSRES_Preview = 'Preview';
  JVCSRES_Save_report_to_file = 'Save report to file';
  JVCSRES_Text_files_404246txt411244246txt124All_files_4042464241124424642 =
    'Text files (*.txt)|*.txt|All files (*.*)|*.*';
  JVCSRES_Parsing_the_ListView_content_raised_exception58 =
    'Parsing the ListView content raised exception:';
  JVCSRES_Save_report_to_CSV_file = 'Save report to CSV file';
  JVCSRES_Comma_sep_values_404246csv411244246csv124Text_files_404246txt411244246txt124All_files_4042464241124424642 =
    'Comma sep values (*.csv)|*.csv|Text files (*.txt)|*.txt|All files (*.*)|*.*';
  JVCSRES_JEDI_VCS_cannot_find_the_Windows_standard_printer46 =
    'JEDI VCS cannot find the Windows standard printer.';
  JVCSRES_Define_a_Windows_standard_printer_and_retry46 =
    'Define a Windows standard printer and retry.';
  JVCSRES_JEDI_VCS_Report = 'JEDI VCS Report';
  JVCSRES_Save_report_to_HTML_file = 'Save report to HTML file';
  JVCSRES_HTML_files_404246htm594246html411244246htm594246html124All_files_4042464241124424642 =
    'HTML files (*.htm;*.html)|*.htm;*.html|All files (*.*)|*.*';
  JVCSRES_JEDI_VCS = 'JEDI VCS';
  JVCSRES_JEDI_VCS_HTML_Report = 'JEDI VCS HTML Report';
  JVCSRES_Save_report_to_RTF_file = 'Save report to RTF file';
  JVCSRES_RTF_files_404246rtf411244246rtf124All_files_4042464241124424642 =
    'RTF files (*.rtf)|*.rtf|All files (*.*)|*.*';

  //ShowTimeLog.pas
  JVCSRES_VCS_Time_Log_45_37s = 'VCS Time Log - %s';
  JVCSRES_Convert_Error = 'Convert Error';
  JVCSRES_37d_h_37s_min = '%d h %s min';
  JVCSRES_VCS_Time_Log_45_37s_45_37d_entries = 'VCS Time Log - %s - %d entries';
  JVCSRES_All_users = 'All users';
  JVCSRES_File_6037s62_not_found46 = 'File <%s> not found.';
  JVCSRES_40This_is_normal_behavior_if_you_open_this_window_for_the_first_time4146 =
    '(This is normal behavior if you open this window for the first time).';
  JVCSRES_Are_you_sure_you_want_to_clear_the_time_log63 =
    'Are you sure you want to clear the time log?';
  JVCSRES_Filter58_37s = 'Filter: %s';
  JVCSRES_Project_6037s62_on_9137s9346 = 'Project <%s> on [%s].';
  JVCSRES_Period_of_time58_37s_45_37s_4037d_days4146 = 'Period of time: %s - %s (%d days).';
  JVCSRES_User58_37s46 = 'User: %s.';
  JVCSRES_Users58_37d46 = 'Users: %d.';
  JVCSRES_Project_time58_37d_d44_37s46 = 'Project time: %d d, %s.';
  JVCSRES_Average58_37s_h47d46 = 'Average: %s h/d.';
  JVCSRES_Working_days_408h47d4158_37s_d46_4037s_weeks4737s_years4146 =
    'Working days (8h/d): %s d. (%s weeks/%s years).';
  JVCSRES_Calculate = 'Calculate';
  JVCSRES_Enter_cost47hour58 = 'Enter cost/hour:';
  JVCSRES_Float_62_0_expected46 = 'Float > 0 expected.';
  JVCSRES_Base_37f47h = 'Base %f/h';

  //ServerOptions.pas
  JVCSRES_37d47h = '%d/h';
  JVCSRES_Backup_path = 'Backup path';
  JVCSRES_Start_version_archive_live_backup_now63 = 'Start version archive live backup now?';
  JVCSRES_Server_may_be_blocked_for_some_time46 = 'Server may be blocked for some time.';
  JVCSRES_Live_backup_result = 'Live backup result';
  JVCSRES_Version_archive_table = 'Version archive table';
  JVCSRES_Size_91Bytes93 = 'Size [Bytes]';
  JVCSRES_SUM58_37s_KB = 'SUM: %s KB';
  JVCSRES_Server_error58_File_not_found46 = 'Server error: File not found.';
  JVCSRES_JEDI_VCS_cannot_detect_the_name_of_the_local_temporary_directory46 =
    'JEDI VCS cannot detect the name of the local temporary directory.';
  JVCSRES_Try_to_define_a_temporary_directory_in_34Properties124Folders34_and_retry46 =
    'Try to define a temporary directory in "Properties|Folders" and retry.';
  JVCSRES_There_is_already_a_file_6037s62_in_6037s6246 =
    'There is already a file <%s> in <%s>.';
  JVCSRES_Delete_the_file_to_show_the_latest_version_of_6037s6263 =
    'Delete the file to show the latest version of <%s>?';
  JVCSRES_TFileStream_Error_4037s4158_37s = 'TFileStream Error (%s): %s';
  JVCSRES_Are_you_sure_you_want_to_clear_the_server_log_file63 =
    'Are you sure you want to clear the server log file?';
  JVCSRES_Remember_that_this_will_clear_the_original_file =
    'Remember that this will clear the original file';
  JVCSRES_on_the_application_servers_machine46 = 'on the application servers machine.';
  JVCSRES_0k = '0k';
  JVCSRES_Bytes_received = 'Bytes received';
  JVCSRES_Bytes_transmitted = 'Bytes transmitted';
  JVCSRES_Modules_40get41 = 'Modules (get)';
  JVCSRES_Modules_40new41 = 'Modules (new)';
  JVCSRES_Modules_40checked_out41 = 'Modules (checked out)';
  JVCSRES_Modules_40checked_in41 = 'Modules (checked in)';
  JVCSRES_Requests = 'Requests';
  JVCSRES_Requests_40Avg41 = 'Requests (Avg)';
  JVCSRES_Server_uptime = 'Server uptime';
  JVCSRES_Space_40available41 = 'Space (available)';
  JVCSRES_Space_40total41 = 'Space (total)';
  JVCSRES_Users_40Sum41 = 'Users (Sum)';
  JVCSRES_Server_Statistics = 'Server Statistics';
  JVCSRES_Item = 'Item';
  JVCSRES_Value = 'Value';
  JVCSRES_Archive58_37s = 'Archive: %s';
  JVCSRES_Information_not_available46 = 'Information not available.';
  JVCSRES_40Probably_you_don39t_have_the_required_right41 =
    '(Probably you don''t have the required right)';

  //SelectProjectID.pas
  JVCSRES_Hierarchy = 'Hierarchy';
  JVCSRES_38Done = '&Done';
  JVCSRES_38Import_37s_Project_Group464646 = '&Import %s Project Group...';
  JVCSRES_Project_Hierarchy = 'Project Hierarchy';
  JVCSRES_Select_a_Project_4037s41 = 'Select a Project (%s)';
  JVCSRES_Project_6037s62_is_not_enabled_for_your_account46 =
    'Project <%s> is not enabled for your account.';
  JVCSRES_Please_contact_the_archive_administrator_for_more_information46 =
    'Please contact the archive administrator for more information.';
  JVCSRES_Project_group_3437s34 = 'Project group "%s"';
  JVCSRES_JEDI_VCS_cannot_find_the_MRU_item_6037s62_in_the_list46 =
    'JEDI VCS cannot find the MRU item <%s> in the list.';
  JVCSRES_Last_Project = 'Last Project';
  JVCSRES_Created58_37s_by_37s_45_Last_write_access58_37s_by_37s =
    'Created: %s by %s - Last write access: %s by %s';
  JVCSRES_Add_new_Group = 'Add new Group';
  JVCSRES_Parent = 'Parent';
  JVCSRES_Root = 'Root';
  JVCSRES_60Unassigned_Projects62 = '<Unassigned Projects>';
  JVCSRES_60Unassigned62_is_an_auto_generated_group_and_not_part_of_the_archive46 =
    '<Unassigned> is an auto generated group and not part of the archive.';
  JVCSRES_You_cannot_edit44_rename_or_remove_this_group46 =
    'You cannot edit, rename or remove this group.';
  JVCSRES_Please_refer_to_the_online_help_file46 = 'Please refer to the online help file.';
  JVCSRES_Add_new_Sub_Group = 'Add new Sub Group';
  JVCSRES_Rename_Group = 'Rename Group';
  JVCSRES_Current = 'Current';
  JVCSRES_Are_you_sure_you_want_to_remove_group_6037s62 =
    'Are you sure you want to remove group <%s>';
  JVCSRES_with_all_sub_groups_and_assigned_projects63 =
    'with all sub groups and assigned projects?';
  JVCSRES_Add_to_3437s34 = 'Add to "%s"';
  JVCSRES_Auto_generated_group46_This_group_lists_all_projects_not_assigned_to_any_user_defined_group46_Not_editable33 =
    'Auto generated group. This group lists all projects not assigned to any user defined group. Not editable!';
  JVCSRES_Project_groups_404246bpg411244246bpg124All_files_4042464241124424642 =
    'Project groups (*.bpg)|*.bpg|All files (*.*)|*.*';
  JVCSRES_Select_parent_for_3437s34 = 'Select parent for "%s"';
  JVCSRES_45_Root_45 = '- Root -';
  JVCSRES_37s_project_group = '%s project group';
  JVCSRES_37s_saved_to_file = '%s saved to file';
  JVCSRES_Project_list = 'Project list';

  //SelectFolder.pas
  JVCSRES_New_Folder = 'New Folder';
  JVCSRES_Create_new_folder = 'Create new folder';
  JVCSRES_Root58_37s = 'Root: %s';
  JVCSRES_JEDI_VCS_cannot_create_the_directory = 'JEDI VCS cannot create the directory';
  JVCSRES_Perhaps_there_is_already_a_folder_with_this_name_or_you =
    'Perhaps there is already a folder with this name or you';
  JVCSRES_do_not_have_the_requested_rights_for_this46 =
    'do not have the requested rights for this.';
  JVCSRES_91recursive93 = '[recursive]';
  JVCSRES_Searching_in_6037s62_37s = 'Searching in <%s> %s';
  JVCSRES_Project_folders = 'Project folders';
  JVCSRES_Your_search_criteria_6037s62_will_include_37d_files46 =
    'Your search criteria <%s> will include %d files.';
  JVCSRES_Are_you_sure_you_want_to_add_all_files_at_once63 =
    'Are you sure you want to add all files at once?';
  JVCSRES_Remember_that_this_may_take_some_time_and_cannot_be_canceld33 =
    'Remember that this may take some time and cannot be canceled!';
  JVCSRES_There_were_no_37s_located_that_match_the_search_criteria46 =
    'There were no %s located that match the search criteria.';
  JVCSRES_files = 'files';
  JVCSRES_Your_search_matches_more_than_500_files46 = 'Your search matches more than 500 files.';
  JVCSRES_No_network_is_present46 = 'No network is present.';
  JVCSRES_A_network45specific_error_occurred46 = 'A network-specific error occurred.';
  JVCSRES_The_specified_password_is_invalid46 = 'The specified password is invalid.';
  JVCSRES_There_is_insufficient_memory_to_start_the_dialog_box46 =
    'There is insufficient memory to start the dialog box.';
  JVCSRES_All_files_4042464241 = 'All files (*.*)';
  JVCSRES_Add_by_folder_45_exclude_files = 'Add by folder - exclude files';
  JVCSRES_There_are_currently_no_known_project_folders_for_6037s6246 =
    'There are currently no known project folders for <%s>.';
  JVCSRES_Probably_the_project_is_still_empty46 = 'Probably the project is still empty.';

  //UsedUnits.pas
  JVCSRES_Used_modules_45_37s_45_37d_modules_40filtered41 =
    'Used modules - %s - %d modules (filtered)';
  JVCSRES_Used_modules_45_37s_45_37d_modules = 'Used modules - %s - %d modules';
  JVCSRES_Search_Paths = 'Search Paths';
  JVCSRES_Used_modules_45_37s = 'Used modules - %s';
  JVCSRES_Not_found = 'Not found';

  //UsedComponents.pas
  JVCSRES_Used_Components_45_37s_45_parsing_project_modules =
    'Used Components - %s - parsing project modules';
  JVCSRES_Used_Components_45_37s_45_37d_comps_40filtered41 =
    'Used Components - %s - %d comps (filtered)';
  JVCSRES_Used_Components_45_37s_45_37d_comps = 'Used Components - %s - %d comps';

  //UnitFilter.pas
  JVCSRES_Component_Filter = 'Component Filter';
  JVCSRES_Ignore_these_Components58 = 'Ignore these Components:';
  JVCSRES_Module_Filter = 'Module Filter';
  JVCSRES_Ignore_these_modules58 = 'Ignore these modules:';

  //SearchModules.pas
  JVCSRES_Mask_string = 'Mask string';
  JVCSRES_Search_Modules_45_searching464646 = 'Search Modules - searching...';
  JVCSRES_Search_Modules_45_37d_hits = 'Search Modules - %d hits';
  JVCSRES_37d_modules_matches_3437s34 = '%d modules matches "%s"';

  //RenameProj.pas
  JVCSRES_Rename_project_6037s62 = 'Rename project <%s>';
  JVCSRES_See_help_topic_34Naming_conventions34_for_more_information46 =
    'See help topic "Naming conventions" for more information.';
  JVCSRES_The_new_project_name_must_have_the_same_file_extension_as_the_old_one46 =
    'The new project name must have the same file extension as the old one.';
  JVCSRES_37s_and_all_selected_modules63 = '%s and all selected modules?';
  JVCSRES_Project_successfully_renamed46 = 'Project successfully renamed.';
  JVCSRES_Access_denied_4037s4146 = 'Access denied (%s).';
  JVCSRES_The_project_still_contains_checked_out_modules46 =
    'The project still contains checked out modules.';
  JVCSRES_Check_In_all_related_modules_and_retry46 = 'Check In all related modules and retry.';
  JVCSRES_Rename_project = 'Rename project';
  JVCSRES_Checked_out = 'Checked out';
  JVCSRES_Module = 'Module';
  JVCSRES_Remove_all_registry_values_associated_with_this_project63 =
    'Remove all registry values associated with this project?';

  //RemoveProj.pas
  JVCSRES_Remove_6037s6263 = 'Remove <%s>?';
  JVCSRES_Project_6037s62_successfully_removed46 = 'Project <%s> successfully removed.';
  JVCSRES_Remove_project = 'Remove project';
  JVCSRES_Module_ID = 'Module ID';
  JVCSRES_Checked_out_modules = 'Checked out modules';

  //Recent.pas
  JVCSRES_Recent_Projects47Files_45_37d_items = 'Recent Projects/Files - %d items';
  JVCSRES_Are_you_sure_you_want_to_clear_37d_entries63 =
    'Are you sure you want to clear %d entries?';
  JVCSRES_Add_module91s93_to_MRU_list = 'Add module[s] to MRU list';
  JVCSRES_37s_source_files_4037s4112437s124All_files_4042464241124424642 =
    '%s source files (%s)|%s|All files (*.*)|*.*';

  //Purge.pas  
  JVCSRES_Purge_project58_6037s62 = 'Purge project: <%s>';
  JVCSRES_Really_purge_project_6037s62_and_keep_37d_revisions_at_maximum63 =
    'Really purge project <%s> and keep %d revisions at maximum?';
  JVCSRES_Purge_project = 'Purge project';
  JVCSRES_Version = 'Version';
  JVCSRES_Revision = 'Revision';
  JVCSRES_Timestamp = 'Timestamp';
  JVCSRES_Owner = 'Owner';
  JVCSRES_This_will_affect_37d_modules46 = 'This will affect %d modules.';
  JVCSRES_Remember_that_Purge_may_take_several_minutes_on_large_projects46 =
    'Remember that Purge may take several minutes on large projects.';
  JVCSRES_Continue63 = 'Continue?';
  JVCSRES_Purge_removed_37d_revisions_40affected_modules58_37d41_from_project_6037s6246 =
    'Purge removed %d revisions (affected modules: %d) from project <%s>.';

  //ProjectTree.pas
  JVCSRES_VCS_Project_37s_45_ID58_37s_45_37s = 'VCS Project %s - ID: %s - %s';
  JVCSRES_Version_37s = 'Version %s';
  JVCSRES_Revision_37s = 'Revision %s';
  JVCSRES_37d_modules47_37d_revisions_45_State58_37s = '%d modules/ %d revisions - State: %s';
  JVCSRES_all_members = 'all members';
  JVCSRES_This_module_is_already_used_by_other_projects46 =
    'This module is already used by other projects.';
  JVCSRES_Only_the_link_to_the_current_project_was_removed46_ =
    'Only the link to the current project was removed. ';
  JVCSRES_all_revisions = 'all revisions';
  JVCSRES_RevisionID58_37d = 'RevisionID: %d';
  JVCSRES_Module_6037s62_on_disk_has_a_newer_date_than_the_module_in_the_archive33 =
    'Module <%s> on disk has a newer date than the module in the archive!';
  JVCSRES_Are_you_sure_you_want_to_overwrite_all_changes_of_the_existing_file63 =
    'Are you sure you want to overwrite all changes of the existing file?';
  JVCSRES_successfully_created46 = 'successfully created.';
  JVCSRES_40Affected_files58_37s41 = '(Affected files: %s)';
  JVCSRES_63RevisionID58_37d = '?RevisionID: %d';
  JVCSRES_Backup_Tree_Options = 'Backup Tree Options';
  JVCSRES_Backup_40Zip41_File = 'Backup (Zip) File';
  JVCSRES_Project_backup_45_collecting_revisions464646 = 'Project backup - collecting revisions...';
  JVCSRES_Project_backup_45_get_revisions464646 = 'Project backup - get revisions...';
  JVCSRES_Project_backup_45_compress_backup464646 = 'Project backup - compress backup...';
  JVCSRES_Module_Dump_Options = 'Module Dump Options';
  JVCSRES_Dump_40Zip41_File = 'Dump (Zip) File';
  JVCSRES_Module_dump_45_collecting_revisions464646 = 'Module dump - collecting revisions...';
  JVCSRES_Module_dump_45_get_revisions464646 = 'Module dump - get revisions...';
  JVCSRES_Module_dump_45_compress_dump464646 = 'Module dump - compress dump...';
  JVCSRES_Module_Version_Dump_Options = 'Module Version Dump Options';
  JVCSRES_Module_Version_dump_45_collecting_revisions464646 = 'Module Version dump - collecting revisions...';
  JVCSRES_Module_Version_dump_45_get_revisions464646 = 'Module Version dump - get revisions...';
  JVCSRES_Module_Version_dump_45_compress_dump464646 = 'Module Version dump - compress dump...';
  JVCSRES_Unable_to_add_backup_files_to = 'Unable to add backup files to';
  JVCSRES_Removing_temporary_files464646 = 'Removing temporary files...';

  //ProjectRights.pas
  JVCSRES_User_6037s62_in_project_6037s62 = 'User <%s> in project <%s>';
  JVCSRES_User_6037s62_in_60Selected_projects_4037d41_62 = 'User <%s> in <Selected projects (%d) >';
  JVCSRES_Are_you_sure_you_want_to_clear_all_project_based_rights =
    'Are you sure you want to clear all project based rights';
  JVCSRES_assigned_to_user_6037s6263 = 'assigned to user <%s>?';
  JVCSRES_None = 'None';
  JVCSRES_read45write = 'read-write';
  JVCSRES_Project_Admin = 'Project Admin';

  //ProjectHist.pas
  JVCSRES_Server_request58_Log_entries46_Please_wait464646 =
    'Server request: Log entries. Please wait...';
  JVCSRES_UC_unknown = 'unknown';
  JVCSRES_Project_History_45_37d_hits = 'Project History - %d hits';
  JVCSRES_Action = 'Action';
  JVCSRES_Check_In_Comment_45_37s = 'Check In Comment - %s';
  JVCSRES_You_have_37d_items_in_the_history_list46 = 'You have %d items in the history list.';
  JVCSRES_Loading_all_Check_In_comments_may_take_several_time46 =
    'Loading all Check In comments may take several time.';
  JVCSRES_Project_History_45_request_server_for_filter_items464646 =
    'Project History - request server for filter items...';
  JVCSRES_Project_History = 'Project History';

  //Plugins.pas
  JVCSRES_JVCL_Plugin_Manager = 'JVCL Plugin Manager';

  //PHFilter.pas
  JVCSRES_The_corresponding_value_cannot_be_blank46 = 'The corresponding value cannot be blank.';

  //Options.pas
  JVCSRES_37s_Modules = '%s Modules';
  JVCSRES_Add46_Modules = 'Add. Modules';
  JVCSRES_Compare_Modules = 'Compare Modules';
  JVCSRES_IDE_Modules = 'IDE Modules';
  JVCSRES_Image_Files = 'Image Files';
  JVCSRES_Resource_Files = 'Resource Files';
  JVCSRES_Text_Files = 'Text Files';
  JVCSRES_User_Editor_Files = 'User Editor Files';
  JVCSRES_Never_Sync = 'Never Sync';
  JVCSRES_Always_Writeable = 'Always Writeable';
  JVCSRES_Exclude_files = 'Exclude files';
  JVCSRES_Time_zone_difference_warning46 = 'Time zone difference warning.';
  JVCSRES_No_project_opened_in_the_IDE46 = 'No project opened in the IDE.';
  JVCSRES_Check_OS_for_valid_project_name46 = 'Check OS for valid project name.';
  JVCSRES_Assign_new_Project_to_Group46 = 'Assign new Project to Group.';
  JVCSRES_Prompt_for_project_description = 'Prompt for project description';
  JVCSRES_Project_related_access_level46 = 'Project related access level.';
  JVCSRES_File_not_member_of_current_project46 = 'File not member of current project.';
  JVCSRES_Prompt_for_module_description = 'Prompt for module description';
  JVCSRES_Check_In_45_skip_unchanged_files46 = 'Check In - skip unchanged files.';
  JVCSRES_Check_In_success46 = 'Check In success.';
  JVCSRES_Check_Out_success46 = 'Check Out success.';
  JVCSRES_Undo_Check_Out_success46 = 'Undo Check Out success.';
  JVCSRES_Shared_module_removed = 'Shared module removed';
  JVCSRES_Confirm_refresh_PM_view = 'Confirm refresh PM view';
  JVCSRES_Confirm_auto_Synchronize46 = 'Confirm auto Synchronize.';
  JVCSRES_Compare_binary_files46 = 'Compare binary files.';
  JVCSRES_Confirm_remove_revision_label46 = 'Confirm remove revision label.';
  JVCSRES_Confirm_delete_45_View_latest_version46 = 'Confirm delete - View latest version.';
  JVCSRES_Confirm_remove_temporary_QR_files46 = 'Confirm remove temporary QR files.';
  JVCSRES_VERSIONINFO_hint46 = 'VERSIONINFO hint.';
  JVCSRES_Confirm_remove_from_custom_filter = 'Confirm remove from custom filter';
  JVCSRES_Confirm_terminate_program = 'Confirm terminate program';
  JVCSRES_Server_connection_closed46 = 'Server connection closed.';
  JVCSRES_Win2K_34Localhost34_warning46 = 'Win2K "Localhost" warning.';
  JVCSRES_Confirm_hide_unselected_34Sync34_files46 = 'Confirm hide unselected "Sync" files.';
  JVCSRES_Auto_start_local_servers46 = 'Auto start local servers.';
  JVCSRES_Direct_SQL_warning46 = 'Direct SQL warning.';
  JVCSRES_Ctrl43_shortcuts_disabled46 = 'Ctrl+ shortcuts disabled.';
  JVCSRES_SMTP_mail_not_send46 = 'SMTP mail not send.';
  JVCSRES_Request_check_in_for_locked_modules46 = 'Request check in for locked modules.';
  JVCSRES_Synchronize_45_Verify_result46 = 'Synchronize - Verify result.';
  JVCSRES_Synchronize_45_Synchronize_result46 = 'Synchronize - Synchronize result.';
  JVCSRES_Adding_modules_45_skip_existing46 = 'Adding modules - skip existing.';
  JVCSRES_Check_In_45_skip_not_checked_out46 = 'Check In - skip not checked out.';
  JVCSRES_Get_writeable_warning46 = 'Get writeable warning.';
  JVCSRES_Don39t_overwrite_local_warning46 = 'Don''t overwrite local warning.';
  JVCSRES_34Global_settings34_forced_on_this_server46 = '"Global settings" forced on this server.';
  JVCSRES_Don39t_disable_locale_RO_checks_warning46 = 'Don''t disable locale RO checks warning.';
  JVCSRES_Integer_between_6037d62_and_6037d62_expected46 =
    'Integer between <%d> and <%d> expected.';
  JVCSRES_JEDI_VCS_cannot_find_the_directory58 = 'JEDI VCS cannot find the directory:';
  JVCSRES_The_directory_you_have_selected_is_located_on_a_RAM_disk_or_a_CDROM46 =
    'The directory you have selected is located on a RAM disk or a CDROM.';
  JVCSRES_You_cannot_use_temporary_or_read45only_drives_for_backup46 =
    'You cannot use temporary or read-only drives for backup.';
  JVCSRES_You_have_a_user_editor_defined_but_no_corresponding_file_extensions46 =
    'You have a user editor defined but no corresponding file extensions.';
  JVCSRES_Invalid_or_duplicate_shortcut46 = 'Invalid or duplicate shortcut.';
  JVCSRES_Char_between_60A62_and_60Z62_or_blank_expected46 =
    'Char between <A> and <Z> or blank expected.';
  JVCSRES_Data_encryption_requires_a_key_length_of_128_bit_min46 =
    'Data encryption requires a key length of 128 bit min.';
  JVCSRES_Your_key_must_be_at_least_16_characters_and_can_be_up_to_56_characters46 =
    'Your key must be at least 16 characters and can be up to 56 characters.';
  JVCSRES_Note_that_longer_keys_will_not_result_in_slower_encoding47decoding44_but_in_more_security46 =
    'Note that longer keys will not result in slower encoding/decoding, but in more security.';
  JVCSRES_Confirmation_does_not_match_key46 = 'Confirmation does not match key.';
  JVCSRES_Please_re45enter_the_key46 = 'Please re-enter the key.';
  JVCSRES_IDE_Menu_accelerator_changed46 = 'IDE Menu accelerator changed.';
  JVCSRES_You_must_restart_the_IDE_for_this_change_to_take_effect46 =
    'You must restart the IDE for this change to take effect.';
  JVCSRES_Select_editor_for_37s_files = 'Select editor for %s files';
  JVCSRES_resource = 'resource';
  JVCSRES_bitmap = 'bitmap';
  JVCSRES_text = 'text';
  JVCSRES_user_defined = 'user defined';
  JVCSRES_38Backup_root_folder58 = '&Backup root folder:';
  JVCSRES_38JEDI_VCS_temporary_folder58 = '&JEDI VCS temporary folder:';
  JVCSRES_Restore_default_filter_values63 = 'Restore default filter values?';
  JVCSRES_This_will_clear_all_changes_to_internal_filter_values46 =
    'This will clear all changes to internal filter values.';
  JVCSRES_Custom_file_filters_added_by_the_user_will_not_be_affected46 =
    'Custom file filters added by the user will not be affected.';
  JVCSRES_40OpenDialog_45_37s_modules41 = '(OpenDialog - %s modules)';
  JVCSRES_40OpenDialog_45_Additional_modules41 = '(OpenDialog - Additional modules)';
  JVCSRES_40do_not_add_binary_file_types3341 = '(do not add binary file types!)';
  JVCSRES_40loadable_by_37s_IDE41 = '(loadable by %s IDE)';
  JVCSRES_40loadable_by_Image_editor41 = '(loadable by Image editor)';
  JVCSRES_40loadable_by_Resource_editor41 = '(loadable by Resource editor)';
  JVCSRES_40loadable_by_Text_editor41 = '(loadable by Text editor)';
  JVCSRES_40loadable_by_User_editor41 = '(loadable by User editor)';
  JVCSRES_40do_not_set_read45only_flag41 = '(do not set read-only flag)';
  JVCSRES_File_filter58_37s = 'File filter: %s';
  JVCSRES_38Delphi39s_installation_base_folder58 = '&Delphi''s installation base folder:';
  JVCSRES_IDE39s_installation_base_directory46 = 'IDE''s installation base directory.';
  JVCSRES_JEDI_VCS_cannot_find_the_37s_in_drive_6037s6246 = 'JEDI VCS cannot find the %s in drive <%s>.';
  JVCSRES_directory = 'directory';
  JVCSRES_Application_server_40local41 = 'Application server (local)';
  JVCSRES_Application_Server_4037s4112437s = 'Application Server (%s)|%s';
  JVCSRES_local_application_server46 = 'local application server.';
  JVCSRES_file = 'file';
  JVCSRES_Ma38x_count = 'Ma&x count';
  JVCSRES_Max_count58_37d = 'Max count: %d';
  JVCSRES_Are_you_sure_you_want_to_clear_the_selected_MRU_list63 =
    'Are you sure you want to clear the selected MRU list?';
  JVCSRES_Source_code_template_34jvcskeywords_124_JEDI_VCS_Keyword_Expansion34_successfully_added46 =
    'Source code template "jvcskeywords | JEDI VCS Keyword Expansion" successfully added.';
  JVCSRES_Search_files_for_keywords = 'Search files for keywords';
  JVCSRES_New_Filter = 'New Filter';
  JVCSRES_Are_you_sure_you_want_to_remove_3437s3463 = 'Are you sure you want to remove "%s"?';
  JVCSRES_New_Diff_Tool = 'New Diff Tool';
  JVCSRES_Sequentiel_backup_archives = 'Sequential backup archives';
  JVCSRES_Name = 'Name';
  JVCSRES_C_Date = 'Date';
  JVCSRES_Size = 'Size';
  JVCSRES_37s_474037n_KB_in_37d_files4641 = '%s /(%n KB in %d files.)';
  JVCSRES_Remember_that_you_need_to_install_the_JEDI_VCS_forwarder =
    'Remember that you need to install the JEDI VCS forwarder';
  JVCSRES_34FVCSSMTP46exe34_in_order_to_send_SMTP_mail46 =
    '"FVCSSMTP.exe" in order to send SMTP mail.';
  JVCSRES_This_is_a_potentially_dangerous_option_and_only_recommended_for =
    'This is a potentially dangerous option and only recommended for';
  JVCSRES_experienced_users46_Inproper_use_may_cause_data_loss33 =
    'experienced users. Inproper use may cause data loss!';
  JVCSRES_Please_read_the_related_help_topic_before_enabling_this_option46 =
    'Please read the related help topic before enabling this option.';
  JVCSRES_Enable_3437s34_anyway63_ = 'Enable "%s" anyway? ';
  JVCSRES_Don39t_perform_RO_flag_checks = 'Don''t perform RO flag checks';
  JVCSRES_Are_you_really_sure_to_change_the_configuration_storage_method63 =
    'Are you really sure to change the configuration storage method?';
  JVCSRES_You_will_loose_all_settings44_MRU_lists_and_stored_window_positions47sizes33 =
    'You will loose all settings, MRU lists and stored window positions/sizes!';
  JVCSRES_This_change_will_not_take_effect_until_you_restart_the_application46 =
    'This change will not take effect until you restart the application.';

  //OpenProject.pas
  JVCSRES_Project_names_are_subject_to_the_naming_conventions_of_the_operating_system46 =
    'Project names are subject to the naming conventions of the operating system.';
  JVCSRES_JEDI_VCS_can_check_for_you_if_the_project_name_matches_these_conditions46 =
    'JEDI VCS can check for you if the project name matches these conditions.';
  JVCSRES_Remember_that_the_test_will_overwrite_existing_files_with_the_same_name_in_your_temporary_foder46 =
    'Remember that the test will overwrite existing files with the same name in your temporary foder.';
  JVCSRES_Check_now63 = 'Check now?';
  JVCSRES_JEDI_VCS_cannot_create_the_file_on_disk46 = 'JEDI VCS cannot create the file on disk.';
  JVCSRES_The_project_name_seems_to_be_invalid46 = 'The project name seems to be invalid.';
  JVCSRES_The_name_matches_the_naming_conventions_of_the_operating_system46 =
    'The name matches the naming conventions of the operating system.';

  //NtfySend.pas
  JVCSRES_From58_9137s_on_37s93_37s = 'From: [%s on %s] %s';
  JVCSRES_Mailslot_notifying_disabled = 'Mailslot notifying disabled';
  JVCSRES_38Message58_40max_length_37d_chars41 = '&Message: (max length %d chars)';
  JVCSRES_40to58_All41_ = '(to: All) ';
  JVCSRES_40to58_37s41_ = '(to: %s) ';
  JVCSRES_User_message58 = 'User message:';
  JVCSRES_Notify58_Send_User_defined_message_45_Success = 'Notify: Send User defined message - Success';
  JVCSRES_Notify58_Send_User_defined_message_45_Error = 'Notify: Send User defined message - Error';
  JVCSRES_42All42 = '*All*';
  JVCSRES_User_defined_message = 'User defined message';
  JVCSRES_42None42 = '*None*';
  JVCSRES_Select_SMTP_recipient = 'Select SMTP recipient';

  //ModuleInfo.pas
  JVCSRES_Unknown_module58_37s = 'Unknown module: %s';
  JVCSRES_Revisions_45_37s_40V_37s4637s41_ = 'Revisions - %s (V %s.%s) ';
  JVCSRES_45_blank_45 = '- blank -';
  JVCSRES_Get = 'Get';
  JVCSRES_38Delete_without_prompting_from_now_on46 = '&Delete without prompting from now on.';
  JVCSRES_There_is_already_a_file_6037s62_in = 'There is already a file <%s> in';
  JVCSRES_Delete_the_file_to_show_the_latest_archive_version_of_6037s6263 =
    'Delete the file to show the latest archive version of <%s>?';
  JVCSRES_Get_writeable = 'Get writeable';

  //ModuleHistoryWindow.pas
  JVCSRES_Check_in_comment58 = 'Check in comment:';
  JVCSRES_Check_out_comment58 = 'Check out comment:';
  JVCSRES_Comments_for_version_37s = 'Comments for version %s';

  //MergeVersion.pas
  JVCSRES_VCS_Merge_Query_45_37s = 'VCS Merge Query - %s';
  JVCSRES_VCS_Merge_45_37s = 'VCS Merge - %s';
  JVCSRES_You_cannot_37s_while_modules_are_checked_out46 =
    'You cannot %s while modules are checked out.';
  JVCSRES_Check_in_all_modules_and_retry46 = 'Check in all modules and retry.';
  JVCSRES_merge = 'merge';
  JVCSRES_Locked_modules = 'Locked modules';
  JVCSRES_Cannot_merge_from_version_6037d62_to_6037d6246 =
    'Cannot merge from version <%d> to <%d>.';
  JVCSRES_Target_version_must_be_higher_than_source_version46 =
    'Target version must be higher than source version.';
  JVCSRES_Are_you_sure_you_want_to_create_a_complete_new_version_4037d4637d41_of_the_application63 =
    'Are you sure you want to create a complete new version (%d.%d) of the application?';
  JVCSRES_Merge_new_version464646 = 'Merge new version...';
  JVCSRES_Project_6037s62_40Version_37d4637d41_successfully_merged46 = 'Project <%s> (Version %d.%d) successfully merged.';
  JVCSRES_37d_modules46 = '%d modules.';
  JVCSRES_Labeling464646 = 'Labeling...';
  JVCSRES_Move_the_module_to_the_current_version63 = 'Move the module to the current version?';
  JVCSRES_Label_6037s62_successfully_assigned_to_37d_modules46 =
    'Label <%s> successfully assigned to %d modules.';

  //MaintainUsers.pas
  JVCSRES_Fatal_Error58_JEDI_VCS_cannot_load_the_library58 =
    'Fatal Error: JEDI VCS cannot load the library:';
  JVCSRES_Terminate_the_program44_make_sure_that_this_file_exists_in_the =
    'Terminate the program, make sure that this file exists in the';
  JVCSRES_application_folder_and_retry46 = 'application folder and retry.';
  JVCSRES_There_are_already_modules_locked_by_this_user46 =
    'There are already modules locked by this user.';
  JVCSRES_If_you_delete_the_user_now_you_will_be_unable_to_check_in_these_modules46 =
    'If you delete the user now you will be unable to check in these modules.';
  JVCSRES_This_is_the_only_archive_administrator_registered_in_the_archive46 =
    'This is the only archive administrator registered in the archive.';
  JVCSRES_You_cannot_delete_this_user_until_a_new_archive_administrator_is_defined46 =
    'You cannot delete this user until a new archive administrator is defined.';
  JVCSRES_Are_you_sure_you_want_to_remove_user_6037s62_from_the_archive63 =
    'Are you sure you want to remove user <%s> from the archive?';
  JVCSRES_records = 'records';
  JVCSRES_Modules_locked_by464646 = 'Modules locked by...';
  JVCSRES_ID = 'ID';
  JVCSRES_Locked = 'Locked';
  JVCSRES_Log_out_user_6037s62_63 = 'Log out user <%s>?';
  JVCSRES_User_list = 'User list';
  JVCSRES_SMTP_Mail = 'SMTP Mail';
  JVCSRES_Enter_mail_address = 'Enter mail address';

  //MaintainMilestones.pas
  JVCSRES_Are_you_sure_you_want_to_remove_milestone_6037s62_from_the_archive63 =
    'Are you sure you want to remove milestone <%s> from the archive?';

  //MaintainLabels.pas
  JVCSRES_Are_you_sure_you_want_to_remove_label_6037s62_from_the_archive63 =
    'Are you sure you want to remove label <%s> from the archive?';
  JVCSRES_Label_6037s62_is_already_in_use_by_some_revisions46 =
    'Label <%s> is already in use by some revisions.';
  JVCSRES_Modules_using_the_label = 'Modules using the label';

  //MaintainFFamilies.pas
  JVCSRES_Are_you_sure_you_want_to_remove_family_6037s62_from_the_archive63 =
    'Are you sure you want to remove family <%s> from the archive?';
  JVCSRES_There_are_already_modules_in_the_archive_checked_in_by_this_family_ID46 =
    'There are already modules in the archive checked in by this family ID.';
  JVCSRES_Modules_checked_in_by464646 = 'Modules checked in by...';

  //MaintainBugs.pas
  JVCSRES_Are_you_sure_you_want_to_remove_bug_6037s62_from_the_archive63 =
    'Are you sure you want to remove bug <%s> from the archive?';
  JVCSRES_Bug_6037s62_is_already_in_use46 = 'Bug <%s> is already in use.';
  JVCSRES_Type = 'Type';
  JVCSRES_This_feature_has_not_been_finished_yet_and_has_been_disabled =
    'This feature has not been finished yet and has been disabled';
  JVCSRES_until_it_has_been_fixed46_Sorry46 = 'until it has been fixed. Sorry.';
  JVCSRES_Select_bug_import_file = 'Select bug import file';
  JVCSRES_Assign_bug_6037s62_to_6037s6263 = 'Assign bug <%s> to <%s>?';
  JVCSRES_No_such_project_in_the_archive46 = 'No such project in the archive.';
  JVCSRES_37d_bugs_added_to_version_archive46 = '%d bugs added to version archive.';

  //LoadModule.pas
  JVCSRES_Select_the_module_again_and_retry_if_you_have_defined_an_editor_now46 =
    'Select the module again and retry if you have defined an editor now.';
  JVCSRES_Module_6037s62_is_not_available_on_the_local_disk46 =
    'Module <%s> is not available on the local disk.';
  JVCSRES_You_must_Get_the_module_first_or_select_34View_latest_Archive_Version3446 =
    'You must Get the module first or select "View latest Archive Version".';
  JVCSRES_Project_files_should_not_be_loaded_from_here46 =
    'Project files should not be loaded from here.';
  JVCSRES_Select_39Recent_Projects39_or_39File124Open_Project39_to_open_a_new_project46 =
    'Select ''Recent Projects'' or ''File|Open Project'' to open a new project.';
  JVCSRES_Load_module58_37s_37s_45_Success = 'Load module: %s %s - Success';
  JVCSRES_Load_module_40IDE4158_37s_45_Success = 'Load module (IDE): %s - Success';
  JVCSRES_You_do_not_have_a_JEDI_VCS_37s_editor_defined46 =
    'You do not have a JEDI VCS %s editor defined.';
  JVCSRES_There_is_no_application_associated_with_the_given_file_extension_4037s4146 =
    'There is no application associated with the given file extension (%s).';
  JVCSRES_Would_you_like_to_select_an_application_now63 =
    'Would you like to select an application now?';
  JVCSRES_Load_module_40ShellExecute4158_37s_45_Success = 'Load module (ShellExecute): %s - Success';

  //ListEdit.pas
  JVCSRES_38Add_as_new_search_path58 = '&Add as new search path:';
  JVCSRES_37s45files_404237s411244237s124All_files_4042464241124424642 =
    '%s-files (*%s)|*%s|All files (*.*)|*.*';
  JVCSRES_37s_a_binary_file_type46_You_37s_use_files_of_this_type_with_JEDIVCSDiff46exe46 =
    '%s a binary file type. You %s use files of this type with JEDIVCSDiff.exe.';
  JVCSRES_is = 'is';
  JVCSRES_cannot = 'cannot';
  JVCSRES_is_not = 'is not';
  JVCSRES_can = 'can';

  //KWExpansion.pas
  JVCSRES_JEDI_VCS_cannot_expand_keywords_in_file = 'JEDI VCS cannot expand keywords in file';
  JVCSRES_The_file_is_a_binary_file_type46 = 'The file is a binary file type.';
  JVCSRES_JEDI_VCS_cannot_expand_the_keywords_in_file =
    'JEDI VCS cannot expand the keywords in file';
  JVCSRES_Exception58_37s = 'Exception: %s';

  //JediVCSDLL.dpr
  JVCSRES_This_is_an_outdated_Beta_version33 = 'This is an outdated Beta version!';
  JVCSRES_37s_Beta_version = '%s Beta version';
  JVCSRES_Connection_closed46 = 'Connection closed.';
  JVCSRES_You_must_reopen_the_connection_to_make_JEDI_VCS39s_functions_available46 =
    'You must reopen the connection to make JEDI VCS''s functions available.';
  JVCSRES_6037s62_is_not_a_member_of_the_current_VC_project_6037s6246 =
    '<%s> is not a member of the current VC project <%s>.';
  JVCSRES_You_cannot_access_the_module_from_here46 =
    'You cannot access the module from here.';
  JVCSRES_Add_the_module_to_the_current_VC_project63 =
    'Add the module to the current VC project?';
  JVCSRES_37s_Check_In = '%s Check In';
  JVCSRES_37s_Check_Out = '%s Check Out';
  JVCSRES_37s_Get = '%s Get';
  JVCSRES_6037s62_is_not_a_member_of_the_current_VC_project46 =
    '<%s> is not a member of the current VC project.';
  JVCSRES_38Synchronize_without_prompting_from_now_on46 =
    '&Synchronize without prompting from now on.';
  JVCSRES_Synchronize_6037s62_with_the_latest_version_archive_state63 =
    'Synchronize <%s> with the latest version archive state?';
  JVCSRES_JEDI_VCS_cannot_load_the_library58 = 'JEDI VCS cannot load the library:';
  JVCSRES_The_function_you_have_requested_requires_an_additional =
    'The function you have requested requires an additional';
  JVCSRES_DLL_which_is_not_part_of_the_JEDI_VCS_standard_package46 =
    'DLL which is not part of the JEDI VCS standard package.';
  JVCSRES_You_can_download_this_DLL_for_free_from_JEDI_VCS_home46 =
    'You can download this DLL for free from JEDI VCS home.';
  JVCSRES_Fatal_Error58_JEDI_VCS_cannot_find_the_external_library_procedure58 =
    'Fatal Error: JEDI VCS cannot find the external library procedure:';
  JVCSRES_The_reason_for_this_is_usually_an_invalid_DLL_version =
    'The reason for this is usually an invalid DLL version';
  JVCSRES_or_the_library_could_not_be_loaded46 = 'or the library could not be loaded.';
  JVCSRES_37d_KBytes_in_37d_temporary_files_40QRPxx46tmp41_left_in_6037s6246 =
    '%d KBytes in %d temporary files (QRPxx.tmp) left in <%s>.';
  JVCSRES_Delete63 = 'Delete?';
  JVCSRES_Fatal_Error58_JEDI_VCS_is_unable_to_get_the_DLL_path46 =
    'Fatal Error: JEDI VCS is unable to get the DLL path.';
  JVCSRES_Close_the_program44_execute_34reginst46exe34_and_retry46 =
    'Close the program, execute "reginst.exe" and retry.';
  JVCSRES_Unable_to_create58_37s = 'Unable to create: %s';
  JVCSRES_37s58_Unable_to_get_privilege_SE95DEBUG46 = '%s: Unable to get privilege SE_DEBUG.';
  JVCSRES_Remember_that_you_must_open_a_project_to_work_with_JEDI_VCS46 =
    'Remember that you must open a project to work with JEDI VCS.';
  JVCSRES_Application_server_not_connected46 = 'Application server not connected.';
  JVCSRES_Connect_the_application_server_and_retry46 =
    'Connect the application server and retry.';
  JVCSRES_Server_reports_an_unknown_project_name_6037s6246 =
    'Server reports an unknown project name <%s>.';
  JVCSRES_Create_a_new_project_with_this_name63 = 'Create a new project with this name?';
  JVCSRES_Project_6037s62_successfully_created46_Project_ID58_37s =
    'Project <%s> successfully created. Project ID: %s';
  JVCSRES_Connect_failed46_4037s4146 = 'Connect failed. (%s).';
  JVCSRES_The_JEDI_VCS_server_on_host_6037s62_did_not_answer46 =
    'The JEDI VCS server on host <%s> did not answer.';
  JVCSRES_Perhaps_the_server_is_not_running44_you_have_entered_an_invalid_IP_or_port_number =
    'Perhaps the server is not running, you have entered an invalid IP or port number';
  JVCSRES_or_your_TCP47IP_network_is_not_properly_set46 =
    'or your TCP/IP network is not properly set.';
  JVCSRES_Select_the_connect_dialog39s_help_button_for_more_information46 =
    'Select the connect dialog''s help button for more information.';
  JVCSRES_40See_34Shared_by34_for_a_complete_list41 = '(See "Shared by" for a complete list)';
  JVCSRES_This_module_is_already_used_by_37d_other_project91s9358 =
    'This module is already used by %d other project[s]:';
  JVCSRES_Module_added_as_shared_link46 = 'Module added as shared link.';
  JVCSRES_You_cannot_add_this_type_of_file58 = 'You cannot add this type of file:';
  JVCSRES_Disconnect47_38Close = 'Disconnect/ &Close';
  JVCSRES_C38onnect_Server464646 = 'C&onnect Server...';
  JVCSRES_38Project_Manager464646 = '&Project Manager...';
  JVCSRES_Check_38In47_Put_6037s62464646 = 'Check &In/ Put <%s>...';
  JVCSRES_Check_38Out_6037s62464646 = 'Check &Out <%s>...';
  JVCSRES_38Get_6037s62464646 = '&Get <%s>...';
  JVCSRES_Relo38ad_6037s62 = 'Relo&ad <%s>';
  JVCSRES_Co38mpare_Modules464646 = 'Co&mpare Modules...';
  JVCSRES_Module_Histor38y464646 = 'Module Histor&y...';
  JVCSRES_P38roject_History464646 = 'P&roject History...';
  JVCSRES_Merge47_38Stamp_Projects464646 = 'Merge/ &Stamp Projects...';
  JVCSRES_Synchroni38ze47_Restore_Projects464646 = 'Synchroni&ze/ Restore Projects...';
  JVCSRES_Create_from_38DB464646 = 'Create from &DB...';
  JVCSRES_38Branch_Projects464646 = '&Branch Projects...';
  JVCSRES_Reports47_Pri38nting464646 = 'Reports/ Pri&nting...';
  JVCSRES_38VCS_Properties464646 = '&VCS Properties...';
  JVCSRES_ToDo_38List464646 = 'ToDo &List...';
  JVCSRES_Tim38e_Log464646 = 'Tim&e Log...';
  JVCSRES_Back38up47_Restore464646 = 'Back&up/ Restore...';
  JVCSRES_38Touch464646 = '&Touch...';
  JVCSRES_Recent_Pro38jects464646 = 'Recent Pro&jects...';
  JVCSRES_38Help_Topics = '&Help Topics';
  JVCSRES_About_38JEDI_VCS = 'About &JEDI VCS';

  //History.pas
  JVCSRES_blank = 'blank';
  JVCSRES_Module_History_45_37s_45_37s_45_available_versions58_37d =
    'Module History - %s - %s - available versions: %d';

  //HandleBlob.pas
  JVCSRES_EncodeKey_blank = 'EncodeKey blank';
  JVCSRES_BlowFishDecode_failed = 'BlowFishDecode failed';
  JVCSRES_Zipmaster46SuccessCnt_61_0 = 'Zipmaster.SuccessCnt = 0';
  JVCSRES_Unable_to_create_target_directory58_37s = 'Unable to create target directory: %s';
  JVCSRES_91Write_access_denied93 = '[Write access denied]';
  JVCSRES_AppSrvClient46Request_Error_91GET95CHECKOUT95MODULE93 =
    'AppSrvClient.Request Error [GET_CHECKOUT_MODULE]';
  JVCSRES_File_is_locked_by_6037s6246 = 'File is locked by <%s>.';
  JVCSRES_Access_denied = 'Access denied';
  JVCSRES_Current_version_does_not_support_uncompressed_modules33 =
    'Current version does not support uncompressed modules!';
  JVCSRES_TFileStream_Error58_37s = 'TFileStream Error: %s';
  JVCSRES_Error_extract_zip_file58_37s = 'Error extract zip file: %s';
  JVCSRES_FileSetDate_Error58_37s = 'FileSetDate Error: %s';
  JVCSRES_General_error_extract_zip_file = 'General error extract zip file';
  JVCSRES_AppSrvClient46Request_Error_91CHECKOUT95ONLY95MODULE93 =
    'AppSrvClient.Request Error [CHECKOUT_ONLY_MODULE]';
  JVCSRES_File_is_locked_by_6037s6246_Access_denied =
    'File is locked by <%s>. Access denied';

  //ProjDependencies.pas
  JVCSRES_External_modules_45_37s = 'External modules - %s';
  JVCSRES_External_modules_45_37s_45_37d_items = 'External modules - %s - %d items';

  //EditIP.pas
  JVCSRES_Integer_between_6037d62_and_6037d62_or_wildcard_expected46 =
    'Integer between <%d> and <%d> or wildcard expected.';

  //Distribution.pas
  JVCSRES_Add_external_files = 'Add external files';
  JVCSRES_37s_source_files_4037s4112437s = '%s source files (%s)|%s';
  JVCSRES_Other_source_files_4037s4112437s = 'Other source files (%s)|%s';
  JVCSRES_Archive_file_successfully_created_4037d_files4146 =
    'Archive file successfully created (%d files).';
  JVCSRES_Save_source_distribution = 'Save source distribution';
  JVCSRES_You_have_added_or_changed_custom_files_to_the_list46 =
    'You have added or changed custom files to the list.';
  JVCSRES_Save_these_files_and_and_restore_the_list_the_next_time_you_open_the_dialog63 =
    'Save these files and and restore the list the next time you open the dialog?';
  JVCSRES_It_is_not_possible_to_create_the_source_distribution_file_without_path_information44 =
    'It is not possible to create the source distribution file without path information,';
  JVCSRES_because_the_current_project_contains_at_least_one_file_with_the_same_name_in_different_paths46 =
    'because the current project contains at least one file with the same name in different paths.';
  JVCSRES_34Include_path_information34_will_be_enabled_now_in_order_to_create_the_source_distribution_file_for_this_project46 =
    '"Include path information" will be enabled now in order to create the source distribution file for this project.';

  //DirWatch.pas
  JVCSRES_Scan_Result_45_37d_files_45_37d_new_files_45_37d_selected =
    'Scan Result - %d files - %d new files - %d selected';
  JVCSRES_Project_member = 'Project member';
  JVCSRES_No_project_member = 'No project member';

  //DirectSQL.pas  
  JVCSRES_Result_set_is_blank46 = 'Result set is blank.';
  JVCSRES_SQL_result = 'SQL result';
  JVCSRES_Open_SQL_query = 'Open SQL query';
  JVCSRES_SQL_files_404246sql594246txt411244246sql594246txt124All_files_4042464241124424642 =
    'SQL files (*.sql;*.txt)|*.sql;*.txt|All files (*.*)|*.*';
  JVCSRES_Save_SQL_query = 'Save SQL query';

  //Description.pas
  JVCSRES_Project_Description = 'Project Description';
  JVCSRES_Module_Description = 'Module Description';
  JVCSRES_Milestone_40reached41_Description = 'Milestone (reached) Description';
  JVCSRES_Last_Description = 'Last Description';

  //DeletePH.pas
  JVCSRES_Ignore_project_name = 'Ignore project name';
  JVCSRES_Ignore_module_name = 'Ignore module name';
  JVCSRES_Ignore_user_name = 'Ignore user name';
  JVCSRES_37s_items_removed46 = '%s items removed.';

  //DBModule.pas
  JVCSRES_Server_banner58_45blank45 = 'Server banner: -blank-';
  JVCSRES_Server_banner58_3937s39 = 'Server banner: ''%s''';

  //CustViewFilter.pas
  JVCSRES_Custom_view_filter_45_37s_45_37d_items = 'Custom view filter - %s - %d items';

  //Create.pas
  JVCSRES_Unable_to_determine_version464646 = 'Unable to determine version...';
  JVCSRES_IDE_returns_no_active_IDE_project46 = 'IDE returns no active IDE project.';
  JVCSRES_JEDI_VCS39s_functionality_will_be_only_partly_available46 =
    'JEDI VCS''s functionality will be only partly available.';
  JVCSRES_Hit_60DEL62_to_stop_Auto_login = 'Hit <DEL> to stop Auto login';
  JVCSRES_Do_not_use_34localhost34_or_3412746046046134_if_your_PC_is_running_Win200033 =
    'Do not use "localhost" or "127.0.0.1" if your PC is running Win2000!';
  JVCSRES_Use_the_machines_real_IP_number_4037s41_to_connect_a_local_server46 =
    'Use the machines real IP number (%s) to connect a local server.';
  JVCSRES_Connecting_server44_please_wait464646 = 'Connecting server, please wait...';
  JVCSRES_JEDI_VCS_cannot_retrieve_the_servers_local_time46 =
    'JEDI VCS cannot retrieve the servers local time.';
  JVCSRES_This_value_is_necessary_around_client_password_encryption46 =
    'This value is necessary around client password encryption.';
  JVCSRES_Server_response58_6037s62 = 'Server response: <%s>';
  JVCSRES_Access_denied46_4040341 = 'Access denied. (403)';
  JVCSRES_Unknown_user_name44_wrong_password_or_invalid_client_IP46 =
    'Unknown user name, wrong password or invalid client IP.';
  JVCSRES_Re45check_your_login_data_and_retry46 = 'Re-check your login data and retry.';
  JVCSRES_No_response_from_server46_Try_to_start_local_server464646 =
    'No response from server. Try to start local server...';
  JVCSRES_38Start_the_local_server_without_prompting_from_now_on46 =
    '&Start the local server without prompting from now on.';
  JVCSRES_Should_JEDI_VCS_try_to_start_the_local_server6346 =
    'Should JEDI VCS try to start the local server?.';
  JVCSRES_No_response_from_server46 = 'No response from server.';
  JVCSRES_JEDI_VCS_detects_an_unknown_server_type58_9137s9346 =
    'JEDI VCS detects an unknown server type: [%s].';
  JVCSRES_See_34Help124About124Version_Information34_for_a_list_of_known_server_types46 =
    'See "Help|About|Version Information" for a list of known server types.';
  JVCSRES_Warning33_Client_may_not_work_correctly33 =
    'Warning! Client may not work correctly!';
  JVCSRES_The_server_you_have_connected_reports_9137s93_version_37d46372462d46 =
    'The server you have connected reports [%s] version %d.%2.2d.';
  JVCSRES_This_client_expects_at_least_a_server_from_version_37d46372462d46 =
    'This client expects at least a server from version %d.%2.2d.';
  JVCSRES_Warning33_Client_will_not_work_correctly33 =
    'Warning! Client will not work correctly!';
  JVCSRES_34Global_settings34_flag_set_by_admin_on_37s46 =
    '"Global settings" flag set by admin on %s.';
  JVCSRES_Some_local_options47features_may_be_overwritten_by_global_settings =
    'Some local options/features may be overwritten by global settings';
  JVCSRES_and_will_be_locked_as_long_as_you_are_connected_to_this_server46 =
    'and will be locked as long as you are connected to this server.';
  JVCSRES_JEDI_VCS_cannot_synchronize_your_local_time_with_the_server39s_time46 =
    'JEDI VCS cannot synchronize your local time with the server''s time.';
  JVCSRES_Probably_you_don39t_have_the_required_rights_for_this46 =
    'Probably you don''t have the required rights for this.';
  JVCSRES_JEDI_VCS_cannot_get_the_privilege_6037s6246 =
    'JEDI VCS cannot get the privilege <%s>.';
  JVCSRES_Access_denied_by_OS46 = 'Access denied by OS.';
  JVCSRES_Execute_Ping_raised_exception58 = 'Execute Ping raised exception:';
  JVCSRES_Execute_Ping_for_6037s62_with_32_Bytes_of_data46 =
    'Execute Ping for <%s> with 32 Bytes of data.';
  JVCSRES_Success46_Ping_reply_status58_No_error46 = 'Success. Ping reply status: No error.';
  JVCSRES_Received_37d_Bytes44_Time_61_37s_msec44_TTL_61_12846 =
    'Received %d Bytes, Time = %s msec, TTL = 128.';
  JVCSRES_Ping_6037s62_45_Success46 = 'Ping <%s> - Success.';
  JVCSRES_Failed46_Ping_reply_status58_37s46 = 'Failed. Ping reply status: %s.';
  JVCSRES_Ping_6037s62_45_Failed46_37s = 'Ping <%s> - Failed. %s';
  JVCSRES_Remember_that_caps_lock_may_interfere_with_passwords46 =
    'Remember that caps lock may interfere with passwords.';
  JVCSRES_Try_to_connect_local_server464646 = 'Try to connect local server...';
  JVCSRES_Are_you_sure_you_want_to_remove_6037s62_37s_from_ =
    'Are you sure you want to remove <%s> %s from ';
  JVCSRES_Server_Identies = 'Server Identies';
  JVCSRES_New_Server_Identity = 'New Server Identity';
  JVCSRES_Enter_Identity_Name = 'Enter Identity Name';
  JVCSRES_Host47Port47User = 'Host/Port/User';
  JVCSRES_Warning33_Storing_your_passwords_is_not_recommended33 =
    'Warning! Storing your passwords is not recommended!';
  JVCSRES_Other_users_with_access_to_your_computer_may_be_able_to =
    'Other users with access to your computer may be able to';
  JVCSRES_decode_or_use_them46_Continue_anyway63 = 'decode or use them. Continue anyway?';

  //CompareFolders.pas
  JVCSRES_38Base_folder58 = '&Base folder:';
  JVCSRES_Base_only = 'Base only';
  JVCSRES_no_such_file = 'no such file';
  JVCSRES_Different = 'Different';
  JVCSRES_C_Equal = 'Equal';
  JVCSRES_Target_only = 'Target only';
  JVCSRES_Base58_37d_files47_Target58_37d_files = 'Base: %d files/ Target: %d files';
  JVCSRES_37d_equal_files47_37d_in_both_directories44_but_different47_37d_only_in_base47_37d_only_in_target46 =
    '%d equal files/ %d in both directories, but different/ %d only in base/ %d only in target.';
  JVCSRES_File_compare58_Timestamp = 'File compare: Timestamp';
  JVCSRES_File_compare58_CRC32 = 'File compare: CRC32';
  JVCSRES__40local41 = ' (local)';
  JVCSRES_Are_you_sure_you_want_to_overwrite_this_file63 =
    'Are you sure you want to overwrite this file?';

  //BackupTreeOptions.pas
  JVCSRES_Development_state_backup_to_zip_file = 'Development state backup to zip file';
  JVCSRES_Zip_files_404246zip411244246zip = 'Zip files (*.zip)|*.zip';

  //Jedivcsdll.dpr
  JVCSRES_Project_37s_is_deleted_in_VCS33 = 'Project %s is deleted in VCS!';
  JVCSRES_Selected_action_is_not_permitted_for_deleted_projects46 = 'Selected action is not permitted for deleted projects.';

  //JVCSChkInOutCommon.pas
  JVCSRES_60empty62 = '<empty>';
  JVCSRES_464646404337d_chars41 = '...(+%d chars)';

  //JVCSLockedModulesDockWnd.pas
  JVCSRES_Undo_Check_Out_of_6037s62_failed33 = 'Undo Check Out of <%s> failed!';

  //JVCSCreateBranchDialog.pas
  JVCSRES_Current_Branch_6037s62 = 'Current Branch <%s>';
  JVCSRES_Parent_Branch58 = 'Parent Branch:';
  JVCSRES_Branch_Name58 = 'Branch Name:';
  JVCSRES_Branch_Description58 = 'Branch Description:';
  JVCSRES_Branch_creation_was_successful46 = 'Branch creation was successful.';
  JVCSRES_Branch_creation_failed33 = 'Branch creation failed!';

  //JVCSManageFavorites.pas
  JVCSRES_Add_project = 'Add project';

  //JVCSSelectBranchDialog.pas
  JVCSRES_Select_a_Branch_40Open41 = 'Select a Branch (Open)';
  JVCSRES_Select_a_Branch_40Remove41 = 'Select a Branch (Remove)';

implementation

end.
