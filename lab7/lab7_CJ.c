// lab7_CJ.c
// Christian Johnson, 10/29/24, chrjohnson@hmc.edu
// Simon. The game of Simon has 11 levels
// Level 0 is a pattern of length 2, level 1 is a length 3 pattern, up to level 11 with a length 12 pattern

#include <stdint.h>

#define LED_LEFT 21     // LED_LEFT on GPIO 21
#define LED_RIGHT 20    // LED_RIGHT on GPIO 20

#define BUT_LEFT 11     // BUT_LEFT on GPIO 11
#define BUT_RIGHT 10    // BUT_RIGHT on GPIO 10

#define DUR 250

void delay(int ms);
int level(int length);
void display_level(int length);
int check_level(int length);
int main(void);
void flash(int times);
void display(int left_input, int right_input);

// Define LED predetermined sequence
// "0" represents the left button pressed
// "1" represents the right button pressed
// Reads from right to left
unsigned int sequence = 0b101010101010;

volatile uint32_t *GPIO_INPUT_VAL  = (uint32_t *)0x10012000;
volatile uint32_t *GPIO_INPUT_EN   = (uint32_t *)0x10012004;
volatile uint32_t *GPIO_OUTPUT_EN  = (uint32_t *)0x10012008;
volatile uint32_t *GPIO_OUTPUT_VAL = (uint32_t *)0x1001200C;



void delay(int ms) {
  volatile uint64_t *mtime = (uint64_t *)0x0200bff8;
  uint64_t doneTime        = *mtime + (ms * 32768) / 1000;
  while (*mtime < doneTime);    // wait until time is reached
}

void display(int left_input, int right_input) {
  if (left_input) {
    // Turn on left LED
    *GPIO_OUTPUT_VAL |= (1 << LED_LEFT);
    delay(DUR);
    // Turn off left LED
    *GPIO_OUTPUT_VAL &= ~(1 << LED_LEFT);
    delay(DUR);
  }
  else {
    // Turn on right LED
    *GPIO_OUTPUT_VAL |= (1 << LED_RIGHT);
    delay(DUR);
    // Turn off both LEDS
    *GPIO_OUTPUT_VAL &= ~(1 << LED_RIGHT);
    delay(DUR);
  }
}


// Both LEDs flash three times each
void flash(int times) {
  for (int i = 0; i < times; i++) {
    // Turn on both LEDS
    *GPIO_OUTPUT_VAL |= (1 << LED_LEFT);
    *GPIO_OUTPUT_VAL |= (1 << LED_RIGHT);
    delay(DUR);
    // Turn off both LEDS
    *GPIO_OUTPUT_VAL &= ~(1 << LED_LEFT);
    *GPIO_OUTPUT_VAL &= ~(1 << LED_RIGHT);
    delay(DUR);
  }
}

/*
  level accepts an integer, length, which represents the current level we are on.
  First, level flashes the level's LED sequence with display_level
  Then, it checks if the user presses the switches in the corresponding sequence
  with check_level

  level will return the next length if the user correctly recreates the sequence
  otherwise, level resets itself to the originial length of two
*/
int level(int length) {
  display_level(length);
  return check_level(length);
}

void display_level(int length) {
  int current_LED;
  for (int i=0; i<length; i++) {
    if ((sequence >> i) & 0b1) current_LED = LED_RIGHT; // current bit is 1
    else                       current_LED = LED_LEFT;  // current bit is 0

    *GPIO_OUTPUT_VAL |= (1 << current_LED);
    delay(DUR); // Keep on for DUR ms
    *GPIO_OUTPUT_VAL &= ~(1 << current_LED);
    delay(DUR); // Pause in between outputs
  }
}

int check_level(int length) {
  int left_input;
  int right_input;
  int right_expected;
  int left_expected;

  for (int i = 0; i < length; i++) {
    // Get button inputs
    left_input  = (*GPIO_INPUT_VAL >> BUT_LEFT) & 0b1;     // Read value on BUT_LEFT
    right_input = (*GPIO_INPUT_VAL >> BUT_RIGHT) & 0b1;    // Read value on BUT_RIGHT

    // Output user's inputs
    display(left_input, right_input);

    right_expected = (sequence >> i) & 0b1; // True if input should be right button
    left_expected  = !right_expected; // True if input should be left button

    if (left_input & right_input) {
      //Flash to indicate that the user error
      flash(3);
      // User input error: can't press two buttons at once
      return 2;
    }
    else if (!(left_input | right_input)) {
      //Flash to indicate that the user error
      flash(3);
      // User input error: needs to press at least one button
      return 2;

    }
    else if ((left_input != left_expected) | (right_input != right_expected)) {
      //Flash to indicate that the user error
      flash(3);
      // Incorrect input detected
      return 2;
    }

    // If left button was pressed wait until released
    if (left_input) {
      while ((*GPIO_INPUT_VAL >> BUT_LEFT) & 0b1) delay(DUR);
    }
    else {
      // otherwise wait for right button to be released
      while ((*GPIO_INPUT_VAL >> BUT_RIGHT) & 0b1) delay(DUR);
    }
  }
  return length + 1;
}

int main(void) {
  int current_length = 2;

  // Enable input for BUT_LEFT and BUT_RIGHT
  *GPIO_INPUT_EN |= (1 << BUT_LEFT) | (1 << BUT_RIGHT);
  // Enable output for LED_LEFT and LED_RIGHT
  *GPIO_OUTPUT_EN |= (1 << LED_LEFT) | (1 << LED_RIGHT);

  while (1) {
    current_length = level(current_length);
    // pause between levels
    delay(DUR * 4);
  }
}
