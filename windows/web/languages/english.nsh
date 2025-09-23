; English Language Strings for SlimeVR Installer
; This file contains all English text used in the installer

; Page titles and subtitles
LangString START_PAGE_TITLE ${LANG_ENGLISH} "Welcome"
LangString START_PAGE_SUBTITLE ${LANG_ENGLISH} "Welcome to SlimeVR Setup!"

; Components page customization
LangString COMPONENTS_PAGE_TITLE ${LANG_ENGLISH} "Choose Components"
LangString COMPONENTS_PAGE_SUBTITLE ${LANG_ENGLISH} "Choose which features of SlimeVR you want to install"
LangString COMPONENTS_PAGE_TEXT_TOP ${LANG_ENGLISH} "Check the components you want to install and uncheck the components you don't want to install. Click Next to continue."
LangString COMPONENTS_PAGE_TEXT_DESCRIPTION_TITLE ${LANG_ENGLISH} "Description"
LangString COMPONENTS_PAGE_TEXT_DESCRIPTION_INFO ${LANG_ENGLISH} "Position your mouse over a component to see its description."

; Directory page customization
LangString DIRECTORY_PAGE_TITLE ${LANG_ENGLISH} "Choose Install Location"
LangString DIRECTORY_PAGE_SUBTITLE ${LANG_ENGLISH} "Choose the folder in which to install SlimeVR"
LangString DIRECTORY_PAGE_TEXT_TOP ${LANG_ENGLISH} "Setup will install SlimeVR in the following folder. To install in a different folder, click Browse and select another folder. Click Next to continue."
LangString DIRECTORY_PAGE_TEXT_DESTINATION ${LANG_ENGLISH} "Destination Folder"

; Installation page customization
LangString INSTFILES_PAGE_TITLE ${LANG_ENGLISH} "Installing"
LangString INSTFILES_PAGE_SUBTITLE ${LANG_ENGLISH} "Installing SlimeVR"; Installation UI text
LangString EXISTING_INSTALLATION_DETECTED_1 ${LANG_ENGLISH} "An existing installation was detected in "
LangString EXISTING_INSTALLATION_DETECTED_2 ${LANG_ENGLISH} ". Choose an option and click Next to proceed."
LangString CLICK_NEXT_TO_PROCEED ${LANG_ENGLISH} "Click Next to proceed with installation."
LangString INSTALLATION_FINISHED ${LANG_ENGLISH} "The installation is finished!"
LangString UPDATE_OPTION ${LANG_ENGLISH} "Update"
LangString REPAIR_OPTION ${LANG_ENGLISH} "Repair"

; Installation progress messages
LangString INSTALLING_SLIMEVR_SERVER ${LANG_ENGLISH} "Installing SlimeVR Server..."
LangString INSTALLING_WEBVIEW2 ${LANG_ENGLISH} "Installing webview2!"
LangString INSTALLING_JAVA_JRE ${LANG_ENGLISH} "Installing Java JRE ${JREVersion}..."
LangString INSTALLING_STEAMVR_DRIVER ${LANG_ENGLISH} "Installing SteamVR Driver..."
LangString UNPACKING_FILES ${LANG_ENGLISH} "Unpacking files..."
LangString UNZIPPING_FINISHED ${LANG_ENGLISH} "Unzipping finished with $0."
LangString INSTALLING_FINISHED ${LANG_ENGLISH} "Installing finished with $0."
LangString COPYING_SLIMEVR_SERVER ${LANG_ENGLISH} "Copying SlimeVR Server to installation folder..."
LangString REMOVING_OLD_JAVA ${LANG_ENGLISH} "Removing old Java JRE..."
LangString REMOVING_OLD_DRIVERS ${LANG_ENGLISH} "Removing old external drivers in SteamVR Config..."
LangString COPYING_STEAMVR_DRIVER ${LANG_ENGLISH} "Copying SteamVR Driver to SteamVR..."
LangString UNZIPPING_JRE_FINISHED ${LANG_ENGLISH} "Unzipping JRE finished with $0."

; Uninstall messages
LangString UNREGISTERING_INSTALLATION ${LANG_ENGLISH} "Unregistering installation..."
LangString UNINSTALL_DONE ${LANG_ENGLISH} "Done."

; Firewall messages
LangString ADDING_FIREWALL_EXCEPTION ${LANG_ENGLISH} "Adding SlimeVR Server to firewall exceptions...."
LangString REMOVING_FIREWALL_EXCEPTION ${LANG_ENGLISH} "Removing SlimeVR Server from firewall exceptions...."
LangString REGISTERING_INSTALLATION ${LANG_ENGLISH} "Registering installation..."

; Component descriptions
LangString DESC_SEC_SERVER ${LANG_ENGLISH} "Installs latest SlimeVR Server."
LangString DESC_SEC_JRE ${LANG_ENGLISH} "Copies Java JRE 17 to installation folder. Required for SlimeVR Server."
LangString DESC_SEC_WEBVIEW ${LANG_ENGLISH} "Installs Webview2 if not already installed. Required for the SlimeVR GUI"
LangString DESC_SEC_VRDRIVER ${LANG_ENGLISH} "Installs latest SteamVR Driver for SlimeVR."
LangString DESC_SEC_USBDRIVERS ${LANG_ENGLISH} "A list of USB drivers that are used by various boards."
LangString DESC_SEC_FEEDER_APP ${LANG_ENGLISH} "Installs SlimeVR Feeder App that sends position of SteamVR trackers (Vive trackers, controllers) to SlimeVR Server. Required for elbow tracking."
LangString DESC_SEC_MSVCPP ${LANG_ENGLISH} "Installs the latest Microsoft Visual C++ Redistributable Version (required by the SteamVR Driver and the SlimeVR Feeder)"
LangString DESC_SEC_CP210X ${LANG_ENGLISH} "Installs CP210X USB driver that comes with the following boards: NodeMCU v2, Wemos D1 Mini."
LangString DESC_SEC_CH340 ${LANG_ENGLISH} "Installs CH340 USB driver that comes with the following boards: NodeMCU v3, SlimeVR, Wemos D1 Mini."
LangString DESC_SEC_CH9102x ${LANG_ENGLISH} "Installs CH9102x USB driver that comes with the following boards: NodeMCU v2.1."

; Status and error messages
LangString DESC_STEAM_NOTFOUND ${LANG_ENGLISH} "No Steam installation detected. Steam and SteamVR are required to be installed and run at least once to install the SteamVR Driver."
LangString DESC_STEAMVR_RUNNING ${LANG_ENGLISH} "SteamVR is running! Please close SteamVR."
LangString DESC_SLIMEVR_RUNNING ${LANG_ENGLISH} "SlimeVR is running! Please close SlimeVR."
LangString DESC_PROCESS_ERROR ${LANG_ENGLISH} "An error happend while trying for look for $0 nsProcess::FindProcess Returns "

; Component names for installation
LangString COMP_SEC_SERVER ${LANG_ENGLISH} "SlimeVR Server"
LangString COMP_SEC_WEBVIEW ${LANG_ENGLISH} "Webview2"
LangString COMP_SEC_JRE ${LANG_ENGLISH} "Java JRE"
LangString COMP_SEC_VRDRIVER ${LANG_ENGLISH} "SteamVR Driver"
LangString COMP_SEC_FEEDER_APP ${LANG_ENGLISH} "SlimeVR Feeder App"
LangString COMP_SEC_MSVCPP ${LANG_ENGLISH} "Microsoft Visual C++ Redistributable"
LangString COMP_SEC_USBDRIVERS ${LANG_ENGLISH} "USB drivers"
LangString COMP_SEC_CP210X ${LANG_ENGLISH} "CP210x driver"
LangString COMP_SEC_CH340 ${LANG_ENGLISH} "CH340 driver"
LangString COMP_SEC_CH9102X ${LANG_ENGLISH} "CH9102x driver"

; End page options
LangString CREATE_DESKTOP_SHORTCUT_TEXT ${LANG_ENGLISH} "Create desktop shortcut"
LangString CREATE_STARTMENU_SHORTCUTS_TEXT ${LANG_ENGLISH} "Create Start Menu shortcuts"
LangString OPEN_DOCUMENTATION_TEXT ${LANG_ENGLISH} "Open SlimeVR Quick setup guide"
LangString OPEN_SLIMEVR_TEXT ${LANG_ENGLISH} "Open SlimeVR Server"

; Feeder App installation messages
LangString INSTALLING_SLIMEVR_FEEDER_APP ${LANG_ENGLISH} "Installing SlimeVR Feeder App..."
LangString COPYING_SLIMEVR_FEEDER_APP ${LANG_ENGLISH} "Copying SlimeVR Feeder App..."
LangString INSTALLING_SLIMEVR_FEEDER_APP_DRIVER ${LANG_ENGLISH} "Installing SlimeVR Feeder App driver..."

; Microsoft Visual C++ Redistributable messages
LangString INSTALLING_MSVCPP ${LANG_ENGLISH} "Installing Microsoft Visual C++ Redistributable..."
LangString MSVCPP_INSTALLED_SUCCESSFULLY ${LANG_ENGLISH} "Microsoft Visual C++ Redistributable installed successfully."
LangString MSVCPP_INSTALLED_REBOOT_REQUIRED ${LANG_ENGLISH} "Microsoft Visual C++ Redistributable installed successfully, but a reboot is required."
LangString MSVCPP_USER_CANCELED ${LANG_ENGLISH} "User canceled the Microsoft Visual C++ Redistributable installation."
LangString MSVCPP_FATAL_ERROR ${LANG_ENGLISH} "Fatal error during Microsoft Visual C++ Redistributable installation."
LangString MSVCPP_INSTALLATION_IN_PROGRESS ${LANG_ENGLISH} "Installation aborted: Another installation is in progress."
LangString MSVCPP_ALREADY_INSTALLED ${LANG_ENGLISH} "Microsoft Visual C++ Redistributable is already installed or a newer version is present."
LangString MSVCPP_INSTALLED_RESTART_HAPPENING ${LANG_ENGLISH} "Microsoft Visual C++ Redistributable installed successfully, and a system restart is happening."
LangString MSVCPP_UNSUPPORTED_OS ${LANG_ENGLISH} "Installation failed: Unsupported operating system."
LangString MSVCPP_UNKNOWN_ERROR ${LANG_ENGLISH} "Microsoft Visual C++ Redistributable installation failed with unknown error code: $0"

; USB Driver installation messages
LangString INSTALLING_CP210X_DRIVER ${LANG_ENGLISH} "Installing CP210x driver..."
LangString INSTALLING_CH340_DRIVER ${LANG_ENGLISH} "Installing CH340 driver..."
LangString INSTALLING_CH910X_DRIVER ${LANG_ENGLISH} "Installing CH910x driver..."
LangString DRIVER_INSTALL_SUCCESS ${LANG_ENGLISH} "Success!"
LangString DRIVER_NO_DEVICES_MATCH ${LANG_ENGLISH} "No devices match the supplied driver or the target device is already using a better or newer driver than the driver specified for installation."
LangString DRIVER_REBOOT_REQUIRED ${LANG_ENGLISH} "The requested operation completed successfully and a system reboot is required."
LangString FAILED_INSTALL_CP210X_DRIVER ${LANG_ENGLISH} "Failed to install CP210x driver. Error code: $0."
LangString FAILED_INSTALL_CH340_DRIVER ${LANG_ENGLISH} "Failed to install CH340 driver. Error code: $0."
LangString FAILED_INSTALL_CH910X_DRIVER ${LANG_ENGLISH} "Failed to install CH910x driver. Error code: $0."

; Uninstall messages
LangString FAILED_REMOVE_SLIMEVR_SERVER ${LANG_ENGLISH} "Failed to remove SlimeVR Server files. Make sure SlimeVR Server is closed."
LangString FAILED_REMOVE_STEAMVR_DRIVER ${LANG_ENGLISH} "Failed to remove SteamVR Driver."
LangString UNREGISTERING_SLIMEVR_FEEDER_APP_DRIVER ${LANG_ENGLISH} "Unregistering SlimeVR Feeder App driver..."
LangString REMOVING_SLIMEVR_FEEDER_APP ${LANG_ENGLISH} "Removing SlimeVR Feeder App..."

; Error messages
LangString FAILED_INSTALL_WEBVIEW2 ${LANG_ENGLISH} "Failed to install webview 2"
LangString FAILED_COPY_SLIMEVR_DRIVER ${LANG_ENGLISH} "Failed to copy SlimeVR Driver."
LangString SPECIFY_STEAMVR_FOLDER ${LANG_ENGLISH} "Specify a path to your SteamVR folder"

; Download and file operation messages
LangString DOWNLOADING ${LANG_ENGLISH} "Downloading"
LangString DOWNLOADED ${LANG_ENGLISH} "Downloaded!"
LangString FAILED_TO_DOWNLOAD ${LANG_ENGLISH} "Failed to download"
LangString REASON ${LANG_ENGLISH} "Reason:"
LangString USING_BUNDLED ${LANG_ENGLISH} "Using bundled"
LangString FAILED_TO_PLACE_BUNDLED ${LANG_ENGLISH} "Failed to place bundled"
LangString AT ${LANG_ENGLISH} "at"
LangString BUNDLED_FILE_READY ${LANG_ENGLISH} "Bundled file ready:"
LangString UNKNOWN_SOURCE_TYPE ${LANG_ENGLISH} "dlFile: Unknown source_type"
LangString USE_URL_OR_LOCAL ${LANG_ENGLISH} "Use 'url' or 'local'."
LangString UNZIPPING_TO_INSTALLATION_FOLDER ${LANG_ENGLISH} "Unzipping"
LangString TO_INSTALLATION_FOLDER ${LANG_ENGLISH} "to installation folder...."
LangString FAILED_TO_UNZIP ${LANG_ENGLISH} "Failed to unzip"
LangString SOURCE ${LANG_ENGLISH} "Source:"
LangString TARGET ${LANG_ENGLISH} "Target:"
LangString UNZIPPED ${LANG_ENGLISH} "Unzipped"
