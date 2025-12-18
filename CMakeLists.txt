include(.project/cmake/Version.cmake)

cmake_minimum_required(VERSION 4.2)
project(Fi VERSION 0 LANGUAGES CXX)

fi_has_git(has_git)
fi_git_desc(git_desc)
fi_git_version(git_version)

message("${has_git}")
message("${git_desc}")
message("${git_version}")

# fi_project_begin()
# fi_project_end()
