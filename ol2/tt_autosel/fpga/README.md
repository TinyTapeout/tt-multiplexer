# Tang Nano 20K Testbench

FPGA Board: [Tang Nano 20K](https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/nano-20k.html).

You need to connect a 1 kbit or 2 kbit I2C EEPROM (e.g. 24C01 or 24C02), program the selected design id into the first two bytes of the EEPROM memory, and connect the EEPROM to the Tang Nano 20K board. After connecting the EEPROM, press the reset button (S1), and observe the ctrl output pins to see if the design id is correctly read from the EEPROM:

- `ctrl_sel_rst_n` should go low, and then high
- `ctrl_sel_inc` should pulse high according to the lowest 10 bits of the number stored in the EEPROM
- `ctrl_ena` should go high

## Pinout

| Tang Nano 20K | Function       |
|---------------|----------------|
| 74            | SDA            |
| 77            | SCL            |
| 27            | ctrl_sel_rst_n |
| 28            | ctrl_sel_inc   |
| 25            | ctrl_ena       |

## Debug interface

The test project also implements a UART debug interface (115200 baud, connected through the BL616). The debug interface will print the two bytes read from the EEPROM as a 16-bit hex number (big endian) once per second.
