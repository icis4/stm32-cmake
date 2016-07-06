MACRO(BOARD_GET_CHIP BOARD CHIP)
    STRING(TOUPPER ${BOARD} BOARD)

    IF(NOT STM32BOARDS_CSV)
        SET(STM32BOARDS_CSV stm32boards.csv)
    ENDIF()

    FILE(STRINGS ${STM32BOARDS_CSV} ROW REGEX "^${BOARD},.+$")
    IF(${ROW} MATCHES "${BOARD},.+")
        STRING(REGEX REPLACE ".+,(.+)" "\\1" ${CHIP} ${ROW})
    ELSE()
        MESSAGE(FATAL_ERROR "Invalid/unsupported board: ${BOARD}")
    ENDIF()
ENDMACRO()

IF(CMAKE_SCRIPT_MODE_FILE) # Run with -P, development only
    IF(NOT CMAKE_PARENT_LIST_FILE) # Not included, top script
        IF(NOT BOARD)
            MESSAGE(FATAL_ERROR "BOARD Undefined!")
        ENDIF()

        INCLUDE(Stm32GetChipParameters.cmake)

        BOARD_GET_CHIP(${BOARD} _CHIP)
        STM32_GET_CHIP_PARAMETERS(${_CHIP} FLASH_SIZE RAM_SIZE FAMILY)
        MESSAGE(Board:\ ${BOARD}\nMcu:\ ${_CHIP})
        MESSAGE(Family: ${FAMILY}\nFlash:${FLASH_SIZE}\nRam: ${RAM_SIZE})
    ENDIF()
ENDIF()
