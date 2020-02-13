Verilog-FixedPoint | 核心代码
===========================

* fixedpoint.sv 包含了所有浮点数计算的可综合模块
* **tb_**   开头的文件为 **Verilog testbench** ， 你可以选择你熟悉的仿真工具（如 **ModelSim** ， **iverilog** ， **Vivado** 等），以它们为顶层进行仿真。
* **run_** 开头的 **.bat** 文件为 Windows 批处理文件，它们调用 **iverilog** 对 **testbench** 进行仿真。需要你预先在Windows上安装好 **iverilog** 并 **配置好运行环境**。仿真主要是为了展示计算结果的正确性。
