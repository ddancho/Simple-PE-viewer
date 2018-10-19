format MS COFF
include 'win32wxp.inc'

include 'extrndef.inc'
include 'kernel32.inc'
include 'user32.inc'

public FormatMessageBox as '_FormatMessageBox@4'

section '.code' code readable executable
	
			proc FormatMessageBox uses ebx,hwnd
			
			local errBuffer:DWORD
				
				lea ebx,[errBuffer]
								
				invoke GetLastError
				
				invoke FormatMessageW,FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM,0,eax,0,ebx,0,0
				
				invoke MessageBoxW,[hwnd],[errBuffer],0,MB_OK or MB_ICONERROR
				
				invoke LocalFree,[errBuffer]
				
				ret
			endp

