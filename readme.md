# 使用Verilog HDL编写的UART串口收发器 #
## 一、特性 ##
1. 参数化波特率、数据位、校验位和停止位。
2. Altera EP4CE10 FPGA下，时钟频率50MHz，实测可在600至500000波特率下正常工作，支持5至8位数据位、5种常见校验位和1、1.5、2三种停止位。
3. 同一FPGA，时钟频率50MHz，配置为最常见的“8N1”模式时的资源消耗如下。
	<table>
	<tr>
		<th>波特率</th>
	    <th>接收</th>
		<th>发送</th>
	</tr>
	<tr>
		<td>600</td>
		<td>45 LCC + 34 LCR</td>
		<td>48 LCC + 33 LCR</td>
	</tr>
	<tr>
		<td>9600</td>
		<td>37 LCC + 30 LCR</td>
		<td>43 LCC + 29 LCR</td>
	</tr>
	<tr>
		<td>115200</td>
		<td>28 LCC + 26 LCR</td>
		<td>40 LCC + 25 LCR</td>
	</tr>
	<tr>
		<td>500000</td>
		<td>25 LCC + 24 LCR</td>
		<td>36 LCC + 23 LCR</td>
	</tr>
	</table>
## 二、注意事项 ##
1. 顶层模块top.v使用收发模块搭建了一个回环测试，由于未使用FIFO缓冲，实际测试时必须将发送模块的波特率设置得比接收模块更大一些以应对由于晶振等因素造成的外部数据发送者波特率偏高引起的测试发送模块数据阻塞问题，表现为测试发送模块未完成上一数据的发送，接收模块已将下一数据送入，引起回环数据丢失。
2. 发送模块的busy信号在整个发送过程中为高，此时模块忽略输入的数据和发送使能信号。
3. 接收模块的error信号仅对校验位进行响应，若配置为“N”无校验模式，error信号将一直保持为低。该信号仅在每次接收到一个完整数据时发生改变，若校验成功，error清0并保持，同时生成一个valid信号；若校验失败，error置1并保持，此时valid信号无动作。

# UART transceiver using Verilog HDL#
## Specifications ##
1. Parametric baudrate, data bits, check mode, and stop bits.
2. Normally work in Altera EP4CE10 FPGA, 50MHz clock frequency, 600 to 500000 boudrate, 5 to 8 data bits, "NOEMS" check mode, 1/1.5/2 stop bits. 
3. In the same FPGA and clock frequency, "8N1" mode, here is the resource usage summary. 
	<table>
	<tr>
		<th>Boudrate</th>
	    <th>Recvive</th>
		<th>Send</th>
	</tr>
	<tr>
		<td>600</td>
		<td>45 LCC + 34 LCR</td>
		<td>48 LCC + 33 LCR</td>
	</tr>
	<tr>
		<td>9600</td>
		<td>37 LCC + 30 LCR</td>
		<td>43 LCC + 29 LCR</td>
	</tr>
	<tr>
		<td>115200</td>
		<td>28 LCC + 26 LCR</td>
		<td>40 LCC + 25 LCR</td>
	</tr>
	<tr>
		<td>500000</td>
		<td>25 LCC + 24 LCR</td>
		<td>36 LCC + 23 LCR</td>
	</tr>
	</table>
## Notes ##
1. top.v is a loopback test. In this test, TX module boudrate must larger a little than RX module in case that outside TX boudrate is a little larger than boudrate settings. 
2. When TX module is busy (O\_busy == 1'b1), I\_data and I\_txen will be ignored. 
3. When RX module is set to "N" check mode, O\_error will be low forever. O\_error only change when RX module received a whole data. If check OK, O\_error will be low and keep its value to next data, at the same time O\_valid will be high for a clock cycle, otherwise O\_error will be high while O\_valid keep stay low. 