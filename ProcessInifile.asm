format MS COFF
include 'win32wxp.inc'

include 'extrndef.inc'
include 'kernel32.inc'
include 'shell32.inc'
include 'user32.inc'

include 'resource.inc'

ERROR_ALREADY_EXISTS = 183

public hIniFile
public CreateIniFile as '_CreateIniFile@0'
public WriteDataToIniFile as '_WriteDataToIniFile@0'
public GetDataFromSectionFile as '_GetDataFromSectionFile@0'
public GetDataFromSectionAddr as '_GetDataFromSectionAddr@0'
public GetDataFromSectionFont as '_GetDataFromSectionFont@4'
public GetDataFromSectionWindow as '_GetDataFromSectionWindow@4'
public WriteDataToSectionFile as '_WriteDataToSectionFile@4'
public WriteDataToSectionAddr as '_WriteDataToSectionAddr@0'
public WriteDataToSectionFont as '_WriteDataToSectionFont@4'
public WriteDataToSectionWindow as '_WriteDataToSectionWindow@4'

extrn 'ptrCN' as ptrCN:dword
extrn 'hMenu' as hMenu:dword

section '.code' code readable executable			
			
			proc CreateIniFile uses ebx
				
				locals
					argv 	dd	0
					argc	dd	0
					len		dd	0					
				endl
				; is ini file already created ?! check
				; where are we atm , get curent directory + program name			
				invoke GetCommandLineW
				invoke CommandLineToArgvW,eax,addr argc
				.if eax = 0
					jmp .err_out
				
				.endif
				; argv is ptr to ptr
				mov [argv],eax
				; first ptr is file name with the path
				mov ebx,dword[eax]
				invoke lstrlenW,ebx
				mov [len],eax
				push ebx				
					; wchar
					shl eax,1
					; go to the end
					add ebx,eax
					; then to the start of extension
					sub ebx,3*2
					; write ini
					mov word[ebx],'i'
					add ebx,2
					mov word[ebx],'n'
					add ebx,2
					mov word[ebx],'i'
					add ebx,2
					mov word[ebx],0				
				pop ebx
				; copy name
				add [len],1
				invoke RtlZeroMemory,iniFileName,MAX_PATH*2
				invoke lstrcpynW,iniFileName,ebx,[len]
				invoke LocalFree,[argv]
				; check for file
				invoke CreateFileW,iniFileName,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ or FILE_SHARE_WRITE,0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN,0
				mov [hIniFile],eax									
				.if eax = INVALID_HANDLE_VALUE
					; func failed , free mem , go our					
					jmp .out
					
				.else
					invoke GetLastError
					.if eax = ERROR_ALREADY_EXISTS
						; func succeeds,file exists
						mov eax,1
						jmp .out
						
					.elseif eax = 0
						; func succeedds,file doesnt exits,file is created
						jmp .out
						
					.endif
				
				.endif												
				
	.err_out:	
				mov eax,-1			
	.out:		
				
				ret
			endp
			
			proc WriteStringW sectionName,keyName,stringName,fileName
				
				invoke WritePrivateProfileStringW,[sectionName],[keyName],[stringName],[fileName]
				
				ret
			endp
			
			proc GetIntW sectionName,keyName,defaultVal,fileName
				
				invoke GetPrivateProfileIntW,[sectionName],[keyName],[defaultVal],[fileName]
				
				ret
			endp
			
			proc WriteDataToIniFile
				
				locals
					tmpl du '%d',0
					temp du	12 dup 0
				endl
				
				; file type section
				; exe - default
				cinvoke wsprintfW,addr temp,addr tmpl,1
				stdcall WriteStringW,sectionFileType,exeKey,addr temp,iniFileName
				; dll -> 0
				cinvoke wsprintfW,addr temp,addr tmpl,0
				stdcall WriteStringW,sectionFileType,dllKey,addr temp,iniFileName
				; object -> 0
				stdcall WriteStringW,sectionFileType,objectKey,addr temp,iniFileName
				; all -> 0
				stdcall WriteStringW,sectionFileType,allKey,addr temp,iniFileName
				
				; address type section
				; file - default
				cinvoke wsprintfW,addr temp,addr tmpl,1
				stdcall WriteStringW,sectionAddrType,fileKey,addr temp,iniFileName
				; rva -> 0
				cinvoke wsprintfW,addr temp,addr tmpl,0
				stdcall WriteStringW,sectionAddrType,rvaKey,addr temp,iniFileName
				; va -> 0
				stdcall WriteStringW,sectionAddrType,vaKey,addr temp,iniFileName
				
				; font section
				; face - Courier New default
				stdcall WriteStringW,sectionFont,faceKey,ptrCN,iniFileName
				; height -> -12
				cinvoke wsprintfW,addr temp,addr tmpl,-12
				stdcall WriteStringW,sectionFont,heightKey,addr temp,iniFileName				
				; width -> 0
				cinvoke wsprintfW,addr temp,addr tmpl,0
				stdcall WriteStringW,sectionFont,widthKey,addr temp,iniFileName
				; weight -> 0
				stdcall WriteStringW,sectionFont,weightKey,addr temp,iniFileName				
				; italic -> 0
				stdcall WriteStringW,sectionFont,italicKey,addr temp,iniFileName
				; charset deafult ANSI_CHARSET = 0
				stdcall WriteStringW,sectionFont,charsetKey,addr temp,iniFileName
				
				; window section
				; top -> 100
				cinvoke wsprintfW,addr temp,addr tmpl,100				
				stdcall WriteStringW,sectionWindow,topKey,addr temp,iniFileName
				; left -> 100	
				cinvoke wsprintfW,addr temp,addr tmpl,100			
				stdcall WriteStringW,sectionWindow,leftKey,addr temp,iniFileName
				; right -> 350	
				cinvoke wsprintfW,addr temp,addr tmpl,350			
				stdcall WriteStringW,sectionWindow,rightKey,addr temp,iniFileName
				; bottom -> 250				
				cinvoke wsprintfW,addr temp,addr tmpl,250
				stdcall WriteStringW,sectionWindow,bottomKey,addr temp,iniFileName
				; maximized -> 0		
				cinvoke wsprintfW,addr temp,addr tmpl,0		
				stdcall WriteStringW,sectionWindow,maximizedKey,addr temp,iniFileName
				
				ret
			endp
			
			proc GetDataFromSectionFile
								
				stdcall GetIntW,sectionFileType,exeKey,0,iniFileName
				.if eax = 1
					jmp .out
					
				.endif
				
				stdcall GetIntW,sectionFileType,dllKey,0,iniFileName
				.if eax = 1
					mov eax,2
					jmp .out
					
				.endif
				
				stdcall GetIntW,sectionFileType,objectKey,0,iniFileName
				.if eax = 1
					mov eax,3
					jmp .out
					
				.endif
				
				stdcall GetIntW,sectionFileType,allKey,0,iniFileName
				.if eax = 1
					mov eax,4
					jmp .out
					
				.endif
				
				xor eax,eax
	.out:			
				ret
			endp
			
			proc GetDataFromSectionAddr
				
				stdcall GetIntW,sectionAddrType,fileKey,0,iniFileName
				.if eax = 1					
					jmp .out
					
				.endif
				
				stdcall GetIntW,sectionAddrType,rvaKey,0,iniFileName
				.if eax = 1
					mov eax,2
					jmp .out
					
				.endif
				
				stdcall GetIntW,sectionAddrType,vaKey,0,iniFileName
				.if eax = 1
					mov eax,3
					jmp .out
					
				.endif
				
				xor eax,eax				
	.out:			
				ret
			endp
			
			proc GetDataFromSectionFont uses ebx esi edi,ptrLogFont
				
				locals
					fontFace du 32 dup 0
				endl
				
				mov ebx,[ptrLogFont]
				invoke RtlZeroMemory,ebx,sizeof.LOGFONT
				lea edi,[fontFace]
				lea esi,[ebx+LOGFONT.lfFaceName]
				
				invoke GetPrivateProfileStringW,sectionFont,faceKey,0,edi,32,iniFileName
				invoke lstrcpyW,esi,edi
				
				stdcall GetIntW,sectionFont,heightKey,0,iniFileName
				mov dword[ebx+LOGFONT.lfHeight],eax
				
				stdcall GetIntW,sectionFont,widthKey,0,iniFileName
				mov dword[ebx+LOGFONT.lfWidth],eax
				
				stdcall GetIntW,sectionFont,weightKey,0,iniFileName
				mov dword[ebx+LOGFONT.lfWeight],eax
				
				stdcall GetIntW,sectionFont,italicKey,0,iniFileName
				mov dword[ebx+LOGFONT.lfItalic],eax
				
				stdcall GetIntW,sectionFont,charsetKey,0,iniFileName
				mov dword[ebx+LOGFONT.lfCharSet],eax
				
				ret
			endp
			
			proc GetDataFromSectionWindow uses ebx,ptrRect
				
				mov ebx,[ptrRect]
				
				stdcall GetIntW,sectionWindow,topKey,0,iniFileName
				mov dword[ebx+RECT.top],eax
				
				stdcall GetIntW,sectionWindow,leftKey,0,iniFileName
				mov dword[ebx+RECT.left],eax
				
				stdcall GetIntW,sectionWindow,rightKey,0,iniFileName
				mov dword[ebx+RECT.right],eax
				
				stdcall GetIntW,sectionWindow,bottomKey,0,iniFileName
				mov dword[ebx+RECT.bottom],eax
				
				stdcall GetIntW,sectionWindow,maximizedKey,0,iniFileName
				
				ret
			endp
			
			proc WriteDataToSectionFile fIndex
				
				locals
					tmpl du '%d',0
					temp0 du 12 dup 0
					temp1 du 12 dup 0
				endl
				
				cinvoke wsprintfW,addr temp0,addr tmpl,0
				cinvoke wsprintfW,addr temp1,addr tmpl,1
				
				.if [fIndex] = 1					
					; exe = 1
	.back:				
					stdcall WriteStringW,sectionFileType,exeKey,addr temp1,iniFileName
					stdcall WriteStringW,sectionFileType,dllKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionFileType,objectKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionFileType,allKey,addr temp0,iniFileName
					
				.elseif [fIndex] = 2
					; dll = 1
					stdcall WriteStringW,sectionFileType,exeKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionFileType,dllKey,addr temp1,iniFileName
					stdcall WriteStringW,sectionFileType,objectKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionFileType,allKey,addr temp0,iniFileName
					
				.elseif [fIndex] = 3
					; object = 1
					stdcall WriteStringW,sectionFileType,exeKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionFileType,dllKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionFileType,objectKey,addr temp1,iniFileName
					stdcall WriteStringW,sectionFileType,allKey,addr temp0,iniFileName
					
				.elseif [fIndex] = 4
					; all = 1
					stdcall WriteStringW,sectionFileType,exeKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionFileType,dllKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionFileType,objectKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionFileType,allKey,addr temp1,iniFileName
					
				.else
					; default exe = 1
					jmp .back
					
				.endif
				
				ret
			endp
			
			proc WriteDataToSectionAddr
				
				locals
					tmpl du '%d',0
					temp0 du 12 dup 0
					temp1 du 12 dup 0
				endl
				
				cinvoke wsprintfW,addr temp0,addr tmpl,0
				cinvoke wsprintfW,addr temp1,addr tmpl,1
				
				invoke GetMenuState,[hMenu],IDM_FILE,MF_BYCOMMAND
				.if eax = MF_CHECKED
					stdcall WriteStringW,sectionAddrType,fileKey,addr temp1,iniFileName
					stdcall WriteStringW,sectionAddrType,rvaKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionAddrType,vaKey,addr temp0,iniFileName
					
				.endif
				invoke GetMenuState,[hMenu],IDM_RVA,MF_BYCOMMAND
				.if eax = MF_CHECKED
					stdcall WriteStringW,sectionAddrType,fileKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionAddrType,rvaKey,addr temp1,iniFileName
					stdcall WriteStringW,sectionAddrType,vaKey,addr temp0,iniFileName
					
				.endif
				invoke GetMenuState,[hMenu],IDM_VA,MF_BYCOMMAND
				.if eax = MF_CHECKED
					stdcall WriteStringW,sectionAddrType,fileKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionAddrType,rvaKey,addr temp0,iniFileName
					stdcall WriteStringW,sectionAddrType,vaKey,addr temp1,iniFileName
					
				.endif				
				
				ret
			endp
			
			proc WriteDataToSectionFont uses ebx esi,ptrLogFont
								
				locals
					tmpl du '%d',0
					temp du 12 dup 0
				endl
				
				mov ebx,[ptrLogFont]
				lea esi,[ebx+LOGFONT.lfFaceName]
				; face
				stdcall WriteStringW,sectionFont,faceKey,esi,iniFileName
				; height
				cinvoke wsprintfW,addr temp,addr tmpl,dword[ebx+LOGFONT.lfHeight]
				stdcall WriteStringW,sectionFont,heightKey,addr temp,iniFileName
				; width
				cinvoke wsprintfW,addr temp,addr tmpl,dword[ebx+LOGFONT.lfWidth]
				stdcall WriteStringW,sectionFont,widthKey,addr temp,iniFileName
				; weight
				cinvoke wsprintfW,addr temp,addr tmpl,dword[ebx+LOGFONT.lfWeight]
				stdcall WriteStringW,sectionFont,weightKey,addr temp,iniFileName
				; italic
				movzx eax,byte[ebx+LOGFONT.lfItalic]
				cinvoke wsprintfW,addr temp,addr tmpl,eax
				stdcall WriteStringW,sectionFont,italicKey,addr temp,iniFileName
				; charset
				movzx eax,byte[ebx+LOGFONT.lfCharSet]
				cinvoke wsprintfW,addr temp,addr tmpl,eax
				stdcall WriteStringW,sectionFont,charsetKey,addr temp,iniFileName
				
				ret
			endp
			
			proc WriteDataToSectionWindow uses ebx esi,ptrWndPlc
				
				locals
					tmpl du '%d',0
					temp du 12 dup 0
				endl
				
				mov ebx,[ptrWndPlc]
				; left
				cinvoke wsprintfW,addr temp,addr tmpl,dword[ebx+WINDOWPLACEMENT.rcNormalPosition.left]
				stdcall WriteStringW,sectionWindow,leftKey,addr temp,iniFileName
				; top
				cinvoke wsprintfW,addr temp,addr tmpl,dword[ebx+WINDOWPLACEMENT.rcNormalPosition.top]
				stdcall WriteStringW,sectionWindow,topKey,addr temp,iniFileName				
				; right
				cinvoke wsprintfW,addr temp,addr tmpl,dword[ebx+WINDOWPLACEMENT.rcNormalPosition.right]
				stdcall WriteStringW,sectionWindow,rightKey,addr temp,iniFileName
				; bottom							
				cinvoke wsprintfW,addr temp,addr tmpl,dword[ebx+WINDOWPLACEMENT.rcNormalPosition.bottom]
				stdcall WriteStringW,sectionWindow,bottomKey,addr temp,iniFileName
				; maximized flag
				.if dword[ebx+WINDOWPLACEMENT.showCmd] = 3
					cinvoke wsprintfW,addr temp,addr tmpl,1					
				
				.else
					cinvoke wsprintfW,addr temp,addr tmpl,0
										
				.endif				
				stdcall WriteStringW,sectionWindow,maximizedKey,addr temp,iniFileName
				
				ret
			endp
			
section '.data' data readable writeable
			sectionFileType		du	'FileType',0			
			exeKey				du	'Exe',0
			dllKey				du	'Dll',0
			objectKey			du	'Object',0
			allKey				du	'All',0
			
			sectionAddrType		du	'AddressType',0
			fileKey				du	'File',0
			rvaKey				du	'Rva',0
			vaKey				du	'VA',0
			
			sectionFont			du	'Font',0
			faceKey				du	'Face',0
			heightKey			du	'Height',0
			widthKey			du	'Width',0
			weightKey			du	'Weight',0
			italicKey			du	'Italic',0
			charsetKey			du	'CharSet',0
		
			sectionWindow		du	'Window',0
			topKey				du	'Top',0
			leftKey				du	'Left',0
			rightKey			du	'Right',0
			bottomKey			du	'Bottom',0
			maximizedKey		du	'Maximized',0
			
			align 4
			hIniFile	dd	0
						
			iniFileName	rw MAX_PATH
			
































;;