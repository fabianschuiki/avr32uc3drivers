#ifndef __AVR32_DRIVER_GPIO_H__
#define __AVR32_DRIVER_GPIO_H__


typedef struct {
	unsigned int pin;
	unsigned int function;
} gpio_map_t;


//GPIO pin functions
enum {
	GPIO_INPUT	= 0,
	GPIO_OUTPUT	= 1
};

//Returns the size of a gpio_map_t
#define GPIO_MAP_SIZE(map) (sizeof(map) / sizeof(map[0]))




/**
 * @return	A pointer to the port that controls the given pin.
 */
inline volatile avr32_gpio_port_t * gpio_portOfPin(unsigned int pin)
{
	return &AVR32_GPIO.port[pin >> 5];
}

/**
 * @return	A bit mask which corresponds to the given pin inside its port.
 */
inline unsigned int gpio_maskOfPin(unsigned int pin)
{
	return (1 << (pin & 0x1F));
}



/**
 * Enables an IO pin for use by a module or peripheral and configures it for a specific function.
 *
 * @param	pin			Pin to be configured. E.g. AVR32_PIN_PA00.
 * @param	function	Function of the pin (A, B, C, etc.). Refer to the GPIO multiplexing infor-
 *						mation of the device datasheet for details.
 */
void gpio_enableModule(unsigned int pin, unsigned int function)
{
	//Get a pointer to the pin's port and calculate the pin's bitmask.
	volatile avr32_gpio_port_t * port = gpio_portOfPin(pin);
	unsigned int mask = gpio_maskOfPin(pin);
	
	//Enable the function by either clearing or setting the appropriate bit in the PMR registers.
	//Bit 0
	if (function & (1 << 0))
		port->pmr0s = mask;
	else
		port->pmr0c = mask;
	
	//Bit 1
	if (function & (1 << 1))
		port->pmr1s = mask;
	else
		port->pmr1c = mask;
	
	//Disable GPIO for this pin since it'll be controlled by some module or peripheral.
	port->gperc = mask;
}

/**
 * Enables multiple pins at once.
 *
 * @param	map		Pointer to a map of pins and their corresponding function to be configured.
 * @param	count	Number of pins in the map.
 */
void gpio_enableModules(const gpio_map_t * map, unsigned int count)
{
	unsigned int i;
	for (i = 0; i < count; i++)
		gpio_enableModule(map[i].pin, map[i].function);
}



/**
 * Enables an IO pin for use as general purpose input/output. The Output Driver is disabled after
 * calling this function and must be (re-)enabled.
 *
 * @param	pin			Pin to be enabled. E.g. AVR32_PIN_PA00.
 * @param	function	Direction of the pin. GPIO_INPUT or GPIO_OUTPUT.
 */
void gpio_enableGPIO(unsigned int pin, unsigned int function)
{
	//Get a pointer to the pin's port and calculate the pin's bitmask.
	volatile avr32_gpio_port_t * port = gpio_portOfPin(pin);
	unsigned int mask = gpio_maskOfPin(pin);
	
	//If this is supposed to be an output pin we have to enable the Output Driver.
	if (function)
		port->oders = mask;
	else
		port->oderc = mask;
	
	//Enable the GPIO module for this pin.
	port->gpers = mask;
}


/**
 * Enables multiple pins at once.
 *
 * @param	map		Pointer to a map of pins and their corresponding function to be configured.
 * @param	count	Number of pins in the map.
 */
void gpio_enableGPIOs(const gpio_map_t * map, unsigned int count)
{
	unsigned int i;
	for (i = 0; i < count; i++)
		gpio_enableGPIO(map[i].pin, map[i].function);
}



/**
 * Output Value
 */
inline void gpio_port_set(volatile avr32_gpio_port_t * port, unsigned int mask, unsigned int value)
{
	if (value)	gpio_port_high(port, mask);
	else		gpio_port_low (port, mask);
}
inline void gpio_port_high   (volatile avr32_gpio_port_t * port, unsigned int mask) { port->ovrs = mask; }
inline void gpio_port_low    (volatile avr32_gpio_port_t * port, unsigned int mask) { port->ovrc = mask; }
inline void gpio_port_toggle (volatile avr32_gpio_port_t * port, unsigned int mask) { port->ovrt = mask; }


inline void gpio_pin_set(unsigned int pin, unsigned int value) { gpio_port_set(gpio_portOfPin(pin), gpio_maskOfPin(pin), value); }
inline void gpio_pin_high   (unsigned int pin) { gpio_port_high  (gpio_portOfPin(pin), gpio_maskOfPin(pin)); }
inline void gpio_pin_low    (unsigned int pin) { gpio_port_low   (gpio_portOfPin(pin), gpio_maskOfPin(pin)); }
inline void gpio_pin_toggle (unsigned int pin) { gpio_port_toggle(gpio_portOfPin(pin), gpio_maskOfPin(pin)); }



/**
 * Input Value
 */
inline unsigned int gpio_port_get(volatile avr32_gpio_port_t * port, unsigned int mask)
{
	return (port->pvr & mask);
}

inline unsigned int gpio_pin_get(unsigned int pin)
{
	return gpio_port_get(gpio_portOfPin(pin), gpio_maskOfPin(pin)) ? 1 : 0;
}



/**
 * Direction
 */
inline void gpio_port_setDirection(volatile avr32_gpio_port_t * port, unsigned int mask, unsigned int dir)
{
	if (dir == GPIO_INPUT)	gpio_port_setInput (port, mask);
	else					gpio_port_setOutput(port, mask);
}
inline void gpio_port_setInput(volatile avr32_gpio_port_t * port, unsigned int mask)
{
	port->ovrc  = mask;
	port->oderc = mask;
}
inline void gpio_port_setOutput(volatile avr32_gpio_port_t * port, unsigned int mask)
{
	port->oders = mask;
}


inline void gpio_pin_setDirection(unsigned int pin, unsigned int dir) { gpio_port_setDirection(gpio_portOfPin(pin), gpio_maskOfPin(pin), dir); }
inline void gpio_pin_setInput (unsigned int pin) { gpio_port_setInput (gpio_portOfPin(pin), gpio_maskOfPin(pin)); }
inline void gpio_pin_setOutput(unsigned int pin) { gpio_port_setOutput(gpio_portOfPin(pin), gpio_maskOfPin(pin)); }


#endif
