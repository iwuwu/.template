macro(fi_set_interface target_name)
    target_include_directories(
        ${target_name}
        PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>"
        "$<INSTALL_INTERFACE:.>"
    )
    # 自动私有链接库所需要的Qt模块
    target_link_libraries(${target_name} PRIVATE Qt6::Core Qt6::Qml)

    # 添加Target相关的头文件（以便在安装的时候使用）
    set_target_properties(${target_name} PROPERTIES
        PUBLIC_HEADER "${FI_FOLDER_H_FILES}"
    )

    if(FI_FOLDER_PRIVATE)
        target_link_libraries(${target_name} PRIVATE ${FI_FOLDER_PRIVATE})
    endif()
    if(FI_FOLDER_INTERFACE)
        target_link_libraries(${target_name} INTERFACE ${FI_FOLDER_INTERFACE})
    endif()
    if(FI_FOLDER_PUBLIC)
        target_link_libraries(${target_name} PUBLIC ${FI_FOLDER_PUBLIC})
    endif()

    #这里必须设为PRIVATE使得只有在本Target编译的时候会有这个宏，当别人导入的时候不是Interface
    target_compile_definitions(${target_name} PRIVATE "FI_${FI_FOLDER_UPPER_NAME}_BUILD")
    target_compile_definitions(
        ${target_name}
        PRIVATE
        "$<BUILD_INTERFACE:FI_HOME=\"${CMAKE_BINARY_DIR}\">"
        "$<INSTALL_INTERFACE:FI_HOME=\"$<INSTALL_PREFIX>\">"
    )
endmacro()

macro(fi_add_qml target_name)
    # qml_module只接受2位版本号
    string(REGEX MATCH "[0-9]+\.[0-9]+" qml_target_version "${FI_FOLDER_VERSION}")
    qt_add_qml_module(
        "${target_name}"
        URI ${FI_FOLDER_URI}
        VERSION ${qml_target_version}
        QML_FILES ${FI_FOLDER_QML_FILES} ${FI_FOLDER_JS_FILES}
        SOURCES ${FI_FOLDER_H_FILES} ${FI_FOLDER_CPP_FILES}
        RESOURCES ${FI_FOLDER_ASSET_FILES}
        IMPORTS TARGET ${FI_FOLDER_IMPORTS} # 这个地方可能要判断是不是TAGET从而调用
        DEPENDENCIES TARGET ${FI_FOLDER_DEPENDS}
    )
    fi_set_interface("${target_name}")

    add_library("::${FI_FOLDER_NAMESPACE}" ALIAS "${target_name}")

    message("添加 QML: ${FI_FOLDER_URI} ${qml_target_version}")
    list(APPEND FI_FOLDER_TARGETS "${target_name}")
endmacro()

macro(fi_add_lib target_name)
    qt_add_library("${target_name}" ${FI_FOLDER_H_FILES} ${FI_FOLDER_CPP_FILES})
    fi_set_interface("${target_name}")
    add_library("::${FI_FOLDER_NAMESPACE}" ALIAS "${target_name}")

    message("添加 LIB: ${target_name}")
    list(APPEND FI_FOLDER_TARGETS "${target_name}")
endmacro()

macro(fi_add_exe target_name)
    qt_add_executable("${target_name}" ${FI_FOLDER_H_FILES} ${FI_FOLDER_CPP_FILES})
    fi_set_interface("${target_name}")

    message("添加 EXE: ${target_name}")
    list(APPEND FI_FOLDER_TARGETS "${target_name}")
endmacro()

macro(fi_add_test target_name main)
    qt_add_executable("${target_name}" ${FI_FOLDER_H_FILES} ${FI_FOLDER_CPP_FILES})
    fi_set_interface("${target_name}")
    if(Catch2_FOUND)
        if("${main}" STREQUAL "MAIN")
            target_link_libraries("${target_name}" PRIVATE Catch2::Catch2)
            if(TARGET "Lib_${target_name}")
                target_link_libraries("Lib_${target_name}" PRIVATE Catch2::Catch2)
            endif()
        else()
            target_link_libraries("${target_name}" PRIVATE Catch2::Catch2WithMain)
            if(TARGET "Lib_${target_name}")
                target_link_libraries("Lib_${target_name}" PRIVATE Catch2::Catch2WithMain)
            endif()
        endif()
        catch_discover_tests("${target_name}")
    else()
        add_test(NAME "${target_name}" COMMAND "${target_name}")
    endif()

    message("添加TEST: ${target_name}")
    list(APPEND FI_FOLDER_TARGETS ${target_name})
endmacro()
