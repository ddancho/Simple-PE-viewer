format MS COFF
include 'win32wxp.inc'

include 'extrndef.inc'
include 'kernel32.inc'
include 'user32.inc'
include 'gdi32.inc'

include 'filetype.inc'
include 'treeandsorttype.inc'
include 'petype.inc'

include 'resource.inc'

ID_VIEWWINDOW = 50001
DATE_LTRREADING	= 0x00000010
TIME_FORCE24HOURFORMAT = 0x00000008
SPI_GETWHEELSCROLLLINES   = 0x0068

public ID_VIEWWINDOW 
public lineData
public InitViewWindow as '_InitViewWindow@0'
public CreateViewWindow as '_CreateViewWindow@4'
public CloseViewWindow as '_CloseViewWindow@0'
public SetScrollInfoForNewTreeItem as '_SetScrollInfoForNewTreeItem@0'
public LoadScrollInfoForNewTreeItem as '_LoadScrollInfoForNewTreeItem@4'
public SaveScrollInfoOfOldTreeItem as '_SaveScrollInfoOfOldTreeItem@4'
public ConvertHexWordToStringU as '_ConvertHexWordToStringU@8'

extrn 'hMenu' as hMenu:dword
extrn 'hHeapObject' as hHeapObject:dword
extrn 'hViewWindow' as hViewWindow:dword
extrn 'numOfTVItemAlloc' as numOfTVItemAlloc:dword
extrn 'ptrStrTbl1' as ptrStrTbl1:dword
extrn 'ptrStrTbl2' as ptrStrTbl2:dword
extrn 'ptrStrTbl3' as ptrStrTbl3:dword
extrn 'ptrStrTbl4' as ptrStrTbl4:dword
extrn 'ptrFilePeInfo' as ptrFilePeInfo:dword
extrn 'ptrSecHeaderInfo' as ptrSecHeaderInfo:dword
extrn 'ptrSortItem' as ptrSortItem:dword
extrn 'ptrTreeViewItem' as ptrTreeViewItem:dword
extrn 'ptrImportNames' as ptrImportNames:dword
extrn 'ptrImportAddress' as ptrImportAddress:dword
extrn 'ptrExportDirec' as ptrExportDirec:dword
extrn 'ptrDelayName' as ptrDelayName:dword
extrn 'ptrDelayAddress' as ptrDelayAddress:dword

extrn '_GetData@16' as GetData:dword
extrn '_CopyStringAtoW@12' as CopyStringAtoW:dword
extrn '_CopyStringWtoW@12' as CopyStringWtoW:dword
extrn '_GetSectionForTableRva@12' as GetSectionForTableRva:dword
extrn '_ProcessingImageDosHeaderLineData@4' as ProcessingImageDosHeaderLineData:dword
extrn '_ProcessingImageFileHeaderLineData@4' as ProcessingImageFileHeaderLineData:dword
extrn '_ProcessingImageOptionalHeaderLineData@4' as ProcessingImageOptionalHeaderLineData:dword
extrn '_ProcessingImageSectionHeaderLineData@8' as ProcessingImageSectionHeaderLineData:dword
extrn '_ProcessingImportDirectoryEntryLineData@8' as ProcessingImportDirectoryEntryLineData:dword
extrn '_ProcessingImportLookupTableLineData@8' as ProcessingImportLookupTableLineData:dword
extrn '_ProcessingImportAddressTableLineData@8' as ProcessingImportAddressTableLineData:dword
extrn '_ProcessingExportDirectoryEntryLineData@4' as ProcessingExportDirectoryEntryLineData:dword
extrn '_ProcessingExportAddressTableLineData@4' as ProcessingExportAddressTableLineData:dword
extrn '_ProcessingExportNamePtrTableLineData@4' as ProcessingExportNamePtrTableLineData:dword
extrn '_ProcessingExportOrdinalTableLineData@4' as ProcessingExportOrdinalTableLineData:dword
extrn '_ProcessingBoundDirectoryEntryLineData@4' as ProcessingBoundDirectoryEntryLineData:dword
extrn '_ProcessingImageBaseRelocationLineData@4' as ProcessingImageBaseRelocationLineData:dword
extrn '_ProcessingImageLoadConfigurationEntryLineData@4' as ProcessingImageLoadConfigurationEntryLineData:dword
extrn '_ProcessingImageTlsDirectoryEntryLineData@4' as ProcessingImageTlsDirectoryEntryLineData:dword
extrn '_ProcessingDelayImportDirecEntryLineData@8' as ProcessingDelayImportDirecEntryLineData:dword
extrn '_ProcessingDebugDirectoryEntryLineData@4' as ProcessingDebugDirectoryEntryLineData:dword
extrn '_ProcessingDebugFpoTypeLineData@4' as ProcessingDebugFpoTypeLineData:dword
extrn '_ProcessingCoffSymbolHeaderLineData@4' as ProcessingCoffSymbolHeaderLineData:dword
extrn '_ProcessingCoffLineNumbersLineData@4' as ProcessingCoffLineNumbersLineData:dword
extrn '_ProcessingCoffRelocations@4' as ProcessingCoffRelocations:dword
extrn '_ProcessingCoffSymbolTableLineData@4' as ProcessingCoffSymbolTableLineData:dword
extrn '_ProcessingResourceDirectoryTableLineData@8' as ProcessingResourceDirectoryTableLineData:dword
extrn '_ProcessingResourceDataEntryLineData@4' as ProcessingResourceDataEntryLineData:dword

section '.code' code readable executable
			
			proc GetTimeDateStamp uses ebx esi edi,stampData,buffer
				
				locals										
					bigNum	dq	0x19DB1DED53E8000					
					fileTime	FILETIME
					sysTime		SYSTEMTIME
					spc		du	' - ',0
					temp	du	32 dup 0
				endl
												
				lea ebx,[bigNum]
				lea esi,[fileTime]
				lea edi,[sysTime]																
				xor edx,edx
				mov ecx,0x989680
				mov eax,[stampData]
				mul ecx
				
				add eax,dword[ebx]
				adc edx,dword[ebx+4]
				mov dword[esi+FILETIME.dwLowDateTime],eax
				mov dword[esi+FILETIME.dwHighDateTime],edx
				
				mov ebx,[buffer]
				invoke FileTimeToSystemTime,esi,edi
				invoke GetDateFormatW,0x00000800,DATE_LTRREADING,edi,0,ebx,128				
				invoke GetTimeFormatW,0x00000800,TIME_FORCE24HOURFORMAT,edi,0,addr temp,32
				
				invoke lstrcatW,ebx,addr spc
				invoke lstrcatW,ebx,addr temp
				
				invoke lstrlenW,ebx
																				
				ret
			endp						
			
			proc ConvertHexByteToStringU uses edi,number,buffer
				
				xor eax,eax
				mov edi,[buffer]
				mov ecx,2
				mov edx,[number]
		.@loop:	
				rol dl,4
				mov al,dl
				and al,0x0F
				cmp al,9
				jbe .not_hex_digit
				add al,'A'-'9'-1
	.not_hex_digit:
				add al,'0'
				mov word[edi],ax
				add edi,2
				loop .@loop
			
				xor eax,eax
				ret
			endp
			
			proc ConvertHexWordToStringU uses edi,number,buffer
				
				xor eax,eax
				mov edi,[buffer]
				mov ecx,4
				mov edx,[number]
		.@loop:	
				rol dx,4
				mov al,dl
				and al,0x0F
				cmp al,9
				jbe .not_hex_digit
				add al,'A'-'9'-1
	.not_hex_digit:
				add al,'0'
				mov word[edi],ax
				add edi,2
				loop .@loop
			
				xor eax,eax
				ret
			endp
			
			proc ConvertDwordToWideString uses edi,number,buffer
				
				xor eax,eax
				mov edi,[buffer]
				mov ecx,8
				mov edx,[number]
		.@loop:	
				rol edx,4
				mov al,dl
				and al,0x0F
				cmp al,9
				jbe .not_hex
				add al,'A'-'9'-1
	.not_hex:
				add al,'0'
				mov word[edi],ax
				add edi,2
				loop .@loop
			
				mov eax,8*2
				ret								
			endp 
			
			proc ConvertByteToWideString uses ebx esi edi,data,buffer,size
				
				locals
					i	dd	0
				endl
				
				xor eax,eax
				xor edx,edx				
				mov esi,[data]
				mov edi,[buffer]
				mov ecx,[size]				
	.@loop:		
				xor ebx,ebx	
				mov dl,byte[esi]
				.repeat			
					rol dl,4
					mov al,dl
					and al,0x0F
					cmp al,9
					jbe .not_hex
					add al,'A'-'9'-1				
		.not_hex:
					add al,'0'
					mov word[edi],ax
					add edi,2
					add [i],2
				inc ebx
				.until ebx = 2	
				
				mov word[edi],' '
				add edi,2
				add [i],2
				
				add esi,1
				loop .@loop				
				
				mov eax,[i]				
				ret
			endp

			proc InitViewWindow
				local wc:WNDCLASSEX
				local hCursor:DWORD
				local hIns:DWORD
				
				invoke RtlZeroMemory,addr wc,sizeof.WNDCLASSEX
				
				invoke GetModuleHandleW,0
				mov [wc.hInstance],eax
				invoke LoadCursorW,0,IDC_IBEAM
				mov [wc.hCursor],eax
				
				mov [wc.cbSize],sizeof.WNDCLASSEX
				mov [wc.lpfnWndProc],ViewWindowProc				
				mov [wc.lpszClassName],viewClassName
				
				invoke RegisterClassExW,addr wc
				
				ret
			endp
			
			proc CreateViewWindow hParent
				
				invoke GetModuleHandleW,0
				invoke CreateWindowExW,0,viewClassName,0,WS_CHILD or WS_VISIBLE or WS_VSCROLL,0,0,0,0,\
						[hParent],ID_VIEWWINDOW,eax,0
				ret
			endp
			
			proc CloseViewWindow uses ebx
				
				local sInfo:SCROLLINFO				
				
				lea ebx,[sInfo]
				invoke RtlZeroMemory,ebx,sizeof.SCROLLINFO
				
				mov [inFileStart],0
				mov [intoFileOffset],0
				mov [addressType],0
				mov [numOfLines],0
				mov [treeItemType],0
				mov [treeItemSize],0
				mov [bytesToCopy],0
				mov [bytesPerLine],0
				mov [vScrollPos],0
				mov [vScrollMaxPos],0
				mov [startAddr.file],0
				mov [startAddr.rva],0
				mov [startAddr.va],0
				mov [secHeader],0
				mov [hModule],0
				
				mov dword[ebx+SCROLLINFO.cbSize],sizeof.SCROLLINFO
				mov dword[ebx+SCROLLINFO.fMask],SIF_PAGE or SIF_POS or SIF_RANGE
				invoke SetScrollInfo,[hwnd],SB_VERT,ebx,1
				
				invoke InvalidateRect,[hwnd],0,1
				
				.if [ptrStrTbl1] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrStrTbl1]
					mov [ptrStrTbl1],0
					
				.endif
				
				.if [ptrStrTbl2] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrStrTbl2]
					mov [ptrStrTbl2],0
				
				.endif
				
				.if [ptrStrTbl3] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrStrTbl3]
					mov [ptrStrTbl3],0
					
				.endif
				
				.if [ptrStrTbl4] <> 0
					invoke HeapFree,[hHeapObject],0,[ptrStrTbl4]
					mov [ptrStrTbl4],0
				
				.endif
				
				ret
			endp
			
			proc SetScrollInfoForNewTreeItem uses ebx
				
				local sInfo:SCROLLINFO
				
				lea ebx,[sInfo]
				
				mov dword[ebx+SCROLLINFO.cbSize],sizeof.SCROLLINFO
				mov dword[ebx+SCROLLINFO.fMask],SIF_PAGE or SIF_RANGE or SIF_POS
				mov dword[ebx+SCROLLINFO.nMin],0
				mov eax,[vScrollMaxPos]
				mov dword[ebx+SCROLLINFO.nMax],eax
				mov edx,[vScrollPos]
				mov dword[ebx+SCROLLINFO.nPos],edx
				xor edx,edx
				mov eax,[pageHeight]
				div [fontHeight]
				mov dword[ebx+SCROLLINFO.nPage],eax		; nPage = pageMaxLines
				invoke SetScrollInfo,[hwnd],SB_VERT,ebx,1
				
				invoke InvalidateRect,[hwnd],0,1
				
				ret
			endp
			
			proc SaveScrollInfoOfOldTreeItem uses ebx esi,pItem
				
				local sInfo:SCROLLINFO
				
				.if [pItem] = 0
					jmp .out
					
				.endif
				
				lea ebx,[sInfo]
				mov esi,[pItem]
				
				mov dword[ebx+SCROLLINFO.cbSize],sizeof.SCROLLINFO
				mov dword[ebx+SCROLLINFO.fMask],SIF_POS
				invoke GetScrollInfo,[hwnd],SB_VERT,ebx
				
				mov eax,[ebx+SCROLLINFO.nPos]
				mov dword[esi+sTREE_ITEM_TYPE.vScrollPos],eax
				
				; free ptrLineData
				.if dword[esi+sTREE_ITEM_TYPE.ptrLineData] <> 0
					invoke HeapFree,[hHeapObject],0,dword[esi+sTREE_ITEM_TYPE.ptrLineData]
					mov dword[esi+sTREE_ITEM_TYPE.ptrLineData],0
					mov [lineData],0
				
				.endif
	.out:					
				ret
			endp
			
			proc GetSectionHeader uses ebx esi edi
				
				.if [treeItemType] = TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO | [treeItemType] = TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO
					mov edx,TREE_ITEM_IMPORT_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
					
				.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO | [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO
					mov edx,TREE_ITEM_DELAY_LOAD_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
					
				.endif
				
				mov ebx,[ptrTreeViewItem]	
				xor ecx,ecx
	.loop:			
				cmp ecx,[numOfTVItemAlloc]
				je .out
					
					.if edx = [ebx+sTREE_ITEM_TYPE.treeItemType]
						mov eax,[ebx+sTREE_ITEM_TYPE.ptrSecHeader]
						jmp .out
						
					.endif
					
				inc ecx
				add ebx,sizeof.sTREE_ITEM_TYPE
				jmp .loop		
	.out:			
				ret
			endp	
					
			proc LoadScrollInfoForNewTreeItem uses ebx esi edi,pItem								
				
				mov ebx,[pItem]
				
				mov eax,[ebx+sTREE_ITEM_TYPE.numOfLines]
				mov [numOfLines],eax				
				mov edx,[ebx+sTREE_ITEM_TYPE.vScrollPos]
				mov [vScrollPos],edx				
				mov ecx,[ebx+sTREE_ITEM_TYPE.vScrollMaxPos]
				mov [vScrollMaxPos],ecx				
				mov eax,[ebx+sTREE_ITEM_TYPE.treeItemType]
				mov [treeItemType],eax				
				mov edx,[ebx+sTREE_ITEM_TYPE.treeItemSize]
				mov [treeItemSize],edx				
				mov ecx,[ebx+sTREE_ITEM_TYPE.address.file]			
				mov [inFileStart],ecx				
				mov [startAddr.file],ecx
				mov eax,[ebx+sTREE_ITEM_TYPE.address.rva]
				mov [startAddr.rva],eax
				mov edx,[ebx+sTREE_ITEM_TYPE.address.va]
				mov [startAddr.va],edx				
				
				.if [treeItemType] = TREE_ITEM_IMAGE_DOS_HEADER or TREE_ITEM_DATA_INFO		
					invoke RtlZeroMemory,[ptrStrTbl2],576*2
					invoke RtlZeroMemory,[ptrStrTbl4],128*2										
					invoke LoadStringW,[hModule],IMAGE_DOS_HEADER_STRING_TABLE,[ptrStrTbl2],576					
					invoke LoadStringW,[hModule],TREE_ITEM_TEXT_2,[ptrStrTbl4],128					
					stdcall ProcessingImageDosHeaderLineData,[pItem]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_SIGNATURE or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl4],128*2					
					invoke LoadStringW,[hModule],TREE_ITEM_TEXT_2,[ptrStrTbl4],128
					
				.elseif [treeItemType] = TREE_ITEM_IMAGE_FILE_HEADER or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl1],1024*2
					invoke RtlZeroMemory,[ptrStrTbl2],576*2
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke LoadStringW,[hModule],CHARACTERISTICS_STRING_TABLE,[ptrStrTbl1],1024
					invoke LoadStringW,[hModule],IMAGE_FILE_HEADER_STRING_TABLE,[ptrStrTbl2],576
					invoke LoadStringW,[hModule],MACHINE_STRING_TABLE,[ptrStrTbl3],256
					stdcall ProcessingImageFileHeaderLineData,[pItem]
					mov [lineData],eax
					
				.elseif [treeItemType] = TREE_ITEM_IMAGE_OPTIONAL_HEADER or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl1],1024*2
					invoke RtlZeroMemory,[ptrStrTbl2],576*2
					invoke LoadStringW,[hModule],IMAGE_OPTIONAL_HEADER_STRING_TABLE,[ptrStrTbl1],1024
					invoke LoadStringW,[hModule],OPTIONAL_HEADER_VALUE_STRING_TABLE,[ptrStrTbl2],576				
					stdcall ProcessingImageOptionalHeaderLineData,[pItem]
					mov [lineData],eax
					
				.elseif [treeItemType] = TREE_ITEM_IMAGE_SECTION_HEADER or TREE_ITEM_DATA_INFO			
					invoke RtlZeroMemory,[ptrStrTbl1],1024*2
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke LoadStringW,[hModule],SECTION_HEADER_CHARACTERISTICS_STR_TBL,[ptrStrTbl1],1024
					invoke LoadStringW,[hModule],IMAGE_SECTION_HEADER_STRING_TABLE,[ptrStrTbl3],256				
					mov ebx,[pItem]
					mov edx,[ebx+sTREE_ITEM_TYPE.ptrSecHeader]
					mov [secHeader],edx
					stdcall ProcessingImageSectionHeaderLineData,[pItem],edx
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_IMPORT_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO			
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke LoadStringW,[hModule],IMPORT_DIRECTORY_STRING_TABLE,[ptrStrTbl3],256
					mov ebx,[pItem]					
					mov edx,[ebx+sTREE_ITEM_TYPE.ptrSecHeader]
					mov [secHeader],edx
					stdcall ProcessingImportDirectoryEntryLineData,[pItem],edx
					mov [lineData],eax					
					
				.elseif [treeItemType] = TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO | [treeItemType] = TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke LoadStringW,[hModule],IMPORT_TABLE,[ptrStrTbl3],256													
					stdcall GetSectionHeader
					mov [secHeader],eax
					stdcall ProcessingImportLookupTableLineData,[pItem],[treeItemType]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO | [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke LoadStringW,[hModule],IMPORT_TABLE,[ptrStrTbl3],256				
					stdcall GetSectionHeader
					mov [secHeader],eax
					stdcall ProcessingImportAddressTableLineData,[pItem],[treeItemType]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_EXPORT_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke LoadStringW,[hModule],EXPORT_DIRECTORY_STRING_TABLE,[ptrStrTbl3],256
					stdcall ProcessingExportDirectoryEntryLineData,[pItem]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_EXPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl4],128*2
					invoke LoadStringW,[hModule],EXPORT_MISC_STRING_TABLE,[ptrStrTbl4],128
					stdcall ProcessingExportAddressTableLineData,[pItem]
					mov [lineData],eax
					
				.elseif [treeItemType] = TREE_ITEM_EXPORT_NAME_PTR_TABLE or TREE_ITEM_DATA_INFO
					stdcall ProcessingExportNamePtrTableLineData,[pItem]
					mov [lineData],eax
					
				.elseif [treeItemType] = TREE_ITEM_EXPORT_ORDINAL_TABLE or TREE_ITEM_DATA_INFO
					stdcall ProcessingExportOrdinalTableLineData,[pItem]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_BOUND_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke LoadStringW,[hModule],BOUND_IMPORT_STRING_TABLE,[ptrStrTbl3],256
					stdcall ProcessingBoundDirectoryEntryLineData,[pItem]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_IMAGE_BASE_RELOCATION or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke LoadStringW,[hModule],BASED_RELOC_TYPES,[ptrStrTbl3],256
					stdcall ProcessingImageBaseRelocationLineData,[pItem]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_LOAD_CONFIGURATION or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl2],576*2
					invoke LoadStringW,[hModule],LOAD_CONFIG_STRING_TABLE,[ptrStrTbl2],576
					stdcall ProcessingImageLoadConfigurationEntryLineData,[pItem]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_TLS_DIRECTORY or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl2],576*2
					invoke LoadStringW,[hModule],TLS_STRING_TABLE,[ptrStrTbl2],576
					stdcall ProcessingImageTlsDirectoryEntryLineData,[pItem]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_DELAY_LOAD_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke LoadStringW,[hModule],DELAY_IMPORT_DIREC_STR_TABLE,[ptrStrTbl3],256
					mov ebx,[pItem]					
					mov edx,[ebx+sTREE_ITEM_TYPE.ptrSecHeader]
					mov [secHeader],edx
					stdcall ProcessingDelayImportDirecEntryLineData,[pItem],edx
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_DEBUG_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl2],576*2
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke LoadStringW,[hModule],DEBUG_TYPE_STRING_TABLE,[ptrStrTbl2],576					
					invoke LoadStringW,[hModule],DEBUG_DIRECTORY_STRING_TABLE,[ptrStrTbl3],256
					stdcall ProcessingDebugDirectoryEntryLineData,[pItem]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_DEBUG_FPO_TYPE or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke LoadStringW,[hModule],DEBUG_TYPE_FPO,[ptrStrTbl3],256
					stdcall ProcessingDebugFpoTypeLineData,[pItem]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_COFF_SYMBOLS_HEADER or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke LoadStringW,[hModule],DEBUG_COFF_HEADER_STRING_TABLE,[ptrStrTbl3],256
					stdcall ProcessingCoffSymbolHeaderLineData,[pItem]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_COFF_LINE_NUMBERS or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl4],128*2
					invoke LoadStringW,[hModule],DEBUG_COFF_LINE_TABLE,[ptrStrTbl4],128
					stdcall ProcessingCoffLineNumbersLineData,[pItem]
					mov [lineData],eax
					
				.elseif [treeItemType] = TREE_ITEM_COFF_RELOCATIONS or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl2],576*2			
					invoke LoadStringW,[hModule],COFF_RELOC_STRING_TABLE,[ptrStrTbl2],576
					stdcall ProcessingCoffRelocations,[pItem]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_COFF_SYMBOL_TABLE or TREE_ITEM_DATA_INFO			
					invoke RtlZeroMemory,[ptrStrTbl2],576*2	
					invoke RtlZeroMemory,[ptrStrTbl3],256*2
					invoke RtlZeroMemory,[ptrStrTbl4],128*2						
					invoke LoadStringW,[hModule],COFF_AUX_STRING_TABLE,[ptrStrTbl2],576
					invoke LoadStringW,[hModule],DEBUG_COFF_SYMBOL_VALUE_TABLE,[ptrStrTbl3],256			
					invoke LoadStringW,[hModule],DEBUG_COFF_SYMBOL_TABLE,[ptrStrTbl4],128										
					stdcall ProcessingCoffSymbolTableLineData,[pItem]
					mov [lineData],eax				
				
				.elseif [treeItemType] = TREE_ITEM_RESOURCE_DIRECTORY or TREE_ITEM_DATA_INFO
					invoke RtlZeroMemory,[ptrStrTbl2],576*2			
					invoke RtlZeroMemory,[ptrStrTbl3],256*2			
					invoke LoadStringW,[hModule],RESOURCE_STRING_TABLE,[ptrStrTbl2],576			
					invoke LoadStringW,[hModule],RESOURCE_ID_STRING_TABLE,[ptrStrTbl3],256
					stdcall ProcessingResourceDirectoryTableLineData,[pItem],dword[ebx+sTREE_ITEM_TYPE.treeItemSize]
					mov [lineData],eax
				
				.elseif [treeItemType] = TREE_ITEM_RESOURCE_DIRECTORY_DATA_ENTRY or TREE_ITEM_DATA_INFO		
					invoke RtlZeroMemory,[ptrStrTbl3],256*2	
					invoke LoadStringW,[hModule],RESOURCE_STRING_TABLE,[ptrStrTbl3],256
					stdcall ProcessingResourceDataEntryLineData,[pItem]
					mov [lineData],eax
					
				.endif
				
				ret
			endp
			
			proc OnFont uses ebx,hWnd,wParam
				
				local hdc:DWORD
				local hOldObj:DWORD
				local tm:TEXTMETRIC	
				local sInfo:SCROLLINFO
				
				lea ebx,[tm]
				
				mov eax,[wParam]
				mov [hFont],eax
				
				invoke GetDC,[hWnd]
				mov [hdc],eax
				invoke SelectObject,eax,[hFont]
				mov [hOldObj],eax
				invoke GetTextMetricsW,[hdc],ebx
				invoke SelectObject,[hdc],[hOldObj]
				invoke ReleaseDC,[hWnd],[hdc]
				
				; set font
				mov eax,[ebx+TEXTMETRIC.tmAveCharWidth]
				mov [fontWidth],eax
				mov edx,[ebx+TEXTMETRIC.tmHeight]
				mov [fontHeight],edx
				
				; set page
				xor edx,edx
				mov eax,[pageHeight]
				div [fontHeight]
				mov [pageMaxLines],eax	; pageMaxLines = pageHeight / fontHeight
				
				; new scroll pos
				lea ebx,[sInfo]
				mov dword[ebx+SCROLLINFO.cbSize],sizeof.SCROLLINFO
				mov dword[ebx+SCROLLINFO.fMask],SIF_PAGE
				mov eax,[pageMaxLines]
				mov dword[ebx+SCROLLINFO.nPage],eax
				invoke SetScrollInfo,[hWnd],SB_VERT,ebx,1
				
				invoke InvalidateRect,[hWnd],0,1
				invoke UpdateWindow,[hWnd]				
				
				ret
			endp
			
			proc OnSize uses ebx,hWnd,width,height
				
				local sInfo:SCROLLINFO
				
				lea ebx,[sInfo]
				
				mov eax,[width]
				mov edx,[height]				
				mov [pageWidth],eax
				mov [pageHeight],edx
				
				.if [pageHeight] <> 0 & [fontHeight] <> 0
					xor edx,edx
					mov eax,[pageHeight]
					div [fontHeight]
					mov [pageMaxLines],eax		; pageMaxLines = pageHeight / fontHeight
					mov dword[ebx+SCROLLINFO.nPage],eax	; nPage = pageMaxLines
					
				.else
					mov [pageMaxLines],0
					mov dword[ebx+SCROLLINFO.nPage],0
				
				.endif
				
				mov dword[ebx+SCROLLINFO.cbSize],sizeof.SCROLLINFO
				mov dword[ebx+SCROLLINFO.fMask],SIF_PAGE or SIF_RANGE
				mov dword[ebx+SCROLLINFO.nMin],0
				;mov eax,[numOfLines]
				;sub eax,1
				mov eax,[vScrollMaxPos]
				mov dword[ebx+SCROLLINFO.nMax],eax
				invoke SetScrollInfo,[hWnd],SB_VERT,ebx,1
				
				mov eax,[vScrollMaxPos]
				.if eax > [pageMaxLines]
					invoke InvalidateRect,[hWnd],0,0
					
				.elseif eax <> 0 & eax<pageMaxLines
					invoke InvalidateRect,[hWnd],0,0
				
				.endif
				
				ret
			endp
			
			proc OnVScroll uses ebx,hWnd,wParam
				
				local sInfo:SCROLLINFO
				
				lea ebx,[sInfo]
				mov dword[ebx+SCROLLINFO.cbSize],sizeof.SCROLLINFO
				mov dword[ebx+SCROLLINFO.fMask],SIF_ALL
				invoke GetScrollInfo,[hWnd],SB_VERT,ebx
				mov eax,[ebx+SCROLLINFO.nPos]
				mov [vScrollPos],eax
				
				and [wParam],0xffff
				
				.if [wParam] = SB_LINEUP
					.if dword[ebx+SCROLLINFO.nPos] > 0
						sub dword[ebx+SCROLLINFO.nPos],1
						
					.endif
					
				.elseif [wParam] = SB_LINEDOWN
					add dword[ebx+SCROLLINFO.nPos],1
					
				.elseif [wParam] = SB_THUMBTRACK
					mov edx,[ebx+SCROLLINFO.nTrackPos]
					mov dword[ebx+SCROLLINFO.nPos],edx
				
				.endif
				
				mov dword[ebx+SCROLLINFO.fMask],SIF_POS
				invoke SetScrollInfo,[hWnd],SB_VERT,ebx,1
				invoke GetScrollInfo,[hWnd],SB_VERT,ebx
				
				mov eax,[vScrollPos]
				
				.if eax <> dword[ebx+SCROLLINFO.nPos]
					sub eax,[ebx+SCROLLINFO.nPos]
					mul [fontHeight]
					invoke ScrollWindow,[hWnd],0,eax,0,0
					invoke UpdateWindow,[hWnd]
					
				.endif
				
				ret
			endp
			
			proc CreateAuxLine uses ebx esi,destination,value,valueLen,data,dataLen,padLen
				
				mov ebx,[destination]
				; pad
				xor ecx,ecx
	.loop:			
				cmp ecx,20
				je .next
				
					mov word[ebx],' '
					add ebx,2	
				
				inc ecx
				jmp .loop
	.next:		
				; data
				.if [dataLen] = 1
					mov eax,[data]
					add eax,'0'
					mov word[ebx],ax
					add ebx,2
					
				.elseif [dataLen] = 2					
					stdcall ConvertHexByteToStringU,[data],ebx
					add ebx,2*2
					
				.elseif [dataLen] = 4				
					mov word[ebx],'0'
					add ebx,2
					mov word[ebx],'x'
					add ebx,2
					stdcall ConvertHexWordToStringU,[data],ebx
					add ebx,4*2					
					
				.elseif [dataLen] = 10
					mov word[ebx],'0'
					add ebx,2
					mov word[ebx],'x'
					add ebx,2
					stdcall ConvertDwordToWideString,[data],ebx
					add ebx,8*2
				
				.elseif [dataLen] = 8
					stdcall ConvertDwordToWideString,[data],ebx
					add ebx,8*2
								
				.endif				
				
				; pad for value
				xor ecx,ecx
	.loop3:			
				cmp ecx,[padLen]
				je .next3			
					
					mov word[ebx],'-'
					add ebx,2	
				
				inc ecx
				jmp .loop3
	.next3:		
				; copy value
				add [valueLen],1
				invoke lstrcpynW,ebx,[value],[valueLen]
							
				ret
			endp
			
			proc CreateHexLine uses ebx esi,destination,data,description,descriptionLen,value,valueLen,valuePad,byteToCopy,address	
				
				mov ebx,[destination]
				; ADDRESS
				stdcall ConvertDwordToWideString,[address],ebx				
				; PAD for data
				add ebx,eax
				mov word[ebx],' '
				add ebx,2
				mov word[ebx],' '
				add ebx,2
				
				; check for aux symbol table
				mov ecx,[data]
				mov edx,[ecx]
				.if edx = '---4'
					jmp .next
				
				.endif
				
				.if [byteToCopy] = 0
					jmp .fastExit
					
				.endif
				
				mov edx,[treeItemType]
				test edx,TREE_ITEM_DATA_RAW
				.if ~ZERO?
					; DATA RAW ( BYTES )
					stdcall ConvertByteToWideString,[data],ebx,[byteToCopy]													
					.if [byteToCopy] < 16										
						mov ecx,96
						sub ecx,eax						
						shr ecx,1
						add ebx,eax											
		.loop1:			
						mov word[ebx],' '	
						add ebx,2
						loop .loop1		
							
					.else				
						add ebx,eax																
						
					.endif												
					; PAD for ascii					
					mov word[ebx],' '
					add ebx,2
					mov word[ebx],' '
					add ebx,2
					; ASCII
					xor eax,eax
					mov ecx,[byteToCopy]
					mov esi,[data]
		.loop2:		
					mov al,byte[esi]	
					.if eax < 33 | eax > 127
						mov word[ebx],'.'
						
					.else
						mov word[ebx],ax
					
					.endif															
					add ebx,2
					add esi,1
					loop .loop2					
					
				.else
					; DATA INFO TYPE			
					; pad for data extra
					.if [byteToCopy] = 1						
						mov word[ebx],' '
						add ebx,2
						mov word[ebx],' '
						add ebx,2						
						mov word[ebx],' '
						add ebx,2
												
					.elseif [byteToCopy] = 2
						mov word[ebx],' '
						add ebx,2
						mov word[ebx],' '
						add ebx,2			
						
					.elseif [byteToCopy] = 3
						mov word[ebx],' '
						add ebx,2										
						
					.endif
					
					; data
					xor eax,eax
					mov esi,[data]
					mov ecx,[byteToCopy]
					.repeat
						
						mov al,byte[esi+ecx-1]
						push ecx
							stdcall ConvertHexByteToStringU,eax,ebx
						pop ecx
						add ebx,4
						
					dec ecx
					.until ecx = 0
		.next:			
					; pad for description info
					.if [byteToCopy] = 1
						mov word[ebx],' '
						add ebx,2
						mov word[ebx],' '
						add ebx,2						
						mov word[ebx],' '
						add ebx,2
						mov word[ebx],' '
						add ebx,2
						mov word[ebx],' '
						add ebx,2												
						
					.elseif [byteToCopy] = 2
						mov word[ebx],' '
						add ebx,2
						mov word[ebx],' '
						add ebx,2						
						mov word[ebx],' '
						add ebx,2
						mov word[ebx],' '
						add ebx,2											
						
					.elseif [byteToCopy] = 3
						mov word[ebx],' '
						add ebx,2
						mov word[ebx],' '
						add ebx,2						
						mov word[ebx],' '
						add ebx,2
						
					.else
						mov word[ebx],' '
						add ebx,2
						mov word[ebx],' '
						add ebx,2												
					
					.endif
									
					; copy desription
					.if [descriptionLen] <> 0
						mov ecx,[descriptionLen]
						push ecx
						add ecx,1												
						invoke lstrcpynW,ebx,[description],ecx
						pop ecx						
						shl ecx,1
						add ebx,ecx
						
					.endif										
					
					.if [valueLen] <> 0
						; pad for value info
						mov ecx,[valuePad]
						sub ecx,[descriptionLen]
						.repeat
							mov word[ebx],'-'
							add ebx,2
							dec ecx
						.until ecx = 0
							
						add [valueLen],1
						invoke lstrcpynW,ebx,[value],[valueLen]					
						
					.endif
					
				.endif	; data info end
	.fastExit:							
				ret
			endp						
			
			proc DrawLine uses ebx esi edi,hdc,lineNo
			
				locals
					dbgTypes 	dd	TREE_ITEM_DEBUG_UNKNOWN_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_COFF_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_CVIEW_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_MISC_TYPE or TREE_ITEM_DATA_RAW,\
									TREE_ITEM_DEBUG_EXCEPTION_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_FIXUP_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_OMAP_TO_S_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_OMAP_FROM_S_TYPE or TREE_ITEM_DATA_RAW,\
									TREE_ITEM_DEBUG_BORLAND_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_RESERVED10_TYPE or TREE_ITEM_DATA_RAW,TREE_ITEM_DEBUG_CLSID_TYPE or TREE_ITEM_DATA_RAW
									
					rect 		RECT	0,0,0,0
					offset		dd	0
					len			dd	0
					pad			dd	0
					tempDD		dd	0
					buffer		du	360 dup 0
					temp		du	128	dup 0					
					dataRaw		db	16 dup 0
					dataInfo	db	4 dup 0
					tempDB		db	4 dup 0													
				endl
				
				mov edx,[treeItemType]
				test edx,TREE_ITEM_DATA_RAW
				.if ~ZERO?
					; DATA RAW
					mov [bytesPerLine],16
					mov [bytesToCopy],16					
					
					.if [treeItemType] = TREE_ITEM_ROOT or TREE_ITEM_DATA_RAW | [treeItemType] = TREE_ITEM_MSDOS_STUB or TREE_ITEM_DATA_RAW | [treeItemType] = TREE_ITEM_IMAGE_NT_HEADERS or TREE_ITEM_DATA_RAW |\
						[treeItemType] = TREE_ITEM_SECTION_RAW or TREE_ITEM_DATA_RAW | [treeItemType] = TREE_ITEM_BOUND_DLLS_NAMES or TREE_ITEM_DATA_RAW | [treeItemType] = TREE_ITEM_CERTIFICATE_TABLE or TREE_ITEM_DATA_RAW |\
						[treeItemType] = TREE_ITEM_COFF_STRING_TABLE or TREE_ITEM_DATA_RAW | [treeItemType] = TREE_ITEM_RESOURCE_DIRECTORY_STRING or TREE_ITEM_DATA_RAW | [treeItemType] = TREE_ITEM_RESOURCE_DATA_OBJECT or TREE_ITEM_DATA_RAW   					
						; treeItemSize-lineNo*bytesPerLine	
						mov edx,[treeItemSize]
						mov eax,[lineNo]
						imul eax,[bytesPerLine]
						mov [intoFileOffset],eax						
						sub edx,eax
						.if edx < [bytesPerLine]
							; bytesToCopy = treeItemSize-lineNo*bytesPerLine
							mov [bytesToCopy],edx
								
						.endif
											
					.else
						lea esi,[dbgTypes]						
						mov [offset],11
						mov [len],0
		.loop10:				
						mov ecx,[len]
						cmp ecx,[offset]
						je .out10
							
							mov edx,[esi+ecx*4]
							.if edx = [treeItemType]							
								jmp .out10
								
							.endif
						
						inc [len]
						jmp .loop10						
		.out10:
						; treeItemSize-lineNo*bytesPerLine	
						mov edx,[treeItemSize]
						mov eax,[lineNo]
						imul eax,[bytesPerLine]
						mov [intoFileOffset],eax						
						sub edx,eax
						.if edx < [bytesPerLine]
							; bytesToCopy = treeItemSize-lineNo*bytesPerLine
							mov [bytesToCopy],edx
								
						.endif
						
					.endif
																																						
					stdcall GetData,addr dataRaw,[inFileStart],[intoFileOffset],[bytesToCopy]															
					mov eax,[addressType]
					add eax,[intoFileOffset]					
					stdcall CreateHexLine,addr buffer,addr dataRaw,0,0,0,0,0,[bytesToCopy],eax					
					
				.else			
					; DATA INFO					
					
					.if [treeItemType] = TREE_ITEM_IMAGE_DOS_HEADER or TREE_ITEM_DATA_INFO									
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],30
						
						mov esi,[ptrStrTbl2]
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]																		
						.if [lineNo] = 0																												
							lea ecx,[dataInfo]
							movzx ecx,word[ecx]
							mov edx,'MZ'
							
							.if ecx = edx
								mov edi,[ptrStrTbl4]	
								mov [len],19																
								jmp .type02hexline						
								
							.else
								jmp .type01hexline
							
							.endif																										
							
						.else								
							jmp .type01hexline
						
						.endif
						
					.elseif [treeItemType] = TREE_ITEM_SIGNATURE or TREE_ITEM_DATA_INFO	
						mov esi,[ptrStrTbl4]			
						stdcall GetData,addr dataInfo,[inFileStart],0,4
						
						lea ecx,[dataInfo]
						movzx ecx,word[ecx]				
						mov edx,'PE'												
						.if ecx = edx
							mov edi,esi
							mov eax,39
							shl eax,1
							add esi,eax
							mov edx,20
							shl edx,1
							add edi,edx
							stdcall CreateHexLine,addr buffer,addr dataInfo,esi,9,edi,18,25,4,[addressType]
													
						.else
							mov eax,39
							shl eax,1
							add esi,eax
							stdcall CreateHexLine,addr buffer,addr dataInfo,esi,9,0,0,25,4,[addressType]
							
						.endif
						
					.elseif [treeItemType] = TREE_ITEM_IMAGE_FILE_HEADER or TREE_ITEM_DATA_INFO		
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],30
						
						mov edx,[ptrFilePeInfo]
						mov edx,[edx+sFILE_PE_INFO.numOfFlagsFileAttr]
						mov eax,[numOfLines]
						sub eax,edx
						.if [lineNo] < eax
							mov esi,[ptrStrTbl2]							
							stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
							; Machine
							.if [lineNo] = 0								
								mov edi,[ptrStrTbl3]
								mov ecx,[ebx+sLINE_DATA.line.lineInfoA]
								shl ecx,1																								
								add edi,ecx
								
								mov edx,dword[ebx+sLINE_DATA.line.lineInfoB]
								mov [len],edx								
								jmp .type02hexline 								
								
							; Time Date Stamp
							.elseif [lineNo] = 2					
								lea ecx,[dataInfo]
								.if dword[ecx] <> 0
									stdcall GetTimeDateStamp,dword[ecx],addr temp	
									mov [len],eax
									jmp .type03hexline
									
								.else
									jmp .type01hexline
									
								.endif																																							
								
							.else
								jmp .type01hexline
								
							.endif
							
						; Characteristics
						.else				
							mov esi,[ptrStrTbl1]
							
							mov edx,[ebx+sLINE_DATA.offset]
							shl edx,1
							add esi,edx
							
							stdcall CreateAuxLine,addr buffer,esi,dword[ebx+sLINE_DATA.len],dword[ebx+sLINE_DATA.line.lineInfoA],4,24
							
						.endif
						
					.elseif [treeItemType] = TREE_ITEM_IMAGE_OPTIONAL_HEADER or TREE_ITEM_DATA_INFO			
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],30
						
						mov esi,[ptrStrTbl1]	
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]																							
						; Magic or Subsystem
						.if [lineNo] = 0 | [lineNo] = 22							
							mov edi,[ptrStrTbl2]
							mov ecx,[ebx+sLINE_DATA.line.lineInfoA]
							shl ecx,1																								
							add edi,ecx							
							
							mov edx,dword[ebx+sLINE_DATA.line.lineInfoB]
							mov [len],edx
							jmp .type02hexline														
							
						; dll characteristics
						.elseif [lineNo] > 23 & dword[ebx+sLINE_DATA.line.lineInfoB] = 1						
							mov edi,[ptrStrTbl2]
							mov edx,[ebx+sLINE_DATA.offset]
							shl edx,1
							add edi,edx
							
							stdcall CreateAuxLine,addr buffer,edi,dword[ebx+sLINE_DATA.len],dword[ebx+sLINE_DATA.line.lineInfoA],4,24
							
						.else						
							jmp .type01hexline
						
						.endif
												
					.elseif [treeItemType] = TREE_ITEM_IMAGE_SECTION_HEADER or TREE_ITEM_DATA_INFO			
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],30
						
						mov edi,[secHeader]
						mov edx,[edi+sSEC_HEADER_INFO.numOfFlags]
						mov eax,[numOfLines]
						sub eax,edx
						.if [lineNo] < eax
							mov esi,[ptrStrTbl3]
							stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
							;  Name[0] and value ( the name itself )
							.if [lineNo] = 0													
								lea edi,[edi+sSEC_HEADER_INFO.headerName]
								invoke lstrlenW,edi
								mov [len],eax
								
								lea ecx,[dataInfo]
								mov edx,[ecx]
								bswap edx
								mov [ecx],edx
								jmp .type02hexline																													
								
							; Name[4]
							.elseif [lineNo] = 1
								lea ecx,[dataInfo]
								mov edx,[ecx]
								bswap edx
								mov [ecx],edx
								jmp .type01hexline																							
								
							.else
								jmp .type01hexline
								
							.endif																											
						
						; section header characteristics
						.else
							mov edi,[ptrStrTbl1]
							mov edx,[ebx+sLINE_DATA.offset]
							shl edx,1
							add edi,edx
							
							stdcall CreateAuxLine,addr buffer,edi,dword[ebx+sLINE_DATA.len],dword[ebx+sLINE_DATA.line.lineInfoA],10,20
						
						.endif							
					
					.elseif [treeItemType] = TREE_ITEM_IMPORT_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],30
						
						mov esi,[ptrStrTbl3]
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]																																																									
						; name rva
						.if dword[ebx+sLINE_DATA.line.lineNo] = 3 & dword[ebx+sLINE_DATA.line.lineInfoC] = 0																															
							lea ecx,[dataInfo]
							mov ecx,[ecx]
							; check if the name rva is in the section with directory			
							push ecx	
								stdcall GetSectionForTableRva,ecx,0,0
								.if signed eax >= 0
									pop ecx
										sub ecx,[ebx+sLINE_DATA.line.lineInfoA]
										add ecx,[ebx+sLINE_DATA.line.lineInfoB]
								
								.else
									pop ecx
									
								.endif													
							stdcall CopyStringAtoW,addr temp,ecx,128
							mov [len],eax
							jmp .type03hexline	
																		
						; last one is empty
						.elseif dword[ebx+sLINE_DATA.line.lineInfoC] = 1
							jmp .type04hexline
							
						.else
							jmp .type01hexline
							
						.endif
						
					.elseif [treeItemType] = TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO | [treeItemType] = TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],25
														
						mov eax,[ebx+sLINE_DATA.line.lineInfoA]
						mov [inFileStart],eax						
						
						invoke GetMenuState,[hMenu],IDM_FILE,MF_BYCOMMAND
						.if eax = MF_CHECKED
							mov edx,[ebx+sLINE_DATA.line.lineInfoA]		; file start
							mov [addressType],edx							
						
						.endif
						invoke GetMenuState,[hMenu],IDM_RVA,MF_BYCOMMAND
						.if eax = MF_CHECKED
							mov edx,[ebx+sLINE_DATA.line.lineInfoB]		; rva start
							mov [addressType],edx					
						
						.endif
						invoke GetMenuState,[hMenu],IDM_VA,MF_BYCOMMAND
						.if eax = MF_CHECKED
							mov edx,[ebx+sLINE_DATA.line.lineInfoC]		; va start						
							mov [addressType],edx
							
						.endif	
						
						mov esi,[ptrStrTbl3]												
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						lea ecx,[dataInfo]
						mov eax,[ecx]
						test eax,0x80000000
						.if ~ZERO?
							; import by ordinal					
							and eax,0xffff
							stdcall ConvertHexWordToStringU,eax,addr temp
							mov [len],4
							jmp .type03hexline														
							
						.elseif eax <> 0
							; get hint/name table
							; get file start								
							; is it in the section	
							push eax	
								stdcall GetSectionForTableRva,eax,0,0
								.if signed eax >= 0
									pop eax
										mov edi,[secHeader]
										sub eax,[edi+sSEC_HEADER_INFO.virtualAddress]
										add eax,[edi+sSEC_HEADER_INFO.pointerToRawData]
								
								.else
									pop eax
									
								.endif															
							mov [offset],eax
							; skip hint , go to the name address
							add [offset],2
							; get hint										
							stdcall GetData,addr tempDB,eax,0,2
							lea ecx,[tempDB]
							mov edx,[ecx]
							; copy hint
							lea edi,[temp]
							stdcall ConvertHexWordToStringU,edx,edi
							; pad for name			
							add edi,4*2
							mov word[edi],' '
							add edi,2
							mov word[edi],' '
							add edi,2
							; copy name					
							stdcall CopyStringAtoW,edi,[offset],128	
							add eax,5											
							mov [len],eax
							jmp .type03hexline							
							
						.elseif eax = 0
							; end of import table
							.if [treeItemType] = TREE_ITEM_IMPORT_LOOKUP_TABLE_RVA or TREE_ITEM_DATA_INFO
								mov eax,[ptrImportNames]
								mov edi,[ptrFilePeInfo]
								mov edi,[edi+sFILE_PE_INFO.numOfImports]
								
							.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_NAME_TABLE or TREE_ITEM_DATA_INFO
								mov eax,[ptrDelayName]
								mov edi,[ptrFilePeInfo]
								mov edi,[edi+sFILE_PE_INFO.numOfDelayImports]
								
							.endif							
							
							mov edx,[inFileStart]
							add edx,[ebx+sLINE_DATA.bytesPerLine]
							xor ecx,ecx
			.loop1:				
							cmp ecx,edi
							je .out1			
									
								.if edx = [eax+sIMPORT_DESCRIPTOR.fileAddressEnd]
									; copy import dll name				
									stdcall CopyStringAtoW,addr temp,dword[eax+sIMPORT_DESCRIPTOR.nameFile],128
									mov [len],eax
									jmp .type03hexline																											
									
								.endif																	
							
							inc ecx
							add eax,sizeof.sIMPORT_DESCRIPTOR
							jmp .loop1		
			.out1:		
														
						.endif
						
					.elseif [treeItemType] = TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO | [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi												
						mov [pad],25
										
						mov eax,[ebx+sLINE_DATA.line.lineInfoA]
						mov [inFileStart],eax						
						
						invoke GetMenuState,[hMenu],IDM_FILE,MF_BYCOMMAND
						.if eax = MF_CHECKED
							mov edx,[ebx+sLINE_DATA.line.lineInfoA]		; file start
							mov [addressType],edx							
						
						.endif
						invoke GetMenuState,[hMenu],IDM_RVA,MF_BYCOMMAND
						.if eax = MF_CHECKED
							mov edx,[ebx+sLINE_DATA.line.lineInfoB]		; rva start
							mov [addressType],edx					
						
						.endif
						invoke GetMenuState,[hMenu],IDM_VA,MF_BYCOMMAND
						.if eax = MF_CHECKED
							mov edx,[ebx+sLINE_DATA.line.lineInfoC]		; va start						
							mov [addressType],edx
							
						.endif	
						
						mov esi,[ptrStrTbl3]				
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						lea ecx,[dataInfo]
						mov eax,[ecx]											
						test eax,0x80000000
						.if ~ZERO?
							; import by ordinal
	.import_ordinal:										
							and eax,0xffff
							stdcall ConvertHexWordToStringU,eax,addr temp
							mov [len],4
							jmp .type03hexline														
							
						.elseif eax <> 0
							; is hint/name or virtual address					
							mov edi,[ptrFilePeInfo]
							.if signed dword[edi+sFILE_PE_INFO.boundImport] < 0 | dword[edi+sFILE_PE_INFO.boundImport] = 1
								; virtual address
								; read lookup table index , get file address start
								.if [treeItemType] = TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO
									mov ecx,[ptrImportNames]
									
								.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO					
									mov ecx,[ptrDelayName]
									
								.endif
	.delay_Bound_Import:														
								mov edx,[ebx+sLINE_DATA.line.lineNo]
								imul edx,sizeof.sIMPORT_DESCRIPTOR
								add ecx,edx
								stdcall GetData,addr tempDB,dword[ecx+sIMPORT_DESCRIPTOR.fileAddressStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
								lea ecx,[tempDB]
								mov eax,[ecx]
								test eax,0x80000000
								.if ~ZERO?									
									jmp .import_ordinal
									
								.endif
							
							.elseif dword[edi+sFILE_PE_INFO.delayBoundImport] = 1 & [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO							
								mov ecx,[ptrDelayName]
								jmp .delay_Bound_Import
								
							.endif
							; get hint/name table
							; get file start		
							; is it in the section	
							push eax	
								stdcall GetSectionForTableRva,eax,0,0
								.if signed eax >= 0
									pop eax
										mov edi,[secHeader]
										sub eax,[edi+sSEC_HEADER_INFO.virtualAddress]
										add eax,[edi+sSEC_HEADER_INFO.pointerToRawData]
								
								.else
									pop eax
									
								.endif																									
							mov [offset],eax
							; skip hint , go to the name address
							add [offset],2
							; get hint							
							stdcall GetData,addr tempDB,eax,0,2
							lea ecx,[tempDB]
							mov edx,[ecx]
							; copy hint
							lea edi,[temp]
							stdcall ConvertHexWordToStringU,edx,edi
							; pad for name			
							add edi,4*2
							mov word[edi],' '
							add edi,2
							mov word[edi],' '
							add edi,2
							; copy name					
							stdcall CopyStringAtoW,edi,[offset],128	
							add eax,5											
							mov [len],eax
							jmp .type03hexline														
							
						.elseif eax = 0
							; end of import table
							.if [treeItemType] = TREE_ITEM_IMPORT_ADDRESS_TABLE_RVA or TREE_ITEM_DATA_INFO
								mov eax,[ptrImportAddress]
								mov edi,[ptrFilePeInfo]
								mov edi,[edi+sFILE_PE_INFO.numOfImports]
									
							.elseif [treeItemType] = TREE_ITEM_DELAY_IMPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO					
								mov eax,[ptrDelayAddress]
								mov edi,[ptrFilePeInfo]
								mov edi,[edi+sFILE_PE_INFO.numOfDelayImports]
								
							.endif																					
							mov edx,[inFileStart]
							add edx,[ebx+sLINE_DATA.bytesPerLine]
							xor ecx,ecx
			.loop2:				
							cmp ecx,edi
							je .out2			
									
								.if edx = [eax+sIMPORT_DESCRIPTOR.fileAddressEnd]
									; copy import dll name													
									stdcall CopyStringAtoW,addr temp,dword[eax+sIMPORT_DESCRIPTOR.nameFile],128						
									mov [len],eax
									jmp .type03hexline																																												
									
								.endif																	
							
							inc ecx
							add eax,sizeof.sIMPORT_DESCRIPTOR
							jmp .loop2
			.out2:		
														
						.endif
					
					.elseif [treeItemType] = TREE_ITEM_EXPORT_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],30
											
						mov esi,[ptrStrTbl3]
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						.if [lineNo] = 1
						; timedatestamp
							lea ecx,[dataInfo]							
							.if dword[ecx] <> 0
								stdcall GetTimeDateStamp,dword[ecx],addr temp
								mov [len],eax
								jmp .type03hexline
							
							.else
								jmp .type01hexline
								
							.endif														
							
						.elseif [lineNo] = 4
						; dll name							
							stdcall CopyStringAtoW,addr temp,dword[ebx+sLINE_DATA.line.lineInfoA],128
							mov [len],eax
							jmp .type03hexline							
							
						.else
							jmp .type01hexline
							
						.endif
					
					.elseif [treeItemType] = TREE_ITEM_EXPORT_ADDRESS_TABLE or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],25
														
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]												
						lea ecx,[dataInfo]																		
						.if dword[ecx] <> 0
							; set value
							; set ordinal = lineNo + ordinal base
							lea edi,[temp]
							mov esi,[ptrExportDirec]
							mov edx,[esi+sEXPORT_DIRECTORY.ordinalBase]
							add edx,[lineNo]
							; copy ordinal to offset var
							mov [offset],edx
							push ecx
								stdcall ConvertHexWordToStringU,edx,edi
							pop ecx
							; pad for name
							add edi,4*2
							mov word[edi],' '
							add edi,2
							mov word[edi],' '
							add edi,2
							mov [len],12
							.if dword[ebx+sLINE_DATA.line.lineInfoA] <> 0
								stdcall CopyStringAtoW,edi,dword[ebx+sLINE_DATA.line.lineInfoA],128
								add [len],eax	
							
							.endif																																																																														
							
							mov esi,[ptrStrTbl4]					
							jmp .type03hexline
							
						.else
							mov esi,[ptrStrTbl4]
							jmp .type01hexline
						
						.endif																	
						
					.elseif [treeItemType] = TREE_ITEM_EXPORT_NAME_PTR_TABLE or TREE_ITEM_DATA_INFO | [treeItemType] = TREE_ITEM_EXPORT_ORDINAL_TABLE or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
																
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						; set ordinal number
						lea edi,[temp]
						stdcall ConvertHexWordToStringU,dword[ebx+sLINE_DATA.line.lineInfoA],edi
						; pad for name
						add edi,4*2
						mov word[edi],' '
						add edi,2
						mov word[edi],' '
						add edi,2
						mov [len],12
						stdcall CopyStringAtoW,edi,dword[ebx+sLINE_DATA.line.lineInfoB],128
						add [len],eax														
						
						mov eax,[addressType]
						add eax,[ebx+sLINE_DATA.bytesPerLine]
										
						stdcall CreateHexLine,addr buffer,addr dataInfo,addr temp,[len],0,0,0,dword[ebx+sLINE_DATA.bytesToCopy],eax												
					
					.elseif [treeItemType] = TREE_ITEM_BOUND_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],30
						
						lea edi,[dataInfo]
						mov esi,[ptrStrTbl3]																										
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]						
						.if dword[ebx+sLINE_DATA.line.lineNo] = 0 & dword[ebx+sLINE_DATA.line.lineInfoA] = 0
							; timedatestamp 
							.if dword[edi] <> 0
								stdcall GetTimeDateStamp,dword[edi],addr temp								
								mov [len],eax
								
							.endif
							jmp .type03hexline							
							
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 1 & dword[ebx+sLINE_DATA.line.lineInfoA] = 0
							; offsetmodulename							
							movzx edx,word[edi]
							add edx,[inFileStart]
							stdcall CopyStringAtoW,addr temp,edx,128
							mov [len],eax							
							jmp .type03hexline																
													
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 2 & dword[ebx+sLINE_DATA.line.lineInfoA] = 0															
							jmp .type01hexline
							
						.elseif dword[ebx+sLINE_DATA.line.lineInfoA] = 1
							; empty entry							
							jmp .type04hexline
							
						.endif	
						
					.elseif [treeItemType] = TREE_ITEM_IMAGE_BASE_RELOCATION or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],25
									
						mov esi,[ptrStrTbl3]																	
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]													
						.if dword[ebx+sLINE_DATA.bytesToCopy] = 4
						; pagerva and blocksize lines , no value							
							jmp .type01hexline								
							
						.elseif dword[ebx+sLINE_DATA.bytesToCopy] = 2 & dword[ebx+sLINE_DATA.len] <> 0 	
							; construct value part
							mov ecx,[ebx+sLINE_DATA.line.lineInfoC]																					
							lea edi,[temp]
							stdcall ConvertDwordToWideString,ecx,edi
							add edi,8*2
							mov word[edi],' '
							add edi,2
							mov word[edi],' '
							add edi,2
							mov ecx,[ebx+sLINE_DATA.line.lineInfoB]		; len
							add ecx,1
							mov edx,[ebx+sLINE_DATA.line.lineInfoA]		; offset
							shl edx,1
							push esi
								add esi,edx
								invoke lstrcpynW,edi,esi,ecx
								invoke lstrlenW,addr temp
								mov [len],eax
							pop esi
							jmp .type03hexline								
							
						.else
							; empty line
							jmp .type04hexline								
							
						.endif
						
					.elseif [treeItemType] = TREE_ITEM_LOAD_CONFIGURATION or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],25
									
						mov esi,[ptrStrTbl2]																	
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						.if [lineNo] = 1
							; timedatestamp
							lea ecx,[dataInfo]
							.if dword[ecx] <> 0
								stdcall GetTimeDateStamp,dword[ecx],addr temp
								mov [len],eax
								jmp .type03hexline
								
							.else
								jmp .type01hexline
								
							.endif							
						
						.else
							jmp .type01hexline							
						
						.endif																				
						
					.elseif [treeItemType] = TREE_ITEM_TLS_DIRECTORY or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
									
						mov esi,[ptrStrTbl2]																	
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						jmp .type01hexline						
						
					.elseif [treeItemType] = TREE_ITEM_DELAY_LOAD_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],30
						
						mov esi,[ptrStrTbl3]
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]																													
						; name rva				
						.if dword[ebx+sLINE_DATA.line.lineNo] = 1 & dword[ebx+sLINE_DATA.line.lineInfoC] = 0																																						
							lea ecx,[dataInfo]
							mov ecx,[ecx]
											
							; check if the name rva is in the section with directory
							push ecx
							stdcall GetSectionForTableRva,ecx,0,0
							.if signed eax >= 0
								pop ecx
									sub ecx,[ebx+sLINE_DATA.line.lineInfoA]
									add ecx,[ebx+sLINE_DATA.line.lineInfoB]
								
							.else
								; VA ?!
								pop ecx
									mov edx,[ptrFilePeInfo]
									mov edx,[edx+sFILE_PE_INFO.imageBase]
									sub ecx,edx
									
							.endif														
							stdcall CopyStringAtoW,addr temp,ecx,128
							mov [len],eax
							jmp .type03hexline																													
						
						; last one is empty
						.elseif dword[ebx+sLINE_DATA.line.lineInfoC] = 1
							jmp .type04hexline
							
						.else
							jmp .type01hexline
							
						.endif
					
					.elseif [treeItemType] = TREE_ITEM_DEBUG_DIRECTORY_ENTRY or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],25
						
						mov esi,[ptrStrTbl3]
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						.if dword[ebx+sLINE_DATA.line.lineNo] = 1
							; timedatestamp
							lea ecx,[dataInfo]
							.if dword[ecx] <> 0
								stdcall GetTimeDateStamp,dword[ecx],addr temp
								mov [len],eax
								jmp .type03hexline															
							
							.else
								jmp .type01hexline
								
							.endif
							
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 4
							; type
							mov edx,[ebx+sLINE_DATA.line.lineInfoA]
							shl edx,1
							mov edi,[ptrStrTbl2]
							add edi,edx
							mov eax,dword[ebx+sLINE_DATA.line.lineInfoB]
							mov [len],eax
							jmp .type02hexline														
							
						.else
							jmp .type01hexline							
							
						.endif						
						
					.elseif [treeItemType] = TREE_ITEM_DEBUG_FPO_TYPE or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
										
						mov esi,[ptrStrTbl3]
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						.if dword[ebx+sLINE_DATA.line.lineNo] = 0 | dword[ebx+sLINE_DATA.line.lineNo] = 1 |\
							dword[ebx+sLINE_DATA.line.lineNo] = 2 | dword[ebx+sLINE_DATA.line.lineNo] = 3
							jmp .type01hexline
							
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 4
							jmp .type04hexline
						
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 5
							mov edx,[ebx+sLINE_DATA.offset]
							shl edx,1
							add esi,edx
							
							stdcall CreateAuxLine,addr buffer,esi,dword[ebx+sLINE_DATA.len],dword[ebx+sLINE_DATA.line.lineInfoA],2,1
							
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 10
							mov edx,[ebx+sLINE_DATA.offset]
							shl edx,1
							add esi,edx
							
							stdcall CreateAuxLine,addr buffer,esi,dword[ebx+sLINE_DATA.len],dword[ebx+sLINE_DATA.line.lineInfoA],1,2
							mov esi,[ptrStrTbl3]				
							mov edx,[ebx+sLINE_DATA.line.lineInfoB]
							shl edx,1
							add esi,edx							
											
							lea edi,[buffer]
							add edi,32*2
							mov word[edi],' '
							add edi,2
							mov word[edi],' '
							add edi,2
							
							mov edx,dword[ebx+sLINE_DATA.line.lineInfoC]
							add edx,1
							
							invoke lstrcpynW,edi,esi,edx														
							
						.else
							mov edx,[ebx+sLINE_DATA.offset]
							shl edx,1
							add esi,edx
							
							stdcall CreateAuxLine,addr buffer,esi,dword[ebx+sLINE_DATA.len],dword[ebx+sLINE_DATA.line.lineInfoA],1,2
							
						.endif
					
					.elseif [treeItemType] = TREE_ITEM_COFF_SYMBOLS_HEADER or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
									
						mov esi,[ptrStrTbl3]																	
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						jmp .type01hexline			
					
					.elseif [treeItemType] = TREE_ITEM_COFF_LINE_NUMBERS or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],30
										
						mov esi,[ptrStrTbl4]																	
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						.if dword[ebx+sLINE_DATA.line.lineNo] = 0 | dword[ebx+sLINE_DATA.line.lineNo] = 1 & dword[ebx+sLINE_DATA.line.lineInfoA] = 0
							; virtual address
							jmp .type01hexline												
										
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 0 & dword[ebx+sLINE_DATA.line.lineInfoA] = 1						
							; index to symbol table
							stdcall CopyStringAtoW,addr temp,dword[ebx+sLINE_DATA.line.lineInfoB],128
							mov [len],eax
							jmp .type03hexline
							
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 1 & dword[ebx+sLINE_DATA.line.lineInfoA] = 1
							; empty
							jmp .type04hexline
							
						.endif
					
					.elseif [treeItemType] = TREE_ITEM_COFF_RELOCATIONS or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],30
																		
						mov esi,[ptrStrTbl2]																	
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						.if dword[ebx+sLINE_DATA.line.lineNo] = 1
							; index to symbol table
							stdcall CopyStringAtoW,addr temp,dword[ebx+sLINE_DATA.line.lineInfoA],128
							mov [len],eax
							jmp .type03hexline
							
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 2
							; type
							mov edi,[ptrStrTbl2]
							mov edx,[ebx+sLINE_DATA.line.lineInfoA]
							shl edx,1
							add edi,edx
							mov eax,[ebx+sLINE_DATA.line.lineInfoB]							
							mov [len],eax
							jmp .type02hexline
						
						.else
							; virtual address
							jmp .type01hexline
							
						.endif						
					
					.elseif [treeItemType] = TREE_ITEM_COFF_SYMBOL_TABLE or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],25
													
						mov esi,[ptrStrTbl4]																	
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]									
						.if dword[ebx+sLINE_DATA.line.lineNo] = 0 & dword[ebx+sLINE_DATA.line.lineInfoB] = 0xabcd
							; symbol table index line
							mov edx,[ebx+sLINE_DATA.offset]
							shl edx,1
							add esi,edx
							
							stdcall CreateAuxLine,addr buffer,esi,dword[ebx+sLINE_DATA.len],dword[ebx+sLINE_DATA.line.lineInfoA],8,2							
							
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 1 & dword[ebx+sLINE_DATA.line.lineInfoA] = 1							
							.if dword[ebx+sLINE_DATA.line.lineInfoB] <> 0
								; long name
								stdcall CopyStringAtoW,addr temp,dword[ebx+sLINE_DATA.line.lineInfoB],128
								mov [len],eax
								jmp .type03hexline
								
							.else
								; short name
								lea ecx,[dataInfo]
								mov edx,[ecx]
								bswap edx
								mov [ecx],edx
								
								mov eax,[inFileStart]
								add eax,[ebx+sLINE_DATA.bytesPerLine]
								; need just 8 bytes			
								stdcall CopyStringAtoW,addr temp,eax,8								
								mov [len],eax
								jmp .type03hexline
								
							.endif
						
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 2 & dword[ebx+sLINE_DATA.line.lineInfoA] = 1
							.if dword[ebx+sLINE_DATA.line.lineInfoB] = 0xabcd
								; offset into string table
								jmp .type01hexline
																
							.elseif dword[ebx+sLINE_DATA.line.lineInfoB] = 0			
								; line 2 from short name
								lea ecx,[dataInfo]
								mov edx,[ecx]
								bswap edx
								mov [ecx],edx
								jmp .type04hexline
 							
							.endif
						
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 3 & dword[ebx+sLINE_DATA.line.lineInfoA] = 1
							; value					
							jmp .type01hexline
						
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 4 & dword[ebx+sLINE_DATA.line.lineInfoA] = 1																	
							; section number
							.if dword[ebx+sLINE_DATA.line.lineInfoC] = 0
								; one based index into sections
								.if dword[ebx+sLINE_DATA.line.lineInfoD] <> 0
									mov eax,dword[ebx+sLINE_DATA.line.lineInfoD]
									lea ecx,[dataInfo]
									mov [ecx],eax
								
								.endif					
								mov eax,[ebx+sLINE_DATA.line.lineInfoB]		; address of section header
								lea ecx,[eax+sSEC_HEADER_INFO.headerName]	; get name												
								invoke lstrcpynW,addr temp,ecx,128
								invoke lstrlenW,addr temp
								mov [len],eax
								jmp .type03hexline
							
							.else
								; special value
								mov edi,[ptrStrTbl3]
								mov edx,[ebx+sLINE_DATA.line.lineInfoB]	; offset
								shl edx,1
								add edi,edx
								
								mov eax,[ebx+sLINE_DATA.line.lineInfoC] ; len
								add eax,1
								invoke lstrcpynW,addr temp,edi,eax
								mov [len],eax
								jmp .type03hexline
							
							.endif
						
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 5 & dword[ebx+sLINE_DATA.line.lineInfoA] = 1
							; type
							; check for dt_func
							.if dword[ebx+sLINE_DATA.line.lineInfoB] <> 0
								mov edi,[ptrStrTbl3]
								mov edx,[ebx+sLINE_DATA.line.lineInfoB]		; offset
								shl edx,1
								add edi,edx
								
								mov eax,[ebx+sLINE_DATA.line.lineInfoC]		; len
								add eax,1
								invoke lstrcpynW,addr temp,edi,eax
								invoke lstrlenW,addr temp
								mov [len],eax
								jmp .type03hexline
								
							.else
								jmp .type01hexline
							
							.endif
						
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 6 & dword[ebx+sLINE_DATA.line.lineInfoA] = 1			
							; storage class
							.if dword[ebx+sLINE_DATA.line.lineInfoB] <> 0
								; there is ms type storage
								mov edi,[ptrStrTbl3]
								mov edx,[ebx+sLINE_DATA.line.lineInfoB]		; offset
								shl edx,1
								add edi,edx
								
								mov eax,[ebx+sLINE_DATA.line.lineInfoC]		; len
								add eax,1
								invoke lstrcpynW,addr temp,edi,eax
								mov [len],eax
								jmp .type03hexline
								
							.else
								jmp .type01hexline
							
							.endif
						
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 7 & dword[ebx+sLINE_DATA.line.lineInfoA] = 1
							; num of aux symbols				
							jmp .type01hexline
								
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 1 & dword[ebx+sLINE_DATA.line.lineInfoD] = 1 & dword[ebx+sLINE_DATA.line.lineInfoC] = 4 
							; aux symbol record file
							mov eax,[inFileStart]
							add eax,[ebx+sLINE_DATA.bytesPerLine]
							; need 18 bytes
							stdcall CopyStringAtoW,addr temp,eax,18													
							mov [len],eax
							; mark data info for aux type 4
							lea ecx,[dataInfo]
							mov edx,[ecx]
							mov edx,'---4'
							mov [ecx],edx							
							jmp .type03hexline		
											
						.elseif dword[ebx+sLINE_DATA.line.lineInfoD] = 1									
							mov esi,[ptrStrTbl2]				
							jmp .type01hexline	
						
						.endif
					
					.elseif [treeItemType] = TREE_ITEM_RESOURCE_DIRECTORY or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],25
																
						mov eax,[ebx+sLINE_DATA.line.lineInfoA]
						mov [inFileStart],eax						
						
						invoke GetMenuState,[hMenu],IDM_FILE,MF_BYCOMMAND
						.if eax = MF_CHECKED
							mov edx,[ebx+sLINE_DATA.line.lineInfoA]		; file start
							mov [addressType],edx							
						
						.endif
						invoke GetMenuState,[hMenu],IDM_RVA,MF_BYCOMMAND
						.if eax = MF_CHECKED
							mov edx,[ebx+sLINE_DATA.line.lineInfoB]		; rva start
							mov [addressType],edx					
						
						.endif
						invoke GetMenuState,[hMenu],IDM_VA,MF_BYCOMMAND
						.if eax = MF_CHECKED
							mov edx,[ebx+sLINE_DATA.line.lineInfoC]		; va start						
							mov [addressType],edx
							
						.endif	
										
						mov esi,[ptrStrTbl2]																										
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						; resource directory table timedatestamp line
						.if dword[ebx+sLINE_DATA.line.lineNo] = 1 & dword[ebx+sLINE_DATA.line.lineInfoD] = 1
							lea ecx,[dataInfo]
							.if dword[ecx] <> 0
								stdcall GetTimeDateStamp,dword[ecx],addr temp	
								mov [len],eax
								jmp .type03hexline
									
							.else
								jmp .type01hexline
									
							.endif
							
						.elseif dword[ebx+sLINE_DATA.line.lineNo] = 2	
						; resource directory entry ,line with name
							invoke lstrlenW,dword[ebx+sLINE_DATA.line.lineInfoD]
							mov [len],eax
							add [len],1							
							invoke lstrcpynW,addr temp,dword[ebx+sLINE_DATA.line.lineInfoD],[len]														
							jmp .type03hexline
						
						.else
							jmp .type01hexline
							
						.endif						
						
					.elseif [treeItemType] = TREE_ITEM_RESOURCE_DIRECTORY_DATA_ENTRY or TREE_ITEM_DATA_INFO
						mov ebx,[lineData]
						mov esi,[lineNo]
						imul esi,sizeof.sLINE_DATA
						add ebx,esi
						mov [pad],25				
						
						mov eax,[ebx+sLINE_DATA.line.lineInfoA]
						mov [inFileStart],eax						
						
						invoke GetMenuState,[hMenu],IDM_FILE,MF_BYCOMMAND
						.if eax = MF_CHECKED
							mov edx,[ebx+sLINE_DATA.line.lineInfoA]		; file start
							mov [addressType],edx							
						
						.endif
						invoke GetMenuState,[hMenu],IDM_RVA,MF_BYCOMMAND
						.if eax = MF_CHECKED
							mov edx,[ebx+sLINE_DATA.line.lineInfoB]		; rva start
							mov [addressType],edx					
						
						.endif
						invoke GetMenuState,[hMenu],IDM_VA,MF_BYCOMMAND
						.if eax = MF_CHECKED
							mov edx,[ebx+sLINE_DATA.line.lineInfoC]		; va start						
							mov [addressType],edx
							
						.endif	
														
						mov esi,[ptrStrTbl3]																										
						stdcall GetData,addr dataInfo,[inFileStart],dword[ebx+sLINE_DATA.bytesPerLine],dword[ebx+sLINE_DATA.bytesToCopy]
						.if dword[ebx+sLINE_DATA.line.lineNo] = 0
							invoke lstrlenW,dword[ebx+sLINE_DATA.line.lineInfoD]
							add eax,1
							mov [len],eax
							invoke lstrcpynW,addr temp,dword[ebx+sLINE_DATA.line.lineInfoD],[len]
							jmp .type03hexline
							
						.else
							jmp .type01hexline
						
						.endif
							
						
					.endif	; check for data info 
					
				.endif
				
			jmp .print
				
	.type01hexline:
					; type 1 call - description -> esi , address -> eax
					mov edx,[ebx+sLINE_DATA.offset]
					shl edx,1																				
					add esi,edx
					
					mov eax,[addressType]
					add eax,[ebx+sLINE_DATA.bytesPerLine]
					
					stdcall CreateHexLine,addr buffer,addr dataInfo,esi,dword[ebx+sLINE_DATA.len],0,0,0,dword[ebx+sLINE_DATA.bytesToCopy],eax																								
					jmp .print
	.type02hexline:	
					; type 2 call - description -> esi , value -> edi , address -> eax											
					mov edx,[ebx+sLINE_DATA.offset]
					shl edx,1																				
					add esi,edx
					
					mov eax,[addressType]
					add eax,[ebx+sLINE_DATA.bytesPerLine]
					
					stdcall CreateHexLine,addr buffer,addr dataInfo,esi,dword[ebx+sLINE_DATA.len],edi,[len],[pad],dword[ebx+sLINE_DATA.bytesToCopy],eax					
					jmp .print
	.type03hexline:	
					; type 3 call - description -> esi , temp , address -> eax
					mov edx,[ebx+sLINE_DATA.offset]
					shl edx,1
					add esi,edx
								
					mov eax,[addressType]
					add eax,[ebx+sLINE_DATA.bytesPerLine]
								
					stdcall CreateHexLine,addr buffer,addr dataInfo,esi,dword[ebx+sLINE_DATA.len],addr temp,[len],[pad],dword[ebx+sLINE_DATA.bytesToCopy],eax					
					jmp .print
	.type04hexline:	
					; type 4 call - address -> eax
					mov eax,[addressType]
					add eax,[ebx+sLINE_DATA.bytesPerLine]
					
					stdcall CreateHexLine,addr buffer,addr dataInfo,0,0,0,0,0,dword[ebx+sLINE_DATA.bytesToCopy],eax										
																						
	.print:				
				mov edx,[pageWidth]
				mov [rect.right],edx
				mov [rect.left],0
				; rect.top = (lineNo-vScrollPos)*fontHeight
				mov eax,[lineNo]
				sub eax,[vScrollPos]
				imul eax,[fontHeight]
				mov [rect.top],eax
				; rect.bottom = rect.top + fontHeight
				add eax,[fontHeight]
				mov [rect.bottom],eax
				invoke lstrlenW,addr buffer
				invoke TabbedTextOutW,[hdc],[rect.left],[rect.top],addr buffer,eax,0,0,[rect.left]
				and eax,0xffff
				add [rect.left],eax
				; fill free space to the right
				invoke ExtTextOutW,[hdc],0,0,ETO_OPAQUE,addr rect,0,0,0
				
				xor eax,eax
				ret
			endp
			
			proc OnPaint uses ebx esi edi
				
				local hdc:DWORD
				local hOldObj:DWORD
				local paintBegin:DWORD
				local paintEnd:DWORD
				local ps:PAINTSTRUCT
				local rect:RECT
				local sInfo:SCROLLINFO				
				
				mov [paintBegin],0
				mov [paintEnd],0
				
				lea esi,[ps]
				invoke BeginPaint,[hwnd],esi
				mov [hdc],eax
				invoke SelectObject,eax,[hFont]
				mov [hOldObj],eax
				
				lea ebx,[sInfo]
				invoke RtlZeroMemory,ebx,sizeof.SCROLLINFO
				mov dword[ebx+SCROLLINFO.cbSize],sizeof.SCROLLINFO
				mov dword[ebx+SCROLLINFO.fMask],SIF_POS
				invoke GetScrollInfo,[hwnd],SB_VERT,ebx
				mov eax,[ebx+SCROLLINFO.nPos]
				mov [vScrollPos],eax								
				
				; paintBegin = vscrollpos + ps.rcpaint.top / fontheight
				xor edx,edx
				mov eax,[esi+PAINTSTRUCT.rcPaint.top]
				div [fontHeight]
				add eax,[vScrollPos]
				mov [paintBegin],eax
				
				; paintEnd
				.if [numOfLines] = 0
					mov [paintEnd],0
					
				.else
					; paintEnd = vscrollpos + ps.rcpaint.bottom / fontheight
					xor edx,edx
					mov eax,[esi+PAINTSTRUCT.rcPaint.bottom]
					div [fontHeight]
					add eax,[vScrollPos]
					mov [paintEnd],eax				
					test edx,edx
					.if ~ZERO?
						add [paintEnd],1
						add eax,1
					.endif
					
					.if eax > [numOfLines]
						mov edx,[numOfLines]
						mov [paintEnd],edx
						
					.endif
				
				.endif												
											
				mov edi,[paintBegin]
				.if [paintEnd] < edi					
					mov [paintEnd],-1
					
				.endif
								
	.loop:			
				cmp edi,[paintEnd]
				jge .next
					stdcall DrawLine,[hdc],edi
				add edi,1
				jmp .loop
	.next:						
				; draw rest of the page
				mov eax,[paintEnd]
				.if signed eax < [pageMaxLines]								
					mul [fontHeight]					
					invoke SetRect,addr rect,0,eax,[pageWidth],[pageHeight]					
					invoke ExtTextOutW,[hdc],0,0,ETO_OPAQUE,addr rect,0,0,0					
					
				.endif			
				; draw last empty line				
				mov eax,[vScrollMaxPos]
				sub eax,[pageMaxLines]
				add eax,1
				.if eax = [vScrollPos]
					mov eax,[pageMaxLines]
					mul [fontHeight]
					invoke SetRect,addr rect,0,eax,[pageWidth],[pageHeight]
					invoke ExtTextOutW,[hdc],0,0,ETO_OPAQUE,addr rect,0,0,0
					
				.endif									
				; draw empty
				.if [numOfLines] = 0
					invoke SetRect,addr rect,0,0,[pageWidth],[pageHeight]
					invoke ExtTextOutW,[hdc],0,0,ETO_OPAQUE,addr rect,0,0,0
				
				.endif		
				
				invoke SelectObject,[hdc],[hOldObj]
				invoke EndPaint,[hwnd],esi
							
				ret
			endp
			
			proc OnMouseWheel uses ebx,hWnd,delta
				
				local sInfo:SCROLLINFO
				local scrollLines:DWORD
				
				lea ebx,[sInfo]			
				invoke SystemParametersInfoW,SPI_GETWHEELSCROLLLINES,0,addr scrollLines,0
				.if [scrollLines] <= 5
					mov [scrollLines],10
				
				.endif
				
				mov dword[ebx+SCROLLINFO.cbSize],sizeof.SCROLLINFO
				mov dword[ebx+SCROLLINFO.fMask],SIF_ALL
				invoke GetScrollInfo,[hWnd],SB_VERT,ebx
				mov edx,[ebx+SCROLLINFO.nPos]
				mov [vScrollPos],edx
											
				mov ecx,120
				mov eax,[delta]				
				neg eax
				cdq												 
				idiv ecx
				imul eax,[scrollLines]
				.if signed edx < 0					
					inc dword[ebx+SCROLLINFO.nPos]
					
				.elseif edx >= 0
					dec dword[ebx+SCROLLINFO.nPos]
					
				.endif																																
				
				mov dword[ebx+SCROLLINFO.cbSize],sizeof.SCROLLINFO
				mov dword[ebx+SCROLLINFO.fMask],SIF_POS
				invoke SetScrollInfo,[hWnd],SB_VERT,ebx,1
				invoke GetScrollInfo,[hWnd],SB_VERT,ebx
				
				mov eax,[vScrollPos]
				.if eax <> [ebx+SCROLLINFO.nPos]
					sub eax,[ebx+SCROLLINFO.nPos]
					imul [fontHeight]
					invoke ScrollWindow,[hWnd],0,eax,0,0
					invoke UpdateWindow,[hWnd]
				
				.endif				
				
				ret
			endp
			
			proc ViewWindowProc hWnd,msg,wParam,lParam
				
			local point:POINT
				
				.if [msg] = WM_PAINT
					invoke GetMenuState,[hMenu],IDM_FILE,MF_BYCOMMAND
					.if eax = MF_CHECKED
						mov edx,[startAddr.file]
						mov [addressType],edx
						jmp .paint	
						
					.endif
					invoke GetMenuState,[hMenu],IDM_RVA,MF_BYCOMMAND
					.if eax = MF_CHECKED
						mov edx,[startAddr.rva]
						mov [addressType],edx
						jmp .paint
						
					.endif
					invoke GetMenuState,[hMenu],IDM_VA,MF_BYCOMMAND
					.if eax = MF_CHECKED
						mov edx,[startAddr.va]
						mov [addressType],edx
					
					.endif							
	.paint:				
					stdcall OnPaint
					
				.elseif [msg] = WM_SIZE							
					; width is loword(lParam)
					; height is hiword(lParam)
					mov eax,[lParam]
					mov edx,eax
					and eax,0xffff
					shr edx,16
					stdcall OnSize,[hWnd],eax,edx
				
				.elseif [msg] = WM_LBUTTONDOWN			
					invoke GetCursorPos,addr point
					invoke WindowFromPoint,[point.x],[point.y]
					.if eax <> 0
						.if eax = [hViewWindow]
							invoke SetFocus,[hViewWindow]							
						
						.endif
					
					.endif
				
				.elseif [msg] = WM_MOUSEWHEEL		
					mov edx,[wParam]
					shr edx,16		
					stdcall OnMouseWheel,[hWnd],edx
					
				.elseif [msg] = WM_VSCROLL
					stdcall OnVScroll,[hWnd],[wParam]
					
				.elseif [msg] = WM_SETFONT
					stdcall OnFont,[hWnd],[wParam]
					
				.elseif [msg] = WM_CREATE
					mov eax,[hWnd]
					mov [hwnd],eax					
					invoke GetModuleHandleW,0
					mov [hModule],eax
					
				.else
					invoke DefWindowProcW,[hWnd],[msg],[wParam],[lParam]
					ret
					
				.endif
															
				xor eax,eax
				ret
			endp
			
section '.data' data readable writeable
	viewClassName	du	'VIEWWINDOW',0
	align 4	
	; font
	hFont	dd	0
	fontWidth	dd	0
	fontHeight	dd	0
	; page
	pageWidth	dd	0
	pageHeight	dd	0
	pageMaxLines	dd	0
	; misc
	hwnd	dd	0
	inFileStart		dd	0
	intoFileOffset	dd	0	
	numOfLines		dd	0
	treeItemSize	dd	0
	treeItemType	dd	0
	bytesToCopy		dd	0
	bytesPerLine	dd	0
	lineData		dd	0	
	secHeader		dd	0
	hModule			dd	0
	; scroll
	vScrollPos		dd	0
	vScrollMaxPos	dd	0	
	; address
	addressType		dd	0
	startAddr		sADDRESS_TYPE	0,0,0
	
	
	
	



;	
	
	
	
	