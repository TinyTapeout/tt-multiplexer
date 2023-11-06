SOURCE_FILES = project.v uart_tx.v ../i2c_master.v ../i2c_eeprom.v ../tt_autosel.v
TARGET = impl/pnr/project.fs
GW_SH = $(GOWIN_HOME)/IDE/bin/gw_sh

$(TARGET): $(SOURCE_FILES)
	$(GW_SH) project.tcl

.PHONY: all
all: $(TARGET)

.PHONY: sram
sram: $(TARGET)
	openFPGALoader $(TARGET)

.PHONY: flash
flash: $(TARGET)
	openFPGALoader -f $(TARGET)

.PHONY: clean
clean:
	rm -rf impl