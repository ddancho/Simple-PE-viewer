
FILE_IS_UNKNOWN		=	0x0
FILE_IS_PE32		=	0x1
FILE_IS_PE32PLUS	=	0x2
FILE_IS_EXE32		=	0x4
FILE_IS_EXE64		=	0x8
FILE_IS_DLL32		=	0x10
FILE_IS_DLL64		=	0x20
FILE_IS_OBJ32		=	0x100
FILE_IS_OBJ64		=	0x200

IMPORT_NOT_BOUND = 0
IMPORT_NEW_BIND = -1
IMPORT_OLD_BIND = 1

struct sDATA_DIRECTORY_INFO
	virtualAddress	dd	?
    size			dd	?
ends

struct sSEC_HEADER_INFO
	headerName				rw	10
	virtualSize				dd	?
	virtualAddress			dd	?
    sizeOfRawData			dd	?
    pointerToRawData		dd	?
    pointerToRelocations	dd	?
    pointerToLinenumbers	dd	?
    numberOfRelocations		dd	?
    numberOfLinenumbers		dd	?
    characteristics			dd	?
	hTreeItem				dd	?
	numOfFlags				dd	?		
ends

struct sFILE_BASE_INFO
	fileName	rw	MAX_PATH
	fileTitle	rw	MAX_PATH
	hFile		dd	?
	hFileMap	dd	?
	allocGran	dd	?
	fileType	dd	?
	fileSize	dd	?
ends

struct sFILE_PE_INFO
	; DOS
	bStubFlag	dd 		?			; is there a msdos stub program
	stubSize	dd 		?
	; NT 
	offsetToNT			dd 		?	; start of the image nt header
	ptrToSymbolTable	dd		? 	; coff symbol table
	numOfSymbols		dd		? 
	ptrToStringTable	dd 		?	; coff string table 
	ptrToLineNumbers	dd 		?	; coff line numbers
	numOfLineNum		dd 		?
	numOfFlagsFileAttr	dd 		?	; from File Header Characteritisc field
	fileChrAttr			dd 		?	; file's characteritisc data
	numOfFlagsDllAttr	dd 		?	; from Optional Header
	fileDllAttr			dd 		?	; file's dll characteritisc data
	numOfSection		dd		? 
	imageBase			dd		? 
	boundImport			dd 		?	; bound imports true or false , type
	delayBoundImport	dd		?	; delay bound imports true or false , only with delay imports
	numOfImports		dd 		?	; number of import descr
	numOfDelayImports	dd		?	; number of delay import descr
ends





;