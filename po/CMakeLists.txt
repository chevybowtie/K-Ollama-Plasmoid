# Translation handling for K-Ollama-Plasmoid
# This file handles automatic extraction, compilation, and installation of translations

# Find gettext tools
find_package(Gettext REQUIRED)

# Set the domain name (should match your plasmoid identifier)
set(TRANSLATION_DOMAIN "K-Ollama-Plasmoid")

# Define source directories to scan for translatable strings
set(SOURCE_DIRS 
    ${CMAKE_SOURCE_DIR}/contents/config
    ${CMAKE_SOURCE_DIR}/contents/ui
)

# Find all QML files that contain translatable strings
file(GLOB_RECURSE QML_SOURCES 
    ${CMAKE_SOURCE_DIR}/contents/config/*.qml
    ${CMAKE_SOURCE_DIR}/contents/ui/*.qml
)

# Custom target to extract translatable strings
add_custom_target(extract-messages
    COMMENT "Extracting translatable messages from QML files"
    COMMAND xgettext 
        --language=JavaScript
        --keyword=i18n
        --keyword=i18nc:1c,2
        --keyword=i18np:1,2  
        --keyword=i18ncp:1c,2,3
        --from-code=UTF-8
        --output=${CMAKE_CURRENT_SOURCE_DIR}/${TRANSLATION_DOMAIN}.pot
        ${QML_SOURCES}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

# Find all .po files
file(GLOB PO_FILES "${CMAKE_CURRENT_SOURCE_DIR}/*.po")

# Process each .po file
foreach(po_file ${PO_FILES})
    # Get language code from filename (e.g., es.po -> es)
    get_filename_component(lang ${po_file} NAME_WE)
    
    # Set output .mo file location
    set(mo_file "${CMAKE_CURRENT_BINARY_DIR}/${lang}.mo")
    
    # Add custom command to compile .po to .mo
    add_custom_command(
        OUTPUT ${mo_file}
        COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} -o ${mo_file} ${po_file}
        DEPENDS ${po_file}
        COMMENT "Compiling translation for ${lang}"
    )
    
    # Install the .mo file
    install(FILES ${mo_file}
        DESTINATION ${LOCALE_INSTALL_DIR}/${lang}/LC_MESSAGES
        RENAME ${TRANSLATION_DOMAIN}.mo
    )
    
    # Add to list of generated files
    list(APPEND mo_files ${mo_file})
endforeach()

# Create target that depends on all .mo files
if(mo_files)
    add_custom_target(translations ALL DEPENDS ${mo_files})
endif()

# Optional: Create update-translations target to update existing .po files from .pot
if(PO_FILES)
    add_custom_target(update-translations
        COMMENT "Updating translation files from template"
        DEPENDS extract-messages
    )
    
    foreach(po_file ${PO_FILES})
        get_filename_component(lang ${po_file} NAME_WE)
        add_custom_command(TARGET update-translations POST_BUILD
            COMMAND ${GETTEXT_MSGMERGE_EXECUTABLE} 
                --update 
                --backup=none
                ${po_file} 
                ${CMAKE_CURRENT_SOURCE_DIR}/${TRANSLATION_DOMAIN}.pot
            COMMENT "Updating ${lang}.po"
        )
    endforeach()
endif()

# Print summary of found translations
message(STATUS "Found translation files:")
foreach(po_file ${PO_FILES})
    get_filename_component(lang ${po_file} NAME_WE)
    message(STATUS "  - ${lang}")
endforeach()