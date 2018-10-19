format MS COFF
include 'win32wxp.inc'

include 'extrndef.inc'
include 'kernel32.inc' 
include 'user32.inc'
include 'comctl32.inc'
include 'comdlg32.inc'
include 'gdi32.inc'

include 'filetype.inc'

include 'resource.inc'

public wWinMainEntry
public hWinMain
public hViewWindow
public hTreeWindow
public hMenu
public hHeapObject
public ptrCN
public ptrFileBaseInfo
public ptrFilePeInfo
public ptrSecHeaderInfo
public ptrDataDirecInfo
public ptrSortItem
public ptrTreeViewItem
public ptrStrTbl1
public ptrStrTbl2
public ptrStrTbl3
public ptrStrTbl4
public filterIndex

; const
extrn 'ID_VIEWWINDOW' as ID_VIEWWINDOW
extrn 'ID_TREEWINDOW' as ID_TREEWINDOW 
extrn 'hIniFile' as hIniFile:dword
; extrn func
extrn '_InitViewWindow@0' as InitViewWindow:dword
extrn '_CreateViewWindow@4' as CreateViewWindow:dword
extrn '_CreateTreeWindow@4' as CreateTreeWindow:dword
extrn '_FormatMessageBox@4' as FormatMessageBox:dword
extrn '_ShowOpenFileDlg@16' as ShowOpenFileDlg:dword
extrn '_SetNewWindowName@12' as SetNewWindowName:dword
extrn '_OpenFilePE@0' as OpenFilePE:dword
extrn '_CloseFilePE@0' as CloseFilePE:dword
extrn '_ProcessingTreeViewNotifyMsg@4' as ProcessingTreeViewNotifyMsg:dword
extrn '_CreateIniFile@0' as CreateIniFile:dword
extrn '_WriteDataToIniFile@0' as WriteDataToIniFile:dword
extrn '_GetDataFromSectionFile@0' as GetDataFromSectionFile:dword
extrn '_GetDataFromSectionAddr@0' as GetDataFromSectionAddr:dword
extrn '_GetDataFromSectionFont@4' as GetDataFromSectionFont:dword
extrn '_GetDataFromSectionWindow@4' as GetDataFromSectionWindow:dword
extrn '_WriteDataToSectionFont@4' as WriteDataToSectionFont:dword
extrn '_WriteDataToSectionFile@4' as WriteDataToSectionFile:dword
extrn '_WriteDataToSectionAddr@0' as WriteDataToSectionAddr:dword
extrn '_WriteDataToSectionWindow@4' as WriteDataToSectionWindow:dword

section '.code' code readable executable

	wWinMainEntry:
						
			invoke GetModuleHandleW,0
			stdcall wWinMain,eax
			invoke ExitProcess,eax
			
			proc wWinMain hInstance
				
			local wc:WNDCLASSEX
			local msg:MSG
			local hIcon:DWORD
			local hCursor:DWORD
				
				invoke RtlZeroMemory,addr wc,sizeof.WNDCLASSEX
				
				invoke LoadIconW,0,IDI_APPLICATION
				mov [wc.hIcon],eax
				invoke LoadCursorW,0,IDC_SIZEWE
				mov[wc.hCursor],eax
				
				mov [wc.cbSize],sizeof.WNDCLASSEX
				mov [wc.lpfnWndProc],MainWindowProc				
				mov [wc.hbrBackground],COLOR_WINDOW				
				mov [wc.lpszClassName],mainClassName
				mov edx,[hInstance]
				mov [wc.hInstance],edx
				mov [wc.lpszMenuName],IDR_MENU
							
				invoke RegisterClassExW,addr wc
				.if eax = 0
					mov eax,-1
					ret
					
				.endif
				
				stdcall InitViewWindow		
				
				invoke CreateWindowExW,0,mainClassName,mainWindowName,WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN,50,50,300,200,0,0,[hInstance],0
				.if eax = 0
					mov eax,-2
					ret
					
				.endif				
				mov [hWinMain],eax
				
				.if [wp.flags] = WPF_RESTORETOMAXIMIZED
					invoke ShowWindow,[hWinMain],SW_SHOWMAXIMIZED
					
				.else
					invoke ShowWindow,[hWinMain],SW_SHOW
					
				.endif
				
				invoke UpdateWindow,[hWinMain]				
				
	.msgLoop:			
				invoke GetMessageW,addr msg,0,0,0
				.if eax > 0
					invoke TranslateMessage,addr msg
					invoke DispatchMessageW,addr msg
					jmp .msgLoop
					
				.else
					jmp .msgLoopEnd
					 	
				.endif										
	.msgLoopEnd:
				
				mov eax,[msg.wParam]			
				
				ret
			endp	
			
			proc MainWindowProc uses ebx esi edi,hWnd,msg,wParam,lParam
			
			local rect:RECT
			local icc:INITCOMMONCONTROLSEX
			local cf:CHOOSEFONT
			local lf:LOGFONT	
				
				.if [msg] = WM_NOTIFY
					stdcall ProcessingTreeViewNotifyMsg,[lParam]									
					
				.elseif [msg] = WM_COMMAND
					mov edx,[wParam]
					and edx,0xffff
					
						.if edx = IDM_OPEN
							mov ebx,[ptrFileBaseInfo]
							lea esi,[ebx+sFILE_BASE_INFO.fileName]
							lea edi,[ebx+sFILE_BASE_INFO.fileTitle]
							;invoke lstrcpyW,esi,name1
							;invoke lstrcpyW,edi,title1																																																																																								
							stdcall ShowOpenFileDlg,[hWnd],esi,edi,[filterIndex]
							.if eax <> 0
								mov [filterIndex],edx
								stdcall OpenFilePE
								.if eax <> 0
									invoke SetFocus,[hTreeWindow]
									invoke UpdateWindow,[hWnd]
									stdcall SetNewWindowName,[hWnd],edi,mainWindowName
									invoke EnableMenuItem,[hMenu],IDM_OPEN,MF_DISABLED
									invoke EnableMenuItem,[hMenu],IDM_CLOSE,MF_ENABLED
																											
								.endif
								
							.endif																							
																																					
						.elseif edx = IDM_CLOSE
							stdcall CloseFilePE
							invoke SetFocus,[hWnd]
							invoke UpdateWindow,[hWnd]															
							invoke SetWindowTextW,[hWnd],mainWindowName
							invoke EnableMenuItem,[hMenu],IDM_OPEN,MF_ENABLED
							invoke EnableMenuItem,[hMenu],IDM_CLOSE,MF_DISABLED							
								
						.elseif edx = IDM_FONT
							lea esi,[lf]
							lea ebx,[cf]
							invoke RtlZeroMemory,ebx,sizeof.CHOOSEFONT
							invoke RtlZeroMemory,esi,sizeof.LOGFONT
							mov dword[ebx+CHOOSEFONT.lStructSize],sizeof.CHOOSEFONT
							mov edx,[hWnd]
							mov dword[ebx+CHOOSEFONT.hwndOwner],edx														
							mov dword[ebx+CHOOSEFONT.lpLogFont],esi
							mov dword[ebx+CHOOSEFONT.Flags],CF_SCREENFONTS
							invoke ChooseFontW,ebx
							.if eax
								invoke CreateFontIndirectW,addr lf
								mov [hFont],eax
								invoke SendMessageW,[hTreeWindow],WM_SETFONT,[hFont],1
								invoke SendMessageW,[hViewWindow],WM_SETFONT,[hFont],1
								; save font info to ini data
								stdcall WriteDataToSectionFont,addr lf
							.endif
								
						.elseif edx = IDM_FILE
							invoke CheckMenuItem,[hMenu],IDM_FILE,MF_CHECKED
							invoke CheckMenuItem,[hMenu],IDM_RVA,MF_UNCHECKED
							invoke CheckMenuItem,[hMenu],IDM_VA,MF_UNCHECKED
							invoke InvalidateRect,[hViewWindow],0,0
								
						.elseif edx = IDM_RVA
							invoke CheckMenuItem,[hMenu],IDM_FILE,MF_UNCHECKED
							invoke CheckMenuItem,[hMenu],IDM_RVA,MF_CHECKED
							invoke CheckMenuItem,[hMenu],IDM_VA,MF_UNCHECKED
							invoke InvalidateRect,[hViewWindow],0,0
								
						.elseif edx = IDM_VA
							invoke CheckMenuItem,[hMenu],IDM_FILE,MF_UNCHECKED
							invoke CheckMenuItem,[hMenu],IDM_RVA,MF_UNCHECKED
							invoke CheckMenuItem,[hMenu],IDM_VA,MF_CHECKED
							invoke InvalidateRect,[hViewWindow],0,0
								
						.elseif edx = IDM_EXIT
							invoke DestroyWindow,[hWnd]
							
						.elseif edx = IDM_ABOUT
							invoke MessageBoxW,[hWnd],aboutText,aboutCaption,MB_OK
							
						.endif
					
				.elseif [msg] = WM_SIZE						
					invoke GetClientRect,[hWnd],addr rect
					invoke EnumChildWindows,[hWnd],EnumChildWindowProc,addr rect		
								
				.elseif [msg] = WM_LBUTTONDOWN			
					invoke SetCapture,[hWnd]
					mov [bDrag],1											
				
				.elseif [msg] = WM_LBUTTONUP
					invoke ReleaseCapture
					mov [bDrag],0
				
				.elseif [msg] = WM_MOUSEMOVE
					.if [bDrag] = 1
						invoke GetClientRect,[hWnd],addr rect
						; low word of lParam is x coordinate of the cursor
						mov eax,[lParam]
						and eax,0xFFFF
						mov ecx,[rect.right]
						sub ecx,50
							.if eax > 50  &  eax < ecx
								mov [drag],eax
								push eax
									sub eax,2
									invoke MoveWindow,[hTreeWindow],0,0,eax,[rect.bottom],TRUE
								pop eax
								mov edx,[rect.right]
								sub edx,eax
								sub edx,2
								add eax,2
								invoke MoveWindow,[hViewWindow],eax,0,edx,[rect.bottom],TRUE
								
							.endif
										
					.endif									
				
				.elseif [msg] = WM_CREATE													
					mov [icc.dwSize],sizeof.INITCOMMONCONTROLSEX
					mov [icc.dwICC],ICC_TREEVIEW_CLASSES
					invoke InitCommonControlsEx,addr icc
										
					stdcall CreateViewWindow,[hWnd]
					mov [hViewWindow],eax
					stdcall CreateTreeWindow,[hWnd]
					mov [hTreeWindow],eax
					
					invoke GetMenu,[hWnd]
					mov [hMenu],eax
					
					; ALLOC MEM
					invoke HeapCreate,0,0,0
					.if eax <> 0
						mov [hHeapObject],eax			
						invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof.sFILE_BASE_INFO						
						mov [ptrFileBaseInfo],eax
						invoke HeapAlloc,[hHeapObject],HEAP_ZERO_MEMORY,sizeof.sFILE_PE_INFO
						mov [ptrFilePeInfo],eax
						
					.else
						stdcall FormatMessageBox,[hWnd]	
						invoke DestroyWindow,[hWnd]
						
					.endif
					
					; INI file
					stdcall CreateIniFile
					.if signed eax < 0
						; error msg from CreateIniFile
						; font default to Courier New
						invoke CreateFontW,-12,0,0,0,0,0,0,0,0,0,0,0,0,ptrCN 	
						mov [hFont],eax						
						; index default to .exe
						mov [filterIndex],1					
						jmp .next
						
					.elseif eax = 0
						; new ini file is created
						stdcall WriteDataToIniFile
						
					.endif												
					
					; read from ini file
					; get file type
					stdcall GetDataFromSectionFile
					.if signed eax <= 0 | eax >= 5
						mov [filterIndex],1
					
					.else
						mov [filterIndex],eax
						
					.endif
										
					; get address type
					stdcall GetDataFromSectionAddr
					.if eax = 1
	.back:			
						invoke CheckMenuItem,[hMenu],IDM_FILE,MF_CHECKED
						invoke CheckMenuItem,[hMenu],IDM_RVA,MF_UNCHECKED
						invoke CheckMenuItem,[hMenu],IDM_VA,MF_UNCHECKED
						
					.elseif eax = 2
						invoke CheckMenuItem,[hMenu],IDM_FILE,MF_UNCHECKED
						invoke CheckMenuItem,[hMenu],IDM_RVA,MF_CHECKED
						invoke CheckMenuItem,[hMenu],IDM_VA,MF_UNCHECKED
						
					.elseif eax = 3
						invoke CheckMenuItem,[hMenu],IDM_FILE,MF_UNCHECKED
						invoke CheckMenuItem,[hMenu],IDM_RVA,MF_UNCHECKED
						invoke CheckMenuItem,[hMenu],IDM_VA,MF_CHECKED
					
					.else
						; default file address
						jmp .back
						
					.endif
					
					; get font
					stdcall GetDataFromSectionFont,addr lf
					invoke CreateFontIndirectW,addr lf
					.if eax <> 0
						mov [hFont],eax
					
					.else
						; font default to Courier New
						invoke CreateFontW,-12,0,0,0,0,0,0,0,0,0,0,0,0,ptrCN 	
						mov [hFont],eax	
					
					.endif										
								
					mov [wp.length],sizeof.WINDOWPLACEMENT
					invoke GetWindowPlacement,[hWnd],wp
					
					; get window pos
					; eax is maximized flag
					lea ecx,[wp.rcNormalPosition]
					stdcall GetDataFromSectionWindow,ecx					
					.if eax = 1																		
						mov [wp.flags],WPF_RESTORETOMAXIMIZED
							
					.endif
					
					mov	[wp.showCmd],SW_HIDE
					invoke SetWindowPlacement,[hWnd],wp
									
	.next:																			
					; set font to child windows
					invoke SendMessageW,[hViewWindow],WM_SETFONT,[hFont],0
					invoke SendMessageW,[hTreeWindow],WM_SETFONT,[hFont],0													
				
				.elseif [msg] = WM_CLOSE			
					invoke DestroyWindow,[hWnd]
					
				.elseif [msg] = WM_DESTROY
					; write file type to ini file
					stdcall WriteDataToSectionFile,[filterIndex]
				
					; write address type to ini file
					stdcall WriteDataToSectionAddr				
							
					; write wp info to ini file
					invoke GetWindowPlacement,[hWnd],wp
					stdcall WriteDataToSectionWindow,wp
					
					; close file handle				
					.if [hIniFile] <> 0
						invoke CloseHandle,[hIniFile]
						mov [hIniFile],0
						
					.endif
					 
					stdcall CloseFilePE
					invoke DeleteObject,[hFont]
					invoke HeapDestroy,[hHeapObject]							
					invoke PostQuitMessage,0
				
				.else					
					invoke DefWindowProcW,[hWnd],[msg],[wParam],[lParam]
					ret
					
				.endif
				
				xor eax,eax
				ret
			endp
			
			proc EnumChildWindowProc uses ebx,hChildWin,lParam
				
				; lParam is ptr to rect struct of the parent
				mov ebx,[lParam]
				invoke GetWindowLongW,[hChildWin],GWL_ID
				.if eax = ID_TREEWINDOW
					mov edx,[drag]
					sub edx,2
					invoke MoveWindow,[hChildWin],0,0,edx,dword[ebx+RECT.bottom],TRUE
				
				.elseif eax = ID_VIEWWINDOW
					mov edx,dword[ebx+RECT.right]
					sub edx,[drag]					
					sub edx,2
					mov ecx,[drag]
					add ecx,2
					invoke MoveWindow,[hChildWin],ecx,0,edx,dword[ebx+RECT.bottom],TRUE
					
				.endif
					
				invoke ShowWindow,[hChildWin],SW_SHOW
				
				ret
			endp
			

section '.data' data readable writeable
	mainClassName 	du	'SIMPLE_PE_VIEWER',0
	mainWindowName	du	'SimplePEviewer',0
	aboutCaption	du	'About',0	
	aboutText		du	'SimplePEviewer version 0.0.64',10,'Viewer For PE/MSCOFF Files',10,'Programmed by Dancho',0
	ptrCN			du	'Courier New',0
	;
	align 4
	hWinMain	dd	0
	hViewWindow	dd	0
	hTreeWindow	dd	0
	hMenu		dd	0
	hFont		dd	0
	hHeapObject			dd	0
	ptrFileBaseInfo		dd	0
	ptrFilePeInfo		dd	0
	ptrSecHeaderInfo	dd	0
	ptrDataDirecInfo	dd	0
	ptrSortItem			dd	0
	ptrTreeViewItem		dd	0
	; for view window
	ptrStrTbl1		dd	0
	ptrStrTbl2		dd	0
	ptrStrTbl3		dd	0
	ptrStrTbl4		dd	0
	drag 	dd 320
	bDrag	dd	0
	filterIndex	dd	0	
	wp	WINDOWPLACEMENT

section '.drectve' linkinfo linkremove
	db ' -defaultlib:kernel32.lib -defaultlib:user32.lib -defaultlib:gdi32.lib -defaultlib:comctl32.lib -defaultlib:comdlg32.lib -defaultlib:advapi32.lib -defaultlib:shell32.lib ' 
	
			                                                                     