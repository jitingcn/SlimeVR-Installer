Unicode True

!AddPluginDir /x86-unicode     "plugins\NScurl\x86-unicode"
!AddPluginDir /x86-ansi        "plugins\NScurl\x86-ansi"
!AddPluginDir /amd64-unicode   "plugins\NScurl\amd64-unicode"
!AddPluginDir /x86-unicode     "plugins\AccessControl\x86-unicode"
!AddPluginDir /x86-ansi        "plugins\AccessControl\x86-ansi"
!AddPluginDir /amd64-unicode   "plugins\AccessControl\amd64-unicode"
!AddPluginDir /x86-unicode     "plugins\Nsisunz\x86-unicode"
!AddPluginDir /x86-ansi        "plugins\Nsisunz\x86-ansi"
!AddPluginDir /x86-unicode     "plugins\NsProcess\x86-unicode"
!AddPluginDir /x86-ansi        "plugins\NsProcess\x86-ansi"
!AddPluginDir /amd64-unicode   "plugins\NsProcess\amd64-unicode"

!include x64.nsh 		; For RunningX64 check
!include LogicLib.nsh	; For conditional operators
!include nsDialogs.nsh  ; For custom pages
!include FileFunc.nsh   ; For GetTime function
!include .\plugins\NsProcess\NsProcess.nsh ; For Check on SteamVR
#!include WinMessages.nsh
!include TextFunc.nsh   ; For ConfigRead
!include MUI2.nsh
!include .\steamdetect.nsh
!include .\dlmacro.nsh

; Language selection dialog configuration
!define MUI_LANGDLL_WINDOWTITLE "Language Selection / 语言选择"
!define MUI_LANGDLL_INFO "Please select the language for the installer:$\r$\n请选择安装程序的语言："
!define MUI_LANGDLL_REGISTRY_ROOT "HKCU"
!define MUI_LANGDLL_REGISTRY_KEY "Software\SlimeVR\Installer"
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
!define MUI_LANGDLL_ALLLANGUAGES

!define CSIDL_COMMON_DOCUMENTS 0x002E ; Define CSIDL_COMMON_DOCUMENTS if not already defined

!define SF_USELECTED  0
!define MUI_ICON "run.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "logo.bmp"
!define MUI_HEADERIMAGE_BITMAP_STRETCH "NoStretchNoCrop"
!define MUI_HEADERIMAGE_RIGHT
!define SLIMETEMP "$TEMP\SlimeVRInstaller"

# Define all download URLs and versions here for easy editing
!define MVCVersion ""
!define MVCURLType "url" ; "url" or "local"
!define MVCDLURL "https://aka.ms/vs/17/release/vc_redist.x64.exe"
!define MVCDLFileZip "vc_redist.x64.exe"

!define WV2Version ""
!define WV2URLType "url" ; "url" or "local"
!define WV2DLURL "https://go.microsoft.com/fwlink/p/?LinkId=2124703"
!define WV2DLFileZip "MicrosoftEdgeWebView2RuntimeInstaller.exe"
# Define the Java Version Strings and to Check (JRE\relase -> JAVA_RUNTIME_VERSION=)
!define JREVersion "17.0.16+8"
!define JREURLType "url" ; "url" or "local"
!define JREDLURL "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.16%2B8/OpenJDK17U-jre_x64_windows_hotspot_17.0.16_8.zip"
!define JREDLFileZip "OpenJDK17U-jre_x64_windows_hotspot_17.0.16_8.zip"

!define SVRServerVersion "latest"
!define SVRServerURLType "url" ; "url" or "local"
!define SVRServerDLURL "https://github.com/SlimeVR/SlimeVR-Server/releases/latest/download/SlimeVR-win64.zip"
!define SVRServerDLFileZip "SlimeVR-Server-latest.zip"

!define SVRDriverVersion "latest"
!define SVRDriverURLType "url" ; "url" or "local"
!define SVRDriverDLURL "https://github.com/SlimeVR/SlimeVR-OpenVR-Driver/releases/latest/download/slimevr-openvr-driver-win64.zip"
!define SVRDriverDLFileZip "slimevr-openvr-driver-win64.zip"

!define SVRFeederVersion "latest"
!define SVRFeederURLType "url" ; "url" or "local"
!define SVRFeederDLURL "https://github.com/SlimeVR/SlimeVR-Feeder-App/releases/latest/download/SlimeVR-Feeder-App-win64.zip"
!define SVRFeederDLFileZip "SlimeVR-Feeder-App-latest.zip"

Var JREneedInstall
Var /GLOBAL PUBLIC
Var /GLOBAL SteamVRResult
Var /GLOBAL SteamVRLabelID
Var /GLOBAL SteamVRLabelTxt
Var /GLOBAL TestProcessReturn
Var /GLOBAL SlimeVRRunning
Var /GLOBAL SlimeVRLabelID
Var /GLOBAL SlimeVRLabelTxt

# Define name of installer
Name "SlimeVR"

SpaceTexts none # Don't show required disk space since we don't know for sure
SetOverwrite on
SetCompressor lzma  # Use LZMA Compression algorithm, compression quality is better.

OutFile "slimevr_web_installer.exe"

# Define installation directory
InstallDir "$PROGRAMFILES\SlimeVR Server" ; $InstDir default value. Defaults to user's local appdata to avoid asking admin rights

ShowInstDetails show
ShowUninstDetails show

BrandingText "SlimeVR Installer 0.2.2 offline package by vrc: jitingcat"

# Admin rights are required for:
# 1. Removing Start Menu shortcut in Windows 7+
# 2. Adding/removing firewall rules
# 3. USB drivers installation
RequestExecutionLevel admin

# Start page installer actions
Var REPAIR
Var UPDATE
Var SELECTED_INSTALLER_ACTION

# End page actions
Var CREATE_DESKTOP_SHORTCUT
Var CREATE_STARTMENU_SHORTCUTS
Var OPEN_DOCUMENTATION
Var OPEN_SLIMEVR

# Detected Steam folder
Var STEAMDIR

# Init functions start #
Function .onInit
    ; Clear any cached language selection to force display of language dialog
    DeleteRegValue HKCU "Software\SlimeVR\Installer" "Installer Language"

    ; Display language selection dialog
    !insertmacro MUI_LANGDLL_DISPLAY

    InitPluginsDir
    ${If} ${RunningX64}
        ReadRegStr $0 HKLM SOFTWARE\WOW6432Node\Valve\Steam InstallPath
    ${Else}
        ReadRegStr $0 HKLM SOFTWARE\Valve\Steam InstallPath
    ${EndIf}
    StrCpy $STEAMDIR $0

    ; Get "Public" user profile folder
    StrCpy $0 ""
    System::Call 'shell32::SHGetFolderPathW(i 0, i ${CSIDL_COMMON_DOCUMENTS}, i 0, i 0, t .r0)'
    ${GetParent} $0 $0
    StrCpy $PUBLIC $0

FunctionEnd

!insertmacro ProcessCheck "un." "SteamVRResult"
!insertmacro ProcessCheck "" "SteamVRResult"

# Detect Steam installation and just write path that we need to remove during uninstall (if present)
Function un.onInit
    ; Display language selection dialog for uninstaller
    !insertmacro MUI_UNGETLANGUAGE

    ${If} ${RunningX64}
        ReadRegStr $0 HKLM SOFTWARE\WOW6432Node\Valve\Steam InstallPath
    ${Else}
        ReadRegStr $0 HKLM SOFTWARE\Valve\Steam InstallPath
    ${EndIf}
    StrCpy $STEAMDIR $0
FunctionEnd

# Clean up on exit
Function cleanTemp
    RMDir /r "${SLIMETEMP}"
FunctionEnd

Function .onInstFailed
    ${If} $SELECTED_INSTALLER_ACTION == ""
        Call cleanInstDir
    ${Endif}
FunctionEnd

Function .onGUIEnd
    Call cleanTemp
FunctionEnd

Function cleanInstDir
    Delete "$INSTDIR\uninstall.exe"
    Delete "$INSTDIR\run.bat"
    Delete "$INSTDIR\run.ico"
    Delete "$INSTDIR\slimevr*"
    Delete "$INSTDIR\firewall*.bat"
    Delete "$INSTDIR\MagnetoLib.dll"
    Delete "$INSTDIR\steamvr.ps1"
    Delete "$INSTDIR\log*"
    Delete "$INSTDIR\*.log"
    Delete "$INSTDIR\*.lck"
    Delete "$INSTDIR\vrconfig.yml"
    Delete "$INSTDIR\LICENSE*"

    RMDir /r "$INSTDIR\Recordings"
    RMdir /r "$INSTDIR\jre"
    RMdir /r "$INSTDIR\driver"
    RMDir /r "$INSTDIR\logs"
    RMdir /r "$INSTDIR\Feeder-App"

    RMDir $INSTDIR
FunctionEnd
# Init functions end #

Page Custom startPage startPageLeave

!define MUI_PAGE_CUSTOMFUNCTION_PRE componentsPre
; Customize components page
!define MUI_COMPONENTSPAGE_TEXT_TOP "$(COMPONENTS_PAGE_TEXT_TOP)"
!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_TITLE "$(COMPONENTS_PAGE_TEXT_DESCRIPTION_TITLE)"
!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_INFO "$(COMPONENTS_PAGE_TEXT_DESCRIPTION_INFO)"
!define MUI_PAGE_HEADER_TEXT "$(COMPONENTS_PAGE_TITLE)"
!define MUI_PAGE_HEADER_SUBTEXT "$(COMPONENTS_PAGE_SUBTITLE)"
# !define MUI_PAGE_CUSTOMFUNCTION_SHOW componentsShow
!insertmacro MUI_PAGE_COMPONENTS

; Customize directory page
!define MUI_DIRECTORYPAGE_TEXT_TOP "$(DIRECTORY_PAGE_TEXT_TOP)"
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "$(DIRECTORY_PAGE_TEXT_DESTINATION)"
!define MUI_DIRECTORYPAGE_HEADER_TEXT "$(DIRECTORY_PAGE_TITLE)"
!define MUI_DIRECTORYPAGE_HEADER_SUBTEXT "$(DIRECTORY_PAGE_SUBTITLE)"
!define MUI_PAGE_CUSTOMFUNCTION_PRE installerActionPre
!insertmacro MUI_PAGE_DIRECTORY

; Customize installation page
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "$(INSTFILES_PAGE_TITLE)"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "$(INSTFILES_PAGE_SUBTITLE)"
!define MUI_PAGE_CUSTOMFUNCTION_PRE cleanTemp ; Clean temp on pre-install to avoid any leftover files failing the installation, temp files will be removed in .onGUIEnd
!insertmacro MUI_PAGE_INSTFILES

Page Custom endPage endPageLeave


# Set MUI_UNCONFIMPAGE to get the translations
!insertmacro MUI_SET MUI_UNCONFIRMPAGE ""
UninstPage custom un.startPageConfirm un.endPageunConfirm
!insertmacro MUI_UNPAGE_INSTFILES

; Include language files
!include .\languages\english.nsh
!include .\languages\chinese_simplified.nsh

; Define supported languages
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"

; Reserve files for faster startup
!insertmacro MUI_RESERVEFILE_LANGDLL

Function startPage
    Call UpdateLabelTimer
    !insertmacro MUI_HEADER_TEXT $(START_PAGE_TITLE) $(START_PAGE_SUBTITLE)
    nsDialogs::Create 1018
    Pop $0

    ${If} $0 == error
        Abort
    ${EndIf}

    ReadRegStr $0 HKLM Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR InstallLocation
    ${If} $0 != ""
        StrCpy $INSTDIR $0

        ; Build the message dynamically
        StrCpy $1 "$(EXISTING_INSTALLATION_DETECTED_1)$0$(EXISTING_INSTALLATION_DETECTED_2)"
        ${NSD_CreateLabel} 0 0 100% 20u '$1'
        ${NSD_CreateRadioButton} 0 40u 100% 10u "$(UPDATE_OPTION)"
        Pop $UPDATE
        ${NSD_CreateRadioButton} 0 55u 100% 10u "$(REPAIR_OPTION)"
        Pop $REPAIR

        ${If} $SELECTED_INSTALLER_ACTION == "update"
            SendMessage $UPDATE ${BM_SETCHECK} 1 0
        ${ElseIf} $SELECTED_INSTALLER_ACTION == "repair"
            SendMessage $REPAIR ${BM_SETCHECK} 1 0
        ${Else}
            SendMessage $UPDATE ${BM_SETCHECK} 1 0
        ${EndIf}
    ${Else}
        ${NSD_CreateLabel} 0 0 100% 50u "$(CLICK_NEXT_TO_PROCEED)"
        Pop $0
    ${EndIf}

    ${NSD_CreateLabel} 0 90u 100% 10u '$SteamVRLabelTxt'
    Pop $SteamVRLabelID
    ${NSD_CreateLabel} 0 100u 100% 10u '$SlimeVRLabelTxt'
    Pop $SlimeVRLabelID
    GetFunctionAddress $0 UpdateLabelTimer
    nsDialogs::CreateTimer $0 2000 ; Set the timer interval to 1000 milliseconds (1 second)

    nsDialogs::Show

FunctionEnd

Function startPageLeave
    GetFunctionAddress $0 UpdateLabelTimer
    nsDialogs::KillTimer $0
    ${NSD_GetState} $UPDATE $0
    ${NSD_GetState} $REPAIR $1

    ${If} $0 = 1
        StrCpy $SELECTED_INSTALLER_ACTION "update"
    ${ElseIf} $1 = 1
        StrCpy $SELECTED_INSTALLER_ACTION "repair"
    ${EndIf}

FunctionEnd

Function endPage

    nsDialogs::Create 1018
    Pop $0

    ${If} $0 == error
        Abort
    ${EndIf}

    ${NSD_CreateLabel} 0 0 100% 12u "$(INSTALLATION_FINISHED)"
    Pop $0

    ${NSD_CreateCheckbox} 0 25u 100% 10u "$(OPEN_DOCUMENTATION_TEXT)"
    Pop $OPEN_DOCUMENTATION
    # Don't open documentation if we're updating
    ${If} $SELECTED_INSTALLER_ACTION == ""
        ${NSD_Check} $OPEN_DOCUMENTATION
    ${EndIf}

    ${NSD_CreateCheckbox} 0 40u 100% 10u "$(CREATE_DESKTOP_SHORTCUT_TEXT)"
    Pop $CREATE_DESKTOP_SHORTCUT
    ${NSD_Check} $CREATE_DESKTOP_SHORTCUT

    ${NSD_CreateCheckbox} 0 55u 100% 10u "$(CREATE_STARTMENU_SHORTCUTS_TEXT)"
    Pop $CREATE_STARTMENU_SHORTCUTS
    ${NSD_Check} $CREATE_STARTMENU_SHORTCUTS

    ${NSD_CreateCheckbox} 0 70u 100% 10u "$(OPEN_SLIMEVR_TEXT)"
    Pop $OPEN_SLIMEVR
    ${NSD_Check} $OPEN_SLIMEVR

    nsDialogs::Show

FunctionEnd


Function endPageLeave

    SetOutPath $INSTDIR

    ${NSD_GetState} $CREATE_STARTMENU_SHORTCUTS $0
    ${NSD_GetState} $CREATE_DESKTOP_SHORTCUT $1
    ${NSD_GetState} $OPEN_DOCUMENTATION $2
    ${NSD_GetState} $OPEN_SLIMEVR $3

    ${If} $0 = 1
        CreateDirectory "$SMPROGRAMS\SlimeVR Server"
        CreateShortcut "$SMPROGRAMS\SlimeVR Server\Uninstall SlimeVR Server.lnk" "$INSTDIR\uninstall.exe"
        CreateShortcut "$SMPROGRAMS\SlimeVR Server\SlimeVR Server.lnk" "$INSTDIR\slimevr.exe" ""
    ${Else}
        Delete "$SMPROGRAMS\Uninstall SlimeVR Server.lnk"
        Delete "$SMPROGRAMS\SlimeVR Server.lnk"
        RMdir /r "$SMPROGRAMS\SlimeVR Server"
    ${Endif}

    ${If} $1 = 1
        CreateShortcut "$DESKTOP\SlimeVR Server.lnk" "$INSTDIR\slimevr.exe" ""
    ${Else}
        Delete "$DESKTOP\SlimeVR Server.lnk"
    ${EndIf}

    ${If} $2 = 1
        ExecShell "open" "https://docs.slimevr.dev/quick-setup.html#connecting-and-preparing-your-trackers"
    ${EndIf}

    ${If} $3 = 1
        # use explorer to open it so it inherits the user token and starts as normal user
        Exec '"$WINDIR\explorer.exe" "$INSTDIR\slimevr.exe"'
    ${EndIf}

FunctionEnd

# Pre-hook for directory selection function
Function installerActionPre
    # Skip directory selection if existing installation was detected and user selected an action
    ${If} $SELECTED_INSTALLER_ACTION != ""
        Abort
    ${EndIf}
FunctionEnd

# Provides a easy function to determit if the JRE is the desired Version or not
Function JREdetect
    IfFileExists "$INSTDIR\jre\release" 0 SEC_JRE_JAVAVERSIONELSE
        ${ConfigRead} "$INSTDIR\jre\release" "JAVA_RUNTIME_VERSION=" $R0
;        DetailPrint "Java JRE: $INSTDIR\jre\release JAVA_RUNTIME_VERSION=$R0"
        ${If} $R0 == "$\"${JREVersion}$\""
            StrCpy $JREneedInstall "False"
        ${Else}
            StrCpy $JREneedInstall "True"
        ${EndIf}
        Goto SEC_JRE_JAVAVERSIONDONE
    SEC_JRE_JAVAVERSIONELSE:
        StrCpy $JREneedInstall "True"
;        DetailPrint "Java JRE: $INSTDIR\jre\release File Not Found"
    SEC_JRE_JAVAVERSIONDONE:
FunctionEnd

# GetTime function macro to get datetime
!insertmacro GetTime

Function DumpLog
  Exch $5
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $6

  FindWindow $0 "#32770" "" $HWNDPARENT
  GetDlgItem $0 $0 1016
  StrCmp $0 0 exit
  FileOpen $5 $5 "w"
  StrCmp $5 "" exit
    SendMessage $0 ${LVM_GETITEMCOUNT} 0 0 $6
    System::Alloc ${NSIS_MAX_STRLEN}
    Pop $3
    StrCpy $2 0
    System::Call "*(i, i, i, i, i, i, i, i, i) i \
      (0, 0, 0, 0, 0, r3, ${NSIS_MAX_STRLEN}) .r1"
    loop: StrCmp $2 $6 done
      System::Call "User32::SendMessageA(i, i, i, i) i \
        ($0, ${LVM_GETITEMTEXT}, $2, r1)"
      System::Call "*$3(&t${NSIS_MAX_STRLEN} .r4)"
      FileWrite $5 "$4$\r$\n"
      IntOp $2 $2 + 1
      Goto loop
    done:
      FileClose $5
      System::Free $1
      System::Free $3
  exit:
    Pop $6
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
    Exch $5
FunctionEnd

# Uninstall Confirm Page Clone to add some Labels
Function un.startPageConfirm
    nsDialogs::Create 1018
    Pop $0
    ${If} $0 == error
      Abort
    ${EndIf}

    !insertmacro MUI_HEADER_TEXT $(MUI_UNTEXT_CONFIRM_TITLE) $(MUI_UNTEXT_CONFIRM_SUBTITLE)

    ; Uninstalling Text
    ${NSD_CreateLabel} 0 0 450 30 "$(^UninstallingText)"

    ; Uninstalling Path Text
    ${NSD_CreateLabel} 0 68 98 20 "$(^UninstallingSubText)"

    ; Uninstalling Path
    ${NSD_CreateText} 98 65 350 20 "$INSTDIR"
    Pop $0
    SendMessage $0 ${EM_SETREADONLY} 1 0

    ; Create the SteamVR Warning Label
    ${NSD_CreateLabel} 0 90u 100% 10u '$SteamVRLabelTxt'
    Pop $SteamVRLabelID
    ${NSD_CreateLabel} 0 100u 100% 10u '$SlimeVRLabelTxt'
    Pop $SlimeVRLabelID

    Call un.UpdateLabelTimer
    GetFunctionAddress $0 un.UpdateLabelTimer
    nsDialogs::CreateTimer /NOUNLOAD $0 2000 ; Set the timer interval to 2000 milliseconds (2 second)

    nsDialogs::Show
FunctionEnd

Function un.endPageunConfirm
    GetFunctionAddress $0 un.UpdateLabelTimer
    nsDialogs::KillTimer $0
FunctionEnd

Section "$(COMP_SEC_SERVER)" SEC_SERVER
    SectionIn RO

    DetailPrint "$(INSTALLING_SLIMEVR_SERVER)"
    SetOutPath "${SLIMETEMP}"
    File "offline-files\SlimeVR-win64.zip"
    SetOutPath $INSTDIR

    nsisunz::Unzip "${SLIMETEMP}\SlimeVR-win64.zip" "${SLIMETEMP}\SlimeVR\"
    Pop $0
    DetailPrint "$(UNZIPPING_FINISHED)"

    ${If} $SELECTED_INSTALLER_ACTION == "update"
        Delete "$INSTDIR\slimevr-ui.exe"
    ${EndIf}

    DetailPrint "$(COPYING_SLIMEVR_SERVER)"
    CopyFiles /SILENT "${SLIMETEMP}\SlimeVR\SlimeVR\*" $INSTDIR

    IfFileExists "$INSTDIR\slimevr-ui.exe" found not_found
    found:
        Delete "$INSTDIR\slimevr.exe"
        Rename "$INSTDIR\slimevr-ui.exe" "$INSTDIR\slimevr.exe"
    not_found:

    Delete "$INSTDIR\run.bat"
    Delete "$INSTDIR\run.ico"

    # Create the uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
SectionEnd

Section "$(COMP_SEC_WEBVIEW)" SEC_WEBVIEW
    SectionIn RO
    # Read Only protects it from Installing when it is not needed

    DetailPrint "$(INSTALLING_WEBVIEW2)"
    SetOutPath "${SLIMETEMP}"
    File "offline-files\MicrosoftEdgeWebView2RuntimeInstaller.exe"
    SetOutPath $INSTDIR

    nsExec::ExecToLog '"${SLIMETEMP}\MicrosoftEdgeWebView2RuntimeInstaller.exe" /silent /install' $0
    Pop $0
    DetailPrint "$(INSTALLING_FINISHED)"
    ${If} $0 != 0
        Abort "$(FAILED_INSTALL_WEBVIEW2)"
    ${EndIf}

SectionEnd

Section "$(COMP_SEC_JRE)" SEC_JRE
    SectionIn RO

    DetailPrint "$(INSTALLING_JAVA_JRE)"
    SetOutPath "${SLIMETEMP}"
    File "offline-files\${JREDLFileZip}"
    SetOutPath $INSTDIR

    # Extract the JRE zip file
    nsisunz::Unzip "${SLIMETEMP}\${JREDLFileZip}" "${SLIMETEMP}\OpenJDK\"
    Pop $0
    DetailPrint "$(UNZIPPING_JRE_FINISHED)"

    # Make sure to delete all files on a update from jre, so if there is a new version no old files are left.
    IfFileExists "$INSTDIR\jre" 0 SEC_JRE_DIRNOTFOUND
        DetailPrint "$(REMOVING_OLD_JAVA)"
        RMdir /r "$INSTDIR\jre"
        CreateDirectory "$INSTDIR\jre"
    SEC_JRE_DIRNOTFOUND:
# Todo: Make a better way to copy the jre folder, since the version number is in the folder name
    FindFirst $0 $1 "${SLIMETEMP}\OpenJDK\jdk-17.*-jre"
    loop:
        StrCmp $1 "" done
        CopyFiles /SILENT "${SLIMETEMP}\OpenJDK\$1\*" "$INSTDIR\jre"
        FindNext $0 $1
        Goto loop
    done:
    FindClose $0
SectionEnd

Section "$(COMP_SEC_VRDRIVER)" SEC_VRDRIVER
    DetailPrint "$(INSTALLING_STEAMVR_DRIVER)"
    SetOutPath "${SLIMETEMP}"
    File "offline-files\slimevr-openvr-driver-win64.zip"
    SetOutPath $INSTDIR

    DetailPrint "$(UNPACKING_FILES)"
    nsisunz::Unzip "${SLIMETEMP}\slimevr-openvr-driver-win64.zip" "${SLIMETEMP}\slimevr-openvr-driver-win64\"
    Pop $0
    DetailPrint "$(UNZIPPING_FINISHED)"

    # Include SteamVR powershell script to register/unregister driver
    File "steamvr.ps1"
    File "steamcleanexternaldrivers.ps1"

    DetailPrint "$(REMOVING_OLD_DRIVERS)"
    # If powershell is present - rely on automatic detection.

    ${DisableX64FSRedirection}
    CreateShortcut "$INSTDIR\steamcleanexternaldrivers.lnk" "$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" '-ExecutionPolicy Bypass -WindowStyle Hidden -File "$INSTDIR\steamcleanexternaldrivers.ps1"' "$INSTDIR\steamcleanexternaldrivers.ps1" 0
    Exec "explorer.exe $INSTDIR\steamcleanexternaldrivers.lnk"
    Sleep 5000
    ${EnableX64FSRedirection}
    IfFileExists "$PUBLIC\Documents\SlimeVRUninstall_log.txt" 0 no_log
        FileOpen $1 "$PUBLIC\Documents\SlimeVRUninstall_log.txt" r
        FileRead $1 $2
        DetailPrint "$2"
        FileClose $1
        Delete "$PUBLIC\Documents\SlimeVRUninstall_log.txt"
    no_log:
    Delete "$INSTDIR\steamcleanexternaldrivers.lnk"
    Delete "$INSTDIR\steamcleanexternaldrivers.ps1"

    DetailPrint "$(COPYING_STEAMVR_DRIVER)"
    ${DisableX64FSRedirection}
    nsExec::ExecToLog '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -File "$INSTDIR\steamvr.ps1" -SteamPath "$STEAMDIR" -DriverPath "${SLIMETEMP}\slimevr-openvr-driver-win64\slimevr"' $0
    ${EnableX64FSRedirection}
    Pop $0
    ${If} $0 != 0
        nsDialogs::SelectFolderDialog "$(SPECIFY_STEAMVR_FOLDER)" "$STEAMDIR\steamapps\common\SteamVR"
        Pop $0
        ${If} $0 == "error"
            Abort "$(FAILED_COPY_SLIMEVR_DRIVER)"
        ${Endif}
        CopyFiles /SILENT "${SLIMETEMP}\slimevr-openvr-driver-win64\slimevr" "$0\drivers\slimevr"
    ${EndIf}
SectionEnd

Section "$(COMP_SEC_FEEDER_APP)" SEC_FEEDER_APP
    DetailPrint "$(INSTALLING_SLIMEVR_FEEDER_APP)"
    SetOutPath "${SLIMETEMP}"
    File "offline-files\SlimeVR-Feeder-App-win64.zip"
    SetOutPath $INSTDIR

    DetailPrint "$(UNPACKING_FILES)"
    nsisunz::Unzip "${SLIMETEMP}\SlimeVR-Feeder-App-win64.zip" "${SLIMETEMP}"
    Pop $0
    DetailPrint "$(UNZIPPING_FINISHED)"

    DetailPrint "$(COPYING_SLIMEVR_FEEDER_APP)"
    CopyFiles /SILENT "${SLIMETEMP}\SlimeVR-Feeder-App-win64\*" "$INSTDIR\Feeder-App"

    DetailPrint "$(INSTALLING_SLIMEVR_FEEDER_APP_DRIVER)"
    nsExec::ExecToLog '"$INSTDIR\Feeder-App\SlimeVR-Feeder-App.exe" --install'
SectionEnd

Section "$(COMP_SEC_MSVCPP)" SEC_MSVCPP
    SetOutPath "${SLIMETEMP}"
    DetailPrint "$(INSTALLING_MSVCPP)"
    File "offline-files\vc_redist.x64.exe"
    SetOutPath $INSTDIR

    DetailPrint "$(INSTALLING_MSVCPP)"
    nsExec::ExecToLog '"${SLIMETEMP}\vc_redist.x64.exe" /install /passive /norestart' $0
    Pop $0 ; Status text ("OK" for success)
    ; Handle return codes
    ${If} $0 == 0
        DetailPrint "$(MSVCPP_INSTALLED_SUCCESSFULLY)"
    ${ElseIf} $0 == 3010
        DetailPrint "$(MSVCPP_INSTALLED_REBOOT_REQUIRED)"
        SetRebootFlag true
    ${ElseIf} $0 == 1602
        Abort "$(MSVCPP_USER_CANCELED)"
    ${ElseIf} $0 == 1603
        Abort "$(MSVCPP_FATAL_ERROR)"
    ${ElseIf} $0 == 1618
        Abort "$(MSVCPP_INSTALLATION_IN_PROGRESS)"
    ${ElseIf} $0 == 1638
        DetailPrint "$(MSVCPP_ALREADY_INSTALLED)"
    ${ElseIf} $0 == 1641
        DetailPrint "$(MSVCPP_INSTALLED_RESTART_HAPPENING)"
    ${ElseIf} $0 == 5100
        Abort "$(MSVCPP_UNSUPPORTED_OS)"
    ${Else}
        Abort "$(MSVCPP_UNKNOWN_ERROR)"
    ${EndIf}
SectionEnd

SectionGroup /e "$(COMP_SEC_USBDRIVERS)" SEC_USBDRIVERS

    Section "$(COMP_SEC_CP210X)" SEC_CP210X
        # CP210X drivers (NodeMCU v2)
        SetOutPath "${SLIMETEMP}\slimevr_usb_drivers_inst\CP201x"
        DetailPrint "$(INSTALLING_CP210X_DRIVER)"
        File /r "CP201x\*"
        ${DisableX64FSRedirection}
        nsExec::Exec '"$SYSDIR\PnPutil.exe" -i -a "${SLIMETEMP}\slimevr_usb_drivers_inst\CP201x\silabser.inf"' $0
        ${EnableX64FSRedirection}
        Pop $0
        ${If} $0 == 0
            DetailPrint "$(DRIVER_INSTALL_SUCCESS)"
        ${ElseIf} $0 == 259
            DetailPrint "$(DRIVER_NO_DEVICES_MATCH)"
        ${ElseIf} $0 == 3010
            DetailPrint "$(DRIVER_REBOOT_REQUIRED)"
        ${Else}
            Abort "$(FAILED_INSTALL_CP210X_DRIVER)"
        ${Endif}
    SectionEnd

    Section "$(COMP_SEC_CH340)" SEC_CH340
        # CH340 drivers (NodeMCU v3)
        SetOutPath "${SLIMETEMP}\slimevr_usb_drivers_inst\CH341SER"
        DetailPrint "$(INSTALLING_CH340_DRIVER)"
        File /r "CH341SER\*"
        ${DisableX64FSRedirection}
        nsExec::Exec '"$SYSDIR\PnPutil.exe" -i -a "${SLIMETEMP}\slimevr_usb_drivers_inst\CH341SER\CH341SER.INF"' $0
        ${EnableX64FSRedirection}
        Pop $0
        ${If} $0 == 0
            DetailPrint "$(DRIVER_INSTALL_SUCCESS)"
        ${ElseIf} $0 == 259
            DetailPrint "$(DRIVER_NO_DEVICES_MATCH)"
        ${ElseIf} $0 == 3010
            DetailPrint "$(DRIVER_REBOOT_REQUIRED)"
        ${Else}
            Abort "$(FAILED_INSTALL_CH340_DRIVER)"
        ${Endif}
    SectionEnd

    Section /o "$(COMP_SEC_CH9102X)" SEC_CH9102X
        # CH343 drivers (NodeMCU v2.1, some NodeMCU v3?)
        SetOutPath "${SLIMETEMP}\slimevr_usb_drivers_inst\CH343SER"
        DetailPrint "$(INSTALLING_CH910X_DRIVER)"
        File /r "CH343SER\*"
        ${DisableX64FSRedirection}
        nsExec::Exec '"$SYSDIR\PnPutil.exe" -i -a "${SLIMETEMP}\slimevr_usb_drivers_inst\CH343SER\CH343SER.INF"' $0
        ${EnableX64FSRedirection}
        Pop $0
        ${If} $0 == 0
            DetailPrint "$(DRIVER_INSTALL_SUCCESS)"
        ${ElseIf} $0 == 259
            DetailPrint "$(DRIVER_NO_DEVICES_MATCH)"
        ${ElseIf} $0 == 3010
            DetailPrint "$(DRIVER_REBOOT_REQUIRED)"
        ${Else}
            Abort "$(FAILED_INSTALL_CH910X_DRIVER)"
        ${Endif}
    SectionEnd

SectionGroupEnd

Section "-" SEC_FIREWALL
    ${If} $SELECTED_INSTALLER_ACTION == "repair"
        ${OrIf} $SELECTED_INSTALLER_ACTION == "update"
        DetailPrint "$(REMOVING_FIREWALL_EXCEPTION)"
        nsExec::ExecToLog '"$INSTDIR\firewall_uninstall.bat"'
    ${Endif}

    DetailPrint "$(ADDING_FIREWALL_EXCEPTION)"
    nsExec::ExecToLog '"$INSTDIR\firewall.bat"'
SectionEnd

Section "-" SEC_REGISTERAPP
    DetailPrint "$(REGISTERING_INSTALLATION)"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "DisplayName" "SlimeVR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "DisplayIcon" "$INSTDIR\slimevr.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "HelpLink" "https://docs.slimevr.dev/"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "URLInfoAbout" "https://slimevr.dev/"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "URLUpdateInfo" "https://github.com/SlimeVR/SlimeVR-Installer/releases"
SectionEnd

Section
    # Grant all users full access to the installation folder to avoid using elevated rights
    # when installing to folders with limited access
    AccessControl::GrantOnFile $INSTDIR "(BU)" "FullAccess"
    Pop $0

    # Add/update installation date
    ${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR" \
                    "InstallDate" "$2$1$0"

    # Write install.log
    StrCpy $0 "$INSTDIR\install.log"
    Push $0
    Call DumpLog
SectionEnd

Function componentsPre
    Call JREdetect
    ${If} $SELECTED_INSTALLER_ACTION == "update"
        SectionSetFlags ${SEC_FIREWALL} ${SF_SELECTED}
        SectionSetFlags ${SEC_REGISTERAPP} 0
        SectionSetFlags ${SEC_WEBVIEW} ${SF_SELECTED}
        SectionSetFlags ${SEC_MSVCPP} ${SF_SELECTED}
        SectionSetFlags ${SEC_USBDRIVERS} ${SF_SECGRP}
        SectionSetFlags ${SEC_SERVER} ${SF_SELECTED}
    ${EndIf}
    ${If} $STEAMDIR == ""
        MessageBox MB_OK $(DESC_STEAM_NOTFOUND)
        SectionSetFlags ${SEC_VRDRIVER} ${SF_USELECTED}|${SF_RO}
        SectionSetFlags ${SEC_FEEDER_APP} ${SF_USELECTED}|${SF_RO}
        SectionSetFlags ${SEC_MSVCPP} ${SF_USELECTED}|${SF_RO}
    ${Else}
        SectionSetFlags ${SEC_VRDRIVER} ${SF_SELECTED}
        SectionSetFlags ${SEC_FEEDER_APP} ${SF_SELECTED}
        SectionSetFlags ${SEC_MSVCPP} ${SF_SELECTED}|${SF_RO}
    ${EndIf}

    # Select JRE Mandatory if not found or outdated on Repair Preselect it
    ${If} $JREneedInstall == "True"
        SectionSetFlags ${SEC_JRE} ${SF_SELECTED}|${SF_RO}
    ${ElseIf} $SELECTED_INSTALLER_ACTION == "repair"
        SectionSetFlags ${SEC_JRE} ${SF_SELECTED}
    ${Else}
        SectionSetFlags ${SEC_JRE} ${SF_USELECTED}
    ${EndIf}

    # Detect WebView2
    # https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution#detect-if-a-suitable-webview2-runtime-is-already-installed
    # Trying to solve #41 Installer doesn't always install WebView2
    # Ignoring only user installed WebView2 it seems to make problems
    ${If} ${RunningX64}
        ReadRegStr $0 HKLM "SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" "pv"
        ReadRegStr $1 HKCU "Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" "pv"
    ${Else}
        ReadRegStr $0 HKLM "SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" "pv"
        ReadRegStr $1 HKCU "Software\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" "pv"
    ${EndIf}

    ${If} $0 == ""
    ${OrIf} $0 == "0.0.0.0"
        StrCpy $0 ""
    ${Else}
        StrCpy $0 "1"
    ${EndIf}

    ${If} $1 == ""
    ${OrIf} $1 == "0.0.0.0"
        StrCpy $1 ""
    ${Else}
        StrCpy $1 "1"
    ${EndIf}

    ${If} $0 == ""
    ${AndIf} $1 == ""
        SectionSetFlags ${SEC_WEBVIEW} ${SF_SELECTED}|${SF_RO}
    ${Else}
        SectionSetFlags ${SEC_WEBVIEW} ${SF_USELECTED}
    ${EndIf}
FunctionEnd

Function .onSelChange
    SectionGetFlags ${SEC_VRDRIVER} $0
    IntOp $0 $0 & ${SF_SELECTED}
    SectionGetFlags ${SEC_FEEDER_APP} $1
    IntOp $1 $1 & ${SF_SELECTED}
    IntOp $0 $0 | $1
    ${If} $0 == ${SF_SELECTED}
        SectionSetFlags ${SEC_MSVCPP} ${SF_SELECTED}|${SF_RO}
    ${Else}
        SectionSetFlags ${SEC_MSVCPP} ${SF_USELECTED}|${SF_RO}
    ${EndIf}
FunctionEnd

Section "-un.SlimeVR Server" un.SEC_SERVER
    # Remove the shortcuts
    RMdir /r "$SMPROGRAMS\SlimeVR Server"
    # Remove separate shortcuts introduced with first release
    Delete "$SMPROGRAMS\Uninstall SlimeVR Server.lnk"
    Delete "$SMPROGRAMS\SlimeVR Server.lnk"
    Delete "$DESKTOP\SlimeVR Server.lnk"
    Delete "$INSTDIR\slimevr-ui.exe"
    Delete "$INSTDIR\run.bat"
    Delete "$INSTDIR\run.ico"
    # Ignore errors on the files above, they are optional to remove and may not even exist
    ClearErrors
    Delete "$INSTDIR\slimevr*"
    Delete "$INSTDIR\MagnetoLib.dll"
    Delete "$INSTDIR\log*"
    Delete "$INSTDIR\*.log"
    Delete "$INSTDIR\*.lck"
    Delete "$INSTDIR\vrconfig.yml"
    Delete "$INSTDIR\LICENSE*"
    Delete "$INSTDIR\ThirdPartyNotices.txt"

    RMDir /r "$INSTDIR\Recordings"
    RMdir /r "$INSTDIR\jre"
    RMDir /r "$INSTDIR\logs"

    IfErrors fail success
    fail:
        Abort "$(FAILED_REMOVE_SLIMEVR_SERVER)"
    success:
SectionEnd

Section "-un.SteamVR Driver" un.SEC_VRDRIVER
    ${DisableX64FSRedirection}
    nsExec::ExecToLog '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -File "$INSTDIR\steamvr.ps1" -SteamPath "$STEAMDIR" -DriverPath "slimevr" -Uninstall' $0
    ${EnableX64FSRedirection}
    Pop $0
    ${If} $0 != 0
        DetailPrint "$(FAILED_REMOVE_STEAMVR_DRIVER)"
    ${EndIf}
    Delete "$INSTDIR\steamvr.ps1"
SectionEnd

Section "-un.SlimeVR Feeder App" un.SEC_FEEDER_APP
    IfFileExists "$INSTDIR\Feeder-App\SlimeVR-Feeder-App.exe" found not_found
    found:
        DetailPrint "$(UNREGISTERING_SLIMEVR_FEEDER_APP_DRIVER)"
        nsExec::ExecToLog '"$INSTDIR\Feeder-App\SlimeVR-Feeder-App.exe" --uninstall'
        DetailPrint "$(REMOVING_SLIMEVR_FEEDER_APP)"
        RMdir /r "$INSTDIR\Feeder-App"
    not_found:
SectionEnd

Section "-un." un.SEC_FIREWALL
    DetailPrint "$(REMOVING_FIREWALL_EXCEPTION)"
    nsExec::Exec '"$INSTDIR\firewall_uninstall.bat"'
    Pop $0
    Delete "$INSTDIR\firewall*.bat"
SectionEnd

Section "-un." un.SEC_POST_UNINSTALL
    DetailPrint "$(UNREGISTERING_INSTALLATION)"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SlimeVR"
    Delete "$INSTDIR\uninstall.exe"
    RMDir $INSTDIR
    DetailPrint "$(UNINSTALL_DONE)"
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_SERVER} $(DESC_SEC_SERVER)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_JRE} $(DESC_SEC_JRE)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_WEBVIEW} $(DESC_SEC_WEBVIEW)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_VRDRIVER} $(DESC_SEC_VRDRIVER)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_FEEDER_APP} $(DESC_SEC_FEEDER_APP)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MSVCPP} $(DESC_SEC_MSVCPP)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_USBDRIVERS} $(DESC_SEC_USBDRIVERS)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_CP210X} $(DESC_SEC_CP210X)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_CH340} $(DESC_SEC_CH340)
    !insertmacro MUI_DESCRIPTION_TEXT ${SEC_CH9102X} $(DESC_SEC_CH9102x)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
