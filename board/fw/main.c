#include <stdint.h>

#define F_CPU 1000000UL

#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>

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

#define SD_INSERTED 1
#define SD_NOT_INSERTED 0

#define CMD_READ_VBAT           0b10000000
#define CMD_BEEP_SHORT          0b10000001
#define CMD_BEEP_LONG           0b10000010
#define CMD_LED_ON              0b10000011
#define CMD_LED_OFF             0b10000100
#define CMD_LED_BLINK_SHORT     0b10000101
#define CMD_LED_BLINK_LONG      0b10000110
#define CMD_POWEROFF            0b10000111
#define CMD_RESET               0b10001000
#define CMD_AUDIO_MUTE          0b10001001
#define CMD_AUDIO_UNMUTE        0b10001010
#define CMD_GET_SD_STATE        0b10001011

/*
 * Function prototypes
 */

void init_peripherals();
uint8_t get_reset_btn();
uint8_t get_power_btn();
uint8_t get_sd_state();
void start_sequence();
void shutdown_sequence();
void reset_sequence();
uint8_t read_vbat();
void exec_command();
void send_byte(uint8_t data);

/*
 * Global variables
 */

static volatile uint8_t cmd_byte = 0;
static volatile uint8_t uart_recieved = 0;
static uint8_t state = HALT;

/*
 * Main program
 */

int main(){
    
    init_peripherals();
    sei();
    
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
            
            //if reset btn is pressed then go to reset sequence
            else if(get_reset_btn() == BTN_PRESS){
                _delay_ms(100);
                if(get_reset_btn() != BTN_PRESS) continue;
                reset_sequence();
            }
            
            //else, check for task from uart interface
            else if(uart_recieved != 0){
                uart_recieved = 0;
                exec_command();
            }
        }
    }
    return 0;
}

/*
 * ISR vectors
 */

ISR(USART_RX_vect){
    //interrupt from UART
    cmd_byte = UDR0;
    uart_recieved = 1;
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
     * ADMUX register
     *  VREF = AVcc
     *  result left adjusted
     *  MUX = ADC4
     * 
     * ADCSRA register
     *  enable adc
     *  prescaler = 8
     * 
     * ADCSRB register
     *  default state
     * 
     * DIDR0 register
     *  disable PC4
     */
         
    ADMUX |= (1 << MUX2) | (1 << ADLAR) | (1 << REFS0);
    ADCSRA |= (1 << ADEN) | (1 << ADPS1) | (1 << ADPS0);
    DIDR0 |= (1 << ADC4D);

    /*
     * UART configuration
     *
     * 8N1 4800baud
     * Enable RX interrupt, reciever and transmitter
     */
    
    UBRR0 = 12;
    UCSR0B |= (1 << RXCIE0) | (1 << RXEN0) | (1 << TXEN0); 

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

uint8_t get_sd_state(){
    return !((PINB & (1 << PB6)) >> PB6);
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

void reset_sequence(){
    CPULED_ON;
    SPEAKER_ON;
    RESET_HI;
    _delay_ms(100);
    SPEAKER_OFF;
    _delay_ms(100);
    RESET_LOW;
    CPULED_OFF;
}

uint8_t read_vbat(){
    //start single conversion and return ADCH value 
    ADCSRA |= (1 << ADSC);  
    while( ADCSRA & (1 << ADSC) );
    return ADCH;
}

void exec_command(){
    switch(cmd_byte){
        case CMD_READ_VBAT:
            send_byte(read_vbat());
            break;
        case CMD_BEEP_SHORT:
            SPEAKER_ON;
            _delay_ms(100);
            SPEAKER_OFF;
            _delay_ms(100);
            break;
        case CMD_BEEP_LONG:
            SPEAKER_ON;
            _delay_ms(300);
            SPEAKER_OFF;
            _delay_ms(100);
            break;
        case CMD_LED_ON:
            CPULED_ON;
            break;
        case CMD_LED_OFF:
            CPULED_OFF;
            break;
        case CMD_LED_BLINK_SHORT:
            CPULED_ON;
            _delay_ms(100);
            CPULED_OFF;
            _delay_ms(100);
            break;
        case CMD_LED_BLINK_LONG:
            CPULED_ON;
            _delay_ms(300);
            CPULED_OFF;
            _delay_ms(100);
            break;
        case CMD_POWEROFF:
            state = HALT;
            shutdown_sequence();
            break;
        case CMD_RESET:
            reset_sequence();
            break;
        case CMD_AUDIO_MUTE:
            AUDIO_MUTE;
            break;
        case CMD_AUDIO_UNMUTE:
            AUDIO_UNMUTE;           
            break;
        case CMD_GET_SD_STATE:
            send_byte(get_sd_state());
            break;
        default:
            break;
    }
}

void send_byte(uint8_t data){
    while ( !(UCSR0A & (1<<UDRE0)) );
    UDR0 = data;
}
