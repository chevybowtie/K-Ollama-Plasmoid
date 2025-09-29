cmake_minimum_required(VERSION 3.16)

project(K-Ollama-Plasmoid VERSION 1.0.0)

# Set install directories (can be overridden)
if(NOT DEFINED PLASMOID_INSTALL_DIR)
    set(PLASMOID_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/share/plasma/plasmoids")
endif()

if(NOT DEFINED LOCALE_INSTALL_DIR)
    set(LOCALE_INSTALL_DIR "${CMAKE_INSTALL_PREFIX}/share/locale")
endif()

# Add subdirectories
add_subdirectory(po)

# Install plasmoid contents
install(DIRECTORY contents/
    DESTINATION ${PLASMOID_INSTALL_DIR}/org.kde.K-Ollama-Plasmoid
    FILES_MATCHING 
    PATTERN "*.qml"
    PATTERN "*.js" 
    PATTERN "*.svg"
    PATTERN "*.wav"
    PATTERN "*.xml"
)

# Install metadata
install(FILES metadata.json 
    DESTINATION ${PLASMOID_INSTALL_DIR}/org.kde.K-Ollama-Plasmoid
)

# Print installation summary
message(STATUS "Installation directories:")
message(STATUS "  Plasmoid: ${PLASMOID_INSTALL_DIR}/org.kde.K-Ollama-Plasmoid")
message(STATUS "  Locale: ${LOCALE_INSTALL_DIR}")