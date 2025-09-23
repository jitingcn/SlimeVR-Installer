; Macro: dlFile
; Downloads a file from a URL or extracts a local file to ${SLIMETEMP}, based on source_type.
; Parameters:
;   source_type - "url" to download, "local" to extract from local file (embedded in installer)
;   name        - Display name of the file (for user messages)
;   version     - Version string (for user messages)
;   url_or_path - URL to download from (if source_type is "url"), or local file path (if "local")
;   local_file  - File name to save as in ${SLIMETEMP} (e.g., "archive.zip")
; Notes:
;   - If source_type is "url", uses NScurl::http with /CANCEL and /RESUME; pops status text into $0 ("OK" on success)
;   - If source_type is "local", embeds the file at compile time and extracts it to ${SLIMETEMP} at install time
;   - Call unzipFile separately to extract the downloaded or copied archive
; Example:
;   !insertmacro dlFile "url" "Java JRE" "17.0.15+6" "https://example.com/jre.zip" "jre.zip"
;   !insertmacro dlFile "local" "Java JRE" "17.0.15+6" "assets\\jre.zip" "jre.zip"
!macro dlFile source_type name version url_or_path local_file
    !if "${source_type}" == "url"
        DetailPrint "$(DOWNLOADING) ${name} ${version}..."
        NScurl::http GET "${url_or_path}" "${SLIMETEMP}\${local_file}" /CANCEL /RESUME /END
        Pop $0 ; Status text ("OK" for success)
        ${If} $0 != "OK"
            Abort "$(FAILED_TO_DOWNLOAD) ${name} ${version}. $(REASON) $0."
        ${EndIf}
        DetailPrint "$(DOWNLOADED)"
    !else
        !if "${source_type}" == "local"
            DetailPrint "$(USING_BUNDLED) ${name} ${version}..."
            Push $0
            StrCpy $0 $OUTDIR
            CreateDirectory "${SLIMETEMP}"
            SetOutPath "${SLIMETEMP}"
            File "/oname=${local_file}" "${url_or_path}"
            SetOutPath $0
            Pop $0
            IfFileExists "${SLIMETEMP}\${local_file}" +2 0
                Abort "$(FAILED_TO_PLACE_BUNDLED) ${name} ${version} $(AT) ${SLIMETEMP}\\${local_file}."
            DetailPrint "$(BUNDLED_FILE_READY) ${SLIMETEMP}\\${local_file}"
        !else
            Abort "$(UNKNOWN_SOURCE_TYPE) '${source_type}'. $(USE_URL_OR_LOCAL)"
        !endif
    !endif
!macroend



; Macro: unzipFile
; Extracts a ZIP archive from the temporary installer directory into a target subdirectory.
; Parameters:
;   name       - Friendly display name shown in the log (e.g., "Java JRE")
;   version    - Version label shown in the log (e.g., "17.0.15+6" or "latest")
;   local_file - ZIP file name located (e.g., "${SLIMETEMP}\archive.zip")
;   local_dir  - Destination directory name to extract into
;                (e.g., "${SLIMETEMP}\OpenJDK\" -> extracts to "${SLIMETEMP}\OpenJDK\...")
; Behavior:
;   - Logs start/end messages with DetailPrint
;   - Calls Nsisunz plugin to unzip: nsisunz::Unzip "${local_file}" "${local_dir}"
;   - Pops plugin return value into $0 (status depends on plugin build)
; Requirements:
;   - Nsisunz plugin must be available via !AddPluginDir
; Notes:
;   - This macro does not validate the unzip result; add checks after calling if needed.
; Example:
;   !insertmacro unzipFile "Java JRE" "${JREVersion}" "${JREDownloadedFileZip}" "OpenJDK"
!macro unzipFile name version local_file local_dir

    DetailPrint "$(UNZIPPING_TO_INSTALLATION_FOLDER) ${name} ${version} $(TO_INSTALLATION_FOLDER)"
    nsisunz::Unzip "${local_file}" "${local_dir}"
    Pop $0
    StrCmp $0 "success" ok
        Abort "$(FAILED_TO_UNZIP) ${name} ${version}. $(SOURCE) ${local_file} $(TARGET) ${local_dir} $(REASON) $0."
    ok:
    DetailPrint "$(UNZIPPED) ${name} ${version}."

!macroend
