macro(fi_set_interface target_name)
    target_include_directories(
        ${target_name}
        PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
    )
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

macro(fi_add_qml)
    # qml_module只接受2位版本号
    string(REGEX MATCH "[0-9]+\.[0-9]+" qml_target_version "${fi_folder_version}")
    qt_add_qml_module(
        "${fi_folder_name}_Qml"
        URI ${fi_folder_uri}
        VERSION ${qml_target_version}
        QML_FILES ${fi_folder_qml_files} ${fi_folder_js_files}
        SOURCES ${fi_folder_h_files} ${fi_folder_cpp_files}
        RESOURCES ${fi_folder_assets_files}
        IMPORTS TARGET ${fi_folder_IMPORTS} # 这个地方可能要判断是不是TAGET从而调用
        DEPENDENCIES TARGET ${fi_folder_DEPENDS}
    )
    fi_set_interface("${fi_folder_name}_Qml")
    add_library("::${fi_folder_namespace}" ALIAS "${fi_folder_name}_Qml")

    message("添加  QML: ${fi_folder_uri} ${qml_target_version}")
    list(APPEND fi_folder_targets "${fi_folder_name}_Qml")
endmacro()

macro(fi_add_lib)
    qt_add_library("${fi_folder_name}_Lib" ${fi_folder_h_files} ${fi_folder_cpp_files})
    fi_set_interface(${fi_folder_name}_Lib)
    add_library("::${fi_folder_namespace}" ALIAS "${fi_folder_name}_Lib")

    message("添加  LIB: ${fi_folder_name}_Lib ${fi_folder_version}")
    list(APPEND fi_folder_targets "${fi_folder_name}_Lib")
endmacro()

macro(fi_add_exe)
    qt_add_executable("${fi_folder_name}_Exe" ${fi_folder_h_files} ${fi_folder_cpp_files})
    fi_set_interface("${fi_folder_name}_Exe")

    message("添加  EXE: ${fi_folder_name}_Exe ${fi_folder_version}")
    list(APPEND fi_folder_targets "${fi_folder_name}_Exe")
endmacro()

macro(fi_add_test main)
    qt_add_executable("${fi_folder_name}_Test" ${fi_folder_h_files} ${fi_folder_cpp_files})
    fi_set_interface("${fi_folder_name}_Test")
    if(Catch2_FOUND)
        if(${main} STREQUAL "MAIN")
            target_link_libraries("${fi_folder_name}_Test" PRIVATE Catch2::Catch2)
        else()
            target_link_libraries("${fi_folder_name}_Test" PRIVATE Catch2::Catch2WithMain)
        endif()
    else()
        add_test(NAME "${fi_folder_name}_Test" COMMAND "${fi_folder_name}_Test")
    endif()

    message("添加 TEST: ${fi_folder_name}_Test ${fi_folder_version}")
    list(APPEND fi_folder_targets "${fi_folder_name}_Test")
endmacro()
