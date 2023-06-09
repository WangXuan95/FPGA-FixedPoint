![语言](https://img.shields.io/badge/语言-verilog_(IEEE1364_2001)-9A90FD.svg) ![仿真](https://img.shields.io/badge/仿真-iverilog-green.svg)

[English](#en) | [中文](#cn)

　

<span id="en">Verilog-FixedPoint</span>
===========================

Verilog fixed-point library. features:

* Customizable integer bit width and fractional bit width.
* **Arithmetic** : Addition, Subtraction, Multiplication, Division, Square Root.
* **Overflow detection**: When an overflow occurs, the overflow signal = 1, and the output result will be set to a positive maximum value (upflow) or a negative minimum value (underflow).
* **Round Control** : When truncation occurs, you can choose whether to round up or not.
* Supports **converting to and from single-precision floating-point numbers (IEEE-754)**.
* All operations have **single-cycle implementation**, operations with long combinatorial logic delays have **pipeline implementation**.

　

# FixedPoint Format

A fixed-point number consists of a number of integers and a number of fractions. Its value = **the integer's complement of its binary code** divided by **2^fractional bit width** .

For example, if the integer bit width is 8 and the fractional bit width is 8, the following table shows some fixed-point values:

|   binary code    | Integer's complement | fixed-point value |      remark      |
| :--------------: | :------------------: | :---------------: | :--------------: |
| 0000000000000000 |          0           |        0.0        |       zero       |
| 0000000100000000 |         256          |        1.0        |                  |
| 1111111100000000 |         -256         |       -1.0        |                  |
| 0000000000000001 |          1           |    0.00390625     | positive minimum |
| 1111111111111111 |          -1          |    -0.00390625    | negative maximum |
| 0111111111111111 |        32767         |   127.99609375    | positive maximum |
| 1000000000000000 |        -32768        |      -128.0       | negative minimum |
| 0001010111000011 |         5571         |    21.76171875    |                  |
| 1001010110100110 |        -27226        |   -106.3515625    |                  |

All module in this repository use parameters to define the fixed-point bit width. The names of these parameters are unified:

- `WOI` and `WOF` are the integer bit width and fractional bit width of the output fixed-point number, respectively.
- For unary operations, `WII` and `WIF` are the integer and fractional widths of the input fixed-point number, respectively.
- For binocular operations, `WIIA` and `WIFA` are the integer and fractional widths of the fixed-point number of input operand A, respectively; `WIIB` and `WIFB` are the integer and fractional widths of the fixed-point number of input operand B, respectively.

Take the multiplier as an example:

```verilog
module fxp_mul # (
    parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter bit ROUND= 1
)(
    input  wire [WIIA+WIFA-1:0] ina,
    input  wire [WIIB+WIFB-1:0] inb,
    output wire [WOI +WOF -1:0] out,
    output wire overflow
);
```

　

# Module List

All synthesizable modules are implemented in [RTL/fixedpoint.v](./RTL/fixedpoint.v) . The names and functions of each module are as follows:

|      Operation       | Single-cycle ver. |   Pipelined ver.   | Pipeline stages |
| :------------------: | :---------------: | :----------------: | :-------------: |
|   width conversion   |   **fxp_zoom**    |    unnecessary     |        -        |
| Addition/Subtraction |  **fxp_addsub**   |    unnecessary     |        -        |
|       Addition       |    **fxp_add**    |    unnecessary     |        -        |
|    Multiplication    |    **fxp_mul**    |  **fxp_mul_pipe**  |        2        |
|       Division       |    **fxp_div**    |  **fxp_div_pipe**  |    WOI+WOF+3    |
|     Square Root      |   **fxp_sqrt**    | **fxp_sqrt_pipe**  |   WII/2+WIF+2   |
| Fixed-point to Float |   **fxp2float**   | **fxp2float_pipe** |    WII+WIF+2    |
| Float to Fixed-point |   **float2fxp**   | **float2fxp_pipe** |    WOI+WOF+4    |

　

# RTL Simulation

Simulation related files are in the SIM folder, where:

| source file             | description                                                  |
| ----------------------- | ------------------------------------------------------------ |
| tb_add_sub_mul_div.v   | Test single-cycle version of addition, subtraction, multiplication and division |
| tb_fxp_mul_div_pipe.v  | Test the pipelined version of multiply and divide.           |
| tb_fxp_sqrt.v          | Test Square Root.                                            |
| tb_convert_fxp_float.v | Test the conversion between fixed-point and floating-point.  |

Before using iverilog for simulation, you need to install iverilog , see: [iverilog_usage](https://github.com/WangXuan95/WangXuan95/blob/main/iverilog_usage/iverilog_usage.md)

Then double-click the corresponding .bat file to run the simulation.

　

　

　

　

　

<span id="cn">Verilog-FixedPoint</span>
===========================

Verilog 定点数库。

* 可定制整数位宽和小数位宽。
* **运算** ： 加、减、乘、除、开方。
* **溢出检测** ： 发生溢出时，溢出信号=1，输出结果会设为正最大值（上溢出）或负最小值（下溢出）。
* **舍入控制** ： 发生截断时，可选择是否进行四舍五入。
* **与单精度浮点数（IEEE754）互相转换** 。
* 所有运算均有 **单周期实现** ，组合逻辑延迟长的运算有 **流水线实现** 。

　

# 定点数格式

定点数由若干位整数和若干位小数组成。其值= **该二进制码对应的整数补码** 除以 **2^小数位数** 。

例如，若整数位数为8，小数位数为8，举例如下表：

|     二进制码     | 整数补码 | 定点数值 (8位整数，8位小数) |   备注   |
| :--------------: | :------: | :-------------------------: | :------: |
| 0000000000000000 |    0     |             0.0             |   零值   |
| 0000000100000000 |   256    |             1.0             |          |
| 1111111100000000 |   -256   |            -1.0             |          |
| 0000000000000001 |    1     |         0.00390625          | 正最小值 |
| 1111111111111111 |    -1    |         -0.00390625         | 负最大值 |
| 0111111111111111 |  32767   |        127.99609375         | 正最大值 |
| 1000000000000000 |  -32768  |           -128.0            | 负最小值 |
| 0001010111000011 |   5571   |         21.76171875         |          |
| 1001010110100110 |  -27226  |        -106.3515625         |          |

本库的模块输入输出都可以用参数 (parameter) 来定制定点数位宽，这些参数的命名是统一的：

- WOI 和 WOF 分别是输出的定点数的整数位宽和小数位宽。
- 对于单目运算， WII 和 WIF 分别是输入的定点数的整数位宽和小数位宽。
- 对于双目运算， WIIA 和 WIFA 分别是输入操作数A的定点数的整数位宽和小数位宽；WIIB 和 WIFB 分别是输入操作数B的定点数的整数位宽和小数位宽。

以乘法器为例：

```verilog
module fxp_mul # ( // 以乘法器为例
    parameter WIIA = 8,       // 输入(乘数a)的整数位宽，默认=8
    parameter WIFA = 8,       // 输入(乘数a)的小数位宽，默认=8
    parameter WIIB = 8,       // 输入(乘数b)的整数位宽，默认=8
    parameter WIFB = 8,       // 输入(乘数b)的小数位宽，默认=8
    parameter WOI  = 8,       // 输出(积)的整数位宽，默认=8
    parameter WOF  = 8,       // 输出(积)的小数位宽，默认=8
    parameter bit ROUND= 1    // 当积的小数截断时，是否四舍五入，默认是
)(
    input  wire [WIIA+WIFA-1:0] ina, // 乘数a
    input  wire [WIIB+WIFB-1:0] inb, // 乘数b
    output wire [WOI +WOF -1:0] out, // 结果(积) = 乘数a * 乘数b
    output wire overflow             // 结果是否溢出，若溢出则为 1'b1
                                     // 若为上溢出，则out被置为最大正值
                                     // 若为下溢出，则out被置为最小负值
);
```

　

# 各模块名称与功能

所有可综合的模块实现都在 RTL/fixedpoint.v 中，各模块名称和功能如下表：
|    运算    | 单周期版本(组合逻辑) |     流水线版本     | 流水线级数  |          说明          |
| :--------: | :------------------: | :----------------: | :---------: | :--------------------: |
|  位宽变换  |     **fxp_zoom**     |       不需要       |      -      |    有溢出、舍入控制    |
|    加减    |    **fxp_addsub**    |       不需要       |      -      | 具有1bit信号控制加或减 |
|     加     |     **fxp_add**      |       不需要       |      -      |                        |
|    乘法    |     **fxp_mul**      |  **fxp_mul_pipe**  |      2      |                        |
|    除法    |     **fxp_div**      |  **fxp_div_pipe**  |  WOI+WOF+3  |  单周期版时序不易收敛  |
| 开方(sqrt) |     **fxp_sqrt**     | **fxp_sqrt_pipe**  | WII/2+WIF+2 |  单周期版时序不易收敛  |
| 定点转浮点 |    **fxp2float**     | **fxp2float_pipe** |  WII+WIF+2  |  单周期版时序不易收敛  |
| 浮点转定点 |    **float2fxp**     | **float2fxp_pipe** |  WOI+WOF+4  |  单周期版时序不易收敛  |

　

# 仿真

仿真相关的文件都在 SIM 文件夹中，其中：

| 代码文件                | 说明                       |
| ----------------------- | -------------------------- |
| tb_add_sub_mul_div.v   | 测试单周期版本的加减乘除   |
| tb_fxp_mul_div_pipe.v  | 测试流水线版本的乘除       |
| tb_fxp_sqrt.v          | 测试开方运算               |
| tb_convert_fxp_float.v | 测试定点数与浮点数互相转化 |

使用 iverilog 进行仿真前，需要安装 iverilog ，见：[iverilog_usage](https://github.com/WangXuan95/WangXuan95/blob/main/iverilog_usage/iverilog_usage.md)

然后双击对应的 .bat 文件就能运行仿真。

