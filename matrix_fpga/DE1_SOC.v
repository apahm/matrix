
module DE1_SOC(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,
	
	
	/// RGB Matrix ////////////////
	output	wire				r0,
	output	wire				g0,
	output	wire				b0,
	output	wire				r1,
	output	wire				g1,
	output	wire				b1,
	
	output	wire				r2,
	output	wire				g2,
	output	wire				b2,
	output	wire				r3,
	output	wire				g3,
	output	wire				b3,
	
	output	wire		[2:0]	a,
	output	wire				blank,
	output	wire				sclk,
	output	wire				latch,

	//////////// HPS //////////
	inout 		          		HPS_CONV_USB_N,
	output		    [14:0]		HPS_DDR3_ADDR,
	output		     [2:0]		HPS_DDR3_BA,
	output		          		HPS_DDR3_CAS_N,
	output		          		HPS_DDR3_CKE,
	output		          		HPS_DDR3_CK_N,
	output		          		HPS_DDR3_CK_P,
	output		          		HPS_DDR3_CS_N,
	output		     [3:0]		HPS_DDR3_DM,
	inout 		    [31:0]		HPS_DDR3_DQ,
	inout 		     [3:0]		HPS_DDR3_DQS_N,
	inout 		     [3:0]		HPS_DDR3_DQS_P,
	output		          		HPS_DDR3_ODT,
	output		          		HPS_DDR3_RAS_N,
	output		          		HPS_DDR3_RESET_N,
	input 		          		HPS_DDR3_RZQ,
	output		          		HPS_DDR3_WE_N,
	output		          		HPS_ENET_GTX_CLK,
	inout 		          		HPS_ENET_INT_N,
	output		          		HPS_ENET_MDC,
	inout 		          		HPS_ENET_MDIO,
	input 		          		HPS_ENET_RX_CLK,
	input 		     [3:0]		HPS_ENET_RX_DATA,
	input 		          		HPS_ENET_RX_DV,
	output		     [3:0]		HPS_ENET_TX_DATA,
	output		          		HPS_ENET_TX_EN,
	inout 		     [3:0]		HPS_FLASH_DATA,
	output		          		HPS_FLASH_DCLK,
	output		          		HPS_FLASH_NCSO,
	inout 		     [1:0]		HPS_GPIO,
	inout 		          		HPS_GSENSOR_INT,
	inout 		          		HPS_I2C1_SCLK,
	inout 		          		HPS_I2C1_SDAT,
	inout 		          		HPS_I2C2_SCLK,
	inout 		          		HPS_I2C2_SDAT,
	inout 		          		HPS_I2C_CONTROL,
	inout 		          		HPS_KEY,
	inout 		          		HPS_LED,
	output		          		HPS_SD_CLK,
	inout 		          		HPS_SD_CMD,
	inout 		     [3:0]		HPS_SD_DATA,
	output		          		HPS_SPIM_CLK,
	input 		          		HPS_SPIM_MISO,
	output		          		HPS_SPIM_MOSI,
	inout 		          		HPS_SPIM_SS,
	input 		          		HPS_UART_RX,
	output		          		HPS_UART_TX,
	input 		          		HPS_USB_CLKOUT,
	inout 		     [7:0]		HPS_USB_DATA,
	input 		          		HPS_USB_DIR,
	input 		          		HPS_USB_NXT,
	output		          		HPS_USB_STP
);

wire 			reset;
wire  			bridge_waitrequest;      //           mm_bridge_0_m0.waitrequest
wire	[31:0]	bridge_readdata;         //                         .readdatawire
wire			bridge_readdatavalid;    //                         .readdatavalid      //                         .burstcount
wire	[31:0]	bridge_writedata;        //                         .writedata
wire	[9:0]   bridge_address;          //                         .address
wire			bridge_write;            //                         .write
wire			bridge_read;


wire clk_100;

wire [28:0] sdram_address;
wire sdram_waitrequest;
wire sdram_readdatavalid;
wire sdram_read;
wire [63:0] sdram_readdata;
wire [28:0] begin_dma_address;
wire [7:0] 	sdram_burstcount;
wire dma_start;
wire [31:0] size_of_buffer;


wire [47:0] dist_dma;
wire write_enable;
wire [9:0] 	dist_address;
wire dist_clock;

wire [47:0] matrix_memory_data;
wire matrix_write_enable;
wire [9:0] 	matrix_memory_address;
wire matrix_memory_clock;

wire mem_mux;
wire matrix_rst;

avalon_csr avalon_csr(
	.clk(CLOCK_50),
	.rst(reset), 
	.mm_waitrequest(bridge_waitrequest),      //           mm_bridge_0_m0.waitrequest
	.mm_readdata(bridge_readdata),         //                         .readdata
	.mm_readdatavalid(bridge_readdatavalid),    //                         .readdatavalid
	.mm_writedata(bridge_writedata),        //                         .writedata
	.mm_address(bridge_address),          //                         .address
	.mm_write(bridge_write),            //                         .write
	.mm_read(bridge_read),   
	.reg0(dma_start),
	.reg1(begin_dma_address),
	.reg2(size_of_buffer),
	.reg3(mem_mux),
	.reg4(matrix_rst)
);

pll pll (
	.refclk(CLOCK_50),   //  refclk.clk
	.rst(reset),      //   reset.reset
	.outclk_0(clk_100) 

);

matrix matrix (
    .rst_n					(matrix_rst),
    .clk					(CLOCK_50),

    .r0						(r0),
    .g0						(g0),
    .b0						(b0),
    .r1						(r1),
    .g1						(g1),
    .b1						(b1),
	 
	.r2						(r2),
    .g2						(g2),
    .b2						(b2),
    .r3						(r3),
    .g3						(g3),
    .b3						(b3),
    .a						(a),
    .blank					(blank),
    .sclk					(sclk),
    .latch					(latch),
	.mem_address(matrix_memory_address),
	.mem_clk(matrix_memory_clock),
	.mem_write_enable(matrix_write_enable),
	.mem_output_data(matrix_memory_data)
);



dma_from_sdram dma_from_sdram (
	.clk(CLOCK_50),
   	.rst(reset),
	 
	.start(dma_start),
	.begin_address(begin_dma_address),

	.sdram0_data_address(sdram_address),          
	.sdram0_data_waitrequest(sdram_waitrequest),        
	.sdram0_data_readdata(sdram_readdata),           
	.sdram0_data_readdatavalid(sdram_readdatavalid),      
	.sdram0_data_read(sdram_read),  
	.sdram0_data_burstcount(sdram_burstcount),	
 
   	.dist_data(dist_dma),
	.dist_address(dist_address),
	.dist_clk(dist_clock),
	.write_enable(write_enable),
	.size_buffer(size_of_buffer)

);

wire [9:0] ram_address;
wire ram_clk;
wire [47:0] ram_data_in;
wire [47:0] ram_data_out;
wire ram_wren;

ram_one ram_one(
	.address(ram_address),
	.clock(ram_clk),
	.data(ram_data_in),
	.wren(ram_wren),
	.q(ram_data_out)
);

// Если mux = 1, то подключается матрица, если mux = 0, то dma
memory_mux memory_mux(

   .slave_0_dist_address(dist_address),
	.slave_0_dist_data(dist_dma),
	.slave_0_write_enable(write_enable),
	.slave_0_dist_clk(dist_clock), 

	.slave_1_dist_out(matrix_memory_data),
   .slave_1_dist_address(matrix_memory_address),
	.slave_1_write_enable(matrix_write_enable),
	.slave_1_dist_clk(matrix_memory_clock),  

	.master_dist_out(ram_data_out),
   .master_dist_address(ram_address),
	.master_dist_data(ram_data_in),
	.master_write_enable(ram_wren),
	.master_dist_clk(ram_clk),

	.mux(mem_mux)

);

hps_system hps_system (
	.clk_clk(CLOCK_50),
		
	.hps_io_hps_io_emac1_inst_TXD0(HPS_ENET_TX_DATA[0]),  
	.hps_io_hps_io_emac1_inst_TXD1(HPS_ENET_TX_DATA[1]),  
	.hps_io_hps_io_emac1_inst_TXD2(HPS_ENET_TX_DATA[2]),  
	.hps_io_hps_io_emac1_inst_TXD3(HPS_ENET_TX_DATA[3]),
	
	.hps_io_hps_io_emac1_inst_MDIO(HPS_ENET_MDIO),  
	.hps_io_hps_io_emac1_inst_MDC(HPS_ENET_MDC),
	
	.hps_io_hps_io_emac1_inst_RX_CTL(HPS_ENET_RX_DV),
	.hps_io_hps_io_emac1_inst_TX_CTL(HPS_ENET_TX_EN),
	
	.hps_io_hps_io_emac1_inst_RX_CLK(HPS_ENET_RX_CLK),
	.hps_io_hps_io_emac1_inst_TX_CLK(HPS_ENET_GTX_CLK),
	
	.hps_io_hps_io_emac1_inst_RXD0(HPS_ENET_RX_DATA[0]),  
	.hps_io_hps_io_emac1_inst_RXD1(HPS_ENET_RX_DATA[1]),  
	.hps_io_hps_io_emac1_inst_RXD2(HPS_ENET_RX_DATA[2]),  
	.hps_io_hps_io_emac1_inst_RXD3(HPS_ENET_RX_DATA[3]),
		
	.hps_io_hps_io_sdio_inst_CMD(HPS_SD_CMD),    
	.hps_io_hps_io_sdio_inst_D0(HPS_SD_DATA[0]),
	.hps_io_hps_io_sdio_inst_D1(HPS_SD_DATA[1]),
	.hps_io_hps_io_sdio_inst_D2(HPS_SD_DATA[2]),
	.hps_io_hps_io_sdio_inst_D3(HPS_SD_DATA[3]),
	.hps_io_hps_io_sdio_inst_CLK(HPS_SD_CLK),
	
	.hps_io_hps_io_uart0_inst_RX(HPS_UART_RX),    
	.hps_io_hps_io_uart0_inst_TX(HPS_UART_TX),
		 
	.leds_external_connection_export(LEDR),
		
	.memory_mem_a(HPS_DDR3_ADDR),                   
	.memory_mem_ba(HPS_DDR3_BA),                  
	.memory_mem_ck(HPS_DDR3_CK_P),                  
	.memory_mem_ck_n(HPS_DDR3_CK_N),                
	.memory_mem_cke(HPS_DDR3_CKE),                 
	.memory_mem_cs_n(HPS_DDR3_CS_N),                
	.memory_mem_ras_n(HPS_DDR3_RAS_N),               
	.memory_mem_cas_n(HPS_DDR3_CAS_N),               
	.memory_mem_we_n(HPS_DDR3_WE_N),                
	.memory_mem_reset_n(HPS_DDR3_RESET_N),             
	.memory_mem_dq(HPS_DDR3_DQ),                  
	.memory_mem_dqs(HPS_DDR3_DQS_P),                 
	.memory_mem_dqs_n(HPS_DDR3_DQS_N),               
	.memory_mem_odt(HPS_DDR3_ODT),                 
	.memory_mem_dm(HPS_DDR3_DM),                  
	.memory_oct_rzqin(HPS_DDR3_RZQ),                
	.mm_bridge_0_m0_waitrequest(bridge_waitrequest),      //           mm_bridge_0_m0.waitrequest
	.mm_bridge_0_m0_readdata(bridge_readdata),         //                         .readdata
	.mm_bridge_0_m0_readdatavalid(bridge_readdatavalid),    //                         .readdatavalid      //                         .burstcount
	.mm_bridge_0_m0_writedata(bridge_writedata),        //                         .writedata
	.mm_bridge_0_m0_address(bridge_address),          //                         .address
	.mm_bridge_0_m0_write(bridge_write),            //                         .write
	.mm_bridge_0_m0_read(bridge_read),             //                         
	.reset_reset(reset),
	.sdram0_data_address(sdram_address),             //              sdram0_data.address          //                         .burstcount
	.sdram0_data_waitrequest(sdram_waitrequest),         //                         .waitrequest
	.sdram0_data_readdata(sdram_readdata),            //                         .readdata
	.sdram0_data_readdatavalid(sdram_readdatavalid),       //                         .readdatavalid
	.sdram0_data_read(sdram_read),
	.sdram0_data_burstcount(sdram_burstcount)
);	



endmodule
