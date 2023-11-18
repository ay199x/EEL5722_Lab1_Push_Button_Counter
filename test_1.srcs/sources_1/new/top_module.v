`timescale 1ns / 1ps

module top_module(
    input clock_100Mhz,
    input reset,
    input btn1, //PB1
    input btn2, //PB2
    output reg [3:0] Anode_Activate, //LED control
    output reg [6:0] LED_out //cathode control
);
    
    reg [26:0] one_second_counter;
    wire one_second_enable;
    reg [15:0] displayed_number; //number16bit
    reg [3:0] LED_BCD; //4-digit number
    reg [19:0] refresh_counter; //20 bit refreash counter for 2.5 ms delay
    wire [1:0] LED_activating_counter; //2 MSBs of counter for LED control

    always @(posedge clock_100Mhz or posedge reset)
    begin
        if(reset==1)
            one_second_counter <= 0;
        else begin
            if(one_second_counter>=99999999) 
                 one_second_counter <= 0;
            else
                one_second_counter <= one_second_counter + 1;
        end
    end 
    
    assign one_second_enable = (one_second_counter==99999999)?1:0;
    always @(posedge clock_100Mhz or posedge reset)
    begin
        if(reset==1)
            displayed_number <= 0;
        else if(one_second_enable==1) begin
            if(displayed_number==99)
                displayed_number <= 0;
            else begin
                if(btn1)
                    displayed_number <= displayed_number + 1;
                else if(btn2)
                    displayed_number <= displayed_number + 10;
                else
                    displayed_number <= displayed_number + 1;
            end
        end
    end
    
    always @(posedge clock_100Mhz or posedge reset)
    begin 
        if(reset==1)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
    assign LED_activating_counter = refresh_counter[19:18];

    always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            Anode_Activate = 4'b1111; 
            //deactivate all
            LED_BCD = displayed_number/1000;
            //D3
              end
        2'b01: begin
            Anode_Activate = 4'b1111; 
            //deactivate all
            LED_BCD = (displayed_number % 1000)/100;
            //D2
              end
        2'b10: begin
            Anode_Activate = 4'b1101; 
            //LED1 ON and LED3, LED2, LED0 OFF
            LED_BCD = ((displayed_number % 1000)%100)/10;
            //D1
                end
        2'b11: begin
            Anode_Activate = 4'b1110; 
            //LED0 ON and LED3, LED2, LED1 OFF
            LED_BCD = ((displayed_number % 1000)%100)%10;
            //D0 
               end
        endcase
    end
    
    //Cathode seg
    always @(*)
    begin
        case(LED_BCD)
        4'b0000: LED_out = 7'b0000001; // "0"     
        4'b0001: LED_out = 7'b1001111; // "1" 
        4'b0010: LED_out = 7'b0010010; // "2" 
        4'b0011: LED_out = 7'b0000110; // "3" 
        4'b0100: LED_out = 7'b1001100; // "4" 
        4'b0101: LED_out = 7'b0100100; // "5" 
        4'b0110: LED_out = 7'b0100000; // "6" 
        4'b0111: LED_out = 7'b0001111; // "7" 
        4'b1000: LED_out = 7'b0000000; // "8"     
        4'b1001: LED_out = 7'b0000100; // "9" 
        default: LED_out = 7'b0000001; // "0"
        endcase
    end
 endmodule