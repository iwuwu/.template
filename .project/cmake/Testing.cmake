macro(fi_enable_testing enable)
    # 注意在宏中展开参数值，不能直接判断
    if(${enable})
        # include会自动enable_testing, 无需再设置
        include(CTest)
        message("单元测试: 开启")
        if(Catch2_FOUND)
            include(Catch)
        else()
            message("警告: Catch2未导入, 无法使用Catch相关功能")
        endif()
    endif()
endmacro()



