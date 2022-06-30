/*================================================*\
		  Filename ﹕
			Author ﹕
	  Description  ﹕超声波检测距离模块
					本模块理论测试距离 2cm~510cm
						输出结果保留两位小数
		 Called by ﹕
Revision History   ﹕ mm/dd/202x
		  			  Revision 1.0
  			  Email﹕ 
			Company﹕ 
\*================================================*/
module 	hc_sr_echo(
	input  wire 		Clk		, //clock 50MHz
	input  wire			clk_us	, //system clock 1MHz
	input  wire 		Rst_n	, //reset ，low valid
		   
	input  wire 		echo	, //
	output wire [18:00]	data_o	  //检测距离，保留3位小数，*1000实现
);
/* 		S(um) = 17 * t 		-->  x.abc cm	*/
//Parameter Declarations
	parameter T_MAX = 16'd60_000;//510cm 对应计数值

//Interrnal wire/reg declarations
	reg				r1_echo,r2_echo; //边沿检测	
	wire			echo_pos,echo_neg; //
	
	reg		[15:00]	cnt		; //Counter 
	wire			add_cnt ; //Counter Enable
	wire			end_cnt ; //Counter Reset 
	
	reg		[18:00]	data_r	;
//Logic Description
	//如果使用clk_us 检测边沿，延时2us，差值过大
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			r1_echo <= 1'b0;
			r2_echo <= 1'b0;
		end  
		else begin  
			r1_echo <= echo;
			r2_echo <= r1_echo;
		end  
	end
	
	assign echo_pos = r1_echo & ~r2_echo;
	assign echo_neg = ~r1_echo & r2_echo;
	
	
	always @(posedge clk_us or negedge Rst_n)begin  
		if(!Rst_n)begin  
			cnt <= 'd0; 
		end 
		else if(add_cnt)begin  
			if(end_cnt)begin  
				cnt <= cnt; 
			end  
			else begin  
				cnt <= cnt + 1'b1; 
			end  
		end  
		else begin  //echo 低电平 归零
			cnt <= 'd0;  
		end  
	end 
	
	assign add_cnt = echo; 
	assign end_cnt = add_cnt && cnt >= T_MAX - 1; //超出最大测量范围则保持不变，极限
	
	always @(posedge Clk or negedge Rst_n)begin  
		if(!Rst_n)begin  
			data_r <= 'd2;
		end  
		else if(echo_neg)begin  
			data_r <= (cnt << 4) + cnt;
		end  
		else begin  
			data_r <= data_r;
		end  
	end //always end
	
	assign data_o = data_r >> 1;

endmodule 
