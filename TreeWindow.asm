format MS COFF
include 'win32wxp.inc'

include 'extrndef.inc'
include 'kernel32.inc'
include 'user32.inc'

include 'pe.inc'
include 'resource.inc'

include 'filetype.inc'
include 'treeandsorttype.inc'
include 'petype.inc'

ID_TREEWINDOW	=	50002

public ID_TREEWINDOW
public CreateTreeWindow as '_CreateTreeWindow@4'
public CloseTreeWindow as '_CloseTreeWindow@0'
public ProcessingTreeViewElements as '_ProcessingTreeViewElements@4'
public ProcessingTreeViewNotifyMsg as '_ProcessingTreeViewNotifyMsg@4'
public InsertionSort as '_InsertionSort@12'

extrn 'hTreeWindow' as hTreeWindow:dword
extrn 'hHeapObject' as hHeapObject:dword
extrn 'numOfTVItemAlloc' as numOfTVItemAlloc:dword
extrn 'numOfSortItemAlloc' as numOfSortItemAlloc:dword
extrn 'ptrFileBaseInfo' as ptrFileBaseInfo:dword
extrn 'ptrFilePeInfo' as ptrFilePeInfo:dword
extrn 'ptrSecHeaderInfo' as ptrSecHeaderInfo:dword
extrn 'ptrDataDirecInfo' as ptrDataDirecInfo:dword
extrn 'ptrSortItem' as ptrSortItem:dword
extrn 'ptrTreeViewItem' as ptrTreeViewItem:dword
extrn 'ptrImportNames' as ptrImportNames:dword
extrn 'ptrImportAddress' as ptrImportAddress:dword
extrn 'ptrExportDirec' as ptrExportDirec:dword
extrn 'ptrDelayAddress' as ptrDelayAddress:dword
extrn 'ptrDelayName' as ptrDelayName:dword
extrn 'ptrDebugDirec' as ptrDebugDirec:dword
extrn 'ptrResource' as ptrResource:dword

extrn '_GetData@16' as GetData:dword
extrn '_CopyMemoryB@12' as CopyMemoryB:dword
extrn '_SetScrollInfoForNewTreeItem@0' as SetScrollInfoForNewTreeItem:dword
extrn '_LoadScrollInfoForNewTreeItem@4' as LoadScrollInfoForNewTreeItem:dword
extrn '_SaveScrollInfoOfOldTreeItem@4' as SaveScrollInfoOfOldTreeItem:dword
extrn '_ProcessingPeHeaders@0' as ProcessingPeHeaders:dword
extrn '_ProcessingMSCoffHeaders@0' as ProcessingMSCoffHeaders:dword
extrn '_ProcessingSections@4' as ProcessingSections:dword
extrn '_ProcessingDataDirectories@4' as ProcessingDataDirectories:dword
extrn '_ProcessingMSCoffData@4' as ProcessingMSCoffData:dword
extrn '_GetResourceDataEntry@8' as GetResourceDataEntry:dword

section '.code' code readable executable
						
			proc GetTextForTreeItem uses ebx esi edi,treeItemType,offset,len
				
				; itemType size = 43
				locals
					itemType	dd		TREE_ITEM_IMAGE_DOS_HEADER or TREE_ITEM_DATA_INFO,TREE_ITEM_MSDOS_STUB or TREE_ITEM_DATA_RAW,TREE_ITEM_IMAGE_NT_HEADERS or TREE_ITEM_DATA_RAW,TREE_ITEM_SIGNATURE or TREE_ITEM_DATA_INFO,TREE_ITEM_IMAGE_FILE_HEADER or TREE_ITEM_DATA_INFO,\
										TREE_ITEM_IMAGE_OPTIONAL_HEADER or TREE_ITEM_DATA_INFO,TREE_ITEM_BOUND_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO,TREE_ITEM_BOUND_DLLS_NAMES or TREE_ITEM_DATA_RAW,TREE_ITEM_IMPORT_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO,TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO,\
										TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO,TREE_ITEM_EXPORT_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO,TREE_ITEM_EXPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO,TREE_ITEM_EXPORT_NAME_PTR_TABLE or TREE_ITEM_DATA_INFO,TREE_ITEM_EXPORT_ORDINAL_TABLE or TREE_ITEM_DATA_INFO,\
										TREE_ITEM_DEBUG_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO,TREE_ITEM_DEBUG_UNKNOWN_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_COFF_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_CVIEW_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_FPO_TYPE or TREE_ITEM_DATA_INFO,\
										TREE_ITEM_DEBUG_MISC_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_EXCEPTION_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_FIXUP_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_OMAP_TO_S_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_OMAP_FROM_S_TYPE or TREE_ITEM_DATA_RAW,\
										TREE_ITEM_DEBUG_BORLAND_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_RESERVED10_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_CLSID_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_COFF_SYMBOLS_HEADER or TREE_ITEM_DATA_INFO,TREE_ITEM_COFF_SYMBOL_TABLE or TREE_ITEM_DATA_INFO,\
										TREE_ITEM_COFF_STRING_TABLE or TREE_ITEM_DATA_RAW,TREE_ITEM_COFF_LINE_NUMBERS or TREE_ITEM_DATA_INFO,TREE_ITEM_IMAGE_BASE_RELOCATION or TREE_ITEM_DATA_INFO,TREE_ITEM_LOAD_CONFIGURATION or TREE_ITEM_DATA_INFO,TREE_ITEM_TLS_DIRECTORY or TREE_ITEM_DATA_INFO,\
										TREE_ITEM_COFF_RELOCATIONS or TREE_ITEM_DATA_INFO,TREE_ITEM_CERTIFICATE_TABLE or TREE_ITEM_DATA_RAW,TREE_ITEM_DELAY_LOAD_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO,TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO,TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO,\
										TREE_ITEM_RESOURCE_DIRECTORY or TREE_ITEM_DATA_INFO,TREE_ITEM_RESOURCE_DIRECTORY_STRING or TREE_ITEM_DATA_RAW,TREE_ITEM_RESOURCE_DIRECTORY_DATA_ENTRY or TREE_ITEM_DATA_INFO										
										
					offsetType	dd		0,17,29,46,56,74,96,118,393,416,436,457,480,501,527,135,157,176,192,212,227,243,264,281,307,335,354,376,548,567,585,603,621,643,\
										668,688,704,722,749,776,800,825,851
					
					lenType		dd		16,11,16,9,17,21,21,16,22,19,20,22,20,25,20,21,18,15,19,14,15,20,16,25,27,18,21,16,18,17,17,17,21,24,19,15,17,26,26,23,24,\
										25,19					
					
				endl
				
				xor ecx,ecx
				
				lea ebx,[itemType]
				lea esi,[offsetType]
				lea edi,[lenType]
				
				mov edx,[treeItemType]								
	.loop:			
				cmp ecx,43
				je .out
					
					.if edx = [ebx+ecx*4]					
						mov edx,[offset]
						mov eax,[esi+ecx*4]
						mov dword[edx],eax
						
						mov edx,[len]
						mov eax,[edi+ecx*4]
						mov dword[edx],eax
						
						jmp .out
					
					.endif											
				
				inc ecx
				jmp .loop		
	.out:			
				ret
			endp			
			
			proc CreateTreeWindow hParent
				
				locals
					WC_TREEVIEWW	du	'SysTreeView32',0	
				endl
				
				invoke CreateWindowExW,0,addr WC_TREEVIEWW,0,WS_CHILD or WS_VISIBLE or TVS_HASLINES or TVS_HASBUTTONS or TVS_LINESATROOT,0,0,0,0,\
						[hParent],ID_TREEWINDOW,<invoke GetModuleHandleW,0>,0
				
				ret
			endp
			
			proc CloseTreeWindow
				
				invoke SendMessageW,[hTreeWindow],TVM_DELETEITEM,0,0
				
				ret
			endp
			
			proc AddItemToTreeView uses esi,hParent,text
				
				local tvi:TV_INSERTSTRUCT				
				
				lea esi,[tvi]
				invoke RtlZeroMemory,esi,sizeof.TV_INSERTSTRUCT
				
				mov dword[esi+TV_INSERTSTRUCT.hInsertAfter],TVI_LAST
				mov eax,[hParent]
				mov dword[esi+TV_INSERTSTRUCT.hParent],eax
				mov dword[esi+TV_INSERTSTRUCT.item.mask],TVIF_TEXT
				mov edx,[text]
				mov dword[esi+TV_INSERTSTRUCT.item.pszText],edx
				
				invoke SendMessageW,[hTreeWindow],TVM_INSERTITEMW,0,esi
				
				ret
			endp			
			
			proc InsertionSort uses ebx esi edi,ptrData,dataType,size
				
				local i:DWORD
				local j:DWORD
				local dataSize:DWORD
				local temp1:sSORT_ITEM_TYPE
				local temp2:IMAGE_IMPORT_DESCRIPTOR
				local temp3:DELAY_IMPORT_DESCRIPTOR
				
				.if [dataType] = 1
					lea ebx,[temp1]
					mov [dataSize],sizeof.sSORT_ITEM_TYPE
					
				.elseif [dataType] = 2
					lea ebx,[temp2]
					mov [dataSize],sizeof.IMAGE_IMPORT_DESCRIPTOR
					
				.elseif [dataType] = 3
					lea ebx,[temp3]
					mov [dataSize],sizeof.DELAY_IMPORT_DESCRIPTOR
					
				.endif								
				
				mov [i],1	
	.loop:			
				mov ecx,[i]
				cmp ecx,[size]
				je .out
					
					; j = i
					mov [j],ecx
					; while j>0 & [j] < [j-1]
	.inLoop:				
					cmp [j],0
					je .next
					; [j-1]
					mov eax,[j]
					sub eax,1
					imul eax,[dataSize]
					; [j]
					mov edx,[j]
					imul edx,[dataSize]
					; ptr to struct
					mov esi,[ptrData]	; [j-1]
					mov edi,[ptrData]	; [j]
					.if [dataType] = 1
						;				[j]												
						.if dword[edx+edi+sSORT_ITEM_TYPE.treeItemType] = TREE_ITEM_RESOURCE_DATA_OBJECT or TREE_ITEM_DATA_RAW
							;			[j-1]
							.if dword[eax+esi+sSORT_ITEM_TYPE.treeItemType]	= TREE_ITEM_SECTION_RAW or TREE_ITEM_DATA_RAW
																			
								mov ecx,[edx+edi+sSORT_ITEM_TYPE.inSectionNo]					
								
								.if dword[eax+esi+sSORT_ITEM_TYPE.inSectionNo] > ecx
									; copy , no matter of file address
									jmp .copy
									
								.endif								
								
							.endif
																																												
						.endif
																																		
						; get [j] address															
						mov ecx,[edx+edi+sSORT_ITEM_TYPE.fileAddress]																					
						; cmp [j] to [j-1] address
						cmp ecx,[eax+esi+sSORT_ITEM_TYPE.fileAddress]	
						jae .next															
						
					.elseif [dataType] = 2
						; get [j] 															
						mov ecx,[edx+edi+IMAGE_IMPORT_DESCRIPTOR.FirstThunk]																					
						; cmp [j] to [j-1]
						cmp ecx,[eax+esi+IMAGE_IMPORT_DESCRIPTOR.FirstThunk]	
						jae .next
						
					.elseif [dataType] = 3
						; get [j] 															
						mov ecx,[edx+edi+DELAY_IMPORT_DESCRIPTOR.DelayImportAddressTable]																					
						; cmp [j] to [j-1]
						cmp ecx,[eax+esi+DELAY_IMPORT_DESCRIPTOR.DelayImportAddressTable]	
						jae .next
						
					.endif	
	.copy:				
					; cpy [j-1] to temp
					mov eax,[j]
					sub eax,1
					imul eax,[dataSize]
					add eax,[ptrData]					
					stdcall CopyMemoryB,ebx,eax,[dataSize]
					; cpy [j] to [j-1]
					mov edx,[j]
					imul edx,[dataSize]
					add edx,[ptrData]
					mov eax,[j]
					sub eax,1
					imul eax,[dataSize]
					add eax,[ptrData]
					stdcall CopyMemoryB,eax,edx,[dataSize]
					; cpy temp to [j]
					mov edx,[j]					
					imul edx,[dataSize]
					add edx,[ptrData]
					stdcall CopyMemoryB,edx,ebx,[dataSize]
					
					dec [j]
					jmp .inLoop
						
	.next:
				inc [i]
				jmp .loop	
					
	.out:			
				ret
			endp
			
			proc GetPtrToTreeViewItem uses ebx,hItem
				
				locals
					i	dd	0
				endl
				
				.if [hItem] = 0
					xor eax,eax
					jmp .out
					
				.endif
				
				mov ebx,[ptrTreeViewItem]
	.loop:			
				mov ecx,[i]
				cmp ecx,[numOfTVItemAlloc]
				je .out
					
					mov edx,[ebx+sTREE_ITEM_TYPE.hTreeItem]
					.if edx = [hItem]
						mov eax,ebx
						jmp .out
						
					.endif
						
				inc [i]
				add ebx,sizeof.sTREE_ITEM_TYPE
				jmp .loop
	
	.out:			
				ret
			endp				
			
			proc ProcessingTreeViewNotifyMsg uses ebx esi edi,lParam
				
				locals
					ptrOldTreeItem	dd	0
					ptrNewTreeItem	dd	0					
				endl
				
				; lParam is a ptr to nm_treeview
				mov esi,[lParam]																		
				
				.if dword[esi+NM_TREEVIEW.hdr.code] = TVN_SELCHANGINGW										
					stdcall GetPtrToTreeViewItem,dword[esi+NM_TREEVIEW.itemOld.hItem]
					mov [ptrOldTreeItem],eax			
					stdcall GetPtrToTreeViewItem,dword[esi+NM_TREEVIEW.itemNew.hItem]
					mov [ptrNewTreeItem],eax
															
					stdcall SaveScrollInfoOfOldTreeItem,[ptrOldTreeItem]
					stdcall LoadScrollInfoForNewTreeItem,[ptrNewTreeItem]
					
				.elseif dword[esi+NM_TREEVIEW.hdr.code] = TVN_SELCHANGEDW
					stdcall GetPtrToTreeViewItem,dword[esi+NM_TREEVIEW.itemNew.hItem]
					stdcall SetScrollInfoForNewTreeItem				
					
				.endif				
						
				xor eax,eax			
				ret
			endp
			
			; args - ptrFilePeInfo , ptrSort
			align 4
			CopyAddressToTreeItem:
				
				mov edi,[esp+8]	; ptrSort
				mov esi,[esp+4]	; ptrFilePeInfo
				mov ecx,[esi+sFILE_PE_INFO.imageBase]
				
				mov eax,[edi+sSORT_ITEM_TYPE.fileAddress]
				mov dword[ebx+sTREE_ITEM_TYPE.address.file],eax
				mov edx,[edi+sSORT_ITEM_TYPE.rvaAddress]
				mov dword[ebx+sTREE_ITEM_TYPE.address.rva],edx
				add ecx,edx
				mov dword[ebx+sTREE_ITEM_TYPE.address.va],ecx								
				
			ret															
			
			proc ProcessingTreeViewItem uses ebx esi edi,treeItemType,hTreeParent,treeText,ptrSecHeader,ptrTree,ptrSort
				
				locals
					dbgTypes dd		TREE_ITEM_DEBUG_UNKNOWN_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_COFF_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_CVIEW_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_MISC_TYPE or TREE_ITEM_DATA_RAW,\
									TREE_ITEM_DEBUG_EXCEPTION_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_FIXUP_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_OMAP_TO_S_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_OMAP_FROM_S_TYPE or TREE_ITEM_DATA_RAW,\
									TREE_ITEM_DEBUG_BORLAND_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_RESERVED10_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_CLSID_TYPE or TREE_ITEM_DATA_RAW
									
					i	dd	0
					j	dd	0
					k	dd	0
					tmpl	du	'%ls',0
					dataInfo db 4 dup 0
					
				endl
				
				; save tree item type
				mov ebx,[ptrTree]
				mov edx,[treeItemType]
				mov dword[ebx+sTREE_ITEM_TYPE.treeItemType],edx																
						
				; check for data type	
				test edx,TREE_ITEM_DATA_RAW			
				.if ~ZERO?
					; DATA RAW					
					
					.if [treeItemType] = TREE_ITEM_ROOT or TREE_ITEM_DATA_RAW
						mov eax,[ptrFileBaseInfo]
						mov edx,[ptrFilePeInfo]	
						mov eax,[eax+sFILE_BASE_INFO.fileSize]
						mov edx,[edx+sFILE_PE_INFO.imageBase]
						
						mov dword[ebx+sTREE_ITEM_TYPE.address.file],0
						mov dword[ebx+sTREE_ITEM_TYPE.address.rva],0
						mov dword[ebx+sTREE_ITEM_TYPE.address.va],edx
						mov dword[ebx+sTREE_ITEM_TYPE.treeItemSize],eax
												
						xor edx,edx
						mov ecx,16						
						div ecx
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
						test edx,edx
						.if ~ZERO?
							add dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
							
						.endif										
						
					.elseif [treeItemType] = TREE_ITEM_MSDOS_STUB or TREE_ITEM_DATA_RAW
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov eax,[esi+sFILE_PE_INFO.stubSize]
						mov dword[ebx+sTREE_ITEM_TYPE.treeItemSize],eax
						
						xor edx,edx
						mov ecx,16						
						div ecx
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
						test edx,edx
						.if ~ZERO?
							add dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
							
						.endif	
						
					
					.elseif [treeItemType] = TREE_ITEM_IMAGE_NT_HEADERS or TREE_ITEM_DATA_RAW
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov dword[ebx+sTREE_ITEM_TYPE.treeItemSize],sizeof.IMAGE_NT_HEADERS32						
						mov eax,sizeof.IMAGE_NT_HEADERS32
						
						xor edx,edx
						mov ecx,16						
						div ecx
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
						test edx,edx
						.if ~ZERO?
							add dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
							
						.endif	
						
					.elseif [treeItemType] = TREE_ITEM_SECTION_RAW or TREE_ITEM_DATA_RAW
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov eax,[edi+sSORT_ITEM_TYPE.fileSize]
						mov dword[ebx+sTREE_ITEM_TYPE.treeItemSize],eax
						
						.if eax = 0				
							mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
						
						.else
							xor edx,edx
							mov ecx,16						
							div ecx
							mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
							test edx,edx
							.if ~ZERO?
								add dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
								
							.endif	
							
						.endif										
					
					.elseif [treeItemType] = TREE_ITEM_BOUND_DLLS_NAMES or TREE_ITEM_DATA_RAW						
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov eax,[edi+sSORT_ITEM_TYPE.fileSize]
						mov dword[ebx+sTREE_ITEM_TYPE.treeItemSize],eax
						
						xor edx,edx
						mov ecx,16						
						div ecx
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
						test edx,edx
						.if ~ZERO?
							add dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
							
						.endif	
					
					.elseif [treeItemType] = TREE_ITEM_CERTIFICATE_TABLE or TREE_ITEM_DATA_RAW
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov eax,[edi+sSORT_ITEM_TYPE.fileSize]
						mov dword[ebx+sTREE_ITEM_TYPE.treeItemSize],eax
						
						xor edx,edx
						mov ecx,16						
						div ecx
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
						test edx,edx
						.if ~ZERO?
							add dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
							
						.endif
					
					.elseif [treeItemType] = TREE_ITEM_COFF_STRING_TABLE or TREE_ITEM_DATA_RAW
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
											
						; get size of the string table
						stdcall GetData,addr dataInfo,dword[esi+sFILE_PE_INFO.ptrToStringTable],0,4
						lea eax,[dataInfo]
						mov eax,[eax]
						; sub size of this entry , it will not be printed
						sub eax,4
						mov dword[ebx+sTREE_ITEM_TYPE.treeItemSize],eax
						
						xor edx,edx
						mov ecx,16						
						div ecx
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
						test edx,edx
						.if ~ZERO?
							add dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
							
						.endif
					
					.elseif [treeItemType] = TREE_ITEM_RESOURCE_DIRECTORY_STRING or TREE_ITEM_DATA_RAW
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov eax,[edi+sSORT_ITEM_TYPE.fileSize]
						mov dword[ebx+sTREE_ITEM_TYPE.treeItemSize],eax
						
						xor edx,edx
						mov ecx,16						
						div ecx
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
						test edx,edx
						.if ~ZERO?
							add dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
							
						.endif
					
					.elseif [treeItemType] = TREE_ITEM_RESOURCE_DATA_OBJECT or TREE_ITEM_DATA_RAW	
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov eax,[edi+sSORT_ITEM_TYPE.fileSize]
						mov dword[ebx+sTREE_ITEM_TYPE.treeItemSize],eax
						
						xor edx,edx
						mov ecx,16						
						div ecx
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
						test edx,edx
						.if ~ZERO?
							add dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
							
						.endif	
						
					.else
						lea esi,[dbgTypes]						
						mov [k],11
						mov [i],0
		.loop10:				
						mov ecx,[i]
						cmp ecx,[k]
						je .out10
							
							mov edx,[esi+ecx*4]
							.if edx = [treeItemType]							
								jmp .out10
								
							.endif
						
						inc [i]
						jmp .loop10						
		.out10:			
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov eax,[edi+sSORT_ITEM_TYPE.fileSize]
						mov dword[ebx+sTREE_ITEM_TYPE.treeItemSize],eax
						
						.if eax = 0			
							mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
							
						.else						
							xor edx,edx
							mov ecx,16						
							div ecx
							mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
							test edx,edx
							.if ~ZERO?
								add dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
								
							.endif
							
						.endif																								
					
					.endif
					
				; 
				.else								
					; DATA INFO					
					
					.if [treeItemType] = TREE_ITEM_IMAGE_DOS_HEADER or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],31
						
					.elseif [treeItemType] = TREE_ITEM_SIGNATURE or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],1
						
					.elseif [treeItemType] = TREE_ITEM_IMAGE_FILE_HEADER or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov edx,[esi+sFILE_PE_INFO.numOfFlagsFileAttr]
						add edx,7
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],edx
						
					.elseif [treeItemType] = TREE_ITEM_IMAGE_OPTIONAL_HEADER or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov edx,[esi+sFILE_PE_INFO.numOfFlagsDllAttr]
						add edx,62
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],edx
						
					.elseif [treeItemType] = TREE_ITEM_IMAGE_SECTION_HEADER or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
											
						mov edx,[ptrSecHeader]
						; copy section header adderss to tree item struct
						mov dword[ebx+sTREE_ITEM_TYPE.ptrSecHeader],edx
						mov edx,[edx+sSEC_HEADER_INFO.numOfFlags]
						add edx,11
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],edx
						
					.elseif [treeItemType] = TREE_ITEM_IMPORT_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						; count number of lines
						; eax is file address , copy
						mov esi,eax
						lea edi,[dataInfo]
						xor ecx,ecx
		.loop:				
						push ecx
						; get ImportLookupTableRVA data
						stdcall GetData,edi,esi,0,4
						mov eax,[edi]
						push eax
						; get ImportAddressTableRVA data
						stdcall GetData,edi,esi,16,4
						mov edx,[edi]
						pop eax
						
						pop ecx
						;  5 lines per struct
						add ecx,5
						add esi,sizeof.IMAGE_IMPORT_DESCRIPTOR
						; last struct is filled with zeroes
						.if eax = 0 & edx = 0
							jmp .out
							
						.endif
						jmp .loop
		.out:			
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],ecx												
						
					.elseif [treeItemType] = TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO | [treeItemType] = TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO |\
							[treeItemType] = TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO | [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO
													
						mov edi,[ptrSort]
						mov esi,[ptrFilePeInfo]
						mov ecx,[esi+sFILE_PE_INFO.imageBase]
						.if [treeItemType] = TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO | [treeItemType] = TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO
							mov edx,[esi+sFILE_PE_INFO.numOfImports]
							
						.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO | [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO 
							mov edx,[esi+sFILE_PE_INFO.numOfDelayImports]
							
						.endif						
						mov [j],edx				
						
						mov eax,[edi+sSORT_ITEM_TYPE.fileAddress]
						mov dword[ebx+sTREE_ITEM_TYPE.address.file],eax
						mov edx,[edi+sSORT_ITEM_TYPE.rvaAddress]
						mov dword[ebx+sTREE_ITEM_TYPE.address.rva],edx
						add ecx,edx
						mov dword[ebx+sTREE_ITEM_TYPE.address.va],ecx
						
						; count lines of every import table
						; last entry is zero
						; copy first file address entry			
						xor ecx,ecx
						lea edi,[dataInfo]
						; i is counter for number of imports	
						mov [i],0
						.if [treeItemType] = TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO
							mov esi,[ptrImportNames]
							
						.elseif [treeItemType] = TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO
							mov esi,[ptrImportAddress]
						
						.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO
							mov esi,[ptrDelayName]
							
						.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO
							mov esi ,[ptrDelayAddress]
							
						.endif																		
						mov esi,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]						
		.loop2:			
						push ecx				
							stdcall GetData,edi,esi,0,4
						pop ecx
						mov eax,[edi]
						
						.if eax = 0
							inc [i]
							mov edx,[i]
							
							.if edx = [j]	; number of import tables
								; add last zero line and break the loop
								inc ecx
								jmp .out2
														
							.else
								; next import table
								.if [treeItemType] = TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO
									mov esi,[ptrImportNames]
									
								.elseif [treeItemType] = TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO
									mov esi,[ptrImportAddress]
								
								.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO
									mov esi,[ptrDelayName]
									
								.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO
									mov esi ,[ptrDelayAddress]
									
								.endif	
								imul edx,sizeof.sIMPORT_DESCRIPTOR
								add esi,edx
								mov esi,[esi+sIMPORT_DESCRIPTOR.fileAddressStart]
								inc ecx
								jmp .loop2
								
							.endif
						
						.else
							; next line
							add esi,4
							inc ecx
							jmp .loop2
						
						.endif
						
		.out2:					
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],ecx														
						
					.elseif [treeItemType] = TREE_ITEM_EXPORT_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],11	
					
					.elseif [treeItemType] = TREE_ITEM_EXPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov eax,[ptrExportDirec]
						mov eax,[eax+sEXPORT_DIRECTORY.numOfAddressTableEntries]
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
						
					.elseif [treeItemType] = TREE_ITEM_EXPORT_NAME_PTR_TABLE or TREE_ITEM_DATA_INFO | [treeItemType] = TREE_ITEM_EXPORT_ORDINAL_TABLE or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
										
						mov eax,[ptrExportDirec]
						mov eax,[eax+sEXPORT_DIRECTORY.numOfNamePointerEntries]
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax																	
					
					.elseif [treeItemType] = TREE_ITEM_BOUND_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov [i],0	; counter for num of lines
						mov [j],0
						mov [k],0
						mov esi,[edi+sSORT_ITEM_TYPE.fileAddress]
						lea edi,[dataInfo]			
	.loop3:					
						; reading IMAGE_BOUND_IMPORT_DESCRIPTOR struct
						; TimeDateStamp
						stdcall GetData,edi,esi,0,4
						mov eax,[edi]
						mov [j],eax
						; OffsetModuleName
						stdcall GetData,edi,esi,4,2
						movzx edx,word[edi]
						mov [k],edx
						; NumberOfModuleForwarderRefs
						stdcall GetData,edi,esi,6,2
						movzx eax,word[edi]
						; 3 lines per struct
						add [i],3
						add esi,sizeof.IMAGE_BOUND_IMPORT_DESCRIPTOR
						; last bound directory entry is filled with zeroes
						.if [j] = 0 & [k] = 0 & eax = 0
							jmp .out3
							
						.endif
						; if eax <> 0 there are forwarders
						.if eax <> 0
							xor ecx,ecx
		.loop4:		
							cmp ecx,eax
							je .loop3
								; 3 lines per struct
								add [i],3
								add esi,sizeof.IMAGE_BOUND_FORWARDER_REF
							inc ecx
							jmp .loop4
							
						.endif
						
						jmp .loop3			
	.out3:				
						mov edx,[i]
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],edx
								
					.elseif [treeItemType] = TREE_ITEM_IMAGE_BASE_RELOCATION or TREE_ITEM_DATA_INFO			
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
									
						; k is total size
						mov edx,[edi+sSORT_ITEM_TYPE.fileSize]
						mov [k],edx
																						
						; copy address
						mov esi,eax
						; i is number of lines
						mov [i],0
						; j is size for counting
						mov [j],0
						lea edi,[dataInfo]
						; is there relocation at all
						; page rva
						stdcall GetData,edi,esi,0,4
						mov edx,[edi]
						push edx
							; block size
							stdcall GetData,edi,esi,4,4
						pop edx
						mov eax,[edi]
						; if not show 2 empty lines
						.if edx = 0 & eax = 0
							mov [i],2
							
						.else
		.loop5:				
							; read block rva
							stdcall GetData,edi,esi,0,4
							mov eax,[edi]
							push eax
								; read block size
								stdcall GetData,edi,esi,4,4
								mov edx,[edi]
							pop eax
							.if eax = 0 & edx <> 0
								; 2 lines only
								; next block
								add esi,edx
								; inc size
								add [j],edx
								; add 2 lines , page rva and block size
								add [i],2
								jmp .next5
								
							.elseif eax = 0 & edx = 0
								; 2 lines , end of the reloc section
								; add 2 lines , page rva and block size
								add [i],2
								jmp .out5
								
							.endif
							; next block
							add esi,edx
							; inc size
							add [j],edx
							; add 2 lines , page rva and block size
							add [i],2
							; calc rest of the lines for the block
							; sub 8 bytes for 2 added 2 lines ( page rva and block size ) 2*4 bytes
							sub edx,8
							; rest are words so div by 2 bytes per line
							shr edx,1
							add [i],edx														
							; check size and total size
		.next5:					
							mov eax,[k]
							cmp eax,[j]
							je .out5
							
							jmp .loop5
							
						.endif
		.out5:					
						mov ecx,[i]
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],ecx
					
					.elseif [treeItemType] = TREE_ITEM_LOAD_CONFIGURATION or TREE_ITEM_DATA_INFO			
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],20
					
					.elseif [treeItemType] = TREE_ITEM_TLS_DIRECTORY or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],6
					
					.elseif [treeItemType] = TREE_ITEM_DELAY_LOAD_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						; count number of lines
						; eax is file address , copy
						mov esi,eax
						lea edi,[dataInfo]
						xor ecx,ecx
		.loop6:				
						push ecx
						; get delay import address table
						stdcall GetData,edi,esi,12,4
						mov eax,[edi]
						push eax
						; get delay import name table
						stdcall GetData,edi,esi,16,4
						mov edx,[edi]
						pop eax
						
						pop ecx
						;  8 lines per struct
						add ecx,8
						add esi,sizeof.DELAY_IMPORT_DESCRIPTOR
						; last struct is filled with zeroes
						.if eax = 0 & edx = 0
							jmp .out6
							
						.endif
						jmp .loop6
		.out6:					
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],ecx																													
					
					.elseif [treeItemType] = TREE_ITEM_DEBUG_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov eax,[ptrDebugDirec]
						mov eax,[eax+sDEBUG_DIRECTORY.numOfTypesInFile]
						; 8 lines per struct
						imul eax,8
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
					
					.elseif [treeItemType] = TREE_ITEM_DEBUG_FPO_TYPE or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
									
						; how many fpo structs there are , size of 1 struct is 16 bytes
						xor edx,edx
						mov ecx,16
						mov eax,[ptrDebugDirec]
						mov eax,[eax+sDEBUG_DIRECTORY.fpoAddressSize]
						div ecx
						; 11 lines per struct
						imul eax,11
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
					
					.elseif [treeItemType] = TREE_ITEM_COFF_SYMBOLS_HEADER or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],8
						
					.elseif [treeItemType] = TREE_ITEM_COFF_LINE_NUMBERS or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
						
						; 2 lines per entry
						mov eax,[esi+sFILE_PE_INFO.numOfLineNum]
						shl eax,1
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
					
					.elseif [treeItemType] = TREE_ITEM_COFF_RELOCATIONS or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
																
						; 3 lines per entry
						mov eax,[edi+sSORT_ITEM_TYPE.fileSize]
						imul eax,3
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
					
					.elseif [treeItemType] = TREE_ITEM_COFF_SYMBOL_TABLE or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
									
						; calc num of lines
						mov edx,[esi+sFILE_PE_INFO.numOfSymbols]
						; j is total num of symbol table entries
						mov [j],edx
						; k is address of symbol table
						mov [k],eax
						lea edi,[dataInfo]
						; esi is symbol table + aux table
						xor esi,esi
		.loop7:				
						; get num of aux symbol , if any
						stdcall GetData,edi,[k],17,1
						.if byte[edi] <> 0																				
							; how many aux tables
							movzx edx,byte[edi]
							add esi,edx
							; get storage class , to identify aux table
							push edx
								stdcall GetData,edi,[k],16,1
							pop edx
							; skip aux entries
							mov eax,edx
							imul eax,18																								
							add [k],eax
							.if byte[edi] = IMAGE_SYM_CLASS_FILE								
								; 2 line per table
								shl edx,1
								add [i],edx
								
							.elseif byte[edi] = IMAGE_SYM_CLASS_STATIC															
								; 8 lines per table
								shl edx,3
								add [i],edx
							
							.elseif byte[edi] = IMAGE_SYM_CLASS_EXTERNAL
								; 6 lines per table
								imul edx,6
								add [i],edx
							
							.elseif byte[edi] = IMAGE_SYM_CLASS_FUNCTION
								; 6 lines per table
								imul edx,6
								add [i],edx
															
							.elseif byte[edi] = IMAGE_SYM_CLASS_WEAK_EXTERNAL
								; 4 line per table
								shl edx,2
								add [i],edx
								
							.endif							
						
						.endif						
						; 8 lines per symbol table table
						add [i],8
						; next table						
						add [k],18
						inc esi
						; is this was the last one						
						.if esi = [j]
							jmp .out7
						
						.else
							jmp .loop7
								
						.endif						
		.out7:			
						mov ecx,[i]
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],ecx
					
					.elseif [treeItemType] = TREE_ITEM_RESOURCE_DIRECTORY or TREE_ITEM_DATA_INFO
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
										
						; get level of directory table
						mov edx,[edi+sSORT_ITEM_TYPE.rvaSize]
						; save level to treeitemsize element
						mov dword[ebx+sTREE_ITEM_TYPE.treeItemSize],edx
						; get num of lines for the directories and entries with that level																											
						stdcall GetNumOfLinesForResDirectory,[ptrResource],edx
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],eax
					
					.elseif [treeItemType] = TREE_ITEM_RESOURCE_DIRECTORY_DATA_ENTRY or TREE_ITEM_DATA_INFO			
						push [ptrSort]
						push [ptrFilePeInfo]
						call CopyAddressToTreeItem
						add esp,4*2
									
						; get total number of data entry structs
						mov edx,[edi+sSORT_ITEM_TYPE.fileSize]
						; 4 lines per struct
						shl edx,2
						mov dword[ebx+sTREE_ITEM_TYPE.numOfLines],edx			
					
					.endif	; data info elements 
					
				.endif			
				
				mov edx,[ebx+sTREE_ITEM_TYPE.numOfLines]
				sub edx,1
				mov dword[ebx+sTREE_ITEM_TYPE.vScrollPos],0
				mov dword[ebx+sTREE_ITEM_TYPE.vScrollMaxPos],edx
				lea edi,[ebx+sTREE_ITEM_TYPE.itemText]
				
				cinvoke wsprintfW,edi,addr tmpl,[treeText]
				
				stdcall AddItemToTreeView,[hTreeParent],[treeText]
				
				mov dword[ebx+sTREE_ITEM_TYPE.hTreeItem],eax				
				ret
			endp
			
			proc GetNumOfLinesForResDirectory uses ebx esi edi,ptrResDirec,level
				
				locals
					numOfEntries	dd	0
					i	dd	0
					j	dd	0
				endl
				
				mov edx,[level]
				mov esi,[ptrResDirec]				
				; if the first directory table is wanted level
				; then it is level 0 , count and exit
				.if dword[esi+sRESOURCE_DIRECTORY.level] = edx
					; found it
					; 6 lines for the table
					add [i],6
					; is there a directory entry
					.if dword[esi+sRESOURCE_DIRECTORY.numOfEntries] <> 0
						mov ecx,[esi+sRESOURCE_DIRECTORY.numOfEntries]
						; 2 lines per entry
						shl ecx,1
						add [i],ecx
					
					.endif
				
				; is there a data entries	
				.elseif dword[esi+sRESOURCE_DIRECTORY.numOfEntries] <> 0
					mov eax,[esi+sRESOURCE_DIRECTORY.numOfEntries]
					mov [numOfEntries],eax
					mov edi,[esi+sRESOURCE_DIRECTORY.ptrDirectoryEntries]
					; for every data entry check if points to subdirectory
					; and if that subdirectory is wanted level
		.loop:			
					mov ecx,[j]
					cmp ecx,[numOfEntries]
					je .out
						
						.if dword[edi+sRESOURCE_ENTRY.ptrSubDirectory] <> 0
							mov esi,[edi+sRESOURCE_ENTRY.ptrSubDirectory]
							stdcall GetNumOfLinesForResDirectory,esi,[level]
							add [i],eax
						
						.endif
					
					inc [j]
					add edi,sizeof.sRESOURCE_ENTRY
					jmp .loop				
		.out:									
				.endif
				
				
				mov eax,[i]
				ret
			endp						
			
			proc ProcessingTreeViewElements uses ebx esi edi,fileType
				
				locals					
					i	dd	0
					j	dd	0
					size	dd	0
					ptrStrTbl	dd	0					
					hTreeRoot	dd	0
					hRoot		dd	0
					offset		dd	0
					len			dd	0
					ish		du	'IMAGE_SECTION_HEADER: ',0
					isr		du	'SECTION: ',0
					text	du	64 dup 0
				endl				
							
				mov edx,[ptrFileBaseInfo]
				lea eax,[edx+sFILE_BASE_INFO.fileTitle]															
				.if [fileType] = FILE_IS_UNKNOWN | [fileType] = FILE_IS_OBJ64 | [fileType] = FILE_IS_EXE64 or FILE_IS_PE32PLUS | [fileType] = FILE_IS_DLL64 or FILE_IS_PE32PLUS
					; display just root					
					stdcall ProcessingTreeViewItem,TREE_ITEM_ROOT or TREE_ITEM_DATA_RAW,TVI_ROOT,eax,0,[ptrTreeViewItem],0
					ret
					
				.endif
								
				mov ebx,[ptrTreeViewItem]												
				; in any case first display root , file's name
				stdcall ProcessingTreeViewItem,TREE_ITEM_ROOT or TREE_ITEM_DATA_RAW,TVI_ROOT,eax,0,ebx,0
				mov [hTreeRoot],eax
				add ebx,sizeof.sTREE_ITEM_TYPE
				
				invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,1024*2
				mov [ptrStrTbl],eax
				; load string table
				invoke GetModuleHandleW,0
				invoke LoadStringW,eax,TREE_ITEM_TEXT,[ptrStrTbl],1024	
				
				.if [fileType] = FILE_IS_EXE32 or FILE_IS_PE32 | [fileType] = FILE_IS_DLL32 or FILE_IS_PE32																											
					; processing standard dos nt headers into sort array
					; ret is index into sort array for the next input					
					stdcall ProcessingPeHeaders
					mov [size],eax
					imul eax,sizeof.sSORT_ITEM_TYPE
					mov esi,eax
					; processing sections raw data into sort structure
					; ret is index into sort array for the next input
					stdcall ProcessingSections,eax					
					add [size],eax
					imul eax,sizeof.sSORT_ITEM_TYPE
					add esi,eax
																		
					; processing data directories into sort structure
					; skip x entries																																				
					stdcall ProcessingDataDirectories,esi
					add [size],eax																																	
					
					mov edx,[numOfSortItemAlloc]
					.if edx <> [numOfTVItemAlloc]
						mov [numOfTVItemAlloc],edx
						imul edx,sizeof.sTREE_ITEM_TYPE
						invoke HeapReAlloc,[hHeapObject],HEAP_ZERO_MEMORY,[ptrTreeViewItem],edx
						mov [ptrTreeViewItem],eax
						; return ptrTree to ebx 
						mov ebx,eax
						; skip one structure , treeitemroot is processed at beggining
						add ebx,sizeof.sTREE_ITEM_TYPE
						
					.endif
								
					; type 1 - sSORT_ITEM_TYPE struct
					stdcall InsertionSort,[ptrSortItem],1,[size]
					
					mov esi,[ptrSortItem]
					mov [j],-1
					mov [i],0					
	.loop:				
					mov ecx,[i]
					cmp ecx,[size]
					je .out
						; is item in the tree root
						.if dword[esi+sSORT_ITEM_TYPE.inRoot] = 1
							; find right index of section header array , copy name , copy tree item handle
							.if dword[esi+sSORT_ITEM_TYPE.treeItemType] = TREE_ITEM_IMAGE_SECTION_HEADER or TREE_ITEM_DATA_INFO													
								mov eax,[esi+sSORT_ITEM_TYPE.inSectionNo]								
								imul eax,sizeof.sSEC_HEADER_INFO
								mov edi,[ptrSecHeaderInfo]
								add edi,eax
								push edi
									lea edi,[edi+sSEC_HEADER_INFO.headerName]								
									; copy name
									invoke lstrcpyW,addr text,addr ish
									invoke lstrcatW,addr text,edi
								pop edi
								
								stdcall ProcessingTreeViewItem,dword[esi+sSORT_ITEM_TYPE.treeItemType],[hTreeRoot],addr text,edi,ebx,esi											
								mov dword[edi+sSEC_HEADER_INFO.hTreeItem],eax
								invoke RtlZeroMemory,addr text,64*2
								
								add ebx,sizeof.sTREE_ITEM_TYPE
								add esi,sizeof.sSORT_ITEM_TYPE
								inc [i]
								
							; find right index of section raw array, copy name , maybe need tree item root handle
							.elseif dword[esi+sSORT_ITEM_TYPE.treeItemType] = TREE_ITEM_SECTION_RAW or TREE_ITEM_DATA_RAW							
								mov edx,[esi+sSORT_ITEM_TYPE.inSectionNo]								
								mov [j],edx							
								imul edx,sizeof.sSEC_HEADER_INFO
								mov edi,[ptrSecHeaderInfo]
								add edi,edx								
								lea edi,[edi+sSEC_HEADER_INFO.headerName]								
								; copy name
								invoke lstrcpyW,addr text,addr isr
								invoke lstrcatW,addr text,edi								
								
								stdcall ProcessingTreeViewItem,dword[esi+sSORT_ITEM_TYPE.treeItemType],[hTreeRoot],addr text,0,ebx,esi												
								mov [hRoot],eax
								invoke RtlZeroMemory,addr text,64*2
								
								add ebx,sizeof.sTREE_ITEM_TYPE
								add esi,sizeof.sSORT_ITEM_TYPE
								inc [i]								
							
							; maybe need tree item root handle
							.else								
								stdcall GetTextForTreeItem,dword[esi+sSORT_ITEM_TYPE.treeItemType],addr offset,addr len
								shl [offset],1
								mov edi,[ptrStrTbl]
								add edi,[offset]
								; + '0'
								add [len],1
								invoke lstrcpynW,addr text,edi,[len]
								
								stdcall ProcessingTreeViewItem,dword[esi+sSORT_ITEM_TYPE.treeItemType],[hTreeRoot],addr text,0,ebx,esi												
								mov [hRoot],eax
								invoke RtlZeroMemory,addr text,64*2
								
								add ebx,sizeof.sTREE_ITEM_TYPE
								add esi,sizeof.sSORT_ITEM_TYPE																								
								inc [i]
								
							.endif ; 
						
						.endif	; it is in the root		
		.next:				
						; is that was a last entry ?!
						mov ecx,[i]
						cmp ecx,[size]
						je .out
						; nop , go on						
		;.next:											
						.if dword[esi+sSORT_ITEM_TYPE.inRoot] = 0														
							mov ecx,[j]
							.if dword[esi+sSORT_ITEM_TYPE.inSectionNo] = ecx | dword[esi+sSORT_ITEM_TYPE.inSectionNo] = TREE_ITEM_IMAGE_NT_HEADERS or TREE_ITEM_DATA_RAW |\
								dword[esi+sSORT_ITEM_TYPE.inSectionNo] = TREE_ITEM_DEBUG_COFF_TYPE or TREE_ITEM_DATA_RAW
																																																							
								.if dword[esi+sSORT_ITEM_TYPE.treeItemType] = TREE_ITEM_RESOURCE_DATA_OBJECT or TREE_ITEM_DATA_RAW
									; set name																		
									stdcall GetResourceDataEntry,[ptrResource],dword[esi+sSORT_ITEM_TYPE.rvaSize]
									lea edi,dword[eax+sRESOURCE_ENTRY.text]
									invoke lstrlenW,edi
									add eax,1
									invoke lstrcpynW,addr text,edi,eax			
									
								.else
									stdcall GetTextForTreeItem,dword[esi+sSORT_ITEM_TYPE.treeItemType],addr offset,addr len
									mov edi,[ptrStrTbl]																																						
									shl [offset],1								
									add edi,[offset]
									; + '0'
									add [len],1
									invoke lstrcpynW,addr text,edi,[len]
								
								.endif																
								
								.if dword[esi+sSORT_ITEM_TYPE.treeItemType] = TREE_ITEM_RESOURCE_DIRECTORY or TREE_ITEM_DATA_INFO						
									; set level name
									lea edi,[text]
									invoke lstrlenW,edi
									shl eax,1
									add edi,eax
									
									mov edx,dword[esi+sSORT_ITEM_TYPE.rvaSize]
									add edx,'0'
									
									mov word[edi],' '
									add edi,2
									mov word[edi],dx																									
									
								.endif
								
								stdcall ProcessingTreeViewItem,dword[esi+sSORT_ITEM_TYPE.treeItemType],[hRoot],addr text,0,ebx,esi																					
								invoke RtlZeroMemory,addr text,64*2
								
								mov edx,[esi+sSORT_ITEM_TYPE.treeItemType]								
								.if edx = TREE_ITEM_IMPORT_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO | edx = TREE_ITEM_DELAY_LOAD_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO 									 									
									mov eax,[ptrSecHeaderInfo]
									mov ecx,[j]
									imul ecx,sizeof.sSEC_HEADER_INFO
									add eax,ecx
									mov dword[ebx+sTREE_ITEM_TYPE.ptrSecHeader],eax																															
								
								.endif
								
								add ebx,sizeof.sTREE_ITEM_TYPE
								add esi,sizeof.sSORT_ITEM_TYPE
								inc [i]
								jmp .next
								
							.else
								jmp .loop
															
							.endif
							
						.endif ; no root item
										
					jmp .loop
								
				.elseif [fileType] = FILE_IS_OBJ32				
					; process mscoff header into sort array
					; ret is num of sort elements
					stdcall ProcessingMSCoffHeaders
					mov [size],eax					
					imul eax,sizeof.sSORT_ITEM_TYPE
					mov esi,eax
					; processing sections raw data into sort structure
					; ret is index into sort array for the next input
					stdcall ProcessingSections,eax					
					add [size],eax
					imul eax,sizeof.sSORT_ITEM_TYPE
					add esi,eax
					; processing coff data into sort structure
					stdcall ProcessingMSCoffData,esi
					add [size],eax
					
					; ; type 1 - sSORT_ITEM_TYPE struct
					stdcall InsertionSort,[ptrSortItem],1,[size]
					
					mov esi,[ptrSortItem]
					mov [i],0
	.loop2:				
					mov ecx,[i]
					cmp ecx,[size]
					je .out
						
						.if dword[esi+sSORT_ITEM_TYPE.treeItemType] = TREE_ITEM_IMAGE_SECTION_HEADER or TREE_ITEM_DATA_INFO				
							mov eax,[esi+sSORT_ITEM_TYPE.inSectionNo]								
							imul eax,sizeof.sSEC_HEADER_INFO
							mov edi,[ptrSecHeaderInfo]
							add edi,eax
							push edi
								lea edi,[edi+sSEC_HEADER_INFO.headerName]								
								; copy name
								invoke lstrcpyW,addr text,addr ish
								invoke lstrcatW,addr text,edi
							pop edi
							
							stdcall ProcessingTreeViewItem,dword[esi+sSORT_ITEM_TYPE.treeItemType],[hTreeRoot],addr text,edi,ebx,esi											
							mov dword[edi+sSEC_HEADER_INFO.hTreeItem],eax
							invoke RtlZeroMemory,addr text,64*2																											
								
						.elseif dword[esi+sSORT_ITEM_TYPE.treeItemType] = TREE_ITEM_SECTION_RAW or TREE_ITEM_DATA_RAW
							mov edx,[esi+sSORT_ITEM_TYPE.inSectionNo]																						
							imul edx,sizeof.sSEC_HEADER_INFO
							mov edi,[ptrSecHeaderInfo]
							add edi,edx							
							lea edi,[edi+sSEC_HEADER_INFO.headerName]								
							; copy name
							invoke lstrcpyW,addr text,addr isr
							invoke lstrcatW,addr text,edi							
							
							stdcall ProcessingTreeViewItem,dword[esi+sSORT_ITEM_TYPE.treeItemType],[hTreeRoot],addr text,0,ebx,esi												
							mov [hRoot],eax
							invoke RtlZeroMemory,addr text,64*2																																			
							
						.else
							stdcall GetTextForTreeItem,dword[esi+sSORT_ITEM_TYPE.treeItemType],addr offset,addr len
							shl [offset],1
							mov edi,[ptrStrTbl]
							add edi,[offset]
							; + '0'
							add [len],1
							invoke lstrcpynW,addr text,edi,[len]
							
							stdcall ProcessingTreeViewItem,dword[esi+sSORT_ITEM_TYPE.treeItemType],[hTreeRoot],addr text,0,ebx,esi												
							mov [hRoot],eax
							invoke RtlZeroMemory,addr text,64*2														
							
						.endif
					
					inc [i]			
					add ebx,sizeof.sTREE_ITEM_TYPE
					add esi,sizeof.sSORT_ITEM_TYPE																													
					jmp .loop2
					
								
				.endif
	
	.out:		
						
				invoke HeapFree,[hHeapObject],0,[ptrStrTbl]				
				
				.if [ptrDebugDirec] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrDebugDirec]
					mov [ptrDebugDirec],0
					
				.endif				
				
				invoke SendMessageW,[hTreeWindow],TVM_EXPAND,TVE_EXPAND,[hTreeRoot]
						
				ret
			endp





























;