![test](https://img.shields.io/badge/test-passing-green.svg)
![platform](https://img.shields.io/badge/platform-Quartus|Vivado|iverilog-blue.svg)

Verilog-FixedPoint
===========================
SystemVerilog 定点数库。

# 特点
* **参数化定制位宽** ： **parameter** 定制整数位宽和小数位宽。
* **四则运算** ： 加减乘除。
* **高级运算** ： 目前已实现 **Sin** 和 **Sqrt** 。
* **四舍五入控制** ： 参数化可选项。
* **与浮点数互转** 
* **单周期与流水线** ： 所有运算均有 **单周期实现** ，时钟周期长的运算有 **流水线实现** 。

# 定点数格式

| **I** | **I** | **......** | **I** | **I** | **F** | **F** | **......** | **F** | **F** |
| :---: | :---: | :---:      | :---: | :---: | :---: | :---: | :---:      | :---: | :---: |
||

如上，定点数由若干位整数和若干位小数组成。等效于 **二进制补码整数** 除以 **2^小数位数** 。

若整数位数为8，小数位数为8，定点数举例如下表：

| 二进制码         |      **整数**       |   **定点数** (8位整数，8位小数)    | 备注            |
| :-----:          | :-----------:       | :-----------:                      | :-------------: |
| 0000000000000000 | 0                   | 0.0                                | 零值            |
| 0000000100000000 | 256                 | 1.0                                |                 |
| 1111111100000000 | -256                | -1.0                               |                 |
| 0000000000000001 | 1                   | 0.00390625                         | 最小正值        |
| 1111111111111111 | -1                  | -0.00390625                        | 最大负值        |
| 0111111111111111 | 32767               | 127.99609375                       | 最大正值        |
| 1000000000000000 | -32768              | -128.0                             | 最小负值        |
| 0001010111000011 | 5571                | 21.76171875                        |                 |
| 1001010110100110 | -27226              | -106.3515625                       |                 |


本库的模块输入输出都可以用参数 **定制定点数位宽** ，这些参数是统一的，见如下注释：
```SystemVerilog
module comb_FixedPointMul # ( // 以乘法器为例
    parameter WIIA = 8,       // 输入(乘数a)的整数位宽，默认=8
    parameter WIFA = 8,       // 输入(乘数a)的小数位宽，默认=8
    parameter WIIB = 8,       // 输入(乘数b)的整数位宽，默认=8
    parameter WIFB = 8,       // 输入(乘数b)的小数位宽，默认=8
    parameter WOI  = 8,       // 输出(积)的整数位宽，默认=8
    parameter WOF  = 8,       // 输出(积)的小数位宽，默认=8
    parameter bit ROUND= 1    // 当积的小数截断时，是否四舍五入，默认是
)(
    input  logic [WIIA+WIFA-1:0] ina, // 乘数a
    input  logic [WIIB+WIFB-1:0] inb, // 乘数b
    output logic [WOI +WOF -1:0] out, // 结果(积) = 乘数a * 乘数b
    output logic overflow             // 结果是否溢出，若溢出则为 1'b1
                                      // 若为正数溢出，则out被置为最大正值
                                      // 若为负数溢出，则out被置为最小负值
);
```

# 文件功能说明
| 运算名     |   单周期(组合逻辑实现)          |  流水线                     |    备注                               |
| :-----:    | :-----------:                   |  :------------:             |  :------------:                       |
| 位宽变换   | **comb_FixedPointZoom.sv**      | 不必要                      | 有溢出、舍入控制                      |
| 加减       | **comb_FixedPointAddSub.sv**    | 不必要                      | 具有1bit信号控制加或减                |
| 加         | **comb_FixedPointAdd.sv**       | 不必要                      | 位宽相同时可直接使用Verilog的加号替代 |
| 乘法       | **comb_FixedPointMul.sv**       | **pipe_FixedPointMul.sv**   |                                       |
| 除法       | **comb_FixedPointDiv.sv**       | **pipe_FixedPointDiv.sv**   | 单周期版时序不易收敛                  |
| 开方(Sqrt) | **comb_FixedPointSqrt.sv**      | **pipe_FixedPointSqrt.sv**  | 单周期版时序不易收敛                  |
| 正弦(Sin)  | **comb_FixedPointSin.sv**       | 待实现                      | 单周期版时序不易收敛                  |
| 浮点转定点 | **comb_Float32toFixedPoint.sv** | **pipe_Float32toFixedPoint.sv** |  单周期版时序不易收敛             |
| 定点转浮点 | **comb_FixedPointToFloat32.sv** | **pipe_FixedPointToFloat32.sv** |  单周期版时序不易收敛             |

> 注：以上所有流水线模块的流水线段数详见注释。

# 仿真
* [./RTL文件夹](https://github.com/WangXuan95/Verilog-FixedPoint/blob/master/RTL/) 中所有以 **tb_** 开头的 **.sv** 文件为 **testbench**。可以对它们进行仿真。

### iverilog 仿真
* 需要： 安装好 **[iverilog](http://iverilog.icarus.com/)** 并配置好其命令行环境
* 在 Windows 中，运行 [./RTL文件夹](https://github.com/WangXuan95/Verilog-FixedPoint/blob/master/RTL/) 中的 **.bat** 文件，可以看到命令行信息的仿真结果。
