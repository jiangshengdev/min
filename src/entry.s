.section .data
spinlock:
    .word 0x6666          # 初始化自旋锁变量，设置初始值为0x6666

.section .text
.globl _start

# 各处理器核心的启动点
_start:
    csrr a0, mhartid       # 读取当前处理器核心的hart ID
    li a1, 0
    beq a0, a1, core0_main # 如果是核心 0，跳转到core0_main
    j core1_main           # 否则，假设是核心 1，跳转到core1_main

# 核心 0 主执行代码
core0_main:
    call delay             # 延时操作
    call try_acquire_lock  # 尝试获取自旋锁
    j core0_main           # 获取锁后，进入持续等待状态

# 延时子程序
delay:
    li t0, 100             # 设置延时计数器初始值
delay_loop:
    addi t0, t0, -1        # 延时计数器递减
    bnez t0, delay_loop    # 如果计数器不为0，继续延时
    ret                    # 返回上一级调用

# 尝试获取自旋锁子程序
try_acquire_lock:
    la t2, spinlock        # 获取自旋锁地址
    li t1, 0x1111          # 设置预期写入值
try_lock:
    lr.w t3, (t2)          # 尝试读取自旋锁
    sc.w t4, t1, (t2)      # 尝试写入新值
    bnez t4, try_lock      # 如果写入失败，重新尝试
    ret                    # 返回上一级调用

# 核心 1 主执行代码
core1_main:
    call check_lock        # 检查自旋锁状态
    call shutdown          # 执行关机操作
    j core1_main           # 进入持续等待状态

# 检查自旋锁子程序
check_lock:
    la t2, spinlock        # 获取自旋锁地址
    li t1, 0x1111          # 设置期望值
check_lock_loop:
    lw t3, 0(t2)           # 读取自旋锁值
    bne t3, t1, check_lock_loop # 如果不等于期望值，继续检查
    ret                    # 返回上一级调用

# 关机子程序
shutdown:
    lui a0, 0x5
    addiw a0, a0, 0x555    # 将0x5555加载到a0寄存器
    lui a1, 0x100
    sw a0, 0(a1)           # 将a0寄存器的值（0x5555）存储到指定地址
    ret                    # 返回上一级调用
