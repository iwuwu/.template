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
            "FI_INITOR=${FI_FOLDER_NAMESPACE}::${class_name}::${class_name}"
            "FI_DESTOR=${FI_FOLDER_NAMESPACE}::${class_name}::~${class_name}() noexcept"
            "FI_INITOR_CP=${FI_FOLDER_NAMESPACE}::${class_name}::${class_name}(const ${class_name}& other)"
            "FI_INITOR_MV=${FI_FOLDER_NAMESPACE}::${class_name}::${class_name}(${class_name}&& other) noexcept"
            "FI_ASSIGN_CP=${FI_FOLDER_NAMESPACE}::${class_name}& ${FI_FOLDER_NAMESPACE}::${class_name}::operator=(const ${class_name}& other)"
            "FI_ASSIGN_MV=${FI_FOLDER_NAMESPACE}::${class_name}& ${FI_FOLDER_NAMESPACE}::${class_name}::operator=(${class_name}&& other) noexcept"
            "FI_METHOD=auto ${FI_FOLDER_NAMESPACE}::${class_name}::"
            "FI_FUNC=auto ${FI_FOLDER_NAMESPACE}::"
            "FI_OPERATOR=auto ${FI_FOLDER_NAMESPACE}::${class_name}::operator"
            "FI_DYNAMIC_TYPE=namespace ${FI_FOLDER_NAMESPACE}{static const int ${class_name}TypeId = ${FI_FOLDER_NAMESPACE}::${class_name}::staticMetaObject.metaType().id()\;}\;"
        )
        set_source_files_properties(${file} PROPERTIES
            COMPILE_DEFINITIONS "${definitions}"
        )
    endforeach()
endfunction()

#设置当前文件夹中的各文件变量
macro(fi_set_folder_files)
    configure_file("${FI_PROJECT_CMAKE_DIR}/__FiModule.h__" ${CMAKE_CURRENT_SOURCE_DIR}/FiModule.h)

    file(GLOB FI_FOLDER_H_FILES LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "*.h")
    list(FILTER FI_FOLDER_H_FILES EXCLUDE REGEX "^#")

    file(GLOB FI_FOLDER_CPP_FILES LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "*.cpp")
    list(FILTER FI_FOLDER_CPP_FILES EXCLUDE REGEX "^#")
    fi_set_cpp_definitions("${FI_FOLDER_CPP_FILES}")

    file(GLOB FI_FOLDER_QML_FILES LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "*.qml")
    list(FILTER FI_FOLDER_QML_FILES EXCLUDE REGEX "^#")
    fi_set_qml_singletons("${FI_FOLDER_QML_FILES}")

    file(GLOB FI_FOLDER_JS_FILES LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS "*.js" "*.mjs")
    list(FILTER FI_FOLDER_JS_FILES EXCLUDE REGEX "^#")

    file(GLOB_RECURSE FI_FOLDER_ASSET_FILES LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS ".asset/*")
    list(FILTER FI_FOLDER_ASSET_FILES EXCLUDE REGEX "/#")
endmacro()
