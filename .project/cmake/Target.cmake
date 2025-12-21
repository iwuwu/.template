# 内部目标添加::开头的别名





function(fi_set_target_interfaces target_name)
    target_include_directories(
        ${target_name}
        PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
    )
    if(FI_ARG_PRIVATE)
        target_link_libraries(${target_name} PRIVATE ${FI_ARG_PRIVATE})
    endif()
    if(FI_ARG_INTERFACE)
        target_link_libraries(${target_name} INTERFACE ${FI_ARG_INTERFACE})
    endif()
    if(FI_ARG_PUBLIC)
        target_link_libraries(${target_name} PUBLIC ${FI_ARG_PUBLIC})
    endif()

    #这里必须设为PRIVATE使得只有在本Target编译的时候会有这个宏，当别人导入的时候不是Interface
    target_compile_definitions(${target_name} PRIVATE "FI_${module_upper_target}_BUILD")
    target_compile_definitions(
        ${target_name}
        PRIVATE
        "$<BUILD_INTERFACE:FI_HOME=\"${CMAKE_BINARY_DIR}\">"
        "$<INSTALL_INTERFACE:FI_HOME=\"$<INSTALL_PREFIX>\">"
    )
endfunction()
