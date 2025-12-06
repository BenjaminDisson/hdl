<html><head><meta charset="GB2312"><title>CM0DS-DesignKit.zip cm0dsasm.s</title>
<LINK href="/inc/read_style.css" type=text/css rel=stylesheet></head>
<body>
<p><a href=http://www.pudn.com>www.pudn.com</a> &gt; <a href="http://www.pudn.com/Download/item/id/2490414.html">CM0DS-DesignKit.zip</a> &gt cm0dsasm.s, change:2012-01-08,size:4890b</p><!-- saved from http://www.pudn.com -->
<script src="/inc/gg_read1.js"></script><BR>
<pre name="code" class="s">
Stack_Size      EQU     0x00040000							; 256KB of STACK 
 
                AREA    STACK, NOINIT, READWRITE, ALIGN=4 
Stack_Mem       SPACE   Stack_Size 
__initial_sp 
 
 
Heap_Size       EQU     0x00100000 							; 1MB of HEAP 
 
                AREA    HEAP, NOINIT, READWRITE, ALIGN=4 
__heap_base 
Heap_Mem        SPACE   Heap_Size 
__heap_limit 
 
 
; Vector Table Mapped to Address 0 at Reset 
 
						PRESERVE8 
                		THUMB 
 
        				AREA	RESET, DATA, READONLY 
        				EXPORT 	__Vectors 
					 
__Vectors		    	DCD		__initial_sp 
        				DCD		Reset_Handler 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD 	0 
        				DCD		0 
        				DCD		0 
        				DCD 	0 
        				DCD		0 
        				 
        				; External Interrupts 
						        				 
        				DCD		UART_Handler 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
        				DCD		0 
               
                AREA |.text|, CODE, READONLY 
;Reset Handler 
Reset_Handler   PROC 
                GLOBAL Reset_Handler 
                ENTRY 
                LDR     R1, =0xE000E100           ;Interrupt Set Enable Register 
                LDR     R0, =0x00000001            
                STR     R0, [R1] 
				IMPORT  __main 
                LDR     R0, =__main                
                BX      R0                        ;Branch to __main 
                ENDP 
                 
UART_Handler    PROC 
                EXPORT UART_Handler 
				IMPORT UART_ISR 
                PUSH    {R0,R1,R2,LR} 
                LDR     R1, =0x51000000               ;UART 
                LDR     R0, [R1]                      ;Get Data from UART 
                STR     R0, [R1]                      ;Write to UART 
 
				BL UART_ISR 
 
                POP     {R0,R1,R2,PC} 
                ENDP 
 
                 
                ALIGN 4 
 
; User Initial Stack & Heap 
                IF      :DEF:__MICROLIB 
                EXPORT  __initial_sp 
                EXPORT  __heap_base 
                EXPORT  __heap_limit 
                ELSE 
                IMPORT  __use_two_region_memory 
                EXPORT  __user_initial_stackheap 
__user_initial_stackheap 
 
                LDR     R0, =  Heap_Mem 
                LDR     R1, =(Stack_Mem + Stack_Size) 
                LDR     R2, = (Heap_Mem +  Heap_Size) 
                LDR     R3, = Stack_Mem 
                BX      LR 
 
                ALIGN 
 
                ENDIF 
 
 
		END                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
   </pre>
<script src="/inc/gg_read2.js"></script><BR>
</body></html>
