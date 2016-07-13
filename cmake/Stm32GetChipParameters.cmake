# How to make stm32mcus.csv:
# Visit http://www.st.com/content/st_com/en/products/microcontrollers/stm32-32-bit-arm-cortex-mcus.html?querycriteria=productId=SC1169
# Click Download, save ProductsList.xls, open with OO or MS Excel and save as CSV file.

SET(_STM32MCUS_CSV ${CMAKE_CURRENT_LIST_DIR}/stm32mcus.csv) # Keep path to module to use in function

FUNCTION(STM32_GET_CHIP_PARAMETERS CHIP FLASH_SIZE RAM_SIZE)
    IF(NOT STM32MCUS_CSV)
        SET(STM32MCUS_CSV ${_STM32MCUS_CSV})
    ENDIF()

    FILE(STRINGS ${STM32MCUS_CSV} ROW REGEX "^${CHIP},[0-9]+,[0-9]+$")
    
    IF(${ROW} MATCHES "${CHIP},[0-9]+,[0-9]+")
        STRING(REGEX REPLACE ".+,([0-9]+),.+" "\\1" FLASH_SIZE ${ROW})
        STRING(REGEX REPLACE ".+,.+,([0-9]+)" "\\1" RAM_SIZE ${ROW})
        SET(${ARGV1} ${FLASH_SIZE}K PARENT_SCOPE)
        SET(${ARGV2} ${RAM_SIZE}K PARENT_SCOPE)
    ELSE()
        MESSAGE(FATAL_ERROR "Invalid/unsupported STM32F4 chip: ${CHIP}")
    ENDIF()
ENDFUNCTION()

IF(CMAKE_SCRIPT_MODE_FILE) # Run with -P, development only
    IF(NOT CMAKE_PARENT_LIST_FILE) # Not included, top script
        IF(NOT STM32_CHIP)
            MESSAGE(FATAL_ERROR "STM32_CHIP Undefined!")
        ENDIF()

        STM32_GET_CHIP_PARAMETERS(${STM32_CHIP} FLASH_SIZE RAM_SIZE)
        
        MESSAGE(Chip:${STM32_CHIP}\nFlash:${FLASH_SIZE}\nRam: ${RAM_SIZE})
    ENDIF()
ENDIF()
