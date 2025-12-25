function(fi_set_sub_packages return)
    file(GLOB paths RELATIVE ${CMAKE_CURRENT_BINARY_DIR} LIST_DIRECTORIES true CONFIGURE_DEPENDS "*")
    foreach(folder IN LISTS ${output})
        get_filename_component(name ${folder} NAME)
        if(NOT EXISTS "${CMAKE_SOURCE_DIR}/${folder}/${name}Config.cmake" AND NOT EXISTS "${CMAKE_SOURCE_DIR}/${folder}/${name}-config.cmake")
            list(REMOVE_ITEM ${output} ${folder})
        endif()
    endforeach()
    set(${output} ${${output}} PARENT_SCOPE)
endfunction()

macro(fi_install targets)
    install(
        TARGETS ${targets}
        EXPORT ${FI_FOLDER_NAME}Targets

        PUBLIC_HEADER "include/${FI_FOLDR_PATH}/"
    )

    export(
        EXPORT ${FI_FOLDER_NAME}Targets
        FILE ${CMAKE_CURRENT_BINARY_DIR}/${FI_FOLDER_LAST_NAME}Targets.cmake
        NAMESPACE Fi_Imported
    )

    install(
        EXPORT ${FI_FOLDER_NAME}Targets
        FILE ${FI_FOLDER_LAST_NAME}Targets.cmake
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${FI_FOLDER_PATH}/"
        NAMESPACE Fi_Imported
    )

    include(CMakePackageConfigHelpers)

    fi_set_sub_packages(FI_SUB_PACKAGES)

    configure_package_config_file(
        "${FI_PROJECT_CMAKE_DIR}/__Config.cmake__"
        "${CMAKE_CURRENT_BINARY_DIR}/${FI_FOLDER_LASTNAME}Config.cmake"
        INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${FI_FOLDER_PATH}/"
    )

    write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/${FI_FOLDER_LASTNAME}ConfigVersion.cmake"
        VERSION "${FI_FOLDER_VERSION}"
        COMPATIBILITY AnyNewerVersion
    )

    install(
        FILES "${CMAKE_CURRENT_BINARY_DIR}/${FI_FOLDER_LASTNAME}Config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${FI_FOLDER_LASTNAME}ConfigVersion.cmake"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${FI_FOLDER_PATH}/"
    )
endmacro()


