<html><head><meta charset="GB2312"><title>CM0DS-DesignKit.zip AHBVGASYS.v</title>
<LINK href="/inc/read_style.css" type=text/css rel=stylesheet></head>
<body>
<p><a href=http://www.pudn.com>www.pudn.com</a> &gt; <a href="http://www.pudn.com/Download/item/id/2490414.html">CM0DS-DesignKit.zip</a> &gt AHBVGASYS.v, change:2012-05-14,size:6639b</p><!-- saved from http://www.pudn.com -->
<script src="/inc/gg_read1.js"></script><BR>
<pre name="code" class="v">
////////////////////////////////////////////////////////////////////////////////// 
//END USER LICENCE AGREEMENT                                                    // 
//                                                                              // 
//Copyright (c) 2012, ARM All rights reserved.                                  // 
//                                                                              // 
//THIS END USER LICENCE AGREEMENT (揕ICENCE�) IS A LEGAL AGREEMENT BETWEEN      // 
//YOU AND ARM LIMITED ("ARM") FOR THE USE OF THE SOFTWARE EXAMPLE ACCOMPANYING  // 
//THIS LICENCE. ARM IS ONLY WILLING TO LICENSE THE SOFTWARE EXAMPLE TO YOU ON   // 
//CONDITION THAT YOU ACCEPT ALL OF THE TERMS IN THIS LICENCE. BY INSTALLING OR  // 
//OTHERWISE USING OR COPYING THE SOFTWARE EXAMPLE YOU INDICATE THAT YOU AGREE   // 
//TO BE BOUND BY ALL OF THE TERMS OF THIS LICENCE. IF YOU DO NOT AGREE TO THE   // 
//TERMS OF THIS LICENCE, ARM IS UNWILLING TO LICENSE THE SOFTWARE EXAMPLE TO    // 
//YOU AND YOU MAY NOT INSTALL, USE OR COPY THE SOFTWARE EXAMPLE.                // 
//                                                                              // 
//ARM hereby grants to you, subject to the terms and conditions of this Licence,// 
//a non-exclusive, worldwide, non-transferable, copyright licence only to       // 
//redistribute and use in source and binary forms, with or without modification,// 
//for academic purposes provided the following conditions are met:              // 
//a) Redistributions of source code must retain the above copyright notice, this// 
//list of conditions and the following disclaimer.                              // 
//b) Redistributions in binary form must reproduce the above copyright notice,  // 
//this list of conditions and the following disclaimer in the documentation     // 
//and/or other materials provided with the distribution.                        // 
//                                                                              // 
//THIS SOFTWARE EXAMPLE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ARM     // 
//EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING     // 
//WITHOUT LIMITATION WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR // 
//PURPOSE, WITH RESPECT TO THIS SOFTWARE EXAMPLE. IN NO EVENT SHALL ARM BE LIABLE/ 
//FOR ANY DIRECT, INDIRECT, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY/ 
//KIND WHATSOEVER WITH RESPECT TO THE SOFTWARE EXAMPLE. ARM SHALL NOT BE LIABLE // 
//FOR ANY CLAIMS, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, // 
//TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE    // 
//EXAMPLE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE EXAMPLE. FOR THE AVOIDANCE/ 
// OF DOUBT, NO PATENT LICENSES ARE BEING LICENSED UNDER THIS LICENSE AGREEMENT.// 
////////////////////////////////////////////////////////////////////////////////// 
 
 
module AHBVGA( 
  input wire HCLK, 
  input wire HRESETn, 
  input wire [31:0] HADDR, 
  input wire [31:0] HWDATA, 
  input wire HREADY, 
  input wire HWRITE, 
  input wire [1:0] HTRANS, 
  input wire HSEL, 
   
  output wire [31:0] HRDATA, 
  output wire HREADYOUT, 
   
  output wire hsync, 
  output wire vsync, 
  output wire [7:0] rgb 
); 
  //Register locations 
  localparam IMAGEADDR = 4'hA; 
  localparam CONSOLEADDR = 4'h0; 
   
  //Internal AHB signals 
  reg last_HWRITE; 
  reg last_HSEL; 
  reg [1:0] last_HTRANS; 
  reg [31:0] last_HADDR; 
   
  wire [7:0] console_rgb; //console rgb signal               
  reg [7:0] rgb_reg;      //rgb register account for delay 
  wire video_on;          //display area 
  wire [9:0] pixel_x;     //current x pixel 
  wire [9:0] pixel_y;     //current y pixel 
  wire p_tick;            //25Mhz clk tick 
   
  reg console_write;      //write to console 
  reg [7:0] console_wdata;//data to write to console 
  reg image_write;        //write to image 
  reg [7:0] image_wdata;  //data to write to image 
   
  wire image_on;          //display only top right 
  wire [7:0] image_rgb;   //image color 
   
  wire scroll;            //scrolling signal 
   
  wire sel_console;        
  wire sel_image; 
   
   
  always @(posedge HCLK) 
  if(HREADY) 
    begin 
      last_HADDR &lt;= HADDR; 
      last_HWRITE &lt;= HWRITE; 
      last_HSEL &lt;= HSEL; 
      last_HTRANS &lt;= HTRANS; 
    end 
     
  //Give time for the screen to refresh before writing 
  assign HREADYOUT = ~scroll;    
   
  vga_sync uvga_sync( 
    .clk(HCLK), 
    .resetn(HRESETn), 
    .hsync(hsync), 
    .vsync(vsync), 
    .video_on(video_on), 
    .p_tick(p_tick), 
    .pixel_x(pixel_x), 
    .pixel_y(pixel_y) 
  ); 
   
  vga_console uvga_console( 
    .clk(HCLK), 
    .resetn(HRESETn), 
    .video_on(video_on), 
    .pixel_x(pixel_x), 
    .pixel_y(pixel_y), 
    .text_rgb(console_rgb), 
    .font_we(console_write), 
    .font_data(console_wdata), 
    .scroll(scroll) 
    ); 
 
  vga_image uvga_image( 
    .clk(HCLK), 
    .resetn(HRESETn), 
    .address(last_HADDR[17:2]), 
    .video_on(video_on), 
    .pixel_x(pixel_x), 
    .pixel_y(pixel_y), 
    .image_we(image_write), 
    .image_data(image_wdata), 
    .image_on(image_on), 
    .image_rgb(image_rgb) 
    ); 
 
  assign sel_console = (last_HADDR[23:20]==4'h0); 
  assign sel_image = (last_HADDR[23:20]==4'hA); 
   
  //Set console write and write data 
  always @(posedge HCLK, negedge HRESETn) 
  begin 
    if(!HRESETn) 
      begin 
        console_write &lt;= 0; 
        console_wdata &lt;= 0; 
      end 
    else if(last_HWRITE & last_HSEL & last_HTRANS[1] & HREADYOUT & sel_console) 
      begin 
        console_write &lt;= 1'b1; 
        console_wdata &lt;= HWDATA[7:0]; 
      end 
    else 
      begin 
        console_write &lt;= 1'b0; 
        console_wdata &lt;= 0; 
      end 
  end 
   
  //Set image write and image write data 
  always @(posedge HCLK, negedge HRESETn) 
  begin 
    if(!HRESETn) 
      begin 
        image_write &lt;= 0; 
        image_wdata &lt;= 0; 
      end 
    else if(last_HWRITE & last_HSEL & last_HTRANS[1] & HREADYOUT & sel_image) 
      begin 
        image_write &lt;= 1'b1; 
        image_wdata &lt;= HWDATA[7:0]; 
      end 
    else 
      begin 
        image_write &lt;= 1'b0; 
        image_wdata &lt;= 0; 
      end 
  end 
 
 
  //RGB output buffer 
  always @(posedge HCLK, negedge HRESETn) 
  begin 
    if(!HRESETn) 
      rgb_reg &lt;= 8'h00; 
    else if (p_tick) 
      if(image_on && !console_rgb) 
        rgb_reg &lt;= image_rgb; 
      else 
        rgb_reg &lt;= console_rgb; 
  end 
 
  //Set output 
  assign rgb = (video_on) ? rgb_reg : 8'h00; 
   
   
 
endmodule 
   
   
</pre>
<script src="/inc/gg_read2.js"></script><BR>
</body></html>
