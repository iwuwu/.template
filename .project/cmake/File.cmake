#设置qml单例文件属性
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
            "FI_INITOR=${module_namespace}::${class_name}::${class_name}"
            "FI_DESTOR=${module_namespace}::${class_name}::~${class_name}() noexcept"
            "FI_INITOR_CP=${module_namespace}::${class_name}::${class_name}(const ${class_name}& other)"
            "FI_INITOR_MV=${module_namespace}::${class_name}::${class_name}(${class_name}&& other) noexcept"
            "FI_ASSIGN_CP=${module_namespace}::${class_name}& ${module_namespace}::${class_name}::operator=(const ${class_name}& other)"
            "FI_ASSIGN_MV=${module_namespace}::${class_name}& ${module_namespace}::${class_name}::operator=(${class_name}&& other) noexcept"
            "FI_METHOD=auto ${module_namespace}::${class_name}::"
            "FI_FUNC=auto ${module_namespace}::"
            "FI_OPERATOR=auto ${module_namespace}::${class_name}::operator"
            "FI_DYNAMIC_TYPE=namespace ${module_namespace}{static const int ${class_name}TypeId = ${module_namespace}::${class_name}::staticMetaObject.metaType().id()\;}\;"
        )
        set_source_files_properties(${file} PROPERTIES
            COMPILE_DEFINITIONS "${definitions}"
        )
    endforeach()
endfunction()

#设置当前文件夹中的各文件变量
macro(fi_set_module_file)
    configure_file("${FI_PROJECT_CMAKE_DIR}/__FiModule.h__" ${CMAKE_CURRENT_SOURCE_DIR}/FiModule.h)

    file(GLOB module_h_files LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "*.h")
    list(FILTER module_h_files EXCLUDE REGEX "^#")

    file(GLOB module_cpp_files LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "*.cpp")
    list(FILTER module_cpp_files EXCLUDE REGEX "^#")
    fi_set_cpp_definitions("${module_cpp_files}")

    file(GLOB module_qml_files LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "*.qml")
    list(FILTER module_qml_files EXCLUDE REGEX "^#")
    fi_set_qml_singletons("${module_qml_files}")

    file(GLOB module_js_files LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "*.js" "*.mjs")
    list(FILTER module_js_files EXCLUDE REGEX "^#")

    # asset用单数表作为整体概念的资源集合，强调一个module只有一个资源集合体
    file(GLOB_RECURSE module_asset_files LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS ".asset/*")
    list(FILTER module_asset_files EXCLUDE REGEX "/#")
endmacro()
