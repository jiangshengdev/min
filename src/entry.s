.section .data
spinlock:
    .word 0x6666          # 初始化自旋锁变量为0x6666

.section .text
.globl _start

# 启动点：读取hart ID并跳转到对应核心的主执行代码
_start:
    csrr a0, mhartid       # 读取当前处理器核心的hart ID
    li a1, 0
    beq a0, a1, core0_main # 如果是核心0，跳转到core0_main
    j core1_main           # 否则，跳转到core1_main（默认核心1）

# 核心0执行代码：尝试获取自旋锁，然后进入等待状态
core0_main:
    call delay             # 延时
    call try_acquire_lock  # 尝试获取自旋锁
    .rept 50                # 插入延迟
        nop
    .endr
    call breakLRSC         # 破坏LR/SC原子性
    j core0_main           # 循环等待

# 破坏LR/SC原子性操作
breakLRSC:
    la t2, spinlock        # 加载自旋锁地址
    li t1, 0x1111          # 设置初始破坏值为0x1111
    li t3, 0x2222          # 设置交替破坏值为0x2222
    mv t4, t1              # 初始化t4为第一个写入值0x1111
break_loop:
    sw t4, 0(t2)           # 写入破坏值
    xor t4, t4, t1         # 交替t4的值
    xor t4, t4, t3         # 从0x1111变为0x2222，或从0x2222变为0x1111
    j break_loop           # 无限循环写入

# 延时操作
delay:
    li t0, 100             # 延时计数器
delay_loop:
    addi t0, t0, -1        # 计数器递减
    bnez t0, delay_loop    # 如果非零，继续延时
    ret                    # 返回调用者

# 尝试获取自旋锁
try_acquire_lock:
    la t2, spinlock        # 加载自旋锁地址
    li t1, 0x1111          # 预设写入值
try_lock:
    lr.w t3, (t2)          # 尝试读取自旋锁
    sc.w t4, t1, (t2)      # 尝试写入新值
    bnez t4, try_lock      # 如果失败，重试
    ret                    # 返回调用者

# 核心1执行代码：检查自旋锁，进行原子操作测试，然后关机
core1_main:
    call check_lock        # 检查自旋锁状态
    call atomic_test       # 测试原子操作
    call shutdown          # 关机
    j core1_main           # 循环等待

# 原子操作测试
atomic_test:
    la t2, spinlock        # 加载自旋锁地址
    li t1, 0x7777          # 设置测试值

    lr.w t3, (t2)          # 执行Load-Reserved

    .rept 10               # 插入延迟
    nop
    .endr

    sc.w t6, t1, (t2)      # 执行Store-Conditional
    bnez t6, atomic_fail   # 如果失败，跳转到atomic_fail
    li t5, 0x5555          # 成功，设置特殊值0x5555
    j atomic_end           # 跳转到结束标签

atomic_fail:
    li t5, 0xAAAA          # 失败，设置特殊值0xAAAA

atomic_end:
    ret                    # 返回调用者

# 检查自旋锁状态
check_lock:
    la t2, spinlock        # 加载自旋锁地址
    li t1, 0x1111          # 设置期望值
check_lock_loop:
    lw t3, 0(t2)           # 读取自旋锁值
    bne t3, t1, check_lock_loop # 如果不等于期望值，继续检查
    ret                    # 返回调用者

# 关机操作
shutdown:
    lui a0, 0x5
    addiw a0, a0, 0x555    # 设置寄存器a0为0x5555
    lui a1, 0x100
    sw a0, 0(a1)           # 将a0的值存储到指定地址实现关机
    ret                    # 返回调用者
