format MS COFF
include 'win32wxp.inc'

include 'extrndef.inc'
include 'kernel32.inc'
include 'user32.inc'
include 'comdlg32.inc'

include 'petype.inc'
include 'filetype.inc'
include 'treeandsorttype.inc'
include 'pe.inc'

MB_PRECOMPOSED	= 0x00000001

public numOfSortItemAlloc
public numOfTVItemAlloc
public ShowOpenFileDlg as '_ShowOpenFileDlg@16'
public SetNewWindowName as '_SetNewWindowName@12'
public OpenFilePE as '_OpenFilePE@0'
public CloseFilePE as '_CloseFilePE@0'

extrn 'basePtr' as basePtr:dword
extrn 'lineData' as lineData:dword
extrn 'hWinMain' as hWinMain:dword
extrn 'hTreeWindow' as hTreeWindow:dword
extrn 'hHeapObject' as hHeapObject:dword
extrn 'hIniFile' as hIniFile:dword
extrn 'ptrFileBaseInfo' as ptrFileBaseInfo:dword
extrn 'ptrFilePeInfo' as ptrFilePeInfo:dword
extrn 'ptrSecHeaderInfo' as ptrSecHeaderInfo:dword
extrn 'ptrDataDirecInfo' as ptrDataDirecInfo:dword
extrn 'ptrSortItem' as ptrSortItem:dword
extrn 'ptrTreeViewItem' as ptrTreeViewItem:dword
extrn 'ptrImportAddress' as ptrImportAddress:dword
extrn 'ptrImportNames' as ptrImportNames:dword
extrn 'ptrExportDirec' as ptrExportDirec:dword
extrn 'ptrDelayAddress' as ptrDelayAddress:dword
extrn 'ptrDelayName' as ptrDelayName:dword
extrn 'ptrResource' as ptrResource:dword

extrn 'ptrStrTbl1' as ptrStrTbl1:dword
extrn 'ptrStrTbl2' as ptrStrTbl2:dword
extrn 'ptrStrTbl3' as ptrStrTbl3:dword
extrn 'ptrStrTbl4' as ptrStrTbl4:dword

extrn '_FormatMessageBox@4' as FormatMessageBox:dword
extrn '_CloseTreeWindow@0' as CloseTreeWindow:dword
extrn '_CloseViewWindow@0' as CloseViewWindow:dword
extrn '_ProcessingTreeViewElements@4' as ProcessingTreeViewElements:dword

section '.code' code readable executable
			
			proc GetCountOfDllAttrib uses ebx,characteristic
				
				locals
					dllAttrib dd IMAGE_DLLCHARACTERISTICS_DYNAMIC_BASE,IMAGE_DLLCHARACTERISTICS_FORCE_INTEGRITY,IMAGE_DLLCHARACTERISTICS_NX_COMPAT,\
								 IMAGE_DLLCHARACTERISTICS_NO_ISOLATION,IMAGE_DLLCHARACTERISTICS_NO_SEH,IMAGE_DLLCHARACTERISTICS_NO_BIND,\
								 IMAGE_DLLCHARACTERISTICS_WDM_DRIVER,IMAGE_DLLCHARACTERISTICS_TERMINAL_SERVER_AWARE
				endl
				
				xor eax,eax
				xor ecx,ecx
				lea ebx,[dllAttrib]
	.loop:			
				cmp ecx,8
				je .out
				mov edx,[ebx]
				test [characteristic],edx
				jz .next
				inc eax	
	.next:		
				inc ecx	
				add ebx,4
				jmp .loop
				
	.out:			
				
				ret
			endp
			
			proc GetCountOfFileAttrib uses ebx,characteristic
				
				locals 
					fileAttrib	dd	IMAGE_FILE_RELOCS_STRIPPED,IMAGE_FILE_EXECUTABLE_IMAGE,IMAGE_FILE_LINE_NUMS_STRIPPED,IMAGE_FILE_LOCAL_SYMS_STRIPPED,\
									IMAGE_FILE_AGGRESIVE_WS_TRIM,IMAGE_FILE_LARGE_ADDRESS_AWARE,IMAGE_FILE_BYTES_REVERSED_LO,IMAGE_FILE_32BIT_MACHINE,\
									IMAGE_FILE_DEBUG_STRIPPED,IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP,IMAGE_FILE_NET_RUN_FROM_SWAP,IMAGE_FILE_SYSTEM,IMAGE_FILE_DLL,\
									IMAGE_FILE_UP_SYSTEM_ONLY,IMAGE_FILE_BYTES_REVERSED_HI
				endl
				
				xor eax,eax
				xor ecx,ecx
				lea ebx,[fileAttrib]
	.loop:			
				cmp ecx,15
				je .out				
				mov edx,[ebx]
				test [characteristic],edx
				jz .next
				inc eax
	.next:		
				inc ecx
				add ebx,4					
				jmp .loop
	.out:						
				ret
			endp
			
			proc GetCountOfSecHeaderAttrib uses ebx,characteristics
								
				locals
					shAttrib	dd	IMAGE_SCN_TYPE_NO_PAD,IMAGE_SCN_CNT_CODE,IMAGE_SCN_CNT_INITIALIZED_DATA,IMAGE_SCN_CNT_UNINITIALIZED_DATA,IMAGE_SCN_LNK_OTHER,\	
									IMAGE_SCN_LNK_INFO,IMAGE_SCN_LNK_REMOVE,IMAGE_SCN_LNK_COMDAT,IMAGE_SCN_NO_DEFER_SPEC_EXC,IMAGE_SCN_GPREL,IMAGE_SCN_MEM_FARDATA,\
									IMAGE_SCN_MEM_PURGEABLE,IMAGE_SCN_MEM_16BIT,IMAGE_SCN_MEM_PRELOAD,IMAGE_SCN_LNK_NRELOC_OVFL,IMAGE_SCN_MEM_DISCARDABLE,\
									IMAGE_SCN_MEM_NOT_CACHED,IMAGE_SCN_MEM_NOT_PAGED,IMAGE_SCN_MEM_SHARED,IMAGE_SCN_MEM_EXECUTE,IMAGE_SCN_MEM_READ,IMAGE_SCN_MEM_WRITE
					
					secAlignAttrib	dd	IMAGE_SCN_ALIGN_1BYTES,IMAGE_SCN_ALIGN_2BYTES,IMAGE_SCN_ALIGN_4BYTES,IMAGE_SCN_ALIGN_8BYTES,IMAGE_SCN_ALIGN_16BYTES,\
										IMAGE_SCN_ALIGN_32BYTES,IMAGE_SCN_ALIGN_64BYTES,IMAGE_SCN_ALIGN_128BYTES,IMAGE_SCN_ALIGN_256BYTES,IMAGE_SCN_ALIGN_512BYTES,\
										IMAGE_SCN_ALIGN_1024BYTES,IMAGE_SCN_ALIGN_2048BYTES,IMAGE_SCN_ALIGN_4096BYTES,IMAGE_SCN_ALIGN_8192BYTES
				endl
				
				xor eax,eax
				xor ecx,ecx
				lea ebx,[shAttrib]
	.loop:			
				cmp ecx,22
				je .out				
				mov edx,[ebx]
				test [characteristics],edx
				jz .next
				inc eax
	.next:		
				inc ecx
				add ebx,4					
				jmp .loop
	.out:						
				;
				;
				xor ecx,ecx
				mov edx,[characteristics]
				and edx,0x00F00000
				lea ebx,[secAlignAttrib]				
	.loop2:		
				cmp ecx,14
				je .out2					
				cmp edx,[ebx]
				jne .next2
				inc eax
				jmp .out2
	.next2:		
				inc ecx
				add ebx,4
				jmp .loop2			
	.out2:			
				
				ret
			endp
						
			proc GetDataDirecInfos uses ebx esi edi,ptrDataDirec
				
				mov ebx,[ptrDataDirecInfo]
				mov esi,[ptrDataDirec]
				
				xor ecx,ecx
				; start loop
	.loop:			
				cmp ecx,15
				je .out
				mov eax,[esi+sDATA_DIRECTORY_INFO.virtualAddress]
				mov edx,[esi+sDATA_DIRECTORY_INFO.size]
				mov dword[ebx+sDATA_DIRECTORY_INFO.virtualAddress],eax
				mov dword[ebx+sDATA_DIRECTORY_INFO.size],edx
				add esi,sizeof.sDATA_DIRECTORY_INFO
				add ebx,sizeof.sDATA_DIRECTORY_INFO
				
				; Export Directory
				.if ecx = 0
					.if eax <> 0 & edx <> 0
						add [numOfTVItemAlloc],4
						
					.endif
				
				; Import Directory
				.elseif ecx = 1
					.if eax <> 0 & edx <> 0
						add [numOfTVItemAlloc],3
						
					.endif
				
				; Resource Directory
				.elseif ecx = 2
					.if eax <> 0 & edx <> 0
						add [numOfTVItemAlloc],1		; resource directory root
						
					.endif
				
				; Certificate Table
				.elseif ecx = 4
					.if eax <> 0 & edx <> 0
						add [numOfTVItemAlloc],1
						
					.endif
				
				; Base Relocation Directory
				.elseif ecx = 5
					.if eax <> 0 & edx <> 0
						add [numOfTVItemAlloc],1
						
					.endif
				
				; Debug Directory
				.elseif ecx = 6
					.if eax <> 0 & edx <> 0									
						; calc num of debug type
						mov edi,sizeof.IMAGE_DEBUG_DIRECTORY
						mov eax,edx
						xor edx,edx						
						div edi
						add [numOfTVItemAlloc],eax
						; 1 for the IMAGE_DEBUG_DIRECTORY entry
						add [numOfTVItemAlloc],1
						
					.endif
				
				; Tls Directory
				.elseif ecx = 9
					.if eax <> 0 & edx <> 0
						add [numOfTVItemAlloc],1
						
					.endif
				
				; Load Configuration Directory
				.elseif ecx = 10
					.if eax <> 0 & edx <> 0
						add [numOfTVItemAlloc],1
						
					.endif
				
				; Bound Import Directory
				.elseif ecx = 11
					.if eax <> 0 & edx <> 0
						add [numOfTVItemAlloc],2
						
					.endif
				
				; Delay-Load Directory
				.elseif ecx = 13		
					.if eax <> 0 & edx <> 0
						add [numOfTVItemAlloc],3
						
					.endif
					
				.endif
																																
				inc ecx
				jmp .loop
				
	.out:
				xor eax,eax			
				ret
			endp

			proc GetSectionsHeadersInfos uses ebx esi edi,pSectionHeader,numOfSection
				
				mov ebx,[pSectionHeader]
				mov edi,[ptrSecHeaderInfo]
				; esi is a counter
				xor esi,esi
	.loop:			
				cmp esi,[numOfSection]
				je .out
						
				lea eax,[ebx+IMAGE_SECTION_HEADER._Name]
				lea edx,[edi+sSEC_HEADER_INFO.headerName]
				invoke MultiByteToWideChar,CP_ACP,MB_PRECOMPOSED,eax,8,edx,10
				
				mov edx,[ebx+IMAGE_SECTION_HEADER.VirtualSize]
				mov dword[edi+sSEC_HEADER_INFO.virtualSize],edx
				
				mov eax,[ebx+IMAGE_SECTION_HEADER.VirtualAddress]
				mov dword[edi+sSEC_HEADER_INFO.virtualAddress],eax
				
				mov ecx,[ebx+IMAGE_SECTION_HEADER.SizeOfRawData]
				mov dword[edi+sSEC_HEADER_INFO.sizeOfRawData],ecx
				
				mov edx,[ebx+IMAGE_SECTION_HEADER.PointerToRawData]
				mov dword[edi+sSEC_HEADER_INFO.pointerToRawData],edx
				
				mov eax,[ebx+IMAGE_SECTION_HEADER.PointerToRelocations]
				mov dword[edi+sSEC_HEADER_INFO.pointerToRelocations],eax
				
				mov ecx,[ebx+IMAGE_SECTION_HEADER.PointerToLinenumbers]
				mov dword[edi+sSEC_HEADER_INFO.pointerToLinenumbers],ecx
				
				movzx edx,[ebx+IMAGE_SECTION_HEADER.NumberOfRelocations]
				mov dword[edi+sSEC_HEADER_INFO.numberOfRelocations],edx
				
				movzx eax,[ebx+IMAGE_SECTION_HEADER.NumberOfLinenumbers]
				mov dword[edi+sSEC_HEADER_INFO.numberOfLinenumbers],eax
				
				mov ecx,[ebx+IMAGE_SECTION_HEADER.Characteristics]
				mov dword[edi+sSEC_HEADER_INFO.characteristics],ecx
				
				stdcall GetCountOfSecHeaderAttrib,ecx
				mov dword[edi+sSEC_HEADER_INFO.numOfFlags],eax
				
				; check for coff line numbers
				.if dword[ebx+IMAGE_SECTION_HEADER.PointerToLinenumbers] <> 0 & word[ebx+IMAGE_SECTION_HEADER.NumberOfLinenumbers] <> 0
					push esi
					mov esi,[ptrFilePeInfo]
					mov eax,[ebx+IMAGE_SECTION_HEADER.PointerToLinenumbers]
					movzx edx,[ebx+IMAGE_SECTION_HEADER.NumberOfLinenumbers]
					mov dword[esi+sFILE_PE_INFO.ptrToLineNumbers],eax
					mov dword[esi+sFILE_PE_INFO.numOfLineNum],edx
					add [numOfTVItemAlloc],1
					pop esi	
					
				.endif
				; check for coff relocations
				.if dword[ebx+IMAGE_SECTION_HEADER.PointerToRelocations] <> 0 & word[ebx+IMAGE_SECTION_HEADER.NumberOfRelocations] <> 0
					add [numOfTVItemAlloc],1
					
				.endif
					
				add ebx,sizeof.IMAGE_SECTION_HEADER
				add edi,sizeof.sSEC_HEADER_INFO
				inc esi
				jmp .loop
				
	.out:			
				xor eax,eax
				ret
			endp
			
			proc IsFileObj32 uses ebx esi edi,ptrFile
				
				mov esi,[ptrFilePeInfo]
				mov ebx,[ptrFile]
				.if word[ebx+IMAGE_FILE_HEADER.Machine] = IMAGE_FILE_MACHINE_I386
					.if dword[ebx+IMAGE_FILE_HEADER.PointerToSymbolTable] <> 0
						.if dword[ebx+IMAGE_FILE_HEADER.NumberOfSymbols] <> 0
							.if word[ebx+IMAGE_FILE_HEADER.SizeOfOptionalHeader] = 0
								; get number of section
								movzx edx,word[ebx+IMAGE_FILE_HEADER.NumberOfSections]
								mov eax,edx
								mov dword[esi+sFILE_PE_INFO.numOfSection],edx
								; sections headers + sections raw
								shl edx,1
								; inc tree item numbers
								add [numOfTVItemAlloc],edx
								; ALLOC MEM for section header info
								imul eax,sizeof.sSEC_HEADER_INFO
								invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,eax
								mov [ptrSecHeaderInfo],eax
								; copy symbol info
								mov edx,[ebx+IMAGE_FILE_HEADER.PointerToSymbolTable]
								mov eax,[ebx+IMAGE_FILE_HEADER.NumberOfSymbols]
								mov dword[esi+sFILE_PE_INFO.ptrToSymbolTable],edx
								mov dword[esi+sFILE_PE_INFO.numOfSymbols],eax
								; get start of string table
								imul eax,18	; 18 bytes is size of one symbol table
								add edx,eax
								mov dword[esi+sFILE_PE_INFO.ptrToStringTable],edx
								; +symbol table +string table
								add [numOfTVItemAlloc],2
								movzx eax,[ebx+IMAGE_FILE_HEADER.Characteristics]
								mov dword[esi+sFILE_PE_INFO.fileChrAttr],eax
								stdcall GetCountOfFileAttrib,eax
								mov dword[esi+sFILE_PE_INFO.numOfFlagsFileAttr],eax
								; parse section headers				
								add ebx,sizeof.IMAGE_FILE_HEADER
								stdcall GetSectionsHeadersInfos,ebx,dword[esi+sFILE_PE_INFO.numOfSection]
								mov eax,1
								ret
								
							.endif
						
						.endif
					
					.endif
					
				.endif
				
				xor eax,eax
				ret
			endp
			
			proc IsFileObj64 ptrFile
				
				xor eax,eax
				ret
			endp
			
			proc IsFilePE32 uses ebx esi edi,ptrFile
				
				mov ebx,[ptrFilePeInfo]
				mov edi,[ptrFileBaseInfo]
				mov esi,[ptrFile]
							
				.if word[esi+IMAGE_DOS_HEADER.e_magic] = IMAGE_DOS_SIGNATURE
					mov edx,[esi+IMAGE_DOS_HEADER.e_lfanew]
					; if addr > file size , error , no pe type
					.if edx > dword[edi+sFILE_BASE_INFO.fileSize]
						jmp .error1
						
					.endif
					mov dword[ebx+sFILE_PE_INFO.offsetToNT],edx
					
					; check for the stub
					; if offset to nt header is less then 0x3c ( last entry of IDH ) 
					; there is no stub
					.if edx > 0x3c
						; calc the size of the stub
						sub edx,0x40					
						mov dword[ebx+sFILE_PE_INFO.stubSize],edx
						mov dword[ebx+sFILE_PE_INFO.bStubFlag],1											
					
					.endif
					
					; check for nt signature
					add esi,[esi+IMAGE_DOS_HEADER.e_lfanew]
					.if dword[esi+IMAGE_NT_HEADERS32.Signature] = IMAGE_NT_SIGNATURE				
						; is pe 32bit		
						.if word[esi+IMAGE_NT_HEADERS32.FileHeader.Machine] = IMAGE_FILE_MACHINE_I386
							; is exe32
							test word[esi+IMAGE_NT_HEADERS32.FileHeader.Characteristics],IMAGE_FILE_EXECUTABLE_IMAGE
							.if ~ZERO?								
								mov dword[edi+sFILE_BASE_INFO.fileType],FILE_IS_EXE32
								
							.else
							; is dll32
								mov dword[edi+sFILE_BASE_INFO.fileType],FILE_IS_DLL32
																								
							.endif
							
							; get number of sections
							movzx edx,[esi+IMAGE_NT_HEADERS32.FileHeader.NumberOfSections]
							mov dword[ebx+sFILE_PE_INFO.numOfSection],edx							
							; num of sec header + num of sec raw data
							mov eax,edx
							shl eax,1
							mov [numOfTVItemAlloc],eax							
							; ALLOC MEM for sections headers infos
							imul edx,sizeof.sSEC_HEADER_INFO
							invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
							mov [ptrSecHeaderInfo],eax
							
							; get image base
							mov edx,[esi+IMAGE_NT_HEADERS32.OptionalHeader.ImageBase]
							mov dword[ebx+sFILE_PE_INFO.imageBase],edx
							
							; get coff symbol table file offset
							.if dword[esi+IMAGE_NT_HEADERS32.FileHeader.PointerToSymbolTable] <> 0 & dword[esi+IMAGE_NT_HEADERS32.FileHeader.NumberOfSymbols] <> 0
								mov eax,[esi+IMAGE_NT_HEADERS32.FileHeader.PointerToSymbolTable]
								mov dword[ebx+sFILE_PE_INFO.ptrToSymbolTable],eax
								mov edx,[esi+IMAGE_NT_HEADERS32.FileHeader.NumberOfSymbols]
								mov dword[ebx+sFILE_PE_INFO.numOfSymbols],edx							
								; +symbol header +symbol table
								add [numOfTVItemAlloc],2
								; get start of coff string table
								; NumberOfSymbols * 18 ( size of 1 symbol record )
								imul edx,18			
								add eax,edx
								mov dword[ebx+sFILE_PE_INFO.ptrToStringTable],eax
								; + string table
								add [numOfTVItemAlloc],1
															
							.endif
							
							; get the number of file attributes
							movzx edx,word[esi+IMAGE_NT_HEADERS32.FileHeader.Characteristics]
							mov dword[ebx+sFILE_PE_INFO.fileChrAttr],edx
							.if edx <> 0
								stdcall GetCountOfFileAttrib,edx
								mov dword[ebx+sFILE_PE_INFO.numOfFlagsFileAttr],eax
							
							.endif														
							
							; get the number of dll attributes
							movzx edx,word[esi+IMAGE_NT_HEADERS32.OptionalHeader.DllCharacteristics]
							mov dword[ebx+sFILE_PE_INFO.fileDllAttr],edx				
							.if edx <> 0
								stdcall GetCountOfDllAttrib,edx
								mov dword[ebx+sFILE_PE_INFO.numOfFlagsDllAttr],eax
							.endif
							
							; ALLOC MEM for data directory info
							invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,2*4*15														
							mov [ptrDataDirecInfo],eax
							; get data directory infos							
							lea edx,[esi+IMAGE_NT_HEADERS32.OptionalHeader.DataDirectory]
							stdcall GetDataDirecInfos,edx	
							
							; parse sections headers
							; go to the start of sections 
							add esi,sizeof.IMAGE_NT_HEADERS32
							stdcall GetSectionsHeadersInfos,esi,dword[ebx+sFILE_PE_INFO.numOfSection]
							
							mov eax,1	
							ret
														
						.endif ; check for 32bit pe
						
					.endif ; check for nt sig
															
				.endif
	.error1:			
				xor eax,eax
				ret			
			endp
			
			proc IsFilePE64 ptrFile
				
				xor eax,eax
				ret
			endp
			
			proc OpenFilePE uses ebx esi edi
				
				local sysInfo:SYSTEM_INFO
				local bytesToMap:DWORD
				local ptrFile:DWORD
							
				mov ebx,[ptrFileBaseInfo]
				lea edx,[ebx+sFILE_BASE_INFO.fileName]
				invoke CreateFileW,edx,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_FLAG_SEQUENTIAL_SCAN,0
				.if eax = INVALID_HANDLE_VALUE
					stdcall FormatMessageBox,0					
					jmp .error
					
				.endif								
				mov [ebx+sFILE_BASE_INFO.hFile],eax
				
				invoke GetFileSize,eax,0
				.if eax = 0
					stdcall FormatMessageBox,0
					jmp .error
					
				.endif								
				mov [ebx+sFILE_BASE_INFO.fileSize],eax
							
				invoke GetSystemInfo,addr sysInfo
				
				mov eax,[sysInfo.dwAllocationGranularity]
				mov [ebx+sFILE_BASE_INFO.allocGran],eax				
				mov edx,[ebx+sFILE_BASE_INFO.fileSize]
				
				.if eax > edx
					mov [bytesToMap],edx
					
				.else
					mov [bytesToMap],eax					
				
				.endif
								
				invoke CreateFileMappingW,dword[ebx+sFILE_BASE_INFO.hFile],0,PAGE_READONLY,0,dword[ebx+sFILE_BASE_INFO.fileSize],0
				.if eax = 0
					stdcall FormatMessageBox,0
					jmp .error
					
				.endif				
				mov [ebx+sFILE_BASE_INFO.hFileMap],eax
							
				invoke MapViewOfFile,eax,FILE_MAP_READ,0,0,[bytesToMap]
				.if eax = 0
					stdcall FormatMessageBox,0
					jmp .error
					
				.endif				
				mov [ptrFile],eax
				
				mov edi,[ptrFilePeInfo]			
										
				stdcall IsFileObj32,[ptrFile]
				.if eax <> 0
					mov dword[ebx+sFILE_BASE_INFO.fileType],FILE_IS_OBJ32
					; +2 standard tree items , root + file header
					add [numOfTVItemAlloc],2
					mov edx,[numOfTVItemAlloc]
					mov esi,edx
					mov [numOfSortItemAlloc],esi
					; ALLOC MEM for sort and tree arrays
					imul edx,sizeof.sTREE_ITEM_TYPE
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
					mov [ptrTreeViewItem],eax
					imul esi,sizeof.sSORT_ITEM_TYPE
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,esi
					mov [ptrSortItem],eax
					; ALLOC MEM for viewwindow				
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,1024*2
					mov [ptrStrTbl1],eax
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,576*2
					mov [ptrStrTbl2],eax
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,256*2
					mov [ptrStrTbl3],eax
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,128*2
					mov [ptrStrTbl4],eax
					
					jmp .out
					
				.endif
					
				stdcall IsFileObj64,[ptrFile]
				.if eax <> 0					
					jmp .out
				
				.endif
				
				stdcall IsFilePE32,[ptrFile]
				.if eax <> 0											
					or dword[ebx+sFILE_BASE_INFO.fileType],FILE_IS_PE32
					; + 7 standard items ( root + imagedosheader + msdosstub + ntheaders(4)
					; check for stub
					.if dword[edi+sFILE_PE_INFO.bStubFlag] <> 0
						add [numOfTVItemAlloc],1
						
					.endif
								
					add [numOfTVItemAlloc],6
					mov edx,[numOfTVItemAlloc]
					mov [numOfSortItemAlloc],edx
									
					mov esi,edx				
					; edx for sSORT_ITEM_TYPE
					imul edx,sizeof.sSORT_ITEM_TYPE
					; esi for sTREE_ITEM_TYPE
					imul esi,sizeof.sTREE_ITEM_TYPE
					
					; ALLOC MEM
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
					mov [ptrSortItem],eax
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,esi
					mov [ptrTreeViewItem],eax
											
					; ALLOC MEM for viewwindow				
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,1024*2
					mov [ptrStrTbl1],eax
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,576*2
					mov [ptrStrTbl2],eax
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,256*2
					mov [ptrStrTbl3],eax
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,128*2
					mov [ptrStrTbl4],eax
					jmp .out
					
				.endif
							
				stdcall IsFilePE64,[ptrFile]
				.if eax <> 0
					jmp .out
				
				.endif				
				
				; file is unknown type
				mov dword[ebx+sFILE_BASE_INFO.fileType],FILE_IS_UNKNOWN
				; just root			
				mov [numOfTVItemAlloc],1
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,sizeof.sTREE_ITEM_TYPE											
				mov [ptrTreeViewItem],eax	
	.out:		
				invoke UnmapViewOfFile,[ptrFile]
				
				; start processing											
				stdcall ProcessingTreeViewElements,dword[ebx+sFILE_BASE_INFO.fileType]
								
				mov eax,1				
				ret
				
	.error:		
				xor eax,eax
				ret				
			endp
			
			proc CloseFilePE uses ebx esi edi																								
										
				.if [basePtr] <> 0
					invoke UnmapViewOfFile,[basePtr]
					mov [basePtr],0
					
				.endif
				
				mov ebx,[ptrFileBaseInfo]
				.if dword[ebx+sFILE_BASE_INFO.hFileMap] <> 0
					invoke CloseHandle,dword[ebx+sFILE_BASE_INFO.hFileMap]
					mov dword[ebx+sFILE_BASE_INFO.hFileMap],0
					
				.endif
				
				.if dword[ebx+sFILE_BASE_INFO.hFile] <> 0
					invoke CloseHandle,dword[ebx+sFILE_BASE_INFO.hFile]
					mov dword[ebx+sFILE_BASE_INFO.hFile],0
					
				.endif
				
				; clear mem
				lea esi,[ebx+sFILE_BASE_INFO.fileName]
				lea edi,[ebx+sFILE_BASE_INFO.fileTitle]
				invoke RtlZeroMemory,esi,MAX_PATH*2
				invoke RtlZeroMemory,edi,MAX_PATH*2
				invoke RtlZeroMemory,[ptrFileBaseInfo],sizeof.sFILE_BASE_INFO
				invoke RtlZeroMemory,[ptrFilePeInfo],sizeof.sFILE_PE_INFO
							
				; free mem
				.if [ptrSecHeaderInfo] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrSecHeaderInfo]
					mov [ptrSecHeaderInfo],0
					
				.endif
				.if [ptrDataDirecInfo] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrDataDirecInfo]
					mov [ptrDataDirecInfo],0
					
				.endif
				.if [ptrSortItem] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrSortItem]
					mov [ptrSortItem],0
					
				.endif
				.if [ptrTreeViewItem] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrTreeViewItem]
					mov [ptrTreeViewItem],0
					
				.endif	
				.if [ptrImportAddress] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrImportAddress]
					mov [ptrImportAddress],0
					
				.endif
				.if [ptrImportNames] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrImportNames]
					mov [ptrImportNames],0
					
				.endif
				.if [ptrExportDirec] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrExportDirec]
					mov [ptrExportDirec],0
					
				.endif
				.if [ptrDelayAddress] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrDelayAddress]
					mov [ptrDelayAddress],0
					
				.endif
				.if [ptrDelayName] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrDelayName]
					mov [ptrDelayName],0
					
				.endif
				.if [ptrResource] <> 0																		
					stdcall FreeResourceMemory,[ptrResource]															
					invoke HeapFree,[hHeapObject],0,[ptrResource]					
					mov [ptrResource],0
					
				.endif
				.if [lineData] <> 0
					invoke HeapFree,[hHeapObject],0,[lineData]
					mov [lineData],0
				
				.endif									
				
				; clear data
				mov [numOfSortItemAlloc],0
				mov [numOfTVItemAlloc],0
				
				stdcall CloseTreeWindow
				stdcall CloseViewWindow
				
				ret
			endp
			
			proc FreeResourceMemory uses ebx esi edi,ptrRes
				
				locals
					numOfEntries	dd	0
					i	dd	0
				endl
				
				mov esi,[ptrRes]
				.if dword[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries] <> 0
					mov edi,[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries]
					mov eax,[esi+sRESOURCE_DIRECTORY.numOfEntries]
					mov [numOfEntries],eax
	.loop:				
					mov ecx,[i]
					cmp ecx,[numOfEntries]
					je .out
						
						.if dword[edi+sRESOURCE_ENTRY.ptrSubDirectory] <> 0						
							; there is a sbudirectory
							; check for down level
							stdcall FreeResourceMemory,dword[edi+sRESOURCE_ENTRY.ptrSubDirectory]
							invoke HeapFree,[hHeapObject],0,dword[edi+sRESOURCE_ENTRY.ptrSubDirectory]							
							mov dword[edi+sRESOURCE_ENTRY.ptrSubDirectory],0																																																																				
																																																						
						.endif
													
					inc [i]
					add edi,sizeof.sRESOURCE_ENTRY
					jmp .loop
	.out:																																
					invoke HeapFree,[hHeapObject],0,dword[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries]					
					mov dword[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries],0
												
				.endif
				
				ret
			endp

			proc ShowOpenFileDlg uses ebx esi edi,hWnd,name,title,fIndex
								
				local ofn:OPENFILENAME				
												
				lea ebx,[ofn]
				invoke RtlZeroMemory,ebx,sizeof.OPENFILENAME
				; clear name and title buffers just in case
				invoke RtlZeroMemory,[name],260*2
				invoke RtlZeroMemory,[title],260*2
				
				; eax is handle to an instance
				invoke GetModuleHandleW,0
								
				mov dword[ebx+OPENFILENAME.lStructSize],sizeof.OPENFILENAME
				mov edx,[hWnd]
				mov dword[ebx+OPENFILENAME.hwndOwner],edx
				mov dword[ebx+OPENFILENAME.hInstance],eax
				mov ecx,[fIndex]
				mov edx,[name]
				mov eax,[title]				
				mov dword[ebx+OPENFILENAME.lpstrFilter],filter
				mov dword[ebx+OPENFILENAME.nFilterIndex],ecx
				mov dword[ebx+OPENFILENAME.lpstrFile],edx
				mov dword[ebx+OPENFILENAME.nMaxFile],260*2
				mov dword[ebx+OPENFILENAME.lpstrFileTitle],eax
				mov dword[ebx+OPENFILENAME.nMaxFileTitle],260*2
				mov dword[ebx+OPENFILENAME.Flags],OFN_EXPLORER or OFN_FILEMUSTEXIST
				
				invoke GetOpenFileNameW,ebx				
				; ret to edx filter index after dlg is closed
				mov edx,[ebx+OPENFILENAME.nFilterIndex]
												
				ret
			endp
			
			proc SetNewWindowName uses ebx esi edi,hWnd,name,winName
				
				locals
					tmpl	du '%ls - [%ls]',0
					buffer	du	260 dup 0
				endl
				
				lea esi,[tmpl]
				lea ebx,[buffer]
				invoke RtlZeroMemory,ebx,260*2
				
				cinvoke wsprintfW,ebx,esi,[winName],[name]			
				
				invoke SetWindowTextW,[hWnd],ebx
				
				ret
			endp
			
section '.data' data readable writeable
			filter du 'Executable (*.exe)',0,'*.exe',0,'Dynamic Link Library (*.dll)',0,'*.dll',0,'Object (*.obj)',0,'*.obj',0,'All Files (*.*)',0,'*.*',0,0
			align 4
			numOfSortItemAlloc	dd	0
			numOfTVItemAlloc	dd	0
			
;			
;			