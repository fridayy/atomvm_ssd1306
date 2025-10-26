-module(atomvm_ssd1306).

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_continue/2]).
-export([start_link/0, start_link/1, display_text/3, clear_page/2, clear_display/1]).


-include("ssd1306.hrl").
-include("font8x8_basic_lut.hrl").

-type supported_resolution() :: '128x32'.
-type opts() :: #{i2c => #{
                           scl => 0..64,
                           sda => 0..64,
                           clock_speed_hz => 1..120000,
                           address => integer()
                          },
                  resolution => supported_resolution()
                  }.

-export_type([opts/0]).

-define(DEFAULT_I2C_CONFIG, #{
                              scl => 21,
                              sda => 22,
                              clock_speed_hz => 40000,
                              address => ?I2C_ADDR
                             }).
-define(SSD1306_128x32_INIT_CMDS, [
                                   ?CMD_DISPLAY_OFF,
                                   ?CMD_SET_DISPLAY_CLOCK_DIV, 16#80,
                                   ?CMD_SET_MULTIPLEX, 31,
                                   ?CMD_SET_DISPLAY_OFFSET, 16#00,
                                   ?CMD_SET_START_LINE bor 16#00,
                                   ?CMD_CHARGEPUMP, 16#14,
                                   ?CMD_SEG_REMAP,
                                   ?CMD_COM_SCAN_DEC,
                                   ?CMD_SET_COM_PINS, 16#02,
                                   ?CMD_SET_CONTRAST, 16#7F,
                                   ?CMD_SET_PRECHARGE, 16#22,
                                   ?CMD_SET_VCOM_DETECT, 16#40,
                                   ?CMD_MEMORY_MODE, 16#02, % page mode
                                   16#00,
                                   16#10,
                                   ?CMD_DISPLAY_ALL_ON_RESUME,
                                   ?CMD_NORMAL_DISPLAY,
                                   ?CMD_DISPLAY_ON
                                  ]).

-record(state, {
           i2c_handle :: term() | undefined,
           device_address :: integer(),
           resolution :: supported_resolution()
          }).

%% api


-spec start_link() -> gen_server:start_ret().
start_link() ->
    gen_server:start_link(?MODULE, #{}, []).

-spec start_link(Opts :: opts()) -> gen_server:start_ret().
start_link(Opts) ->
    gen_server:start_link(?MODULE, Opts, []).

-spec display_text(Pid :: pid(), Page :: 0..8, Binary :: binary()) -> ok.
display_text(Pid, Page, Binary) ->
    Text = binary_to_list(Binary),
    lists:foldl(fun(Char, Acc) -> 
                          Buffer = lists:nth(Char + 1, ?font8x8_basic_lut),
                          gen_server:call(Pid, {display, Page, Acc, Buffer}),
                          Acc + 8
                  end, 0, Text),
    ok.

clear_page(Pid, Page) ->
    display_text(Pid, Page, binary:copy(<<" ">>, 16)).

clear_display(Pid) ->
    display_text(Pid, 0, binary:copy(<<" ">>, 16)),
    display_text(Pid, 1, binary:copy(<<" ">>, 16)),
    display_text(Pid, 2, binary:copy(<<" ">>, 16)),
    display_text(Pid, 3, binary:copy(<<" ">>, 16)).

%% gen_server callbacks
init(Opts) ->
    #{
      sda := SdaPin,
      scl := SclPin,
      clock_speed_hz := ClckSpd,
      address := Addr
     } = maps:get(i2c, Opts, ?DEFAULT_I2C_CONFIG),
    Resolution = maps:get(resolution, Opts, '128x32'),
    I2c = i2c:open([{scl, SclPin}, {sda, SdaPin}, {clock_speed_hz, ClckSpd}]),
    {ok, #state{
            i2c_handle = I2c,
            device_address = Addr,
            resolution = Resolution
           }, {continue, init_display}}.

handle_continue(init_display, #state{i2c_handle = I2c, resolution = '128x32', device_address = DeviceAddress} = State) ->
    i2c:begin_transmission(I2c, DeviceAddress),
    i2c:write_byte(I2c, ?CMD_START),
    lists:foreach(fun(Cmd) -> 
                          i2c:write_byte(I2c, Cmd)
                  end, ?SSD1306_128x32_INIT_CMDS),
    i2c:end_transmission(I2c),
    {noreply, State}.


handle_call({display, Page, Segment, Buffer}, _From, #state{i2c_handle = I2c, device_address = DeviceAddress} = State) ->
    ColumnLow = Segment band 16#0F,
    ColumnHigh = (Segment bsr 4) band 16#0F,
    i2c:begin_transmission(I2c, DeviceAddress),
    i2c:write_byte(I2c, 16#00),
    i2c:write_byte(I2c, ColumnLow),
    i2c:write_byte(I2c, 16#10 + ColumnHigh),
    i2c:write_byte(I2c, 16#B0 bor Page),
    i2c:end_transmission(I2c),
    %% write buffer to page
    i2c:begin_transmission(I2c, ?I2C_ADDR),
    i2c:write_byte(I2c, 16#40),
    i2c:write_bytes(I2c, Buffer),
    i2c:end_transmission(I2c),
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.
