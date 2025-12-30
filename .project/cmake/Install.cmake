function(fi_set_sub_packages return)
    file(GLOB subfolders RELATIVE ${CMAKE_CURRENT_BINARY_DIR} LIST_DIRECTORIES true CONFIGURE_DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/*")
    foreach(folder IN LISTS subfolders)
        cmake_path(GET folder STEM name)
        if(EXISTS "${CMAKE_CURRENT_BINARY_DIR}/${folder}/${name}Config.cmake")
            list(APPEND ${return} ${folder})
        endif()
    endforeach()
    set(${return} ${${return}} PARENT_SCOPE)
endfunction()

function(fi_install targets)
    install(
        TARGETS ${targets}
        EXPORT ${FI_FOLDER_NAME}Targets
        LIBRARY DESTINATION "lib"
        ARCHIVE DESTINATION "lib"
        RUNTIME DESTINATION "bin"
        PUBLIC_HEADER DESTINATION "include/${FI_FOLDER_PATH}"
    )

    export(
        EXPORT ${FI_FOLDER_NAME}Targets
        FILE ${CMAKE_BINARY_DIR}/lib/cmake/${FI_FOLDER_PATH}/${FI_FOLDER_LASTNAME}Targets.cmake
        NAMESPACE Fi_Imported_
    )

    install(
        EXPORT ${FI_FOLDER_NAME}Targets
        FILE ${FI_FOLDER_LASTNAME}Targets.cmake
        DESTINATION "lib/cmake/${FI_FOLDER_PATH}"
        NAMESPACE Fi_Imported_
    )

    install(
        DIRECTORY "${CMAKE_BINARY_DIR}/qml/"
        DESTINATION "qml"
    )

    include(CMakePackageConfigHelpers)

    fi_set_sub_packages(FI_SUB_PACKAGES)

    configure_package_config_file(
        "${FI_PROJECT_CMAKE_DIR}/__Config.cmake__"
        "${CMAKE_BINARY_DIR}/lib/cmake/${FI_FOLDER_PATH}/${FI_FOLDER_LASTNAME}Config.cmake"
        INSTALL_DESTINATION "lib/cmake/${FI_FOLDER_PATH}"
        NO_CHECK_REQUIRED_COMPONENTS_MACRO
        NO_SET_AND_CHECK_MACRO
    )

    write_basic_package_version_file(
        "${CMAKE_BINARY_DIR}/lib/cmake/${FI_FOLDER_PATH}/${FI_FOLDER_LASTNAME}ConfigVersion.cmake"
        VERSION "${FI_FOLDER_VERSION}"
        COMPATIBILITY AnyNewerVersion
    )

    install(
        FILES "${CMAKE_BINARY_DIR}/lib/cmake/${FI_FOLDER_PATH}/${FI_FOLDER_LASTNAME}Config.cmake"
        "${CMAKE_BINARY_DIR}/lib/cmake/${FI_FOLDER_PATH}/${FI_FOLDER_LASTNAME}ConfigVersion.cmake"
        DESTINATION "lib/cmake/${FI_FOLDER_PATH}"
    )
endfunction()

