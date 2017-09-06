#ifndef SPL_VGA_included
#define SPL_VGA_included

#define VRAM0_beg 0x001000
#define VRAM0_end 0x001FFF

#define VRAM0(ROW, COLUMN) (*(unsigned int *)(VRAM0_beg + (ROW * 0x100) + COLUMN))

#define FG_BLACK           (0x0 << 7)
#define FG_GRAY            (0x1 << 7)
#define FG_GREEN           (0x2 << 7)
#define FG_LIGHT_GREEN     (0x3 << 7)
#define FG_RED             (0x4 << 7)
#define FG_LIGHT_RED       (0x5 << 7)
#define FG_BROWN           (0x6 << 7)
#define FG_YELLOW          (0x7 << 7)
#define FG_BLUE            (0x8 << 7)
#define FG_LIGHT_BLUE      (0x9 << 7)
#define FG_CYAN            (0xA << 7)
#define FG_LIGHT_CYAN      (0xB << 7)
#define FG_MAGENTA         (0xC << 7)
#define FG_LIGHT_MAGENTA   (0xD << 7)
#define FG_LIGHT_GRAY      (0xE << 7)
#define FG_WHITE           (0xF << 7)

#define BG_BLACK           (0x0 << 11)
#define BG_GRAY            (0x1 << 11)
#define BG_GREEN           (0x2 << 11)
#define BG_LIGHT_GREEN     (0x3 << 11)
#define BG_RED             (0x4 << 11)
#define BG_LIGHT_RED       (0x5 << 11)
#define BG_BROWN           (0x6 << 11)
#define BG_YELLOW          (0x7 << 11)
#define BG_BLUE            (0x8 << 11)
#define BG_LIGHT_BLUE      (0x9 << 11)
#define BG_CYAN            (0xA << 11)
#define BG_LIGHT_CYAN      (0xB << 11)
#define BG_MAGENTA         (0xC << 11)
#define BG_LIGHT_MAGENTA   (0xD << 11)
#define BG_LIGHT_GRAY      (0xE << 11)
#define BG_WHITE           (0xF << 11)

#define ROW_0 0
#define ROW_1 1
#define ROW_2 2
#define ROW_3 3
#define ROW_4 4
#define ROW_5 5
#define ROW_6 6
#define ROW_7 7
#define ROW_8 8
#define ROW_9 9
#define ROW_10 10
#define ROW_11 11
#define ROW_12 12
#define ROW_13 13
#define ROW_14 14
#define ROW_15 15
#define ROW_16 16
#define ROW_17 17
#define ROW_18 18
#define ROW_19 19
#define ROW_20 20
#define ROW_21 21
#define ROW_22 22
#define ROW_23 23
#define ROW_24 24
#define ROW_25 25
#define ROW_26 26
#define ROW_27 27
#define ROW_28 28
#define ROW_29 29

#define COLUMN_0 0
#define COLUMN_1 1
#define COLUMN_2 2
#define COLUMN_3 3
#define COLUMN_4 4
#define COLUMN_5 5
#define COLUMN_6 6
#define COLUMN_7 7
#define COLUMN_8 8
#define COLUMN_9 9
#define COLUMN_10 10
#define COLUMN_11 11
#define COLUMN_12 12
#define COLUMN_13 13
#define COLUMN_14 14
#define COLUMN_15 15
#define COLUMN_16 16
#define COLUMN_17 17
#define COLUMN_18 18
#define COLUMN_19 19
#define COLUMN_20 20
#define COLUMN_21 21
#define COLUMN_22 22
#define COLUMN_23 23
#define COLUMN_24 24
#define COLUMN_25 25
#define COLUMN_26 26
#define COLUMN_27 27
#define COLUMN_28 28
#define COLUMN_29 29
#define COLUMN_30 30
#define COLUMN_31 31
#define COLUMN_32 32
#define COLUMN_33 33
#define COLUMN_34 34
#define COLUMN_35 35
#define COLUMN_36 36
#define COLUMN_37 37
#define COLUMN_38 38
#define COLUMN_39 39
#define COLUMN_40 40
#define COLUMN_41 41
#define COLUMN_42 42
#define COLUMN_43 43
#define COLUMN_44 44
#define COLUMN_45 45
#define COLUMN_46 46
#define COLUMN_47 47
#define COLUMN_48 48
#define COLUMN_49 49
#define COLUMN_50 50
#define COLUMN_51 51
#define COLUMN_52 52
#define COLUMN_53 53
#define COLUMN_54 54
#define COLUMN_55 55
#define COLUMN_56 56
#define COLUMN_57 57
#define COLUMN_58 58
#define COLUMN_59 59
#define COLUMN_60 60
#define COLUMN_61 61
#define COLUMN_62 62
#define COLUMN_63 63
#define COLUMN_64 64
#define COLUMN_65 65
#define COLUMN_66 66
#define COLUMN_67 67
#define COLUMN_68 68
#define COLUMN_69 69
#define COLUMN_70 70
#define COLUMN_71 71
#define COLUMN_72 72
#define COLUMN_73 73
#define COLUMN_74 74
#define COLUMN_75 75
#define COLUMN_76 76
#define COLUMN_77 77
#define COLUMN_78 78
#define COLUMN_79 79

#endif
