format pe64 efiboot
entry main

; Set your own offsets in mv
; core and cache offsets should be set to the same value on most laptops where they refer to the same voltage
VcoreOffset            = -20
VcacheOffset           = -20
VuncoreOffset          = -20
VgraphicsOffset        = 0
VioOffset              = 0


WriteVcore         = (((VcoreOffset shl 21)/1000) shl 10) and 0xffe00000
WriteVcache        = (((VcacheOffset shl 21)/1000) shl 10) and 0xffe00000
WriteVuncore       = (((VuncoreOffset shl 21)/1000) shl 10) and 0xffe00000
WriteVgraphics     = (((VgraphicsOffset shl 21)/1000) shl 10) and 0xffe00000
WriteVio           = (((VioOffset shl 21)/1000) shl 10) and 0xffe00000

section '.text' code executable readable

main: 
 mov [SystemTable], rdx

 mov     ecx,150h
 mov     eax,WriteVcore
 mov     edx,80000011h                
 wrmsr
 rdmsr
 cmp     dl,0
 jne     failed
 mov     eax,WriteVgraphics
 mov     edx,80000111h                
 wrmsr
 mov     eax,WriteVcache
 mov     edx,80000211h                
 wrmsr
 mov     eax,WriteVuncore
 mov     edx,80000311h
 wrmsr
 mov     eax,WriteVio
 mov     edx,80000411h
 wrmsr
 retn

failed:
 ; rdx becomes the pointer to the System Table, rdx + 64 points to the address of ConOut
 mov rdx, [SystemTable]
 mov rcx, [rdx + 64]

 ; OutputString function in ConOut
 mov rax, [rcx + 8]
 mov rdx, string
 sub rsp, 32
 call rax
 add rsp, 32
 retn


section '.data' readable writable

SystemTable dq ?
string  du 'Unable to undervolt, undervolting may be blocked by your bios, or unsupported by your CPU',13,10,0