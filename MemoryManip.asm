format MS COFF
include 'win32wxp.inc'

include 'extrndef.inc'
include 'kernel32.inc'
include 'user32.inc'

include 'filetype.inc'

MB_PRECOMPOSED	= 0x00000001

ERROR_INSUFFICIENT_BUFFER = 0x7a

public basePtr
public GetData as '_GetData@16'
public CopyMemoryB as '_CopyMemoryB@12'
public CopyStringAtoW as '_CopyStringAtoW@12'
public CopyStringWtoW as '_CopyStringWtoW@12'

extrn 'ptrFileBaseInfo' as ptrFileBaseInfo:dword
extrn 'hHeapObject' as hHeapObject:dword

section '.code' code readable executable					
			
			proc GetMappedBase uses ebx esi edi,index 
				
				mov ebx,[ptrFileBaseInfo]
				mov eax,[index]
							
				.if eax < dword[ebx+sFILE_BASE_INFO.allocGran]
					xor eax,eax
					
				.else		
					xor edx,edx
					div dword[ebx+sFILE_BASE_INFO.allocGran]					
					mul dword[ebx+sFILE_BASE_INFO.allocGran]									
					
				.endif				
				
				ret
			endp
			
			proc GetMappedPtr uses ebx esi edi,index,size
				
				locals
					next	dd	0
					diff	dd	0
				endl
				
				stdcall GetMappedBase,[index]
				mov [baseOffset],eax
				
				mov edx,eax
				mov ecx,[ptrFileBaseInfo]
				mov ecx,[ecx+sFILE_BASE_INFO.allocGran]				
				add edx,ecx
				mov [next],edx								
				
				mov ecx,[index]
				add ecx,[size]
				.if ecx > [next]
					sub ecx,[next]
					mov [diff],ecx														
					jmp .calc
					
				.endif
				
				.if eax = [mappedOffset] & [basePtr] <> 0
					mov eax,[dataPtr]
					ret
				
				.else
	.calc:			
					.if [basePtr] <> 0
						invoke UnmapViewOfFile,[basePtr]
						mov [basePtr],0
					
					.endif
					; mappedLen = min(pFile->fileSize-baseOffset,pFile->allocGran);
					mov ebx,[ptrFileBaseInfo]
					mov edx,[ebx+sFILE_BASE_INFO.fileSize]
					sub edx,[baseOffset]																									
					.if edx < dword[ebx+sFILE_BASE_INFO.allocGran]						
						mov [mappedLen],edx												
					
					.else
						mov eax,[ebx+sFILE_BASE_INFO.allocGran]						
						mov [mappedLen],eax						
					
					.endif				
					.if [diff] > 0
						mov ecx,[diff]
						add [mappedLen],ecx						
					
					.endif
					
					invoke MapViewOfFile,dword[ebx+sFILE_BASE_INFO.hFileMap],FILE_MAP_READ,0,[baseOffset],[mappedLen]
					.if eax = 0
						int3
						int3						
						
					.endif	
										
					mov [basePtr],eax
					mov edx,[baseOffset]
					mov [mappedOffset],edx					
					mov [dataPtr],eax
					sub [dataPtr],edx										
					mov eax,[dataPtr]
					
				.endif							
				
				ret
			endp
						
			proc GetData uses ebx esi edi,destination,fileOffset,intoFileOffset,bytesToCopy												
				
				cmp [bytesToCopy],0
				je .out
				
				mov ebx,[fileOffset]
				add ebx,[intoFileOffset]
				stdcall GetMappedPtr,ebx,[bytesToCopy]
				
				add ebx,eax															
				stdcall CopyMemoryB,[destination],ebx,[bytesToCopy]				
				
	.out:		
				ret
			endp
			
			proc CopyMemoryB uses ebx esi edi,dest,source,size
				
				cld
				
				mov ecx,[size]
				mov esi,[source]
				mov edi,[dest]								
				
				rep movsb
				
				ret
			endp
			
			proc CopyStringAtoW destination,source,size				
				
				locals
					len dd 128
				endl
								
				stdcall GetMappedPtr,[source],[size]
				add [source],eax													
				
				invoke MultiByteToWideChar,CP_ACP,MB_PRECOMPOSED,[source],[len],[destination],0	
				.if eax > [size]				
					mov edx,[size]
					mov [len],edx			
				
				.endif
				
				invoke MultiByteToWideChar,CP_ACP,MB_PRECOMPOSED,[source],[len],[destination],[size]
							
				ret
			endp
			
			proc CopyStringWtoW destination,source,size
				
				stdcall GetMappedPtr,[source],[size]
				add [source],eax
				
				invoke lstrcpynW,[destination],[source],[size]																
				
				ret
			endp
			
section '.data' data readable writeable
	baseOffset		dd	0
	mappedLen		dd	0
	mappedOffset	dd	0
	dataPtr		dd	0
	basePtr		dd	0
			













;;			
			