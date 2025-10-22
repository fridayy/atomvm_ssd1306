%% see: https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf

%% default i2c address
-define(I2C_ADDR, 16#3C).

%% commands
-define(CMD_START, 16#00).
-define(CMD_SET_LOW_COLUMN,16#00).
-define(CMD_SET_HIGH_COLUMN,16#10).
-define(CMD_MEMORY_MODE,16#20).
-define(CMD_COLUMN_ADDR,16#21).
-define(CMD_PAGE_ADDR,16#22).
-define(CMD_SET_START_LINE,16#40).
-define(CMD_DEFAULT_ADDRESS,16#78).
-define(CMD_SET_CONTRAST,16#81).
-define(CMD_CHARGEPUMP,16#8D).
-define(CMD_SEG_REMAP,16#A1).
-define(CMD_DISPLAY_ALL_ON_RESUME,16#A4).
-define(CMD_DISPLAY_ALL_ON,16#A5).
-define(CMD_NORMAL_DISPLAY,16#A6).
-define(CMD_INVERT_DISPLAY,16#A7).
-define(CMD_SET_MULTIPLEX,16#A8).
-define(CMD_DISPLAY_OFF,16#AE).
-define(CMD_DISPLAY_ON,16#AF).
-define(CMD_SET_PAGE,16#B0).
-define(CMD_COM_SCAN_INC,16#C0).
-define(CMD_COM_SCAN_DEC,16#C8).
-define(CMD_SET_DISPLAY_OFFSET,16#D3).
-define(CMD_SET_DISPLAY_CLOCK_DIV,16#D5).
-define(CMD_SET_PRECHARGE,16#D9).
-define(CMD_SET_COM_PINS,16#DA).
-define(CMD_SET_VCOM_DETECT,16#DB).
-define(CMD_SWITCH_CAP_VCC,16#02).
-define(CMD_NOP,16#E3).
