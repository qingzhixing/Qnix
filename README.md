# Qnix

简易操作系统实现

这个项目不会分课时建立文件夹，代码迭代请查看git提交记录

## 项目目录

[src/](./src/) 存放项目代码

[reference/](./reference/) 存放参考代码,里面有脚本，下载本项目后在该目录下运行以下来下载参考代码

## 环境配置

**Bochs:**

Bochs x86 Emulator 2.6.11

使用更高版本会出现奇怪错误.

请手动编译以开启bochs-dbg功能

项目里有bochs-gdb一键式安装（安装到项目文件夹中)，请在运行 `make bochs-gdb`前运行

[Bochs2.6.11配置安装参考](https://www.cnblogs.com/oasisyang/archive/2021/09/30/15358137.html "Bochs2.6.11配置安装参考")

**NASM** version 2.14.02

**qemu:**

qemu 在进入保护模式代码那里会重启，我也不知道为什么

QEMU emulator version 8.1.92 (v8.2.0-rc2-6-g29b5d70cb7)
Copyright (c) 2003-2023 Fabrice Bellard and the QEMU Project developers

[QEMU安装参考(记得开翻译机)](https://wiki.qemu.org/Hosts/Linux)

qemu git: `git@github.com:qemu/qemu.git`

## 如何运行

在src目录下运行 `make bochs` 即可运行代码

**烧录入USB:**

重要事项！！

请先使用 `lsblk` 找到要烧录的USB名称，然后再修改makefile中相应位置的名称

否则误操作会造成 **数据丢失**!!!!

## 参考视频

[操作系统实现 - 001.1 学习笔记](https://www.bilibili.com/video/BV1qM4y127om/?spm_id_from=333.999.top_right_bar_window_history.content.click&vd_source=7aca0011cad4c76468be9e183b41c88a)
