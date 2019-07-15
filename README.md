![platform](https://img.shields.io/badge/platform-Quartus|Vivado|iverilog-blue.svg)

Verilog-FixedPoint
===========================
SystemVerilog 定点数库。

# 特点
* **参数化定制位宽** ： 所有运算的输入输出可由 parameter 定制整数位宽和小数位宽。
* **四则运算** ： 加减乘除。
* **高级运算** ： 目前已实现 Sin 和 Sqrt。
* **溢出与四舍五入控制** ： 参数化可选项
* **与浮点数互转** ： 目前已实现单精度浮点数转定点数，待实现定点数转浮点数。
* **单周期与流水线实现** ： 所有运算均有单周期实现，对于某些时钟周期长的运算流水线化。

| 运算名     |   单周期(组合逻辑实现)      |  流水线                 |    备注                |
| :-----:    | :-----------:               |  :------------:         |  :------------:        |
| 位宽变换   | comb_FixedPointZoom.sv      | 不必要                  | 具有溢出控制和四舍五入控制 |
| 加减       | comb_FixedPointAddSub.sv    | 不必要                  | 具有1bit信号控制加或减 |
| 加         | comb_FixedPointAdd.sv       | 不必要                  |                        |
| 乘法       | comb_FixedPointMul.sv       | pipe_FixedPointMul.sv   |  2段流水线             |
| 除法       | comb_FixedPointDiv.sv       | pipe_FixedPointDiv.sv   | 为了时序收敛，不推荐使用单周期版。流水线段数见注释 |
| 开方(Sqrt) | comb_FixedPointSqrt.sv      | 待实现                  |                        |
| 正弦(Sin)  | comb_FixedPointSin.sv       | 待实现                  |                        |
| ......     | 待实现                      | 待实现                  |  ......                |
| 浮点转定点 | comb_Float32toFixedPoint.sv | 待实现                  |  为单精度浮点          |
| 定点转浮点 | 待实现                      | 待实现                  |  为单精度浮点          |

# 仿真
* [./RTL文件夹](https://github.com/WangXuan95/Verilog-FixedPoint/RTL/) 中所有以 **test_** 开头的 **.sv** 文件为 **testbench**。可以对它们进行仿真。

### iverilog 仿真
* 需要： 安装好 **[iverilog](http://iverilog.icarus.com/)** 并配置好其命令行环境
* 在 Windows 中，运行 [./RTL文件夹](https://github.com/WangXuan95/Verilog-FixedPoint/RTL/) 中的 **.bat** 文件，可以看到命令行信息的仿真结果。
