.section .data
sync_flag:
    .word 0

.section .text
.globl _start

# 启动点：读取hart ID并跳转到对应核心的主执行代码
_start:
    csrr a0, mhartid       # 读取当前处理器核心的hart ID
    li a1, 0
    beq a0, a1, core0_main # 如果是核心0，跳转到core0_main
    j other_cores_wait     # 否则，跳转到other_cores_wait

# 核心0执行代码：完成任务后设置同步标志
core0_main:
    # ... 执行核心0的初始化代码 ...

    # 使用原子指令和释放语义设置同步标志，通知其他核继续执行
    li t1, 1
    la t2, sync_flag
    amoswap.w.rl t0, t1, (t2) # 原子地交换sync_flag的值为1，并使用释放语义

    # ... 核心0继续执行其他代码 ...
    j end_of_program       # 跳转到程序结束处

# 其他核心的等待循环
other_cores_wait:
    la t2, sync_flag
wait_for_flag:
    lr.w.aq t1, (t2)       # 使用获取语义原子地加载sync_flag
    beqz t1, wait_for_flag # 如果sync_flag为0，则继续等待

    # 跳转到其他核心的主执行代码
    j other_cores_main

# 其他核心的主执行代码
other_cores_main:
    # ... 其他核继续执行代码 ...
    j end_of_program       # 跳转到程序结束处

end_of_program:
    j end_of_program       # 跳转到自身，形成无限循环
