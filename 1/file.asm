# 从键盘输入包括驱动器名、路径名、文件名及0的ASCIIZ字符串（即为指定路径下的一个文件），然后把这个文件打开并读入到内存数据缓冲区50000H（对应的逻辑地址为5000:0000）处，再换个文件名重新写入磁盘。
assume cs:code, ds:data, es:data, ss:stack # es用作ds的补充
data segment
    file1 db 40 # 全局变量
        db ? # data段只能用问号预留空间 
        db 40 dup(0)
    file2 db 40
        db ?
        db 40 dup(0)
    msg1 db 'INPUT SOURCE FILE:$' # 定义每个字符大小1字节
    msg2 db 'INPUT NEW NAME:$' # '$' 结束字符串
    enter db 0DH, 0AH, '$'
    buf db 100 dup(0)
stack segment
    db 100 dup(?) # 嵌套栈段，实现局部变量动态分配
stack ends
data ends

code segment
main proc far
    mov ax,data
    mov ds,ax
    mov es,ax
    
    lea dx,msg1 # 汇编中，字符串首地址放在ds:dx中
    mov ah,09H
    int 21H # 中断，执行子程序 09H 系统调用(显示字符串)

    lea dx,file1
    mov ah,0AH # 键盘输入缓冲区
    int 21H

    lea si,file1 # 源变址寄存器si指向原操作数的偏移地址
    mov al,[si+1] # 寄存器间接寻址
    cbw # convert byte to word 将al扩充成ax
    inc si # 自加
    inc si
    add si,ax
    mov byte ptr[si],0 # 初始化file1

    lea dx,enter
    mov ah,09h # 显示字符串
    int 21H

    lea dx,file1+2
    mov ah,3dh # 利用串地址 ds:si 打开文件
    mov al,0 # 中断程序返回值
    int 21H

    mov bx,ax # bx 文件代号
    mov ah,3fh # 读取文件到缓冲区 ds:dx=数据缓冲区地址 bx=文件标号 cx=读取字节数
    push ds
    push es
    mov cx,5000H
    mov ds,cx
    mov dx,0000H

    mov cx,50 # 设定读取的字节数为50
    int 21H
    pop ds # 读取完毕 ds es 回到 data 位置
    pop es
    
    mov ah,3EH # 读取文件完毕后关闭文件
    int 21H
    
    lea dx,msg2
    mov ah,09H # 显示字符串
    int 21H
    
    lea dx,file2
    mov ah,0AH # 键盘输入缓冲区
    int 21H

    lea si,file2
    mov al,[si+1]
    cbw
    inc si
    inc si
    add si,ax
    mov byte ptr[si],0

    mov ah,3CH # 建立文件
    mov cx,00H
    lea dx,file2+2
    int 21H

    mov bx,ax
    mov ah,40H # 写文件
    push ds
    push es
    mov cx,5000H
    mov ds,cx
    mov dx,0000H
    
    mov cx,14
    int 21H
    pop ds
    pop es
    mov ah,3EH
    int 21H
    pop ds
    pop es
    mov AH,3EH
    int 21H

    mov ah,4CH
    int 21H
main endp
code ends
end main

    
    

