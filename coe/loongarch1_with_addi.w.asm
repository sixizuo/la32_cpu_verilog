ag:
addi.w a0,zero,-4
add.w a0,t2,t3
sub.w a1,t2,t3
and a2,t2,t3
or a3,t2,t3
slt a4,t2,t3
ld.w a5,t2,0
st.w a6,t2,4
beq t1,zero,next
b next
next: beq t1,t2,next
b ag
