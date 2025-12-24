macro(fi_set_interface target_name)
    target_include_directories(
        ${target_name}
        PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
    )
    target_link_libraries(${target_name} PRIVATE Qt6::Core Qt6::Qml)
    if(fi_folder_PRIVATE)
        target_link_libraries(${target_name} PRIVATE ${fi_folder_PRIVATE})
    endif()
    if(fi_folder_INTERFACE)
        target_link_libraries(${target_name} INTERFACE ${fi_folder_INTERFACE})
    endif()
    if(fi_folder_PUBLIC)
        target_link_libraries(${target_name} PUBLIC ${fi_folder_PUBLIC})
    endif()

    #这里必须设为PRIVATE使得只有在本Target编译的时候会有这个宏，当别人导入的时候不是Interface
    target_compile_definitions(${target_name} PRIVATE "FI_${fi_folder_upper_name}_BUILD")
    target_compile_definitions(
        ${target_name}
        PRIVATE
        "$<BUILD_INTERFACE:FI_HOME=\"${CMAKE_BINARY_DIR}\">"
        "$<INSTALL_INTERFACE:FI_HOME=\"$<INSTALL_PREFIX>\">"
    )
endmacro()

macro(fi_add_qml target_name)
    # qml_module只接受2位版本号
    string(REGEX MATCH "[0-9]+\.[0-9]+" qml_target_version "${fi_folder_VERSION}")
    qt_add_qml_module(
        "${target_name}"
        URI ${fi_folder_uri}
        VERSION ${qml_target_version}
        QML_FILES ${fi_folder_qml_files} ${fi_folder_js_files}
        SOURCES ${fi_folder_h_files} ${fi_folder_cpp_files}
        RESOURCES ${fi_folder_assets_files}
        IMPORTS TARGET ${fi_folder_IMPORTS} # 这个地方可能要判断是不是TAGET从而调用
        DEPENDENCIES TARGET ${fi_folder_DEPENDS}
    )
    fi_set_interface("${target_name}")
    add_library("::${fi_folder_namespace}" ALIAS "${target_name}")

    message("添加  QML: ${fi_folder_uri} ${qml_target_version}")
    list(APPEND fi_folder_targets "${target_name}")
endmacro()

macro(fi_add_lib target_name)
    qt_add_library("${target_name}" ${fi_folder_h_files} ${fi_folder_cpp_files})
    fi_set_interface("${target_name}")
    add_library("::${fi_folder_namespace}" ALIAS "${target_name}")

    message("添加  LIB: ${target_name} ${fi_folder_VERSION}")
    list(APPEND fi_folder_targets "${target_name}")
endmacro()

macro(fi_add_exe target_name)
    qt_add_executable("${target_name}" ${fi_folder_h_files} ${fi_folder_cpp_files})
    fi_set_interface("${target_name}")

    message("添加  EXE: ${target_name} ${fi_folder_VERSION}")
    list(APPEND fi_folder_targets "${target_name}")
endmacro()

macro(fi_add_test target_name main)
    qt_add_executable("${target_name}" ${fi_folder_h_files} ${fi_folder_cpp_files})
    fi_set_interface("${target_name}")
    if(Catch2_FOUND)
        if("${main}" STREQUAL "MAIN")
            target_link_libraries("${target_name}" PRIVATE Catch2::Catch2)
        else()
            target_link_libraries("${target_name}" PRIVATE Catch2::Catch2WithMain)
        endif()
    else()
        add_test(NAME "${target_name}" COMMAND "${target_name}")
    endif()

    message("添加 TEST: ${target_name} ${fi_folder_VERSION}")
    list(APPEND fi_folder_targets ${target_name})
endmacro()
