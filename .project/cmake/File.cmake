function(fi_set_qml_singletons files)
    foreach(file IN LISTS files)
        file(STRINGS ${file} head LIMIT_COUNT 1)
        if(head MATCHES "pragma Singleton")
            set_source_files_properties(${file} PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
        endif()
    endforeach()
endfunction()

#配置CPP文件宏，可以输入一个或多个文件
function(fi_set_cpp_definitions files)
    foreach(file IN LISTS files)
        cmake_path(GET file STEM class_name)
        set(definitions
            "FI_INITOR=${folder_namespace}::${class_name}::${class_name}"
            "FI_DESTOR=${folder_namespace}::${class_name}::~${class_name}() noexcept"
            "FI_INITOR_CP=${folder_namespace}::${class_name}::${class_name}(const ${class_name}& other)"
            "FI_INITOR_MV=${folder_namespace}::${class_name}::${class_name}(${class_name}&& other) noexcept"
            "FI_ASSIGN_CP=${folder_namespace}::${class_name}& ${folder_namespace}::${class_name}::operator=(const ${class_name}& other)"
            "FI_ASSIGN_MV=${folder_namespace}::${class_name}& ${folder_namespace}::${class_name}::operator=(${class_name}&& other) noexcept"
            "FI_METHOD=auto ${folder_namespace}::${class_name}::"
            "FI_FUNC=auto ${folder_namespace}::"
            "FI_OPERATOR=auto ${folder_namespace}::${class_name}::operator"
            "FI_DYNAMIC_TYPE=namespace ${folder_namespace}{static const int ${class_name}TypeId = ${folder_namespace}::${class_name}::staticMetaObject.metaType().id()\;}\;"
        )
        set_source_files_properties(${file} PROPERTIES
            COMPILE_DEFINITIONS "${definitions}"
        )
    endforeach()
endfunction()

#设置当前文件夹中的各文件变量
macro(fi_set_folder_files)
    configure_file("${fi_project_cmake_dir}/__FiModule.h__" ${CMAKE_CURRENT_SOURCE_DIR}/FiModule.h)

    file(GLOB folder_h_files LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "*.h")
    list(FILTER folder_h_files EXCLUDE REGEX "^#")

    file(GLOB folder_cpp_files LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "*.cpp")
    list(FILTER folder_cpp_files EXCLUDE REGEX "^#")
    fi_set_cpp_definitions("${folder_cpp_files}")

    file(GLOB folder_qml_files LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "*.qml")
    list(FILTER folder_qml_files EXCLUDE REGEX "^#")
    fi_set_qml_singletons("${folder_qml_files}")

    file(GLOB folder_js_files LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "*.js" "*.mjs")
    list(FILTER folder_js_files EXCLUDE REGEX "^#")

    file(GLOB_RECURSE folder_assets_files LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS ".assets/*")
    list(FILTER folder_assets_files EXCLUDE REGEX "/#")
endmacro()
