# Build STM32.csv 
# from http://www.st.com/content/st_com/en/products/microcontrollers/stm32-32-bit-arm-cortex-mcus.html?querycriteria=productId=SC1169
# Download, Save XLS as CSV "," delimited
MACRO(STM32_GET_CHIP_PARAMETERS CHIP _FLASH _RAM _FAMILY)
    STRING(TOUPPER ${CHIP} _CHIP)
    FILE(STRINGS "stm32mcus.csv" ROW REGEX "^${_CHIP},[0-9]+,[0-9]+$")
    IF(${ROW} MATCHES "${_CHIP},[0-9]+,[0-9]+")
        STRING(REGEX REPLACE ".+,([0-9]+),.+" "\\1" ${_FLASH} ${ROW})
        STRING(REGEX REPLACE ".+,.+,([0-9]+)" "\\1" ${_RAM} ${ROW})
        STRING(REGEX REPLACE "STM32(F[0-47]|L[014]|TS).+" "\\1" ${_FAMILY} ${_CHIP})
    ELSE()
        MESSAGE(FATAL_ERROR "Invalid/unsupported STM32F4 chip: ${_CHIP}")
    ENDIF()
ENDMACRO()

IF(TESTING)
    IF(NOT STM32_CHIP)
        MESSAGE(FATAL_ERROR "STM32_CHIP Undefined!")
    ENDIF()

    STM32_GET_CHIP_PARAMETERS(${STM32_CHIP} FLASH_SIZE RAM_SIZE FAMILY)
    MESSAGE(${STM32_CHIP}\ Flash:${FLASH_SIZE}\ Ram: ${RAM_SIZE}\ Family: ${FAMILY})
ENDIF()
