ag: #初始设置$t2=0x10010000,$t3初=x10008000,数据存储器mem[0]=0x5555aaaa,其余全部为0
add.w $a0,$t2,$t3 #$a0=0x20018000
sub.w $a1,$t2,$t3#$a1=0x00008000
and $a2,$t2,$t3#$a2=0x10000000
or $a3,$t2,$t3#$a3=0x10018000
slt $a4,$t3,$t2#$a4=0x1
ld.w $a5,$t2,0#$a5=0x5555aaaa
st.w $a5,$t2,4#mem[4]=0x5555aaaa
beq $t1,$zero,next #复位后$t1=$zero=0,此指令跳转到next
b next
next: beq $t1,$t2,next#$t1=0,$t2=0x10010000,此指令顺序执行
b ag
