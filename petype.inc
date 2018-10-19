
struct sIMPORT_DESCRIPTOR
	inSectionNo			dd	?
	fileAddressStart	dd	?
	fileAddressEnd		dd	?
	rvaAddressStart		dd	?
	nameRva				dd	?
	nameFile			dd	?
ends

struct sEXPORT_DIRECTORY
	nameFile					dd	?
	ordinalBase					dd	?
	numOfAddressTableEntries	dd	?
	numOfNamePointerEntries		dd	?
	exportAddressFile			dd	?
	exportAddressRVA			dd	?
	namePointerFile				dd	?
	namePointerRVA				dd	?
	ordinalTableFile			dd	?
	ordinalTableRVA				dd	?
	sectionRVA					dd	?
	sectionPtrToRawData			dd	?
	exportDataDirecRVA			dd	?
	exportDataDirecSize			dd	?
ends

struct sDEBUG_DIRECTORY
	numOfTypesInFile 			dd	?
	unknownAddress				dd	?
	unknownAddressRVA			dd	?
	unknownAddressFile			dd	?
	unknownAddressSize			dd	?
	coffAddress					dd	?
	coffAddressRVA				dd	?
	coffAddressFile				dd	?
	coffAddressSize				dd	?
	cviewAddress				dd	?
	cviewAddressRVA				dd	?
	cviewAddressFile			dd	?
	cviewAddressSize			dd	?
	fpoAddress					dd	?
	fpoAddressRVA				dd	?
	fpoAddressFile				dd	?
	fpoAddressSize				dd	?
	miscAddress					dd	?
	miscAddressRVA				dd	?
	miscAddressFile				dd	?
	miscAddressSize				dd	?
	exceptionAddress			dd	?
	exceptionAddressRVA			dd	?
	exceptionAddressFile		dd	?
	exceptionAddressSize		dd	?
	fixupAddress				dd	?
	fixupAddressRVA				dd	?
	fixupAddressFile			dd	?
	fixupAddressSize			dd	?
	omapToSourceAddress			dd	?
	omapToSourceAddressRVA		dd	?
	omapToSourceAddressFile		dd	?
	omapToSourceAddressSize		dd	?
	omapFromSourceAddress		dd	?
	omapFromSourceAddressRVA	dd	?
	omapFromSourceAddressFile	dd	?
	omapFromSourceAddressSize	dd	?
	borlandAddress				dd	?
	borlandAddressRVA			dd	?
	borlandAddressFile			dd	?
	borlandAddressSize			dd	?
	reserved10Address			dd	?
	reserved10AddressRVA		dd	?
	reserved10AddressFile		dd	?
	reserved10AddressSize		dd	?
	clsidAddress				dd	?
	clsidAddressRVA				dd	?
	clsidAddressFile			dd	?
	clsidAddressSize			dd	?
ends

struct sRESOURCE_DIRECTORY
	text	rw	42
	level					dd	?	
	addressFile				dd	?
	addressRva				dd	?
	startAddressEntries		dd	?
	numOfEntries			dd	?
	ptrDirectoryEntries		dd	?	
ends

struct sRESOURCE_DATA
	index					dd	?
	inSection				dd	?
	addressFile				dd	?
	addressRva				dd	?
ends

struct sRESOURCE_STRING
	addressFile				dd	?
	addressRva				dd	?
	size					dd	?	; bytes
ends

struct sRESOURCE_ENTRY
	text	rw	42
	level 				dd		?
	integerID			dd		?
	subDirectoryRva		dd		?
	subDirectoryFile	dd		?
	ptrSubDirectory		dd		?	
	name				sRESOURCE_STRING	?
	data				sRESOURCE_DATA		?
ends












































;;