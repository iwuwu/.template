macro(fi_set_interface target_name)
    target_include_directories(
        ${target_name}
        PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>"
        "$<INSTALL_INTERFACE:include>"
    )
    # 自动私有链接所需要的Qt模块
    target_link_libraries(${target_name} PRIVATE Qt6::Core Qt6::Qml)
    if(ENABLE_TESTING)
        target_link_libraries(${target_name} PRIVATE Qt6::QuickTest)
    endif()

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

    if(APPLE)
        set_target_properties(${target_name} PROPERTIES
            INSTALL_RPATH "@loader_path/../lib"
            MACOSX_RPATH ON
        )
    elseif(UNIX)
        set_target_properties(${target_name} PROPERTIES
            INSTALL_RPATH "$ORIGIN/../lib"
            BUILD_WITH_INSTALL_RPATH FALSE
        )
    endif()

    set_target_properties(${target_name} PROPERTIES OUTPUT_NAME "${FI_FOLDER_CAMEL_NAME}")
    set_target_properties(${target_name} PROPERTIES PREFIX "")
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
        RESOURCES ${FI_FOLDER_RES_FILES}
        IMPORTS TARGET ${FI_FOLDER_IMPORTS} # 这两个地方只能传本项目一同编译的目标
        DEPENDENCIES TARGET ${FI_FOLDER_DEPENDS}
        OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml/${FI_FOLDER_PATH}"
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
            if(TARGET "${FI_FOLDER_NAME}.lib")
                target_link_libraries("${FI_FOLDER_NAME}.lib" PRIVATE Catch2::Catch2)
            endif()
        else()
            target_link_libraries("${target_name}" PRIVATE Catch2::Catch2WithMain)
            if(TARGET "${FI_FOLDER_NAME}.lib")
                target_link_libraries("${FI_FOLDER_NAME}.lib" PRIVATE Catch2::Catch2WithMain)
            endif()
        endif()
        catch_discover_tests("${target_name}")
    else()
        # TODO: add非Catch2的测试需要更进一步的设置
        add_test(NAME "${target_name}" COMMAND "${target_name}")
    endif()

    message("添加TEST: ${target_name}")
    list(APPEND FI_FOLDER_TARGETS ${target_name})
endmacro()
