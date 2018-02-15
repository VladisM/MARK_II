#include <stdint.h>

#define F_CPU 1000000UL

#include <avr/io.h>
#include <util/delay.h>

/*
 * Macro definitions
 */

#define POWER_ON        PORTB |= (1 << PB7)
#define POWER_OFF       PORTB &= ~(1 << PB7)
#define RESET_HI        PORTD |= (1 << PD2)
#define RESET_LOW       PORTD &= ~(1 << PD2)
#define CPULED_ON       PORTD &= ~(1 << PD5)
#define CPULED_OFF      PORTD |= (1 << PD5)
#define SPEAKER_ON      PORTB |= (1 << PB2)
#define SPEAKER_OFF     PORTB &= ~(1 << PB2)
#define AUDIO_MUTE      PORTC |= (1 << PC5)
#define AUDIO_UNMUTE    PORTC &= ~(1 << PC5)

#define HALT 0
#define RUN 1

#define BTN_PRESS 1
#define BTN_UNPRESS 0

/*
 * Function prototypes
 */

void init_peripherals();
uint8_t get_reset_btn();
uint8_t get_power_btn();
void start_sequence();
void shutdown_sequence();

/*
 * Main program
 */

int main(){

    uint8_t state = HALT;

    init_peripherals();

    while(1){

        if(state == HALT){

            //check if pwrbtn is pressed; if so go to start sequence
            if(get_power_btn() == BTN_PRESS){
                _delay_ms(100);
                if(get_power_btn() != BTN_PRESS) continue;
                start_sequence();
                state = RUN;
            }
        }

        if(state == RUN){

            //check if pwrbtn is pressed; if so go to shutdown sequence
            if(get_power_btn() == BTN_PRESS){
                _delay_ms(100);
                if(get_power_btn() != BTN_PRESS) continue;
                shutdown_sequence();
                state = HALT;
            }
        }
    }
    return 0;
}

/*
 * Functions definitions
 */

void init_peripherals(){

    /*
     * Port B configuration
     *
     * PB7  out     power_on
     * PB6  in      sd_sw
     * PB5          ISP
     * PB4          ISP
     * PB3          ISP
     * PB2  out     speaker
     * PB1          nc
     * PB0          nc
     */

    DDRB = 0;
    DDRB |= (1 << PB7) | (1 << PB2);

    /*
     * Port C configuration
     *
     * PC6          reset
     * PC5  out     audio_mute
     * PC4  in      Vbat_voltage (ADC)
     * PC3          nc
     * PC2          nc
     * PC1          nc
     * PC0          nc
     */

    DDRC = 0;
    DDRC |= (1 << PC5);

    /*
     * Port D configuration
     *
     * PD7  in      reset_btn       pullup
     * PD6  in      power_btn       pullup
     * PD5  out     cpu_led
     * PD4          nc
     * PD3          nc
     * PD2  out     pwrmng_res
     * PD1          uart
     * PD0          uart
     */

    DDRD = 0;
    DDRD |= (1 << PD5) | (1 << PD2);
    PORTD |= (1 << PD7) | (1 << PD6);

    /*
     * ADC configuration
     *
     *
     */
    //TODO: add ADC for Vbat

    /*
     * UART configuration
     *
     *
     */
     //TODO: add uart

    /*
     * Set control pins defaults
     */

    POWER_OFF;
    AUDIO_UNMUTE;
    RESET_LOW;
    CPULED_OFF;
    SPEAKER_OFF;
}

uint8_t get_reset_btn(){
    return !((PIND & (1 << PD7)) >> PD7);
}

uint8_t get_power_btn(){
    return !((PIND & (1 << PD6)) >> PD6);
}

void start_sequence(){
    //enable voltage regulators and wait a bit
    POWER_ON;
    _delay_ms(5);

    //disable audio output, set reset state
    AUDIO_MUTE;
    RESET_HI;

    //light on LED and produce beep for short while
    CPULED_ON;
    SPEAKER_ON;
    _delay_ms(100);
    SPEAKER_OFF;
    _delay_ms(100);
    CPULED_OFF;

    //wait another while and then unset reset; MARK-II now can run
    _delay_ms(100);
    RESET_LOW;
}

void shutdown_sequence(){
    //light on LED and produce beep for short while
    CPULED_ON;
    SPEAKER_ON;
    _delay_ms(100);
    SPEAKER_OFF;
    _delay_ms(100);
    CPULED_OFF;

    //unmute audio, set reset to low
    AUDIO_UNMUTE;
    RESET_LOW;

    //wait a bit and disable voltage regulatos
    _delay_ms(10);
    POWER_OFF;
}

