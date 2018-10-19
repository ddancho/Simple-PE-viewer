; Fasm macro to support lib2inc

macro EXTERNDEF decorated_name,name	; EXTERNDEF for direct calls
{
    if used name
    extrn decorated_name as name
    end if
}

macro EXTRNDEF decorated_name,name	; EXTRNDEF for indirect calls
{
    if used name
    extrn decorated_name as name : dword
    end if
}
