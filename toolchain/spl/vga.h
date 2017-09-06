/**
@file vga.h

@brief Symbol definitions for vga
*/

#ifndef SPL_VGA_included
#define SPL_VGA_included

#define VRAM0_beg 0x001000 /**< @brief Beginning of vram0. */
#define VRAM0_end 0x001FFF /**< @brief End of vram0. */

#define VRAM0(ROW, COLUMN) (*(unsigned int *)(VRAM0_beg + (ROW * 0x100) + COLUMN)) /**< @brief Macro for writing into video RAM. */

#define FG_BLACK           (0x0 << 7) /**< @brief Foreground color code. */
#define FG_GRAY            (0x1 << 7) /**< @brief Foreground color code. */
#define FG_GREEN           (0x2 << 7) /**< @brief Foreground color code. */
#define FG_LIGHT_GREEN     (0x3 << 7) /**< @brief Foreground color code. */
#define FG_RED             (0x4 << 7) /**< @brief Foreground color code. */
#define FG_LIGHT_RED       (0x5 << 7) /**< @brief Foreground color code. */
#define FG_BROWN           (0x6 << 7) /**< @brief Foreground color code. */
#define FG_YELLOW          (0x7 << 7) /**< @brief Foreground color code. */
#define FG_BLUE            (0x8 << 7) /**< @brief Foreground color code. */
#define FG_LIGHT_BLUE      (0x9 << 7) /**< @brief Foreground color code. */
#define FG_CYAN            (0xA << 7) /**< @brief Foreground color code. */
#define FG_LIGHT_CYAN      (0xB << 7) /**< @brief Foreground color code. */
#define FG_MAGENTA         (0xC << 7) /**< @brief Foreground color code. */
#define FG_LIGHT_MAGENTA   (0xD << 7) /**< @brief Foreground color code. */
#define FG_LIGHT_GRAY      (0xE << 7) /**< @brief Foreground color code. */
#define FG_WHITE           (0xF << 7) /**< @brief Foreground color code. */

#define BG_BLACK           (0x0 << 11) /**< @brief Background color code. */
#define BG_GRAY            (0x1 << 11) /**< @brief Background color code. */
#define BG_GREEN           (0x2 << 11) /**< @brief Background color code. */
#define BG_LIGHT_GREEN     (0x3 << 11) /**< @brief Background color code. */
#define BG_RED             (0x4 << 11) /**< @brief Background color code. */
#define BG_LIGHT_RED       (0x5 << 11) /**< @brief Background color code. */
#define BG_BROWN           (0x6 << 11) /**< @brief Background color code. */
#define BG_YELLOW          (0x7 << 11) /**< @brief Background color code. */
#define BG_BLUE            (0x8 << 11) /**< @brief Background color code. */
#define BG_LIGHT_BLUE      (0x9 << 11) /**< @brief Background color code. */
#define BG_CYAN            (0xA << 11) /**< @brief Background color code. */
#define BG_LIGHT_CYAN      (0xB << 11) /**< @brief Background color code. */
#define BG_MAGENTA         (0xC << 11) /**< @brief Background color code. */
#define BG_LIGHT_MAGENTA   (0xD << 11) /**< @brief Background color code. */
#define BG_LIGHT_GRAY      (0xE << 11) /**< @brief Background color code. */
#define BG_WHITE           (0xF << 11) /**< @brief Background color code. */

#define ROW_0 0     /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_1 1     /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_2 2     /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_3 3     /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_4 4     /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_5 5     /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_6 6     /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_7 7     /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_8 8     /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_9 9     /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_10 10   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_11 11   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_12 12   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_13 13   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_14 14   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_15 15   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_16 16   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_17 17   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_18 18   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_19 19   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_20 20   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_21 21   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_22 22   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_23 23   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_24 24   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_25 25   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_26 26   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_27 27   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_28 28   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */
#define ROW_29 29   /**< @brief Row constant, use it for VRAM0(ROW, COLUMN) macro. */

#define COLUMN_0 0      /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_1 1      /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_2 2      /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_3 3      /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_4 4      /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_5 5      /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_6 6      /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_7 7      /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_8 8      /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_9 9      /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_10 10    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_11 11    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_12 12    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_13 13    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_14 14    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_15 15    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_16 16    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_17 17    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_18 18    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_19 19    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_20 20    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_21 21    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_22 22    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_23 23    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_24 24    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_25 25    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_26 26    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_27 27    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_28 28    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_29 29    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_30 30    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_31 31    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_32 32    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_33 33    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_34 34    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_35 35    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_36 36    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_37 37    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_38 38    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_39 39    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_40 40    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_41 41    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_42 42    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_43 43    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_44 44    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_45 45    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_46 46    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_47 47    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_48 48    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_49 49    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_50 50    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_51 51    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_52 52    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_53 53    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_54 54    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_55 55    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_56 56    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_57 57    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_58 58    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_59 59    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_60 60    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_61 61    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_62 62    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_63 63    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_64 64    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_65 65    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_66 66    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_67 67    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_68 68    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_69 69    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_70 70    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_71 71    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_72 72    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_73 73    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_74 74    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_75 75    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_76 76    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_77 77    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_78 78    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */
#define COLUMN_79 79    /**< @brief Column constant, use it for VRAM(ROW, COLUMN) macro. */

#endif
