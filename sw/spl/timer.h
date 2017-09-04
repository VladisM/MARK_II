#ifndef SPL_TIMER_included
#define SPL_TIMER_included

#define TIMER0_BASE 0x000110
#define TIMER1_BASE 0x000114
#define TIMER2_BASE 0x000118
#define TIMER3_BASE 0x00011C

#define TCCR0    (*(unsigned int *)(TIMER0_BASE + 0))
#define OCRA0    (*(unsigned int *)(TIMER0_BASE + 1))
#define OCRB0    (*(unsigned int *)(TIMER0_BASE + 2))
#define TCNR0    (*(unsigned int *)(TIMER0_BASE + 3))

#define TCCR1    (*(unsigned int *)(TIMER1_BASE + 0))
#define OCRA1    (*(unsigned int *)(TIMER1_BASE + 1))
#define OCRB1    (*(unsigned int *)(TIMER1_BASE + 2))
#define TCNR1    (*(unsigned int *)(TIMER1_BASE + 3))

#define TCCR2    (*(unsigned int *)(TIMER2_BASE + 0))
#define OCRA2    (*(unsigned int *)(TIMER2_BASE + 1))
#define OCRB2    (*(unsigned int *)(TIMER2_BASE + 2))
#define TCNR2    (*(unsigned int *)(TIMER2_BASE + 3))

#define TCCR3    (*(unsigned int *)(TIMER3_BASE + 0))
#define OCRA3    (*(unsigned int *)(TIMER3_BASE + 1))
#define OCRB3    (*(unsigned int *)(TIMER3_BASE + 2))
#define TCNR3    (*(unsigned int *)(TIMER3_BASE + 3))

#define TCCR0_ccmen 0x00000001
#define TCCR0_timen 0x00000002
#define TCCR0_ovint 0x00000004
#define TCCR0_cmint 0x00000008
#define TCCR0_pwmen 0x00000010
#define TCCR0_pre0  0x00000020
#define TCCR0_pre1  0x00000040

#define TCCR1_ccmen 0x00000001
#define TCCR1_timen 0x00000002
#define TCCR1_ovint 0x00000004
#define TCCR1_cmint 0x00000008
#define TCCR1_pwmen 0x00000010
#define TCCR1_pre0  0x00000020
#define TCCR1_pre1  0x00000040

#define TCCR2_ccmen 0x00000001
#define TCCR2_timen 0x00000002
#define TCCR2_ovint 0x00000004
#define TCCR2_cmint 0x00000008
#define TCCR2_pwmen 0x00000010
#define TCCR2_pre0  0x00000020
#define TCCR2_pre1  0x00000040

#define TCCR3_ccmen 0x00000001
#define TCCR3_timen 0x00000002
#define TCCR3_ovint 0x00000004
#define TCCR3_cmint 0x00000008
#define TCCR3_pwmen 0x00000010
#define TCCR3_pre0  0x00000020
#define TCCR3_pre1  0x00000040

#endif
