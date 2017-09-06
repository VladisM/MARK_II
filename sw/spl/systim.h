#ifndef SPL_SYSTIM_included
#define SPL_SYSTIM_included

#define SYSTIM0_BASE 0x000104

#define SYSTCR (*(unsigned int *)(SYSTIM0_BASE + 0))
#define SYSTVR (*(unsigned int *)(SYSTIM0_BASE + 1))

#define SYSTCR_top 0x00FFFFFF
#define SYSTCR_en  0x01000000

#endif
