#ifndef SPL_GPIO_included
#define SPL_GPIO_included

#define GPIO_BASE 0x000100

#define PORTA    (*(unsigned int *)(GPIO_BASE + 0))
#define DDRA     (*(unsigned int *)(GPIO_BASE + 1))
#define PORTB    (*(unsigned int *)(GPIO_BASE + 2))
#define DDRB     (*(unsigned int *)(GPIO_BASE + 3))

#define PA0 0x01
#define PA1 0x02
#define PA2 0x04
#define PA3 0x08
#define PA4 0x10
#define PA5 0x20
#define PA6 0x40
#define PA7 0x80

#define DA0 0x01
#define DA1 0x02
#define DA2 0x04
#define DA3 0x08
#define DA4 0x10
#define DA5 0x20
#define DA6 0x40
#define DA7 0x80

#define PB0 0x01
#define PB1 0x02
#define PB2 0x04
#define PB3 0x08
#define PB4 0x10
#define PB5 0x20
#define PB6 0x40
#define PB7 0x80

#define DB0 0x01
#define DB1 0x02
#define DB2 0x04
#define DB3 0x08
#define DB4 0x10
#define DB5 0x20
#define DB6 0x40
#define DB7 0x80

#endif
