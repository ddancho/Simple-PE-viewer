format MS COFF
include 'win32wxp.inc'

include 'extrndef.inc'
include 'kernel32.inc'
include 'user32.inc'
include 'resource.inc'

include 'pe.inc'
include 'petype.inc'

include 'filetype.inc'
include 'treeandsorttype.inc'

public ptrImportNames
public ptrImportAddress
public ptrExportDirec
public ptrDelayAddress
public ptrDelayName
public ptrDebugDirec
public ptrResource
public ProcessingPeHeaders as '_ProcessingPeHeaders@0'
public ProcessingMSCoffHeaders as '_ProcessingMSCoffHeaders@0'
public ProcessingSections as '_ProcessingSections@4'
public ProcessingDataDirectories as '_ProcessingDataDirectories@4'
public ProcessingMSCoffData as '_ProcessingMSCoffData@4'
public GetSectionForTableRva as '_GetSectionForTableRva@12'

extrn 'basePtr' as basePtr:dword
extrn 'numOfTVItemAlloc' as numOfTVItemAlloc:dword
extrn 'numOfSortItemAlloc' as numOfSortItemAlloc:dword
extrn 'hHeapObject' as hHeapObject:dword
extrn 'ptrFilePeInfo' as ptrFilePeInfo:dword
extrn 'ptrSecHeaderInfo' as ptrSecHeaderInfo:dword
extrn 'ptrDataDirecInfo' as ptrDataDirecInfo:dword
extrn 'ptrTreeViewItem' as ptrTreeViewItem:dword
extrn 'ptrSortItem' as ptrSortItem:dword

extrn '_GetData@16' as GetData:dword
extrn '_InsertionSort@12' as InsertionSort:dword
extrn '_GetTextForResourceID@4' as GetTextForResourceID:dword
extrn '_CopyStringWtoW@12' as CopyStringWtoW:dword
extrn '_ConvertHexWordToStringU@8' as ConvertHexWordToStringU:dword
extrn '_GetResourceDataEntry@8' as GetResourceDataEntry:dword

section '.code' code readable executable
			
			proc ProcessingMSCoffHeaders uses ebx esi
				
				; eax is a counter
				; ecx is for loop
				xor eax,eax
				xor ecx,ecx
				mov ebx,[ptrSortItem]
				mov esi,[ptrFilePeInfo]
				
				; IMAGE FILE HEADER
				mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_IMAGE_FILE_HEADER or TREE_ITEM_DATA_INFO
				mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
				add eax,1
				add ebx,sizeof.sSORT_ITEM_TYPE
				
				; IMAGE SECTION HEADER
				mov edx,sizeof.IMAGE_FILE_HEADER
	.loop:			
				cmp ecx,[esi+sFILE_PE_INFO.numOfSection]
				je .out
					
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_IMAGE_SECTION_HEADER or TREE_ITEM_DATA_INFO
					mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],edx
					mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx
					mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
				
				inc ecx
				add eax,1
				add ebx,sizeof.sSORT_ITEM_TYPE
				add edx,sizeof.IMAGE_SECTION_HEADER
				jmp .loop
	.out:			
				
				ret
			endp
			
			proc ProcessingMSCoffData uses ebx esi edi,index
				
				; eax is a counter
				xor eax,eax
				mov edi,[ptrSecHeaderInfo]
				mov esi,[ptrFilePeInfo]
				mov ebx,[ptrSortItem]
				add ebx,[index]
				
				; symbol table & string table
				.if dword[esi+sFILE_PE_INFO.ptrToSymbolTable] <> 0 & dword[esi+sFILE_PE_INFO.numOfSymbols] <> 0
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_COFF_SYMBOL_TABLE or TREE_ITEM_DATA_INFO
					mov edx,[esi+sFILE_PE_INFO.ptrToSymbolTable]
					mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],edx
					mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1					
					add eax,1
					add ebx,sizeof.sSORT_ITEM_TYPE					
					
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_COFF_STRING_TABLE or TREE_ITEM_DATA_RAW
					mov edx,[esi+sFILE_PE_INFO.ptrToStringTable]
					; skip size of the string table entry
					add edx,4
					mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],edx
					mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
					add eax,1
					add ebx,sizeof.sSORT_ITEM_TYPE					
				
				.endif
				
				; line number
				.if dword[esi+sFILE_PE_INFO.ptrToLineNumbers] <> 0 & dword[esi+sFILE_PE_INFO.numOfLineNum]
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_COFF_LINE_NUMBERS or TREE_ITEM_DATA_INFO
					mov edx,[esi+sFILE_PE_INFO.ptrToLineNumbers]
					mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],edx
					mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
					add eax,1
					add ebx,sizeof.sSORT_ITEM_TYPE
				
				.endif
				
				;coff relocations
				xor ecx,ecx
	.loop:			
				cmp ecx,[esi+sFILE_PE_INFO.numOfSection]
				je .out
					
					.if dword[edi+sSEC_HEADER_INFO.pointerToRelocations] <> 0 & dword[edi+sSEC_HEADER_INFO.numberOfRelocations] <> 0
						push ecx
							mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_COFF_RELOCATIONS or TREE_ITEM_DATA_INFO
							mov edx,[edi+sSEC_HEADER_INFO.pointerToRelocations]
							mov ecx,[edi+sSEC_HEADER_INFO.numberOfRelocations]
							mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
							mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],edx
							mov dword[ebx+sSORT_ITEM_TYPE.fileSize],ecx
							mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
							add eax,1
							add ebx,sizeof.sSORT_ITEM_TYPE
						pop ecx
						
					.endif					
						
				inc ecx
				add edi,sizeof.sSEC_HEADER_INFO
				jmp .loop
	.out:		
							
				ret
			endp
			
			proc ProcessingPeHeaders uses ebx esi
				
				; eax is a counter for num of sort elements
				; ecx is for loop
				xor eax,eax
				xor ecx,ecx				
				mov esi,[ptrFilePeInfo]
				mov ebx,[ptrSortItem]
								
				; IMAGE_DOS_HEADER
				mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_IMAGE_DOS_HEADER or TREE_ITEM_DATA_INFO
				mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
				add ebx,sizeof.sSORT_ITEM_TYPE
				add eax,1
				
				; MS-DOS STUB
				.if dword[esi+sFILE_PE_INFO.bStubFlag] = 1
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_MSDOS_STUB or TREE_ITEM_DATA_RAW
					mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],sizeof.IMAGE_DOS_HEADER
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],sizeof.IMAGE_DOS_HEADER
					mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
					add ebx,sizeof.sSORT_ITEM_TYPE
					add eax,1	
				
				.endif
				
				; IMAGE_NT_HEADERS
				mov edx,[esi+sFILE_PE_INFO.offsetToNT]
				mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_IMAGE_NT_HEADERS or TREE_ITEM_DATA_RAW
				mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
				mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],edx
				mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
				add ebx,sizeof.sSORT_ITEM_TYPE
				add eax,1
				
				; SIGNATURE
				mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_SIGNATURE or TREE_ITEM_DATA_INFO
				mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
				mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],edx
				mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],TREE_ITEM_IMAGE_NT_HEADERS or TREE_ITEM_DATA_RAW
				add ebx,sizeof.sSORT_ITEM_TYPE
				add eax,1
				
				; IMAGE_FILE_HEADER
				; + sizeof Signature
				add edx,4
				mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_IMAGE_FILE_HEADER or TREE_ITEM_DATA_INFO
				mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
				mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],edx
				mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],TREE_ITEM_IMAGE_NT_HEADERS or TREE_ITEM_DATA_RAW
				add ebx,sizeof.sSORT_ITEM_TYPE
				add eax,1
				
				; IMAGE_OPTIONAL_HEADER
				add edx,sizeof.IMAGE_FILE_HEADER
				mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_IMAGE_OPTIONAL_HEADER or TREE_ITEM_DATA_INFO
				mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
				mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],edx
				mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],TREE_ITEM_IMAGE_NT_HEADERS or TREE_ITEM_DATA_RAW
				add ebx,sizeof.sSORT_ITEM_TYPE
				add eax,1
				
				; SECTION HEADERS
				add edx,sizeof.IMAGE_OPTIONAL_HEADER32
	.loop:			
				cmp ecx,[esi+sFILE_PE_INFO.numOfSection]
				je .out
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_IMAGE_SECTION_HEADER or TREE_ITEM_DATA_INFO
					mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],edx
					mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx					
					mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
					add ebx,sizeof.sSORT_ITEM_TYPE					
					add eax,1
					add edx,sizeof.IMAGE_SECTION_HEADER
					inc ecx					
				
				jmp .loop
				
	.out:				
				ret
			endp
			
			proc ProcessingSections uses ebx esi edi,index								
				
				local flag:DWORD
				; eax is a counter for num of sort elements
				; ecx is for loop
				xor eax,eax
				xor ecx,ecx	
				mov edi,[ptrSecHeaderInfo]
				mov esi,[ptrFilePeInfo]
				mov ebx,[ptrSortItem]
				add ebx,[index]
	.loop:			
				cmp ecx,[esi+sFILE_PE_INFO.numOfSection]
				je .out					
						mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_SECTION_RAW or TREE_ITEM_DATA_RAW
						mov edx,[edi+sSEC_HEADER_INFO.virtualAddress]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
						mov edx,[edi+sSEC_HEADER_INFO.virtualSize]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],edx	
						
						mov edx,[edi+sSEC_HEADER_INFO.pointerToRawData]
						mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],edx
						
						; check section characteristics
						push edx			
							mov edx,[edi+sSEC_HEADER_INFO.characteristics]
							and edx,0x000000F0
							.if edx = IMAGE_SCN_CNT_UNINITIALIZED_DATA
								mov [flag],1
							
							.else
								mov [flag],0
								
							.endif
						pop edx
						
						.if [flag] = 1
							mov dword[ebx+sSORT_ITEM_TYPE.fileSize],0
							
						.elseif [flag] = 0
							mov edx,[edi+sSEC_HEADER_INFO.sizeOfRawData]
							mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
							
						.endif
						
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx						
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						
						add ebx,sizeof.sSORT_ITEM_TYPE
						add eax,1																		
										
					add edi,sizeof.sSEC_HEADER_INFO
					inc ecx
					
				jmp .loop	
	.out:						
				ret
			endp						
											
			; args - debugType,size,rvaAddr,fileAddr
			align 4
			SetDebugTypeInfos: 
				
				label .debugType dword at esp+4
				label .size dword at esp+8
				label .rvaAddr dword at esp+12
				label .fileAddr dword at esp+16
				
				mov eax,[.size]
				mov ecx,[.rvaAddr]
				mov edx,[.fileAddr]
				
				.if dword[.debugType] = 0
					; unknown
					mov dword[esi+sDEBUG_DIRECTORY.unknownAddress],1
					mov dword[esi+sDEBUG_DIRECTORY.unknownAddressRVA],ecx
					mov dword[esi+sDEBUG_DIRECTORY.unknownAddressFile],edx
					mov dword[esi+sDEBUG_DIRECTORY.unknownAddressSize],eax
					
				.elseif dword[.debugType] = 1
					; coff
					mov dword[esi+sDEBUG_DIRECTORY.coffAddress],1
					mov dword[esi+sDEBUG_DIRECTORY.coffAddressRVA],ecx
					mov dword[esi+sDEBUG_DIRECTORY.coffAddressFile],edx
					mov dword[esi+sDEBUG_DIRECTORY.coffAddressSize],eax
					
				.elseif dword[.debugType] = 2
					; codeview
					mov dword[esi+sDEBUG_DIRECTORY.cviewAddress],1
					mov dword[esi+sDEBUG_DIRECTORY.cviewAddressRVA],ecx
					mov dword[esi+sDEBUG_DIRECTORY.cviewAddressFile],edx
					mov dword[esi+sDEBUG_DIRECTORY.cviewAddressSize],eax
					
				.elseif dword[.debugType] = 3
					; fpo
					mov dword[esi+sDEBUG_DIRECTORY.fpoAddress],1
					mov dword[esi+sDEBUG_DIRECTORY.fpoAddressRVA],ecx
					mov dword[esi+sDEBUG_DIRECTORY.fpoAddressFile],edx
					mov dword[esi+sDEBUG_DIRECTORY.fpoAddressSize],eax
					
				.elseif dword[.debugType] = 4
					; misc
					mov dword[esi+sDEBUG_DIRECTORY.miscAddress],1
					mov dword[esi+sDEBUG_DIRECTORY.miscAddressRVA],ecx
					mov dword[esi+sDEBUG_DIRECTORY.miscAddressFile],edx
					mov dword[esi+sDEBUG_DIRECTORY.miscAddressSize],eax
					
				.elseif dword[.debugType] = 5
					; exception
					mov dword[esi+sDEBUG_DIRECTORY.exceptionAddress],1
					mov dword[esi+sDEBUG_DIRECTORY.exceptionAddressRVA],ecx
					mov dword[esi+sDEBUG_DIRECTORY.exceptionAddressFile],edx
					mov dword[esi+sDEBUG_DIRECTORY.exceptionAddressSize],eax
					
				.elseif dword[.debugType] = 6
					; fixup
					mov dword[esi+sDEBUG_DIRECTORY.fixupAddress],1
					mov dword[esi+sDEBUG_DIRECTORY.fixupAddressRVA],ecx
					mov dword[esi+sDEBUG_DIRECTORY.fixupAddressFile],edx
					mov dword[esi+sDEBUG_DIRECTORY.fixupAddressSize],eax
					
				.elseif dword[.debugType] = 7
					; omap to src
					mov dword[esi+sDEBUG_DIRECTORY.omapToSourceAddress],1
					mov dword[esi+sDEBUG_DIRECTORY.omapToSourceAddressRVA],ecx
					mov dword[esi+sDEBUG_DIRECTORY.omapToSourceAddressFile],edx
					mov dword[esi+sDEBUG_DIRECTORY.omapToSourceAddressSize],eax
					
				.elseif dword[.debugType] = 8
					; omap from src 
					mov dword[esi+sDEBUG_DIRECTORY.omapFromSourceAddress],1
					mov dword[esi+sDEBUG_DIRECTORY.omapFromSourceAddressRVA],ecx
					mov dword[esi+sDEBUG_DIRECTORY.omapFromSourceAddressFile],edx
					mov dword[esi+sDEBUG_DIRECTORY.omapFromSourceAddressSize],eax
					
				.elseif dword[.debugType] = 9
					; borland
					mov dword[esi+sDEBUG_DIRECTORY.borlandAddress],1
					mov dword[esi+sDEBUG_DIRECTORY.borlandAddressRVA],ecx
					mov dword[esi+sDEBUG_DIRECTORY.borlandAddressFile],edx
					mov dword[esi+sDEBUG_DIRECTORY.borlandAddressSize],eax
					
				.elseif dword[.debugType] = 10
					; reserved10
					mov dword[esi+sDEBUG_DIRECTORY.reserved10Address],1
					mov dword[esi+sDEBUG_DIRECTORY.reserved10AddressRVA],ecx
					mov dword[esi+sDEBUG_DIRECTORY.reserved10AddressFile],edx
					mov dword[esi+sDEBUG_DIRECTORY.reserved10AddressSize],eax
					
				.elseif dword[.debugType] = 11
					; clsid	
					mov dword[esi+sDEBUG_DIRECTORY.clsidAddress],1
					mov dword[esi+sDEBUG_DIRECTORY.clsidAddressRVA],ecx
					mov dword[esi+sDEBUG_DIRECTORY.clsidAddressFile],edx
					mov dword[esi+sDEBUG_DIRECTORY.clsidAddressSize],eax
					
				.endif
				
			ret
			
			proc IsRvaPointsToSection uses esi edi,rvaAddr
				
				.if [rvaAddr] = 0
					jmp .out_err
					
				.endif
				
				mov edi,[ptrSecHeaderInfo]
				mov esi,[ptrFilePeInfo]
				mov esi,[esi+sFILE_PE_INFO.numOfSection]				
				xor ecx,ecx
	.loop:			
				cmp ecx,esi
				je .out_err
					
					mov eax,[edi+sSEC_HEADER_INFO.virtualAddress]	; rva
					.if	dword[edi+sSEC_HEADER_INFO.virtualSize] = 0
						mov edx,[edi+sSEC_HEADER_INFO.sizeOfRawData]		; size
						
					.else
						mov edx,[edi+sSEC_HEADER_INFO.virtualSize]		; size
					
					.endif					
					add edx,eax										; section end
					.if [rvaAddr] >= eax & [rvaAddr] < edx
						mov eax,ecx
						jmp .out
						
					.endif
						
				inc ecx
				add edi,sizeof.sSEC_HEADER_INFO
				jmp .loop
	.out_err:	
				mov eax,-1					
	.out:			
				ret
			endp	
			
			proc SetDebugSortInfos 
				
				locals
					rvaAddr	dd	0
					item dd 0
				endl
				
				; esi is ptr to sDebug_Directory
				; ebx is ptr to sort array
				
				.if dword[esi+sDEBUG_DIRECTORY.unknownAddress] = 1
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE																																	
					; is it in the section
					stdcall IsRvaPointsToSection,dword[esi+sDEBUG_DIRECTORY.unknownAddressRVA]
					.if signed eax < 0
						; no , it is in the root
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						mov edx,dword[esi+sDEBUG_DIRECTORY.unknownAddressFile]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.else
						; yes in the section
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
						mov edx,dword[esi+sDEBUG_DIRECTORY.unknownAddressRVA]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.endif
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_UNKNOWN_TYPE or TREE_ITEM_DATA_RAW
					mov eax,[esi+sDEBUG_DIRECTORY.unknownAddressFile]
					mov edx,[esi+sDEBUG_DIRECTORY.unknownAddressSize]
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1
					
				.endif
				;--------------------------------------------------------------------------------------------------------;
				.if dword[esi+sDEBUG_DIRECTORY.coffAddress] = 1
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE	
					; is it in the section
					stdcall IsRvaPointsToSection,dword[esi+sDEBUG_DIRECTORY.coffAddressRVA]	
					.if signed eax < 0
						; no , it is in the root
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						mov edx,dword[esi+sDEBUG_DIRECTORY.coffAddressFile]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						mov [rvaAddr],edx
						
					.else
						; yes in the section
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
						mov edx,dword[esi+sDEBUG_DIRECTORY.coffAddressRVA]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						mov [rvaAddr],edx
						
					.endif
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_COFF_TYPE or TREE_ITEM_DATA_RAW
					mov eax,[esi+sDEBUG_DIRECTORY.coffAddressFile]
					mov edx,[esi+sDEBUG_DIRECTORY.coffAddressSize]
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax	; start address of the coff symbols header
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1
					
					; coff symbol header
						; next free sort struct
						add ebx,sizeof.sSORT_ITEM_TYPE
						mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_COFF_SYMBOLS_HEADER or TREE_ITEM_DATA_INFO
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],TREE_ITEM_DEBUG_COFF_TYPE or TREE_ITEM_DATA_RAW
						mov edx,[rvaAddr]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
						add [item],1
						
					mov ecx,[ptrFilePeInfo]				
					
					.if dword[ecx+sFILE_PE_INFO.ptrToSymbolTable] <> 0 & dword[ecx+sFILE_PE_INFO.numOfSymbols] <> 0
					; coff symbol table
						; next free sort struct
						add ebx,sizeof.sSORT_ITEM_TYPE
						mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_COFF_SYMBOL_TABLE or TREE_ITEM_DATA_INFO
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],TREE_ITEM_DEBUG_COFF_TYPE or TREE_ITEM_DATA_RAW
						mov eax,[ecx+sFILE_PE_INFO.ptrToSymbolTable]
						mov edx,[ecx+sFILE_PE_INFO.numOfSymbols]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
						mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
						mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
						add [item],1
						
					; coff string table
						; next free sort struct
						add ebx,sizeof.sSORT_ITEM_TYPE
						mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_COFF_STRING_TABLE or TREE_ITEM_DATA_RAW
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],TREE_ITEM_DEBUG_COFF_TYPE or TREE_ITEM_DATA_RAW
						mov eax,[ecx+sFILE_PE_INFO.ptrToStringTable]
						; first entry is a size of the string table
						; skip it , read later 
						add eax,4
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
						mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
						add [item],1
						
					.endif
					
					.if dword[ecx+sFILE_PE_INFO.ptrToLineNumbers] <> 0 & dword[ecx+sFILE_PE_INFO.numOfLineNum] <> 0
					; coff line numbers
						; next free sort struct
						add ebx,sizeof.sSORT_ITEM_TYPE
						mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_COFF_LINE_NUMBERS or TREE_ITEM_DATA_INFO
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],TREE_ITEM_DEBUG_COFF_TYPE or TREE_ITEM_DATA_RAW
						mov eax,[ecx+sFILE_PE_INFO.ptrToLineNumbers]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
						mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
						add [item],1
						
					.endif
																																																																								
				.endif
				;--------------------------------------------------------------------------------------------------------;
				.if dword[esi+sDEBUG_DIRECTORY.cviewAddress] = 1
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE	
					; is it in the section
					stdcall IsRvaPointsToSection,dword[esi+sDEBUG_DIRECTORY.cviewAddressRVA]
					.if signed eax < 0
						; no , it is in the root
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						mov edx,dword[esi+sDEBUG_DIRECTORY.cviewAddressFile]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.else
						; yes in the section
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
						mov edx,dword[esi+sDEBUG_DIRECTORY.cviewAddressRVA]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.endif
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_CVIEW_TYPE or TREE_ITEM_DATA_RAW
					mov eax,[esi+sDEBUG_DIRECTORY.cviewAddressFile]
					mov edx,[esi+sDEBUG_DIRECTORY.cviewAddressSize]
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1																																	
				
				.endif
				;--------------------------------------------------------------------------------------------------------;
				.if dword[esi+sDEBUG_DIRECTORY.fpoAddress] = 1
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE	
					; is it in the section
					stdcall IsRvaPointsToSection,dword[esi+sDEBUG_DIRECTORY.fpoAddressRVA]	
					.if signed eax < 0
						; no , it is in the root
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						mov edx,dword[esi+sDEBUG_DIRECTORY.fpoAddressFile]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.else
						; yes in the section
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
						mov edx,dword[esi+sDEBUG_DIRECTORY.fpoAddressRVA]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.endif
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_FPO_TYPE or TREE_ITEM_DATA_INFO
					mov eax,[esi+sDEBUG_DIRECTORY.fpoAddressFile]
					mov edx,[esi+sDEBUG_DIRECTORY.fpoAddressSize]
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1																																
				
				.endif
				;--------------------------------------------------------------------------------------------------------;
				.if dword[esi+sDEBUG_DIRECTORY.miscAddress] = 1
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE	
					; is it in the section
					stdcall IsRvaPointsToSection,dword[esi+sDEBUG_DIRECTORY.miscAddressRVA]	
					.if signed eax < 0
						; no , it is in the root
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						mov edx,dword[esi+sDEBUG_DIRECTORY.miscAddressFile]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.else
						; yes in the section
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
						mov edx,dword[esi+sDEBUG_DIRECTORY.miscAddressRVA]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.endif
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_MISC_TYPE or TREE_ITEM_DATA_RAW
					mov eax,[esi+sDEBUG_DIRECTORY.miscAddressFile]
					mov edx,[esi+sDEBUG_DIRECTORY.miscAddressSize]
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1																																
				
				.endif
				;--------------------------------------------------------------------------------------------------------;
				.if dword[esi+sDEBUG_DIRECTORY.exceptionAddress] = 1
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE	
					; is it in the section
					stdcall IsRvaPointsToSection,dword[esi+sDEBUG_DIRECTORY.exceptionAddressRVA]
					.if signed eax < 0
						; no , it is in the root
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						mov edx,dword[esi+sDEBUG_DIRECTORY.exceptionAddressFile]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.else
						; yes in the section
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
						mov edx,dword[esi+sDEBUG_DIRECTORY.exceptionAddressRVA]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.endif
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_EXCEPTION_TYPE or TREE_ITEM_DATA_RAW
					mov eax,[esi+sDEBUG_DIRECTORY.exceptionAddressFile]
					mov edx,[esi+sDEBUG_DIRECTORY.exceptionAddressSize]
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1																																	
				
				.endif
				;--------------------------------------------------------------------------------------------------------;
				.if dword[esi+sDEBUG_DIRECTORY.fixupAddress] = 1
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE	
					; is it in the section
					stdcall IsRvaPointsToSection,dword[esi+sDEBUG_DIRECTORY.fixupAddressRVA]
					.if signed eax < 0
						; no , it is in the root
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						mov edx,dword[esi+sDEBUG_DIRECTORY.fixupAddressFile]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.else
						; yes in the section
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
						mov edx,dword[esi+sDEBUG_DIRECTORY.fixupAddressRVA]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.endif
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_FIXUP_TYPE or TREE_ITEM_DATA_RAW
					mov eax,[esi+sDEBUG_DIRECTORY.fixupAddressFile]
					mov edx,[esi+sDEBUG_DIRECTORY.fixupAddressSize]
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1																																	
				
				.endif
				;--------------------------------------------------------------------------------------------------------;
				.if dword[esi+sDEBUG_DIRECTORY.omapToSourceAddress] = 1
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE	
					; is it in the section
					stdcall IsRvaPointsToSection,dword[esi+sDEBUG_DIRECTORY.omapToSourceAddressRVA]
					.if signed eax < 0
						; no , it is in the root
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						mov edx,dword[esi+sDEBUG_DIRECTORY.omapToSourceAddressFile]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.else
						; yes in the section
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
						mov edx,dword[esi+sDEBUG_DIRECTORY.omapToSourceAddressRVA]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.endif
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_OMAP_TO_S_TYPE or TREE_ITEM_DATA_RAW
					mov eax,[esi+sDEBUG_DIRECTORY.omapToSourceAddressFile]
					mov edx,[esi+sDEBUG_DIRECTORY.omapToSourceAddressSize]
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1																																	
				
				.endif
				;--------------------------------------------------------------------------------------------------------;
				.if dword[esi+sDEBUG_DIRECTORY.omapFromSourceAddress] = 1
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE	
					; is it in the section
					stdcall IsRvaPointsToSection,dword[esi+sDEBUG_DIRECTORY.omapFromSourceAddressRVA]	
					.if signed eax < 0
						; no , it is in the root
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						mov edx,dword[esi+sDEBUG_DIRECTORY.omapFromSourceAddressFile]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.else
						; yes in the section
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
						mov edx,dword[esi+sDEBUG_DIRECTORY.omapFromSourceAddressRVA]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.endif
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_OMAP_FROM_S_TYPE or TREE_ITEM_DATA_RAW
					mov eax,[esi+sDEBUG_DIRECTORY.omapFromSourceAddressFile]
					mov edx,[esi+sDEBUG_DIRECTORY.omapFromSourceAddressSize]
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1																																
				
				.endif
				;--------------------------------------------------------------------------------------------------------;
				.if dword[esi+sDEBUG_DIRECTORY.borlandAddress] = 1
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE	
					; is it in the section
					stdcall IsRvaPointsToSection,dword[esi+sDEBUG_DIRECTORY.borlandAddressRVA]	
					.if signed eax < 0
						; no , it is in the root
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						mov edx,dword[esi+sDEBUG_DIRECTORY.borlandAddressFile]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.else
						; yes in the section
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
						mov edx,dword[esi+sDEBUG_DIRECTORY.borlandAddressRVA]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.endif
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_BORLAND_TYPE or TREE_ITEM_DATA_RAW
					mov eax,[esi+sDEBUG_DIRECTORY.borlandAddressFile]
					mov edx,[esi+sDEBUG_DIRECTORY.borlandAddressSize]
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1																																
				
				.endif
				;--------------------------------------------------------------------------------------------------------;
				.if dword[esi+sDEBUG_DIRECTORY.reserved10Address] = 1			
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE	
					; is it in the section
					stdcall IsRvaPointsToSection,dword[esi+sDEBUG_DIRECTORY.reserved10AddressRVA]	
					.if signed eax < 0
						; no , it is in the root
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						mov edx,dword[esi+sDEBUG_DIRECTORY.reserved10AddressFile]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.else
						; yes in the section
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
						mov edx,dword[esi+sDEBUG_DIRECTORY.reserved10AddressRVA]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.endif
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_RESERVED10_TYPE or TREE_ITEM_DATA_RAW
					mov eax,[esi+sDEBUG_DIRECTORY.reserved10AddressFile]
					mov edx,[esi+sDEBUG_DIRECTORY.reserved10AddressSize]
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1																																
				
				.endif	
				;--------------------------------------------------------------------------------------------------------;
				.if dword[esi+sDEBUG_DIRECTORY.clsidAddress] = 1
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE	
					; is it in the section
					stdcall IsRvaPointsToSection,dword[esi+sDEBUG_DIRECTORY.clsidAddressRVA]
					.if signed eax < 0
						; no , it is in the root
						mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
						mov edx,dword[esi+sDEBUG_DIRECTORY.clsidAddressFile]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.else
						; yes in the section
						mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
						mov edx,dword[esi+sDEBUG_DIRECTORY.clsidAddressRVA]
						mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
						
					.endif
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_CLSID_TYPE or TREE_ITEM_DATA_RAW
					mov eax,[esi+sDEBUG_DIRECTORY.clsidAddressFile]
					mov edx,[esi+sDEBUG_DIRECTORY.clsidAddressSize]
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1																																	
					
				.endif	
														
				mov eax,[item]
				ret
			endp
			
			proc GetSectionForTableRva uses ebx esi edi,tableRva,secRva,secPtrToRawData			
				
				local numOfSection:DWORD
				
				mov ebx,[ptrSecHeaderInfo]
				mov edx,[ptrFilePeInfo]
				mov edx,[edx+sFILE_PE_INFO.numOfSection]
				mov [numOfSection],edx				
				xor ecx,ecx
	.loop:			
				cmp ecx,[numOfSection]
				je .out_err
					
					mov eax,[ebx+sSEC_HEADER_INFO.virtualAddress]	; rva
					.if dword[ebx+sSEC_HEADER_INFO.virtualSize] <> 0 & dword[ebx+sSEC_HEADER_INFO.sizeOfRawData] = 0
						jmp .next
					
					.elseif dword[ebx+sSEC_HEADER_INFO.virtualSize] = 0
						mov edx,[ebx+sSEC_HEADER_INFO.sizeOfRawData]		; size
						
					.else
						mov edx,[ebx+sSEC_HEADER_INFO.virtualSize]			; size
						
					.endif					
					add edx,eax										; section end
					
					.if [tableRva] >= eax & [tableRva] < edx
						; mybe just a check
						.if [secRva] <> 0 & [secPtrToRawData] <> 0
							mov esi,[secRva]
							mov edi,[secPtrToRawData]
							mov [esi],eax
							mov eax,[ebx+sSEC_HEADER_INFO.pointerToRawData]
							mov [edi],eax
						
						.endif												
												
						mov eax,ecx
						jmp .out
						
					.endif
					
	.next:			
				inc ecx
				add ebx,sizeof.sSEC_HEADER_INFO
				jmp .loop
	.out_err:	
				mov eax,-1					
	.out:			
				ret
			endp									
			
			proc ProcessDelayImportDescriptor uses ebx esi edi,fileAddress
				
				locals
					ptrDelayDescr	dd	0
					numOfImports	dd	0
					boundImport		dd	0
					dataInfo	db 4 dup 0
				endl
				
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,100*sizeof.DELAY_IMPORT_DESCRIPTOR
				mov [ptrDelayDescr],eax
				mov edi,eax
				
				lea ebx,[dataInfo]
				xor esi,esi
	.loop:			
				cmp esi,100
				je .out
					
					; get name
					stdcall GetData,ebx,[fileAddress],4,4
					mov edx,[ebx]
					mov dword[edi+DELAY_IMPORT_DESCRIPTOR.Name],edx
					; get delay import address table
					stdcall GetData,ebx,[fileAddress],12,4
					mov edx,[ebx]
					mov dword[edi+DELAY_IMPORT_DESCRIPTOR.DelayImportAddressTable],edx
					; get delay import name table
					stdcall GetData,ebx,[fileAddress],16,4
					mov edx,[ebx]
					mov dword[edi+DELAY_IMPORT_DESCRIPTOR.DelayImportNameTable],edx					
					; check for last entry
					.if dword[edi+DELAY_IMPORT_DESCRIPTOR.DelayImportAddressTable] = 0 & dword[edi+DELAY_IMPORT_DESCRIPTOR.DelayImportNameTable] = 0
						jmp .out
					
					.endif
					; get bound delay iat for check later
					stdcall GetData,ebx,[fileAddress],20,4
					mov edx,[ebx]				
					mov [boundImport],edx
				
				inc esi
				add [fileAddress],sizeof.DELAY_IMPORT_DESCRIPTOR
				add edi,sizeof.DELAY_IMPORT_DESCRIPTOR
				jmp .loop
	.out:		
				mov eax,[ptrFilePeInfo]
				mov dword[eax+sFILE_PE_INFO.numOfDelayImports],esi
				.if [boundImport] <> 0
					mov dword[eax+sFILE_PE_INFO.delayBoundImport],1
					
				.endif
				mov [numOfImports],esi
					
				stdcall InsertionSort,[ptrDelayDescr],3,esi		
				
				; ALLOC MEM for sIMPORT_DESCRIPTOR
				imul esi,sizeof.sIMPORT_DESCRIPTOR
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,esi
				mov [ptrDelayAddress],eax
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,esi
				mov [ptrDelayName],eax
				
				mov ebx,[ptrDelayDescr]
				mov esi,[ptrDelayName]
				mov edi,[ptrDelayAddress]
				
				xor ecx,ecx
	.loop2:			
				cmp ecx,[numOfImports]
				je .out2
					
					mov eax,[ebx+DELAY_IMPORT_DESCRIPTOR.DelayImportNameTable]
					mov edx,[ebx+DELAY_IMPORT_DESCRIPTOR.Name]
					
					mov dword[esi+sIMPORT_DESCRIPTOR.rvaAddressStart],eax
					mov dword[esi+sIMPORT_DESCRIPTOR.nameRva],edx
					
					mov eax,[ebx+DELAY_IMPORT_DESCRIPTOR.DelayImportAddressTable]
					mov dword[edi+sIMPORT_DESCRIPTOR.rvaAddressStart],eax
					mov dword[edi+sIMPORT_DESCRIPTOR.nameRva],edx											
				
				inc ecx
				add ebx,sizeof.DELAY_IMPORT_DESCRIPTOR
				add esi,sizeof.sIMPORT_DESCRIPTOR
				add edi,sizeof.sIMPORT_DESCRIPTOR
				jmp .loop2
	.out2:			
				.if [ptrDelayDescr] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrDelayDescr]
					
				.endif				
														
				ret
			endp
			
			proc ProcessImageImportDescriptor uses ebx esi edi,fileAddress
				
				locals
					ptrImageDescriptor	dd	0
					boundImport		dd	0
					numOfImports	dd	0
					dataInfo	db	4 dup 0	
				endl
							
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,100*sizeof.IMAGE_IMPORT_DESCRIPTOR
				mov [ptrImageDescriptor],eax
				mov edi,eax
				
				lea ebx,[dataInfo]
				xor esi,esi
	.loop:			
				cmp esi,100
				je .out
					
					; get import lookup table rva address
					stdcall GetData,ebx,[fileAddress],0,4
					mov edx,[ebx]
					mov dword[edi+IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk],edx
					; get name rva
					stdcall GetData,ebx,[fileAddress],12,4
					mov edx,[ebx]
					mov dword[edi+IMAGE_IMPORT_DESCRIPTOR.Name_],edx
					; get import address table rva address
					stdcall GetData,ebx,[fileAddress],16,4
					mov edx,[ebx]
					mov dword[edi+IMAGE_IMPORT_DESCRIPTOR.FirstThunk],edx
					
					.if dword[edi+IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk] = 0 & dword[edi+IMAGE_IMPORT_DESCRIPTOR.FirstThunk] = 0
						jmp .out
					
					.endif
					
					; get timedatestamp for bound checking later
					stdcall GetData,ebx,[fileAddress],4,4
					mov edx,[ebx]
					mov [boundImport],edx
					
				inc esi
				add [fileAddress],sizeof.IMAGE_IMPORT_DESCRIPTOR
				add edi,sizeof.IMAGE_IMPORT_DESCRIPTOR
				jmp .loop
	.out:					
				mov eax,[ptrFilePeInfo]
				.if [boundImport] = 0
					mov dword[eax+sFILE_PE_INFO.boundImport],IMPORT_NOT_BOUND
					
				.elseif [boundImport] = -1
					mov dword[eax+sFILE_PE_INFO.boundImport],IMPORT_NEW_BIND
					
				.else
					mov dword[eax+sFILE_PE_INFO.boundImport],IMPORT_OLD_BIND
					
				.endif
				
				mov [numOfImports],esi
				mov dword[eax+sFILE_PE_INFO.numOfImports],esi
						
				stdcall InsertionSort,[ptrImageDescriptor],2,esi
								
				; ALLOC MEM for sIMPORT_DESCRIPTOR
				imul esi,sizeof.sIMPORT_DESCRIPTOR
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,esi
				mov [ptrImportNames],eax
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,esi
				mov [ptrImportAddress],eax
				
				mov ebx,[ptrImageDescriptor]
				mov esi,[ptrImportNames]
				mov edi,[ptrImportAddress]
				
				xor ecx,ecx
	.loop2:			
				cmp ecx,[numOfImports]
				je .out2
					
					mov eax,[ebx+IMAGE_IMPORT_DESCRIPTOR.OriginalFirstThunk]
					mov edx,[ebx+IMAGE_IMPORT_DESCRIPTOR.Name_]
					
					mov dword[esi+sIMPORT_DESCRIPTOR.rvaAddressStart],eax
					mov dword[esi+sIMPORT_DESCRIPTOR.nameRva],edx
					
					mov eax,[ebx+IMAGE_IMPORT_DESCRIPTOR.FirstThunk]
					mov dword[edi+sIMPORT_DESCRIPTOR.rvaAddressStart],eax
					mov dword[edi+sIMPORT_DESCRIPTOR.nameRva],edx											
				
				inc ecx
				add ebx,sizeof.IMAGE_IMPORT_DESCRIPTOR
				add esi,sizeof.sIMPORT_DESCRIPTOR
				add edi,sizeof.sIMPORT_DESCRIPTOR
				jmp .loop2
	.out2:			
				.if [ptrImageDescriptor] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrImageDescriptor]
					
				.endif								
					
				ret
			endp
			
			proc DataDirectoryPointsOutsideSection uses ebx esi edi,directoryType,pDataDirectory,pSort
				
				locals
					item	dd	0
					address	dd	0
					numOfTypes	dd	0
					i	dd	0
					dataInfo	db 4 dup 0
				endl
				
				mov ebx,[pSort]
				mov esi,[pDataDirectory]
				lea edi,[dataInfo]
				
				.if [directoryType] = TREE_ITEM_BOUND_DIRECTORY_ENTRY
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_BOUND_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
					mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
					mov eax,[esi+sDATA_DIRECTORY_INFO.virtualAddress]					
					mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					add [item],1
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE
									
					; read first offset to module name
					stdcall GetData,edi,eax,4,2
					movzx edx,word[edi]
					; file start of first module of bound dll names
					add edx,[esi+sDATA_DIRECTORY_INFO.virtualAddress]
					; calc file size of bound dll names
					mov eax,[esi+sDATA_DIRECTORY_INFO.virtualAddress]
					add eax,[esi+sDATA_DIRECTORY_INFO.size]
					sub eax,edx
					
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_BOUND_DLLS_NAMES or TREE_ITEM_DATA_RAW
					mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
					mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
					mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],edx
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],eax
					add [item],1
																					
					mov edx,[item]
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE		
					mov eax,ebx
					
				.elseif [directoryType] = TREE_ITEM_CERTIFICATE_TABLE				
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_CERTIFICATE_TABLE or TREE_ITEM_DATA_RAW
					mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
					mov eax,[esi+sDATA_DIRECTORY_INFO.virtualAddress]
					mov edx,[esi+sDATA_DIRECTORY_INFO.size]					
					mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],edx
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
					add [item],1
										
					mov edx,[item]
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE
					mov eax,ebx								
				
				.elseif [directoryType] = TREE_ITEM_DEBUG_DIRECTORY_ENTRY
					mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
					mov dword[ebx+sSORT_ITEM_TYPE.inRoot],1
					mov eax,[esi+sDATA_DIRECTORY_INFO.virtualAddress]
					mov edx,[esi+sDATA_DIRECTORY_INFO.size]
					mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],edx
					mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
					mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx															
					add [item],1
					
					mov [address],eax											
					; ALLOC MEM for debug directory struct
					invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,sizeof.sDEBUG_DIRECTORY
					mov [ptrDebugDirec],eax
					; how many debug types there are in the file
					xor edx,edx
					mov eax,[esi+sDATA_DIRECTORY_INFO.size]
					mov ecx,sizeof.IMAGE_DEBUG_DIRECTORY
					div ecx
					mov [numOfTypes],eax																				
					; find them
					.if eax <> 0
						mov esi,[ptrDebugDirec]
						mov dword[esi+sDEBUG_DIRECTORY.numOfTypesInFile],eax
						mov [i],0															
	.loop:				
						mov ecx,[i]	
						cmp ecx,[numOfTypes]	; count for num of debug types
						je .out
																																										
							; get ptr to raw data
							stdcall GetData,edi,[address],24,4
							push dword[edi]
							; get rva of data
							stdcall GetData,edi,[address],20,4
							push dword[edi]
							; get size of data
							stdcall GetData,edi,[address],16,4
							push dword[edi]
							; get type
							stdcall GetData,edi,[address],12,4
							push dword[edi]					
							; args - debugType,size,rvaAddr,fileAddr									
							call SetDebugTypeInfos
							add esp,4*4
							
						inc [i]
						add [address],sizeof.IMAGE_DEBUG_DIRECTORY
						jmp .loop
	.out:														
						stdcall SetDebugSortInfos
						add [item],eax
																						
					.endif							
																										
					mov edx,[item]
					; next free sort struct
					add ebx,sizeof.sSORT_ITEM_TYPE
					mov eax,ebx		
					
				.endif
				
				ret
			endp
			
			proc DataDirectoryPointsToSection uses ebx esi edi,directoryType,pDataDirectory,pSort
				
				locals
					numOfSections	dd	0	
					numOfImports	dd	0
					secRVA	dd	0
					secPtrToRawData	dd	0
					sRVA	dd	0
					sRawData	dd	0														
					i	dd	0
					j	dd	0
					k	dd	0					
					item	dd	0
					dataInfo db 4 dup 0					
				endl
				
				mov edx,[ptrFilePeInfo]
				mov edx,[edx+sFILE_PE_INFO.numOfSection]
				mov [numOfSections],edx
				
				mov ebx,[pSort]
				mov esi,[ptrSecHeaderInfo]
				mov edi,[pDataDirectory]
				
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfSections]
				je .out_err
					
					; is section empty
					.if dword[esi+sSEC_HEADER_INFO.pointerToRawData] = 0 | dword[esi+sSEC_HEADER_INFO.sizeOfRawData] = 0
						; try next
						inc [i]
						add esi,sizeof.sSEC_HEADER_INFO
						jmp .loop
						
					.endif
					
					mov eax,[esi+sSEC_HEADER_INFO.pointerToRawData]
					mov [secPtrToRawData],eax
					mov eax,[esi+sSEC_HEADER_INFO.virtualAddress]	; section start
					mov [secRVA],eax
					.if dword[esi+sSEC_HEADER_INFO.virtualSize] = 0
						mov edx,[esi+sSEC_HEADER_INFO.sizeOfRawData]
						
					.else
						mov edx,[esi+sSEC_HEADER_INFO.virtualSize]
					
					.endif					
					add edx,eax										; section end
					
					; is data directory points to the sections raw data of the section header
					.if dword[edi+sDATA_DIRECTORY_INFO.virtualAddress] >= eax & dword[edi+sDATA_DIRECTORY_INFO.virtualAddress] < edx
						; it points
						.if [directoryType]	= TREE_ITEM_EXPORT_DIRECTORY_ENTRY														
							; is the export directory table for real ?
							mov eax,[edi+sDATA_DIRECTORY_INFO.virtualAddress]
							sub eax,[secRVA]
							add eax,[secPtrToRawData]					
							stdcall GetData,addr dataInfo,eax,0,4
							; if edx <> 0 data is probably false
							lea ecx,[dataInfo]							
							.if dword[ecx] <> 0
								jmp .out_err
								
							.endif							
							; set export directory
							mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_EXPORT_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
							mov ecx,[i]
							mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx
							mov eax,[edi+sDATA_DIRECTORY_INFO.virtualAddress]
							mov edx,[edi+sDATA_DIRECTORY_INFO.size]
							mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
							mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],edx
							; calc file start
							sub eax,[secRVA]
							add eax,[secPtrToRawData]
							mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
							add [item],1
																	
							push esi	
							push edi
							; ALLOC MEM for sEXPORT_DIRECTORY
							invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,sizeof.sEXPORT_DIRECTORY
							mov [ptrExportDirec],eax
							mov esi,eax
							; set sEXPORT_DIRECTORY struct
							lea edi,[dataInfo]																
								; get namerva dll and set to namefile dll
								stdcall GetData,edi,dword[ebx+sSORT_ITEM_TYPE.fileAddress],12,4
								mov edx,[edi]
								sub edx,[secRVA]
								add edx,[secPtrToRawData]
								mov dword[esi+sEXPORT_DIRECTORY.nameFile],edx
								; get ordinal base and save
								stdcall GetData,edi,dword[ebx+sSORT_ITEM_TYPE.fileAddress],16,4
								mov edx,[edi]
								mov dword[esi+sEXPORT_DIRECTORY.ordinalBase],edx
								; get number address table entries and save
								stdcall GetData,edi,dword[ebx+sSORT_ITEM_TYPE.fileAddress],20,4
								mov edx,[edi]
								mov dword[esi+sEXPORT_DIRECTORY.numOfAddressTableEntries],edx
								; get number of name pointers and save
								stdcall GetData,edi,dword[ebx+sSORT_ITEM_TYPE.fileAddress],24,4
								mov edx,[edi]
								mov dword[esi+sEXPORT_DIRECTORY.numOfNamePointerEntries],edx
								; get export address table rva
								stdcall GetData,edi,dword[ebx+sSORT_ITEM_TYPE.fileAddress],28,4
								mov edx,[edi]
								.if edx <> 0
									mov dword[esi+sEXPORT_DIRECTORY.exportAddressRVA],edx																										
									
								.endif
								; get name pointer rva
								stdcall GetData,edi,dword[ebx+sSORT_ITEM_TYPE.fileAddress],32,4
								mov edx,[edi]
								.if edx <> 0
									mov dword[esi+sEXPORT_DIRECTORY.namePointerRVA],edx									
									
								.endif
								; get ordinal table rva 
								stdcall GetData,edi,dword[ebx+sSORT_ITEM_TYPE.fileAddress],36,4
								mov edx,[edi]
								.if edx <> 0
									mov dword[esi+sEXPORT_DIRECTORY.ordinalTableRVA],edx									
									
								.endif
								; sec rva
								mov edx,[secRVA]
								mov dword[esi+sEXPORT_DIRECTORY.sectionRVA],edx
								; sec ptr to raw data
								mov edx,[secPtrToRawData]
								mov dword[esi+sEXPORT_DIRECTORY.sectionPtrToRawData],edx
								
							pop edi
								; export data directory rva
								mov edx,[edi+sDATA_DIRECTORY_INFO.virtualAddress]
								mov dword[esi+sEXPORT_DIRECTORY.exportDataDirecRVA],edx
								; export data directory size
								mov edx,[edi+sDATA_DIRECTORY_INFO.size]
								mov dword[esi+sEXPORT_DIRECTORY.exportDataDirecSize],edx							
							
							
							; check for the export address table
							.if dword[esi+sEXPORT_DIRECTORY.exportAddressRVA] <> 0 & dword[esi+sEXPORT_DIRECTORY.numOfAddressTableEntries] <> 0									
								add ebx,sizeof.sSORT_ITEM_TYPE								
								mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_EXPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO								
								mov eax,[esi+sEXPORT_DIRECTORY.exportAddressRVA]
								mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
								push eax																																	
									stdcall GetSectionForTableRva,eax,addr sRVA,addr sRawData
									mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
								pop eax
								sub eax,[sRVA]
								add eax,[sRawData]
								mov dword[esi+sEXPORT_DIRECTORY.exportAddressFile],eax				
								mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax	
								add [item],1
							
							.endif
							; check for the name pointer table
							.if dword[esi+sEXPORT_DIRECTORY.namePointerRVA] <> 0 & dword[esi+sEXPORT_DIRECTORY.numOfNamePointerEntries] <> 0
								add ebx,sizeof.sSORT_ITEM_TYPE								
								mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_EXPORT_NAME_PTR_TABLE or TREE_ITEM_DATA_INFO																
								mov eax,[esi+sEXPORT_DIRECTORY.namePointerRVA]								
								mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
								push eax
									stdcall GetSectionForTableRva,eax,addr sRVA,addr sRawData
									mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
								pop eax
								sub eax,[sRVA]
								add eax,[sRawData]
								mov dword[esi+sEXPORT_DIRECTORY.namePointerFile],eax
								mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax	
								add [item],1
								
							.endif
							; check for the ordinal table
							.if dword[esi+sEXPORT_DIRECTORY.ordinalTableRVA] <> 0 & dword[esi+sEXPORT_DIRECTORY.numOfNamePointerEntries] <> 0
								add ebx,sizeof.sSORT_ITEM_TYPE								
								mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_EXPORT_ORDINAL_TABLE or TREE_ITEM_DATA_INFO								
								mov eax,[esi+sEXPORT_DIRECTORY.ordinalTableRVA]
								mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
								push eax
									stdcall GetSectionForTableRva,eax,addr sRVA,addr sRawData
									mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
								pop eax
								sub eax,[sRVA]
								add eax,[sRawData]
								mov dword[esi+sEXPORT_DIRECTORY.ordinalTableFile],eax
								mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax	
								add [item],1
							
							.endif
							
							pop esi
														
							mov edx,[item]
							; next free sort struct
							add ebx,sizeof.sSORT_ITEM_TYPE
							mov eax,ebx
							jmp .out
							
						.elseif [directoryType] = TREE_ITEM_IMPORT_DIRECTORY_ENTRY					
							; set import directory												
							mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_IMPORT_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
							mov ecx,[i]
							mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx
							mov eax,[edi+sDATA_DIRECTORY_INFO.virtualAddress]
							mov edx,[edi+sDATA_DIRECTORY_INFO.size]
							mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
							mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],edx
							; calc file start
							sub eax,[secRVA]
							add eax,[secPtrToRawData]
							mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
							add [item],1
							
							; find which image_import_descriptor struct have smallest rva addresses ( lookup table and address table )
							stdcall ProcessImageImportDescriptor,eax
							; process imports for infos						
							mov edx,[ptrFilePeInfo]
							mov edx,[edx+sFILE_PE_INFO.numOfImports]
							mov [numOfImports],edx							
												
							mov esi,[ptrImportNames]
							mov edi,[ptrImportAddress]
							xor ecx,ecx
			.loop2:				
							cmp ecx,[numOfImports]
							je .next
								
								.if dword[esi+sIMPORT_DESCRIPTOR.rvaAddressStart] <> 0					
									push ecx																				
										stdcall GetSectionForTableRva,dword[esi+sIMPORT_DESCRIPTOR.rvaAddressStart],addr sRVA,addr sRawData
										.if	signed eax >= 0											
											pop ecx
												mov dword[esi+sIMPORT_DESCRIPTOR.inSectionNo],eax
												mov eax,[esi+sIMPORT_DESCRIPTOR.rvaAddressStart]
												sub eax,[sRVA]
												add eax,[sRawData]
												mov dword[esi+sIMPORT_DESCRIPTOR.fileAddressStart],eax
										
										.else
											; dont process to sort struct
											pop ecx
												mov dword[esi+sIMPORT_DESCRIPTOR.rvaAddressStart],0
												
										.endif	
									
									push ecx
										stdcall GetSectionForTableRva,dword[esi+sIMPORT_DESCRIPTOR.nameRva],addr sRVA,addr sRawData
										.if signed eax < 0
											pop ecx
												mov edx,[esi+sIMPORT_DESCRIPTOR.nameRva]
												mov dword[esi+sIMPORT_DESCRIPTOR.nameFile],edx
												
										.else
											pop ecx															
												mov edx,[esi+sIMPORT_DESCRIPTOR.nameRva]
												sub edx,[sRVA]
												add edx,[sRawData]
												mov dword[esi+sIMPORT_DESCRIPTOR.nameFile],edx
											
										.endif									
									
								.endif
								
								.if dword[edi+sIMPORT_DESCRIPTOR.rvaAddressStart] <> 0									
									push ecx
										stdcall GetSectionForTableRva,dword[edi+sIMPORT_DESCRIPTOR.rvaAddressStart],addr sRVA,addr sRawData
										.if	signed eax >= 0											
											pop ecx
												mov dword[edi+sIMPORT_DESCRIPTOR.inSectionNo],eax
												mov eax,[edi+sIMPORT_DESCRIPTOR.rvaAddressStart]
												sub eax,[sRVA]
												add eax,[sRawData]
												mov dword[edi+sIMPORT_DESCRIPTOR.fileAddressStart],eax
										
										.else
											; dont process to sort struct
											pop ecx
												mov dword[edi+sIMPORT_DESCRIPTOR.rvaAddressStart],0
												
										.endif				
									
									push ecx
										stdcall GetSectionForTableRva,dword[edi+sIMPORT_DESCRIPTOR.nameRva],addr sRVA,addr sRawData
										.if signed eax < 0
											pop ecx
												mov edx,[edi+sIMPORT_DESCRIPTOR.nameRva]
												mov dword[edi+sIMPORT_DESCRIPTOR.nameFile],edx
												
										.else
											pop ecx															
												mov edx,[edi+sIMPORT_DESCRIPTOR.nameRva]
												sub edx,[sRVA]
												add edx,[sRawData]
												mov dword[edi+sIMPORT_DESCRIPTOR.nameFile],edx
											
										.endif																																								
									
								.endif
							
							inc ecx
							add esi,sizeof.sIMPORT_DESCRIPTOR
							add edi,sizeof.sIMPORT_DESCRIPTOR
							
							jmp .loop2		
			.next:																				
							; get rva address of the first import lookup table
							; check is there any and fill sort struct							
							mov esi,[ptrImportNames]
							.if dword[esi+sIMPORT_DESCRIPTOR.rvaAddressStart] <> 0	
								add ebx,sizeof.sSORT_ITEM_TYPE															
								mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO								
								mov eax,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
								mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
								mov edx,[esi+sIMPORT_DESCRIPTOR.rvaAddressStart]
								mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
								mov eax,[esi+sIMPORT_DESCRIPTOR.inSectionNo]
								mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax								
								add [item],1
								
							.endif			
							
							; get rva address of the first import address table
							; check is there any and fill sort struct
							mov esi,[ptrImportAddress]
							.if dword[esi+sIMPORT_DESCRIPTOR.rvaAddressStart] <> 0
								add ebx,sizeof.sSORT_ITEM_TYPE								
								mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO								
								mov eax,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
								mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
								mov edx,[esi+sIMPORT_DESCRIPTOR.rvaAddressStart]
								mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
								mov eax,[esi+sIMPORT_DESCRIPTOR.inSectionNo]
								mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax								
								add [item],1
							
							.endif	
							
							mov edx,[item]
							; next free sort struct
							add ebx,sizeof.sSORT_ITEM_TYPE
							mov eax,ebx							
							jmp .out
							
						.elseif [directoryType] = TREE_ITEM_IMAGE_BASE_RELOCATION						
							mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_IMAGE_BASE_RELOCATION or TREE_ITEM_DATA_INFO																								
							mov eax,[edi+sDATA_DIRECTORY_INFO.virtualAddress]
							mov edx,[edi+sDATA_DIRECTORY_INFO.size]
							mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
							mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],edx
							mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
							mov ecx,[i]
							mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx
							; calc file start
							sub eax,[secRVA]
							add eax,[secPtrToRawData]
							mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
							add [item],1
							
							mov edx,[item]
							; next free sort struct
							add ebx,sizeof.sSORT_ITEM_TYPE
							mov eax,ebx							
							jmp .out													
							
						.elseif [directoryType] = TREE_ITEM_TLS_DIRECTORY
							mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_TLS_DIRECTORY or TREE_ITEM_DATA_INFO														
							mov eax,[edi+sDATA_DIRECTORY_INFO.virtualAddress]
							mov edx,[edi+sDATA_DIRECTORY_INFO.size]
							mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
							mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],edx
							mov ecx,[i]											
							mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx							
							; calc file start
							sub eax,[secRVA]
							add eax,[secPtrToRawData]
							mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
							add [item],1
							
							mov edx,[item]
							; next free sort struct
							add ebx,sizeof.sSORT_ITEM_TYPE
							mov eax,ebx							
							jmp .out
							
						.elseif [directoryType] = TREE_ITEM_LOAD_CONFIGURATION			
							mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_LOAD_CONFIGURATION or TREE_ITEM_DATA_INFO							
							mov eax,[edi+sDATA_DIRECTORY_INFO.virtualAddress]
							mov edx,[edi+sDATA_DIRECTORY_INFO.size]
							mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
							mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],edx
							mov ecx,[i]										
							mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx							
							; calc file start
							sub eax,[secRVA]
							add eax,[secPtrToRawData]
							mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
							add [item],1
							
							mov edx,[item]
							; next free sort struct
							add ebx,sizeof.sSORT_ITEM_TYPE
							mov eax,ebx
							jmp .out
						
						.elseif [directoryType] = TREE_ITEM_DELAY_LOAD_DIRECTORY_ENTRY
							; set delay-load directory entry
							mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DELAY_LOAD_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
							mov ecx,[i]
							mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx
							mov eax,[edi+sDATA_DIRECTORY_INFO.virtualAddress]
							mov edx,[edi+sDATA_DIRECTORY_INFO.size]
							mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
							mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],edx
							; calc file start
							sub eax,[secRVA]
							add eax,[secPtrToRawData]
							mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
							add [item],1
							
							; find which delay_descriptor struct have smallest rva addresses ( lookup table and address table )											
							stdcall ProcessDelayImportDescriptor,eax
							; process imports for infos			
							; get proper virtual address and pointer to data if needed <<<<<<-----							
							mov edx,[ptrFilePeInfo]
							mov edx,[edx+sFILE_PE_INFO.numOfDelayImports]			
							mov [numOfImports],edx		
																	
							mov esi,[ptrDelayName]
							mov edi,[ptrDelayAddress]
							xor ecx,ecx
			.loop3:				
							cmp ecx,[numOfImports]
							je .next2
								
								.if dword[esi+sIMPORT_DESCRIPTOR.rvaAddressStart] <> 0																											
									push ecx																				
										stdcall GetSectionForTableRva,dword[esi+sIMPORT_DESCRIPTOR.rvaAddressStart],addr sRVA,addr sRawData
										.if	signed eax >= 0											
											pop ecx
												mov dword[esi+sIMPORT_DESCRIPTOR.inSectionNo],eax
												mov eax,[esi+sIMPORT_DESCRIPTOR.rvaAddressStart]
												sub eax,[sRVA]
												add eax,[sRawData]
												mov dword[esi+sIMPORT_DESCRIPTOR.fileAddressStart],eax
										
										.else
											; dont process to sort struct
											pop ecx
												mov dword[esi+sIMPORT_DESCRIPTOR.rvaAddressStart],0
												
										.endif																																																																							
									
									push ecx
										stdcall GetSectionForTableRva,dword[esi+sIMPORT_DESCRIPTOR.nameRva],addr sRVA,addr sRawData
										.if signed eax < 0
											pop ecx
												mov edx,[esi+sIMPORT_DESCRIPTOR.nameRva]
												mov dword[esi+sIMPORT_DESCRIPTOR.nameFile],edx
												
										.else
											pop ecx															
												mov edx,[esi+sIMPORT_DESCRIPTOR.nameRva]
												sub edx,[sRVA]
												add edx,[sRawData]
												mov dword[esi+sIMPORT_DESCRIPTOR.nameFile],edx
											
										.endif																			
									
								.endif
								
								.if dword[edi+sIMPORT_DESCRIPTOR.rvaAddressStart] <> 0																		
									push ecx
										stdcall GetSectionForTableRva,dword[edi+sIMPORT_DESCRIPTOR.rvaAddressStart],addr sRVA,addr sRawData
										.if	signed eax >= 0											
											pop ecx
												mov dword[edi+sIMPORT_DESCRIPTOR.inSectionNo],eax
												mov eax,[edi+sIMPORT_DESCRIPTOR.rvaAddressStart]
												sub eax,[sRVA]
												add eax,[sRawData]
												mov dword[edi+sIMPORT_DESCRIPTOR.fileAddressStart],eax
										
										.else
											; dont process to sort struct
											pop ecx
												mov dword[edi+sIMPORT_DESCRIPTOR.rvaAddressStart],0
												
										.endif											
																												
									push ecx
										stdcall GetSectionForTableRva,dword[edi+sIMPORT_DESCRIPTOR.nameRva],addr sRVA,addr sRawData
										.if signed eax < 0
											pop ecx
												mov edx,[edi+sIMPORT_DESCRIPTOR.nameRva]
												mov dword[edi+sIMPORT_DESCRIPTOR.nameFile],edx
												
										.else
											pop ecx															
												mov edx,[edi+sIMPORT_DESCRIPTOR.nameRva]
												sub edx,[sRVA]
												add edx,[sRawData]
												mov dword[edi+sIMPORT_DESCRIPTOR.nameFile],edx
											
										.endif	
									
								.endif
							
							inc ecx
							add esi,sizeof.sIMPORT_DESCRIPTOR
							add edi,sizeof.sIMPORT_DESCRIPTOR
							
							jmp .loop3		
			.next2:			
							; get rva address of the first delay import name table
							; check is there any and fill sort struct													
							mov esi,[ptrDelayName]
							.if dword[esi+sIMPORT_DESCRIPTOR.rvaAddressStart] <> 0	
								add ebx,sizeof.sSORT_ITEM_TYPE															
								mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO																
								mov eax,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
								mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
								mov edx,[esi+sIMPORT_DESCRIPTOR.rvaAddressStart]
								mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx				
								mov eax,[esi+sIMPORT_DESCRIPTOR.inSectionNo]
								mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
								add [item],1
												
							.endif	
							; get rva address of the first delay import address table
							; check is there any and fill sort struct
							mov esi,[ptrDelayAddress]
							.if dword[esi+sIMPORT_DESCRIPTOR.rvaAddressStart] <> 0
								add ebx,sizeof.sSORT_ITEM_TYPE								
								mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO																				
								mov eax,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
								mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
								mov edx,[esi+sIMPORT_DESCRIPTOR.rvaAddressStart]
								mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx					
								mov eax,[esi+sIMPORT_DESCRIPTOR.inSectionNo]		
								mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
								add [item],1
							
							.endif	
																						
							mov edx,[item]
							; next free sort struct
							add ebx,sizeof.sSORT_ITEM_TYPE
							mov eax,ebx	
							jmp .out
						
						.elseif [directoryType] = TREE_ITEM_DEBUG_DIRECTORY_ENTRY
							mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_DEBUG_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
							mov ecx,[i]
							mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx
							mov eax,[edi+sDATA_DIRECTORY_INFO.virtualAddress]
							mov edx,[edi+sDATA_DIRECTORY_INFO.size]
							mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
							mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],edx
							mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx
							; calc file start
							sub eax,[secRVA]
							add eax,[secPtrToRawData]
							mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
							; for later if needed
							mov [sRawData],eax	; address label for parsing debug directories 
							add [item],1
										
							; ALLOC MEM for debug directory struct
							invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,sizeof.sDEBUG_DIRECTORY
							mov [ptrDebugDirec],eax
							mov esi,eax
							; how many debug types there are in the file
							xor edx,edx
							mov eax,[edi+sDATA_DIRECTORY_INFO.size]
							mov ecx,sizeof.IMAGE_DEBUG_DIRECTORY
							div ecx
							mov dword[esi+sDEBUG_DIRECTORY.numOfTypesInFile],eax
							mov [numOfImports],eax																				
							; find them
							.if eax <> 0
								lea edi,[dataInfo]
								mov [i],0															
			.loop4:				
								mov ecx,[i]	
								cmp ecx,[numOfImports]	; count for num of debug types
								je .out4
																																												
									; get ptr to raw data
									stdcall GetData,edi,[sRawData],24,4
									push dword[edi]
									; get rva of data
									stdcall GetData,edi,[sRawData],20,4
									push dword[edi]
									; get size of data
									stdcall GetData,edi,[sRawData],16,4
									push dword[edi]
									; get type
									stdcall GetData,edi,[sRawData],12,4
									push dword[edi]					
									; args - debugType,size,rvaAddr,fileAddr									
									call SetDebugTypeInfos
									add esp,4*4
									
								inc [i]
								add [sRawData],sizeof.IMAGE_DEBUG_DIRECTORY
								jmp .loop4
			.out4:														
								stdcall SetDebugSortInfos
								add [item],eax
																								
							.endif							
																												
							mov edx,[item]
							; next free sort struct
							add ebx,sizeof.sSORT_ITEM_TYPE
							mov eax,ebx	
							jmp .out
						
						.elseif [directoryType] = TREE_ITEM_RESOURCE_DIRECTORY				
							; set resource directory table level 0
							mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_RESOURCE_DIRECTORY or TREE_ITEM_DATA_INFO							
							mov ecx,[i]
							mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx
							mov eax,[edi+sDATA_DIRECTORY_INFO.virtualAddress]							
							mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],eax
							; calc file start
							sub eax,[secRVA]
							add eax,[secPtrToRawData]				
							mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax														
							add [item],1
										
							; level 0
							mov [j],0
							; ALLOC MEM - start resource directory 0
							invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,sizeof.sRESOURCE_DIRECTORY
							mov [ptrResource],eax
							mov esi,eax																										
							; set level 0
							mov dword[esi+sRESOURCE_DIRECTORY.level],0
							
							; save start address of the root
							mov ecx,[ebx+sSORT_ITEM_TYPE.rvaAddress]
							mov dword[esi+sRESOURCE_DIRECTORY.addressRva],ecx
							mov [sRVA],ecx
							mov edx,[ebx+sSORT_ITEM_TYPE.fileAddress]							
							mov dword[esi+sRESOURCE_DIRECTORY.addressFile],edx
							mov [sRawData],edx														
							
							; save address of the entries		
							add edx,sizeof.IMAGE_RESOURCE_DIRECTORY
							mov dword[esi+sRESOURCE_DIRECTORY.startAddressEntries],edx							
											
							; get num of name and id entries , if any																	
							lea edi,[dataInfo]							
							stdcall GetData,edi,dword[esi+sRESOURCE_DIRECTORY.addressFile],12,2
							movzx edx,word[edi]
							mov dword[esi+sRESOURCE_DIRECTORY.numOfEntries],edx							
							
							stdcall GetData,edi,dword[esi+sRESOURCE_DIRECTORY.addressFile],14,2
							movzx eax,word[edi]
							add dword[esi+sRESOURCE_DIRECTORY.numOfEntries],eax
																																																																			
							.if dword[esi+sRESOURCE_DIRECTORY.numOfEntries] <> 0
								
								; ALLOC MEM for directory entries
								mov edx,[esi+sRESOURCE_DIRECTORY.numOfEntries]
								imul edx,sizeof.sRESOURCE_ENTRY
								invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
								mov dword[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries],eax
								
								; parse RESOURCE DIRECTORY ENTRIES											
								stdcall GetDirectoryEntriesInfo,esi,[sRawData],[sRVA],[j]					
								
							.endif		
							
							; RESOURCE SUBLEVELS
																					
							; is there a level down , esi is ptrtores
							; check and get first ptr to subdirectory
							xor ecx,ecx
			.loop5:					
							mov edi,[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries]							
					
							cmp ecx,[esi+sRESOURCE_DIRECTORY.numOfEntries]
							je .out5
								
								.if dword[edi+sRESOURCE_ENTRY.subDirectoryFile] <> 0
									; level down found																	
									; prev size of sort array
									invoke HeapSize,[hHeapObject],0,[ptrSortItem]									
									add eax,sizeof.sSORT_ITEM_TYPE
									; ALLOC MEM new size of sort array
									invoke HeapReAlloc,[hHeapObject],HEAP_ZERO_MEMORY,[ptrSortItem],eax										
									mov [ptrSortItem],eax
									mov ebx,eax
									add [numOfSortItemAlloc],1
									; find first free sort struct
				.loop6:					
									.if dword[ebx+sSORT_ITEM_TYPE.treeItemType] = 0										
										jmp .out6
										
									.endif										
									
									add ebx,sizeof.sSORT_ITEM_TYPE
									jmp .loop6																			
				.out6:																										
									; get directory table pointer
									mov esi,[edi+sRESOURCE_ENTRY.ptrSubDirectory]
									; start of level down directory table
									mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_RESOURCE_DIRECTORY or TREE_ITEM_DATA_INFO
									mov ecx,[i]
									mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx
									mov eax,[esi+sRESOURCE_DIRECTORY.addressFile]
									mov edx,[esi+sRESOURCE_DIRECTORY.addressRva]
									mov ecx,[esi+sRESOURCE_DIRECTORY.level]							
									mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
									mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
									; save level of the directory table into rvasize element
									mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],ecx																															
									add [item],1									
									xor ecx,ecx
									
								.else
									inc ecx	
									add edi,sizeof.sRESOURCE_ENTRY									
									
								.endif										
													
							jmp .loop5
			.out5:							
							; RESOURCE STRINGS
										
							mov [sRawData],0		; file address
							mov [sRVA],0			; rva address
							mov [numOfSections],0	; size
							stdcall GetDirectoryStringInfo,[ptrResource],addr sRawData,addr sRVA,addr numOfSections							
							.if [sRawData] <> 0
								; set resource directory string
								; prev size of sort array
								invoke HeapSize,[hHeapObject],0,[ptrSortItem]									
								add eax,sizeof.sSORT_ITEM_TYPE
								; ALLOC MEM new size of sort array
								invoke HeapReAlloc,[hHeapObject],HEAP_ZERO_MEMORY,[ptrSortItem],eax										
								mov [ptrSortItem],eax
								mov ebx,eax
								add [numOfSortItemAlloc],1
								; find first free sort struct
			.loop7:									
								.if dword[ebx+sSORT_ITEM_TYPE.treeItemType] = 0										
									jmp .out7
									
								.endif										
								
								add ebx,sizeof.sSORT_ITEM_TYPE
								jmp .loop7																			
			.out7:				
								mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_RESOURCE_DIRECTORY_STRING or TREE_ITEM_DATA_RAW
								mov ecx,[i]
								mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx
								mov eax,[sRawData]
								mov edx,[sRVA]
								mov ecx,[numOfSections]
								mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
								mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
								mov dword[ebx+sSORT_ITEM_TYPE.fileSize],ecx
								add [item],1
								
							.endif
							
							; RESOURCE DATA ENTRY
														
							mov [sRawData],0		; file address
							mov [sRVA],0			; rva address
							mov [numOfSections],0	; count , 1 based				
							stdcall GetDirectoryDataEntryInfo,[ptrResource],addr sRawData,addr sRVA,addr numOfSections
							.if [numOfSections] <> 0
								; set resource directory data entry
								; prev size of sort array
								invoke HeapSize,[hHeapObject],0,[ptrSortItem]									
								add eax,sizeof.sSORT_ITEM_TYPE
								; ALLOC MEM new size of sort array
								invoke HeapReAlloc,[hHeapObject],HEAP_ZERO_MEMORY,[ptrSortItem],eax										
								mov [ptrSortItem],eax
								mov ebx,eax
								add [numOfSortItemAlloc],1
								; find first free sort struct
			.loop8:									
								.if dword[ebx+sSORT_ITEM_TYPE.treeItemType] = 0										
									jmp .out8
									
								.endif										
								
								add ebx,sizeof.sSORT_ITEM_TYPE
								jmp .loop8																			
			.out8:				
								mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_RESOURCE_DIRECTORY_DATA_ENTRY or TREE_ITEM_DATA_INFO
								mov ecx,[i]
								mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],ecx				
								mov eax,[sRawData]
								mov edx,[sRVA]
								mov ecx,[numOfSections]
								mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
								mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
								mov dword[ebx+sSORT_ITEM_TYPE.fileSize],ecx		; total count of data entry saved here 
								add [item],1
													
								; RESOURCE DATA OBJECT
								; check how many data objects points to a section with sizeofrawdata > 0
								lea edi,[dataInfo]
								mov [j],0
								mov [k],0								
								xor ecx,ecx			
			.loop9:					
								mov edx,[j]
								cmp edx,[numOfSections]
								je .out9
									stdcall GetResourceDataEntry,[ptrResource],[j]
									mov esi,eax
									; get datarva
									stdcall GetData,edi,dword[esi+sRESOURCE_ENTRY.data.addressFile],0,4
									; check data rva
									stdcall GetSectionForTableRva,dword[edi],0,0
									.if signed eax >= 0										
										inc [k]																																						
										
									.endif
									mov dword[esi+sRESOURCE_ENTRY.data.inSection],eax
														
								inc [j]
								jmp .loop9
			.out9:												
								mov esi,[k]
								; update total size data
								add [numOfSortItemAlloc],esi									
								imul esi,sizeof.sSORT_ITEM_TYPE
								; get prev size of sort struct
								invoke HeapSize,[hHeapObject],0,[ptrSortItem]
								add eax,esi
								; ALLOC MEM for new size
								invoke HeapReAlloc,[hHeapObject],HEAP_ZERO_MEMORY,[ptrSortItem],eax
								mov [ptrSortItem],eax
								mov ebx,eax
								; find first free sort struct
			.loop10:									
								.if dword[ebx+sSORT_ITEM_TYPE.treeItemType] = 0										
									jmp .out10
									
								.endif										
								
								add ebx,sizeof.sSORT_ITEM_TYPE
								jmp .loop10																			
			.out10:				
								; process data objects			
								mov [j],0
			.loop11:					
								mov ecx,[j]
								cmp ecx,[numOfSections]
								je .out11
									
									stdcall GetResourceDataEntry,[ptrResource],[j]
									; is it points anywhere
									mov edx,dword[eax+sRESOURCE_ENTRY.data.inSection]
									.if signed edx < 0
										jmp .next3
										
									.endif									
									; esi is a ptr to resource data entry
									mov esi,eax																																													
									mov [sRVA],0
									mov [sRawData],0									
									; set sort struct
									mov dword[ebx+sSORT_ITEM_TYPE.treeItemType],TREE_ITEM_RESOURCE_DATA_OBJECT or TREE_ITEM_DATA_RAW									
									; get data rva info
									stdcall GetData,edi,dword[esi+sRESOURCE_ENTRY.data.addressFile],0,4
									; get section for resource object
									stdcall GetSectionForTableRva,dword[edi],addr sRVA,addr sRawData
									mov dword[ebx+sSORT_ITEM_TYPE.inSectionNo],eax
									mov edx,[edi]	; data rva
									mov eax,edx
									sub eax,[sRVA]
									add eax,[sRawData]
									mov dword[ebx+sSORT_ITEM_TYPE.fileAddress],eax
									mov dword[ebx+sSORT_ITEM_TYPE.rvaAddress],edx
									; get raw data size
									stdcall GetData,edi,dword[esi+sRESOURCE_ENTRY.data.addressFile],4,4
									mov edx,[edi]
									mov dword[ebx+sSORT_ITEM_TYPE.fileSize],edx 
									; save index to rva size field
									mov eax,[esi+sRESOURCE_ENTRY.data.index]
									; start from zero
									sub eax,1
									mov dword[ebx+sSORT_ITEM_TYPE.rvaSize],eax																											
									add [item],1	
									add ebx,sizeof.sSORT_ITEM_TYPE
				.next3:								
								inc [j]								
								jmp .loop11							
			.out11:												
							.endif		; resource data entry check
																														
							mov edx,[item]
							; next free sort struct
							;add ebx,sizeof.sSORT_ITEM_TYPE							
							mov eax,ebx	
							jmp .out
												
						.endif	; check for data directory
						
					.endif
					
				inc [i]
				add esi,sizeof.sSEC_HEADER_INFO
				jmp .loop
														
	.out_err:	
				xor edx,edx
				xor eax,eax		
	.out:			
				ret
			endp
			
			proc GetDirectoryDataEntryInfo uses ebx esi edi,ptrRes,fileAddr,rvaAddr,count
				
				locals										
					numOfEntries	dd	0
					i	dd	0
				endl
				mov esi,[ptrRes]
				
				.if dword[esi+sRESOURCE_DIRECTORY.numOfEntries] <> 0
					mov edx,[esi+sRESOURCE_DIRECTORY.numOfEntries]
					mov [numOfEntries],edx
					mov edi,[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries]
	.loop:				
					mov ecx,[i]
					cmp ecx,[numOfEntries]
					je .out
						
						; do we have subdirectory or data entry
						.if dword[edi+sRESOURCE_ENTRY.data.addressFile] <> 0
							; data entry
											
							mov ebx,[fileAddr]
							mov eax,[ebx]
							
							.if eax = 0
								; first data entry , just copy					
								mov edx,[edi+sRESOURCE_ENTRY.data.addressFile]
								mov dword[ebx],edx
								mov edx,[edi+sRESOURCE_ENTRY.data.addressRva]
								mov ebx,[rvaAddr]
								mov dword[ebx],edx							
								mov ebx,[count]
								add dword[ebx],1
								; save count as index to data entry					
								mov ecx,[ebx]
								mov dword[edi+sRESOURCE_ENTRY.data.index],ecx
								
							.else																								
								mov ebx,[count]
								add dword[ebx],1
								; save count as index to data entry					
								mov ecx,[ebx]
								mov dword[edi+sRESOURCE_ENTRY.data.index],ecx
								
							.endif
							
						.endif
						; do we have subdirectory
						.if dword[edi+sRESOURCE_ENTRY.ptrSubDirectory] <> 0
							; check 
							stdcall GetDirectoryDataEntryInfo,dword[edi+sRESOURCE_ENTRY.ptrSubDirectory],[fileAddr],[rvaAddr],[count]
						
						.endif
								
					inc [i]
					add edi,sizeof.sRESOURCE_ENTRY
					jmp .loop
	.out:			
							
				.endif
				
				ret
			endp
			
			proc GetDirectoryStringInfo uses ebx esi edi,ptrRes,fileAddr,rvaAddr,size
				
				locals										
					numOfEntries	dd	0
					i	dd	0
				endl
				mov esi,[ptrRes]
				
				.if dword[esi+sRESOURCE_DIRECTORY.numOfEntries] <> 0
					mov edx,[esi+sRESOURCE_DIRECTORY.numOfEntries]
					mov [numOfEntries],edx
					mov edi,[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries]
	.loop:				
					mov ecx,[i]
					cmp ecx,[numOfEntries]
					je .out
						
						; do we have ID or name entry
						.if dword[edi+sRESOURCE_ENTRY.name.size] <> 0
							; name
											
							mov ebx,[fileAddr]
							mov eax,[ebx]
							
							.if eax = 0
								; first entry , just copy
								mov edx,[edi+sRESOURCE_ENTRY.name.addressFile]
								mov dword[ebx],edx
								mov edx,[edi+sRESOURCE_ENTRY.name.addressRva]
								mov ebx,[rvaAddr]
								mov dword[ebx],edx
								mov edx,[edi+sRESOURCE_ENTRY.name.size]
								shl edx,1
								mov ebx,[size]
								add dword[ebx],edx
								
							.else
								; just add size
								mov edx,[edi+sRESOURCE_ENTRY.name.size]
								shl edx,1
								mov ebx,[size]
								add dword[ebx],edx
								
							.endif
							
						.endif
						; do we have subdirectory
						.if dword[edi+sRESOURCE_ENTRY.ptrSubDirectory] <> 0
							; check 
							stdcall GetDirectoryStringInfo,dword[edi+sRESOURCE_ENTRY.ptrSubDirectory],[fileAddr],[rvaAddr],[size]
						
						.endif
								
					inc [i]
					add edi,sizeof.sRESOURCE_ENTRY
					jmp .loop
	.out:			
							
				.endif				
				
				ret
			endp
			
			proc GetDirectoryEntriesInfo uses ebx esi edi,ptrResDirec,addrOfRes0,addrOfRes0Rva,level
				
				locals
					ptrResIDtable	dd	0
					prevSize		dd	0
					direcAddress	dd	0
					numOfEntries	dd	0
					addrOfEntries	dd	0
					len				dd	0
					i	dd	0
					dataInfo db 4 dup 0
					resDirecText	du	42 dup 0
					temp du 42 dup 0
				endl
				
				mov ebx,[ptrResDirec]
				mov eax,[ebx+sRESOURCE_DIRECTORY.numOfEntries]
				mov [numOfEntries],eax
				mov edx,[ebx+sRESOURCE_DIRECTORY.startAddressEntries]
				mov [addrOfEntries],edx
				lea esi,[ebx+sRESOURCE_DIRECTORY.text]
				invoke lstrlenW,esi
				.if eax <> 0					
					push eax
						add eax,1
						invoke lstrcpynW,addr resDirecText,esi,eax
					pop eax
					shl eax,1
					lea esi,[resDirecText]
					; pad
					add esi,eax
					mov word[esi],' '
					add esi,2
					mov word[esi],0
					
				.endif				
				mov ebx,[ebx+sRESOURCE_DIRECTORY.ptrDirectoryEntries]							
				
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,576
				mov [ptrResIDtable],eax
				invoke LoadStringW,<invoke GetModuleHandleW,0>,RESOURCE_ID_STRING_TABLE,[ptrResIDtable],576
				lea edi,[dataInfo]
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfEntries]
				je .out
					
					; reset temp memory
					invoke RtlZeroMemory,addr temp,42*2
					
					; level
					mov eax,[level]
					mov dword[ebx+sRESOURCE_ENTRY.level],eax
					
					stdcall GetData,edi,[addrOfEntries],0,4
					mov edx,[edi]
					test edx,0x80000000
					.if ZERO?
						; integer ID - that identify this resource directory entry												
						mov dword[ebx+sRESOURCE_ENTRY.integerID],edx
						
						.if [level] = 0
							; ID represent resource type													
							stdcall GetTextForResourceID,edx
							mov esi,[ptrResIDtable]
							shl edx,1
							add esi,edx
							add eax,1
							invoke lstrcpynW,addr temp,esi,eax
								
						.else
							; word size resource ID
							mov eax,edx
							stdcall ConvertHexWordToStringU,eax,addr temp
							
						.endif
												
						
					.else
						; nameRVA - offset to IMAGE_RESOURCE_DIRECTORY_STRING		0x7FFFFFFF				
						and edx,0x7FFFFFFF
						mov eax,edx
						add eax,[addrOfRes0Rva]
						mov dword[ebx+sRESOURCE_ENTRY.name.addressRva],eax
						add edx,[addrOfRes0]
						mov dword[ebx+sRESOURCE_ENTRY.name.addressFile],edx
						push edx
							stdcall GetData,edi,edx,0,2
							movzx eax,word[edi]
							; save len
							add eax,1
							mov [len],eax
						pop edx
						; save len ( unicode size )
						mov dword[ebx+sRESOURCE_ENTRY.name.size],eax
						; skip len
						add edx,2
						stdcall CopyStringWtoW,addr temp,edx,[len]
						
					.endif
					
					; name for the entry
					lea esi,[ebx+sRESOURCE_ENTRY.text]
					invoke lstrcatW,esi,addr resDirecText
					invoke lstrcatW,esi,addr temp
					
					stdcall GetData,edi,[addrOfEntries],4,4
					mov edx,[edi]
					test edx,0x80000000
					.if ZERO?
						; data entry RVA - IMAGE_RESOURCE_DATA_ENTRY   
						mov eax,edx
						add eax,[addrOfRes0Rva]  
						mov dword[ebx+sRESOURCE_ENTRY.data.addressRva],eax
						add edx,[addrOfRes0]					
						mov dword[ebx+sRESOURCE_ENTRY.data.addressFile],edx												
						
					.else
						; subdirectory RVA 			0x7FFFFFFF
						and edx,0x7FFFFFFF
						mov eax,edx
						add eax,[addrOfRes0Rva]
						mov dword[ebx+sRESOURCE_ENTRY.subDirectoryRva],eax
						add edx,[addrOfRes0]
						mov dword[ebx+sRESOURCE_ENTRY.subDirectoryFile],edx
						; ALLOC MEM for level down directory table
						invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,sizeof.sRESOURCE_DIRECTORY
						mov dword[ebx+sRESOURCE_ENTRY.ptrSubDirectory],eax
						mov esi,eax
						; set name
						push edi
							lea edi,[esi+sRESOURCE_DIRECTORY.text]
							lea eax,[ebx+sRESOURCE_ENTRY.text]
							invoke lstrcatW,edi,eax
						pop edi
						; set info for directory table
						mov edx,[level]
						add edx,1
						mov dword[esi+sRESOURCE_DIRECTORY.level],edx
						mov edx,[ebx+sRESOURCE_ENTRY.subDirectoryRva]
						mov eax,[ebx+sRESOURCE_ENTRY.subDirectoryFile]
						mov dword[esi+sRESOURCE_DIRECTORY.addressRva],edx
						mov dword[esi+sRESOURCE_DIRECTORY.addressFile],eax
						add eax,sizeof.IMAGE_RESOURCE_DIRECTORY				
						mov dword[esi+sRESOURCE_DIRECTORY.startAddressEntries],eax
										
						; check for data entries
						stdcall GetData,edi,dword[esi+sRESOURCE_DIRECTORY.addressFile],12,2
						movzx edx,word[edi]
						push edx
							stdcall GetData,edi,dword[esi+sRESOURCE_DIRECTORY.addressFile],14,2
						pop edx						
						movzx eax,word[edi]
						add edx,eax
						mov dword[esi+sRESOURCE_DIRECTORY.numOfEntries],edx
						
						.if dword[esi+sRESOURCE_DIRECTORY.numOfEntries] <> 0
							; ALLOC MEM for directory entries								
							imul edx,sizeof.sRESOURCE_ENTRY
							invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,edx
							mov dword[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries],eax
							
							; parse directory entries	
							stdcall GetDirectoryEntriesInfo,esi,[addrOfRes0],[addrOfRes0Rva],dword[esi+sRESOURCE_DIRECTORY.level]
							
						.endif
						
						
					.endif												
				
				inc [i]
				add [addrOfEntries],8
				add ebx,sizeof.sRESOURCE_ENTRY
				
				jmp .loop		
	.out:			
						
				invoke HeapFree,[hHeapObject],0,[ptrResIDtable]
				
				ret
			endp											
			
			proc ProcessingDataDirectories uses ebx esi edi,index
				
				locals
					i	dd	0
				endl
				
				; ecx is a counter for loop
				xor ecx,ecx
				mov esi,[ptrDataDirecInfo]
				mov ebx,[ptrSortItem]
				add ebx,[index]
				
	.loop:			
				cmp ecx,15
				je .out
					; Export Directory
					.if ecx = 0				
						.if dword[esi+sDATA_DIRECTORY_INFO.virtualAddress] <> 0 & dword[esi+sDATA_DIRECTORY_INFO.size] <> 0				
							push ecx														
								stdcall DataDirectoryPointsToSection,TREE_ITEM_EXPORT_DIRECTORY_ENTRY,esi,ebx
								.if eax = 0 & edx = 0													
									pop ecx					
									jmp .next
									
								.endif	
								mov ebx,eax
								add [i],edx
							pop ecx
							
						.endif
						
					; Import Directory
					.elseif ecx = 1				
						.if dword[esi+sDATA_DIRECTORY_INFO.virtualAddress] <> 0 & dword[esi+sDATA_DIRECTORY_INFO.size] <> 0					
							push ecx														
								stdcall DataDirectoryPointsToSection,TREE_ITEM_IMPORT_DIRECTORY_ENTRY,esi,ebx
								.if eax = 0 & edx = 0					
									pop ecx					
									jmp .next
									
								.endif	
								mov ebx,eax
								add [i],edx
							pop ecx
							
						.endif
					
					; Resource Directory
					.elseif ecx = 2
						.if dword[esi+sDATA_DIRECTORY_INFO.virtualAddress] <> 0 & dword[esi+sDATA_DIRECTORY_INFO.size] <> 0					
							push ecx														
								stdcall DataDirectoryPointsToSection,TREE_ITEM_RESOURCE_DIRECTORY,esi,ebx
								.if eax = 0 & edx = 0					
									pop ecx					
									jmp .next
									
								.endif	
								mov ebx,eax
								add [i],edx
							pop ecx
							
						.endif
						
					; Certificate Table
					.elseif ecx = 4
						.if dword[esi+sDATA_DIRECTORY_INFO.virtualAddress] <> 0 & dword[esi+sDATA_DIRECTORY_INFO.size] <> 0
							push ecx				
								stdcall DataDirectoryPointsOutsideSection,TREE_ITEM_CERTIFICATE_TABLE,esi,ebx								
								mov ebx,eax
								add [i],edx
							pop ecx
							
						.endif
					; Base Relocation Directory
					.elseif ecx = 5
						.if dword[esi+sDATA_DIRECTORY_INFO.virtualAddress] <> 0 & dword[esi+sDATA_DIRECTORY_INFO.size] <> 0
							push ecx
								stdcall DataDirectoryPointsToSection,TREE_ITEM_IMAGE_BASE_RELOCATION,esi,ebx
								.if eax = 0 & edx = 0					
									pop ecx					
									jmp .next
									
								.endif	
								mov ebx,eax
								add [i],edx
							pop ecx
							
						.endif
						
					; Debug Directory
					.elseif ecx = 6
						.if dword[esi+sDATA_DIRECTORY_INFO.virtualAddress] <> 0 & dword[esi+sDATA_DIRECTORY_INFO.size] <> 0
							push ecx
								stdcall DataDirectoryPointsToSection,TREE_ITEM_DEBUG_DIRECTORY_ENTRY,esi,ebx
								.if eax = 0 & edx = 0
									stdcall DataDirectoryPointsOutsideSection,TREE_ITEM_DEBUG_DIRECTORY_ENTRY,esi,ebx
									
								.endif								
								mov ebx,eax
								add [i],edx								
							pop ecx
							
						.endif
						
					; TlS Directory
					.elseif ecx = 9
						.if dword[esi+sDATA_DIRECTORY_INFO.virtualAddress] <> 0 & dword[esi+sDATA_DIRECTORY_INFO.size] <> 0
							push ecx																			
								stdcall DataDirectoryPointsToSection,TREE_ITEM_TLS_DIRECTORY,esi,ebx
								.if eax = 0 & edx = 0					
									pop ecx					
									jmp .next
									
								.endif	
								mov ebx,eax
								add [i],edx
							pop ecx
						.endif
						
					; Load Configuration Directory
					.elseif ecx = 10
						.if dword[esi+sDATA_DIRECTORY_INFO.virtualAddress] <> 0 & dword[esi+sDATA_DIRECTORY_INFO.size] <> 0
							push ecx														
								stdcall DataDirectoryPointsToSection,TREE_ITEM_LOAD_CONFIGURATION,esi,ebx
								.if eax = 0 & edx = 0					
									pop ecx					
									jmp .next
									
								.endif	
								mov ebx,eax
								add [i],edx
							pop ecx
						.endif
						
					; Bound Import Directory
					.elseif ecx = 11
						.if dword[esi+sDATA_DIRECTORY_INFO.virtualAddress] <> 0 & dword[esi+sDATA_DIRECTORY_INFO.size] <> 0
							push ecx
								stdcall DataDirectoryPointsOutsideSection,TREE_ITEM_BOUND_DIRECTORY_ENTRY,esi,ebx
								mov ebx,eax
								add [i],edx
							pop ecx
							
						.endif
					
					; Delay-Load Directory
					.elseif ecx = 13			
						.if dword[esi+sDATA_DIRECTORY_INFO.virtualAddress] <> 0 & dword[esi+sDATA_DIRECTORY_INFO.size] <> 0
							push ecx
								stdcall DataDirectoryPointsToSection,TREE_ITEM_DELAY_LOAD_DIRECTORY_ENTRY,esi,ebx
								.if eax = 0 & edx = 0					
									pop ecx					
									jmp .next
									
								.endif	
								mov ebx,eax
								add [i],edx
							pop ecx
							
						.endif	
						
					.endif
	.next:				
					add esi,sizeof.sDATA_DIRECTORY_INFO
					inc ecx
									
				jmp .loop
	.out:		
				mov eax,[i]	
				ret
			endp
			
section '.data' data readable writeable
	ptrImportNames	dd	0
	ptrImportAddress	dd	0
	ptrExportDirec	dd	0
	ptrDelayAddress		dd	0
	ptrDelayName	dd	0		
	ptrDebugDirec		dd	0
	ptrResource		dd	0		
			
			
			
			
			
			
			
			
			
;			