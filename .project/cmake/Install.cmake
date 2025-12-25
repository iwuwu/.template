function(fi_set_sub_packages return)
    file(GLOB paths RELATIVE ${return} LIST_DIRECTORIES true CONFIGURE_DEPENDS "*")
    foreach(folder IN LISTS ${output})
        get_filename_component(name ${folder} NAME)
        if(NOT EXISTS "${CMAKE_SOURCE_DIR}/${folder}/${name}Config.cmake" AND NOT EXISTS "${CMAKE_SOURCE_DIR}/${folder}/${name}-config.cmake")
            list(REMOVE_ITEM ${output} ${folder})
        endif()
    endforeach()
    set(${output} ${${output}} PARENT_SCOPE)
endfunction()

function(fi_install targets)

endfunction()


