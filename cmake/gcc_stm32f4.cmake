SET(CMAKE_C_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wall -std=gnu99 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "c compiler flags")
SET(CMAKE_CXX_FLAGS "-mthumb -fno-builtin -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -Wall -std=c++11 -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -fno-unroll-loops -ffast-math -ftree-vectorize" CACHE INTERNAL "cxx compiler flags")
SET(CMAKE_ASM_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -x assembler-with-cpp" CACHE INTERNAL "asm compiler flags")

SET(CMAKE_EXE_LINKER_FLAGS "-Wl,--gc-sections -mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "executable linker flags")
SET(CMAKE_MODULE_LINKER_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "module linker flags")
SET(CMAKE_SHARED_LINKER_FLAGS "-mthumb -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=softfp -mabi=aapcs" CACHE INTERNAL "shared linker flags")
SET(STM32_CHIP_TYPES 405xx 415xx 407xx 417xx 427xx 437xx 429xx 439xx 446xx 401xC 401xE 411xE CACHE INTERNAL "stm32f4 chip types")
SET(STM32_CODES "405.." "415.." "407.." "417.." "427.." "437.." "429.." "439.." "446.." "401.[CB]" "401.[ED]" "411.[ED]")

MACRO(STM32_GET_CHIP_TYPE CHIP CHIP_TYPE)
    STRING(REGEX REPLACE "^[sS][tT][mM]32[fF](4[01234][15679].[BCERGI]).*$" "\\1" STM32_CODE ${CHIP})
    SET(INDEX 0)
    FOREACH(C_TYPE ${STM32_CHIP_TYPES})
        LIST(GET STM32_CODES ${INDEX} CHIP_TYPE_REGEXP)
        IF(STM32_CODE MATCHES ${CHIP_TYPE_REGEXP})
            SET(RESULT_TYPE ${C_TYPE})
        ENDIF()
        MATH(EXPR INDEX "${INDEX}+1")
    ENDFOREACH()
    SET(${CHIP_TYPE} ${RESULT_TYPE})
ENDMACRO()

# How to make stm32mcus.csv:
# Visit http://www.st.com/content/st_com/en/products/microcontrollers/stm32-32-bit-arm-cortex-mcus.html?querycriteria=productId=SC1169
# Click Download, save ProductsList.xls, open with OO or MS Excel and save as CSV file.

SET(_STM32MCUS_CSV ${CMAKE_CURRENT_LIST_DIR}/stm32mcus.csv) # Keep path to module to use in macro

MACRO(STM32_GET_CHIP_PARAMETERS CHIP FLASH_SIZE RAM_SIZE)
    MESSAGE(***\ ${CHIP}\ ***)
    IF(NOT STM32MCUS_CSV)
        SET(STM32MCUS_CSV ${_STM32MCUS_CSV})
    ENDIF()

    FILE(STRINGS ${STM32MCUS_CSV} ROW REGEX "^${CHIP},[0-9]+,[0-9]+$")

    IF(${ROW} MATCHES "${CHIP},[0-9]+,[0-9]+")
        STRING(REGEX REPLACE ".+,([0-9]+),.+" "\\1" ${FLASH_SIZE} ${ROW})
        STRING(REGEX REPLACE ".+,.+,([0-9]+)" "\\1" ${RAM_SIZE} ${ROW})
    ELSE()
        MESSAGE(FATAL_ERROR "Invalid/unsupported STM32F4 chip: ${CHIP}")
    ENDIF()
    MESSAGE(***\ ${CHIP}\ ${FLASH_SIZE}\ ${RAM_SIZE} \ ***)
ENDMACRO()

FUNCTION(STM32_SET_CHIP_DEFINITIONS TARGET CHIP_TYPE)
    LIST(FIND STM32_CHIP_TYPES ${CHIP_TYPE} TYPE_INDEX)
    IF(TYPE_INDEX EQUAL -1)
        MESSAGE(FATAL_ERROR "Invalid/unsupported STM32F4 chip type: ${CHIP_TYPE}")
    ENDIF()
    GET_TARGET_PROPERTY(TARGET_DEFS ${TARGET} COMPILE_DEFINITIONS)
    IF(TARGET_DEFS)
        SET(TARGET_DEFS "STM32F4;STM32F${CHIP_TYPE};${TARGET_DEFS}")
    ELSE()
        SET(TARGET_DEFS "STM32F4;STM32F${CHIP_TYPE}")
    ENDIF()
        
    SET_TARGET_PROPERTIES(${TARGET} PROPERTIES COMPILE_DEFINITIONS "${TARGET_DEFS}")
ENDFUNCTION()
