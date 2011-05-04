# Ugly workaround to catch a space in a variable
nothing		=
space		= $(nothing) $(nothing)

# Environment
MAKECFG		= config.mk

AVR32_TOOLCHAIN	= /usr/local/avr32/bin/avr32-

CC			= $(AVR32_TOOLCHAIN)gcc
CXX			= $(AVR32_TOOLCHAIN)g++
LD			= $(AVR32_TOOLCHAIN)g++
FLAGS		= $(PART:%=-mpart=%) -Os
IQUOTE		= $(ALL_INC_PATH:%=-iquote%)
CFLAGS		= $(FLAGS) $(IQUOTE) $(DEFS)
CXXFLAGS	= $(FLAGS) $(IQUOTE) $(DEFS)
ASFLAGS		= $(FLAGS) $(IQUOTE) $(DEFS)
LDFLAGS		= $(FLAGS) -Wl,--section-start,.reset=0x80002000

OBJCOPY		= $(AVR32_TOOLCHAIN)objcopy

DFU			= /usr/local/avr32/bin/dfu-programmer
DFUFLAGS	= $(PART:%=at32%)

SIZE		= $(AVR32_TOOLCHAIN)size
SIZEFLAGS	= --format=berkeley

DUMP		= $(AVR32_TOOLCHAIN)objdump
DUMPFLAGS	= -d

TARGET		= $(subst $(space),_,$(TARGET_NAME))
BUILD_DIR	= build

C_SRC		=
CPP_SRC		=
AS_SRC		=


# UC3 Software Framework
UCSFW_PATH = /usr/local/avr32/avr32/include/UC3
APPS_PATH = $(UCSFW_PATH)/APPLICATIONS
BRDS_PATH = $(UCSFW_PATH)/BOARDS
COMP_PATH = $(UCSFW_PATH)/COMPONENTS
DRVR_PATH = $(UCSFW_PATH)/DRIVERS
SERV_PATH = $(UCSFW_PATH)/SERVICES
UTIL_PATH = $(UCSFW_PATH)/UTILS

UCSFW_DRIVERS	=

UCSFW_INC_PATH		= \
	$(UCSFW_DRIVERS:%=$(DRVR_PATH)/%) \
	$(UCSFW_SERVICES:%=$(SERV_PATH)/%)
UCSFW_C_SRC			= $(foreach x,$(UCSFW_INC_PATH),$(x)/$(shell echo $(notdir $(x)) | tr A-Z a-z).c)


# Derived Environment
ELF			= $(TARGET).elf
HEX			= $(TARGET).hex
BIN			= $(TARGET).bin

ALL_INC_PATH	= $(INC_PATH) $(UCSFW_INC_PATH) ./
ALL_C_SRC		= $(C_SRC) $(UCSFW_C_SRC)
ALL_CPP_SRC		= $(CPP_SRC)
ALL_AS_SRC		= $(AS_SRC)

OBJFILES	= $(ALL_C_SRC:.c=.oc) $(ALL_CPP_SRC:.cpp=.ocpp) $(ALL_AS_SRC:.S=.oS)


# Create the build directory
$(BUILD_DIR):
	mkdir $(BUILD_DIR)


# Include the configuration
include $(MAKECFG)


# C source files (compile & assemble)
%.oc: %.c $(BUILD_DIR)
	$(CC) -c $(CFLAGS) -o $(BUILD_DIR)/$(subst /,-,$@) $<

# C++ source files (compile & assemble)
%.ocpp: %.cpp $(BUILD_DIR)
	$(CXX) -c $(CXXFLAGS) -o $(BUILD_DIR)/$(subst /,-,$@) $<

# Assembler source files (assemble)
%.oS: %.S $(BUILD_DIR)
	$(CC) -c $(ASFLAGS) -o $(BUILD_DIR)/$(subst /,-,$@) $<


# Link (create the ELF output file)
$(ELF): $(OBJFILES)
	$(LD) $(LDFLAGS) $(addprefix $(BUILD_DIR)/,$(subst /,-,$+)) -o $(BUILD_DIR)/$@
	$(SIZE) $(SIZEFLAGS) $(BUILD_DIR)/$@
	$(DUMP) $(DUMPFLAGS) $(BUILD_DIR)/$@ > $(addsuffix .S,$(BUILD_DIR)/$@)


# Create Intel HEX from ELF
$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $(BUILD_DIR)/$< $(BUILD_DIR)/$@

# Create Binary from ELF
$(BIN): $(ELF)
	$(OBJCOPY) -O binary $(BUILD_DIR)/$< $(BUILD_DIR)/$@


# Erase the chip
erase:
	$(DFU) $(DFUFLAGS) erase

# Start the application
start:
	$(DFU) $(DFUFLAGS) start

# Flash the chip
flash: $(HEX)
	$(DFU) $(DFUFLAGS) flash --suppress-bootloader-mem $(BUILD_DIR)/$(HEX)


# Shortcuts
compile: $(HEX)
program: $(HEX) erase flash start
