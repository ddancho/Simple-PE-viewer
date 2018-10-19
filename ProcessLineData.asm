format MS COFF
include 'win32wxp.inc'

include 'extrndef.inc'
include 'kernel32.inc'
include 'user32.inc'

include 'pe.inc'
include 'petype.inc'

include 'filetype.inc'
include 'treeandsorttype.inc'

public ProcessingImageDosHeaderLineData as '_ProcessingImageDosHeaderLineData@4'
public ProcessingImageFileHeaderLineData as '_ProcessingImageFileHeaderLineData@4'
public ProcessingImageOptionalHeaderLineData as '_ProcessingImageOptionalHeaderLineData@4'
public ProcessingImageSectionHeaderLineData as '_ProcessingImageSectionHeaderLineData@8'
public ProcessingImportDirectoryEntryLineData as '_ProcessingImportDirectoryEntryLineData@8'
public ProcessingImportLookupTableLineData as '_ProcessingImportLookupTableLineData@8'
public ProcessingImportAddressTableLineData as '_ProcessingImportAddressTableLineData@8'
public ProcessingExportDirectoryEntryLineData as '_ProcessingExportDirectoryEntryLineData@4'
public ProcessingExportAddressTableLineData as '_ProcessingExportAddressTableLineData@4'
public ProcessingExportNamePtrTableLineData as '_ProcessingExportNamePtrTableLineData@4'
public ProcessingExportOrdinalTableLineData as '_ProcessingExportOrdinalTableLineData@4'
public ProcessingBoundDirectoryEntryLineData as '_ProcessingBoundDirectoryEntryLineData@4'
public ProcessingImageBaseRelocationLineData as '_ProcessingImageBaseRelocationLineData@4'
public ProcessingImageLoadConfigurationEntryLineData as '_ProcessingImageLoadConfigurationEntryLineData@4'
public ProcessingImageTlsDirectoryEntryLineData as '_ProcessingImageTlsDirectoryEntryLineData@4'
public ProcessingDelayImportDirecEntryLineData as '_ProcessingDelayImportDirecEntryLineData@8'
public ProcessingDebugDirectoryEntryLineData as '_ProcessingDebugDirectoryEntryLineData@4'
public ProcessingDebugFpoTypeLineData as '_ProcessingDebugFpoTypeLineData@4'
public ProcessingCoffSymbolHeaderLineData as '_ProcessingCoffSymbolHeaderLineData@4'
public ProcessingCoffLineNumbersLineData as '_ProcessingCoffLineNumbersLineData@4'
public ProcessingCoffRelocations as '_ProcessingCoffRelocations@4'
public ProcessingCoffSymbolTableLineData as '_ProcessingCoffSymbolTableLineData@4'
public ProcessingResourceDirectoryTableLineData as '_ProcessingResourceDirectoryTableLineData@8'
public ProcessingResourceDataEntryLineData as '_ProcessingResourceDataEntryLineData@4'

public GetTextForResourceID as '_GetTextForResourceID@4'
public GetResourceDataEntry as '_GetResourceDataEntry@8'

extrn 'hHeapObject' as hHeapObject:dword
extrn 'ptrFilePeInfo' as ptrFilePeInfo:dword
extrn 'ptrSecHeaderInfo' as ptrSecHeaderInfo:dword
extrn 'ptrImportNames' as ptrImportNames:dword
extrn 'ptrImportAddress' as ptrImportAddress:dword
extrn 'ptrExportDirec' as ptrExportDirec:dword
extrn 'basePtr' as basePtr:dword
extrn 'ptrDelayName' as ptrDelayName:dword
extrn 'ptrDelayAddress' as ptrDelayAddress:dword
extrn 'ptrResource' as ptrResource:dword

extrn '_GetData@16' as GetData:dword

section '.code' code readable executable

			proc ProcessingImageDosHeaderLineData uses ebx esi edi,ptrTree
				
				; line no 14..17 same offset & len
				; and line no 20..29
				locals
					strTbl	dd	0,2,0,11,2,2,12,21,4,2,34,11,6,2,46,11,8,2,58,24,10,2,83,28,\
								12,2,112,28,14,2,141,24,16,2,166,14,18,2,181,8,20,2,190,14,22,2,205,24,\
								24,2,230,28,26,2,259,13,  28,2,273,13,  34,2,287,13,36,2,301,14,  38,2,273,13,  60,4,316,25
					
					numOfLines	dd	0
					i		dd	0
					j		dd	0					
				endl
							
				mov ebx,[ptrTree]
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax				
				push ebx					
				mov ebx,eax
				lea esi,[strTbl]
				
	.loop:				
					mov ecx,[i]
					cmp ecx,[numOfLines]
					je .out
						
						.if [i] = 14										
							.next1:
									mov ecx,[i]
									cmp ecx,18
									je .to_add
										mov eax,[esi+0]	; bytesPerLine
										mov edx,[esi+4]	; bytesToCopy
										mov edi,[esi+8]	; offset
										
										add eax,[j]
										
										mov dword[ebx+sLINE_DATA.bytesPerLine],eax
										mov dword[ebx+sLINE_DATA.bytesToCopy],edx
										mov dword[ebx+sLINE_DATA.offset],edi
							
										mov eax,[esi+12]	; len							
										mov dword[ebx+sLINE_DATA.len],eax
							
										mov dword[ebx+sLINE_DATA.line.lineNo],ecx	; lineNo	
									
									inc [i]
									add [j],2
									add ebx,sizeof.sLINE_DATA									
							jmp .next1													
							
						.elseif [i] = 20				
								mov [j],0
							.next2:
									mov ecx,[i]
									cmp ecx,30
									je .to_add
										mov eax,[esi+0]	; bytesPerLine
										mov edx,[esi+4]	; bytesToCopy
										mov edi,[esi+8]	; offset
										
										add eax,[j]
										
										mov dword[ebx+sLINE_DATA.bytesPerLine],eax
										mov dword[ebx+sLINE_DATA.bytesToCopy],edx
										mov dword[ebx+sLINE_DATA.offset],edi
							
										mov eax,[esi+12]	; len							
										mov dword[ebx+sLINE_DATA.len],eax
							
										mov dword[ebx+sLINE_DATA.line.lineNo],ecx	; lineNo	
									
									inc [i]
									add [j],2
									add ebx,sizeof.sLINE_DATA									
							jmp .next2
								
						.to_add:
									add esi,4*4
									jmp .loop
							
						.else
							mov eax,[esi+0]	; bytesPerLine
							mov edx,[esi+4]	; bytesToCopy
							mov edi,[esi+8]	; offset
							
							mov dword[ebx+sLINE_DATA.bytesPerLine],eax
							mov dword[ebx+sLINE_DATA.bytesToCopy],edx
							mov dword[ebx+sLINE_DATA.offset],edi
							
							mov eax,[esi+12]	; len							
							mov dword[ebx+sLINE_DATA.len],eax
							
							mov dword[ebx+sLINE_DATA.line.lineNo],ecx	; lineNo
														
							inc [i]
							add ebx,sizeof.sLINE_DATA
							add esi,4*4
							
						.endif	
					
					jmp .loop
	.out:				
					
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingImageFileHeaderLineData uses ebx esi edi,ptrTree
				
				locals
					strTbl	dd	0,2,0,7,2,2,8,16,4,4,25,13,8,4,39,20,12,4,60,15,16,2,76,20,18,2,97,15	
					; only offset and len for file characteristics
					chrTbl	dd	0,26,27,27,55,29,85,30,116,28,145,30,176,28,205,24,230,25,256,34,291,28,320,17,338,14,353,25,379,28
					; size = 15
					fileAttr	dd	IMAGE_FILE_RELOCS_STRIPPED,IMAGE_FILE_EXECUTABLE_IMAGE,IMAGE_FILE_LINE_NUMS_STRIPPED,IMAGE_FILE_LOCAL_SYMS_STRIPPED,\
									IMAGE_FILE_AGGRESIVE_WS_TRIM,IMAGE_FILE_LARGE_ADDRESS_AWARE,IMAGE_FILE_BYTES_REVERSED_LO,IMAGE_FILE_32BIT_MACHINE,\
									IMAGE_FILE_DEBUG_STRIPPED,IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP,IMAGE_FILE_NET_RUN_FROM_SWAP,IMAGE_FILE_SYSTEM,\
									IMAGE_FILE_DLL,IMAGE_FILE_UP_SYSTEM_ONLY,IMAGE_FILE_BYTES_REVERSED_HI
					
					numOfLines	dd	0
					fileChrAttr	dd	0
					numOfFileAttr	dd	0					
					i	dd	0
					j	dd	0					
				endl
				
				mov ebx,[ptrTree]				
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx				
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				
				mov edx,[ptrFilePeInfo]
				mov ecx,[edx+sFILE_PE_INFO.fileChrAttr]
				mov [fileChrAttr],ecx
				mov edx,[edx+sFILE_PE_INFO.numOfFlagsFileAttr]
				mov [numOfFileAttr],edx
				
				lea esi,[strTbl]
	.loop:			
					mov ecx,[i]
					cmp ecx,[numOfLines]
					je .out
					
						.if [i] > 6			
							.if [numOfFileAttr] <> 0								
								lea esi,[chrTbl]
								lea edi,[fileAttr]
																		
						.loop2:		
								cmp [j],15
								je .out
									mov eax,[edi]
									test eax,[fileChrAttr]
									.if ~ZERO?
										mov eax,[esi+0]	; offset
										mov edx,[esi+4]	; len
									
										mov dword[ebx+sLINE_DATA.offset],eax
										mov dword[ebx+sLINE_DATA.len],edx	
										
										mov dword[ebx+sLINE_DATA.line.lineNo],ecx	; lineNo
										
										mov edx,[edi]
										mov dword[ebx+sLINE_DATA.line.lineInfoA],edx	; data
										
										inc [i]
										mov ecx,[i]
										.if ecx = [numOfLines] 
											jmp .out
																				
										.endif
										
										add ebx,sizeof.sLINE_DATA
										
									.endif
								
								inc [j]
								
								add esi,8
								add edi,4
								jmp .loop2																																											
							
							.endif	; numOfFileAttr check
							
						.else
							; machine
							.if [i] = 0							
								mov dword[ebx+sLINE_DATA.line.lineInfoA],27		; offset
								mov dword[ebx+sLINE_DATA.line.lineInfoB],23		; len
								
							.endif
							mov eax,[esi+0]	; bytesPerLine
							mov edx,[esi+4]	; bytesToCopy
							mov edi,[esi+8]	; offset
							
							mov dword[ebx+sLINE_DATA.bytesPerLine],eax
							mov dword[ebx+sLINE_DATA.bytesToCopy],edx
							mov dword[ebx+sLINE_DATA.offset],edi
							
							mov eax,[esi+12]	; len							
							mov dword[ebx+sLINE_DATA.len],eax
							
							mov dword[ebx+sLINE_DATA.line.lineNo],ecx	; lineNo
														
							inc [i]
							add ebx,sizeof.sLINE_DATA
							add esi,4*4
													
						.endif
															
					jmp .loop				
	.out:			
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingImageOptionalHeaderLineData uses ebx esi edi,ptrTree
				
				; dll characteristics start at line 24 ( if any )
				locals
					strTbl	dd	0,2,0,5,2,1,6,18,3,1,25,18,4,4,44,10,8,4,55,21,12,4,77,23,16,4,101,19,20,4,121,10,24,4,132,10,28,4,143,9,32,4,153,16,\
								36,4,170,13,40,2,184,27,42,2,212,27,44,2,240,17,46,2,258,17,48,2,276,21,50,2,298,21,52,4,320,17,56,4,338,11,60,4,350,13,\
								64,4,364,8,68,2,373,9,70,2,383,18,72,4,402,18,76,4,421,17,80,4,440,17,84,4,458,16,88,4,475,11,92,4,487,19,96,4,507,6,\
								100,4,0,0,104,4,514,6,108,4,0,0,112,4,521,8,116,4,0,0,120,4,530,9,124,4,0,0,128,4,540,8,132,4,0,0,136,4,549,21,140,4,0,0,\
								144,4,572,5,148,4,0,0,152,4,578,26,156,4,0,0,160,4,605,9,164,4,0,0,168,4,615,3,172,4,0,0,176,4,619,18,180,4,0,0,184,4,638,12,\
								188,4,0,0,192,4,651,20,196,4,0,0,200,4,672,29,204,4,0,0,208,4,702,22,212,4,0,0,216,4,729,22,220,4,0,0
					; only offset and len			
					dllTbl	dd	235,37,273,40,314,34,349,37,387,31,419,32,452,35,488,46	
					
					dllAttr	dd	IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE,IMAGE_DLLCHARACTERISTICS_FORCE_INTEGRITY,IMAGE_DLLCHARACTERISTICS_NX_COMPAT,IMAGE_DLLCHARACTERISTICS_NO_ISOLATION,\
								IMAGE_DLLCHARACTERISTICS_NO_SEH,IMAGE_DLLCHARACTERISTICS_NO_BIND,IMAGE_DLLCHARACTERISTICS_WDM_DRIVER,IMAGE_DLLCHARACTERISTICS_TERMINAL_SERVER_AWARE
					
					numOfLines	dd	0
					numOfDllAttr	dd	0
					fileDllAttr		dd	0
					address		dd	0
					i	dd	0
					j	dd	0
					dataInfo db 4 dup 0
				endl
							
				mov ebx,[ptrTree]
				mov eax,[ebx+sTREE_ITEM_TYPE.address.file]
				mov [address],eax
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx				
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				
				mov edx,[ptrFilePeInfo]
				mov ecx,[edx+sFILE_PE_INFO.numOfFlagsDllAttr]
				mov [numOfDllAttr],ecx
				mov edx,[edx+sFILE_PE_INFO.fileDllAttr]
				mov [fileDllAttr],edx
				
				lea esi,[strTbl]
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
					
					.if [i] > 23 & [numOfDllAttr] <> 0						
						push esi
							
						lea esi,[dllTbl]
						lea edi,[dllAttr]
			.loop2:				
						cmp [j],8
						je .next
								
							mov eax,[edi]
							test eax,[fileDllAttr]
							.if ~ZERO?
								mov eax,[esi+0]	; offset
								mov edx,[esi+4]	; len
									
								mov dword[ebx+sLINE_DATA.offset],eax
								mov dword[ebx+sLINE_DATA.len],edx	
										
								mov dword[ebx+sLINE_DATA.line.lineNo],ecx	; lineNo
										
								mov edx,[edi]
								mov dword[ebx+sLINE_DATA.line.lineInfoA],edx	; data
								mov dword[ebx+sLINE_DATA.line.lineInfoB],1		; true	
								
								inc [i]
								mov ecx,[i]
								add ebx,sizeof.sLINE_DATA
								
							.endif
										
						inc [j]
						add esi,8
						add edi,4
						jmp .loop2
			.next:			
						pop esi
						mov [numOfDllAttr],0
						jmp .loop
																																		
					.else
						.if [i] = 0
						; magic				
							stdcall GetData,addr dataInfo,[address],0,2
							lea ecx,[dataInfo]
							movzx ecx,word[ecx]
							.if ecx = 0x10b
								mov dword[ebx+sLINE_DATA.line.lineInfoA],0		; offset
								mov dword[ebx+sLINE_DATA.line.lineInfoB],29		; len
								
							.endif
							
						.elseif [i] = 22
						; subsystem				
							stdcall GetData,addr dataInfo,[address],68,2
							lea ecx,[dataInfo]
							movzx ecx,word[ecx]
							.if ecx = 0
								mov dword[ebx+sLINE_DATA.line.lineInfoA],60		; offset
								mov dword[ebx+sLINE_DATA.line.lineInfoB],23		; len
								
							.elseif ecx = 1
								mov dword[ebx+sLINE_DATA.line.lineInfoA],84		; offset
								mov dword[ebx+sLINE_DATA.line.lineInfoB],22		; len
								
							.elseif ecx = 2
								mov dword[ebx+sLINE_DATA.line.lineInfoA],107	; offset
								mov dword[ebx+sLINE_DATA.line.lineInfoB],27		; len
								
							.elseif ecx = 3
								mov dword[ebx+sLINE_DATA.line.lineInfoA],135	; offset
								mov dword[ebx+sLINE_DATA.line.lineInfoB],27		; len
								
							.elseif ecx = 8
								mov dword[ebx+sLINE_DATA.line.lineInfoA],163	; offset
								mov dword[ebx+sLINE_DATA.line.lineInfoB],30		; len
								
							.elseif ecx = 16
								mov dword[ebx+sLINE_DATA.line.lineInfoA],194	; offset
								mov dword[ebx+sLINE_DATA.line.lineInfoB],40		; len
								
							.endif
						
						.endif
						mov eax,[esi+0]	; bytesPerLine
						mov edx,[esi+4]	; bytesToCopy
						mov edi,[esi+8]	; offset
							
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],edx
						mov dword[ebx+sLINE_DATA.offset],edi
							
						mov eax,[esi+12]	; len							
						mov dword[ebx+sLINE_DATA.len],eax
							
						mov dword[ebx+sLINE_DATA.line.lineNo],ecx	; lineNo
														
						inc [i]
						add ebx,sizeof.sLINE_DATA
						add esi,4*4	
						
					.endif
								
				jmp .loop		
	.out:						
					
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]			
				ret
			endp
			
			proc ProcessingImageSectionHeaderLineData uses ebx esi edi,pTree,pSection
				
				locals
					strTbl	dd	0,4,0,4,4,4,0,0,8,4,5,11,12,4,17,14,16,4,32,13,20,4,46,16,24,4,63,20,28,4,84,20,32,2,105,19,34,2,125,19,36,4,145,15
					; 15 elem to the align one , 14 align type elem , then 8 elem to the end of array
					secTbl	dd	0,21,22,18,41,30,72,32,105,19,125,18,144,20,165,20,186,27,214,15,230,21,252,23,276,19,296,20,317,21,339,22,362,22,\
								385,22,408,22,431,23,455,23,479,23,503,24,528,24,553,24,578,25,604,25,630,25,656,25,703,25,729,25,755,24,780,23,\
								804,20,825,21,847,18,866,19
					; 15 elem to the align one , 14 align type elem , then 8 elem to the end of array
					secAttr	dd	IMAGE_SCN_TYPE_NO_PAD,IMAGE_SCN_CNT_CODE,IMAGE_SCN_CNT_INITIALIZED_DATA,IMAGE_SCN_CNT_UNINITIALIZED_DATA,IMAGE_SCN_LNK_OTHER,\
								IMAGE_SCN_LNK_INFO,IMAGE_SCN_LNK_REMOVE,IMAGE_SCN_LNK_COMDAT,IMAGE_SCN_NO_DEFER_SPEC_EXC,IMAGE_SCN_GPREL,IMAGE_SCN_MEM_FARDATA,\
								IMAGE_SCN_MEM_PURGEABLE,IMAGE_SCN_MEM_16BIT,IMAGE_SCN_MEM_LOCKED,IMAGE_SCN_MEM_PRELOAD,\
								IMAGE_SCN_ALIGN_1BYTES,IMAGE_SCN_ALIGN_2BYTES,IMAGE_SCN_ALIGN_4BYTES,IMAGE_SCN_ALIGN_8BYTES,IMAGE_SCN_ALIGN_16BYTES,\
								IMAGE_SCN_ALIGN_32BYTES,IMAGE_SCN_ALIGN_64BYTES,IMAGE_SCN_ALIGN_128BYTES,IMAGE_SCN_ALIGN_256BYTES,IMAGE_SCN_ALIGN_512BYTES,\
								IMAGE_SCN_ALIGN_1024BYTES,IMAGE_SCN_ALIGN_2048BYTES,IMAGE_SCN_ALIGN_4096BYTES,IMAGE_SCN_ALIGN_8192BYTES,\
								IMAGE_SCN_LNK_NRELOC_OVFL,IMAGE_SCN_MEM_DISCARDABLE,IMAGE_SCN_MEM_NOT_CACHED,IMAGE_SCN_MEM_NOT_PAGED,IMAGE_SCN_MEM_SHARED,\
								IMAGE_SCN_MEM_EXECUTE,IMAGE_SCN_MEM_READ,IMAGE_SCN_MEM_WRITE
					
					numOfLines	dd	0
					secHeadChr	dd	0
					i	dd	0
					j	dd	0
				endl
							
				mov esi,[pSection]
				mov esi,[esi+sSEC_HEADER_INFO.characteristics]
				mov [secHeadChr],esi
				mov ebx,[pTree]
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx				
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				
				lea esi,[strTbl]
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
					
					.if [i] > 10
						.if [secHeadChr] <> 0
							lea esi,[secTbl]
							lea edi,[secAttr]
							
				.loop2:			
							cmp [j],37
							je .out																
								.if [j] > 14 & [j] < 29
									; 0x00F00000
									mov eax,[secHeadChr]
									and eax,0x00F00000
									.if eax = [edi]
										mov eax,[esi+0]	; offset
										mov edx,[esi+4]	; len
									
										mov dword[ebx+sLINE_DATA.offset],eax
										mov dword[ebx+sLINE_DATA.len],edx	
										
										mov dword[ebx+sLINE_DATA.line.lineNo],ecx	; lineNo
										
										mov edx,[edi]
										mov dword[ebx+sLINE_DATA.line.lineInfoA],edx	; data
										
										inc [i]
										mov ecx,[i]										
										
										add ebx,sizeof.sLINE_DATA
										
									.endif
									
								.else
									mov eax,[edi]
									test eax,[secHeadChr]
									.if ~ZERO?
										mov eax,[esi+0]	; offset
										mov edx,[esi+4]	; len
									
										mov dword[ebx+sLINE_DATA.offset],eax
										mov dword[ebx+sLINE_DATA.len],edx	
										
										mov dword[ebx+sLINE_DATA.line.lineNo],ecx	; lineNo
										
										mov edx,[edi]
										mov dword[ebx+sLINE_DATA.line.lineInfoA],edx	; data
										
										inc [i]
										mov ecx,[i]										
										
										add ebx,sizeof.sLINE_DATA
										
									.endif																
									
								.endif
							
							inc [j]								
							add esi,8
							add edi,4		
							
							jmp .loop2
						
						.endif
						
					.else
						mov eax,[esi+0]	; bytesPerLine
						mov edx,[esi+4]	; bytesToCopy
						mov edi,[esi+8]	; offset
							
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],edx
						mov dword[ebx+sLINE_DATA.offset],edi
							
						mov eax,[esi+12]	; len							
						mov dword[ebx+sLINE_DATA.len],eax
							
						mov dword[ebx+sLINE_DATA.line.lineNo],ecx	; lineNo
														
						inc [i]
						add ebx,sizeof.sLINE_DATA
						add esi,4*4	
						
					.endif
				
				jmp .loop		
	.out:		
					
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingImportDirectoryEntryLineData uses ebx esi edi,ptrTree,pSection
				
				locals					
					numOfLines	dd	0
					lastEntry	dd	0
					secRVA		dd	0
					secRawData	dd	0
					i	dd	0					
					k	dd	0
				endl				
				
				mov ebx,[pSection]
				mov eax,[ebx+sSEC_HEADER_INFO.virtualAddress]
				mov edx,[ebx+sSEC_HEADER_INFO.pointerToRawData]
				mov [secRVA],eax
				mov [secRawData],edx
				
				mov ebx,[ptrTree]
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx
				push edx
					sub edx,5
					mov [lastEntry],edx
				pop edx				
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax											
				
	.loop:															
				mov edx,[lastEntry]
				.if [i] = edx
					mov esi,[k]
					imul esi,sizeof.IMAGE_IMPORT_DESCRIPTOR
					; 0.line import lookup table rva
					mov edi,0
					add edi,esi	
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],0
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					add ebx,sizeof.sLINE_DATA
					; 1.line timedatestamp
					mov edi,4
					add edi,esi	
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4	
					mov dword[ebx+sLINE_DATA.line.lineNo],1
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					add ebx,sizeof.sLINE_DATA
					; 2.line forwarder chain
					mov edi,8
					add edi,esi	
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4	
					mov dword[ebx+sLINE_DATA.line.lineNo],2
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					add ebx,sizeof.sLINE_DATA
					; 3.line name rva
					mov edi,12
					add edi,esi	
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4	
					mov dword[ebx+sLINE_DATA.line.lineNo],3
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					add ebx,sizeof.sLINE_DATA
					; 4.line  import address table rva
					mov edi,16
					add edi,esi	
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4	
					mov dword[ebx+sLINE_DATA.line.lineNo],4
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					
					jmp .out
					
				.else
					mov esi,[k]
					imul esi,sizeof.IMAGE_IMPORT_DESCRIPTOR
					; 0. line	import lookup table rva
					mov edi,0
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4
					mov dword[ebx+sLINE_DATA.offset],0
					mov dword[ebx+sLINE_DATA.len],20		
					mov dword[ebx+sLINE_DATA.line.lineNo],0
					add ebx,sizeof.sLINE_DATA
					; 1.line timedatestamp
					mov edi,4
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4
					mov dword[ebx+sLINE_DATA.offset],21
					mov dword[ebx+sLINE_DATA.len],13		
					mov dword[ebx+sLINE_DATA.line.lineNo],1
					add ebx,sizeof.sLINE_DATA
					; 2.line forwarder chain
					mov edi,8
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4
					mov dword[ebx+sLINE_DATA.offset],35
					mov dword[ebx+sLINE_DATA.len],14		
					mov dword[ebx+sLINE_DATA.line.lineNo],2
					add ebx,sizeof.sLINE_DATA
					; 3.line name rva
					mov edi,12
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4
					mov dword[ebx+sLINE_DATA.offset],50
					mov dword[ebx+sLINE_DATA.len],7	
					mov dword[ebx+sLINE_DATA.line.lineNo],3
					mov eax,[secRVA]
					mov dword[ebx+sLINE_DATA.line.lineInfoA],eax	; section rva
					mov ecx,[secRawData]
					mov dword[ebx+sLINE_DATA.line.lineInfoB],ecx	; ptr to section raw data					
					add ebx,sizeof.sLINE_DATA
					; 4.line  import address table rva
					mov edi,16
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4
					mov dword[ebx+sLINE_DATA.offset],58
					mov dword[ebx+sLINE_DATA.len],21		
					mov dword[ebx+sLINE_DATA.line.lineNo],4
					add ebx,sizeof.sLINE_DATA
					
				.endif
										
				inc [k]
				add [i],5					
					
				jmp .loop			
	.out:				
				
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingImportLookupTableLineData uses ebx esi edi,ptrTree,treeItemType
				
				locals
					numOfLines		dd	0
					numOfImports	dd	0
					fileAddress	dd	0
					rvaAddress	dd	0
					vaAddress	dd	0
					imgBase		dd	0
					i	dd	0
					j	dd	0
					dataInfo	db 4 dup 0
				endl
				
				mov ebx,[ptrTree]
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax				
				
				mov edi,[ptrFilePeInfo]
				mov eax,[edi+sFILE_PE_INFO.imageBase]				
				mov [imgBase],eax
				; addresses of the first import table
				.if [treeItemType] = TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO
					mov esi,[ptrImportNames]
					mov edx,[edi+sFILE_PE_INFO.numOfImports]
					
				.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO
					mov esi,[ptrDelayName]
					mov edx,[edi+sFILE_PE_INFO.numOfDelayImports]
					
				.endif
				mov [numOfImports],edx
				
				mov edx,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
				mov [fileAddress],edx
				mov eax,[esi+sIMPORT_DESCRIPTOR.rvaAddressStart]
				mov [rvaAddress],eax
				add eax,[imgBase]
				mov [vaAddress],eax
				mov esi,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
				lea edi,[dataInfo]
	.loop:				
					mov ecx,[i]
					cmp ecx,[numOfLines]
					je .out
						
						push ecx
							stdcall GetData,edi,esi,0,4
							mov eax,[fileAddress]
							mov edx,[rvaAddress]
							mov ecx,[vaAddress]
							mov dword[ebx+sLINE_DATA.line.lineInfoA],eax	; file start
							mov dword[ebx+sLINE_DATA.line.lineInfoB],edx	; rva start
							mov dword[ebx+sLINE_DATA.line.lineInfoC],ecx	; va start
							mov dword[ebx+sLINE_DATA.bytesToCopy],4
						pop ecx
						shl ecx,2
						mov dword[ebx+sLINE_DATA.bytesPerLine],ecx
						mov edx,[edi]						
						test edx,0x80000000						
						.if ~ZERO?
							; if msb is set , it is import by ordinal
							mov dword[ebx+sLINE_DATA.offset],0
							mov dword[ebx+sLINE_DATA.len],13
							inc [i]
							add esi,4
							add ebx,sizeof.sLINE_DATA
							
						.elseif edx <> 0
							; not set , not zero , its hint/name
							mov dword[ebx+sLINE_DATA.offset],14
							mov dword[ebx+sLINE_DATA.len],17
							inc [i]
							add esi,4
							add ebx,sizeof.sLINE_DATA
							
						.elseif edx = 0
							; end of import
							mov dword[ebx+sLINE_DATA.offset],47
							mov dword[ebx+sLINE_DATA.len],15
							; save end address
							.if [treeItemType] = TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO
								mov eax,[ptrImportNames]
								
							.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO
								mov eax,[ptrDelayName]
								
							.endif														
							mov ecx,[j]
							imul ecx,sizeof.sIMPORT_DESCRIPTOR
							add eax,ecx
							mov dword[eax+sIMPORT_DESCRIPTOR.fileAddressEnd],esi
							; check for end
							inc [j]
							mov ecx,[j]
							.if ecx = [numOfImports]
								jmp .out
							
							.else
								; next import table
								.if [treeItemType] = TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO
									mov esi,[ptrImportNames]
									
								.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO
									mov esi,[ptrDelayName]
									
								.endif								
								
								imul ecx,sizeof.sIMPORT_DESCRIPTOR
								add esi,ecx								
								mov edx,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
								mov [fileAddress],edx
								mov eax,[esi+sIMPORT_DESCRIPTOR.rvaAddressStart]
								mov [rvaAddress],eax
								add eax,[imgBase]
								mov [vaAddress],eax
								mov esi,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
								; for every import table bytes per line is reseting
								mov [i],0
								add ebx,sizeof.sLINE_DATA
								
							.endif													
							
						.endif
						
					
					jmp .loop
	.out:						
										
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingImportAddressTableLineData uses ebx esi edi,ptrTree,treeItemType
				locals
					numOfLines		dd	0
					numOfImports	dd	0
					boundImport		dd	0
					delayBoundImport	dd	0
					fileAddress	dd	0
					rvaAddress	dd	0
					vaAddress	dd	0
					imgBase		dd	0
					i	dd	0
					j	dd	0
					dataInfo	db 4 dup 0
				endl
																
				mov ebx,[ptrTree]
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax								
				
				; addresses of the first import table
				mov edi,[ptrFilePeInfo]
				mov edx,[edi+sFILE_PE_INFO.delayBoundImport]
				mov [delayBoundImport],edx
				mov eax,[edi+sFILE_PE_INFO.imageBase]
				mov ecx,[edi+sFILE_PE_INFO.boundImport]
				.if [treeItemType] = TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO
					mov esi,[ptrImportAddress]
					mov edx,[edi+sFILE_PE_INFO.numOfImports]
					
				.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO
					mov esi,[ptrDelayAddress]
					mov edx,[edi+sFILE_PE_INFO.numOfDelayImports]
					
				.endif
				mov [imgBase],eax
				mov [numOfImports],edx
				mov [boundImport],ecx				
				
				mov edx,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
				mov [fileAddress],edx
				mov eax,[esi+sIMPORT_DESCRIPTOR.rvaAddressStart]
				mov [rvaAddress],eax
				add eax,[imgBase]
				mov [vaAddress],eax
				mov esi,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
				lea edi,[dataInfo]
	.loop:				
					mov ecx,[i]
					cmp ecx,[numOfLines]
					je .out
						
						push ecx
							stdcall GetData,edi,esi,0,4
							mov eax,[fileAddress]
							mov edx,[rvaAddress]
							mov ecx,[vaAddress]
							mov dword[ebx+sLINE_DATA.line.lineInfoA],eax	; file start
							mov dword[ebx+sLINE_DATA.line.lineInfoB],edx	; rva start
							mov dword[ebx+sLINE_DATA.line.lineInfoC],ecx	; va start
							mov dword[ebx+sLINE_DATA.bytesToCopy],4
						pop ecx
						shl ecx,2
						mov dword[ebx+sLINE_DATA.bytesPerLine],ecx
						mov edx,[edi]						
						test edx,0x80000000						
						.if ~ZERO?
							; if msb is set , it is import by ordinal
							mov dword[ebx+sLINE_DATA.offset],0
							mov dword[ebx+sLINE_DATA.len],13
							inc [i]
							add esi,4
							add ebx,sizeof.sLINE_DATA
							
						.elseif edx <> 0
							; not set , not zero , its hint/name or virtual address							
							.if signed [boundImport] < 0 | [boundImport] = 1 
								; virtual address
								mov dword[ebx+sLINE_DATA.offset],32
								mov dword[ebx+sLINE_DATA.len],14
								; if it is a virtual address we need rva of import lookup table
								; for hint/name indexing
								mov ecx,[j]
								mov dword[ebx+sLINE_DATA.line.lineNo],ecx
							
							.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO & [delayBoundImport] = 1  
								; virtual address
								mov dword[ebx+sLINE_DATA.offset],32
								mov dword[ebx+sLINE_DATA.len],14
								; if it is a virtual address we need rva of import lookup table
								; for hint/name indexing
								mov ecx,[j]
								mov dword[ebx+sLINE_DATA.line.lineNo],ecx
																																			
							.else
								; hint/name
								mov dword[ebx+sLINE_DATA.offset],14
								mov dword[ebx+sLINE_DATA.len],17
							
							.endif
							
							inc [i]
							add esi,4
							add ebx,sizeof.sLINE_DATA
							
						.elseif edx = 0
							; end of import
							mov dword[ebx+sLINE_DATA.offset],47
							mov dword[ebx+sLINE_DATA.len],15
							; save end address
							.if [treeItemType] = TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO
								mov eax,[ptrImportAddress]
								
							.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO
								mov eax,[ptrDelayAddress]
								
							.endif
																					
							mov ecx,[j]
							imul ecx,sizeof.sIMPORT_DESCRIPTOR
							add eax,ecx
							mov dword[eax+sIMPORT_DESCRIPTOR.fileAddressEnd],esi
							; check for end
							inc [j]
							mov ecx,[j]
							.if ecx = [numOfImports]
								jmp .out
							
							.else
								; next import table
								.if [treeItemType] = TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO
									mov esi,[ptrImportAddress]
								
								.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO
									mov esi,[ptrDelayAddress]
									
								.endif																
								imul ecx,sizeof.sIMPORT_DESCRIPTOR
								add esi,ecx								
								mov edx,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
								mov [fileAddress],edx
								mov eax,[esi+sIMPORT_DESCRIPTOR.rvaAddressStart]
								mov [rvaAddress],eax
								add eax,[imgBase]
								mov [vaAddress],eax
								mov esi,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
								; for every import table bytes per line is reseting
								mov [i],0
								add ebx,sizeof.sLINE_DATA
								
							.endif													
							
						.endif
						
					
					jmp .loop
	.out:						
				
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingExportDirectoryEntryLineData uses ebx esi edi,ptrTree
				
				locals
					strTbl	dd	0,4,0,11,4,4,12,13,8,2,26,12,10,2,39,12,12,4,52,7,16,4,60,11,20,4,72,19,24,4,92,20,28,4,113,21,32,4,135,14,36,4,150,15
					
				endl
				
				mov ebx,[ptrTree]
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				lea esi,[strTbl]				
				xor ecx,ecx
	.loop:			
				cmp ecx,11
				je .out
					
					mov eax,[esi+0]	; bytesPerLine
					mov edx,[esi+4]	; bytesToCopy
					mov edi,[esi+8]	; offset
					
					mov dword[ebx+sLINE_DATA.bytesPerLine],eax
					mov dword[ebx+sLINE_DATA.bytesToCopy],edx
					mov dword[ebx+sLINE_DATA.offset],edi
					
					mov eax,[esi+12]	; len							
					mov dword[ebx+sLINE_DATA.len],eax
					
					mov dword[ebx+sLINE_DATA.line.lineNo],ecx	; lineNo
					; save dll name file address
					.if ecx = 4
						mov edx,[ptrExportDirec]
						mov edx,[edx+sEXPORT_DIRECTORY.nameFile]
						mov dword[ebx+sLINE_DATA.line.lineInfoA],edx	; name file
						
					.endif
												
				inc ecx
				add ebx,sizeof.sLINE_DATA
				add esi,4*4
				jmp .loop		
	.out:				
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]			
				ret
			endp
			
			proc ProcessingExportAddressTableLineData uses ebx esi edi,ptrTree
				
				locals
					numOfLines	dd	0
					address		dd	0
					ordinal		dd	0
					i	dd	0
					dataInfo	db 4 dup 0
				endl
				
				mov ebx,[ptrTree]
				mov eax,[ebx+sTREE_ITEM_TYPE.address.file]
				mov [address],eax
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				mov esi,[ptrExportDirec]
				lea edi,[dataInfo]							
	.loop:		
				mov ecx,[i]		
				cmp ecx,[numOfLines]
				je .out
				
				mov eax,[i]
				add eax,[esi+sEXPORT_DIRECTORY.ordinalBase]
				mov [ordinal],eax						
				shl ecx,2
				mov dword[ebx+sLINE_DATA.bytesPerLine],ecx	
				mov dword[ebx+sLINE_DATA.bytesToCopy],4
				stdcall GetData,edi,[address],ecx,4					
				mov eax,[edi]
					.if eax <> 0
						mov edx,[esi+sEXPORT_DIRECTORY.exportDataDirecRVA]
						add edx,[esi+sEXPORT_DIRECTORY.exportDataDirecSize]	
							.if eax >= [esi+sEXPORT_DIRECTORY.exportDataDirecRVA] & eax <= edx
							; if address is within export data directory -> forwarder rva
								; calc file start
								mov edx,[esi+sEXPORT_DIRECTORY.sectionRVA]
								sub eax,edx
								add eax,[esi+sEXPORT_DIRECTORY.sectionPtrToRawData]
								mov dword[ebx+sLINE_DATA.line.lineInfoA],eax	; file start
								mov dword[ebx+sLINE_DATA.offset],11
								mov dword[ebx+sLINE_DATA.len],13
									
							.else
							; if address is not within export data directory ->  export rva
								; find the index into ordinal table for ordinal - ordinal base
								; get name for that index		
								xor ecx,ecx
				.loop2:						
								cmp ecx,[esi+sEXPORT_DIRECTORY.numOfNamePointerEntries]
								je .no_name
									push ecx										
										shl ecx,1										
										stdcall GetData,edi,dword[esi+sEXPORT_DIRECTORY.ordinalTableFile],ecx,2
									pop ecx
									lea eax,[edi]
									movzx eax,word[eax]
									; get ordinal - base
									mov edx,[ordinal]
									sub edx,[esi+sEXPORT_DIRECTORY.ordinalBase]
									; is index = ordinal - base						
									.if eax = edx
										push ecx	
											shl ecx,2
											stdcall GetData,edi,dword[esi+sEXPORT_DIRECTORY.namePointerFile],ecx,4
										pop ecx	
										lea eax,[edi]
										mov eax,[eax]
										sub eax,[esi+sEXPORT_DIRECTORY.sectionRVA]
										add eax,[esi+sEXPORT_DIRECTORY.sectionPtrToRawData]
										mov dword[ebx+sLINE_DATA.line.lineInfoA],eax	; file start
										mov dword[ebx+sLINE_DATA.offset],0
										mov dword[ebx+sLINE_DATA.len],10
										jmp .out2																		
										
									.endif
															
								inc ecx
								jmp .loop2
				
				.no_name:		
								mov dword[ebx+sLINE_DATA.offset],0
								mov dword[ebx+sLINE_DATA.len],10
								jmp .out2				
											
							.endif
								
					.endif
		.out2:				
												
				inc [i]
				add ebx,sizeof.sLINE_DATA
				jmp .loop			
	.out:						
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingExportNamePtrTableLineData uses ebx esi edi,ptrTree
				
				locals
					numOfLines	dd	0
					address		dd	0
					i	dd	0
					dataInfo db 4 dup 0
				endl
				
				mov ebx,[ptrTree]
				mov eax,[ebx+sTREE_ITEM_TYPE.address.file]
				mov [address],eax
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				mov esi,[ptrExportDirec]
				lea edi,[dataInfo]			
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
					
					shl ecx,1					
					; get ordinal
					stdcall GetData,edi,dword[esi+sEXPORT_DIRECTORY.ordinalTableFile],ecx,2
					movzx edx,word[edi]
					add edx,[esi+sEXPORT_DIRECTORY.ordinalBase]
					; save
					mov dword[ebx+sLINE_DATA.line.lineInfoA],edx	; ordinal
					mov ecx,[i]
					shl ecx,2
					mov dword[ebx+sLINE_DATA.bytesPerLine],ecx
					mov dword[ebx+sLINE_DATA.bytesToCopy],4
					stdcall GetData,edi,[address],ecx,4
					mov edx,[edi]
					; get name rva to name file
					sub edx,[esi+sEXPORT_DIRECTORY.sectionRVA]
					add edx,[esi+sEXPORT_DIRECTORY.sectionPtrToRawData]
					; save
					mov dword[ebx+sLINE_DATA.line.lineInfoB],edx	; name file
				
				inc [i]
				add ebx,sizeof.sLINE_DATA
				jmp .loop
	.out:									
							
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingExportOrdinalTableLineData uses ebx esi edi,ptrTree
				
				locals
					numOfLines	dd	0
					address		dd	0
					i	dd	0
					dataInfo db 4 dup 0
				endl
				
				mov ebx,[ptrTree]
				mov eax,[ebx+sTREE_ITEM_TYPE.address.file]
				mov [address],eax
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				mov esi,[ptrExportDirec]
				lea edi,[dataInfo]			
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
					
					shl ecx,1
					mov dword[ebx+sLINE_DATA.bytesPerLine],ecx
					mov dword[ebx+sLINE_DATA.bytesToCopy],2
					; get ordinal
					stdcall GetData,edi,[address],ecx,2
					movzx edx,word[edi]
					add edx,[esi+sEXPORT_DIRECTORY.ordinalBase]
					mov dword[ebx+sLINE_DATA.line.lineInfoA],edx	; ordinal
					; get name rva to name file
					mov ecx,[i]
					shl ecx,2
					stdcall GetData,edi,dword[esi+sEXPORT_DIRECTORY.namePointerFile],ecx,4
					mov edx,[edi]
					sub edx,[esi+sEXPORT_DIRECTORY.sectionRVA]
					add edx,[esi+sEXPORT_DIRECTORY.sectionPtrToRawData]
					; save
					mov dword[ebx+sLINE_DATA.line.lineInfoB],edx	; name file
				
				inc [i]
				add ebx,sizeof.sLINE_DATA
				jmp .loop
	.out:													
							
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingBoundDirectoryEntryLineData uses ebx esi edi,ptrTree
				
				locals
					numOfLines	dd	0
					address		dd	0
					i	dd	0
					j	dd	0
					k	dd	0
					dataInfo db 4 dup 0
				endl
				
				mov ebx,[ptrTree]
				mov eax,[ebx+sTREE_ITEM_TYPE.address.file]
				mov [address],eax
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				xor esi,esi							
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
					
					lea edi,[dataInfo]
					; reading IMAGE_BOUND_IMPORT_DESCRIPTOR struct
					; TimeDateStamp
					stdcall GetData,edi,[address],0,4
					mov edx,[edi]
					mov [j],edx
					; OffsetModuleName
					stdcall GetData,edi,[address],4,2
					movzx edx,word[edi]
					mov [k],edx
					; NumberOfModuleForwarderRefs
					stdcall GetData,edi,[address],6,2
					movzx edi,word[edi]
					
					; last bound directory entry is filled with zeroes
					.if [j] = 0 & [k] = 0 & edi = 0
						mov ecx,esi
						imul ecx,sizeof.IMAGE_BOUND_IMPORT_DESCRIPTOR
						; TimeDateStamp
						mov eax,0
						add eax,ecx
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],4
						mov dword[ebx+sLINE_DATA.line.lineNo],0
						mov dword[ebx+sLINE_DATA.line.lineInfoA],1						
						add ebx,sizeof.sLINE_DATA
						; OffsetModuleName
						mov eax,4
						add eax,ecx
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],2						
						mov dword[ebx+sLINE_DATA.line.lineNo],1
						mov dword[ebx+sLINE_DATA.line.lineInfoA],1					
						add ebx,sizeof.sLINE_DATA
						; NumberOfModuleForwarderRefs
						mov eax,6
						add eax,ecx
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],2						
						mov dword[ebx+sLINE_DATA.line.lineNo],2
						mov dword[ebx+sLINE_DATA.line.lineInfoA],1						
						add ebx,sizeof.sLINE_DATA
						
						jmp .out
						
					.else
						mov ecx,esi
						imul ecx,sizeof.IMAGE_BOUND_IMPORT_DESCRIPTOR
						; TimeDateStamp
						mov eax,0
						add eax,ecx
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],4
						mov dword[ebx+sLINE_DATA.offset],0
						mov dword[ebx+sLINE_DATA.len],13
						mov dword[ebx+sLINE_DATA.line.lineNo],0					
						add ebx,sizeof.sLINE_DATA
						; OffsetModuleName
						mov eax,4
						add eax,ecx
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],2
						mov dword[ebx+sLINE_DATA.offset],14
						mov dword[ebx+sLINE_DATA.len],16
						mov dword[ebx+sLINE_DATA.line.lineNo],1				
						add ebx,sizeof.sLINE_DATA
						; NumberOfModuleForwarderRefs
						mov eax,6
						add eax,ecx
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],2
						mov dword[ebx+sLINE_DATA.offset],31
						mov dword[ebx+sLINE_DATA.len],27
						mov dword[ebx+sLINE_DATA.line.lineNo],2					
						add ebx,sizeof.sLINE_DATA
						
						; next 
						inc esi
						add [i],3
						add [address],sizeof.IMAGE_BOUND_IMPORT_DESCRIPTOR
						
					.endif
																																								
					; is there a forwarders
					.if edi <> 0
						xor ecx,ecx
		.loop2:				
						cmp ecx,edi
						je .loop
							push ecx
							
								imul ecx,sizeof.IMAGE_BOUND_FORWARDER_REF
								mov edx,esi
								imul edx,sizeof.IMAGE_BOUND_IMPORT_DESCRIPTOR
								; TimeDateStamp
								mov eax,0
								add eax,ecx
								add eax,edx
								mov dword[ebx+sLINE_DATA.bytesPerLine],eax
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								mov dword[ebx+sLINE_DATA.offset],0
								mov dword[ebx+sLINE_DATA.len],13
								mov dword[ebx+sLINE_DATA.line.lineNo],0																				
								add ebx,sizeof.sLINE_DATA
								; OffsetModuleName
								mov eax,4
								add eax,ecx
								add eax,edx
								mov dword[ebx+sLINE_DATA.bytesPerLine],eax
								mov dword[ebx+sLINE_DATA.bytesToCopy],2
								mov dword[ebx+sLINE_DATA.offset],14
								mov dword[ebx+sLINE_DATA.len],16
								mov dword[ebx+sLINE_DATA.line.lineNo],1																		
								add ebx,sizeof.sLINE_DATA
								; Reserved
								mov eax,6
								add eax,ecx
								add eax,edx
								mov dword[ebx+sLINE_DATA.bytesPerLine],eax
								mov dword[ebx+sLINE_DATA.bytesToCopy],2
								mov dword[ebx+sLINE_DATA.offset],59
								mov dword[ebx+sLINE_DATA.len],8
								mov dword[ebx+sLINE_DATA.line.lineNo],2												
								add ebx,sizeof.sLINE_DATA
								
								; next
								inc esi
								add [i],3
								add [address],sizeof.IMAGE_BOUND_FORWARDER_REF
					
							pop ecx
						inc ecx
						jmp .loop2
						
					.endif					
				
				jmp .loop		
	.out:						
							
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingImageBaseRelocationLineData uses ebx esi edi,ptrTree
				
				locals															
					numOfLines	dd	0
					address		dd	0
					startAddr	dd	0
					pageRVA		dd	0
					blockSize	dd	0
					i	dd	0
					j	dd	0
					dataInfo db 4 dup 0
				endl
				
				mov ebx,[ptrTree]
				mov eax,[ebx+sTREE_ITEM_TYPE.address.file]
				mov [address],eax
				mov [startAddr],eax
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				
				; check for 2 lines only
				.if [numOfLines] = 2
					mov dword[ebx+sLINE_DATA.bytesPerLine],0
					mov dword[ebx+sLINE_DATA.bytesToCopy],4
					mov dword[ebx+sLINE_DATA.offset],0
					mov dword[ebx+sLINE_DATA.len],7
					add ebx,sizeof.sLINE_DATA
					
					mov dword[ebx+sLINE_DATA.bytesPerLine],4
					mov dword[ebx+sLINE_DATA.bytesToCopy],4
					mov dword[ebx+sLINE_DATA.offset],8
					mov dword[ebx+sLINE_DATA.len],9
					
				.else
					lea edi,[dataInfo]
	.loop:				
					mov ecx,[i]
					cmp ecx,[numOfLines]
					je .out
						
						; read page rva
						stdcall GetData,edi,[address],0,4
						mov edx,[edi]
						mov [pageRVA],edx
						; read block size
						stdcall GetData,edi,[address],4,4
						mov edx,[edi]
						; check for 2 liners
						.if [pageRVA] = 0 & edx <> 0
							; next address						
							add [address],edx
							; set bytesperline for this block
							mov esi,[blockSize]
							; for the next page we have to skip prev
							add [blockSize],edx
							; set pagerva and blocksize lines
							mov dword[ebx+sLINE_DATA.bytesPerLine],esi
							mov dword[ebx+sLINE_DATA.bytesToCopy],4
							mov dword[ebx+sLINE_DATA.offset],0
							mov dword[ebx+sLINE_DATA.len],7
							inc [i]
							add ebx,sizeof.sLINE_DATA
							mov eax,esi
							add eax,4
							mov dword[ebx+sLINE_DATA.bytesPerLine],eax
							mov dword[ebx+sLINE_DATA.bytesToCopy],4
							mov dword[ebx+sLINE_DATA.offset],8
							mov dword[ebx+sLINE_DATA.len],9
							inc [i]
							add ebx,sizeof.sLINE_DATA
							jmp .loop
							
						.elseif [pageRVA] = 0 & edx = 0
							; set bytesperline for this block
							mov esi,[blockSize]
							; for the next page we have to skip prev
							add [blockSize],edx
							; set pagerva and blocksize lines
							mov dword[ebx+sLINE_DATA.bytesPerLine],esi
							mov dword[ebx+sLINE_DATA.bytesToCopy],4
							mov dword[ebx+sLINE_DATA.offset],0
							mov dword[ebx+sLINE_DATA.len],7
							inc [i]
							add ebx,sizeof.sLINE_DATA
							mov eax,esi
							add eax,4
							mov dword[ebx+sLINE_DATA.bytesPerLine],eax
							mov dword[ebx+sLINE_DATA.bytesToCopy],4
							mov dword[ebx+sLINE_DATA.offset],8
							mov dword[ebx+sLINE_DATA.len],9
							inc [i]
							add ebx,sizeof.sLINE_DATA
							jmp .loop
							
						.endif
						
						; next address						
						add [address],edx
						; set bytesperline for this block
						mov esi,[blockSize]
						; for the next page we have to skip prev
						add [blockSize],edx
						; set first 2 lines ( pagerva and block size )
						mov dword[ebx+sLINE_DATA.bytesPerLine],esi
						mov dword[ebx+sLINE_DATA.bytesToCopy],4
						mov dword[ebx+sLINE_DATA.offset],0
						mov dword[ebx+sLINE_DATA.len],7
						inc [i]
						add ebx,sizeof.sLINE_DATA
						mov eax,esi
						add eax,4
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],4
						mov dword[ebx+sLINE_DATA.offset],8
						mov dword[ebx+sLINE_DATA.len],9
						inc [i]
						add ebx,sizeof.sLINE_DATA
						; set block lines
						; sub 8 bytes for 2 added 2 lines ( page rva and block size ) 2*4 bytes
						sub edx,8
						; rest are words so div by 2 bytes per line
						shr edx,1
						add [i],edx
						mov [j],edx					
						xor ecx,ecx
	.loop2:				
						cmp ecx,[j]
						je .loop
						push ecx
							; sizeof.word + offset 8 + prev block esi
							shl ecx,1
							add ecx,8
							add ecx,esi
							mov dword[ebx+sLINE_DATA.bytesPerLine],ecx
							mov dword[ebx+sLINE_DATA.bytesToCopy],2
							; read data
							; if data = 0 last entry , no description
							; set type and offset fields
							stdcall GetData,edi,[startAddr],dword[ebx+sLINE_DATA.bytesPerLine],2
							
						pop ecx
																																					
						movzx eax,word[edi]
						mov edx,eax
						.if word[edi] = 0							
							inc ecx
							add ebx,sizeof.sLINE_DATA				
							jmp .loop2
							
						.else
							mov dword[ebx+sLINE_DATA.offset],18
							mov dword[ebx+sLINE_DATA.len],11													
							; get reloc type
							and eax,0x0000F000
							shr eax,12
							.if eax = 0
								mov dword[ebx+sLINE_DATA.line.lineInfoA],30		; offset for reloc type
								mov dword[ebx+sLINE_DATA.line.lineInfoB],24		; len for reloc type
								
							.elseif eax = 1
								mov dword[ebx+sLINE_DATA.line.lineInfoA],55
								mov dword[ebx+sLINE_DATA.line.lineInfoB],20
								
							.elseif eax = 2
								mov dword[ebx+sLINE_DATA.line.lineInfoA],76
								mov dword[ebx+sLINE_DATA.line.lineInfoB],19
								
							.elseif eax = 3
								mov dword[ebx+sLINE_DATA.line.lineInfoA],96
								mov dword[ebx+sLINE_DATA.line.lineInfoB],23
								
							.elseif eax = 4
								mov dword[ebx+sLINE_DATA.line.lineInfoA],120
								mov dword[ebx+sLINE_DATA.line.lineInfoB],23
								
							.else
								mov dword[ebx+sLINE_DATA.line.lineInfoA],0
								mov dword[ebx+sLINE_DATA.line.lineInfoB],0
							
							.endif																			
							; get offset value for that relocation					
							and edx,0x00000FFF
							add edx,[pageRVA]
							mov dword[ebx+sLINE_DATA.line.lineInfoC],edx	; offset value for relocation
							
						.endif	
																																
						inc ecx
						add ebx,sizeof.sLINE_DATA
						jmp .loop2																					
	.out:				
				.endif
				
							
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingImageLoadConfigurationEntryLineData uses ebx esi edi,ptrTree
				
				locals
					strTbl	dd	0,4,0,15,4,4,16,13,8,2,30,12,10,2,43,12,12,4,56,16,16,4,73,14,20,4,88,29,24,4,118,26,28,4,145,26,32,4,172,15,36,4,188,21,\
								40,4,210,22,44,4,233,19,48,4,253,16,52,2,270,10,54,2,281,8,56,4,290,8,60,4,299,14,64,4,314,14,68,4,329,14
					numOfLines	dd	0
					i	dd	0
				endl
				
				mov ebx,[ptrTree]								
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				lea esi,[strTbl]			
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
										
					mov eax,[esi+0]		; bytesperline
					mov edx,[esi+4]		; bytestocopy
					mov ecx,[esi+8]		; offset
					mov edi,[esi+12]	; len
					mov dword[ebx+sLINE_DATA.bytesPerLine],eax
					mov dword[ebx+sLINE_DATA.bytesToCopy],edx
					mov dword[ebx+sLINE_DATA.offset],ecx
					mov dword[ebx+sLINE_DATA.len],edi					
				
				inc [i]
				add esi,4*4
				add ebx,sizeof.sLINE_DATA
				jmp .loop		
	.out:			
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingImageTlsDirectoryEntryLineData uses ebx esi edi,ptrTree
				
				locals
					strTbl		dd	0,4,0,14,4,4,15,12,8,4,28,14,12,4,43,18,16,4,62,14,20,4,77,15	
					numOfLines	dd	0
					i	dd	0
				endl
				
				mov ebx,[ptrTree]								
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				lea esi,[strTbl]
								
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
					
					mov eax,[esi+0]		; bytesperline
					mov edx,[esi+4]		; bytestocopy
					mov ecx,[esi+8]		; offset
					mov edi,[esi+12]	; len
					mov dword[ebx+sLINE_DATA.bytesPerLine],eax
					mov dword[ebx+sLINE_DATA.bytesToCopy],edx
					mov dword[ebx+sLINE_DATA.offset],ecx
					mov dword[ebx+sLINE_DATA.len],edi					
				
				inc [i]
				add esi,4*4
				add ebx,sizeof.sLINE_DATA
				jmp .loop		
	.out:								
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingDelayImportDirecEntryLineData uses ebx esi edi,ptrTree,pSection
				
				locals					
					numOfLines	dd	0
					lastEntry	dd	0
					secRVA		dd	0
					secRawData	dd	0
					i	dd	0					
					k	dd	0
				endl				
				
				mov ebx,[pSection]
				mov eax,[ebx+sSEC_HEADER_INFO.virtualAddress]
				mov edx,[ebx+sSEC_HEADER_INFO.pointerToRawData]
				mov [secRVA],eax
				mov [secRawData],edx
				
				mov ebx,[ptrTree]
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx
				push edx
					sub edx,8
					mov [lastEntry],edx
				pop edx				
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax				
	.loop:			
				mov edx,[i]
				.if edx = [lastEntry]
					mov esi,[k]
					imul esi,sizeof.DELAY_IMPORT_DESCRIPTOR
					; 0.line attributes
					mov edi,0
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],0
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					add ebx,sizeof.sLINE_DATA
					; 1.line name
					mov edi,4
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],1
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					add ebx,sizeof.sLINE_DATA
					; 2.line module handle
					mov edi,8
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],2
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					add ebx,sizeof.sLINE_DATA
					; 3.line delay import address table
					mov edi,12
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],3
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					add ebx,sizeof.sLINE_DATA
					; 4.line delay import name table
					mov edi,16
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],4
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					add ebx,sizeof.sLINE_DATA
					; 5.line bound delay import table
					mov edi,20
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],5
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					add ebx,sizeof.sLINE_DATA
					; 6.line unload delay import table
					mov edi,24
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],6
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					add ebx,sizeof.sLINE_DATA
					; 7.line time stamp
					mov edi,28
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],7
					mov dword[ebx+sLINE_DATA.line.lineInfoC],1
					add ebx,sizeof.sLINE_DATA
										
					jmp .out
					
				.else
					mov esi,[k]
					imul esi,sizeof.DELAY_IMPORT_DESCRIPTOR
					; 0.line attributes
					mov edi,0
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],0
					mov dword[ebx+sLINE_DATA.offset],0
					mov dword[ebx+sLINE_DATA.len],10	
					add ebx,sizeof.sLINE_DATA
					; 1.line name
					mov edi,4
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],1
					mov dword[ebx+sLINE_DATA.offset],11
					mov dword[ebx+sLINE_DATA.len],4	
					mov eax,[secRVA]
					mov dword[ebx+sLINE_DATA.line.lineInfoA],eax	; section rva
					mov ecx,[secRawData]
					mov dword[ebx+sLINE_DATA.line.lineInfoB],ecx	; ptr to section raw data	
					add ebx,sizeof.sLINE_DATA
					; 2.line module handle
					mov edi,8
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],2
					mov dword[ebx+sLINE_DATA.offset],16
					mov dword[ebx+sLINE_DATA.len],12	
					add ebx,sizeof.sLINE_DATA
					; 3.line delay import address table
					mov edi,12
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],3
					mov dword[ebx+sLINE_DATA.offset],29
					mov dword[ebx+sLINE_DATA.len],23	
					add ebx,sizeof.sLINE_DATA
					; 4.line delay import name table
					mov edi,16
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],4
					mov dword[ebx+sLINE_DATA.offset],53
					mov dword[ebx+sLINE_DATA.len],20	
					add ebx,sizeof.sLINE_DATA
					; 5.line bound delay import table
					mov edi,20
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],5
					mov dword[ebx+sLINE_DATA.offset],74
					mov dword[ebx+sLINE_DATA.len],21	
					add ebx,sizeof.sLINE_DATA
					; 6.line unload delay import table
					mov edi,24
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],6
					mov dword[ebx+sLINE_DATA.offset],96
					mov dword[ebx+sLINE_DATA.len],22	
					add ebx,sizeof.sLINE_DATA
					; 7.line time stamp
					mov edi,28
					add edi,esi
					mov dword[ebx+sLINE_DATA.bytesPerLine],edi
					mov dword[ebx+sLINE_DATA.bytesToCopy],4				
					mov dword[ebx+sLINE_DATA.line.lineNo],7
					mov dword[ebx+sLINE_DATA.offset],119
					mov dword[ebx+sLINE_DATA.len],9	
					add ebx,sizeof.sLINE_DATA
					
				.endif
				
				inc [k]
				add [i],8
				jmp .loop
	.out:		
					
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingDebugDirectoryEntryLineData uses ebx esi edi,ptrTree
				
				locals
					strTbl	dd	0,4,0,15,4,4,16,13,8,2,30,12,10,2,43,12,12,4,56,4,16,4,61,10,20,4,72,16,24,4,89,16
					dbgType	dd	0,24,  25,21,  47,25,  73,20,  94,21,  116,26,  143,22,  166,28,  195,30,  226,24,  251,27,  279,22
					numOfLines	dd	0
					address	dd	0
					i	dd	0
					k	dd	0
					dataInfo db 4 dup 0
				endl
				
				mov ebx,[ptrTree]
				mov eax,[ebx+sTREE_ITEM_TYPE.address.file]
				mov [address],eax								
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				lea esi,[strTbl]
						
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
					
					xor ecx,ecx
					xor edi,edi
					; Characteristics TimeDateStamp MajorVersion MinorVersion Type SizeOfData AddressOfRawData PointerToRawData
		.loop2:			
					cmp ecx,8
					je .next	
						; calc bytes per line
						mov eax,[k]
						imul eax,sizeof.IMAGE_DEBUG_DIRECTORY
						add eax,[esi+edi*4]
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						inc edi						
						; bytes to copy
						mov edx,[esi+edi*4]
						mov dword[ebx+sLINE_DATA.bytesToCopy],edx
						inc edi
						; offset
						mov eax,[esi+edi*4]
						mov dword[ebx+sLINE_DATA.offset],eax
						inc edi
						; len
						mov edx,[esi+edi*4]
						mov dword[ebx+sLINE_DATA.len],edx
						inc edi
						; line no
						mov dword[ebx+sLINE_DATA.line.lineNo],ecx
						.if ecx = 4
							; debug type
							push ecx
							push esi
											
								lea esi,[dbgType]
								stdcall GetData,addr dataInfo,[address],12,4
								lea ecx,[dataInfo]
								mov ecx,[ecx]
								; get offset and len
								imul ecx,8
								add esi,ecx
								mov eax,[esi+0]		; offset
								mov edx,[esi+4]		; len
								mov dword[ebx+sLINE_DATA.line.lineInfoA],eax	; offset
								mov dword[ebx+sLINE_DATA.line.lineInfoB],edx	; len
								
							pop esi	
							pop ecx
							
						.endif
						
						inc [i]
						inc ecx
						add ebx,sizeof.sLINE_DATA
						jmp .loop2															
					
	.next:				
				inc [k]
				add [address],sizeof.IMAGE_DEBUG_DIRECTORY
				jmp .loop
	.out:		
					
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingDebugFpoTypeLineData uses ebx esi edi,ptrTree
				
				; 5 lines of fpo_data struct , 6 lines of extra
				locals
					strTbl		dd	0,4,0,20, 4,4,21,12, 8,4,34,18, 12,2,53,18, 14,2,0,0,  0,0,72,15, 0,0,88,9, 0,0,98,11, 0,0,110,10, 0,0,121,8, 0,0,130,9
					fpoType		dd	140,9,  150,10,  161,9,  171,12
					address		dd	0
					numOfLines	dd	0
					extra		dd	0
					i	dd	0
					k	dd	0
					dataInfo db 4 dup 0
				endl
				
				mov ebx,[ptrTree]
				mov eax,[ebx+sTREE_ITEM_TYPE.address.file]
				mov [address],eax								
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				lea esi,[strTbl]
						
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
					
					xor edi,edi
					xor ecx,ecx					
		.loop2:			
					cmp ecx,11
					je .next
						
						; extra lines - NoBytesInProlog RegsSaved IsSehInFunc IsEbpAlloc Reserved FrameType 
						.if ecx > 4
							; bytesperline and bytestocopy are 0 , skip them
							add edi,2
							; offset
							mov eax,[esi+edi*4]
							mov dword[ebx+sLINE_DATA.offset],eax
							inc edi
							; len
							mov edx,[esi+edi*4]
							mov dword[ebx+sLINE_DATA.len],edx
							inc edi
							; line no
							mov dword[ebx+sLINE_DATA.line.lineNo],ecx
							.if ecx = 5
								; NoBytesInProlog								
								mov edx,[extra]
								and edx,0xff
								mov dword[ebx+sLINE_DATA.line.lineInfoA],edx
								
							.elseif ecx = 6
								; RegsSaved					
								mov edx,[extra]
								and edx,0x700
								shr edx,8
								mov dword[ebx+sLINE_DATA.line.lineInfoA],edx
							
							.elseif ecx = 7
								; IsSehInFunc
								mov edx,[extra]
								and edx,0x800
								shr edx,11
								mov dword[ebx+sLINE_DATA.line.lineInfoA],edx
								
							.elseif ecx = 8
								; IsEbpAlloc
								mov edx,[extra]
								and edx,0x1000
								shr edx,12
								mov dword[ebx+sLINE_DATA.line.lineInfoA],edx
								
							.elseif ecx = 9
								; Reserved
								mov edx,[extra]
								and edx,0x2000
								shr edx,13
								mov dword[ebx+sLINE_DATA.line.lineInfoA],edx
							
							.elseif ecx = 10
								; FrameType
								mov edx,[extra]
								and edx,0xc000
								shr edx,14
								mov dword[ebx+sLINE_DATA.line.lineInfoA],edx
								push edi
									lea edi,[fpoType]
									imul edx,4*2
									add edi,edx						
									mov eax,[edi+0]
									mov edx,[edi+4]
									mov dword[ebx+sLINE_DATA.line.lineInfoB],eax	; offset
									mov dword[ebx+sLINE_DATA.line.lineInfoC],edx	; len
								pop edi
								
							.endif							
														
						.else
							; OffsetToFunctionCode FunctionSize NoOfLocals(DWORDs) NoOfParams(DWORDs) extra
							; calc bytes per line
							mov eax,[k]
							imul eax,sizeof.FPO_DATA
							add eax,[esi+edi*4]
							mov dword[ebx+sLINE_DATA.bytesPerLine],eax
							inc edi						
							; bytes to copy
							mov edx,[esi+edi*4]
							mov dword[ebx+sLINE_DATA.bytesToCopy],edx
							inc edi
							; offset
							mov eax,[esi+edi*4]
							mov dword[ebx+sLINE_DATA.offset],eax
							inc edi
							; len
							mov edx,[esi+edi*4]
							mov dword[ebx+sLINE_DATA.len],edx
							inc edi
							; line no
							mov dword[ebx+sLINE_DATA.line.lineNo],ecx
							; read extra
							.if ecx = 4							
								push ecx
									stdcall GetData,addr dataInfo,[address],14,2
									lea edx,[dataInfo]
									movzx edx,word[edx]
									mov [extra],edx
								pop ecx
															
							.endif
							
						.endif					
					
					inc [i]
					inc ecx
					add ebx,sizeof.sLINE_DATA					
					jmp .loop2
		.next:		
				inc [k]
				add [address],sizeof.FPO_DATA
				jmp .loop
	.out:			
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp

			proc ProcessingCoffSymbolHeaderLineData uses ebx esi edi,ptrTree
				
				locals
					strTbl	dd	0,4,0,15, 4,4,16,17, 8,4,33,19, 12,4,53,20, 16,4,74,20, 20,4,95,19, 24,4,115,20, 28,4,136,19
					numOfLines	dd	0
					i	dd	0
				endl
				
				mov ebx,[ptrTree]																
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				lea esi,[strTbl]								
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
					
					mov eax,[esi+0]		; bytesperline
					mov edx,[esi+4]		; bytestocopy
					mov ecx,[esi+8]		; offset
					mov edi,[esi+12]	; len
					mov dword[ebx+sLINE_DATA.bytesPerLine],eax
					mov dword[ebx+sLINE_DATA.bytesToCopy],edx
					mov dword[ebx+sLINE_DATA.offset],ecx
					mov dword[ebx+sLINE_DATA.len],edi					
				
				inc [i]
				add esi,4*4
				add ebx,sizeof.sLINE_DATA
				jmp .loop		
	.out:																
				
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingCoffLineNumbersLineData uses ebx esi edi,ptrTree
				
				locals
					address		dd	0
					numOfLines	dd	0
					ptrSymbolTable	dd	0
					ptrStringTable	dd	0
					i	dd	0
					k	dd	0
					dataInfo db 4 dup 0
				endl
				
				mov ecx,[ptrFilePeInfo]
				mov eax,[ecx+sFILE_PE_INFO.ptrToSymbolTable]
				mov edx,[ecx+sFILE_PE_INFO.ptrToStringTable]
				mov [ptrSymbolTable],eax
				mov [ptrStringTable],edx
				
				mov ebx,[ptrTree]
				mov eax,[ebx+sTREE_ITEM_TYPE.address.file]			
				mov [address],eax																
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				lea edi,[dataInfo]						
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
					
					; check if line number is zero or not
					stdcall GetData,edi,[address],4,2
					.if word[edi] = 0
						; it is a index to symbol table
						; get index
						stdcall GetData,edi,[address],0,4
						mov esi,[edi]
						; get symbol table address
						imul esi,18
						add esi,[ptrSymbolTable]
						; check name type , short or long
						stdcall GetData,edi,esi,0,4
						.if dword[edi] = 0
							; long name
							; read offset to the string table
							stdcall GetData,edi,esi,4,4				
							mov edx,[edi]
							add edx,[ptrStringTable]
							mov dword[ebx+sLINE_DATA.line.lineInfoB],edx					
							
						.else
							; short name	
							mov dword[ebx+sLINE_DATA.line.lineInfoB],esi
							
						.endif
						mov eax,[k]
						imul eax,6 
						mov edx,0
						add edx,eax
						mov dword[ebx+sLINE_DATA.bytesPerLine],edx
						mov dword[ebx+sLINE_DATA.bytesToCopy],4
						mov dword[ebx+sLINE_DATA.offset],0
						mov dword[ebx+sLINE_DATA.len],16
						mov dword[ebx+sLINE_DATA.line.lineNo],0
						mov dword[ebx+sLINE_DATA.line.lineInfoA],1	; true , symbol table entry
						add ebx,sizeof.sLINE_DATA
						mov edx,4
						add edx,eax
						mov dword[ebx+sLINE_DATA.bytesPerLine],edx
						mov dword[ebx+sLINE_DATA.bytesToCopy],2
						mov dword[ebx+sLINE_DATA.offset],0
						mov dword[ebx+sLINE_DATA.len],0
						mov dword[ebx+sLINE_DATA.line.lineNo],1
						mov dword[ebx+sLINE_DATA.line.lineInfoA],1	; true , symbol table entry
						add ebx,sizeof.sLINE_DATA
						
					.else
						; it is a virtual address
						mov eax,[k]
						imul eax,6 
						mov edx,0
						add edx,eax
						mov dword[ebx+sLINE_DATA.bytesPerLine],edx
						mov dword[ebx+sLINE_DATA.bytesToCopy],4
						mov dword[ebx+sLINE_DATA.offset],17
						mov dword[ebx+sLINE_DATA.len],14
						mov dword[ebx+sLINE_DATA.line.lineNo],0
						add ebx,sizeof.sLINE_DATA						
						mov edx,4
						add edx,eax
						mov dword[ebx+sLINE_DATA.bytesPerLine],edx
						mov dword[ebx+sLINE_DATA.bytesToCopy],2
						mov dword[ebx+sLINE_DATA.offset],32
						mov dword[ebx+sLINE_DATA.len],10
						mov dword[ebx+sLINE_DATA.line.lineNo],1
						add ebx,sizeof.sLINE_DATA						
						
					.endif
				
				inc [k]
				add [i],2
				add [address],6				
				jmp .loop
	.out:			
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp
			
			proc ProcessingCoffRelocations uses ebx esi edi,ptrTree
				
				locals					
					address		dd	0
					numOfLines	dd	0
					ptrSymbolTable	dd	0
					ptrStringTable	dd	0
					i	dd	0
					k	dd	0
					dataInfo db 4 dup 0
				endl
				
				mov ecx,[ptrFilePeInfo]
				mov eax,[ecx+sFILE_PE_INFO.ptrToSymbolTable]
				mov edx,[ecx+sFILE_PE_INFO.ptrToStringTable]
				mov [ptrSymbolTable],eax
				mov [ptrStringTable],edx
				
				mov ebx,[ptrTree]
				mov eax,[ebx+sTREE_ITEM_TYPE.address.file]			
				mov [address],eax																
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				push ebx
				mov ebx,eax
				lea edi,[dataInfo]			
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
										
					mov eax,[k]
					imul eax,10			; 10 bytes is size of 1 coff reloc record
					; virtual address
					mov edx,0
					add edx,eax
					mov dword[ebx+sLINE_DATA.bytesPerLine],edx
					mov dword[ebx+sLINE_DATA.bytesToCopy],4
					mov dword[ebx+sLINE_DATA.offset],0
					mov dword[ebx+sLINE_DATA.len],14
					mov dword[ebx+sLINE_DATA.line.lineNo],0
					inc [i]
					add ebx,sizeof.sLINE_DATA			
					; symbol to table index
					mov edx,4
					add edx,eax
					mov dword[ebx+sLINE_DATA.bytesPerLine],edx
					mov dword[ebx+sLINE_DATA.bytesToCopy],4
					push eax
						; get index
						stdcall GetData,edi,[address],4,4
						mov esi,[edi]
						; get symbol table address
						imul esi,18
						add esi,[ptrSymbolTable]
						; check name type , short or long
						stdcall GetData,edi,esi,0,4
						.if dword[edi] = 0
							; long name
							; read offset to the string table
							stdcall GetData,edi,esi,4,4				
							mov edx,[edi]
							add edx,[ptrStringTable]
							mov dword[ebx+sLINE_DATA.line.lineInfoA],edx					
							
						.else
							; short name	
							mov dword[ebx+sLINE_DATA.line.lineInfoA],esi
							
						.endif						
					pop eax
					mov dword[ebx+sLINE_DATA.offset],15
					mov dword[ebx+sLINE_DATA.len],16
					mov dword[ebx+sLINE_DATA.line.lineNo],1
					inc [i]
					add ebx,sizeof.sLINE_DATA
					
					; type
					mov edx,8
					add edx,eax
					mov dword[ebx+sLINE_DATA.bytesPerLine],edx
					mov dword[ebx+sLINE_DATA.bytesToCopy],2
					mov dword[ebx+sLINE_DATA.offset],32
					mov dword[ebx+sLINE_DATA.len],4
					mov dword[ebx+sLINE_DATA.line.lineNo],2
					; get type								
					stdcall GetData,edi,[address],8,2
					movzx edx,word[edi]
					stdcall GetTextForCoffRelocType,edx
					mov dword[ebx+sLINE_DATA.line.lineInfoA],edx	; offset
					mov dword[ebx+sLINE_DATA.line.lineInfoB],eax	; len
					inc [i]
					add ebx,sizeof.sLINE_DATA	
				
				inc [k]
				add [address],10				
				jmp .loop		
	.out:				
				pop ebx
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp						
			
			proc ProcessingCoffSymbolTableLineData uses ebx esi edi,ptrTree
				
				locals
					address		dd	0
					numOfLines	dd	0
					numOfSymbols	dd	0
					numOfAuxSymbols	dd	0
					ptrStringTable	dd	0
					i	dd	0
					k	dd	0
					retAddr	dd	0									
					dataInfo db 4 dup 0
				endl				
				
				mov ecx,[ptrFilePeInfo]
				mov edx,[ecx+sFILE_PE_INFO.ptrToStringTable]
				mov [ptrStringTable],edx
				mov ebx,[ptrTree]			
				mov eax,[ebx+sTREE_ITEM_TYPE.address.file]			
				mov [address],eax																
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx				
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				mov [retAddr],eax
				;push ebx
				mov ebx,eax
				lea edi,[dataInfo]
																				
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfLines]
				je .out
					
					; symbol table index line
					; just description and value
					mov dword[ebx+sLINE_DATA.offset],83
					mov dword[ebx+sLINE_DATA.len],16
					mov dword[ebx+sLINE_DATA.line.lineNo],0
					; save value
					mov edx,[numOfSymbols]
					mov dword[ebx+sLINE_DATA.line.lineInfoA],edx
					mov dword[ebx+sLINE_DATA.line.lineInfoB],0xabcd					
					add ebx,sizeof.sLINE_DATA
					inc [i]
					
					; is it short or long name			
					stdcall GetData,edi,[address],0,4
					.if dword[edi] = 0
						; long name
						; get offset				
						stdcall GetData,edi,[address],4,4	
						mov edx,[edi]
						add edx,[ptrStringTable]
						; save address
						; long name
						mov eax,[k]
						imul eax,18
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],4
						mov dword[ebx+sLINE_DATA.offset],10
						mov dword[ebx+sLINE_DATA.len],8
						mov dword[ebx+sLINE_DATA.line.lineNo],1
						mov dword[ebx+sLINE_DATA.line.lineInfoA],1
						mov dword[ebx+sLINE_DATA.line.lineInfoB],edx
						add ebx,sizeof.sLINE_DATA
						inc [i]
						
						; offset into string table
						mov eax,[k]
						imul eax,18
						add eax,4
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],4
						mov dword[ebx+sLINE_DATA.offset],19
						mov dword[ebx+sLINE_DATA.len],6
						mov dword[ebx+sLINE_DATA.line.lineNo],2
						mov dword[ebx+sLINE_DATA.line.lineInfoA],1
						mov dword[ebx+sLINE_DATA.line.lineInfoB],0xabcd	
						add ebx,sizeof.sLINE_DATA
						inc [i]						
						
					.else
						; short name
						mov eax,[k]
						imul eax,18
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],4
						mov dword[ebx+sLINE_DATA.offset],0
						mov dword[ebx+sLINE_DATA.len],9
						mov dword[ebx+sLINE_DATA.line.lineNo],1
						mov dword[ebx+sLINE_DATA.line.lineInfoA],1
						add ebx,sizeof.sLINE_DATA
						inc [i]
						
						; no description
						mov eax,[k]
						imul eax,18
						add eax,4
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],4
						mov dword[ebx+sLINE_DATA.offset],0
						mov dword[ebx+sLINE_DATA.len],0
						mov dword[ebx+sLINE_DATA.line.lineNo],2
						mov dword[ebx+sLINE_DATA.line.lineInfoA],1
						add ebx,sizeof.sLINE_DATA
						inc [i]						
					
					.endif
					
					; value	-------------------------------------------------------------------------------------------				
					mov eax,[k]
					imul eax,18
					add eax,8
					mov dword[ebx+sLINE_DATA.bytesPerLine],eax
					mov dword[ebx+sLINE_DATA.bytesToCopy],4
					mov dword[ebx+sLINE_DATA.offset],26
					mov dword[ebx+sLINE_DATA.len],5
					mov dword[ebx+sLINE_DATA.line.lineNo],3
					mov dword[ebx+sLINE_DATA.line.lineInfoA],1
					add ebx,sizeof.sLINE_DATA
					inc [i]
					
					; section number -----------------------------------------------------------------------------------
					; check for special meanings								
					stdcall GetData,edi,[address],12,2								
					.if word[edi] = 0xFEFF
					 	; IMAGE_SYM_SECTION_MAX
						mov dword[ebx+sLINE_DATA.line.lineInfoB],55		; offset
						mov dword[ebx+sLINE_DATA.line.lineInfoC],21		; len
					 	
					.elseif word[edi] = 0
						; IMAGE_SYM_UNDEFINED
						mov dword[ebx+sLINE_DATA.line.lineInfoB],0		; offset
						mov dword[ebx+sLINE_DATA.line.lineInfoC],19		; len
						
					.elseif word[edi] = 0xFFFF
						; IMAGE_SYM_ABSOLUTE
						mov dword[ebx+sLINE_DATA.line.lineInfoB],20		; offset
						mov dword[ebx+sLINE_DATA.line.lineInfoC],18		; len
						
					.elseif word[edi] = 0xFFFE
						; IMAGE_SYM_DEBUG
						mov dword[ebx+sLINE_DATA.line.lineInfoB],39		; offset
						mov dword[ebx+sLINE_DATA.line.lineInfoC],15		; len																	
						
					.else
						; one based index into sections
					 	movzx eax,word[edi]
					 	sub eax,1
					 	mov ecx,[ptrFilePeInfo]
					 	.if eax > [ecx+sFILE_PE_INFO.numOfSection]
					 		push eax
					 			add eax,1
					 			and eax,0xff
					 			mov dword[ebx+sLINE_DATA.line.lineInfoD],eax
					 		pop eax
					 		and eax,0xff
					 		
					 	.endif					 	
					 	imul eax,sizeof.sSEC_HEADER_INFO
					 	add eax,[ptrSecHeaderInfo]
					 	; save address of the section header					 	
					 	mov dword[ebx+sLINE_DATA.line.lineInfoB],eax
						
					.endif
					
					mov eax,[k]
					imul eax,18
					add eax,12
					mov dword[ebx+sLINE_DATA.bytesPerLine],eax
					mov dword[ebx+sLINE_DATA.bytesToCopy],2
					mov dword[ebx+sLINE_DATA.offset],32
					mov dword[ebx+sLINE_DATA.len],13
					mov dword[ebx+sLINE_DATA.line.lineNo],4
					mov dword[ebx+sLINE_DATA.line.lineInfoA],1
					add ebx,sizeof.sLINE_DATA
					inc [i]
					
					; type -------------------------------------------------------------------------------------------
					; check for function			
					stdcall GetData,edi,[address],14,2
					.if word[edi] = 0x20
						; DT_FUNCTION
						mov dword[ebx+sLINE_DATA.line.lineInfoB],171	; offset
						mov dword[ebx+sLINE_DATA.line.lineInfoC],14		; len
						
					.endif	
					mov eax,[k]
					imul eax,18
					add eax,14
					mov dword[ebx+sLINE_DATA.bytesPerLine],eax
					mov dword[ebx+sLINE_DATA.bytesToCopy],2
					mov dword[ebx+sLINE_DATA.offset],46
					mov dword[ebx+sLINE_DATA.len],4
					mov dword[ebx+sLINE_DATA.line.lineNo],5
					mov dword[ebx+sLINE_DATA.line.lineInfoA],1
					add ebx,sizeof.sLINE_DATA
					inc [i]
					
					; storage class -----------------------------------------------------------------------------------
					; check for storage			
					stdcall GetData,edi,[address],16,1
					.if byte[edi] = 0x2
						; IMAGE_SYM_CLASS_EXTERNAL
						mov dword[ebx+sLINE_DATA.line.lineInfoB],77		; offset
						mov dword[ebx+sLINE_DATA.line.lineInfoC],24		; len
						
					.elseif byte[edi] = 0x3
						; IMAGE_SYM_CLASS_STATIC
						mov dword[ebx+sLINE_DATA.line.lineInfoB],102	; offset
						mov dword[ebx+sLINE_DATA.line.lineInfoC],22		; len
						
					.elseif byte[edi] = 0x65
						; IMAGE_SYM_CLASS_FUNCTION
						mov dword[ebx+sLINE_DATA.line.lineInfoB],125	; offset
						mov dword[ebx+sLINE_DATA.line.lineInfoC],24		; len
						
					.elseif byte[edi] = 0x67
						; IMAGE_SYM_CLASS_FILE
						mov dword[ebx+sLINE_DATA.line.lineInfoB],150	; offset
						mov dword[ebx+sLINE_DATA.line.lineInfoC],20		; len
					
					.elseif byte[edi] = 0x69
						; IMAGE_SYM_CLASS_WEAK_EXTERNAL
						mov dword[ebx+sLINE_DATA.line.lineInfoB],186	; offset
						mov dword[ebx+sLINE_DATA.line.lineInfoC],29		; len
						
					.endif
					mov eax,[k]
					imul eax,18
					add eax,16
					mov dword[ebx+sLINE_DATA.bytesPerLine],eax
					mov dword[ebx+sLINE_DATA.bytesToCopy],1
					mov dword[ebx+sLINE_DATA.offset],51
					mov dword[ebx+sLINE_DATA.len],12
					mov dword[ebx+sLINE_DATA.line.lineNo],6
					mov dword[ebx+sLINE_DATA.line.lineInfoA],1
					add ebx,sizeof.sLINE_DATA
					inc [i]
					
					; num of aux symbols -----------------------------------------------------------------------------------
					mov eax,[k]
					imul eax,18
					add eax,17
					mov dword[ebx+sLINE_DATA.bytesPerLine],eax
					mov dword[ebx+sLINE_DATA.bytesToCopy],1
					mov dword[ebx+sLINE_DATA.offset],64
					mov dword[ebx+sLINE_DATA.len],18
					mov dword[ebx+sLINE_DATA.line.lineNo],7
					mov dword[ebx+sLINE_DATA.line.lineInfoA],1
					add ebx,sizeof.sLINE_DATA
					inc [i]
												
					; check for aux symbol records			
					stdcall GetData,edi,[address],17,1
					.if byte[edi] > 0
						; how many
						movzx edx,byte[edi]
						mov [numOfAuxSymbols],edx						
						; -= WHAT TYPE =-										
						stdcall GetData,edi,[address],16,1
						.if byte[edi] = IMAGE_SYM_CLASS_EXTERNAL
						; aux format 1 : function definitions
						; storage class is IMAGE_SYM_CLASS_EXTERNAL
						; type value indicates function 0x20
						; section number greater then zero						
							xor ecx,ecx
			.loop4:							
							cmp ecx,[numOfAuxSymbols]
							je .next
								
								inc [k]
								inc [numOfSymbols]
								add [address],18										
								; 0.symbol table index line									
								mov dword[ebx+sLINE_DATA.offset],83
								mov dword[ebx+sLINE_DATA.len],16
								mov dword[ebx+sLINE_DATA.line.lineNo],0									
								mov edx,[numOfSymbols]
								mov dword[ebx+sLINE_DATA.line.lineInfoA],edx
								mov dword[ebx+sLINE_DATA.line.lineInfoB],0xabcd						
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
								mov eax,[k]
								imul eax,18
								; 1.tag index
								mov edx,0
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								mov dword[ebx+sLINE_DATA.offset],0
								mov dword[ebx+sLINE_DATA.len],8
								mov dword[ebx+sLINE_DATA.line.lineNo],1
								mov dword[ebx+sLINE_DATA.line.lineInfoC],1
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
										
								; 2.total size
								mov edx,4
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								mov dword[ebx+sLINE_DATA.offset],9
								mov dword[ebx+sLINE_DATA.len],9
								mov dword[ebx+sLINE_DATA.line.lineNo],2
								mov dword[ebx+sLINE_DATA.line.lineInfoC],1
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
								; 3.pointer to line number
								mov edx,8
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								mov dword[ebx+sLINE_DATA.offset],19
								mov dword[ebx+sLINE_DATA.len],19
								mov dword[ebx+sLINE_DATA.line.lineNo],3
								mov dword[ebx+sLINE_DATA.line.lineInfoC],1
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
										
								; 4.pointer to next function
								mov edx,12
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								mov dword[ebx+sLINE_DATA.offset],39
								mov dword[ebx+sLINE_DATA.len],21
								mov dword[ebx+sLINE_DATA.line.lineNo],4
								mov dword[ebx+sLINE_DATA.line.lineInfoC],1
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
								; 5.unused
								mov edx,16
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],2
								mov dword[ebx+sLINE_DATA.offset],61
								mov dword[ebx+sLINE_DATA.len],6
								mov dword[ebx+sLINE_DATA.line.lineNo],5
								mov dword[ebx+sLINE_DATA.line.lineInfoC],1
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
							inc ecx
							jmp .loop4									
						
						.elseif byte[edi] = IMAGE_SYM_CLASS_FUNCTION
							; aux format 2 : .bf and .ef symbols
							; storage class = IMAGE_SYM_CLASS_FUNCTION
							; name of symbol record is .bf ( begin function ) or .ef ( end of function )
							; get name
							stdcall GetData,edi,[address],0,4													
							xor ecx,ecx
							xor esi,esi
							mov esi,[edi]
				.loop5:				
							cmp ecx,[numOfAuxSymbols]
							je .next
								
								inc [k]
								inc [numOfSymbols]
								add [address],18										
								; 0.symbol table index line									
								mov dword[ebx+sLINE_DATA.offset],83
								mov dword[ebx+sLINE_DATA.len],16
								mov dword[ebx+sLINE_DATA.line.lineNo],0									
								mov edx,[numOfSymbols]
								mov dword[ebx+sLINE_DATA.line.lineInfoA],edx
								mov dword[ebx+sLINE_DATA.line.lineInfoB],0xabcd						
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
								mov eax,[k]
								imul eax,18
								; 1.unused
								mov edx,0
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								mov dword[ebx+sLINE_DATA.offset],61
								mov dword[ebx+sLINE_DATA.len],6
								mov dword[ebx+sLINE_DATA.line.lineNo],1
								mov dword[ebx+sLINE_DATA.line.lineInfoC],2
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
									
								; 2.line number
								mov edx,4
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],2
								mov dword[ebx+sLINE_DATA.offset],68
								mov dword[ebx+sLINE_DATA.len],10
								mov dword[ebx+sLINE_DATA.line.lineNo],2
								mov dword[ebx+sLINE_DATA.line.lineInfoC],2
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
								; 3.unused
								mov edx,6
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								mov dword[ebx+sLINE_DATA.offset],61
								mov dword[ebx+sLINE_DATA.len],6
								mov dword[ebx+sLINE_DATA.line.lineNo],3
								mov dword[ebx+sLINE_DATA.line.lineInfoC],2
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]									
								
								; 4. for .bf pointer to next function
								;    for .ef unused
								mov edx,12
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								.if esi = '.bf'
									mov dword[ebx+sLINE_DATA.offset],39
									mov dword[ebx+sLINE_DATA.len],21
									
								.elseif esi = '.ef'
									mov dword[ebx+sLINE_DATA.offset],61
									mov dword[ebx+sLINE_DATA.len],6
									
								.endif
								mov dword[ebx+sLINE_DATA.line.lineNo],4
								mov dword[ebx+sLINE_DATA.line.lineInfoC],2
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
								; 5.unused
								mov edx,16
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],2
								mov dword[ebx+sLINE_DATA.offset],61
								mov dword[ebx+sLINE_DATA.len],6
								mov dword[ebx+sLINE_DATA.line.lineNo],5
								mov dword[ebx+sLINE_DATA.line.lineInfoC],2
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
							inc ecx
							jmp .loop5
							
						.elseif byte[edi] = IMAGE_SYM_CLASS_WEAK_EXTERNAL
							; aux format 3 : weak externals
							; storage class = IMAGE_SYM_CLASS_WEAK_EXTERNAL
							; value = 0
							; section number = IMAGE_SYM_UNDEFINED														
							xor ecx,ecx
				.loop6:				
							cmp ecx,[numOfAuxSymbols]
							je .next
								
								inc [k]
								inc [numOfSymbols]
								add [address],18										
								; 0.symbol table index line									
								mov dword[ebx+sLINE_DATA.offset],83
								mov dword[ebx+sLINE_DATA.len],16
								mov dword[ebx+sLINE_DATA.line.lineNo],0									
								mov edx,[numOfSymbols]
								mov dword[ebx+sLINE_DATA.line.lineInfoA],edx
								mov dword[ebx+sLINE_DATA.line.lineInfoB],0xabcd						
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
								mov eax,[k]
								imul eax,18
								; 1.tag index
								mov edx,0
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								mov dword[ebx+sLINE_DATA.offset],0
								mov dword[ebx+sLINE_DATA.len],8
								mov dword[ebx+sLINE_DATA.line.lineNo],1
								mov dword[ebx+sLINE_DATA.line.lineInfoC],3
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
										
								; 2.characteristics
								mov edx,4
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								mov dword[ebx+sLINE_DATA.offset],79
								mov dword[ebx+sLINE_DATA.len],15
								mov dword[ebx+sLINE_DATA.line.lineNo],2
								mov dword[ebx+sLINE_DATA.line.lineInfoC],3
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
								; 3.unused
								mov edx,8
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								mov dword[ebx+sLINE_DATA.offset],61
								mov dword[ebx+sLINE_DATA.len],6
								mov dword[ebx+sLINE_DATA.line.lineNo],3
								mov dword[ebx+sLINE_DATA.line.lineInfoC],3
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
										
							inc ecx
							jmp .loop6			
							
						.elseif byte[edi] = IMAGE_SYM_CLASS_FILE
							; aux format 4 : files
							; storage class = IMAGE_SYM_CLASS_FILE
							; name of the symbol table = .file							
							xor ecx,ecx
				.loop2:				
							cmp ecx,[numOfAuxSymbols]
							je .next
								
								inc [k]
								inc [numOfSymbols]
								add [address],18										
								; symbol table index line									
								mov dword[ebx+sLINE_DATA.offset],83
								mov dword[ebx+sLINE_DATA.len],16
								mov dword[ebx+sLINE_DATA.line.lineNo],0									
								mov edx,[numOfSymbols]
								mov dword[ebx+sLINE_DATA.line.lineInfoA],edx
								mov dword[ebx+sLINE_DATA.line.lineInfoB],0xabcd						
								add ebx,sizeof.sLINE_DATA
								inc [i]
																	
								; file line
								mov eax,[k]
								imul eax,18
								mov dword[ebx+sLINE_DATA.bytesPerLine],eax
								mov dword[ebx+sLINE_DATA.bytesToCopy],0
								mov dword[ebx+sLINE_DATA.offset],100
								mov dword[ebx+sLINE_DATA.len],8
								mov dword[ebx+sLINE_DATA.line.lineNo],1
								mov dword[ebx+sLINE_DATA.line.lineInfoC],4	
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1								
								add ebx,sizeof.sLINE_DATA
								inc [i]
															
							inc ecx
							jmp .loop2
							
						.elseif byte[edi] = IMAGE_SYM_CLASS_STATIC
							; aux format 5 : section definition
							; symbol record name is the name of a section
							; so if the section number is 1 or greater we have section name ( one based index )
							; storage class = IMAGE_SYM_CLASS_STATIC							
							xor ecx,ecx
				.loop3:			
							cmp ecx,[numOfAuxSymbols]
							je .next
								
								inc [k]
								inc [numOfSymbols]
								add [address],18										
								; 0.symbol table index line									
								mov dword[ebx+sLINE_DATA.offset],83
								mov dword[ebx+sLINE_DATA.len],16
								mov dword[ebx+sLINE_DATA.line.lineNo],0									
								mov edx,[numOfSymbols]
								mov dword[ebx+sLINE_DATA.line.lineInfoA],edx
								mov dword[ebx+sLINE_DATA.line.lineInfoB],0xabcd						
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
								mov eax,[k]
								imul eax,18
								; 1.length
								mov edx,0
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								mov dword[ebx+sLINE_DATA.offset],95
								mov dword[ebx+sLINE_DATA.len],6
								mov dword[ebx+sLINE_DATA.line.lineNo],1
								mov dword[ebx+sLINE_DATA.line.lineInfoC],5	
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
									
								; 2.number of relocations
								mov edx,4
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],2
								mov dword[ebx+sLINE_DATA.offset],102
								mov dword[ebx+sLINE_DATA.len],19
								mov dword[ebx+sLINE_DATA.line.lineNo],2	
								mov dword[ebx+sLINE_DATA.line.lineInfoC],5
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
								; 3.number of line numbers
								mov edx,6
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],2
								mov dword[ebx+sLINE_DATA.offset],122
								mov dword[ebx+sLINE_DATA.len],19
								mov dword[ebx+sLINE_DATA.line.lineNo],3	
								mov dword[ebx+sLINE_DATA.line.lineInfoC],5
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
									
								; 4.checksum
								mov edx,8
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],4
								mov dword[ebx+sLINE_DATA.offset],142
								mov dword[ebx+sLINE_DATA.len],8
								mov dword[ebx+sLINE_DATA.line.lineNo],4	
								mov dword[ebx+sLINE_DATA.line.lineInfoC],5
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
								; 5.number
								mov edx,12
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],2
								mov dword[ebx+sLINE_DATA.offset],151
								mov dword[ebx+sLINE_DATA.len],6
								mov dword[ebx+sLINE_DATA.line.lineNo],5	
								mov dword[ebx+sLINE_DATA.line.lineInfoC],5
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
									
								; 6.selection
								mov edx,14
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],1
								mov dword[ebx+sLINE_DATA.offset],158
								mov dword[ebx+sLINE_DATA.len],9
								mov dword[ebx+sLINE_DATA.line.lineNo],6	
								mov dword[ebx+sLINE_DATA.line.lineInfoC],5
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
								; 7.unused
								mov edx,15
								add edx,eax
								mov dword[ebx+sLINE_DATA.bytesPerLine],edx
								mov dword[ebx+sLINE_DATA.bytesToCopy],3
								mov dword[ebx+sLINE_DATA.offset],61
								mov dword[ebx+sLINE_DATA.len],6
								mov dword[ebx+sLINE_DATA.line.lineNo],7	
								mov dword[ebx+sLINE_DATA.line.lineInfoC],5
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
								add ebx,sizeof.sLINE_DATA
								inc [i]
								
							inc ecx	
							jmp .loop3
						
						.endif																		
						
					.endif		; aux format check
		.next:	
								
				inc [k]
				inc [numOfSymbols]
				add [address],18		
				jmp .loop
	.out:
															
				;pop ebx
				;mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				mov eax,[retAddr]				
				ret
			endp
			
			proc ProcessingResourceDirectoryTableLineData uses ebx esi edi,ptrTree,level
				
				locals					
					numOfLines	dd	0
					k	dd	0					
				endl				
								
				mov ebx,[ptrTree]																			
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
								
				stdcall GetResourceDirecTable,[ptrResource],[level],eax,addr k								
				
				mov eax,[ebx+sTREE_ITEM_TYPE.ptrLineData]
				ret
			endp	
			
			proc ProcessingResourceDataEntryLineData uses ebx esi edi,ptrTree
				;						datarva		size	codepage	reserved	
				locals
					resStrTbl	dd	0,4,141,7,  4,4,149,4,  8,4,154,8,  12,4,163,8
					numOfLines	dd	0
					numOfDataEntries	dd	0
					imgBase	dd	0
					fileAddr	dd	0
					rvaAddr		dd	0
					vaAddr		dd	0
					ptrText		dd	0
					i	dd	0
					j	dd	0
					temp du 32 dup 0
				endl
				
				mov ecx,[ptrFilePeInfo]
				mov ecx,[ecx+sFILE_PE_INFO.imageBase]
				mov [imgBase],ecx
				mov ebx,[ptrTree]		
				mov eax,[ebx+sTREE_ITEM_TYPE.numOfLines]
				shr eax,2
				mov [numOfDataEntries],eax																				
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],edx								
				imul edx,sizeof.sLINE_DATA
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
				mov dword[ebx+sTREE_ITEM_TYPE.ptrLineData],eax
				mov ebx,eax
				push ebx
				lea edi,[resStrTbl]
						
	.loop:				
				mov ecx,[i]
				cmp ecx,[numOfDataEntries]
				je .out
					
					stdcall GetResourceDataEntry,[ptrResource],[i]	
					; esi is a ptr to resource entry
					mov esi,eax
					mov eax,[esi+sRESOURCE_ENTRY.data.addressFile]
					mov edx,[esi+sRESOURCE_ENTRY.data.addressRva]					
					mov [fileAddr],eax
					mov [rvaAddr],edx
					add edx,[imgBase]
					mov [vaAddr],edx
					lea ecx,[esi+sRESOURCE_ENTRY.text]
					mov [ptrText],ecx															
					; set lines
					mov [j],0
					xor ecx,ecx
	.loop2:				
					mov ecx,[j]
					cmp ecx,4	; dataRva	size	codepage	reserved
					je .next
						; line no
						mov dword[ebx+sLINE_DATA.line.lineNo],ecx
						shl ecx,4																	
						mov eax,[edi+0+ecx]		; bytesperline
						mov edx,[edi+4+ecx]		; bytestocopy
						mov dword[ebx+sLINE_DATA.bytesPerLine],eax
						mov dword[ebx+sLINE_DATA.bytesToCopy],edx
						mov eax,[edi+8+ecx]		; offset
						mov edx,[edi+12+ecx]	; len
						mov dword[ebx+sLINE_DATA.offset],eax
						mov dword[ebx+sLINE_DATA.len],edx
						mov eax,[fileAddr]
						mov edx,[rvaAddr]
						mov ecx,[vaAddr]
						mov dword[ebx+sLINE_DATA.line.lineInfoA],eax	; file
						mov dword[ebx+sLINE_DATA.line.lineInfoB],edx	; rva
						mov dword[ebx+sLINE_DATA.line.lineInfoC],ecx	; va
						.if dword[ebx+sLINE_DATA.line.lineNo] = 0
							mov eax,[ptrText]
							mov dword[ebx+sLINE_DATA.line.lineInfoD],eax
							
						.endif					 						
						
					inc [j]
					add ebx,sizeof.sLINE_DATA
					jmp .loop2					
					
	.next:							
				inc [i]
				jmp .loop
	.out:		
							
				pop ebx
				mov eax,ebx
				ret
			endp
			
			proc GetResourceDataEntry uses ebx esi edi,ptrResDir,index
				
				locals
					numOfEntries	dd	0
					i	dd	0
				endl
				
				mov esi,[ptrResDir]
				mov ebx,[index]
				
				.if dword[esi+sRESOURCE_DIRECTORY.numOfEntries] <> 0
					mov edx,[esi+sRESOURCE_DIRECTORY.numOfEntries]
					mov [numOfEntries],edx
					mov edi,[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries]
	.loop:				
					mov ecx,[i]
					cmp ecx,[numOfEntries]
					je .out
						
						; do we have data entry
						.if dword[edi+sRESOURCE_ENTRY.data.addressFile] <> 0 
							; data entry
							; index is 1 based count
							mov edx,dword[edi+sRESOURCE_ENTRY.data.index]
							sub edx,1																		
							.if edx = ebx 
								; needed index
								mov eax,edi
								jmp .out
							
							.else
								jmp .next
								
							.endif							
							
						.endif
		.next:				
						; do we have subdirectory
						.if dword[edi+sRESOURCE_ENTRY.ptrSubDirectory] <> 0
							; check 
							stdcall GetResourceDataEntry,dword[edi+sRESOURCE_ENTRY.ptrSubDirectory],[index]
						
						.endif
								
					inc [i]
					add edi,sizeof.sRESOURCE_ENTRY
					jmp .loop
	.out:			
							
				.endif
				
				ret
			endp					
			
			proc GetResourceDirecTable uses ebx esi edi,ptrResDirec,level,ptrLineData,k
				
				locals
					resDir			dd	0,4, 0,15, 4,4,16,13, 8,2,30,12, 10,2,43,12, 12,2,56,19, 14,2,76,17
					;					namerva		id			datarva		subdirecrva
					resEntries		dd	0,4,94,7,  0,4,102,9, 4,4,112,12,  4,4,125,15
					numOfEntries	dd	0
					numOfEntries2	dd	0
					index	dd	0
					i	dd	0
					imgBase	dd	0
					fileAddr	dd	0
					rvaAddr		dd	0
					vaAddr		dd	0
				endl
				
				mov ecx,[ptrFilePeInfo]
				mov ecx,[ecx+sFILE_PE_INFO.imageBase]
				mov [imgBase],ecx
				
				mov eax,[k]
				mov eax,[eax]
				mov [index],eax
				
				mov edx,[level]
				mov ebx,[ptrLineData]
				mov esi,[ptrResDirec]				
				; if the first directory table is wanted level
				; then it is level 0 , count and exit
				.if dword[esi+sRESOURCE_DIRECTORY.level] = edx
					; found it
					; save file , rva and va
					mov eax,[esi+sRESOURCE_DIRECTORY.addressFile]	
					mov [fileAddr],eax
					mov edx,[esi+sRESOURCE_DIRECTORY.addressRva]
					mov [rvaAddr],edx
					add edx,[imgBase]
					mov [vaAddr],edx
					; 6 lines per entry
					push edi
						lea edi,[resDir]
		.loop1:			
						mov ecx,[i]	
						cmp ecx,6
						je .out1
							mov ecx,[index]
							mov eax,[edi+0]		; bytes per line
							add eax,ecx
							mov edx,[edi+4]		; bytes to copy							
							mov dword[ebx+sLINE_DATA.bytesPerLine],eax
							mov dword[ebx+sLINE_DATA.bytesToCopy],edx
							mov eax,[edi+8]		; offset
							mov edx,[edi+12]	; len
							mov dword[ebx+sLINE_DATA.offset],eax
							mov dword[ebx+sLINE_DATA.len],edx
							mov eax,[fileAddr]
							mov edx,[rvaAddr]
							mov ecx,[vaAddr]
							mov dword[ebx+sLINE_DATA.line.lineNo],1			; resource directory table
							mov dword[ebx+sLINE_DATA.line.lineInfoA],eax	; file	
							mov dword[ebx+sLINE_DATA.line.lineInfoB],edx	; rva
							mov dword[ebx+sLINE_DATA.line.lineInfoC],ecx	; va
							.if [i] = 1
								; timedatestamp mark
								mov dword[ebx+sLINE_DATA.line.lineInfoD],1
							
							.endif
						inc [i]
						add edi,4*4
						add ebx,sizeof.sLINE_DATA
						jmp .loop1
		.out1:						
					pop edi
					add [index],sizeof.IMAGE_RESOURCE_DIRECTORY
										
					; is there a directory entry
					.if dword[esi+sRESOURCE_DIRECTORY.numOfEntries] <> 0
						; 2 lines per entry
						mov [i],0
						push edi
						push esi							
							mov ecx,[esi+sRESOURCE_DIRECTORY.numOfEntries]
							shl ecx,1
							mov [numOfEntries2],ecx
							mov edi,[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries]
							lea esi,[resEntries]
			.loop2:				
							mov ecx,[i]
							cmp ecx,[numOfEntries2]
							je .out2
												
								; copy address of the name for this entry
								lea ecx,[edi+sRESOURCE_ENTRY.text]
								mov dword[ebx+sLINE_DATA.line.lineNo],2		; resource directory entry
								mov dword[ebx+sLINE_DATA.line.lineInfoD],ecx
								mov eax,[fileAddr]
								mov edx,[rvaAddr]
								mov ecx,[vaAddr]
								mov dword[ebx+sLINE_DATA.line.lineInfoA],eax	; file	
								mov dword[ebx+sLINE_DATA.line.lineInfoB],edx	; rva
								mov dword[ebx+sLINE_DATA.line.lineInfoC],ecx	; va
																
								.if dword[edi+sRESOURCE_ENTRY.name.addressRva] <> 0
									; name rva
									mov ecx,[index]
									mov eax,[esi+0]		; bytes per line
									add eax,ecx
									mov edx,[esi+4]		; bytes to copy
									mov dword[ebx+sLINE_DATA.bytesPerLine],eax
									mov dword[ebx+sLINE_DATA.bytesToCopy],edx
									mov eax,[esi+8]		; offset
									mov edx,[esi+12]	; len
									mov dword[ebx+sLINE_DATA.offset],eax
									mov dword[ebx+sLINE_DATA.len],edx
									
								.else	
									; integer id , can be zero so no <> 0
									mov ecx,[index]
									mov eax,[esi+0+4*4]		; bytes per line
									add eax,ecx
									mov edx,[esi+4+4*4]		; bytes to copy
									mov dword[ebx+sLINE_DATA.bytesPerLine],eax
									mov dword[ebx+sLINE_DATA.bytesToCopy],edx
									mov eax,[esi+8+4*4]		; offset
									mov edx,[esi+12+4*4]	; len
									mov dword[ebx+sLINE_DATA.offset],eax
									mov dword[ebx+sLINE_DATA.len],edx
									
								.endif								
								inc [i]
								add ebx,sizeof.sLINE_DATA								
																
								.if dword[edi+sRESOURCE_ENTRY.data.addressRva] <> 0
									; data entry rva
									mov ecx,[index]
									mov eax,[esi+0+4*4*2]		; bytes per line
									add eax,ecx
									mov edx,[esi+4+4*4*2]		; bytes to copy
									mov dword[ebx+sLINE_DATA.bytesPerLine],eax
									mov dword[ebx+sLINE_DATA.bytesToCopy],edx
									mov eax,[esi+8+4*4*2]		; offset
									mov edx,[esi+12+4*4*2]	; len
									mov dword[ebx+sLINE_DATA.offset],eax
									mov dword[ebx+sLINE_DATA.len],edx
									
								.elseif dword[edi+sRESOURCE_ENTRY.subDirectoryRva] <> 0
									; subdirectory rva
									mov ecx,[index]
									mov eax,[esi+0+4*4*3]		; bytes per line
									add eax,ecx
									mov edx,[esi+4+4*4*3]		; bytes to copy
									mov dword[ebx+sLINE_DATA.bytesPerLine],eax
									mov dword[ebx+sLINE_DATA.bytesToCopy],edx
									mov eax,[esi+8+4*4*3]		; offset
									mov edx,[esi+12+4*4*3]	; len
									mov dword[ebx+sLINE_DATA.offset],eax
									mov dword[ebx+sLINE_DATA.len],edx
									
								.endif
								mov dword[ebx+sLINE_DATA.line.lineNo],3		; resource directory entry , no name line
								mov eax,[fileAddr]
								mov edx,[rvaAddr]
								mov ecx,[vaAddr]
								mov dword[ebx+sLINE_DATA.line.lineInfoA],eax	; file	
								mov dword[ebx+sLINE_DATA.line.lineInfoB],edx	; rva
								mov dword[ebx+sLINE_DATA.line.lineInfoC],ecx	; va
																
								inc [i]
								add ebx,sizeof.sLINE_DATA
								
							add [index],4*2
							add edi,sizeof.sRESOURCE_ENTRY							
							jmp .loop2		
			.out2:		
						pop esi		
						pop edi																		
					
					mov ecx,[k]
					mov eax,[index]
					mov [ecx],eax
					
					mov eax,ebx					
					.endif
				
				; is there a data entries	
				.elseif dword[esi+sRESOURCE_DIRECTORY.numOfEntries] <> 0
					mov eax,[esi+sRESOURCE_DIRECTORY.numOfEntries]
					mov [numOfEntries],eax
					mov edi,[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries]
					; for every data entry check if points to subdirectory
					; and if that subdirectory is wanted level
		.loop:			
					mov ecx,[i]
					cmp ecx,[numOfEntries]
					je .out
						
						.if dword[edi+sRESOURCE_ENTRY.ptrSubDirectory] <> 0
							;mov esi,[edi+sRESOURCE_ENTRY.ptrSubDirectory]	
							mov ecx,[k]
							mov dword[ecx],0																								
							stdcall GetResourceDirecTable,dword[edi+sRESOURCE_ENTRY.ptrSubDirectory],[level],ebx,[k]
							mov ebx,eax
						.endif
					
					inc [i]
					add edi,sizeof.sRESOURCE_ENTRY
					jmp .loop				
		.out:									
				.endif
				
				ret
			endp
			
			proc GetTextForCoffRelocType uses ebx esi edi,typeData								
				locals
					typeID	dd	0x0,0x1,0x2,0x6,0x7,0x9,0xa,0xb,0xc,0xd,0x14
					offset	dd	37, 61, 82, 103, 124, 147, 168, 191, 213, 234, 257
					len		dd	23, 20,	20,	 20,  22,  20,	22,	 21,  20,  22,	20
				endl
				
				lea ebx,[typeID]
				lea esi,[offset]
				lea edi,[len]
				
				mov edx,[typeData]
				xor ecx,ecx
	.loop:			
				cmp ecx,11
				je .out
					
					.if edx = [ebx+ecx*4]
						mov edx,[esi+ecx*4]		; offset
						mov eax,[edi+ecx*4]		; len
						jmp .out
						
					.endif
						
				inc ecx
				jmp .loop
	.out:		
							
				ret
			endp
			
			proc GetTextForResourceID uses ebx esi edi,idData
				
				locals
					idType	dd	1,2,3,4,5,6,7,8,9,10,11,12,14,16,17,19,20,21,22,23,24
					offset	dd	0,7,14,19,24,31,38,46,51,63,70,83,96,107,115,126,135,139,149,157,162,171
					len		dd	6,6, 4, 4, 6, 6, 7, 4,11, 6,12,12,10,  7, 10,  8,  3,  9,  7,  4,  8, 12 
				endl
				
				lea ebx,[idType]
				lea esi,[offset]
				lea edi,[len]
				
				mov edx,[idData]						
				xor ecx,ecx
	.loop:			
				cmp ecx,21
				je .out_err
					
					.if edx = [ebx+ecx*4] 
						mov edx,[esi+ecx*4]		; offset in edx
						mov eax,[edi+ecx*4]		; len in eax
						jmp .out
						
					.endif
				
				inc ecx
				jmp .loop
	.out_err:
				; user defined
				mov edx,[esi+ecx*4]
				mov eax,[edi+ecx*4]							
	.out:			
				ret
			endp
			

			
			
			
			
			
			
			
			
			
			
			























































			
;;			