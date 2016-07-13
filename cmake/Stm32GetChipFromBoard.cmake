SET(_STM32BOARDS_CSV ${CMAKE_CURRENT_LIST_DIR}/stm32boards.csv) # Keep path to module to use in function

FUNCTION(BOARD_GET_CHIP BOARD CHIP)
    STRING(TOUPPER ${BOARD} BOARD)

    IF(NOT STM32BOARDS_CSV)
        SET(STM32BOARDS_CSV ${_STM32BOARDS_CSV})
    ENDIF()
    MESSAGE(${STM32BOARDS_CSV}|${BOARD}|)
    FILE(STRINGS ${STM32BOARDS_CSV} ROW REGEX "^${BOARD},.+$")
    IF(${ROW} MATCHES "${BOARD},.+")
        STRING(REGEX REPLACE ".+,(.+)" "\\1" CHIP ${ROW})
        SET(${ARGV1} ${CHIP} PARENT_SCOPE)
    ELSE()
        MESSAGE(FATAL_ERROR "Invalid/unsupported board: ${BOARD}")
    ENDIF()
ENDFUNCTION()

IF(CMAKE_SCRIPT_MODE_FILE) # Run with -P, development only
    IF(NOT CMAKE_PARENT_LIST_FILE) # Not included, top script
        IF(NOT BOARD)
            MESSAGE(FATAL_ERROR "BOARD Undefined!")
        ENDIF()

        INCLUDE(Stm32GetChipParameters.cmake)

        BOARD_GET_CHIP(${BOARD} CHIP)
        STM32_GET_CHIP_PARAMETERS(${CHIP} FLASH_SIZE RAM_SIZE)
        MESSAGE(Board:\ ${BOARD}\nMcu:\ ${CHIP}\n)
        MESSAGE(Flash:\ ${FLASH_SIZE}\nRam:\ ${RAM_SIZE})
    ENDIF()
ENDIF()
