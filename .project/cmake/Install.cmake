function(fi_get_sub_packages output)
    fi_get_sub_folders(${output})
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


