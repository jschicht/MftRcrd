#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=C:\Program Files (x86)\AutoIt3\Icons\au3.ico
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Quick $MFT record dump and decode
#AutoIt3Wrapper_Res_Description=Decode any given file's $MFT record
#AutoIt3Wrapper_Res_Fileversion=1.0.0.41
#AutoIt3Wrapper_Res_LegalCopyright=Joakim Schicht
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Include <WinAPIEx.au3>
#Include <Date.au3>
#include <Array.au3>
#Include <String.au3>
;
; https://github.com/jschicht
;
Global $AttrDefArray[6][1]
Global $ReparseType,$ReparseDataLength,$ReparsePadding,$ReparseSubstituteNameOffset,$ReparseSubstituteNameLength,$ReparsePrintNameOffset,$ReparsePrintNameLength,$ResidentIndx, $_COMMON_KERNEL32DLL=DllOpen("kernel32.dll")
Global $BrowsedFile,$TargetDrive = "", $ALInnerCouner, $MFTSize, $TargetIsOffset=0,$TargetOffset,$DoExtraction=0
Global $SectorsPerCluster,$MFT_Record_Size,$BytesPerCluster,$BytesPerSector,$MFT_Offset
Global $HEADER_LSN,$HEADER_SequenceNo,$HEADER_Flags,$HEADER_RecordRealSize,$HEADER_RecordAllocSize,$HEADER_BaseRecord
Global $HEADER_NextAttribID,$HEADER_MFTREcordNumber
Global $IsolatedAttributeList, $AttribListNonResident=0
Global $FN_CTime,$FN_ATime,$FN_MTime,$FN_RTime,$FN_AllocSize,$FN_RealSize,$FN_Flags,$FN_FileName,$FN_NameType
Global $DATA_NameLength,$DATA_NameRelativeOffset,$DATA_Flags,$DATA_NameSpace,$DATA_Name,$RecordActive,$DATA_CompressionUnitSize,$DATA_Length,$DATA_AttributeID,$DATA_OffsetToDataRuns,$DATA_Padding,$DATA_OffsetToAttribute,$DATA_IndexedFlag,$DATA_Name_Core
Global $DATA_NonResidentFlag,$DATA_NameLength,$DATA_NameRelativeOffset,$DATA_Flags,$DATA_Name,$RecordActive
Global $DATA_CompressionUnitSize,$DATA_ON,$DATA_CompressedSize,$DATA_LengthOfAttribute,$DATA_StartVCN,$DATA_LastVCN
Global $DATA_AllocatedSize,$DATA_RealSize,$DATA_InitializedStreamSize,$RunListOffset,$DataRun,$IsCompressed,$IsSparse
Global $RUN_VCN[1],$RUN_Clusters[1],$MFT_RUN_Clusters[1],$MFT_RUN_VCN[1],$NameQ[5],$DataQ[1],$sBuffer,$AttrQ[1], $RUN_Sparse[1], $MFT_RUN_Sparse[1], $RUN_Complete[1][4], $MFT_RUN_Complete[1][4], $RUN_Sectors, $MFT_RUN_Sectors
Global $SI_CTime,$SI_ATime,$SI_MTime,$SI_RTime,$SI_FilePermission,$SI_USN,$Errors,$RecordSlackSpace
Global $IndxEntryNumberArr[1],$IndxMFTReferenceArr[1],$IndxMFTRefSeqNoArr[1],$IndxIndexFlagsArr[1],$IndxMFTReferenceOfParentArr[1],$IndxMFTParentRefSeqNoArr[1],$IndxCTimeArr[1],$IndxATimeArr[1],$IndxMTimeArr[1],$IndxRTimeArr[1],$IndxAllocSizeArr[1],$IndxRealSizeArr[1],$IndxFileFlagsArr[1],$IndxReparseTagArr[1],$IndxFileNameArr[1],$IndxSubNodeVCNArr[1],$IndxNameSpaceArr[1]
Global $IsDirectory = 0, $AttributesArr[18][4], $SIArr[14][2], $FNArr[15][1], $RecordHdrArr[16][2], $ObjectIDArr[25][2], $DataArr[21][2], $AttribListArr[9][2],$VolumeNameArr[2][2],$VolumeInformationArr[3][2],$RPArr[12][2],$LUSArr[3][2],$EAInfoArr[5][2],$EAArr[8][2],$IRArr[12][2],$IndxArr[20][2],$IndxObjIdOArr[1][27]
Global $HexDumpRecordSlack[1],$HexDumpRecord[1],$HexDumpHeader[1],$HexDumpStandardInformation[1],$HexDumpAttributeList[1],$HexDumpFileName[1],$HexDumpObjectId[1],$HexDumpSecurityDescriptor[1],$HexDumpVolumeName[1],$HexDumpVolumeInformation[1],$HexDumpData[1],$HexDumpIndexRoot[1],$HexDumpIndexAllocation[1],$HexDumpBitmap[1],$HexDumpReparsePoint[1],$HexDumpEaInformation[1],$HexDumpEa[1],$HexDumpPropertySet[1],$HexDumpLoggedUtilityStream[1],$HexDumpIndxRecord[1]
Global $FN_Number,$DATA_Number,$SI_Number,$ATTRIBLIST_Number,$OBJID_Number,$SECURITY_Number,$VOLNAME_Number,$VOLINFO_Number,$INDEXROOT_Number,$INDEXALLOC_Number,$BITMAP_Number,$REPARSEPOINT_Number,$EAINFO_Number,$EA_Number,$PROPERTYSET_Number,$LOGGEDUTILSTREAM_Number
Global $STANDARD_INFORMATION_ON,$ATTRIBUTE_LIST_ON,$FILE_NAME_ON,$OBJECT_ID_ON,$SECURITY_DESCRIPTOR_ON,$VOLUME_NAME_ON,$VOLUME_INFORMATION_ON,$DATA_ON,$INDEX_ROOT_ON,$INDEX_ALLOCATION_ON,$BITMAP_ON,$REPARSE_POINT_ON,$EA_INFORMATION_ON,$EA_ON,$PROPERTY_SET_ON,$LOGGED_UTILITY_STREAM_ON,$ATTRIBUTE_END_MARKER_ON
Global $GUID_ObjectID,$GUID_BirthVolumeID,$GUID_BirthObjectID,$GUID_BirthDomainID,$VOLUME_NAME_NAME,$VOL_INFO_NTFS_VERSION,$VOL_INFO_FLAGS,$INVALID_FILENAME
Global $DateTimeFormat = 6 ; YYYY-MM-DD HH:MM:SS:MSMSMS:NSNSNSNS = 2007-08-18 08:15:37:733:1234
Global $TimestampPrecision = 3, $PrecisionSeparator=".", $PrecisionSeparator2=""
Global $tDelta = _WinTime_GetUTCToLocalFileTimeDelta()
Global $TimestampErrorVal = "0000-00-00 00:00:00"
Global $TimeDiff = 5748192000000000
Global Const $RecordSignature = '46494C45' ; FILE signature
Global Const $RecordSignatureBad = '44414142' ; BAAD signature
Global Const $STANDARD_INFORMATION = '10000000'; Standard Information
Global Const $ATTRIBUTE_LIST = '20000000'
Global Const $FILE_NAME = '30000000' ; File Name
Global Const $OBJECT_ID = '40000000' ; Object ID
Global Const $SECURITY_DESCRIPTOR = '50000000'
Global Const $VOLUME_NAME = '60000000'
Global Const $VOLUME_INFORMATION = '70000000'
Global Const $DATA = '80000000' ; Data
Global Const $INDEX_ROOT = '90000000' ; Index Root
Global Const $INDEX_ALLOCATION = 'A0000000' ; Index Allocation
Global Const $BITMAP = 'B0000000' ; Bitmap
Global Const $REPARSE_POINT = 'C0000000'
Global Const $EA_INFORMATION = 'D0000000'
Global Const $EA = 'E0000000'
Global Const $PROPERTY_SET = 'F0000000'
Global Const $LOGGED_UTILITY_STREAM = '00010000'; 0x100
Global Const $ATTRIBUTE_END_MARKER = 'FFFFFFFF'
Global Const $ATTRIB_HEADER_FLAG_COMPRESSED = 0x0001
Global Const $ATTRIB_HEADER_FLAG_ENCRYPTED = 0x4000
Global Const $ATTRIB_HEADER_FLAG_SPARSE = 0x8000
Global Const $SI_FILE_PERM_READ_ONLY = 0x0001
Global Const $SI_FILE_PERM_HIDDEN = 0x0002
Global Const $SI_FILE_PERM_SYSTEM = 0x0004
;Global Const $SI_FILE_PERM_DIRECTORY = 0x0010
Global Const $SI_FILE_PERM_ARCHIVE = 0x0020
Global Const $SI_FILE_PERM_DEVICE = 0x0040
Global Const $SI_FILE_PERM_NORMAL = 0x0080
Global Const $SI_FILE_PERM_TEMPORARY = 0x0100
Global Const $SI_FILE_PERM_SPARSE_FILE = 0x0200
Global Const $SI_FILE_PERM_REPARSE_POINT = 0x0400
Global Const $SI_FILE_PERM_COMPRESSED = 0x0800
Global Const $SI_FILE_PERM_OFFLINE = 0x1000
Global Const $SI_FILE_PERM_NOT_INDEXED = 0x2000
Global Const $SI_FILE_PERM_ENCRYPTED = 0x4000
;Global Const $SI_FILE_PERM_VIRTUAL = 0x10000
Global Const $SI_FILE_PERM_DIRECTORY = 0x10000000
Global Const $SI_FILE_PERM_INDEX_VIEW = 0x20000000
Global Const $FileBasicInformation = 4
Global Const $FileInternalInformation = 6
Global Const $OBJ_CASE_INSENSITIVE = 0x00000040
Global Const $FILE_DIRECTORY_FILE = 0x00000002
Global Const $FILE_NON_DIRECTORY_FILE = 0x00000040
Global Const $FILE_RANDOM_ACCESS = 0x00000800
Global Const $tagIOSTATUSBLOCK = "dword Status;ptr Information"
Global Const $tagOBJECTATTRIBUTES = "ulong Length;hwnd RootDirectory;ptr ObjectName;ulong Attributes;ptr SecurityDescriptor;ptr SecurityQualityOfService"
Global Const $tagUNICODESTRING = "ushort Length;ushort MaximumLength;ptr Buffer"
Global Const $tagFILEINTERNALINFORMATION = "int IndexNumber;"
Global $NeedLock = 0
Global $FormattedTimestamp
Global $Timerstart = TimerInit()
ConsoleWrite("" & @CRLF)
ConsoleWrite("Starting MftRcrd by Joakim Schicht" & @CRLF)
ConsoleWrite("Version 1.0.0.41" & @CRLF)
ConsoleWrite("" & @CRLF)
_validate_parameters()
$TargetDrive = StringMid($cmdline[1],1,1)&":"
$filesystem = DriveGetFileSystem(StringMid($TargetDrive,1,1)&":\")
If $filesystem = "NTFS" Then
	ConsoleWrite("Filesystem on " & $TargetDrive & " is " & $filesystem & @CRLF)
Else
	ConsoleWrite("Error: filesystem on " & $TargetDrive & " is " & $filesystem & @CRLF)
	Exit
EndIf
If $TargetIsOffset Then
	_ReadBootSector($TargetDrive)
	$TargetDrive = StringMid($cmdline[1],1,StringInStr($cmdline[1],"?")-1)
	If StringLen($TargetDrive) = 1 Then $TargetDrive = $TargetDrive & ":"
	_ExtractSingleFile($TargetOffset)
	_DumpInfo()
	ConsoleWrite(@CRLF)
	_End($Timerstart)
	Exit
EndIf
If StringIsDigit(StringMid($cmdline[1],3)) Then
	ConsoleWrite("File IndexNumber: " & StringMid($cmdline[1],3) & @CRLF)
Else
	ConsoleWrite("File IndexNumber: " & _GetIndexNumber($cmdline[1], $IsDirectory) & @CRLF)
EndIf
If $cmdline[2] = "-d" OR $cmdline[2] = "-a" Then
	_SetIndexNumber()
	_DumpInfo()
	ConsoleWrite(@CRLF)
	_End($Timerstart)
	Exit
EndIf
ConsoleWrite("Error: something not right.." & @CRLF)
Exit

Func _validate_parameters()
Local $FileAttrib
If $cmdline[0] <> 5 Then
	ConsoleWrite("Error: Wrong number of parameters supplied: " & $cmdline[0] & @CRLF)
	ConsoleWrite("" & @CRLF)
	ConsoleWrite('Usage: "MFTRCRD param1 param2 param3 param4"' & @CRLF)
	ConsoleWrite("" & @CRLF)
	ConsoleWrite("param1 can be a valid file/folder path, an IndexNumber ($MFT record number), or volume and offset" & @CRLF)
	ConsoleWrite("param2 is a switch (-d|-a) " & @CRLF)
	ConsoleWrite("	-d means decode $MFT entry " & @CRLF)
	ConsoleWrite("	-a same as -d but also display formatted hexdump of $MFT record and individual attributes " & @CRLF)
	;ConsoleWrite("" & @CRLF)
	ConsoleWrite("param3 for specifying wether to hexdump complete INDX records and can be either indxdump=on or indxdump=off. Beware that indxdump=on may generate a significant amount of dump to console for certain directories." & @CRLF)
	;ConsoleWrite("" & @CRLF)
	ConsoleWrite("param4 is the MFT record size (1024 or 4096). Only relevant when param1 is an offset" & @CRLF)
	ConsoleWrite("param5 is a switch (-s|-w)." & @CRLF)
	ConsoleWrite("	-s means to skip extraction of the binary record" & @CRLF)
	ConsoleWrite("	-w will extract the record in binary format to the current directory" & @CRLF)
	ConsoleWrite("" & @CRLF)
	ConsoleWrite("Example for dumping an $MFT decode for boot.ini:" & @CRLF)
	ConsoleWrite("MFTRCRD C:\boot.ini -d indxdump=off 1024 -s" & @CRLF)
	ConsoleWrite("" & @CRLF)
	ConsoleWrite("Example for dumping an $MFT decode + the $MFT record and individual attributes for $MFT itself from the C: drive:" & @CRLF)
	ConsoleWrite("MFTRCRD C:0 -a indxdump=off 1024 -s" & @CRLF)
	ConsoleWrite("" & @CRLF)
	ConsoleWrite("Example for dumping an $MFT decode for $LogFile from the D: drive:" & @CRLF)
	ConsoleWrite("MFTRCRD D:2 -d indxdump=off 1024 -s" & @CRLF)
	ConsoleWrite("" & @CRLF)
	ConsoleWrite("Example for dumping an $MFT record decode + hexdump of its resolved INDX records for the root directory on C:, equivalent to the 'folder' named C:\" & @CRLF)
	ConsoleWrite("MFTRCRD C:5 -d indxdump=on 1024 -s" & @CRLF)
	ConsoleWrite("" & @CRLF)
	ConsoleWrite("Example for dumping an $MFT record decode from volume offset 0x100000 and with a record size of 4096 bytes" & @CRLF)
	ConsoleWrite("MFTRCRD C?0x100000 -d indxdump=off 4096 -s" & @CRLF)
	ConsoleWrite("" & @CRLF)
	ConsoleWrite("Example for dumping an $MFT record decode from volume offset 0x100000, with a record size of 4096 bytes, and saving the binary record in current directory" & @CRLF)
	ConsoleWrite("MFTRCRD C?0x100000 -d indxdump=off 4096 -w" & @CRLF)
	Exit
EndIf
If $cmdline[2] <> "-d" AND $cmdline[2] <> "-a" Then
	ConsoleWrite("Error: Wrong parameter 2 supplied: " & $cmdline[2] & @CRLF)
EndIf
$Sep = 1
If FileExists($cmdline[1]) <> 1 Then ;OR StringMid($cmdline[1],2,1) <> ":" OR StringMid($cmdline[1],2,1) <> "?" Then
	If StringInStr($cmdline[1],"?") Then
		$Sep = StringInStr($cmdline[1],"?")
		If StringMid($cmdline[1],$Sep+1,2) = "0x" Then
			$TargetOffset = Dec(StringMid($cmdline[1],$Sep+3),2)
			$TargetIsOffset = 1
		Else
			$TargetOffset = StringMid($cmdline[1],$Sep+1)
			$TargetIsOffset = 1
		EndIf
		If Not StringIsDigit($TargetOffset) Then
			ConsoleWrite("Error: Param1 omitted the offset part: " & $cmdline[1] & @CRLF)
			Exit
		EndIf
		If Not IsInt($TargetOffset/512) Then
			$TargetOffset = Floor($TargetOffset/512)*512
			ConsoleWrite("Target offset was not sector aligned and was corrected downwards to: 0x" & Hex($TargetOffset) & @CRLF)
			ConsoleWrite(@CRLF)
		Else
			ConsoleWrite("Target offset is: 0x" & Hex($TargetOffset) & @CRLF & @CRLF)
		EndIf
	EndIf
Else
	$FileAttrib = FileGetAttrib($cmdline[1])
	If $FileAttrib <> "D" Then
		$IsDirectory = 0
		ConsoleWrite("Target is a File" & @CRLF)
	EndIf
	If $FileAttrib = "D" Then
		$IsDirectory = 1
		ConsoleWrite("Target is a Directory" & @CRLF)
	EndIf
EndIf
If $Sep = 1 Then
	$file = $cmdline[1]
Else
	$file = StringMid($cmdline[1],1,$Sep-1)
EndIf
;ConsoleWrite("$file: " & $file & @CRLF)
If $cmdline[3] <> "indxdump=on" AND $cmdline[3] <> "indxdump=off" Then
	ConsoleWrite("Param 3 must be either indxdump=on or indxdump=off" & @CRLF)
	Exit
EndIf
If ($TargetIsOffset And $cmdline[4] <> 1024) AND ($TargetIsOffset And $cmdline[4] <> 4096) Then
	ConsoleWrite("Param 4 must be either 1024 or 4096 when decoding from volume offset" & @CRLF)
	Exit
EndIf
If $cmdline[5] <> "-s" AND $cmdline[5] <> "-w" Then
	ConsoleWrite("Error: Wrong parameter 5 supplied: " & $cmdline[5] & @CRLF)
	Exit
EndIf
If $cmdline[5] = "-s" Then $DoExtraction=0
If $cmdline[5] = "-w" Then $DoExtraction=1
Global $MFT_Record_Size = $cmdline[4]
EndFunc

Func NT_SUCCESS($status)
    If 0 <= $status And $status <= 0x7FFFFFFF Then
        Return True
    Else
        Return False
    EndIf
EndFunc

Func _FillZero($inp)
Local $inplen, $out, $tmp = ""
$inplen = StringLen($inp)
For $i = 1 To 4-$inplen
	$tmp &= "0"
Next
$out = $tmp & $inp
Return $out
EndFunc

Func _SetIndexNumber()
If StringIsDigit(StringMid($cmdline[1],3)) Then
	$bIndexNumber = StringMid($cmdline[1],3)
Else
	$bIndexNumber = _GetIndexNumber($cmdline[1], $IsDirectory)
EndIf
If $bIndexNumber = 0 Then
	$IsMFT = 1
	_ExtractSystemfile("$MFT")
Else
	_ExtractSystemfile($bIndexNumber)
EndIf
EndFunc

Func _GetIndexNumber($file, $mode)
	Local $IndexNumber
    Local $hNTDLL = DllOpen("ntdll.dll")
    Local $szName = DllStructCreate("wchar[260]")
    Local $sUS = DllStructCreate($tagUNICODESTRING)
    Local $sOA = DllStructCreate($tagOBJECTATTRIBUTES)
    Local $sISB = DllStructCreate($tagIOSTATUSBLOCK)
    Local $buffer = DllStructCreate("byte[16384]")
    Local $ret, $FILE_MODE
    If $mode == 0 Then
        $FILE_MODE = $FILE_NON_DIRECTORY_FILE
    Else
        $FILE_MODE = $FILE_DIRECTORY_FILE
    EndIf
    $file = "\??\" & $file
;	ConsoleWrite("$file: " & $file & @CRLF)
    DllStructSetData($szName, 1, $file)
    $ret = DllCall($hNTDLL, "none", "RtlInitUnicodeString", "ptr", DllStructGetPtr($sUS), "ptr", DllStructGetPtr($szName))
    DllStructSetData($sOA, "Length", DllStructGetSize($sOA))
    DllStructSetData($sOA, "RootDirectory", Chr(0))
    DllStructSetData($sOA, "ObjectName", DllStructGetPtr($sUS))
    DllStructSetData($sOA, "Attributes", $OBJ_CASE_INSENSITIVE)
    DllStructSetData($sOA, "SecurityDescriptor", Chr(0))
    DllStructSetData($sOA, "SecurityQualityOfService", Chr(0))
    $ret = DllCall($hNTDLL, "int", "NtOpenFile", "hwnd*", "", "dword", $GENERIC_READ, "ptr", DllStructGetPtr($sOA), "ptr", DllStructGetPtr($sISB), _
                                "ulong", $FILE_SHARE_READ, "ulong", BitOR($FILE_MODE, $FILE_RANDOM_ACCESS))
	If NT_SUCCESS($ret[0]) Then
;		ConsoleWrite("NtOpenFile: Success" & @CRLF)
	Else
		ConsoleWrite("Error: NtOpenFile Failed" & @CRLF)
		Exit
	EndIf
    Local $hFile = $ret[1]

    $ret = DllCall($hNTDLL, "int", "NtQueryInformationFile", "hwnd", $hFile, "ptr", DllStructGetPtr($sISB), "ptr", DllStructGetPtr($buffer), _
                                "int", 16384, "ptr", $FileInternalInformation)

    If NT_SUCCESS($ret[0]) Then
;        ConsoleWrite("NtQueryInformationFile: Success" & @CRLF)
        Local $pFSO = DllStructGetPtr($buffer)
		Local $sFSO = DllStructCreate($tagFILEINTERNALINFORMATION, $pFSO)
		Local $IndexNumber = DllStructGetData($sFSO, "IndexNumber")
    Else
        ConsoleWrite("Error: NtQueryInformationFile Failed" & @CRLF)
		Exit
    EndIf
    $ret = DllCall($hNTDLL, "int", "NtClose", "hwnd", $hFile)
    DllClose($hNTDLL)
	Return $IndexNumber
EndFunc

Func _ExtractSystemfile($TargetFile)
	Global $DataQ[1], $RUN_VCN[1], $RUN_Clusters[1]
	_ReadBootSector($TargetDrive)
	$BytesPerCluster = $SectorsPerCluster*$BytesPerSector
	$MFTEntry = _FindMFT(0)
	_DecodeMFTRecord($MFTEntry)
	_DecodeDataQEntry($DataQ[1])
	$MFTSize = $DATA_RealSize
;	_SetDataInfo(1)
	Global $RUN_VCN[1], $RUN_Clusters[1]
	_ExtractDataRuns()
	$MFT_RUN_VCN = $RUN_VCN
	$MFT_RUN_Clusters = $RUN_Clusters
	If $TargetFile = "$MFT" Then
		ConsoleWrite("TargetFile is $MFT" & @CRLF)
		_ExtractSingleFile(0)
	ElseIf $TargetFile = "ALL" Then
		ConsoleWrite("TargetFiles are ALL meta files" & @CRLF)
		For $i = 0 To 26
			If ($i > 15 AND $i < 24) Or ($i = 8) Then ContinueLoop		;exclude $BadClus (has volume size ADS)
			_ExtractSingleFile($i)
		Next
	Else
		_ExtractSingleFile(Int($TargetFile,2))
	EndIf
EndFunc

Func _ExtractSingleFile($MFTReferenceNumber)
	Global $DataQ[1]				;clear array
	_ClearVar()
	If $TargetIsOffset Then
		$MFTRecord = _DumpFromOffset($MFTReferenceNumber)
	Else
		$MFTRecord = _FindFileMFTRecord($MFTReferenceNumber)
	EndIf
	If $MFTRecord = "" Then
		ConsoleWrite("Target " & $MFTReferenceNumber & " not found" & @CRLF)
		Exit
	ElseIf StringMid($MFTRecord,3,8) <> $RecordSignature AND StringMid($MFTRecord,3,8) <> $RecordSignatureBad Then
		ConsoleWrite("Found record is not valid:" & @CRLF)
		ConsoleWrite(_HexEncode($MFTRecord) & @crlf)
		Exit
	EndIf
	_DecodeMFTRecord($MFTRecord)
	_DecodeNameQ($NameQ)
	If $DATA_ON = "FALSE" Then
;		ConsoleWrite("No $DATA attribute present for the file: " & $FN_FileName & @crlf)
		Return
	EndIf
	For $i = 1 To UBound($DataQ) - 1
		_DecodeDataQEntry($DataQ[$i])
;		_SetDataInfo($i)
		If $DATA_NonResidentFlag = '00' Then
;			_ExtractResidentFile($DATA_Name, $DATA_LengthOfAttribute)
		Else
			Global $RUN_VCN[1], $RUN_Clusters[1]
			$TotalClusters = $DATA_LastVCN - $DATA_StartVCN + 1
			$Size = $DATA_RealSize
			_ExtractDataRuns()
			If $TotalClusters * $BytesPerCluster >= $Size Then
;				ConsoleWrite(_ArrayToString($RUN_VCN) & @CRLF)
;				ConsoleWrite(_ArrayToString($RUN_Clusters) & @CRLF)
;				_ExtractFile()
			Else 		 ;code to handle attribute list
				$Flag = $IsCompressed		;preserve compression state
				For $j =$i + 1 To UBound($DataQ) - 1
					_DecodeDataQEntry($DataQ[$j])
					$TotalClusters += $DATA_LastVCN - $DATA_StartVCN + 1
					_ExtractDataRuns()
					If $TotalClusters * $BytesPerCluster >= $Size Then
						$DATA_RealSize = $Size
						$IsCompressed = $Flag
;						ConsoleWrite(_ArrayToString($RUN_VCN) & @CRLF)
;						ConsoleWrite(_ArrayToString($RUN_Clusters) & @CRLF)
;						_ExtractFile()
						ExitLoop
					EndIf
				Next
				$i=$j
			EndIf
		EndIf
	Next
Return
EndFunc

Func _ClearVar()
	$STANDARD_INFORMATION_ON = "FALSE"
	$ATTRIBUTE_LIST_ON = "FALSE"
	$FILE_NAME_ON = "FALSE"
	$OBJECT_ID_ON = "FALSE"
	$SECURITY_DESCRIPTOR_ON = "FALSE"
	$VOLUME_NAME_ON = "FALSE"
	$VOLUME_INFORMATION_ON = "FALSE"
	$DATA_ON = "FALSE"
	$INDEX_ROOT_ON = "FALSE"
	$INDEX_ALLOCATION_ON = "FALSE"
	$BITMAP_ON = "FALSE"
	$REPARSE_POINT_ON = "FALSE"
	$EA_INFORMATION_ON = "FALSE"
	$EA_ON = "FALSE"
	$PROPERTY_SET_ON = "FALSE"
	$LOGGED_UTILITY_STREAM_ON = "FALSE"
	$ATTRIBUTE_END_MARKER_ON = "FALSE"
	$SI_CTime = ""
	$SI_ATime = ""
	$SI_MTime = ""
	$SI_RTime = ""
	$SI_FilePermission = ""
	$SI_USN = ""
	$FN_CTime = ""
	$FN_ATime = ""
	$FN_MTime = ""
	$FN_RTime = ""
	$FN_AllocSize = ""
	$FN_RealSize = ""
	$FN_Flags = ""
	$FN_FileName = ""
	$DATA_NameLength = ""
	$DATA_NameRelativeOffset = ""
	$DATA_Flags = ""
	$DATA_NameSpace = ""
	$DATA_Name = ""
	$DATA_VCNs = ""
	$DATA_NonResidentFlag = ""
	$DATA_AllocatedSize = ""
	$DATA_RealSize = ""
	$DATA_InitializedStreamSize = ""
	$RecordSlackSpace = ""
	$FN_NameType = ""
	$FN_ParentReferenceNo = ""
	$FN_ParentSequenceNo = ""
	$DATA_LengthOfAttribute = ""
	$DATA_OffsetToAttribute = ""
	$DATA_IndexedFlag = ""
	$MSecTest = ""
	$CTimeTest = ""
	$SI_MaxVersions = ""
	$SI_VersionNumber = ""
	$SI_ClassID = ""
	$SI_OwnerID = ""
	$SI_SecurityID = ""
	$SI_HEADER_Flags = ""
	$GUID_ObjectID = ""
	$GUID_BirthVolumeID = ""
	$GUID_BirthObjectID = ""
	$GUID_BirthDomainID = ""
	$VOLUME_NAME_NAME = ""
	$VOL_INFO_NTFS_VERSION = ""
	$VOL_INFO_FLAGS = ""
	$INVALID_FILENAME = 0
	$DATA_Number = ""
	$Alternate_Data_Stream = ""
	$FileSizeBytes = ""
	$SI_CTime_tmp = ""
	$SI_ATime_tmp = ""
	$SI_MTime_tmp = ""
	$SI_RTime_tmp = ""
	$FN_CTime_tmp = ""
	$FN_ATime_tmp = ""
	$FN_MTime_tmp = ""
	$FN_RTime_tmp = ""
	$IntegrityCheck = ""
	$DATA_Length = ""
	$DATA_AttributeID = ""
	$DATA_OffsetToDataRuns = ""
	$DATA_Padding = ""
	$DATA_Name_Core = ""
	$ATTRIBLIST_Number = ""
	$FN_Number=""
	$DATA_Number=""
	$SI_Number=""
	$ATTRIBLIST_Number=""
	$OBJID_Number=""
	$SECURITY_Number=""
	$VOLNAME_Number=""
	$VOLINFO_Number=""
	$INDEXROOT_Number=""
	$INDEXALLOC_Number=""
	$BITMAP_Number=""
	$REPARSEPOINT_Number=""
	$EAINFO_Number=""
	$EA_Number=""
	$PROPERTYSET_Number=""
	$LOGGEDUTILSTREAM_Number=""
	$ReparseType=""
	$ReparseDataLength=""
	$ReparsePadding=""
	$ReparseSubstituteNameOffset=""
	$ReparseSubstituteNameLength=""
	$ReparsePrintNameOffset=""
	$ReparsePrintNameLength=""
EndFunc

Func _AttribHeaderFlags($AHinput)
Local $AHoutput = ""
If BitAND($AHinput,0x0001) Then $AHoutput &= 'COMPRESSED+'
If BitAND($AHinput,0x4000) Then $AHoutput &= 'ENCRYPTED+'
If BitAND($AHinput,0x8000) Then $AHoutput &= 'SPARSE+'
$AHoutput = StringTrimRight($AHoutput,1)
Return $AHoutput
EndFunc

Func _DecodeAttrList($TargetFile, $AttrList)
	Local $offset, $length, $nBytes, $hFile, $LocalAttribID, $LocalName, $ALRecordLength, $ALNameLength, $ALNameOffset
	If StringMid($AttrList, 17, 2) = "00" Then		;attribute list is in $AttrList
		$offset = Dec(_SwapEndian(StringMid($AttrList, 41, 4)))
		$List = StringMid($AttrList, $offset*2+1)
;		$IsolatedAttributeList = $list
	Else			;attribute list is found from data run in $AttrList
		$size = Dec(_SwapEndian(StringMid($AttrList, $offset*2 + 97, 16)))
		$offset = ($offset + Dec(_SwapEndian(StringMid($AttrList, $offset*2 + 65, 4))))*2
		$DataRun = StringMid($AttrList, $offset+1, StringLen($AttrList)-$offset)
;		ConsoleWrite("Attribute_List DataRun is " & $DataRun & @CRLF)
		Global $RUN_VCN[1], $RUN_Clusters[1]
		_ExtractDataRuns()
		$tBuffer = DllStructCreate("byte[" & $BytesPerCluster & "]")
		$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
		If $hFile = 0 Then
			ConsoleWrite("Error in function CreateFile when trying to locate Attribute List." & @CRLF)
			_WinAPI_CloseHandle($hFile)
			Exit
		EndIf
		$List = ""
		For $r = 1 To Ubound($RUN_VCN)-1
			_WinAPI_SetFilePointerEx($hFile, $RUN_VCN[$r]*$BytesPerCluster, $FILE_BEGIN)
			For $i = 1 To $RUN_Clusters[$r]
				_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $BytesPerCluster, $nBytes)
				$List &= StringTrimLeft(DllStructGetData($tBuffer, 1),2)
			Next
		Next
;		_DebugOut("***AttrList New:",$List)
		_WinAPI_CloseHandle($hFile)
		$List = StringMid($List, 1, $size*2)
	EndIf
	$IsolatedAttributeList = $list
	$offset=0
	$str=""
	While StringLen($list) > $offset*2
		$type=StringMid($List, ($offset*2)+1, 8)
		$ALRecordLength = Dec(_SwapEndian(StringMid($List, $offset*2 + 9, 4)))
		$ALNameLength = Dec(_SwapEndian(StringMid($List, $offset*2 + 13, 2)))
		$ALNameOffset = Dec(_SwapEndian(StringMid($List, $offset*2 + 15, 2)))
		$TestVCN = Dec(_SwapEndian(StringMid($List, $offset*2 + 17, 16)))
		$ref=Dec(_SwapEndian(StringMid($List, $offset*2 + 33, 8)))
		$LocalAttribID = "0x" & StringMid($List, $offset*2 + 49, 2) & StringMid($List, $offset*2 + 51, 2)
		If $ALNameLength > 0 Then
			$LocalName = StringMid($List, $offset*2 + 53, $ALNameLength*2*2)
			$LocalName = _UnicodeHexToStr($LocalName)
		Else
			$LocalName = ""
		EndIf
		If $ref <> $TargetFile Then		;new attribute
			If Not StringInStr($str, $ref) Then $str &= $ref & "-"
			$ALInnerCouner += 1
			ReDim $AttribListArr[9][$ALInnerCouner+1]
			$AttribListArr[0][$ALInnerCouner] = "Number " & $ALInnerCouner
			$AttribListArr[1][$ALInnerCouner] = $type
			$AttribListArr[2][$ALInnerCouner] = $ALRecordLength
			$AttribListArr[3][$ALInnerCouner] = $ALNameLength
			$AttribListArr[4][$ALInnerCouner] = $ALNameOffset
			$AttribListArr[5][$ALInnerCouner] = $TestVCN
			$AttribListArr[6][$ALInnerCouner] = $ref
			$AttribListArr[7][$ALInnerCouner] = $LocalName
			$AttribListArr[8][$ALInnerCouner] = $LocalAttribID
		EndIf
		If $type=$DATA Then
			$DataInAttrlist=1
			$IsolatedData=StringMid($List, ($offset*2)+1, $ALRecordLength*2)
			If $TestVCN=0 Then $DataIsResident=1
		EndIf
		$offset += Dec(_SwapEndian(StringMid($List, $offset*2 + 9, 4)))
	WEnd
	If $str = "" Then
		ConsoleWrite("No extra MFT records found" & @CRLF)
	Else
		$AttrQ = StringSplit(StringTrimRight($str,1), "-")
;		ConsoleWrite("Decode of $ATTRIBUTE_LIST reveiled extra MFT Records to be examined = " & _ArrayToString($AttrQ, @CRLF) & @CRLF)
	EndIf
EndFunc

Func _StripMftRecord($MFTEntry)
	$UpdSeqArrOffset = Dec(_SwapEndian(StringMid($MFTEntry,11,4)))
	$UpdSeqArrSize = Dec(_SwapEndian(StringMid($MFTEntry,15,4)))
	$UpdSeqArr = StringMid($MFTEntry,3+($UpdSeqArrOffset*2),$UpdSeqArrSize*2*2)
	;ConsoleWrite("$UpdSeqArr: " & $UpdSeqArr & @CRLF)
	If $MFT_Record_Size = 1024 Then
		Local $UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
		Local $UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
		Local $UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
		Local $RecordEnd1 = StringMid($MFTEntry,1023,4)
		Local $RecordEnd2 = StringMid($MFTEntry,2047,4)
		If $UpdSeqArrPart0 <> $RecordEnd1 OR $UpdSeqArrPart0 <> $RecordEnd2 Then
			ConsoleWrite("The record failed Fixup:" & @CRLF)
			ConsoleWrite(_HexEncode($MFTEntry))
			Return ""
		EndIf
		$MFTEntry = StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2
	ElseIf $MFT_Record_Size = 4096 Then
		Local $UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
		Local $UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
		Local $UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
		Local $UpdSeqArrPart3 = StringMid($UpdSeqArr,13,4)
		Local $UpdSeqArrPart4 = StringMid($UpdSeqArr,17,4)
		Local $UpdSeqArrPart5 = StringMid($UpdSeqArr,21,4)
		Local $UpdSeqArrPart6 = StringMid($UpdSeqArr,25,4)
		Local $UpdSeqArrPart7 = StringMid($UpdSeqArr,29,4)
		Local $UpdSeqArrPart8 = StringMid($UpdSeqArr,33,4)
		Local $RecordEnd1 = StringMid($MFTEntry,1023,4)
		Local $RecordEnd2 = StringMid($MFTEntry,2047,4)
		Local $RecordEnd3 = StringMid($MFTEntry,3071,4)
		Local $RecordEnd4 = StringMid($MFTEntry,4095,4)
		Local $RecordEnd5 = StringMid($MFTEntry,5119,4)
		Local $RecordEnd6 = StringMid($MFTEntry,6143,4)
		Local $RecordEnd7 = StringMid($MFTEntry,7167,4)
		Local $RecordEnd8 = StringMid($MFTEntry,8191,4)
		If $UpdSeqArrPart0 <> $RecordEnd1 OR $UpdSeqArrPart0 <> $RecordEnd2 OR $UpdSeqArrPart0 <> $RecordEnd3 OR $UpdSeqArrPart0 <> $RecordEnd4 OR $UpdSeqArrPart0 <> $RecordEnd5 OR $UpdSeqArrPart0 <> $RecordEnd6 OR $UpdSeqArrPart0 <> $RecordEnd7 OR $UpdSeqArrPart0 <> $RecordEnd8 Then
			ConsoleWrite("The record failed Fixup:" & @CRLF)
			ConsoleWrite(_HexEncode($MFTEntry))
			Return ""
		Else
			$MFTEntry =  StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2 & StringMid($MFTEntry,2051,1020) & $UpdSeqArrPart3 & StringMid($MFTEntry,3075,1020) & $UpdSeqArrPart4 & StringMid($MFTEntry,4099,1020) & $UpdSeqArrPart5 & StringMid($MFTEntry,5123,1020) & $UpdSeqArrPart6 & StringMid($MFTEntry,6147,1020) & $UpdSeqArrPart7 & StringMid($MFTEntry,7171,1020) & $UpdSeqArrPart8
		EndIf
	EndIf

	$RecordSize = Dec(_SwapEndian(StringMid($MFTEntry,51,8)),2)
	$HeaderSize = Dec(_SwapEndian(StringMid($MFTEntry,43,4)),2)
	$MFTEntry = StringMid($MFTEntry,$HeaderSize*2+3,($RecordSize-$HeaderSize-8)*2)        ;strip "0x..." and "FFFFFFFF..."
	Return $MFTEntry
EndFunc

Func _DecodeDataQEntry($Entry)
	$DATA_Length = StringMid($Entry,9,8)
	$DATA_Length = Dec(StringMid($DATA_Length,7,2) & StringMid($DATA_Length,5,2) & StringMid($DATA_Length,3,2) & StringMid($DATA_Length,1,2))
	$DATA_NonResidentFlag = StringMid($Entry,17,2)
	$DATA_NameLength = Dec(StringMid($Entry,19,2))
	$DATA_NameRelativeOffset = Dec(_SwapEndian(StringMid($Entry,21,4)))
	If $DATA_NameLength > 0 Then
		$DATA_Name = _UnicodeHexToStr(StringMid($Entry,$DATA_NameRelativeOffset*2 + 1,$DATA_NameLength*4))
		$DATA_Name_Core = $DATA_Name
		$DATA_Name = $FN_FileName & "[" & $DATA_Name & "]"		;must be ADS
	Else
		$DATA_Name = $FN_FileName
	EndIf
	$DATA_Flags = _SwapEndian(StringMid($Entry,25,4))
	$Flags = ""
	If $DATA_Flags = "0000" Then
		$Flags = "NORMAL"
	Else
		If BitAND($DATA_Flags,"0001") Then
			$IsCompressed = 1
			$Flags &= "COMPRESSED+"
		EndIf
		If BitAND($DATA_Flags,"4000") Then
			$IsEncrypted = 1
			$Flags &= "ENCRYPTED+"
		EndIf
		If BitAND($DATA_Flags,"8000") Then
			$IsSparse = 1
			$Flags &= "SPARSE+"
		EndIf
		$Flags = StringTrimRight($Flags,1)
	EndIf
	$DATA_AttributeID = StringMid($Entry,29,4)
	$DATA_AttributeID = StringMid($DATA_AttributeID,3,2) & StringMid($DATA_AttributeID,1,2)
	If $DATA_NonResidentFlag = '01' Then
		$DATA_StartVCN = Dec(_SwapEndian(StringMid($Entry,33,16)),2)
		$DATA_LastVCN = Dec(_SwapEndian(StringMid($Entry,49,16)),2)
		$DATA_VCNs = $DATA_LastVCN - $DATA_StartVCN
		$DATA_OffsetToDataRuns = StringMid($Entry,65,4)
		$DATA_OffsetToDataRuns = Dec(StringMid($DATA_OffsetToDataRuns,3,1) & StringMid($DATA_OffsetToDataRuns,3,1))
		$DATA_CompressionUnitSize = Dec(_SwapEndian(StringMid($Entry,69,4)))
		$DATA_Padding = StringMid($Entry,73,8)
		$DATA_Padding = StringMid($DATA_Padding,7,2) & StringMid($DATA_Padding,5,2) & StringMid($DATA_Padding,3,2) & StringMid($DATA_Padding,1,2)
		$DATA_AllocatedSize = Dec(_SwapEndian( StringMid($Entry,81,16)),2)
		$DATA_RealSize = Dec(_SwapEndian(StringMid($Entry,97,16)),2)
		$DATA_InitializedStreamSize = Dec(_SwapEndian(StringMid($Entry,113,16)),2)
		$RunListOffset = Dec(_SwapEndian(StringMid($Entry,65,4)))
		If $IsCompressed AND $RunListOffset = 72 Then $DATA_CompressedSize = Dec(_SwapEndian(StringMid($Entry,129,16)),2)
		$DataRun = StringMid($Entry,$RunListOffset*2+1,(StringLen($Entry)-$RunListOffset)*2)
	ElseIf $DATA_NonResidentFlag = '00' Then
		$DATA_LengthOfAttribute = StringMid($Entry,33,8)
		$DATA_LengthOfAttribute = Dec(_SwapEndian($DATA_LengthOfAttribute),2)
		$DATA_OffsetToAttribute = Dec(_SwapEndian(StringMid($Entry,41,4)))
		$DATA_IndexedFlag = Dec(StringMid($Entry,45,2))
		$DATA_Padding = StringMid($Entry,47,2)
		$DataRun = StringMid($Entry,$DATA_OffsetToAttribute*2+1,$DATA_LengthOfAttribute*2)
	EndIf
EndFunc

Func _DecodeMFTRecord($MFTEntry)
Local $MFTEntryOrig
Global $IndxEntryNumberArr[1],$IndxMFTReferenceArr[1],$IndxIndexFlagsArr[1],$IndxMFTReferenceOfParentArr[1],$IndxCTimeArr[1],$IndxATimeArr[1],$IndxMTimeArr[1],$IndxRTimeArr[1],$IndxAllocSizeArr[1],$IndxRealSizeArr[1],$IndxFileFlagsArr[1],$IndxReparseTagArr[1],$IndxFileNameArr[1],$IndxSubNodeVCNArr[1],$IndxNameSpaceArr[1]
Global $HexDumpRecordSlack[1],$HexDumpRecord[1],$HexDumpHeader[1],$HexDumpStandardInformation[1],$HexDumpAttributeList[1],$HexDumpFileName[1],$HexDumpObjectId[1],$HexDumpSecurityDescriptor[1],$HexDumpVolumeName[1],$HexDumpVolumeInformation[1],$HexDumpData[1],$HexDumpIndexRoot[1],$HexDumpIndexAllocation[1],$HexDumpBitmap[1],$HexDumpReparsePoint[1],$HexDumpEaInformation[1],$HexDumpEa[1],$HexDumpPropertySet[1],$HexDumpLoggedUtilityStream[1],$HexDumpIndxRecord[1]
Global $NameQ[5]		;clear name array
Global $TxfDataArr[8][2]
_Arrayadd($HexDumpRecord,StringMid($MFTEntry,3))
_SetArrays()
$HEADER_LSN = ""
$HEADER_SequenceNo = ""
$HEADER_Flags = ""
$HEADER_RecordRealSize = ""
$HEADER_RecordAllocSize = ""
$HEADER_BaseRecord = ""
$HEADER_NextAttribID = ""
$HEADER_MFTREcordNumber = ""
$UpdSeqArrOffset = Dec(_SwapEndian(StringMid($MFTEntry,11,4)))
$UpdSeqArrSize = Dec(_SwapEndian(StringMid($MFTEntry,15,4)))
$UpdSeqArr = StringMid($MFTEntry,3+($UpdSeqArrOffset*2),$UpdSeqArrSize*2*2)
;ConsoleWrite("$UpdSeqArr: " & $UpdSeqArr & @CRLF)
	If $MFT_Record_Size = 1024 Then
		Local $UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
		Local $UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
		Local $UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
		Local $RecordEnd1 = StringMid($MFTEntry,1023,4)
		Local $RecordEnd2 = StringMid($MFTEntry,2047,4)
		If $UpdSeqArrPart0 <> $RecordEnd1 OR $UpdSeqArrPart0 <> $RecordEnd2 Then
			_DebugOut("The record failed Fixup", $MFTEntry)
			Return ""
		EndIf
		$MFTEntry = StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2
	ElseIf $MFT_Record_Size = 4096 Then
		Local $UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
		Local $UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
		Local $UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
		Local $UpdSeqArrPart3 = StringMid($UpdSeqArr,13,4)
		Local $UpdSeqArrPart4 = StringMid($UpdSeqArr,17,4)
		Local $UpdSeqArrPart5 = StringMid($UpdSeqArr,21,4)
		Local $UpdSeqArrPart6 = StringMid($UpdSeqArr,25,4)
		Local $UpdSeqArrPart7 = StringMid($UpdSeqArr,29,4)
		Local $UpdSeqArrPart8 = StringMid($UpdSeqArr,33,4)
		Local $RecordEnd1 = StringMid($MFTEntry,1023,4)
		Local $RecordEnd2 = StringMid($MFTEntry,2047,4)
		Local $RecordEnd3 = StringMid($MFTEntry,3071,4)
		Local $RecordEnd4 = StringMid($MFTEntry,4095,4)
		Local $RecordEnd5 = StringMid($MFTEntry,5119,4)
		Local $RecordEnd6 = StringMid($MFTEntry,6143,4)
		Local $RecordEnd7 = StringMid($MFTEntry,7167,4)
		Local $RecordEnd8 = StringMid($MFTEntry,8191,4)
		If $UpdSeqArrPart0 <> $RecordEnd1 OR $UpdSeqArrPart0 <> $RecordEnd2 OR $UpdSeqArrPart0 <> $RecordEnd3 OR $UpdSeqArrPart0 <> $RecordEnd4 OR $UpdSeqArrPart0 <> $RecordEnd5 OR $UpdSeqArrPart0 <> $RecordEnd6 OR $UpdSeqArrPart0 <> $RecordEnd7 OR $UpdSeqArrPart0 <> $RecordEnd8 Then
			_DebugOut("The record failed Fixup", $MFTEntry)
			Return ""
		Else
			$MFTEntry =  StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2 & StringMid($MFTEntry,2051,1020) & $UpdSeqArrPart3 & StringMid($MFTEntry,3075,1020) & $UpdSeqArrPart4 & StringMid($MFTEntry,4099,1020) & $UpdSeqArrPart5 & StringMid($MFTEntry,5123,1020) & $UpdSeqArrPart6 & StringMid($MFTEntry,6147,1020) & $UpdSeqArrPart7 & StringMid($MFTEntry,7171,1020) & $UpdSeqArrPart8
		EndIf
	EndIf

Local $MFTHeader = StringMid($MFTEntry,1,2+32)
$HEADER_LSN = StringMid($MFTEntry,19,16)
$HEADER_LSN = Dec(_SwapEndian($HEADER_LSN),2)
$HEADER_SequenceNo = Dec(_SwapEndian(StringMid($MFTEntry,35,4)))
$Header_HardLinkCount = StringMid($MFTEntry,39,4)
$Header_HardLinkCount = Dec(StringMid($Header_HardLinkCount,3,2) & StringMid($Header_HardLinkCount,1,2))
$HEADER_Flags = StringMid($MFTEntry,47,4)
	Select
		Case $HEADER_Flags = '0000'
			$HEADER_Flags = 'FILE'
			$RecordActive = 'DELETED'
		Case $HEADER_Flags = '0100'
			$HEADER_Flags = 'FILE'
			$RecordActive = 'ALLOCATED'
		Case $HEADER_Flags = '0200'
			$HEADER_Flags = 'FOLDER'
			$RecordActive = 'DELETED'
		Case $HEADER_Flags = '0300'
			$HEADER_Flags = 'FOLDER'
			$RecordActive = 'ALLOCATED'
		Case $HEADER_Flags = '0400'
			$HEADER_Flags = 'FILE+USNJRNL+DISABLED'
			$RecordActive = 'ALLOCATED'
		Case $HEADER_Flags = '0500'
			$HEADER_Flags = 'FILE+USNJRNL+ENABLED'
			$RecordActive = 'ALLOCATED'
		Case $HEADER_Flags = '0900'
			$HEADER_Flags = 'FILE+INDEX_SECURITY'
			$RecordActive = 'ALLOCATED'
		Case $HEADER_Flags = '0D00'
			$HEADER_Flags = 'FILE+INDEX_OTHER'
			$RecordActive = 'ALLOCATED'
		Case Else
			$HEADER_Flags = 'UNKNOWN'
			$RecordActive = 'UNKNOWN'
	EndSelect
$HEADER_RecordRealSize = Dec(_SwapEndian(StringMid($MFTEntry,51,8)),2)
$HEADER_RecordAllocSize = Dec(_SwapEndian(StringMid($MFTEntry,59,8)),2)
$HEADER_BaseRecord = Dec(_SwapEndian(StringMid($MFTEntry,67,12)),2) ;Base file record
$HEADER_BaseRecSeqNo = Dec(_SwapEndian(StringMid($MFTEntry,79,4)),2)
$HEADER_NextAttribID = StringMid($MFTEntry,83,4)
$HEADER_NextAttribID = "0x"&_SwapEndian($HEADER_NextAttribID)
If $UpdSeqArrOffset = 48 Then
	$HEADER_MFTREcordNumber = Dec(_SwapEndian(StringMid($MFTEntry,91,8)),2)
Else
	$HEADER_MFTREcordNumber = "NT style"
EndIf
$AttributeOffset = (Dec(StringMid($MFTEntry,43,2))*2)+3
$RecordHdrArr[0][1] = "Field value"
$RecordHdrArr[1][1] = $UpdSeqArrOffset
$RecordHdrArr[2][1] = $UpdSeqArrSize
$RecordHdrArr[3][1] = $HEADER_LSN
$RecordHdrArr[4][1] = $HEADER_SequenceNo
$RecordHdrArr[5][1] = $Header_HardLinkCount
$RecordHdrArr[6][1] = $AttributeOffset
$RecordHdrArr[7][1] = $HEADER_Flags&"+"&$RecordActive
$RecordHdrArr[8][1] = $HEADER_RecordRealSize
$RecordHdrArr[9][1] = $HEADER_RecordAllocSize
$RecordHdrArr[10][1] = $HEADER_BaseRecord
$RecordHdrArr[11][1] = $HEADER_BaseRecSeqNo
$RecordHdrArr[12][1] = $HEADER_NextAttribID
$RecordHdrArr[13][1] = $HEADER_MFTREcordNumber
$RecordHdrArr[14][1] = $UpdSeqArrPart0
$RecordHdrArr[15][1] = $UpdSeqArrPart1&$UpdSeqArrPart2
_Arrayadd($HexDumpHeader,StringMid($MFTEntry,3,$AttributeOffset-3))
While 1
	$AttributeType = StringMid($MFTEntry,$AttributeOffset,8)
	$AttributeSize = StringMid($MFTEntry,$AttributeOffset+8,8)
	$AttributeSize = Dec(_SwapEndian($AttributeSize),2)
	Select
		Case $AttributeType = $STANDARD_INFORMATION
			$STANDARD_INFORMATION_ON = "TRUE"
			$SI_Number += 1
			ReDim $SIArr[14][$SI_Number+1]
			_Get_StandardInformation($MFTEntry,$AttributeOffset,$AttributeSize,$SI_Number)
			ReDim $HexDumpStandardInformation[$SI_Number]
			_Arrayadd($HexDumpStandardInformation,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $ATTRIBUTE_LIST
			$ATTRIBUTE_LIST_ON = "TRUE"
			$ATTRIBLIST_Number += 1
			$MFTEntryOrig = $MFTEntry
			$AttrList = StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2)
			_DecodeAttrList($HEADER_MFTRecordNumber, $AttrList)		;produces $AttrQ - extra record list
			$str = ""
			For $i = 1 To $AttrQ[0]
				$record = _FindFileMFTRecord($AttrQ[$i])
			   $str &= _StripMftRecord($record)		;no header or end marker
			Next
			$str &= "FFFFFFFF"		;add end marker
			$MFTEntry = StringMid($MFTEntry,1,($HEADER_RecordRealSize-8)*2+2) & $str       ;strip "FFFFFFFF..." first
			ReDim $HexDumpAttributeList[$ATTRIBLIST_Number]
			_Arrayadd($HexDumpAttributeList,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
;			_DebugOut("***AttrList",StringMid($MFTEntry,3))
   		Case $AttributeType = $FILE_NAME
			$FILE_NAME_ON = "TRUE"
			$FN_Number += 1
			$attr = StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2)
			$NameSpace = StringMid($attr,179,2)
			Select
				Case $NameSpace = "00"	;POSIX
					$NameQ[2] = $attr
				Case $NameSpace = "01"	;WIN32
					$NameQ[4] = $attr
				Case $NameSpace = "02"	;DOS
					$NameQ[1] = $attr
				Case $NameSpace = "03"	;DOS+WIN32
					$NameQ[3] = $attr
			EndSelect
			ReDim $FNArr[15][$FN_Number+1]
			_Get_FileName($MFTEntry,$AttributeOffset,$AttributeSize,$FN_Number)
			ReDim $HexDumpFileName[$FN_Number]
			_Arrayadd($HexDumpFileName,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $OBJECT_ID
			$OBJECT_ID_ON = "TRUE"
			$OBJID_Number += 1
			ReDim $ObjectIDArr[25][$OBJID_Number+1]
			_Get_ObjectID($MFTEntry,$AttributeOffset,$AttributeSize)
			ReDim $HexDumpObjectId[$OBJID_Number]
			_Arrayadd($HexDumpObjectId,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $SECURITY_DESCRIPTOR
			$SECURITY_DESCRIPTOR_ON = "TRUE"
			$SECURITY_Number += 1
;			_Get_SecurityDescriptor()
			ReDim $HexDumpSecurityDescriptor[$SECURITY_Number]
			_Arrayadd($HexDumpSecurityDescriptor,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $VOLUME_NAME
			$VOLUME_NAME_ON = "TRUE"
			$VOLNAME_Number += 1
			ReDim $VolumeNameArr[2][$VOLNAME_Number+1]
			_Get_VolumeName($MFTEntry,$AttributeOffset,$AttributeSize,$VOLNAME_Number)
			ReDim $HexDumpVolumeName[$VOLNAME_Number]
			_Arrayadd($HexDumpVolumeName,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $VOLUME_INFORMATION
			$VOLUME_INFORMATION_ON = "TRUE"
			$VOLINFO_Number += 1
			ReDim $VolumeInformationArr[3][$VOLINFO_Number+1]
			_Get_VolumeInformation($MFTEntry,$AttributeOffset,$AttributeSize,$VOLINFO_Number)
			ReDim $HexDumpVolumeInformation[$VOLINFO_Number]
			_Arrayadd($HexDumpVolumeInformation,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $DATA
			$DATA_ON = "TRUE"
			$DATA_Number += 1
			ReDim $DataArr[21][$DATA_Number+1]
			_Get_Data($MFTEntry,$AttributeOffset,$AttributeSize,$DATA_Number)
			_ArrayAdd($DataQ, StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
			ReDim $HexDumpData[$DATA_Number]
			_Arrayadd($HexDumpData,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
			If $HEADER_MFTREcordNumber = 4 Then
				$CoreData = _GetAttributeEntry(StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
				$CoreDataChunk = $CoreData[0]
				$CoreDataName = $CoreData[1]
				_Decode_AttrDef($CoreDataChunk)
			EndIf
		Case $AttributeType = $INDEX_ROOT
;			$INDEX_ROOT_ON = "TRUE"
			$INDEXROOT_Number += 1
			ReDim $IRArr[12][$INDEXROOT_Number+1]
			$CoreIndexRoot = _GetAttributeEntry(StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
			$CoreIndexRootChunk = $CoreIndexRoot[0]
			$CoreIndexRootName = $CoreIndexRoot[1]
			If $CoreIndexRootName = "$I30" Then
				$INDEX_ROOT_ON = "TRUE"
				_Get_IndexRoot($CoreIndexRootChunk,$INDEXROOT_Number,$CoreIndexRootName,1)
			ElseIf $CoreIndexRootName = "$O" And $FN_FileName = "$ObjId" Then
				$INDEX_ROOT_ON = "TRUE"
				_Get_IndexRoot($CoreIndexRootChunk,$INDEXROOT_Number,$CoreIndexRootName,2)
			EndIf
			ReDim $HexDumpIndexRoot[$INDEXROOT_Number]
			_Arrayadd($HexDumpIndexRoot,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $INDEX_ALLOCATION
;			$INDEX_ALLOCATION_ON = "TRUE"
			$INDEXALLOC_Number += 1
;			ReDim $IndxArr[20][$INDEXALLOC_Number+1]
			ReDim $HexDumpIndxRecord[$INDEXALLOC_Number]
			$CoreIndexAllocation = _GetAttributeEntry(StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
			$CoreIndexAllocationChunk = $CoreIndexAllocation[0]
			$CoreIndexAllocationName = $CoreIndexAllocation[1]
			_Arrayadd($HexDumpIndxRecord,$CoreIndexAllocationChunk)
			If $CoreIndexAllocationName = "$I30" Then
				$INDEX_ALLOCATION_ON = "TRUE"
				_Get_IndexAllocation($CoreIndexAllocationChunk,$INDEXALLOC_Number,$CoreIndexAllocationName,1)
			ElseIf $CoreIndexRootName = "$O" And $FN_FileName = "$ObjId" Then
				$INDEX_ALLOCATION_ON = "TRUE"
				_Get_IndexAllocation($CoreIndexAllocationChunk,$INDEXALLOC_Number,$CoreIndexAllocationName,2)
			EndIf
			ReDim $HexDumpIndexAllocation[$INDEXALLOC_Number]
			_Arrayadd($HexDumpIndexAllocation,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $BITMAP
			$BITMAP_ON = "TRUE"
			$BITMAP_Number += 1
			$CoreBitmap = _GetAttributeEntry(StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
			$CoreBitmapChunk = $CoreBitmap[0]
			$CoreBitmapName = $CoreBitmap[1]
			_Get_Bitmap($CoreBitmapChunk,$BITMAP_Number,$CoreBitmapName)
			ReDim $HexDumpBitmap[$BITMAP_Number]
			_Arrayadd($HexDumpBitmap,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $REPARSE_POINT
			$REPARSE_POINT_ON = "TRUE"
			$REPARSEPOINT_Number += 1
			ReDim $RPArr[12][$REPARSEPOINT_Number+1]
			$CoreReparsePoint = _GetAttributeEntry(StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
			$CoreReparsePointChunk = $CoreReparsePoint[0]
			$CoreReparsePointName = $CoreReparsePoint[1]
			_Get_ReparsePoint($CoreReparsePointChunk,$REPARSEPOINT_Number,$CoreReparsePointName)
			ReDim $HexDumpReparsePoint[$REPARSEPOINT_Number]
			_Arrayadd($HexDumpReparsePoint,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $EA_INFORMATION
			$EA_INFORMATION_ON = "TRUE"
			$EAINFO_Number += 1
			ReDim $EAInfoArr[5][$EAINFO_Number+1]
			$CoreEaInformation = _GetAttributeEntry(StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
			$CoreEaInformationChunk = $CoreEaInformation[0]
			$CoreEaInformationName = $CoreEaInformation[1]
			_Get_EaInformation($CoreEaInformationChunk,$EAINFO_Number,$CoreEaInformationName)
			ReDim $HexDumpEaInformation[$EAINFO_Number]
			_Arrayadd($HexDumpEaInformation,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $EA
			$EA_ON = "TRUE"
			$EA_Number += 1
			ReDim $EAArr[8][$EA_Number+1]
			$CoreEa = _GetAttributeEntry(StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
			$CoreEaChunk = $CoreEa[0]
			$CoreEaName = $CoreEa[1]
			_Get_Ea($CoreEaChunk,$EA_Number,$CoreEaName)
			ReDim $HexDumpEa[$EA_Number]
			_Arrayadd($HexDumpEa,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $PROPERTY_SET
			$PROPERTY_SET_ON = "TRUE"
			$PROPERTYSET_Number += 1
;			_Get_PropertySet()
			ReDim $HexDumpPropertySet[$PROPERTYSET_Number]
			_Arrayadd($HexDumpPropertySet,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $LOGGED_UTILITY_STREAM
			$LOGGED_UTILITY_STREAM_ON = "TRUE"
			$LOGGEDUTILSTREAM_Number += 1
			ReDim $LUSArr[3][$LOGGEDUTILSTREAM_Number+1]
			$CoreLoggedUtilityStream = _GetAttributeEntry(StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
			$CoreLoggedUtilityStreamChunk = $CoreLoggedUtilityStream[0]
			$CoreLoggedUtilityStreamName = $CoreLoggedUtilityStream[1]
			_Get_LoggedUtilityStream($CoreLoggedUtilityStreamChunk,$LOGGEDUTILSTREAM_Number,$CoreLoggedUtilityStreamName)
			ReDim $HexDumpLoggedUtilityStream[$LOGGEDUTILSTREAM_Number]
			_Arrayadd($HexDumpLoggedUtilityStream,StringMid($MFTEntry,$AttributeOffset,$AttributeSize*2))
		Case $AttributeType = $ATTRIBUTE_END_MARKER
			If $ATTRIBUTE_LIST_ON = "TRUE" Then
				_Arrayadd($HexDumpRecordSlack,StringMid($MFTEntryOrig,($HEADER_RecordRealSize*2)+3))
			Else
				_Arrayadd($HexDumpRecordSlack,StringMid($MFTEntry,($HEADER_RecordRealSize*2)+3))
			EndIf
			ExitLoop
	EndSelect
	$AttributeOffset += $AttributeSize*2
WEnd
$AttributesArr[1][2] = $STANDARD_INFORMATION_ON
$AttributesArr[2][2] = $ATTRIBUTE_LIST_ON
$AttributesArr[3][2] = $FILE_NAME_ON
$AttributesArr[4][2] = $OBJECT_ID_ON
$AttributesArr[5][2] = $SECURITY_DESCRIPTOR_ON
$AttributesArr[6][2] = $VOLUME_NAME_ON
$AttributesArr[7][2] = $VOLUME_INFORMATION_ON
$AttributesArr[8][2] = $DATA_ON
$AttributesArr[9][2] = $INDEX_ROOT_ON
$AttributesArr[10][2] = $INDEX_ALLOCATION_ON
$AttributesArr[11][2] = $BITMAP_ON
$AttributesArr[12][2] = $REPARSE_POINT_ON
$AttributesArr[13][2] = $EA_INFORMATION_ON
$AttributesArr[14][2] = $EA_ON
$AttributesArr[15][2] = $PROPERTY_SET_ON
$AttributesArr[16][2] = $LOGGED_UTILITY_STREAM_ON
$AttributesArr[17][2] = $ATTRIBUTE_END_MARKER_ON
$AttributesArr[1][3] = $SI_Number
$AttributesArr[2][3] = $ATTRIBLIST_Number
$AttributesArr[3][3] = $FN_Number
$AttributesArr[4][3] = $OBJID_Number
$AttributesArr[5][3] = $SECURITY_Number
$AttributesArr[6][3] = $VOLNAME_Number
$AttributesArr[7][3] = $VOLINFO_Number
$AttributesArr[8][3] = $DATA_Number
$AttributesArr[9][3] = $INDEXROOT_Number
$AttributesArr[10][3] = $INDEXALLOC_Number
$AttributesArr[11][3] = $BITMAP_Number
$AttributesArr[12][3] = $REPARSEPOINT_Number
$AttributesArr[13][3] = $EAINFO_Number
$AttributesArr[14][3] = $EA_Number
$AttributesArr[15][3] = $PROPERTYSET_Number
$AttributesArr[16][3] = $LOGGEDUTILSTREAM_Number
$AttributesArr[17][3] = 1
EndFunc

Func _DecodeNameQ($NameQ)
	For $name = 1 To UBound($NameQ) - 1
		$NameString = $NameQ[$name]
		If $NameString = "" Then ContinueLoop
		$FN_AllocSize = Dec(_SwapEndian(StringMid($NameString,129,16)),2)
		$FN_RealSize = Dec(_SwapEndian(StringMid($NameString,145,16)),2)
		$FN_NameLength = Dec(StringMid($NameString,177,2))
		$FN_NameSpace = StringMid($NameString,179,2)
		Select
			Case $FN_NameSpace = '00'
				$FN_NameSpace = 'POSIX'
			Case $FN_NameSpace = '01'
				$FN_NameSpace = 'WIN32'
			Case $FN_NameSpace = '02'
				$FN_NameSpace = 'DOS'
			Case $FN_NameSpace = '03'
				$FN_NameSpace = 'DOS+WIN32'
			Case Else
				$FN_NameSpace = 'UNKNOWN'
		EndSelect
		$FN_FileName = StringMid($NameString,181,$FN_NameLength*4)
		$FN_FileName = _UnicodeHexToStr($FN_FileName)
		If StringLen($FN_FileName) <> $FN_NameLength Then $INVALID_FILENAME = 1
	Next
	Return
EndFunc

Func _ExtractDataRuns()
	$r=UBound($RUN_Clusters)
	$i=1
	$RUN_VCN[0] = 0
	$BaseVCN = $RUN_VCN[0]
	If $DataRun = "" Then $DataRun = "00"
	Do
		$RunListID = StringMid($DataRun,$i,2)
		If $RunListID = "00" Then ExitLoop
		$i += 2
		$RunListClustersLength = Dec(StringMid($RunListID,2,1))
		$RunListVCNLength = Dec(StringMid($RunListID,1,1))
		$RunListClusters = Dec(_SwapEndian(StringMid($DataRun,$i,$RunListClustersLength*2)),2)
		$i += $RunListClustersLength*2
		$RunListVCN = _SwapEndian(StringMid($DataRun, $i, $RunListVCNLength*2))
		;next line handles positive or negative move
		$BaseVCN += Dec($RunListVCN,2)-(($r>1) And (Dec(StringMid($RunListVCN,1,1))>7))*Dec(StringMid("10000000000000000",1,$RunListVCNLength*2+1),2)
		If $RunListVCN <> "" Then
			$RunListVCN = $BaseVCN
		Else
			$RunListVCN = 0			;$RUN_VCN[$r-1]		;0
		EndIf
		If (($RunListVCN=0) And ($RunListClusters>16) And (Mod($RunListClusters,16)>0)) Then
		 ;may be sparse section at end of Compression Signature
			_ArrayAdd($RUN_Clusters,Mod($RunListClusters,16))
			_ArrayAdd($RUN_VCN,$RunListVCN)
			$RunListClusters -= Mod($RunListClusters,16)
			$r += 1
		ElseIf (($RunListClusters>16) And (Mod($RunListClusters,16)>0)) Then
		 ;may be compressed data section at start of Compression Signature
			_ArrayAdd($RUN_Clusters,$RunListClusters-Mod($RunListClusters,16))
			_ArrayAdd($RUN_VCN,$RunListVCN)
			$RunListVCN += $RUN_Clusters[$r]
			$RunListClusters = Mod($RunListClusters,16)
			$r += 1
		EndIf
	  ;just normal or sparse data
		_ArrayAdd($RUN_Clusters,$RunListClusters)
		_ArrayAdd($RUN_VCN,$RunListVCN)
		$r += 1
		$i += $RunListVCNLength*2
	Until $i > StringLen($DataRun)
EndFunc

Func _FindFileMFTRecord($TargetFile)
	Local $nBytes, $TmpOffset, $Counter, $Counter2, $RecordJumper, $TargetFileDec, $RecordsTooMuch
	$tBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")
	$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
	If $hFile = 0 Then
		ConsoleWrite("Error in function _WinAPI_CreateFile when trying to locate target file." & @CRLF)
		_WinAPI_CloseHandle($hFile)
		Exit
	EndIf
	$TargetFile = _DecToLittleEndian($TargetFile)
	$TargetFileDec = Dec(_SwapEndian($TargetFile),2)
	Local $RecordsDivisor = $MFT_Record_Size/512
	For $i = 1 To UBound($MFT_RUN_Clusters)-1
		$CurrentClusters = $MFT_RUN_Clusters[$i]
		$RecordsInCurrentRun = ($CurrentClusters*$SectorsPerCluster)/$RecordsDivisor
		$Counter+=$RecordsInCurrentRun
		If $Counter>$TargetFileDec Then
			ExitLoop
		EndIf
	Next
	$TryAt = $Counter-$RecordsInCurrentRun
	$TryAtArrIndex = $i
	$RecordsPerCluster = $SectorsPerCluster/$RecordsDivisor
	Do
		$RecordJumper+=$RecordsPerCluster
		$Counter2+=1
		$Final = $TryAt+$RecordJumper
	Until $Final>=$TargetFileDec
	$RecordsTooMuch = $Final-$TargetFileDec
	_WinAPI_SetFilePointerEx($hFile, $MFT_RUN_VCN[$i]*$BytesPerCluster+($Counter2*$BytesPerCluster)-($RecordsTooMuch*$MFT_Record_Size), $FILE_BEGIN)
	_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
	$record = DllStructGetData($tBuffer, 1)
	If StringMid($record,91,8) = $TargetFile Then
		$TmpOffset = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $hFile, 'int64', 0, 'int64*', 0, 'dword', 1)
		$FoundOffset = Int($TmpOffset[3])-Int($MFT_Record_Size)
		ConsoleWrite("Record number: " & Dec(_SwapEndian($TargetFile),2) & " found at disk offset: 0x" & Hex($FoundOffset) & @CRLF)
		If $DoExtraction Then
			Local $hDump = _WinAPI_CreateFile("\\.\" & @ScriptDir & "\Record_" & StringLeft($TargetDrive,1) & "_" & Dec(_SwapEndian($TargetFile),2) & ".bin", 1, 6, 6)
			_WinAPI_WriteFile($hDump, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
			_WinAPI_CloseHandle($hDump)
		EndIf
		_WinAPI_CloseHandle($hFile)
		Return $record
	Else
		_WinAPI_CloseHandle($hFile)
		Return ""
	EndIf
EndFunc

Func _FindMFT($TargetFile)
	Local $nBytes
	$tBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")
	$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
	If $hFile = 0 Then
		ConsoleWrite("Error in function CreateFile when trying to locate MFT." & @CRLF)
		Exit
	EndIf
	_WinAPI_SetFilePointerEx($hFile, $MFT_Offset)
	_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $MFT_Record_Size, $nBytes)
	_WinAPI_CloseHandle($hFile)
	$record = DllStructGetData($tBuffer, 1)
	If NOT StringMid($record,1,8) = '46494C45' Then
		ConsoleWrite("MFT record signature not found. "& @crlf)
		Return ""
	EndIf
	If StringMid($record,47,4) = "0100" AND Dec(_SwapEndian(StringMid($record,91,8))) = $TargetFile Then
;		ConsoleWrite("MFT record found" & @CRLF)
		Return $record		;returns record for MFT
	EndIf
	ConsoleWrite("MFT record not found" & @CRLF)
	Return ""
EndFunc

Func _DecToLittleEndian($DecimalInput)
	Return _SwapEndian(Hex($DecimalInput,8))
EndFunc

Func _SwapEndian($iHex)
	Return StringMid(Binary(Dec($iHex,2)),3, StringLen($iHex))
EndFunc

Func _UnicodeHexToStr($FileName)
	$str = ""
	For $i = 1 To StringLen($FileName) Step 4
		$str &= ChrW(Dec(_SwapEndian(StringMid($FileName, $i, 4))))
	Next
	Return $str
EndFunc

Func _DebugOut($text, $var)
	ConsoleWrite("Debug output for " & $text & @CRLF)
	For $i=1 To StringLen($var) Step 32
		$str=""
		For $n=0 To 15
			$str &= StringMid($var, $i+$n*2, 2) & " "
			if $n=7 then $str &= "- "
		Next
		ConsoleWrite($str & @CRLF)
	Next
EndFunc

Func _ReadBootSector($TargetDrive)
	Local $nbytes
	$tBuffer=DllStructCreate("byte[512]")
	$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive,2,2,7)
	If $hFile = 0 then
		ConsoleWrite("Error in function CreateFile for: " & "\\.\" & $TargetDrive & @crlf)
		Exit
	EndIf
	$read = _WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), 512, $nBytes)
	If $read = 0 then
		ConsoleWrite("Error in function _WinAPI_ReadFile for: " & "\\.\" & $TargetDrive & @crlf)
		Return
	EndIf
	_WinAPI_CloseHandle($hFile)
   ; Good starting point from KaFu & tranexx at the AutoIt forum
	$tBootSectorSections = DllStructCreate("align 1;" & _
								"byte Jump[3];" & _
								"char SystemName[8];" & _
								"ushort BytesPerSector;" & _
								"ubyte SectorsPerCluster;" & _
								"ushort ReservedSectors;" & _
								"ubyte[3];" & _
								"ushort;" & _
								"ubyte MediaDescriptor;" & _
								"ushort;" & _
								"ushort SectorsPerTrack;" & _
								"ushort NumberOfHeads;" & _
								"dword HiddenSectors;" & _
								"dword;" & _
								"dword;" & _
								"int64 TotalSectors;" & _
								"int64 LogicalClusterNumberforthefileMFT;" & _
								"int64 LogicalClusterNumberforthefileMFTMirr;" & _
								"dword ClustersPerFileRecordSegment;" & _
								"dword ClustersPerIndexBlock;" & _
								"int64 NTFSVolumeSerialNumber;" & _
								"dword Checksum", DllStructGetPtr($tBuffer))

	$BytesPerSector = DllStructGetData($tBootSectorSections, "BytesPerSector")
	$SectorsPerCluster = DllStructGetData($tBootSectorSections, "SectorsPerCluster")
	$BytesPerCluster = $BytesPerSector * $SectorsPerCluster
	$ClustersPerFileRecordSegment = DllStructGetData($tBootSectorSections, "ClustersPerFileRecordSegment")
	$LogicalClusterNumberforthefileMFT = DllStructGetData($tBootSectorSections, "LogicalClusterNumberforthefileMFT")

;	ConsoleWrite("Jump:  " & DllStructGetData($tBootSectorSections, "Jump") & @CRLF)
;	ConsoleWrite("SystemName:  " & DllStructGetData($tBootSectorSections, "SystemName") & @CRLF)
	ConsoleWrite("BytesPerSector:  " & $BytesPerSector & @CRLF)
	ConsoleWrite("SectorsPerCluster:  " & $SectorsPerCluster & @CRLF)
	ConsoleWrite("ReservedSectors:  " & DllStructGetData($tBootSectorSections, "ReservedSectors") & @CRLF)
;	ConsoleWrite("MediaDescriptor:  " & DllStructGetData($tBootSectorSections, "MediaDescriptor") & @CRLF)
	ConsoleWrite("SectorsPerTrack:  " & DllStructGetData($tBootSectorSections, "SectorsPerTrack") & @CRLF)
	ConsoleWrite("NumberOfHeads:  " & DllStructGetData($tBootSectorSections, "NumberOfHeads") & @CRLF)
	ConsoleWrite("HiddenSectors:  " & DllStructGetData($tBootSectorSections, "HiddenSectors") & @CRLF)
	ConsoleWrite("TotalSectors:  " & DllStructGetData($tBootSectorSections, "TotalSectors") & @CRLF)
	ConsoleWrite("LogicalClusterNumberforthefileMFT:  " & $LogicalClusterNumberforthefileMFT & @CRLF)
	ConsoleWrite("LogicalClusterNumberforthefileMFTMirr:  " & DllStructGetData($tBootSectorSections, "LogicalClusterNumberforthefileMFTMirr") & @CRLF)
;	ConsoleWrite("ClustersPerFileRecordSegment:  " & $ClustersPerFileRecordSegment & @CRLF)
;	ConsoleWrite("ClustersPerIndexBlock:  " & DllStructGetData($tBootSectorSections, "ClustersPerIndexBlock") & @CRLF)
;	ConsoleWrite("VolumeSerialNumber:  " & Ptr(DllStructGetData($tBootSectorSections, "NTFSVolumeSerialNumber")) & @CRLF)
;	ConsoleWrite("NTFSVolumeSerialNumber:  " & DllStructGetData($tBootSectorSections, "NTFSVolumeSerialNumber") & @CRLF)
;	ConsoleWrite("Checksum:  " & DllStructGetData($tBootSectorSections, "Checksum") & @CRLF)

	$MFT_Offset = $BytesPerCluster * $LogicalClusterNumberforthefileMFT
;	ConsoleWrite("$MFT_Offset: " & $MFT_Offset & @CRLF)
	If $ClustersPerFileRecordSegment > 127 Then
		$MFT_Record_Size = 2 ^ (256 - $ClustersPerFileRecordSegment)
	Else
		$MFT_Record_Size = $BytesPerCluster * $ClustersPerFileRecordSegment
	EndIf
	ConsoleWrite("MFT Record Size: " & $MFT_Record_Size & @crlf)
	ConsoleWrite(@CRLF)
EndFunc

Func _SetArrays()
Global $AttributesArr[18][4], $SIArr[14][4], $FNArr[15][1], $RecordHdrArr[16][2], $ObjectIDArr[25][2], $DataArr[21][2], $AttribListArr[9][2], $VolumeNameArr[2][2], $VolumeInformationArr[3][2]
$AttributesArr[0][0] = "Attribute name:"
$AttributesArr[1][0] = "STANDARD_INFORMATION"
$AttributesArr[2][0] = "ATTRIBUTE_LIST"
$AttributesArr[3][0] = "FILE_NAME"
$AttributesArr[4][0] = "OBJECT_ID"
$AttributesArr[5][0] = "SECURITY_DESCRIPTOR"
$AttributesArr[6][0] = "VOLUME_NAME"
$AttributesArr[7][0] = "VOLUME_INFORMATION"
$AttributesArr[8][0] = "DATA"
$AttributesArr[9][0] = "INDEX_ROOT"
$AttributesArr[10][0] = "INDEX_ALLOCATION"
$AttributesArr[11][0] = "BITMAP"
$AttributesArr[12][0] = "REPARSE_POINT"
$AttributesArr[13][0] = "EA_INFORMATION"
$AttributesArr[14][0] = "EA"
$AttributesArr[15][0] = "PROPERTY_SET"
$AttributesArr[16][0] = "LOGGED_UTILITY_STREAM"
$AttributesArr[17][0] = "ATTRIBUTE_END_MARKER"
$AttributesArr[0][1] = "Internal offset:"
$RecordHdrArr[0][0] = "Field name"
$RecordHdrArr[1][0] = "Offst to update sequence number"
$RecordHdrArr[2][0] = "Update sequence array size (words)"
$RecordHdrArr[3][0] = "$LogFile sequence number (LSN)"
$RecordHdrArr[4][0] = "Sequence number"
$RecordHdrArr[5][0] = "Hard link count"
$RecordHdrArr[6][0] = "Offset to first Attribute"
$RecordHdrArr[7][0] = "Flags"
$RecordHdrArr[8][0] = "Real size of the FILE record"
$RecordHdrArr[9][0] = "Allocated size of the FILE record"
$RecordHdrArr[10][0] = "Base record MFT Ref"
$RecordHdrArr[11][0] = "Base record MFT Ref SequenceNo"
$RecordHdrArr[12][0] = "Next Attribute Id"
$RecordHdrArr[13][0] = "File reference (MFT Record number)"
$RecordHdrArr[14][0] = "Update Sequence Number (a)"
$RecordHdrArr[15][0] = "Update Sequence Array (a)"
$SIArr[0][0] = "Field name:"
;$SIArr[1][0] = "HEADER_Flags"
$SIArr[2][0] = "File Create Time (CTime)"
$SIArr[3][0] = "File Modified Time (ATime)"
$SIArr[4][0] = "MFT Entry modified Time (MTime)"
$SIArr[5][0] = "File Last Access Time (RTime)"
$SIArr[6][0] = "DOS File Permissions"
$SIArr[7][0] = "Max Versions"
$SIArr[8][0] = "Version Number"
$SIArr[9][0] = "Class ID"
$SIArr[10][0] = "Owner ID"
$SIArr[11][0] = "Security ID"
$SIArr[12][0] = "Quota Charged"
$SIArr[13][0] = "USN"
$SIArr[0][1] = "Value:"
$SIArr[0][2] = "Field offset:"
$SIArr[0][3] = "Field size (bytes):"
$FNArr[0][0] = "Field name"
$FNArr[1][0] = "Parent MFTReference"
$FNArr[2][0] = "ParentSequenceNo"
$FNArr[3][0] = "File Create Time (CTime)"
$FNArr[4][0] = "File Modified Time (ATime)"
$FNArr[5][0] = "MFT Entry modified Time (MTime)"
$FNArr[6][0] = "File Last Access Time (RTime)"
$FNArr[7][0] = "AllocSize"
$FNArr[8][0] = "RealSize"
$FNArr[9][0] = "EaSize"
$FNArr[10][0] = "Flags"
$FNArr[11][0] = "NameLength"
$FNArr[12][0] = "NameType"
$FNArr[13][0] = "NameSpace"
$FNArr[14][0] = "FileName"
$ObjectIDArr[0][0] = "Member name"
$ObjectIDArr[1][0] = "ObjectId"
$ObjectIDArr[2][0] = "ObjectId Version"
$ObjectIDArr[3][0] = "ObjectId Timestamp"
$ObjectIDArr[4][0] = "ObjectId TimestampDec"
$ObjectIDArr[5][0] = "ObjectId ClockSeq"
$ObjectIDArr[6][0] = "ObjectId Node"
$ObjectIDArr[7][0] = "BirthVolumeId"
$ObjectIDArr[8][0] = "BirthVolumeId Version"
$ObjectIDArr[9][0] = "BirthVolumeId Timestamp"
$ObjectIDArr[10][0] = "BirthVolumeId TimestampDec"
$ObjectIDArr[11][0] = "BirthVolumeId ClockSeq"
$ObjectIDArr[12][0] = "BirthVolumeId Node"
$ObjectIDArr[13][0] = "BirthObjectId"
$ObjectIDArr[14][0] = "BirthObjectId Version"
$ObjectIDArr[15][0] = "BirthObjectId Timestamp"
$ObjectIDArr[16][0] = "BirthObjectId TimestampDec"
$ObjectIDArr[17][0] = "BirthObjectId ClockSeq"
$ObjectIDArr[18][0] = "BirthObjectId Node"
$ObjectIDArr[19][0] = "DomainId"
$ObjectIDArr[20][0] = "DomainId Version"
$ObjectIDArr[21][0] = "DomainId Timestamp"
$ObjectIDArr[22][0] = "DomainId TimestampDec"
$ObjectIDArr[23][0] = "DomainId ClockSeq"
$ObjectIDArr[24][0] = "DomainId Node"
$DataArr[0][0] = "Field name"
$DataArr[1][0] = "Length"
$DataArr[2][0] = "Non-resident flag"
$DataArr[3][0] = "Name length"
$DataArr[4][0] = "Offset to the Name"
$DataArr[5][0] = "Flags"
$DataArr[6][0] = "Attribute Id"
$DataArr[7][0] = "Resident - Length of the Attribute"
$DataArr[8][0] = "Resident - Offset to the Attribute"
$DataArr[9][0] = "Resident - Indexed flag"
$DataArr[10][0] = "Resident - Padding"
$DataArr[11][0] = "Non-Resident - Starting VCN"
$DataArr[12][0] = "Non-Resident - Last VCN"
$DataArr[13][0] = "Non-Resident - Offset to the Data Runs"
$DataArr[14][0] = "Non-Resident - Compression Unit Size"
$DataArr[15][0] = "Non-Resident - Padding"
$DataArr[16][0] = "Non-Resident - Allocated size of the attribute"
$DataArr[17][0] = "Non-Resident - Real size of the attribute"
$DataArr[18][0] = "Non-Resident - Initialized data size of the stream"
$DataArr[19][0] = "Non-Resident - DataRuns"
$DataArr[20][0] = "The Attribute's Name"
$AttribListArr[0][0] = "Description:"
$AttribListArr[1][0] = "Type"
$AttribListArr[2][0] = "Record Lenght"
$AttribListArr[3][0] = "Name Length"
$AttribListArr[4][0] = "Offset to name"
$AttribListArr[5][0] = "Starting VCN"
$AttribListArr[6][0] = "Base file reference"
$AttribListArr[7][0] = "Name"
$AttribListArr[8][0] = "Attribute ID"
$VolumeNameArr[0][0] = "Description:"
$VolumeNameArr[1][0] = "Volume Name"
$VolumeInformationArr[0][0] = "Description:"
$VolumeInformationArr[1][0] = "NTFS Version"
$VolumeInformationArr[2][0] = "Flags"
$RPArr[0][0] = "Description:"
$RPArr[1][0] = "Name of Attribute"
$RPArr[2][0] = "ReparseType"
$RPArr[3][0] = "ReparseDataLength"
$RPArr[4][0] = "ReparsePadding"
$RPArr[5][0] = "ReparseGUID"
$RPArr[6][0] = "ReparseSubstituteNameOffset"
$RPArr[7][0] = "ReparseSubstituteNameLength"
$RPArr[8][0] = "ReparsePrintNameOffset"
$RPArr[9][0] = "ReparsePrintNameLength"
$RPArr[10][0] = "ReparseSubstituteName"
$RPArr[11][0] = "ReparsePrintName"
$LUSArr[0][0] = "Field name"
$LUSArr[1][0] = "Name of Attribute"
$LUSArr[2][0] = "The raw Logged Utility Stream"
$EAInfoArr[0][0] = "Description:"
$EAInfoArr[1][0] = "Name of Attribute"
$EAInfoArr[2][0] = "SizeOfPackedEas"
$EAInfoArr[3][0] = "NumberOfEaWithFlagSet"
$EAInfoArr[4][0] = "SizeOfUnpackedEas"
$EAArr[0][0] = "Description:"
$EAArr[1][0] = "Name of Attribute"
$EAArr[2][0] = "OffsetToNextEa"
$EAArr[3][0] = "EaFlags"
$EAArr[4][0] = "EaNameLength"
$EAArr[5][0] = "EaValueLength"
$EAArr[6][0] = "EaName"
$EAArr[7][0] = "EaValue"
$IRArr[0][0] = "Description:"
$IRArr[1][0] = "Name of Attribute"
$IRArr[2][0] = "Indexed AttributeType"
$IRArr[3][0] = "CollationRule"
$IRArr[4][0] = "SizeOfIndexAllocationEntry"
$IRArr[5][0] = "ClustersPerIndexRoot"
$IRArr[6][0] = "IRPadding"
$IRArr[7][0] = "OffsetToFirstEntry"
$IRArr[8][0] = "TotalSizeOfEntries"
$IRArr[9][0] = "AllocatedSizeOfEntries"
$IRArr[10][0] = "Flags"
$IRArr[11][0] = "IRPadding2"
$IndxEntryNumberArr[0] = "Entry number"
$IndxMFTReferenceArr[0] = "MFTReference"
$IndxMFTRefSeqNoArr[0] = "MFTReference SeqNo"
$IndxIndexFlagsArr[0] = "IndexFlags"
$IndxMFTReferenceOfParentArr[0] = "Parent MFTReference"
$IndxMFTParentRefSeqNoArr[0] = "Parent MFTReference SeqNo"
$IndxCTimeArr[0] = "CTime"
$IndxATimeArr[0] = "ATime"
$IndxMTimeArr[0] = "MTime"
$IndxRTimeArr[0] = "RTime"
$IndxAllocSizeArr[0] = "AllocSize"
$IndxRealSizeArr[0] = "RealSize"
$IndxFileFlagsArr[0] = "File flags"
$IndxReparseTagArr[0] = "Reparse Point Tag"
$IndxFileNameArr[0] = "FileName"
$IndxNameSpaceArr[0] = "NameSpace"
$IndxSubNodeVCNArr[0] = "SubNodeVCN"
$IndxObjIdOArr[0][0] = "Member name"
$IndxObjIdOArr[0][1] = "MftRef"
$IndxObjIdOArr[0][2] = "MftRef SeqNo"
$IndxObjIdOArr[0][3] = "ObjectId"
$IndxObjIdOArr[0][4] = "ObjectId Version"
$IndxObjIdOArr[0][5] = "ObjectId Timestamp"
$IndxObjIdOArr[0][6] = "ObjectId TimestampDec"
$IndxObjIdOArr[0][7] = "ObjectId ClockSeq"
$IndxObjIdOArr[0][8] = "ObjectId Node"
$IndxObjIdOArr[0][9] = "BirthVolumeId"
$IndxObjIdOArr[0][10] = "BirthVolumeId Version"
$IndxObjIdOArr[0][11] = "BirthVolumeId Timestamp"
$IndxObjIdOArr[0][12] = "BirthVolumeId TimestampDec"
$IndxObjIdOArr[0][13] = "BirthVolumeId ClockSeq"
$IndxObjIdOArr[0][14] = "BirthVolumeId Node"
$IndxObjIdOArr[0][15] = "BirthObjectId"
$IndxObjIdOArr[0][16] = "BirthObjectId Version"
$IndxObjIdOArr[0][17] = "BirthObjectId Timestamp"
$IndxObjIdOArr[0][18] = "BirthObjectId TimestampDec"
$IndxObjIdOArr[0][19] = "BirthObjectId ClockSeq"
$IndxObjIdOArr[0][20] = "BirthObjectId Node"
$IndxObjIdOArr[0][21] = "DomainId"
$IndxObjIdOArr[0][22] = "DomainId Version"
$IndxObjIdOArr[0][23] = "DomainId Timestamp"
$IndxObjIdOArr[0][24] = "DomainId TimestampDec"
$IndxObjIdOArr[0][25] = "DomainId ClockSeq"
$IndxObjIdOArr[0][26] = "DomainId Node"
EndFunc

Func _HexEncode($bInput)
    Local $tInput = DllStructCreate("byte[" & BinaryLen($bInput) & "]")
    DllStructSetData($tInput, 1, $bInput)
    Local $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", 0, _
            "dword*", 0)

    If @error Or Not $a_iCall[0] Then
        Return SetError(1, 0, "")
    EndIf

    Local $iSize = $a_iCall[5]
    Local $tOut = DllStructCreate("char[" & $iSize & "]")

    $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", DllStructGetPtr($tOut), _
            "dword*", $iSize)

    If @error Or Not $a_iCall[0] Then
        Return SetError(2, 0, "")
    EndIf

    Return SetError(0, 0, DllStructGetData($tOut, 1))

EndFunc  ;==>_HexEncode

Func _Get_StandardInformation($MFTEntry,$SI_Offset,$SI_Size,$Current_SI_Number)
	$SI_CTime = StringMid($MFTEntry, $SI_Offset + 48, 16)
	$SI_CTime = _SwapEndian($SI_CTime)
	$SI_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_CTime)
	$SI_CTime = _WinTime_UTCFileTimeFormat(Dec($SI_CTime,2) - $tDelta, $DateTimeFormat, 2)
	If @error Then
		$SI_CTime = "-"
	Else
		$SI_CTime = $SI_CTime & ":" & _FillZero(StringRight($SI_CTime_tmp, 4))
	EndIf
	$SI_ATime = StringMid($MFTEntry, $SI_Offset + 64, 16)
	$SI_ATime = _SwapEndian($SI_ATime)
	$SI_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_ATime)
	$SI_ATime = _WinTime_UTCFileTimeFormat(Dec($SI_ATime,2) - $tDelta, $DateTimeFormat, 2)
	If @error Then
		$SI_ATime = "-"
	Else
		$SI_ATime = $SI_ATime & ":" & _FillZero(StringRight($SI_ATime_tmp, 4))
	EndIf
	$SI_MTime = StringMid($MFTEntry, $SI_Offset + 80, 16)
	$SI_MTime = _SwapEndian($SI_MTime)
	$SI_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_MTime)
	$SI_MTime = _WinTime_UTCFileTimeFormat(Dec($SI_MTime,2) - $tDelta, $DateTimeFormat, 2)
	If @error Then
		$SI_MTime = "-"
	Else
		$SI_MTime = $SI_MTime & ":" & _FillZero(StringRight($SI_MTime_tmp, 4))
	EndIf
	$SI_RTime = StringMid($MFTEntry, $SI_Offset + 96, 16)
	$SI_RTime = _SwapEndian($SI_RTime)
	$SI_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $SI_RTime)
	$SI_RTime = _WinTime_UTCFileTimeFormat(Dec($SI_RTime,2) - $tDelta, $DateTimeFormat, 2)
	If @error Then
		$SI_RTime = "-"
	Else
		$SI_RTime = $SI_RTime & ":" & _FillZero(StringRight($SI_RTime_tmp, 4))
	EndIf
	$SI_FilePermission = StringMid($MFTEntry, $SI_Offset + 112, 8)
	$SI_FilePermission = _SwapEndian($SI_FilePermission)
	$SI_FilePermission = _File_Attributes("0x" & $SI_FilePermission)
	$SI_MaxVersions = StringMid($MFTEntry, $SI_Offset + 120, 8)
	$SI_MaxVersions = Dec(_SwapEndian($SI_MaxVersions),2)
	$SI_VersionNumber = StringMid($MFTEntry, $SI_Offset + 128, 8)
	$SI_VersionNumber = Dec(_SwapEndian($SI_VersionNumber),2)
	$SI_ClassID = StringMid($MFTEntry, $SI_Offset + 136, 8)
	$SI_ClassID = Dec(_SwapEndian($SI_ClassID),2)
	$SI_OwnerID = StringMid($MFTEntry, $SI_Offset + 144, 8)
	$SI_OwnerID = Dec(_SwapEndian($SI_OwnerID),2)
	$SI_SecurityID = StringMid($MFTEntry, $SI_Offset + 152, 8)
	$SI_SecurityID = Dec(_SwapEndian($SI_SecurityID),2)
	$SI_QuotaCharged = StringMid($MFTEntry, $SI_Offset + 160, 16)
	$SI_QuotaCharged = Dec(_SwapEndian($SI_QuotaCharged),2)
	$SI_USN = StringMid($MFTEntry, $SI_Offset + 176, 16)
	$SI_USN = Dec(_SwapEndian($SI_USN),2)

;	$SIArr[1][$Current_SI_Number] = $SI_HEADER_Flags
	$SIArr[2][$Current_SI_Number] = $SI_CTime
	$SIArr[3][$Current_SI_Number] = $SI_ATime
	$SIArr[4][$Current_SI_Number] = $SI_MTime
	$SIArr[5][$Current_SI_Number] = $SI_RTime
	$SIArr[6][$Current_SI_Number] = $SI_FilePermission
	$SIArr[7][$Current_SI_Number] = $SI_MaxVersions
	$SIArr[8][$Current_SI_Number] = $SI_VersionNumber
	$SIArr[9][$Current_SI_Number] = $SI_ClassID
	$SIArr[10][$Current_SI_Number] = $SI_OwnerID
	$SIArr[11][$Current_SI_Number] = $SI_SecurityID
	$SIArr[12][$Current_SI_Number] = $SI_QuotaCharged
	$SIArr[13][$Current_SI_Number] = $SI_USN
EndFunc

Func _Get_ObjectID($MFTEntry,$OBJECTID_Offset,$OBJECTID_Size)
	;FILE_OBJECTID_BUFFER structure
	;https://msdn.microsoft.com/en-us/library/aa364393(v=vs.85).aspx
	Local $GUID_ObjectID_Version,$GUID_ObjectID_Timestamp,$GUID_ObjectID_TimestampDec,$GUID_ObjectID_ClockSeq,$GUID_ObjectID_Node
	Local $GUID_BirthVolumeID_Version,$GUID_BirthVolumeID_Timestamp,$GUID_BirthVolumeID_TimestampDec,$GUID_BirthVolumeID_ClockSeq,$GUID_BirthVolumeID_Node
	Local $GUID_BirthObjectID_Version,$GUID_BirthObjectID_Timestamp,$GUID_BirthObjectID_TimestampDec,$GUID_BirthObjectID_ClockSeq,$GUID_BirthObjectID_Node
	Local $GUID_DomainID_Version,$GUID_DomainID_Timestamp,$GUID_DomainID_TimestampDec,$GUID_DomainID_ClockSeq,$GUID_DomainID_Node
	ReDim $ObjectIDArr[25][$OBJID_Number+1]
	$ObjectIDArr[0][1] = "Value"
	;ObjectId
	$GUID_ObjectID = StringMid($MFTEntry,$OBJECTID_Offset+48,32)
	;Decode guid
	$GUID_ObjectID_Version = Dec(StringMid($GUID_ObjectID,15,1))
	$GUID_ObjectID_Timestamp = StringMid($GUID_ObjectID,1,14) & "0" & StringMid($GUID_ObjectID,16,1)
	$GUID_ObjectID_TimestampDec = Dec(_SwapEndian($GUID_ObjectID_Timestamp),2)
	$GUID_ObjectID_Timestamp = _DecodeTimestampFromGuid($GUID_ObjectID_Timestamp)
	$GUID_ObjectID_ClockSeq = StringMid($GUID_ObjectID,17,4)
	$GUID_ObjectID_ClockSeq = Dec($GUID_ObjectID_ClockSeq)
	$GUID_ObjectID_Node = StringMid($GUID_ObjectID,21,12)
	$GUID_ObjectID_Node = _DecodeMacFromGuid($GUID_ObjectID_Node)
	$GUID_ObjectID = _HexToGuidStr($GUID_ObjectID,1)

	Select
		Case $OBJECTID_Size - 24 = 16
			$GUID_BirthVolumeID = "NOT PRESENT"
			$GUID_BirthObjectID = "NOT PRESENT"
			$GUID_DomainID = "NOT PRESENT"
			$ObjectIDArr[1][1] = $GUID_ObjectID
			$ObjectIDArr[2][1] = $GUID_ObjectID_Version
			$ObjectIDArr[3][1] = $GUID_ObjectID_Timestamp
			$ObjectIDArr[4][1] = $GUID_ObjectID_TimestampDec
			$ObjectIDArr[5][1] = $GUID_ObjectID_ClockSeq
			$ObjectIDArr[6][1] = $GUID_ObjectID_Node
			$ObjectIDArr[7][1] = $GUID_BirthVolumeID
			$ObjectIDArr[13][1] = $GUID_BirthObjectID
			$ObjectIDArr[19][1] = $GUID_DomainID
		Case $OBJECTID_Size - 24 = 32
			;BirthVolumeId
			$GUID_BirthVolumeID = StringMid($MFTEntry,$OBJECTID_Offset+80,32)
			;Decode guid
			$GUID_BirthVolumeID_Version = Dec(StringMid($GUID_BirthVolumeID,15,1))
			$GUID_BirthVolumeID_Timestamp = StringMid($GUID_BirthVolumeID,1,14) & "0" & StringMid($GUID_BirthVolumeID,16,1)
			$GUID_BirthVolumeID_TimestampDec = Dec(_SwapEndian($GUID_BirthVolumeID_Timestamp),2)
			$GUID_BirthVolumeID_Timestamp = _DecodeTimestampFromGuid($GUID_BirthVolumeID_Timestamp)
			$GUID_BirthVolumeID_ClockSeq = StringMid($GUID_BirthVolumeID,17,4)
			$GUID_BirthVolumeID_ClockSeq = Dec($GUID_BirthVolumeID_ClockSeq)
			$GUID_BirthVolumeID_Node = StringMid($GUID_BirthVolumeID,21,12)
			$GUID_BirthVolumeID_Node = _DecodeMacFromGuid($GUID_BirthVolumeID_Node)
			$GUID_BirthVolumeID = _HexToGuidStr($GUID_BirthVolumeID,1)
			$GUID_BirthObjectID = "NOT PRESENT"
			$GUID_DomainID = "NOT PRESENT"
			$ObjectIDArr[1][1] = $GUID_ObjectID
			$ObjectIDArr[2][1] = $GUID_ObjectID_Version
			$ObjectIDArr[3][1] = $GUID_ObjectID_Timestamp
			$ObjectIDArr[4][1] = $GUID_ObjectID_TimestampDec
			$ObjectIDArr[5][1] = $GUID_ObjectID_ClockSeq
			$ObjectIDArr[6][1] = $GUID_ObjectID_Node
			$ObjectIDArr[7][1] = $GUID_BirthVolumeID
			$ObjectIDArr[8][1] = $GUID_BirthVolumeID_Version
			$ObjectIDArr[9][1] = $GUID_BirthVolumeID_Timestamp
			$ObjectIDArr[10][1] = $GUID_BirthVolumeID_TimestampDec
			$ObjectIDArr[11][1] = $GUID_BirthVolumeID_ClockSeq
			$ObjectIDArr[12][1] = $GUID_BirthVolumeID_Node
			$ObjectIDArr[13][1] = $GUID_BirthObjectID
			$ObjectIDArr[19][1] = $GUID_DomainID
		Case $OBJECTID_Size - 24 = 48
			;BirthVolumeId
			$GUID_BirthVolumeID = StringMid($MFTEntry,$OBJECTID_Offset+80,32)
			;Decode guid
			$GUID_BirthVolumeID_Version = Dec(StringMid($GUID_BirthVolumeID,15,1))
			$GUID_BirthVolumeID_Timestamp = StringMid($GUID_BirthVolumeID,1,14) & "0" & StringMid($GUID_BirthVolumeID,16,1)
			$GUID_BirthVolumeID_TimestampDec = Dec(_SwapEndian($GUID_BirthVolumeID_Timestamp),2)
			$GUID_BirthVolumeID_Timestamp = _DecodeTimestampFromGuid($GUID_BirthVolumeID_Timestamp)
			$GUID_BirthVolumeID_ClockSeq = StringMid($GUID_BirthVolumeID,17,4)
			$GUID_BirthVolumeID_ClockSeq = Dec($GUID_BirthVolumeID_ClockSeq)
			$GUID_BirthVolumeID_Node = StringMid($GUID_BirthVolumeID,21,12)
			$GUID_BirthVolumeID_Node = _DecodeMacFromGuid($GUID_BirthVolumeID_Node)
			$GUID_BirthVolumeID = _HexToGuidStr($GUID_BirthVolumeID,1)
			;BirthObjectId
			$GUID_BirthObjectID = StringMid($MFTEntry,$OBJECTID_Offset+112,32)
			;Decode guid
			$GUID_BirthObjectID_Version = Dec(StringMid($GUID_BirthObjectID,15,1))
			$GUID_BirthObjectID_Timestamp = StringMid($GUID_BirthObjectID,1,14) & "0" & StringMid($GUID_BirthObjectID,16,1)
			$GUID_BirthObjectID_TimestampDec = Dec(_SwapEndian($GUID_BirthObjectID_Timestamp),2)
			$GUID_BirthObjectID_Timestamp = _DecodeTimestampFromGuid($GUID_BirthObjectID_Timestamp)
			$GUID_BirthObjectID_ClockSeq = StringMid($GUID_BirthObjectID,17,4)
			$GUID_BirthObjectID_ClockSeq = Dec($GUID_BirthObjectID_ClockSeq)
			$GUID_BirthObjectID_Node = StringMid($GUID_BirthObjectID,21,12)
			$GUID_BirthObjectID_Node = _DecodeMacFromGuid($GUID_BirthObjectID_Node)
			$GUID_BirthObjectID = _HexToGuidStr($GUID_BirthObjectID,1)
			$GUID_DomainID = "NOT PRESENT"
			$ObjectIDArr[1][1] = $GUID_ObjectID
			$ObjectIDArr[2][1] = $GUID_ObjectID_Version
			$ObjectIDArr[3][1] = $GUID_ObjectID_Timestamp
			$ObjectIDArr[4][1] = $GUID_ObjectID_TimestampDec
			$ObjectIDArr[5][1] = $GUID_ObjectID_ClockSeq
			$ObjectIDArr[6][1] = $GUID_ObjectID_Node
			$ObjectIDArr[7][1] = $GUID_BirthVolumeID
			$ObjectIDArr[8][1] = $GUID_BirthVolumeID_Version
			$ObjectIDArr[9][1] = $GUID_BirthVolumeID_Timestamp
			$ObjectIDArr[10][1] = $GUID_BirthVolumeID_TimestampDec
			$ObjectIDArr[11][1] = $GUID_BirthVolumeID_ClockSeq
			$ObjectIDArr[12][1] = $GUID_BirthVolumeID_Node
			$ObjectIDArr[13][1] = $GUID_BirthObjectID
			$ObjectIDArr[14][1] = $GUID_BirthObjectID_Version
			$ObjectIDArr[15][1] = $GUID_BirthObjectID_Timestamp
			$ObjectIDArr[16][1] = $GUID_BirthObjectID_TimestampDec
			$ObjectIDArr[17][1] = $GUID_BirthObjectID_ClockSeq
			$ObjectIDArr[18][1] = $GUID_BirthObjectID_Node
			$ObjectIDArr[19][1] = $GUID_DomainID
		Case $OBJECTID_Size - 24 = 64
			;BirthVolumeId
			$GUID_BirthVolumeID = StringMid($MFTEntry,$OBJECTID_Offset+80,32)
			;Decode guid
			$GUID_BirthVolumeID_Version = Dec(StringMid($GUID_BirthVolumeID,15,1))
			$GUID_BirthVolumeID_Timestamp = StringMid($GUID_BirthVolumeID,1,14) & "0" & StringMid($GUID_BirthVolumeID,16,1)
			$GUID_BirthVolumeID_TimestampDec = Dec(_SwapEndian($GUID_BirthVolumeID_Timestamp),2)
			$GUID_BirthVolumeID_Timestamp = _DecodeTimestampFromGuid($GUID_BirthVolumeID_Timestamp)
			$GUID_BirthVolumeID_ClockSeq = StringMid($GUID_BirthVolumeID,17,4)
			$GUID_BirthVolumeID_ClockSeq = Dec($GUID_BirthVolumeID_ClockSeq)
			$GUID_BirthVolumeID_Node = StringMid($GUID_BirthVolumeID,21,12)
			$GUID_BirthVolumeID_Node = _DecodeMacFromGuid($GUID_BirthVolumeID_Node)
			$GUID_BirthVolumeID = _HexToGuidStr($GUID_BirthVolumeID,1)
			;BirthObjectId
			$GUID_BirthObjectID = StringMid($MFTEntry,$OBJECTID_Offset+112,32)
			;Decode guid
			$GUID_BirthObjectID_Version = Dec(StringMid($GUID_BirthObjectID,15,1))
			$GUID_BirthObjectID_Timestamp = StringMid($GUID_BirthObjectID,1,14) & "0" & StringMid($GUID_BirthObjectID,16,1)
			$GUID_BirthObjectID_TimestampDec = Dec(_SwapEndian($GUID_BirthObjectID_Timestamp),2)
			$GUID_BirthObjectID_Timestamp = _DecodeTimestampFromGuid($GUID_BirthObjectID_Timestamp)
			$GUID_BirthObjectID_ClockSeq = StringMid($GUID_BirthObjectID,17,4)
			$GUID_BirthObjectID_ClockSeq = Dec($GUID_BirthObjectID_ClockSeq)
			$GUID_BirthObjectID_Node = StringMid($GUID_BirthObjectID,21,12)
			$GUID_BirthObjectID_Node = _DecodeMacFromGuid($GUID_BirthObjectID_Node)
			$GUID_BirthObjectID = _HexToGuidStr($GUID_BirthObjectID,1)
			;DomainId
			$GUID_DomainID = StringMid($MFTEntry,$OBJECTID_Offset+144,32)
			;Decode guid
			$GUID_DomainID_Version = Dec(StringMid($GUID_DomainID,15,1))
			$GUID_DomainID_Timestamp = StringMid($GUID_DomainID,1,14) & "0" & StringMid($GUID_DomainID,16,1)
			$GUID_DomainID_TimestampDec = Dec(_SwapEndian($GUID_DomainID_Timestamp),2)
			$GUID_DomainID_Timestamp = _DecodeTimestampFromGuid($GUID_DomainID_Timestamp)
			$GUID_DomainID_ClockSeq = StringMid($GUID_DomainID,17,4)
			$GUID_DomainID_ClockSeq = Dec($GUID_DomainID_ClockSeq)
			$GUID_DomainID_Node = StringMid($GUID_DomainID,21,12)
			$GUID_DomainID_Node = _DecodeMacFromGuid($GUID_DomainID_Node)
			$GUID_DomainID = _HexToGuidStr($GUID_DomainID,1)
			$ObjectIDArr[1][1] = $GUID_ObjectID
			$ObjectIDArr[2][1] = $GUID_ObjectID_Version
			$ObjectIDArr[3][1] = $GUID_ObjectID_Timestamp
			$ObjectIDArr[4][1] = $GUID_ObjectID_TimestampDec
			$ObjectIDArr[5][1] = $GUID_ObjectID_ClockSeq
			$ObjectIDArr[6][1] = $GUID_ObjectID_Node
			$ObjectIDArr[7][1] = $GUID_BirthVolumeID
			$ObjectIDArr[8][1] = $GUID_BirthVolumeID_Version
			$ObjectIDArr[9][1] = $GUID_BirthVolumeID_Timestamp
			$ObjectIDArr[10][1] = $GUID_BirthVolumeID_TimestampDec
			$ObjectIDArr[11][1] = $GUID_BirthVolumeID_ClockSeq
			$ObjectIDArr[12][1] = $GUID_BirthVolumeID_Node
			$ObjectIDArr[13][1] = $GUID_BirthObjectID
			$ObjectIDArr[14][1] = $GUID_BirthObjectID_Version
			$ObjectIDArr[15][1] = $GUID_BirthObjectID_Timestamp
			$ObjectIDArr[16][1] = $GUID_BirthObjectID_TimestampDec
			$ObjectIDArr[17][1] = $GUID_BirthObjectID_ClockSeq
			$ObjectIDArr[18][1] = $GUID_BirthObjectID_Node
			$ObjectIDArr[19][1] = $GUID_DomainID
			$ObjectIDArr[20][1] = $GUID_DomainID_Version
			$ObjectIDArr[21][1] = $GUID_DomainID_Timestamp
			$ObjectIDArr[22][1] = $GUID_DomainID_TimestampDec
			$ObjectIDArr[23][1] = $GUID_DomainID_ClockSeq
			$ObjectIDArr[24][1] = $GUID_DomainID_Node
		Case Else
			;ExtendedInfo instead of DomainId?
			_DebugOut("Error: The $OBJECT_ID size (" & $OBJECTID_Size - 24 & ") was unexpected.", "0x" & StringMid($MFTEntry,$OBJECTID_Offset))
	EndSelect
EndFunc

Func _DecodeMacFromGuid($Input)
	If StringLen($Input) <> 12 Then Return SetError(1)
	Local $Mac = StringMid($Input,1,2) & "-" & StringMid($Input,3,2) & "-" & StringMid($Input,5,2) & "-" & StringMid($Input,7,2) & "-" & StringMid($Input,9,2) & "-" & StringMid($Input,11,2)
	Return $Mac
EndFunc

Func _DecodeTimestampFromGuid($StampDecode)
	$StampDecode = _SwapEndian($StampDecode)
	$StampDecode_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $StampDecode)
	$StampDecode = _WinTime_UTCFileTimeFormat(Dec($StampDecode,2) - $tDelta - $TimeDiff, $DateTimeFormat, $TimestampPrecision)
	If @error Then
		$StampDecode = $TimestampErrorVal
	ElseIf $TimestampPrecision = 3 Then
		$StampDecode = $StampDecode & $PrecisionSeparator2 & _FillZero(StringRight($StampDecode_tmp, 4))
	EndIf
	Return $StampDecode
EndFunc

Func _HexToGuidStr($input,$mode)
	;{4b-2b-2b-2b-6b}
	Local $OutStr
	If Not StringLen($input) = 32 Then Return $input
	If $mode Then $OutStr = "{"
	$OutStr &= _SwapEndian(StringMid($input,1,8)) & "-"
	$OutStr &= _SwapEndian(StringMid($input,9,4)) & "-"
	$OutStr &= _SwapEndian(StringMid($input,13,4)) & "-"
	$OutStr &= StringMid($input,17,4) & "-"
	$OutStr &= StringMid($input,21,12)
	If $mode Then $OutStr &= "}"
	Return $OutStr
EndFunc

Func _Get_VolumeName($MFTEntry,$VOLUME_NAME_Offset,$VOLUME_NAME_Size,$Current_VN_Number)
If $VOLUME_NAME_Size - 24 > 0 Then
	$VOLUME_NAME_NAME = StringMid($MFTEntry,$VOLUME_NAME_Offset+48,($VOLUME_NAME_Size-24)*2)
	$VOLUME_NAME_NAME = _UnicodeHexToStr($VOLUME_NAME_NAME)
;	$VOLUME_NAME_NAME = _HexToString($VOLUME_NAME_NAME)
;	ConsoleWrite("$VOLUME_NAME_NAME = " & $VOLUME_NAME_NAME & @crlf)
	$VolumeNameArr[1][$Current_VN_Number] = $VOLUME_NAME_NAME
	Return
EndIf
$VOLUME_NAME_NAME = "EMPTY"
$VolumeNameArr[1][$Current_VN_Number] = $VOLUME_NAME_NAME
Return
EndFunc

Func _Get_VolumeInformation($MFTEntry,$VOLUME_INFO_Offset,$VOLUME_INFO_Size,$Current_VI_Number)
$VOL_INFO_NTFS_VERSION = Dec(StringMid($MFTEntry,$VOLUME_INFO_Offset+64,2)) & "," & Dec(StringMid($MFTEntry,$VOLUME_INFO_Offset+66,2))
;ConsoleWrite("$VOL_INFO_NTFS_VERSION = " & $VOL_INFO_NTFS_VERSION & @crlf)
$VOL_INFO_FLAGS = StringMid($MFTEntry,$VOLUME_INFO_Offset+68,4)
$VOL_INFO_FLAGS = StringMid($VOL_INFO_FLAGS,3,2) & StringMid($VOL_INFO_FLAGS,1,2)
$VOL_INFO_FLAGS = _VolInfoFlag("0x" & $VOL_INFO_FLAGS)
If $VOL_INFO_FLAGS = "" Then $VOL_INFO_FLAGS = "EMPTY"
;ConsoleWrite("$VOL_INFO_FLAGS = " & $VOL_INFO_FLAGS & @crlf)
$VolumeInformationArr[1][$Current_VI_Number] = $VOL_INFO_NTFS_VERSION
$VolumeInformationArr[2][$Current_VI_Number] = $VOL_INFO_FLAGS
Return
EndFunc

Func _Get_Data($MFTEntry, $DATA_Offset, $DATA_Size, $Current_DATA_Number)
	Local $DATA_NameLength, $DATA_NameRelativeOffset, $DATA_VCNs, $DATA_LengthOfAttribute, $DATA_OffsetToAttribute, $DATA_IndexedFlag, $DATA_Name
	$DATA_NonResidentFlag = StringMid($MFTEntry, $DATA_Offset + 16, 2)
	$DATA_NameLength = Dec(StringMid($MFTEntry, $DATA_Offset + 18, 2))
	$DATA_NameRelativeOffset = StringMid($MFTEntry, $DATA_Offset + 20, 4)
	$DATA_NameRelativeOffset = Dec(_SwapEndian($DATA_NameRelativeOffset),2)
	$DATA_Flags = StringMid($MFTEntry, $DATA_Offset + 24, 4)
	$DATA_Flags = _SwapEndian($DATA_Flags)
	$DATA_Flags = _AttribHeaderFlags("0x" & $DATA_Flags)
	$DATA_AttributeID = StringMid($MFTEntry, $DATA_Offset + 28, 4)
	$DATA_AttributeID = _SwapEndian($DATA_AttributeID)
	If $DATA_NameLength > 0 Then
		$DATA_NameSpace = $DATA_NameLength - 1
		$DATA_Name = StringMid($MFTEntry, $DATA_Offset + ($DATA_NameRelativeOffset * 2), ($DATA_NameLength + $DATA_NameSpace) * 2)
		$DATA_Name = _UnicodeHexToStr($DATA_Name)
	EndIf
	If $DATA_NonResidentFlag = '01' Then
		$DATA_StartVCN = StringMid($MFTEntry, $DATA_Offset + 32, 16)
		$DATA_StartVCN = Dec(_SwapEndian($DATA_StartVCN),2)
		$DATA_LastVCN = StringMid($MFTEntry, $DATA_Offset + 48, 16)
		$DATA_LastVCN = Dec(_SwapEndian($DATA_LastVCN),2)
;		$DATA_VCNs = $DATA_LastVCN - $DATA_StartVCN
		$DATA_OffsetToDataRuns = StringMid($MFTEntry, $DATA_Offset + 64, 4)
		$DATA_OffsetToDataRuns = Dec(_SwapEndian($DATA_OffsetToDataRuns),2)
		$DATA_ComprUnitSize = StringMid($MFTEntry, $DATA_Offset + 68, 4)
		$DATA_ComprUnitSize = Dec(_SwapEndian($DATA_ComprUnitSize),2)
		$DATA_AllocatedSize = StringMid($MFTEntry, $DATA_Offset + 80, 16)
		$DATA_AllocatedSize = Dec(_SwapEndian($DATA_AllocatedSize),2)
		$DATA_RealSize = StringMid($MFTEntry, $DATA_Offset + 96, 16)
		$DATA_RealSize = Dec(_SwapEndian($DATA_RealSize),2)
;		$FileSizeBytes = $DATA_RealSize
		$DATA_InitializedStreamSize = StringMid($MFTEntry, $DATA_Offset + 112, 16)
		$DATA_InitializedStreamSize = Dec(_SwapEndian($DATA_InitializedStreamSize),2)
		$DATA_DataRuns = StringMid($MFTEntry,$DATA_Offset+($DATA_OffsetToDataRuns*2),($DATA_Size-$DATA_OffsetToDataRuns)*2)
	ElseIf $DATA_NonResidentFlag = '00' Then
		$DATA_LengthOfAttribute = StringMid($MFTEntry, $DATA_Offset + 32, 8)
		$DATA_LengthOfAttribute = Dec(_SwapEndian($DATA_LengthOfAttribute),2)
		$DATA_OffsetToAttribute = StringMid($MFTEntry, $DATA_Offset + 40, 4)
		$DATA_OffsetToAttribute = Dec(_SwapEndian($DATA_OffsetToAttribute),2)
		$DATA_IndexedFlag = Dec(StringMid($MFTEntry, $DATA_Offset + 44, 2))
	EndIf
If $DATA_NonResidentFlag = '01' Then
	$DataArr[0][$Current_DATA_Number] = "Data value " & $Current_DATA_Number
	$DataArr[1][$Current_DATA_Number] = $DATA_Size
	$DataArr[2][$Current_DATA_Number] = $DATA_NonResidentFlag
	$DataArr[3][$Current_DATA_Number] = $DATA_NameLength
	$DataArr[4][$Current_DATA_Number] = $DATA_NameRelativeOffset
	$DataArr[5][$Current_DATA_Number] = $DATA_Flags
	$DataArr[6][$Current_DATA_Number] = $DATA_AttributeID
	$DataArr[7][$Current_DATA_Number] = ""
	$DataArr[8][$Current_DATA_Number] = ""
	$DataArr[9][$Current_DATA_Number] = ""
	$DataArr[10][$Current_DATA_Number] = ""
	$DataArr[11][$Current_DATA_Number] = $DATA_StartVCN
	$DataArr[12][$Current_DATA_Number] = $DATA_LastVCN
	$DataArr[13][$Current_DATA_Number] = $DATA_OffsetToDataRuns
	$DataArr[14][$Current_DATA_Number] = $DATA_CompressionUnitSize
	$DataArr[15][$Current_DATA_Number] = $DATA_Padding
	$DataArr[16][$Current_DATA_Number] = $DATA_AllocatedSize
	$DataArr[17][$Current_DATA_Number] = $DATA_RealSize
	$DataArr[18][$Current_DATA_Number] = $DATA_InitializedStreamSize
	$DataArr[19][$Current_DATA_Number] = $DATA_DataRuns
	$DataArr[20][$Current_DATA_Number] = $DATA_Name
ElseIf $DATA_NonResidentFlag = '00' Then
	$DataArr[0][$Current_DATA_Number] = "Data value " & $Current_DATA_Number
	$DataArr[1][$Current_DATA_Number] = $DATA_Size
	$DataArr[2][$Current_DATA_Number] = $DATA_NonResidentFlag
	$DataArr[3][$Current_DATA_Number] = $DATA_NameLength
	$DataArr[4][$Current_DATA_Number] = $DATA_NameRelativeOffset
	$DataArr[5][$Current_DATA_Number] = $DATA_Flags
	$DataArr[6][$Current_DATA_Number] = $DATA_AttributeID
	$DataArr[7][$Current_DATA_Number] = $DATA_LengthOfAttribute
	$DataArr[8][$Current_DATA_Number] = $DATA_OffsetToAttribute
	$DataArr[9][$Current_DATA_Number] = $DATA_IndexedFlag
	$DataArr[10][$Current_DATA_Number] = $DATA_Padding
	$DataArr[11][$Current_DATA_Number] = ""
	$DataArr[12][$Current_DATA_Number] = ""
	$DataArr[13][$Current_DATA_Number] = ""
	$DataArr[14][$Current_DATA_Number] = ""
	$DataArr[15][$Current_DATA_Number] = ""
	$DataArr[16][$Current_DATA_Number] = ""
	$DataArr[17][$Current_DATA_Number] = ""
	$DataArr[18][$Current_DATA_Number] = ""
	$DataArr[19][$Current_DATA_Number] = ""
	$DataArr[20][$Current_DATA_Number] = $DATA_Name
EndIf
EndFunc

Func _Get_FileName($MFTEntry,$FN_Offset,$FN_Size,$FN_Number)

	$FN_ParentReferenceNo = StringMid($MFTEntry,$FN_Offset+48,12)
	$FN_ParentReferenceNo = Dec(_SwapEndian($FN_ParentReferenceNo),2)
	$FN_ParentSequenceNo = StringMid($MFTEntry,$FN_Offset+60,4)
	$FN_ParentSequenceNo = Dec(_SwapEndian($FN_ParentSequenceNo),2)
	$FN_CTime = StringMid($MFTEntry, $FN_Offset + 64, 16)
	$FN_CTime = _SwapEndian($FN_CTime)
	$FN_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_CTime)
	$FN_CTime = _WinTime_UTCFileTimeFormat(Dec($FN_CTime,2) - $tDelta, $DateTimeFormat, 2)
	If @error Then
		$FN_CTime = "-"
	Else
		$FN_CTime = $FN_CTime & ":" & _FillZero(StringRight($FN_CTime_tmp, 4))
	EndIf
	$FN_ATime = StringMid($MFTEntry, $FN_Offset + 80, 16)
	$FN_ATime = _SwapEndian($FN_ATime)
	$FN_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_ATime)
	$FN_ATime = _WinTime_UTCFileTimeFormat(Dec($FN_ATime,2) - $tDelta, $DateTimeFormat, 2)
	If @error Then
		$FN_ATime = "-"
	Else
		$FN_ATime = $FN_ATime & ":" & _FillZero(StringRight($FN_ATime_tmp, 4))
	EndIf
	$FN_MTime = StringMid($MFTEntry, $FN_Offset + 96, 16)
	$FN_MTime = _SwapEndian($FN_MTime)
	$FN_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_MTime)
	$FN_MTime = _WinTime_UTCFileTimeFormat(Dec($FN_MTime,2) - $tDelta, $DateTimeFormat, 2)
	If @error Then
		$FN_MTime = "-"
	Else
		$FN_MTime = $FN_MTime & ":" & _FillZero(StringRight($FN_MTime_tmp, 4))
	EndIf
	$FN_RTime = StringMid($MFTEntry, $FN_Offset + 112, 16)
	$FN_RTime = _SwapEndian($FN_RTime)
	$FN_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $FN_RTime)
	$FN_RTime = _WinTime_UTCFileTimeFormat(Dec($FN_RTime,2) - $tDelta, $DateTimeFormat, 2)
	If @error Then
		$FN_RTime = "-"
	Else
		$FN_RTime = $FN_RTime & ":" & _FillZero(StringRight($FN_RTime_tmp, 4))
	EndIf
	$FN_AllocSize = StringMid($MFTEntry, $FN_Offset + 128, 16)
	$FN_AllocSize = Dec(_SwapEndian($FN_AllocSize),2)
	$FN_RealSize = StringMid($MFTEntry, $FN_Offset + 144, 16)
	$FN_RealSize = Dec(_SwapEndian($FN_RealSize),2)
	$FN_Flags = StringMid($MFTEntry, $FN_Offset + 160, 8)
	$FN_Flags = _SwapEndian($FN_Flags)
	$FN_Flags = _File_Attributes("0x" & $FN_Flags)
	$FN_EaSize = StringMid($MFTEntry, $FN_Offset + 168, 8)
	$FN_EaSize = Dec(_SwapEndian($FN_EaSize),2)
	$FN_NameLength = StringMid($MFTEntry,$FN_Offset+176,2)
	$FN_NameLength = Dec($FN_NameLength)
	$FN_NameType = StringMid($MFTEntry,$FN_Offset+178,2)
	$FN_NameSpace = Dec($FN_NameType)
	Select
		Case $FN_NameType = '00'
			$FN_NameType = 'POSIX'
		Case $FN_NameType = '01'
			$FN_NameType = 'WIN32'
		Case $FN_NameType = '02'
			$FN_NameType = 'DOS'
		Case $FN_NameType = '03'
			$FN_NameType = 'DOS+WIN32'
		Case $FN_NameType <> '00' AND $FN_NameType <> '01' AND $FN_NameType <> '02' AND $FN_NameType <> '03'
			$FN_NameType = 'UNKNOWN'
	EndSelect

	$FN_FileName = StringMid($MFTEntry,$FN_Offset+180,$FN_NameLength*2*2)
	$FN_FileName = _UnicodeHexToStr($FN_FileName)
	If StringLen($FN_FileName) <> $FN_NameLength Then $INVALID_FILENAME = 1
	$FNArr[0][$FN_Number] = "FN Number " & $FN_Number
	$FNArr[1][$FN_Number] = $FN_ParentReferenceNo
	$FNArr[2][$FN_Number] = $FN_ParentSequenceNo
	$FNArr[3][$FN_Number] = $FN_CTime
	$FNArr[4][$FN_Number] = $FN_ATime
	$FNArr[5][$FN_Number] = $FN_MTime
	$FNArr[6][$FN_Number] = $FN_RTime
	$FNArr[7][$FN_Number] = $FN_AllocSize
	$FNArr[8][$FN_Number] = $FN_RealSize
	$FNArr[9][$FN_Number] = $FN_EaSize
	$FNArr[10][$FN_Number] = $FN_Flags
	$FNArr[11][$FN_Number] = $FN_NameLength
	$FNArr[12][$FN_Number] = $FN_NameType
	$FNArr[13][$FN_Number] = $FN_NameSpace
	$FNArr[14][$FN_Number] = $FN_FileName
	Return
EndFunc

Func _VolInfoFlag($VIFinput)
Local $VIFoutput = ""
If BitAND($VIFinput,0x0001) Then $VIFoutput &= 'Dirty+'
If BitAND($VIFinput,0x0002) Then $VIFoutput &= 'Resize_LogFile+'
If BitAND($VIFinput,0x0004) Then $VIFoutput &= 'Upgrade_On_Mount+'
If BitAND($VIFinput,0x0008) Then $VIFoutput &= 'Mounted_On_NT4+'
If BitAND($VIFinput,0x0010) Then $VIFoutput &= 'Deleted_USN_Underway+'
If BitAND($VIFinput,0x0020) Then $VIFoutput &= 'Repair_ObjectIDs+'
If BitAND($VIFinput,0x8000) Then $VIFoutput &= 'Modified_By_CHKDSK+'
;$FRFoutput = StringMid($FRFoutput,1,StringLen($FRFoutput)-1)
$VIFoutput = StringTrimRight($VIFoutput,1)
;ConsoleWrite("$FRFoutput = " & $FRFoutput & @crlf)
Return $VIFoutput
EndFunc

Func _File_Attributes($FAInput)
	Local $FAOutput = ""
	If BitAND($FAInput, 0x0001) Then $FAOutput &= 'read_only+'
	If BitAND($FAInput, 0x0002) Then $FAOutput &= 'hidden+'
	If BitAND($FAInput, 0x0004) Then $FAOutput &= 'system+'
	If BitAND($FAInput, 0x0010) Then $FAOutput &= 'directory1+'
	If BitAND($FAInput, 0x0020) Then $FAOutput &= 'archive+'
	If BitAND($FAInput, 0x0040) Then $FAOutput &= 'device+'
	If BitAND($FAInput, 0x0080) Then $FAOutput &= 'normal+'
	If BitAND($FAInput, 0x0100) Then $FAOutput &= 'temporary+'
	If BitAND($FAInput, 0x0200) Then $FAOutput &= 'sparse_file+'
	If BitAND($FAInput, 0x0400) Then $FAOutput &= 'reparse_point+'
	If BitAND($FAInput, 0x0800) Then $FAOutput &= 'compressed+'
	If BitAND($FAInput, 0x1000) Then $FAOutput &= 'offline+'
	If BitAND($FAInput, 0x2000) Then $FAOutput &= 'not_indexed+'
	If BitAND($FAInput, 0x4000) Then $FAOutput &= 'encrypted+'
	If BitAND($FAInput, 0x8000) Then $FAOutput &= 'integrity_stream+'
	If BitAND($FAInput, 0x10000) Then $FAOutput &= 'virtual+'
	If BitAND($FAInput, 0x20000) Then $FAOutput &= 'no_scrub_data+'
	If BitAND($FAInput, 0x40000) Then $FAOutput &= 'ea+'
	If BitAND($FAInput, 0x10000000) Then $FAOutput &= 'directory2+'
	If BitAND($FAInput, 0x20000000) Then $FAOutput &= 'index_view+'
	$FAOutput = StringTrimRight($FAOutput, 1)
	Return $FAOutput
EndFunc

Func _DumpInfo()
Local $NextSector, $TotalSectors
If $cmdline[2] = "-a" Then
	ConsoleWrite(@CRLF)
	ConsoleWrite("Dump of full Record" & @crlf)
	ConsoleWrite(_HexEncode("0x"&$HexDumpRecord[1]) & @crlf)
EndIf
$p = 1
ConsoleWrite(@CRLF)
ConsoleWrite("Found attributes: " & @CRLF)
For $p = 1 To Ubound($AttributesArr)-1
	If $AttributesArr[$p][2] = 'TRUE' Then
		ConsoleWrite("$" & $AttributesArr[$p][0] & " (" & $AttributesArr[$p][3] & ")" & @CRLF)
	EndIf
Next
ConsoleWrite(@CRLF)
ConsoleWrite("Record header info: " & @CRLF)
$p = 1
For $p = 1 To Ubound($RecordHdrArr)-1
	ConsoleWrite($RecordHdrArr[$p][0] & ": " & $RecordHdrArr[$p][1] & @CRLF)
Next
If $cmdline[2] = "-a" Then
	ConsoleWrite(@CRLF)
	ConsoleWrite("Dump of Record Header" & @crlf)
	ConsoleWrite(_HexEncode("0x"&$HexDumpHeader[1]) & @crlf)
EndIf
;_ArrayDisplay($HexDumpHeader,"$HexDumpHeader")
$p = 1
If $AttributesArr[1][2] = "TRUE" Then; $STANDARD_INFORMATION
	For $p = 1 To $SI_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$STANDARD_INFORMATION " & $p & ":" & @CRLF)
		For $j = 2 To 13
			ConsoleWrite($SIArr[$j][0] & ": " & $SIArr[$j][$p] & @CRLF)
		Next
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $STANDARD_INFORMATION (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpStandardInformation[$p]) & @crlf)
		EndIf
	Next
;	_ArrayDisplay($HexDumpStandardInformation,"$HexDumpStandardInformation")
EndIf

If $AttributesArr[2][2] = "TRUE"  Then; $ATTRIBUTE_LIST
	ConsoleWrite(@CRLF)
	ConsoleWrite("$ATTRIBUTE_LIST:" & @CRLF)
	If $ALInnerCouner > 0 Then
		For $ALC = 1 To $ALInnerCouner
			ConsoleWrite("Base record: " & $AttribListArr[6][$ALC] & ", Start VCN: " & $AttribListArr[5][$ALC] & ", Type: " & $AttribListArr[1][$ALC] & ", AL Record length: " & $AttribListArr[2][$ALC] & ", Name: " & $AttribListArr[7][$ALC] & ", Attrib ID: " & $AttribListArr[8][$ALC] & @CRLF)
		Next
		ConsoleWrite("" & @crlf)
		ConsoleWrite("Isolated attribute list:" & @crlf)
		ConsoleWrite(_HexEncode("0x"&$IsolatedAttributeList) & @crlf)
	ElseIf $AttribListNonResident = 1 Then
		ConsoleWrite("Sorry, non-resident $ATTRIBUTE_LIST not yet supported in this application" & @crlf)
	Else
		ConsoleWrite("No extra records to inspect.." & @crlf)
	EndIf
;	_ArrayDisplay($HexDumpAttributeList,"$HexDumpAttributeList")
EndIf

If $AttributesArr[3][2] = "TRUE" Then ;$FILE_NAME
	$p = 1
	For $p = 1 To $FN_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$FILE_NAME " & $p & ":" & @CRLF)
		For $j = 1 To 14
			ConsoleWrite($FNArr[$j][0] & ": " & $FNArr[$j][$p] & @CRLF)
		Next
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $FILE_NAME (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpFileName[$p]) & @crlf)
		EndIf
	Next
;	_ArrayDisplay($HexDumpFileName,"$HexDumpFileName")
EndIf

If $AttributesArr[4][2] = "TRUE" Then; $OBJECT_ID
	$p = 1
	For $p = 1 To $OBJID_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$OBJECT_ID " & $p & ":" & @CRLF)
		For $j = 1 To 24
			ConsoleWrite($ObjectIDArr[$j][0] & ": " & $ObjectIDArr[$j][$p] & @CRLF)
			If $ObjectIDArr[$j][$p] = "NOT PRESENT" Then
				$j += 5
			EndIf
		Next
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $OBJECT_ID (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpObjectId[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[5][2] = "TRUE" Then; $SECURITY_DESCRIPTOR
	$p = 1
	For $p = 1 To $SECURITY_Number
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $SECURITY_DESCRIPTOR (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpSecurityDescriptor[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[6][2] = "TRUE" Then; $VOLUME_NAME
	$p = 1
	For $p = 1 To $VOLNAME_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$VOLUME_NAME " & $p & ":" & @CRLF)
		ConsoleWrite($VolumeNameArr[1][0] & ": " & $VolumeNameArr[1][$p] & @CRLF)
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $VOLUME_NAME (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpVolumeName[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[7][2] = "TRUE" Then; $VOLUME_INFORMATION
	$p = 1
	For $p = 1 To $VOLINFO_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$VOLUME_INFORMATION " & $p & ":" & @CRLF)
		For $j = 1 To 2
			ConsoleWrite($VolumeInformationArr[$j][0] & ": " & $VolumeInformationArr[$j][$p] & @CRLF)
		Next
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $VOLUME_INFORMATION (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpVolumeInformation[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[8][2] = "TRUE" Then; $DATA
	$p = 1
	For $p = 1 To $DATA_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$DATA " & $p & ":" & @CRLF)
		If $DataArr[2][$p] = "01" Then
			For $j = 1 To 20
				If ($j = 1 Or $j = 4 Or $j = 10 Or $j = 15 Or ($j > 6 And $j < 11)) Then ContinueLoop
				ConsoleWrite($DataArr[$j][0] & ": " & $DataArr[$j][$p] & @CRLF)
			Next
		ElseIf $DataArr[2][$p] = "00" Then
			For $j = 1 To 20
				If ($j = 1 Or $j = 4 Or $j = 10 Or $j = 15 Or ($j > 10 And $j < 20)) Then ContinueLoop
				ConsoleWrite($DataArr[$j][0] & ": " & $DataArr[$j][$p] & @CRLF)
			Next
		EndIf
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $DATA (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpData[$p]) & @crlf)
		EndIf
	Next
;	_ArrayDisplay($HexDumpData,"$HexDumpData")
	If $HEADER_MFTREcordNumber = 4 Then
		ConsoleWrite("ATTRIBUTE DEFINITIONS:" & @CRLF)
		For $p = 1 To UBound($AttrDefArray,2)-1
			ConsoleWrite(@CRLF)
			For $j = 0 To UBound($AttrDefArray)-1
				ConsoleWrite($AttrDefArray[$j][0] & ": " & $AttrDefArray[$j][$p] & @CRLF)
			Next
		Next
	EndIf
EndIf

If $AttributesArr[9][2] = "TRUE" Then; $INDEX_ROOT
	$p = 1
	For $p = 1 To $INDEXROOT_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$INDEX_ROOT " & $p & ":" & @CRLF)
		For $j = 1 To 11
			ConsoleWrite($IRArr[$j][0] & ": " & $IRArr[$j][$p] & @CRLF)
		Next
		If $ResidentIndx Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Decode of resident index entries:" & @CRLF)
			If Ubound($IndxEntryNumberArr) > 1 Then
				ConsoleWrite(@CRLF)
				ConsoleWrite("$I30:" & @CRLF)
				For $k = 1 To Ubound($IndxEntryNumberArr)-1
					ConsoleWrite(@CRLF)
					ConsoleWrite($IndxEntryNumberArr[0] & ": " & $IndxEntryNumberArr[$k] & @CRLF)
					ConsoleWrite($IndxFileNameArr[0] & ": " & $IndxFileNameArr[$k] & @CRLF)
					ConsoleWrite($IndxMFTReferenceArr[0] & ": " & $IndxMFTReferenceArr[$k] & @CRLF)
					ConsoleWrite($IndxMFTRefSeqNoArr[0] & ": " & $IndxMFTRefSeqNoArr[$k] & @CRLF)
					ConsoleWrite($IndxIndexFlagsArr[0] & ": " & $IndxIndexFlagsArr[$k] & @CRLF)
	;				If $IndxIndexFlagsArr[$j] <> "0000" Then MsgBox(0,"Hey", "Something interesting to investigate") ; yeah don't know what to with it at the moment -> look SubNodeVCN
					ConsoleWrite($IndxMFTReferenceOfParentArr[0] & ": " & $IndxMFTReferenceOfParentArr[$k] & @CRLF)
					ConsoleWrite($IndxMFTParentRefSeqNoArr[0] & ": " & $IndxMFTParentRefSeqNoArr[$k] & @CRLF)
					ConsoleWrite($IndxCTimeArr[0] & ": " & $IndxCTimeArr[$k] & @CRLF)
					ConsoleWrite($IndxATimeArr[0] & ": " & $IndxATimeArr[$k] & @CRLF)
					ConsoleWrite($IndxMTimeArr[0] & ": " & $IndxMTimeArr[$k] & @CRLF)
					ConsoleWrite($IndxRTimeArr[0] & ": " & $IndxRTimeArr[$k] & @CRLF)
					ConsoleWrite($IndxAllocSizeArr[0] & ": " & $IndxAllocSizeArr[$k] & @CRLF)
					ConsoleWrite($IndxRealSizeArr[0] & ": " & $IndxRealSizeArr[$k] & @CRLF)
					ConsoleWrite($IndxFileFlagsArr[0] & ": " & $IndxFileFlagsArr[$k] & @CRLF)
					ConsoleWrite($IndxReparseTagArr[0] & ": " & $IndxReparseTagArr[$k] & @CRLF)
					ConsoleWrite($IndxNameSpaceArr[0] & ": " & $IndxNameSpaceArr[$k] & @CRLF)
					ConsoleWrite($IndxSubNodeVCNArr[0] & ": " & $IndxSubNodeVCNArr[$k] & @CRLF)
				Next
			EndIf
			If Ubound($IndxObjIdOArr) > 1 Then
				ConsoleWrite(@CRLF)
				ConsoleWrite("$ObjId:$O:" & @CRLF)
				For $k = 1 To UBound($IndxObjIdOArr)-1
					ConsoleWrite(@CRLF)
					ConsoleWrite("Entry: " & $k & @CRLF)
					For $j = 1 To 26
						ConsoleWrite($IndxObjIdOArr[0][$j] & ": " & $IndxObjIdOArr[$k][$j] & @CRLF)
					Next
				Next
			EndIf
		EndIf
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $INDEX_ROOT (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpIndexRoot[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[10][2] = "TRUE" Then; $INDEX_ALLOCATION
	$p = 1
	For $p = 1 To $INDEXALLOC_Number
		;This loop makes no sense..
		ConsoleWrite(@CRLF)
		ConsoleWrite("$INDEX_ALLOCATION " & $p & ":" & @CRLF)
;		If Not $TargetIsOffset Then
			ConsoleWrite("Resolved and decoded INDX records:" & @CRLF)
			If Ubound($IndxEntryNumberArr) > 1 Then
				ConsoleWrite(@CRLF)
				ConsoleWrite("$I30:" & @CRLF)
				For $j = 1 To Ubound($IndxEntryNumberArr)-1
					ConsoleWrite(@CRLF)
					ConsoleWrite($IndxEntryNumberArr[0] & ": " & $IndxEntryNumberArr[$j] & @CRLF)
					ConsoleWrite($IndxFileNameArr[0] & ": " & $IndxFileNameArr[$j] & @CRLF)
					ConsoleWrite($IndxMFTReferenceArr[0] & ": " & $IndxMFTReferenceArr[$j] & @CRLF)
					ConsoleWrite($IndxMFTRefSeqNoArr[0] & ": " & $IndxMFTRefSeqNoArr[$j] & @CRLF)
					ConsoleWrite($IndxIndexFlagsArr[0] & ": " & $IndxIndexFlagsArr[$j] & @CRLF)
	;				If $IndxIndexFlagsArr[$j] <> "0000" Then MsgBox(0,"Hey", "Something interesting to investigate") ; yeah don't know what to with it at the moment -> look SubNodeVCN
					ConsoleWrite($IndxMFTReferenceOfParentArr[0] & ": " & $IndxMFTReferenceOfParentArr[$j] & @CRLF)
					ConsoleWrite($IndxMFTParentRefSeqNoArr[0] & ": " & $IndxMFTParentRefSeqNoArr[$j] & @CRLF)
					ConsoleWrite($IndxCTimeArr[0] & ": " & $IndxCTimeArr[$j] & @CRLF)
					ConsoleWrite($IndxATimeArr[0] & ": " & $IndxATimeArr[$j] & @CRLF)
					ConsoleWrite($IndxMTimeArr[0] & ": " & $IndxMTimeArr[$j] & @CRLF)
					ConsoleWrite($IndxRTimeArr[0] & ": " & $IndxRTimeArr[$j] & @CRLF)
					ConsoleWrite($IndxAllocSizeArr[0] & ": " & $IndxAllocSizeArr[$j] & @CRLF)
					ConsoleWrite($IndxRealSizeArr[0] & ": " & $IndxRealSizeArr[$j] & @CRLF)
					ConsoleWrite($IndxFileFlagsArr[0] & ": " & $IndxFileFlagsArr[$j] & @CRLF)
					ConsoleWrite($IndxReparseTagArr[0] & ": " & $IndxReparseTagArr[$j] & @CRLF)
					ConsoleWrite($IndxNameSpaceArr[0] & ": " & $IndxNameSpaceArr[$j] & @CRLF)
					ConsoleWrite($IndxSubNodeVCNArr[0] & ": " & $IndxSubNodeVCNArr[$j] & @CRLF)
				Next
			EndIf
			If Ubound($IndxObjIdOArr) > 1 Then
				ConsoleWrite(@CRLF)
				ConsoleWrite("$ObjId:$O:" & @CRLF)
				For $k = 1 To UBound($IndxObjIdOArr)-1
					ConsoleWrite(@CRLF)
					ConsoleWrite("Entry: " & $k & @CRLF)
					For $j = 1 To 26
						ConsoleWrite($IndxObjIdOArr[0][$j] & ": " & $IndxObjIdOArr[$k][$j] & @CRLF)
					Next
				Next
			EndIf
			If $cmdline[3] = "indxdump=on" Then
				ConsoleWrite(@CRLF)
				ConsoleWrite("Dump of resolved and extracted INDX records for $INDEX_ALLOCATION (" & $p & ")" & @crlf)
				ConsoleWrite(_HexEncode("0x"&$HexDumpIndxRecord[$p]) & @crlf)
			EndIf
;		Else
;			ConsoleWrite("INDX records decode not yet supported when using offset mode." & @crlf)
;		EndIf
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $INDEX_ALLOCATION (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpIndexAllocation[$p]) & @crlf)
		EndIf

	Next
EndIf

If $AttributesArr[11][2] = "TRUE" Then; $BITMAP
	$p = 1
	For $p = 1 To $BITMAP_Number
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $BITMAP (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpBitmap[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[12][2] = "TRUE" Then; $REPARSE_POINT
	$p = 1
	For $p = 1 To $REPARSEPOINT_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$REPARSE_POINT " & $p & ":" & @CRLF)
		For $j = 1 To Ubound($RPArr)-1
			ConsoleWrite($RPArr[$j][0] & ": " & $RPArr[$j][$p] & @CRLF)
		Next
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $REPARSE_POINT (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpReparsePoint[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[13][2] = "TRUE" Then; $EA_INFORMATION
	$p = 1
	For $p = 1 To $EAINFO_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$EA_INFORMATION " & $p & ":" & @CRLF)
		For $j = 2 To 4
			ConsoleWrite($EAInfoArr[$j][0] & ": " & $EAInfoArr[$j][$p] & @CRLF)
		Next
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $EA_INFORMATION (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpEaInformation[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[14][2] = "TRUE" Then; $EA
;	_ArrayDisplay($EAArr,"$EAArr")
	$p = 1
	For $p = 1 To $EA_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$EA " & $p & ":" & @CRLF)
;		For $j = 1 To 5
		For $j = 3 To Ubound($EAArr)-1
			#cs
			If $j = 7 Then
				ConsoleWrite($EAArr[$j][0] & ": " & @CRLF)
				ConsoleWrite(_HexEncode("0x"&$EAArr[$j][$p]) & @crlf)
			Else
				ConsoleWrite($EAArr[$j][0] & ": " & $EAArr[$j][$p] & @CRLF)
			EndIf
			#ce
			ConsoleWrite($EAArr[$j][0] & ": " & $EAArr[$j][$p] & @CRLF)
		Next
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $EA (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpEa[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[15][2] = "TRUE" Then; $PROPERTY_SET
	$p = 1
	For $p = 1 To $PROPERTYSET_Number
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $PROPERTY_SET (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpPropertySet[$p]) & @crlf)
		EndIf
	Next
EndIf

If $AttributesArr[16][2] = "TRUE" Then; $LOGGED_UTILITY_STREAM
	$p = 1
	For $p = 1 To $LOGGEDUTILSTREAM_Number
		ConsoleWrite(@CRLF)
		ConsoleWrite("$LOGGED_UTILITY_STREAM " & $p & ":" & @CRLF)
		For $j = 1 To 2
			ConsoleWrite($LUSArr[$j][0] & ": " & $LUSArr[$j][$p] & @CRLF)
		Next
		If $LUSArr[1][$p] = "$TXF_DATA" Then
			For $b = 1 to 1
				For $c = 0 to UBound($TxfDataArr)-1
					ConsoleWrite($TxfDataArr[$c][0] & ": " & $TxfDataArr[$c][$b] & @CRLF)
				Next
			Next
		EndIf
;		ConsoleWrite($LUSArr[1][0] & ": " & $LUSArr[1][1] & @CRLF)
		If $cmdline[2] = "-a" Then
			ConsoleWrite(@CRLF)
			ConsoleWrite("Dump of $LOGGED_UTILITY_STREAM (" & $p & ")" & @crlf)
			ConsoleWrite(_HexEncode("0x"&$HexDumpLoggedUtilityStream[$p]) & @crlf)
		EndIf

	Next
EndIf

; Record slack data
;_ArrayDisplay($HexDumpRecordSlack,"$HexDumpRecordSlack")
If $cmdline[2] = "-a" Then
	ConsoleWrite(@CRLF)
	ConsoleWrite("Dump of Record slack for base record" & @crlf)
	ConsoleWrite(_HexEncode("0x"&$HexDumpRecordSlack[1]) & @crlf)
EndIf
EndFunc

Func _GetAttributeEntry($Entry)
	Local $CoreAttribute,$CoreAttributeTmp,$CoreAttributeArr[2]
	Local $ATTRIBUTE_HEADER_Length,$ATTRIBUTE_HEADER_NonResidentFlag,$ATTRIBUTE_HEADER_NameLength,$ATTRIBUTE_HEADER_NameRelativeOffset,$ATTRIBUTE_HEADER_Name,$ATTRIBUTE_HEADER_Flags,$ATTRIBUTE_HEADER_AttributeID,$ATTRIBUTE_HEADER_StartVCN,$ATTRIBUTE_HEADER_LastVCN
	Local $ATTRIBUTE_HEADER_VCNs,$ATTRIBUTE_HEADER_OffsetToDataRuns,$ATTRIBUTE_HEADER_CompressionUnitSize,$ATTRIBUTE_HEADER_Padding,$ATTRIBUTE_HEADER_AllocatedSize,$ATTRIBUTE_HEADER_RealSize,$ATTRIBUTE_HEADER_InitializedStreamSize,$RunListOffset
	Local $ATTRIBUTE_HEADER_LengthOfAttribute,$ATTRIBUTE_HEADER_OffsetToAttribute,$ATTRIBUTE_HEADER_IndexedFlag
	$ATTRIBUTE_HEADER_Length = StringMid($Entry,9,8)
	$ATTRIBUTE_HEADER_Length = Dec(StringMid($ATTRIBUTE_HEADER_Length,7,2) & StringMid($ATTRIBUTE_HEADER_Length,5,2) & StringMid($ATTRIBUTE_HEADER_Length,3,2) & StringMid($ATTRIBUTE_HEADER_Length,1,2))
	$ATTRIBUTE_HEADER_NonResidentFlag = StringMid($Entry,17,2)
;	ConsoleWrite("$ATTRIBUTE_HEADER_NonResidentFlag = " & $ATTRIBUTE_HEADER_NonResidentFlag & @crlf)
	$ATTRIBUTE_HEADER_NameLength = Dec(StringMid($Entry,19,2))
;	ConsoleWrite("$ATTRIBUTE_HEADER_NameLength = " & $ATTRIBUTE_HEADER_NameLength & @crlf)
	$ATTRIBUTE_HEADER_NameRelativeOffset = StringMid($Entry,21,4)
;	ConsoleWrite("$ATTRIBUTE_HEADER_NameRelativeOffset = " & $ATTRIBUTE_HEADER_NameRelativeOffset & @crlf)
	$ATTRIBUTE_HEADER_NameRelativeOffset = Dec(_SwapEndian($ATTRIBUTE_HEADER_NameRelativeOffset))
;	ConsoleWrite("$ATTRIBUTE_HEADER_NameRelativeOffset = " & $ATTRIBUTE_HEADER_NameRelativeOffset & @crlf)
	If $ATTRIBUTE_HEADER_NameLength > 0 Then
		$ATTRIBUTE_HEADER_Name = _UnicodeHexToStr(StringMid($Entry,$ATTRIBUTE_HEADER_NameRelativeOffset*2 + 1,$ATTRIBUTE_HEADER_NameLength*4))
	Else
		$ATTRIBUTE_HEADER_Name = ""
	EndIf
	$ATTRIBUTE_HEADER_Flags = _SwapEndian(StringMid($Entry,25,4))
;	ConsoleWrite("$ATTRIBUTE_HEADER_Flags = " & $ATTRIBUTE_HEADER_Flags & @crlf)
	$Flags = ""
	If $ATTRIBUTE_HEADER_Flags = "0000" Then
		$Flags = "NORMAL"
	Else
		If BitAND($ATTRIBUTE_HEADER_Flags,"0001") Then
			$IsCompressed = 1
			$Flags &= "COMPRESSED+"
		EndIf
		If BitAND($ATTRIBUTE_HEADER_Flags,"4000") Then
			$IsEncrypted = 1
			$Flags &= "ENCRYPTED+"
		EndIf
		If BitAND($ATTRIBUTE_HEADER_Flags,"8000") Then
			$IsSparse = 1
			$Flags &= "SPARSE+"
		EndIf
		$Flags = StringTrimRight($Flags,1)
	EndIf
;	ConsoleWrite("File is " & $Flags & @CRLF)
	$ATTRIBUTE_HEADER_AttributeID = StringMid($Entry,29,4)
	$ATTRIBUTE_HEADER_AttributeID = StringMid($ATTRIBUTE_HEADER_AttributeID,3,2) & StringMid($ATTRIBUTE_HEADER_AttributeID,1,2)
	If $ATTRIBUTE_HEADER_NonResidentFlag = '01' Then
		$ATTRIBUTE_HEADER_StartVCN = StringMid($Entry,33,16)
;		ConsoleWrite("$ATTRIBUTE_HEADER_StartVCN = " & $ATTRIBUTE_HEADER_StartVCN & @crlf)
		$ATTRIBUTE_HEADER_StartVCN = Dec(_SwapEndian($ATTRIBUTE_HEADER_StartVCN),2)
;		ConsoleWrite("$ATTRIBUTE_HEADER_StartVCN = " & $ATTRIBUTE_HEADER_StartVCN & @crlf)
		$ATTRIBUTE_HEADER_LastVCN = StringMid($Entry,49,16)
;		ConsoleWrite("$ATTRIBUTE_HEADER_LastVCN = " & $ATTRIBUTE_HEADER_LastVCN & @crlf)
		$ATTRIBUTE_HEADER_LastVCN = Dec(_SwapEndian($ATTRIBUTE_HEADER_LastVCN),2)
;		ConsoleWrite("$ATTRIBUTE_HEADER_LastVCN = " & $ATTRIBUTE_HEADER_LastVCN & @crlf)
		$ATTRIBUTE_HEADER_VCNs = $ATTRIBUTE_HEADER_LastVCN - $ATTRIBUTE_HEADER_StartVCN
;		ConsoleWrite("$ATTRIBUTE_HEADER_VCNs = " & $ATTRIBUTE_HEADER_VCNs & @crlf)
		$ATTRIBUTE_HEADER_OffsetToDataRuns = StringMid($Entry,65,4)
		$ATTRIBUTE_HEADER_OffsetToDataRuns = Dec(StringMid($ATTRIBUTE_HEADER_OffsetToDataRuns,3,1) & StringMid($ATTRIBUTE_HEADER_OffsetToDataRuns,3,1))
		$ATTRIBUTE_HEADER_CompressionUnitSize = Dec(_SwapEndian(StringMid($Entry,69,4)))
;		ConsoleWrite("$ATTRIBUTE_HEADER_CompressionUnitSize = " & $ATTRIBUTE_HEADER_CompressionUnitSize & @crlf)
		$IsCompressed = 0
		If $ATTRIBUTE_HEADER_CompressionUnitSize = 4 Then $IsCompressed = 1
		$ATTRIBUTE_HEADER_Padding = StringMid($Entry,73,8)
		$ATTRIBUTE_HEADER_Padding = StringMid($ATTRIBUTE_HEADER_Padding,7,2) & StringMid($ATTRIBUTE_HEADER_Padding,5,2) & StringMid($ATTRIBUTE_HEADER_Padding,3,2) & StringMid($ATTRIBUTE_HEADER_Padding,1,2)
		$ATTRIBUTE_HEADER_AllocatedSize = StringMid($Entry,81,16)
;		ConsoleWrite("$ATTRIBUTE_HEADER_AllocatedSize = " & $ATTRIBUTE_HEADER_AllocatedSize & @crlf)
		$ATTRIBUTE_HEADER_AllocatedSize = Dec(_SwapEndian($ATTRIBUTE_HEADER_AllocatedSize),2)
;		ConsoleWrite("$ATTRIBUTE_HEADER_AllocatedSize = " & $ATTRIBUTE_HEADER_AllocatedSize & @crlf)
		$ATTRIBUTE_HEADER_RealSize = StringMid($Entry,97,16)
;		ConsoleWrite("$ATTRIBUTE_HEADER_RealSize = " & $ATTRIBUTE_HEADER_RealSize & @crlf)
		$ATTRIBUTE_HEADER_RealSize = Dec(_SwapEndian($ATTRIBUTE_HEADER_RealSize),2)
;		ConsoleWrite("$ATTRIBUTE_HEADER_RealSize = " & $ATTRIBUTE_HEADER_RealSize & @crlf)
		$ATTRIBUTE_HEADER_InitializedStreamSize = StringMid($Entry,113,16)
;		ConsoleWrite("$ATTRIBUTE_HEADER_InitializedStreamSize = " & $ATTRIBUTE_HEADER_InitializedStreamSize & @crlf)
		$ATTRIBUTE_HEADER_InitializedStreamSize = Dec(_SwapEndian($ATTRIBUTE_HEADER_InitializedStreamSize),2)
;		ConsoleWrite("$ATTRIBUTE_HEADER_InitializedStreamSize = " & $ATTRIBUTE_HEADER_InitializedStreamSize & @crlf)
		$RunListOffset = StringMid($Entry,65,4)
;		ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
		$RunListOffset = Dec(_SwapEndian($RunListOffset))
;		ConsoleWrite("$RunListOffset = " & $RunListOffset & @crlf)
		If $IsCompressed AND $RunListOffset = 72 Then
			$ATTRIBUTE_HEADER_CompressedSize = StringMid($Entry,129,16)
			$ATTRIBUTE_HEADER_CompressedSize = Dec(_SwapEndian($ATTRIBUTE_HEADER_CompressedSize),2)
		EndIf
		$DataRun = StringMid($Entry,$RunListOffset*2+1,(StringLen($Entry)-$RunListOffset)*2)
;		ConsoleWrite("$DataRun = " & $DataRun & @crlf)
	ElseIf $ATTRIBUTE_HEADER_NonResidentFlag = '00' Then
		$ATTRIBUTE_HEADER_LengthOfAttribute = StringMid($Entry,33,8)
;		ConsoleWrite("$ATTRIBUTE_HEADER_LengthOfAttribute = " & $ATTRIBUTE_HEADER_LengthOfAttribute & @crlf)
		$ATTRIBUTE_HEADER_LengthOfAttribute = Dec(_SwapEndian($ATTRIBUTE_HEADER_LengthOfAttribute),2)
;		ConsoleWrite("$ATTRIBUTE_HEADER_LengthOfAttribute = " & $ATTRIBUTE_HEADER_LengthOfAttribute & @crlf)
;		$ATTRIBUTE_HEADER_OffsetToAttribute = StringMid($Entry,41,4)
;		$ATTRIBUTE_HEADER_OffsetToAttribute = Dec(StringMid($ATTRIBUTE_HEADER_OffsetToAttribute,3,2) & StringMid($ATTRIBUTE_HEADER_OffsetToAttribute,1,2))
		$ATTRIBUTE_HEADER_OffsetToAttribute = Dec(_SwapEndian(StringMid($Entry,41,4)))
;		ConsoleWrite("$ATTRIBUTE_HEADER_OffsetToAttribute = " & $ATTRIBUTE_HEADER_OffsetToAttribute & @crlf)
		$ATTRIBUTE_HEADER_IndexedFlag = Dec(StringMid($Entry,45,2))
		$ATTRIBUTE_HEADER_Padding = StringMid($Entry,47,2)
		$DataRun = StringMid($Entry,$ATTRIBUTE_HEADER_OffsetToAttribute*2+1,$ATTRIBUTE_HEADER_LengthOfAttribute*2)
;		ConsoleWrite("$DataRun = " & $DataRun & @crlf)
	EndIf
; Possible continuation
;	For $i = 1 To UBound($DataQ) - 1
	For $i = 1 To 1
;		_DecodeDataQEntry($DataQ[$i])
		If $ATTRIBUTE_HEADER_NonResidentFlag = '00' Then
;_ExtractResidentFile($DATA_Name, $DATA_LengthOfAttribute)
			$CoreAttribute = $DataRun
		Else
			Global $RUN_VCN[1], $RUN_Clusters[1]

			$TotalClusters = $ATTRIBUTE_HEADER_LastVCN - $ATTRIBUTE_HEADER_StartVCN + 1
			$Size = $ATTRIBUTE_HEADER_RealSize
;_ExtractDataRuns()
			$r=UBound($RUN_Clusters)
			$i=1
			$RUN_VCN[0] = 0
			$BaseVCN = $RUN_VCN[0]
			If $DataRun = "" Then $DataRun = "00"
			Do
				$RunListID = StringMid($DataRun,$i,2)
				If $RunListID = "00" Then ExitLoop
;				ConsoleWrite("$RunListID = " & $RunListID & @crlf)
				$i += 2
				$RunListClustersLength = Dec(StringMid($RunListID,2,1))
;				ConsoleWrite("$RunListClustersLength = " & $RunListClustersLength & @crlf)
				$RunListVCNLength = Dec(StringMid($RunListID,1,1))
;				ConsoleWrite("$RunListVCNLength = " & $RunListVCNLength & @crlf)
				$RunListClusters = Dec(_SwapEndian(StringMid($DataRun,$i,$RunListClustersLength*2)),2)
;				ConsoleWrite("$RunListClusters = " & $RunListClusters & @crlf)
				$i += $RunListClustersLength*2
				$RunListVCN = _SwapEndian(StringMid($DataRun, $i, $RunListVCNLength*2))
				;next line handles positive or negative move
				$BaseVCN += Dec($RunListVCN,2)-(($r>1) And (Dec(StringMid($RunListVCN,1,1))>7))*Dec(StringMid("10000000000000000",1,$RunListVCNLength*2+1),2)
				If $RunListVCN <> "" Then
					$RunListVCN = $BaseVCN
				Else
					$RunListVCN = 0			;$RUN_VCN[$r-1]		;0
				EndIf
;				ConsoleWrite("$RunListVCN = " & $RunListVCN & @crlf)
				If (($RunListVCN=0) And ($RunListClusters>16) And (Mod($RunListClusters,16)>0)) Then
				;If (($RunListVCN=$RUN_VCN[$r-1]) And ($RunListClusters>16) And (Mod($RunListClusters,16)>0)) Then
				;may be sparse section at end of Compression Signature
					_ArrayAdd($RUN_Clusters,Mod($RunListClusters,16))
					_ArrayAdd($RUN_VCN,$RunListVCN)
					$RunListClusters -= Mod($RunListClusters,16)
					$r += 1
				ElseIf (($RunListClusters>16) And (Mod($RunListClusters,16)>0)) Then
				;may be compressed data section at start of Compression Signature
					_ArrayAdd($RUN_Clusters,$RunListClusters-Mod($RunListClusters,16))
					_ArrayAdd($RUN_VCN,$RunListVCN)
					$RunListVCN += $RUN_Clusters[$r]
					$RunListClusters = Mod($RunListClusters,16)
					$r += 1
				EndIf
			;just normal or sparse data
				_ArrayAdd($RUN_Clusters,$RunListClusters)
				_ArrayAdd($RUN_VCN,$RunListVCN)
				$r += 1
				$i += $RunListVCNLength*2
			Until $i > StringLen($DataRun)
;--------------------------------_ExtractDataRuns()
;			_ArrayDisplay($RUN_Clusters,"$RUN_Clusters")
;			_ArrayDisplay($RUN_VCN,"$RUN_VCN")
			If $TotalClusters * $BytesPerCluster >= $Size Then
;				ConsoleWrite(_ArrayToString($RUN_VCN) & @CRLF)
;				ConsoleWrite(_ArrayToString($RUN_Clusters) & @CRLF)
;ExtractFile
				Local $nBytes
				$hFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
				If $hFile = 0 Then
					ConsoleWrite("Error in function _WinAPI_CreateFile when trying to open target drive." & @CRLF)
					_WinAPI_CloseHandle($hFile)
					Return
				EndIf
				$tBuffer = DllStructCreate("byte[" & $BytesPerCluster * 16 & "]")
				Select
					Case UBound($RUN_VCN) = 1		;no data, do nothing
					Case (UBound($RUN_VCN) = 2) Or (Not $IsCompressed)	;may be normal or sparse
						If $RUN_VCN[1] = $RUN_VCN[0] And $DATA_Name <> "$Boot" Then		;sparse, unless $Boot
;							_DoSparse($htest)
							ConsoleWrite("Error: Sparse attributes not supported!!!" & @CRLF)
						Else								;normal
;							_DoNormalAttribute($hFile, $tBuffer)
;							Local $nBytes
							$FileSize = $ATTRIBUTE_HEADER_RealSize
							For $s = 1 To UBound($RUN_VCN)-1
								_WinAPI_SetFilePointerEx($hFile, $RUN_VCN[$s]*$BytesPerCluster, $FILE_BEGIN)
								$g = $RUN_Clusters[$s]
								While $g > 16 And $FileSize > $BytesPerCluster * 16
									_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $BytesPerCluster * 16, $nBytes)
;									_WinAPI_WriteFile($htest, DllStructGetPtr($tBuffer), $BytesPerCluster * 16, $nBytes)
									$g -= 16
									$FileSize -= $BytesPerCluster * 16
									$CoreAttributeTmp = StringMid(DllStructGetData($tBuffer,1),3,$BytesPerCluster*16*2)
									$CoreAttribute &= $CoreAttributeTmp
								WEnd
								If $g <> 0 Then
									_WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $BytesPerCluster * $g, $nBytes)
;									$CoreAttributeTmp = StringMid(DllStructGetData($tBuffer,1),3)
;									$CoreAttribute &= $CoreAttributeTmp
									If $FileSize > $BytesPerCluster * $g Then
;										_WinAPI_WriteFile($htest, DllStructGetPtr($tBuffer), $BytesPerCluster * $g, $nBytes)
										$FileSize -= $BytesPerCluster * $g
										$CoreAttributeTmp = StringMid(DllStructGetData($tBuffer,1),3,$BytesPerCluster*$g*2)
										$CoreAttribute &= $CoreAttributeTmp
									Else
;										_WinAPI_WriteFile($htest, DllStructGetPtr($tBuffer), $FileSize, $nBytes)
;										Return
										$CoreAttributeTmp = StringMid(DllStructGetData($tBuffer,1),3,$FileSize*2)
										$CoreAttribute &= $CoreAttributeTmp
									EndIf
								EndIf
							Next
;------------------_DoNormalAttribute()
						EndIf
					Case Else					;may be compressed
;						_DoCompressed($hFile, $htest, $tBuffer)
						ConsoleWrite("Error: Compressed attributes not supported!!!" & @CRLF)
				EndSelect
;------------------------ExtractFile
			EndIf
;-------------------------
		EndIf
	Next
	$CoreAttributeArr[0] = $CoreAttribute
	$CoreAttributeArr[1] = $ATTRIBUTE_HEADER_Name
;	Return $CoreAttribute
	Return $CoreAttributeArr
; Alternatively just return the core attribute and call the respective _Get_ function from within the main record decoder
;	Select
;		Case $AttribType = $REPARSE_POINT
;			_Get_ReparsePoint($Entry,$RP_Offset,$RP_Size,$Current_RP_Number)
;	EndSelect
EndFunc

Func _Get_Bitmap($Entry,$Current_Attrib_Number,$CurrentAttributeName)
	Local $LocalAttributeOffset = 1,$TheBitmap
	$TheBitmap = StringMid($Entry,$LocalAttributeOffset)
EndFunc

Func _GetReparseType($ReparseType)
	;winnt.h
	;ntifs.h
	Select
		Case $ReparseType = '0x00000000'
			Return 'RESERVED_ZERO'
		Case $ReparseType = '0x00000001'
			Return 'RESERVED_ONE'
		Case $ReparseType = '0x00000002'
			Return 'RESERVED_TWO'
		Case $ReparseType = '0x80000005'
			Return 'DRIVER_EXTENDER'
		Case $ReparseType = '0x80000006'
			Return 'HSM2'
		Case $ReparseType = '0x80000007'
			Return 'SIS'
		Case $ReparseType = '0x80000008'
			Return 'WIM'
		Case $ReparseType = '0x80000009'
			Return 'CSV'
		Case $ReparseType = '0x8000000A'
			Return 'DFS'
		Case $ReparseType = '0x8000000B'
			Return 'FILTER_MANAGER'
		Case $ReparseType = '0x80000012'
			Return 'DFSR'
		Case $ReparseType = '0x80000013'
			Return 'DEDUP'
		Case $ReparseType = '0x80000014'
			Return 'NFS'
		Case $ReparseType = '0x80000015'
			Return 'FILE_PLACEHOLDER'
		Case $ReparseType = '0x80000017'
			Return 'WOF'
		Case $ReparseType = '0x80000018'
			Return 'WCI'
		Case $ReparseType = '0x80000019'
			Return 'GLOBAL_REPARSE'
		Case $ReparseType = '0x8000001B'
			Return 'APPEXECLINK'
		Case $ReparseType = '0x8000001E'
			Return 'HFS'
		Case $ReparseType = '0x80000020'
			Return 'UNHANDLED'
		Case $ReparseType = '0x80000021'
			Return 'ONEDRIVE'
		Case $ReparseType = '0x9000001A'
			Return 'CLOUD'
		Case $ReparseType = '0x9000101A'
			Return 'CLOUD_ROOT'
		Case $ReparseType = '0x9000201A'
			Return 'CLOUD_ON_DEMAND'
		Case $ReparseType = '0x9000301A'
			Return 'CLOUD_ROOT_ON_DEMAND'
		Case $ReparseType = '0x9000001C'
			Return 'GVFS'
		Case $ReparseType = '0xA0000003'
			Return 'MOUNT_POINT'
		Case $ReparseType = '0xA000000C'
			Return 'SYMLINK'
		Case $ReparseType = '0xA0000010'
			Return 'IIS_CACHE'
		Case $ReparseType = '0xA0000019'
			Return 'GLOBAL_REPARSE'
		Case $ReparseType = '0xA000001D'
			Return 'LX_SYMLINK'
		Case $ReparseType = '0xA000001F'
			Return 'WCI_TOMBSTONE'
		Case $ReparseType = '0xA0000022'
			Return 'GVFS_TOMBSTONE'
		Case $ReparseType = '0xC0000004'
			Return 'HSM'
		Case $ReparseType = '0xC0000014'
			Return 'APPXSTRM'
		Case Else
			Return 'UNKNOWN(' & $ReparseType & ')'
	EndSelect
EndFunc

Func _Get_ReparsePoint($Entry,$Current_Attrib_Number,$CurrentAttributeName)
	Local $LocalAttributeOffset = 1,$GuidPresent=0,$ReparseType,$ReparseData,$ReparseDataLength,$ReparsePadding,$ReparseGuid,$ReparseSubstituteNameOffset,$ReparseSubstituteNameLength,$ReparsePrintNameOffset,$ReparsePrintNameLength,$ReparseSubstituteName,$ReparsePrintName
	$ReparseType = StringMid($Entry,$LocalAttributeOffset,8)
	$ReparseType = _SwapEndian($ReparseType)
	If Dec(StringMid($ReparseType,1,2)) < 128 Then ;Non-Microsoft - GUID exist
		$GuidPresent = 1
	EndIf
	$ReparseType = "0x" & $ReparseType
	$ReparseType = _GetReparseType($ReparseType)
	$ReparseDataLength = StringMid($Entry,$LocalAttributeOffset+8,4)
	$ReparseDataLength = Dec(_SwapEndian($ReparseDataLength),2)
	$ReparsePadding = StringMid($Entry,$LocalAttributeOffset+12,4)
	If $ReparseType = "WCI" Then
		$ReparseGuid = StringMid($Entry,$LocalAttributeOffset+32,32)
		$ReparseGuid = _HexToGuidStr($ReparseGuid,1)
		$ReparsePrintNameLength = StringMid($Entry,$LocalAttributeOffset+64,4)
		$ReparsePrintNameLength = Dec(_SwapEndian($ReparsePrintNameLength))
		If $ReparsePrintNameLength > 0 Then
			$ReparsePrintName = StringMid($Entry,($LocalAttributeOffset+68),$ReparsePrintNameLength*2)
			$ReparsePrintName = BinaryToString("0x"&$ReparsePrintName,2)
		EndIf
	Else
		If $GuidPresent Then
			$ReparseGuid = StringMid($Entry,$LocalAttributeOffset+16,32)
			$ReparseGuid = _HexToGuidStr($ReparseGuid,1)
			$ReparseData = StringMid($Entry,$LocalAttributeOffset+48,$ReparseDataLength*2)
		Else
			$ReparseData = StringMid($Entry,$LocalAttributeOffset+16,$ReparseDataLength*2)
		EndIf
	;	$ReparseData = StringMid($Entry,$LocalAttributeOffset+16,$ReparseDataLength*2)
		$ReparseSubstituteNameOffset = StringMid($ReparseData,1,4)
		$ReparseSubstituteNameOffset = Dec(_SwapEndian($ReparseSubstituteNameOffset),2)
		$ReparseSubstituteNameLength = StringMid($ReparseData,5,4)
		$ReparseSubstituteNameLength = Dec(_SwapEndian($ReparseSubstituteNameLength),2)
		$ReparsePrintNameOffset = StringMid($ReparseData,9,4)
		$ReparsePrintNameOffset = Dec(_SwapEndian($ReparsePrintNameOffset),2)
		$ReparsePrintNameLength = StringMid($ReparseData,13,4)
		$ReparsePrintNameLength = Dec(_SwapEndian($ReparsePrintNameLength),2)
		;-----if $ReparseSubstituteNameOffset<>0 then the order is reversed and parsed from end of $ReparseData ????????
		If StringMid($ReparseData,1,4) <> "0000" Then
			ConsoleWrite("1: " & @crlf)
			$ReparseSubstituteName = StringMid($Entry,StringLen($Entry)+1-($ReparseSubstituteNameLength*2),$ReparseSubstituteNameLength*2)
			ConsoleWrite("$ReparseSubstituteName: " & @crlf)
			ConsoleWrite(_HexEncode("0x"&$ReparseSubstituteName) & @crlf)
			$ReparseSubstituteName = BinaryToString("0x"&$ReparseSubstituteName,2)
			$ReparsePrintName = StringMid($Entry,StringLen($Entry)+1-($ReparseSubstituteNameLength*2)-($ReparsePrintNameLength*2),$ReparsePrintNameLength*2)
			ConsoleWrite("$ReparsePrintName: " & @crlf)
			ConsoleWrite(_HexEncode("0x"&$ReparsePrintName) & @crlf)
			$ReparsePrintName = BinaryToString("0x"&$ReparsePrintName,2)
		Else
			ConsoleWrite("2: " & @crlf)
			$ReparseSubstituteName = StringMid($Entry,$LocalAttributeOffset+16+16,$ReparseSubstituteNameLength*2)
			ConsoleWrite("$ReparseSubstituteName: " & $ReparseSubstituteName & @crlf)
			$ReparseSubstituteName = BinaryToString("0x"&$ReparseSubstituteName,2)
			$ReparsePrintName = StringMid($Entry,($LocalAttributeOffset+32)+($ReparsePrintNameOffset*2),$ReparsePrintNameLength*2)
			ConsoleWrite("$ReparsePrintName: " & $ReparsePrintName & @crlf)
			$ReparsePrintName = BinaryToString("0x"&$ReparsePrintName,2)
		EndIf
	EndIf
	$RPArr[0][$Current_Attrib_Number] = "RP Number " & $Current_Attrib_Number
	$RPArr[1][$Current_Attrib_Number] = $CurrentAttributeName
	$RPArr[2][$Current_Attrib_Number] = $ReparseType
	$RPArr[3][$Current_Attrib_Number] = $ReparseDataLength
	$RPArr[4][$Current_Attrib_Number] = $ReparsePadding
	$RPArr[5][$Current_Attrib_Number] = $ReparseGuid
	$RPArr[6][$Current_Attrib_Number] = $ReparseSubstituteNameOffset
	$RPArr[7][$Current_Attrib_Number] = $ReparseSubstituteNameLength
	$RPArr[8][$Current_Attrib_Number] = $ReparsePrintNameOffset
	$RPArr[9][$Current_Attrib_Number] = $ReparsePrintNameLength
	$RPArr[10][$Current_Attrib_Number] = $ReparseSubstituteName
	$RPArr[11][$Current_Attrib_Number] = $ReparsePrintName
EndFunc

Func _Get_EaInformation($Entry,$Current_Attrib_Number,$CurrentAttributeName)
	Local $LocalAttributeOffset = 1,$TheEaInformation,$SizeOfPackedEas,$NumberOfEaWithFlagSet,$SizeOfUnpackedEas
	$TheEaInformation = StringMid($Entry,$LocalAttributeOffset)
;	ConsoleWrite("$TheEaInformation = " & $TheEaInformation & @crlf)
	$SizeOfPackedEas = StringMid($Entry,$LocalAttributeOffset,4)
	$SizeOfPackedEas = Dec(_SwapEndian($SizeOfPackedEas),2)
;	ConsoleWrite("$SizeOfPackedEas = " & $SizeOfPackedEas & @crlf)
	$NumberOfEaWithFlagSet = StringMid($Entry,$LocalAttributeOffset+4,4)
	$NumberOfEaWithFlagSet = Dec(_SwapEndian($NumberOfEaWithFlagSet),2)
;	ConsoleWrite("$NumberOfEaWithFlagSet = " & $NumberOfEaWithFlagSet & @crlf)
	$SizeOfUnpackedEas = StringMid($Entry,$LocalAttributeOffset+8,8)
	$SizeOfUnpackedEas = Dec(_SwapEndian($SizeOfUnpackedEas),2)
;	ConsoleWrite("$SizeOfUnpackedEas = " & $SizeOfUnpackedEas & @crlf)
	$EAInfoArr[0][$Current_Attrib_Number] = "EA Info Number " & $Current_Attrib_Number
	$EAInfoArr[1][$Current_Attrib_Number] = $CurrentAttributeName
	$EAInfoArr[2][$Current_Attrib_Number] = $SizeOfPackedEas
	$EAInfoArr[3][$Current_Attrib_Number] = $NumberOfEaWithFlagSet
	$EAInfoArr[4][$Current_Attrib_Number] = $SizeOfUnpackedEas
EndFunc
;8+2+2+2+namelength+valuesize
Func _Get_Ea($Entry,$Current_Attrib_Number,$CurrentAttributeName)
	Local $LocalAttributeOffset = 1,$TheEa,$OffsetToNextEa,$EaFlags,$EaNameLength,$EaValueLength,$EaCounter=0
;	$TheEa = StringMid($Entry,$LocalAttributeOffset,$SizeOfUnpackedEas*2)
	$TheEa = StringMid($Entry,$LocalAttributeOffset)
	ConsoleWrite("$TheEa: " & @crlf)
	ConsoleWrite(_HexEncode("0x"&$TheEa) & @crlf)
	$OffsetToNextEa = StringMid($Entry,$LocalAttributeOffset,8)
;	ConsoleWrite("$OffsetToNextEa = " & $OffsetToNextEa & @crlf)
	$OffsetToNextEa = Dec(_SwapEndian($OffsetToNextEa),2)
;	ConsoleWrite("$OffsetToNextEa = " & $OffsetToNextEa & @crlf)
	$EaFlags = StringMid($Entry,$LocalAttributeOffset+8,2)
;	ConsoleWrite("$EaFlags = " & $EaFlags & @crlf)
	$EaNameLength = Dec(StringMid($Entry,$LocalAttributeOffset+10,2))
;	ConsoleWrite("$EaNameLength = " & $EaNameLength & @crlf)
	$EaValueLength = StringMid($Entry,$LocalAttributeOffset+12,4)
	$EaValueLength = Dec(_SwapEndian($EaValueLength),2)
;	ConsoleWrite("$EaValueLength = " & $EaValueLength & @crlf)
	$EaName = StringMid($Entry,$LocalAttributeOffset+16,$EaNameLength*2)
;	ConsoleWrite("$EaName = " & $EaName & @crlf)
	$EaName = _HexToString($EaName)
;	ConsoleWrite("$EaName = " & $EaName & @crlf)
	$EaValue = StringMid($Entry,$LocalAttributeOffset+2+16+($EaNameLength*2),$EaValueLength*2)
;	ConsoleWrite("$EaValue = " & $EaValue & @crlf)
	$EAArr[0][$Current_Attrib_Number] = "EA Number " & $Current_Attrib_Number
	$EAArr[1][$Current_Attrib_Number] = $CurrentAttributeName
	$EAArr[2][$Current_Attrib_Number] = $OffsetToNextEa
	$EAArr[3][$Current_Attrib_Number] = $EaFlags
	$EAArr[4][$Current_Attrib_Number] = $EaNameLength
	$EAArr[5][$Current_Attrib_Number] = $EaValueLength
	$EAArr[6][$Current_Attrib_Number] = $EaName
	$EAArr[7][$Current_Attrib_Number] = $EaValue
;	$NextEaOffset = $LocalAttributeOffset+22+($EaNameLength*2)+($EaValueLength*2)
	$NextEaOffset = $LocalAttributeOffset+8+16+($EaNameLength*2)+($EaValueLength*2)
	Do
		$EaCounter += 5
		$NextEaFlag = StringMid($Entry,$NextEaOffset+8,2)
;		ConsoleWrite("$NextEaFlag = " & $NextEaFlag & @crlf)
		$NextEaNameLength = Dec(StringMid($Entry,$NextEaOffset+10,2))
;		ConsoleWrite("$NextEaNameLength = " & $NextEaNameLength & @crlf)
		$NextEaValueLength = StringMid($Entry,$NextEaOffset+12,4)
		$NextEaValueLength = Dec(_SwapEndian($NextEaValueLength),2)
;		ConsoleWrite("$NextEaValueLength = " & $NextEaValueLength & @crlf)
		$NextEaName = StringMid($Entry,$NextEaOffset+16,$NextEaNameLength*2)
;		ConsoleWrite("$NextEaName = " & $NextEaName & @crlf)
		$NextEaName = _HexToString($NextEaName)
		$NextEaValue = StringMid($Entry,$NextEaOffset+2+16+($NextEaNameLength*2),$NextEaValueLength*2)
;		ConsoleWrite("$NextEaName = " & $NextEaName & @crlf)
;		ConsoleWrite("$NextEaValue = " & $NextEaValue & @crlf)
		If $NextEaNameLength = 0 Or $NextEaValueLength = 0 Then ExitLoop
		ReDim $EAArr[8+$EaCounter][$Current_Attrib_Number+1]
		Local $Counter1 = 7+($EaCounter-4)
		Local $Counter2 = 7+($EaCounter-3)
		Local $Counter3 = 7+($EaCounter-2)
		Local $Counter4 = 7+($EaCounter-1)
		Local $Counter5 = 7+($EaCounter-0)
		$EAArr[$Counter1][0] = "NextEaFlag"
		$EAArr[$Counter2][0] = "NextEaNameLength"
		$EAArr[$Counter3][0] = "NextEaValueLength"
		$EAArr[$Counter4][0] = "NextEaName"
		$EAArr[$Counter5][0] = "NextEaValue"
		$EAArr[$Counter1][$Current_Attrib_Number] = $NextEaFlag
		$EAArr[$Counter2][$Current_Attrib_Number] = $NextEaNameLength
		$EAArr[$Counter3][$Current_Attrib_Number] = $NextEaValueLength
		$EAArr[$Counter4][$Current_Attrib_Number] = $NextEaName
		$EAArr[$Counter5][$Current_Attrib_Number] = $NextEaValue
;		$NextEaOffset = $NextEaOffset+22+2+($NextEaNameLength*2)+($NextEaValueLength*2)
		$NextEaOffset = $NextEaOffset+16+($NextEaNameLength*2)+($NextEaValueLength*2)
		If $NextEaOffset + 18 > StringLen($TheEa) Then ExitLoop
	Until $NextEaOffset >= StringLen($TheEa)
;	_ArrayDisplay($EAArr,"$EAArr")
EndFunc

Func _Get_IndexRoot($Entry,$Current_Attrib_Number,$CurrentAttributeName,$IndxType)
	Local $LocalAttributeOffset = 1,$AttributeType,$CollationRule,$SizeOfIndexAllocationEntry,$ClustersPerIndexRoot,$IRPadding
	$AttributeType = StringMid($Entry,$LocalAttributeOffset,8)
;	$AttributeType = _SwapEndian($AttributeType)
	$CollationRule = StringMid($Entry,$LocalAttributeOffset+8,8)
	$CollationRule = _SwapEndian($CollationRule)
	$SizeOfIndexAllocationEntry = StringMid($Entry,$LocalAttributeOffset+16,8)
	$SizeOfIndexAllocationEntry = Dec(_SwapEndian($SizeOfIndexAllocationEntry),2)
	$ClustersPerIndexRoot = Dec(StringMid($Entry,$LocalAttributeOffset+24,2))
;	$IRPadding = StringMid($Entry,$LocalAttributeOffset+26,6)
	$OffsetToFirstEntry = StringMid($Entry,$LocalAttributeOffset+32,8)
	$OffsetToFirstEntry = Dec(_SwapEndian($OffsetToFirstEntry),2)
	$TotalSizeOfEntries = StringMid($Entry,$LocalAttributeOffset+40,8)
	$TotalSizeOfEntries = Dec(_SwapEndian($TotalSizeOfEntries),2)
	$AllocatedSizeOfEntries = StringMid($Entry,$LocalAttributeOffset+48,8)
	$AllocatedSizeOfEntries = Dec(_SwapEndian($AllocatedSizeOfEntries),2)
	$Flags = StringMid($Entry,$LocalAttributeOffset+56,2)
	If $Flags = "01" Then
		$Flags = "01 (Index Allocation needed)"
		$ResidentIndx = 0
	Else
		$Flags = "00 (Fits in Index Root)"
		$ResidentIndx = 1
	EndIf
;	$IRPadding2 = StringMid($Entry,$LocalAttributeOffset+58,6)
	$IRArr[0][$Current_Attrib_Number] = "IndexRoot Number " & $Current_Attrib_Number
	$IRArr[1][$Current_Attrib_Number] = $CurrentAttributeName
	$IRArr[2][$Current_Attrib_Number] = $AttributeType
	$IRArr[3][$Current_Attrib_Number] = $CollationRule
	$IRArr[4][$Current_Attrib_Number] = $SizeOfIndexAllocationEntry
	$IRArr[5][$Current_Attrib_Number] = $ClustersPerIndexRoot
;	$IRArr[6][$Current_Attrib_Number] = $IRPadding
	$IRArr[7][$Current_Attrib_Number] = $OffsetToFirstEntry
	$IRArr[8][$Current_Attrib_Number] = $TotalSizeOfEntries
	$IRArr[9][$Current_Attrib_Number] = $AllocatedSizeOfEntries
	$IRArr[10][$Current_Attrib_Number] = $Flags
;	$IRArr[11][$Current_Attrib_Number] = $IRPadding2
;	If $AttributeType=$FILE_NAME Then
;		$TheResidentIndexEntry = StringMid($Entry,$LocalAttributeOffset+64,($TotalSizeOfEntries*2)-64)
;		_DecodeIndxEntries($TheResidentIndexEntry,$Current_Attrib_Number,$CurrentAttributeName)
;	EndIf
	$TheResidentIndexEntry = StringMid($Entry,$LocalAttributeOffset+64,($TotalSizeOfEntries*2)-64)
	Select
		Case $IndxType = 1
			If StringLen($TheResidentIndexEntry) > 140 Then
				_DecodeIndxEntries($TheResidentIndexEntry,$Current_Attrib_Number,$CurrentAttributeName)
			EndIf
		Case $IndxType = 2
			_Decode_ObjId_O($TheResidentIndexEntry)
	EndSelect
EndFunc

Func _StripIndxRecord($Entry)
;	ConsoleWrite("Starting function _StripIndxRecord()" & @crlf)
	Local $LocalAttributeOffset = 1,$IndxHdrUpdateSeqArrOffset,$IndxHdrUpdateSeqArrSize,$IndxHdrUpdSeqArr,$IndxHdrUpdSeqArrPart0,$IndxHdrUpdSeqArrPart1,$IndxHdrUpdSeqArrPart2,$IndxHdrUpdSeqArrPart3,$IndxHdrUpdSeqArrPart4,$IndxHdrUpdSeqArrPart5,$IndxHdrUpdSeqArrPart6,$IndxHdrUpdSeqArrPart7,$IndxHdrUpdSeqArrPart8
	Local $IndxRecordEnd1,$IndxRecordEnd2,$IndxRecordEnd3,$IndxRecordEnd4,$IndxRecordEnd5,$IndxRecordEnd6,$IndxRecordEnd7,$IndxRecordEnd8,$IndxRecordSize,$IndxHeaderSize,$IsNotLeafNode
;	ConsoleWrite("Unfixed INDX record:" & @crlf)
;	ConsoleWrite(_HexEncode("0x"&$Entry) & @crlf)
;	ConsoleWrite(_HexEncode("0x" & StringMid($Entry,1,4096)) & @crlf)
	$IndxHdrUpdateSeqArrOffset = Dec(_SwapEndian(StringMid($Entry,$LocalAttributeOffset+8,4)))
;	ConsoleWrite("$IndxHdrUpdateSeqArrOffset = " & $IndxHdrUpdateSeqArrOffset & @crlf)
	$IndxHdrUpdateSeqArrSize = Dec(_SwapEndian(StringMid($Entry,$LocalAttributeOffset+12,4)))
;	ConsoleWrite("$IndxHdrUpdateSeqArrSize = " & $IndxHdrUpdateSeqArrSize & @crlf)
	$IndxHdrUpdSeqArr = StringMid($Entry,1+($IndxHdrUpdateSeqArrOffset*2),$IndxHdrUpdateSeqArrSize*2*2)
;	ConsoleWrite("$IndxHdrUpdSeqArr = " & $IndxHdrUpdSeqArr & @crlf)
	$IndxHdrUpdSeqArrPart0 = StringMid($IndxHdrUpdSeqArr,1,4)
	$IndxHdrUpdSeqArrPart1 = StringMid($IndxHdrUpdSeqArr,5,4)
	$IndxHdrUpdSeqArrPart2 = StringMid($IndxHdrUpdSeqArr,9,4)
	$IndxHdrUpdSeqArrPart3 = StringMid($IndxHdrUpdSeqArr,13,4)
	$IndxHdrUpdSeqArrPart4 = StringMid($IndxHdrUpdSeqArr,17,4)
	$IndxHdrUpdSeqArrPart5 = StringMid($IndxHdrUpdSeqArr,21,4)
	$IndxHdrUpdSeqArrPart6 = StringMid($IndxHdrUpdSeqArr,25,4)
	$IndxHdrUpdSeqArrPart7 = StringMid($IndxHdrUpdSeqArr,29,4)
	$IndxHdrUpdSeqArrPart8 = StringMid($IndxHdrUpdSeqArr,33,4)
	$IndxRecordEnd1 = StringMid($Entry,1021,4)
	$IndxRecordEnd2 = StringMid($Entry,2045,4)
	$IndxRecordEnd3 = StringMid($Entry,3069,4)
	$IndxRecordEnd4 = StringMid($Entry,4093,4)
	$IndxRecordEnd5 = StringMid($Entry,5117,4)
	$IndxRecordEnd6 = StringMid($Entry,6141,4)
	$IndxRecordEnd7 = StringMid($Entry,7165,4)
	$IndxRecordEnd8 = StringMid($Entry,8189,4)
	If $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd1 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd2 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd3 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd4 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd5 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd6 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd7 OR $IndxHdrUpdSeqArrPart0 <> $IndxRecordEnd8 Then
		ConsoleWrite("Error the INDX record is corrupt" & @CRLF)
		Return ; Not really correct because I think in theory chunks of 1024 bytes can be invalid and not just everything or nothing for the given INDX record.
	Else
		$Entry = StringMid($Entry,1,1020) & $IndxHdrUpdSeqArrPart1 & StringMid($Entry,1025,1020) & $IndxHdrUpdSeqArrPart2 & StringMid($Entry,2049,1020) & $IndxHdrUpdSeqArrPart3 & StringMid($Entry,3073,1020) & $IndxHdrUpdSeqArrPart4 & StringMid($Entry,4097,1020) & $IndxHdrUpdSeqArrPart5 & StringMid($Entry,5121,1020) & $IndxHdrUpdSeqArrPart6 & StringMid($Entry,6145,1020) & $IndxHdrUpdSeqArrPart7 & StringMid($Entry,7169,1020)
	EndIf
	$IndxRecordSize = Dec(_SwapEndian(StringMid($Entry,$LocalAttributeOffset+56,8)),2)
;	ConsoleWrite("$IndxRecordSize = " & $IndxRecordSize & @crlf)
	$IndxHeaderSize = Dec(_SwapEndian(StringMid($Entry,$LocalAttributeOffset+48,8)),2)
;	ConsoleWrite("$IndxHeaderSize = " & $IndxHeaderSize & @crlf)
	$IsNotLeafNode = StringMid($Entry,$LocalAttributeOffset+72,2) ;1 if not leaf node
	$Entry = StringMid($Entry,$LocalAttributeOffset+48+($IndxHeaderSize*2),($IndxRecordSize-$IndxHeaderSize-16)*2)
	If $IsNotLeafNode = "01" Then  ; This flag leads to the entry being 8 bytes of 00's longer than the others. Can be stripped I think.
		$Entry = StringTrimRight($Entry,16)
;		ConsoleWrite("Is not leaf node..." & @crlf)
	EndIf
	Return $Entry
EndFunc

Func _Get_IndexAllocation($Entry,$Current_Attrib_Number,$CurrentAttributeName,$IndxType)
;	ConsoleWrite("Starting function _Get_IndexAllocation()" & @crlf)
	Local $NextPosition = 1,$IndxHdrMagic,$IndxEntries,$TotalIndxEntries
;	ConsoleWrite("StringLen of chunk = " & StringLen($Entry) & @crlf)
;	ConsoleWrite("Expected records = " & StringLen($Entry)/8192 & @crlf)
	$NextPosition = 1
	Do
		$IndxHdrMagic = StringMid($Entry,$NextPosition,8)
;		ConsoleWrite("$IndxHdrMagic = " & $IndxHdrMagic & @crlf)
		$IndxHdrMagic = _HexToString($IndxHdrMagic)
;		ConsoleWrite("$IndxHdrMagic = " & $IndxHdrMagic & @crlf)
		If $IndxHdrMagic <> "INDX" Then
;			ConsoleWrite("$IndxHdrMagic: " & $IndxHdrMagic & @crlf)
;			ConsoleWrite("Error: Record is not of type INDX, and this was not expected.." & @crlf)
			$NextPosition += 8192
			ContinueLoop
		EndIf
		$IndxEntries = _StripIndxRecord(StringMid($Entry,$NextPosition,8192))
		$TotalIndxEntries &= $IndxEntries
		$NextPosition += 8192
	Until $NextPosition >= StringLen($Entry)+32
;	ConsoleWrite("INDX record:" & @crlf)
;	ConsoleWrite(_HexEncode("0x"& StringMid($Entry,1)) & @crlf)
;	ConsoleWrite("Total chunk of stripped INDX entries:" & @crlf)
;	ConsoleWrite(_HexEncode("0x"& StringMid($TotalIndxEntries,1)) & @crlf)
	Select
		Case $IndxType = 1
			_DecodeIndxEntries($TotalIndxEntries,$Current_Attrib_Number,$CurrentAttributeName)
		Case $IndxType = 2
			_Decode_ObjId_O($TotalIndxEntries)
	EndSelect
EndFunc

Func _Decode_ObjId_O($InputData)
	Local $Counter=1, $OrigArraySize=UBound($IndxObjIdOArr)
	Local $GUID_ObjectID_Version,$GUID_ObjectID_Timestamp,$GUID_ObjectID_TimestampDec,$GUID_ObjectID_ClockSeq,$GUID_ObjectID_Node
	Local $GUID_BirthVolumeID_Version,$GUID_BirthVolumeID_Timestamp,$GUID_BirthVolumeID_TimestampDec,$GUID_BirthVolumeID_ClockSeq,$GUID_BirthVolumeID_Node
	Local $GUID_BirthObjectID_Version,$GUID_BirthObjectID_Timestamp,$GUID_BirthObjectID_TimestampDec,$GUID_BirthObjectID_ClockSeq,$GUID_BirthObjectID_Node
	Local $GUID_DomainID_Version,$GUID_DomainID_Timestamp,$GUID_DomainID_TimestampDec,$GUID_DomainID_ClockSeq,$GUID_DomainID_Node

	;88 bytes
	$StartOffset = 1
	$InputDataSize = StringLen($InputData)

	;ConsoleWrite("_Decode_ObjId_O():" & @CRLF)
	;ConsoleWrite(_HexEncode("0x"&$InputData) & @CRLF)

	Do
		$DataOffset = StringMid($InputData, $StartOffset, 4)
		$DataOffset = Dec(_SwapEndian($DataOffset),2)

		$DataSize = StringMid($InputData, $StartOffset + 4, 4)
		$DataSize = Dec(_SwapEndian($DataSize),2)

		If $DataOffset = 0 Or $DataSize = 0 Then $StartOffset+=16

		;Padding 4 bytes
		$IndexEntrySize = StringMid($InputData, $StartOffset + 16, 4)
		$IndexEntrySize = Dec(_SwapEndian($IndexEntrySize),2)
		If $IndexEntrySize = 0 Then ExitLoop

		$IndexKeySize = StringMid($InputData, $StartOffset + 20, 4)
		$IndexKeySize = Dec(_SwapEndian($IndexKeySize),2)

		;1=Entry has subnodes, 2=Last entry
		$Flags = StringMid($InputData, $StartOffset + 24, 4)
		$Flags = "0x" & _SwapEndian($Flags)

		;Padding 2 bytes

		;ObjectId
		$GUID_ObjectId = StringMid($InputData, $StartOffset + 32, 32)
		;Decode guid
		$GUID_ObjectID_Version = Dec(StringMid($GUID_ObjectID,15,1))
		$GUID_ObjectID_Timestamp = StringMid($GUID_ObjectID,1,14) & "0" & StringMid($GUID_ObjectID,16,1)
		$GUID_ObjectID_TimestampDec = Dec(_SwapEndian($GUID_ObjectID_Timestamp),2)
		$GUID_ObjectID_Timestamp = _DecodeTimestampFromGuid($GUID_ObjectID_Timestamp)
		$GUID_ObjectID_ClockSeq = StringMid($GUID_ObjectID,17,4)
		$GUID_ObjectID_ClockSeq = Dec($GUID_ObjectID_ClockSeq)
		$GUID_ObjectID_Node = StringMid($GUID_ObjectID,21,12)
		$GUID_ObjectID_Node = _DecodeMacFromGuid($GUID_ObjectID_Node)
		$GUID_ObjectID = _HexToGuidStr($GUID_ObjectID,1)

		$MftRef = StringMid($InputData, $StartOffset + 64, 12)
		$MftRef = Dec(_SwapEndian($MftRef),2)

		$MftSeqNo = StringMid($InputData, $StartOffset + 76, 4)
		$MftSeqNo = Dec(_SwapEndian($MftSeqNo),2)

		;BirthVolumeId
		$GUID_BirthVolumeId = StringMid($InputData, $StartOffset + 80, 32)
		;Decode guid
		$GUID_BirthVolumeID_Version = Dec(StringMid($GUID_BirthVolumeID,15,1))
		$GUID_BirthVolumeID_Timestamp = StringMid($GUID_BirthVolumeID,1,14) & "0" & StringMid($GUID_BirthVolumeID,16,1)
		$GUID_BirthVolumeID_TimestampDec = Dec(_SwapEndian($GUID_BirthVolumeID_Timestamp),2)
		$GUID_BirthVolumeID_Timestamp = _DecodeTimestampFromGuid($GUID_BirthVolumeID_Timestamp)
		$GUID_BirthVolumeID_ClockSeq = StringMid($GUID_BirthVolumeID,17,4)
		$GUID_BirthVolumeID_ClockSeq = Dec($GUID_BirthVolumeID_ClockSeq)
		$GUID_BirthVolumeID_Node = StringMid($GUID_BirthVolumeID,21,12)
		$GUID_BirthVolumeID_Node = _DecodeMacFromGuid($GUID_BirthVolumeID_Node)
		$GUID_BirthVolumeID = _HexToGuidStr($GUID_BirthVolumeID,1)

		;BirthObjectId
		$GUID_BirthObjectId = StringMid($InputData, $StartOffset + 112, 32)
		;Decode guid
		$GUID_BirthObjectID_Version = Dec(StringMid($GUID_BirthObjectID,15,1))
		$GUID_BirthObjectID_Timestamp = StringMid($GUID_BirthObjectID,1,14) & "0" & StringMid($GUID_BirthObjectID,16,1)
		$GUID_BirthObjectID_TimestampDec = Dec(_SwapEndian($GUID_BirthObjectID_Timestamp),2)
		$GUID_BirthObjectID_Timestamp = _DecodeTimestampFromGuid($GUID_BirthObjectID_Timestamp)
		$GUID_BirthObjectID_ClockSeq = StringMid($GUID_BirthObjectID,17,4)
		$GUID_BirthObjectID_ClockSeq = Dec($GUID_BirthObjectID_ClockSeq)
		$GUID_BirthObjectID_Node = StringMid($GUID_BirthObjectID,21,12)
		$GUID_BirthObjectID_Node = _DecodeMacFromGuid($GUID_BirthObjectID_Node)
		$GUID_BirthObjectID = _HexToGuidStr($GUID_BirthObjectID,1)

		;DomainId
		$GUID_DomainId = StringMid($InputData, $StartOffset + 144, 32)
		;Decode guid
		$GUID_DomainID_Version = Dec(StringMid($GUID_DomainID,15,1))
		$GUID_DomainID_Timestamp = StringMid($GUID_DomainID,1,14) & "0" & StringMid($GUID_DomainID,16,1)
		$GUID_DomainID_TimestampDec = Dec(_SwapEndian($GUID_DomainID_Timestamp),2)
		$GUID_DomainID_Timestamp = _DecodeTimestampFromGuid($GUID_DomainID_Timestamp)
		$GUID_DomainID_ClockSeq = StringMid($GUID_DomainID,17,4)
		$GUID_DomainID_ClockSeq = Dec($GUID_DomainID_ClockSeq)
		$GUID_DomainID_Node = StringMid($GUID_DomainID,21,12)
		$GUID_DomainID_Node = _DecodeMacFromGuid($GUID_DomainID_Node)
		$GUID_DomainID = _HexToGuidStr($GUID_DomainID,1)
		#cs
		ConsoleWrite(@CRLF)
		;ConsoleWrite(_HexEncode("0x"&StringMid($InputData, $StartOffset, $IndexEntrySize*2)) & @CRLF)
		ConsoleWrite("$Counter: " & $Counter & @CRLF)
		ConsoleWrite("$DataOffset: " & $DataOffset & @CRLF)
		ConsoleWrite("$DataSize: " & $DataSize & @CRLF)
		ConsoleWrite("$IndexEntrySize: " & $IndexEntrySize & @CRLF)
		ConsoleWrite("$IndexKeySize: " & $IndexKeySize & @CRLF)
		ConsoleWrite("$Flags: " & $Flags & @CRLF)
		ConsoleWrite("$MftRef: " & $MftRef & @CRLF)
		ConsoleWrite("$MftSeqNo: " & $MftSeqNo & @CRLF)
		ConsoleWrite("$GUID_ObjectID: " & $GUID_ObjectID & @CRLF)
		ConsoleWrite("$GUID_ObjectID_Version: " & $GUID_ObjectID_Version & @CRLF)
		ConsoleWrite("$GUID_ObjectID_Timestamp: " & $GUID_ObjectID_Timestamp & @CRLF)
		ConsoleWrite("$GUID_ObjectID_TimestampDec: " & $GUID_ObjectID_TimestampDec & @CRLF)
		ConsoleWrite("$GUID_ObjectID_ClockSeq: " & $GUID_ObjectID_ClockSeq & @CRLF)
		ConsoleWrite("$GUID_ObjectID_Node: " & $GUID_ObjectID_Node & @CRLF)
		ConsoleWrite("$GUID_BirthVolumeID: " & $GUID_BirthVolumeID & @CRLF)
		ConsoleWrite("$GUID_BirthVolumeID_Version: " & $GUID_BirthVolumeID_Version & @CRLF)
		ConsoleWrite("$GUID_BirthVolumeID_Timestamp: " & $GUID_BirthVolumeID_Timestamp & @CRLF)
		ConsoleWrite("$GUID_BirthVolumeID_TimestampDec: " & $GUID_BirthVolumeID_TimestampDec & @CRLF)
		ConsoleWrite("$GUID_BirthVolumeID_ClockSeq: " & $GUID_BirthVolumeID_ClockSeq & @CRLF)
		ConsoleWrite("$GUID_BirthVolumeID_Node: " & $GUID_BirthVolumeID_Node & @CRLF)
		ConsoleWrite("$GUID_BirthObjectID: " & $GUID_BirthObjectID & @CRLF)
		ConsoleWrite("$GUID_BirthObjectID_Version: " & $GUID_BirthObjectID_Version & @CRLF)
		ConsoleWrite("$GUID_BirthObjectID_Timestamp: " & $GUID_BirthObjectID_Timestamp & @CRLF)
		ConsoleWrite("$GUID_BirthObjectID_TimestampDec: " & $GUID_BirthObjectID_TimestampDec & @CRLF)
		ConsoleWrite("$GUID_BirthObjectID_ClockSeq: " & $GUID_BirthObjectID_ClockSeq & @CRLF)
		ConsoleWrite("$GUID_BirthObjectID_Node: " & $GUID_BirthObjectID_Node & @CRLF)
		ConsoleWrite("$GUID_DomainID: " & $GUID_DomainID & @CRLF)
		ConsoleWrite("$GUID_DomainID_Version: " & $GUID_DomainID_Version & @CRLF)
		ConsoleWrite("$GUID_DomainID_Timestamp: " & $GUID_DomainID_Timestamp & @CRLF)
		ConsoleWrite("$GUID_DomainID_TimestampDec: " & $GUID_DomainID_TimestampDec & @CRLF)
		ConsoleWrite("$GUID_DomainID_ClockSeq: " & $GUID_DomainID_ClockSeq & @CRLF)
		ConsoleWrite("$GUID_DomainID_Node: " & $GUID_DomainID_Node & @CRLF)
		#ce

		ReDim $IndxObjIdOArr[$OrigArraySize+$Counter][27]
		;$IndxObjIdOArr[$OrigArraySize+$Counter-1][0] = "Value"
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][1] = $MftRef
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][2] = $MftSeqNo
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][3] = $GUID_ObjectID
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][4] = $GUID_ObjectID_Version
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][5] = $GUID_ObjectID_Timestamp
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][6] = $GUID_ObjectID_TimestampDec
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][7] = $GUID_ObjectID_ClockSeq
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][8] = $GUID_ObjectID_Node
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][9] = $GUID_BirthVolumeID
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][10] = $GUID_BirthVolumeID_Version
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][11] = $GUID_BirthVolumeID_Timestamp
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][12] = $GUID_BirthVolumeID_TimestampDec
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][13] = $GUID_BirthVolumeID_ClockSeq
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][14] = $GUID_BirthVolumeID_Node
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][15] = $GUID_BirthObjectID
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][16] = $GUID_BirthObjectID_Version
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][17] = $GUID_BirthObjectID_Timestamp
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][18] = $GUID_BirthObjectID_TimestampDec
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][19] = $GUID_BirthObjectID_ClockSeq
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][20] = $GUID_BirthObjectID_Node
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][21] = $GUID_DomainID
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][22] = $GUID_DomainID_Version
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][23] = $GUID_DomainID_Timestamp
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][24] = $GUID_DomainID_TimestampDec
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][25] = $GUID_DomainID_ClockSeq
		$IndxObjIdOArr[$OrigArraySize+$Counter-1][26] = $GUID_DomainID_Node

		$StartOffset += $IndexEntrySize*2
		$Counter+=1
	Until $StartOffset >= $InputDataSize
EndFunc

Func _DecodeIndxEntries($Entry,$Current_Attrib_Number,$CurrentAttributeName)
;	ConsoleWrite("Starting function _DecodeIndxEntries()" & @crlf)
	Local $LocalAttributeOffset = 1,$NewLocalAttributeOffset,$IndxHdrMagic,$IndxHdrUpdateSeqArrOffset,$IndxHdrUpdateSeqArrSize,$IndxHdrLogFileSequenceNo,$IndxHdrVCNOfIndx,$IndxHdrOffsetToIndexEntries,$IndxHdrSizeOfIndexEntries,$IndxHdrAllocatedSizeOfIndexEntries
	Local $IndxHdrFlag,$IndxHdrPadding,$IndxHdrUpdateSequence,$IndxHdrUpdSeqArr,$IndxHdrUpdSeqArrPart0,$IndxHdrUpdSeqArrPart1,$IndxHdrUpdSeqArrPart2,$IndxHdrUpdSeqArrPart3,$IndxRecordEnd4,$IndxRecordEnd1,$IndxRecordEnd2,$IndxRecordEnd3,$IndxRecordEnd4
	Local $FileReference,$IndexEntryLength,$StreamLength,$Flags,$Stream,$SubNodeVCN,$tmp0=0,$tmp1=0,$tmp2=0,$tmp3=0,$Padding2,$EntryCounter=UBound($IndxFileNameArr)
	$NewLocalAttributeOffset = 1
	$MFTReference = StringMid($Entry,$NewLocalAttributeOffset,12)
	$MFTReference = StringMid($MFTReference,7,2)&StringMid($MFTReference,5,2)&StringMid($MFTReference,3,2)&StringMid($MFTReference,1,2)
	$MFTReference = Dec($MFTReference)
	$MFTReferenceSeqNo = StringMid($Entry,$NewLocalAttributeOffset+12,4)
	$MFTReferenceSeqNo = Dec(StringMid($MFTReferenceSeqNo,3,2)&StringMid($MFTReferenceSeqNo,1,2))
	$IndexEntryLength = StringMid($Entry,$NewLocalAttributeOffset+16,4)
	$IndexEntryLength = Dec(StringMid($IndexEntryLength,3,2)&StringMid($IndexEntryLength,1,2))
	$OffsetToFileName = StringMid($Entry,$NewLocalAttributeOffset+20,4)
	$OffsetToFileName = Dec(StringMid($OffsetToFileName,3,2)&StringMid($OffsetToFileName,1,2))
	$IndexFlags = StringMid($Entry,$NewLocalAttributeOffset+24,4)
;	$Padding = StringMid($Entry,$NewLocalAttributeOffset+28,4)
	$MFTReferenceOfParent = StringMid($Entry,$NewLocalAttributeOffset+32,12)
	$MFTReferenceOfParent = StringMid($MFTReferenceOfParent,7,2)&StringMid($MFTReferenceOfParent,5,2)&StringMid($MFTReferenceOfParent,3,2)&StringMid($MFTReferenceOfParent,1,2)
	$MFTReferenceOfParent = Dec($MFTReferenceOfParent)
	$MFTReferenceOfParentSeqNo = StringMid($Entry,$NewLocalAttributeOffset+44,4)
	$MFTReferenceOfParentSeqNo = Dec(StringMid($MFTReferenceOfParentSeqNo,3,2) & StringMid($MFTReferenceOfParentSeqNo,1,2))
	$Indx_CTime = StringMid($Entry,$NewLocalAttributeOffset+48,16)
	$Indx_CTime = StringMid($Indx_CTime,15,2) & StringMid($Indx_CTime,13,2) & StringMid($Indx_CTime,11,2) & StringMid($Indx_CTime,9,2) & StringMid($Indx_CTime,7,2) & StringMid($Indx_CTime,5,2) & StringMid($Indx_CTime,3,2) & StringMid($Indx_CTime,1,2)
	$Indx_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_CTime)
	$Indx_CTime = _WinTime_UTCFileTimeFormat(Dec($Indx_CTime)-$tDelta,$DateTimeFormat,2)
	If @error Then
		$Indx_CTime = "-"
	Else
		$Indx_CTime = $Indx_CTime & ":" & _FillZero(StringRight($Indx_CTime_tmp,4))
	EndIf
	$Indx_ATime = StringMid($Entry,$NewLocalAttributeOffset+64,16)
	$Indx_ATime = StringMid($Indx_ATime,15,2) & StringMid($Indx_ATime,13,2) & StringMid($Indx_ATime,11,2) & StringMid($Indx_ATime,9,2) & StringMid($Indx_ATime,7,2) & StringMid($Indx_ATime,5,2) & StringMid($Indx_ATime,3,2) & StringMid($Indx_ATime,1,2)
	$Indx_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_ATime)
	$Indx_ATime = _WinTime_UTCFileTimeFormat(Dec($Indx_ATime)-$tDelta,$DateTimeFormat,2)
	If @error Then
		$Indx_ATime = "-"
	Else
		$Indx_ATime = $Indx_ATime & ":" & _FillZero(StringRight($Indx_ATime_tmp,4))
	EndIf
	$Indx_MTime = StringMid($Entry,$NewLocalAttributeOffset+80,16)
	$Indx_MTime = StringMid($Indx_MTime,15,2) & StringMid($Indx_MTime,13,2) & StringMid($Indx_MTime,11,2) & StringMid($Indx_MTime,9,2) & StringMid($Indx_MTime,7,2) & StringMid($Indx_MTime,5,2) & StringMid($Indx_MTime,3,2) & StringMid($Indx_MTime,1,2)
	$Indx_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_MTime)
	$Indx_MTime = _WinTime_UTCFileTimeFormat(Dec($Indx_MTime)-$tDelta,$DateTimeFormat,2)
	If @error Then
		$Indx_MTime = "-"
	Else
		$Indx_MTime = $Indx_MTime & ":" & _FillZero(StringRight($Indx_MTime_tmp,4))
	EndIf
	$Indx_RTime = StringMid($Entry,$NewLocalAttributeOffset+96,16)
	$Indx_RTime = StringMid($Indx_RTime,15,2) & StringMid($Indx_RTime,13,2) & StringMid($Indx_RTime,11,2) & StringMid($Indx_RTime,9,2) & StringMid($Indx_RTime,7,2) & StringMid($Indx_RTime,5,2) & StringMid($Indx_RTime,3,2) & StringMid($Indx_RTime,1,2)
	$Indx_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_RTime)
	$Indx_RTime = _WinTime_UTCFileTimeFormat(Dec($Indx_RTime)-$tDelta,$DateTimeFormat,2)
	If @error Then
		$Indx_RTime = "-"
	Else
		$Indx_RTime = $Indx_RTime & ":" & _FillZero(StringRight($Indx_RTime_tmp,4))
	EndIf
	$Indx_AllocSize = StringMid($Entry,$NewLocalAttributeOffset+112,16)
	$Indx_AllocSize = Dec(StringMid($Indx_AllocSize,15,2) & StringMid($Indx_AllocSize,13,2) & StringMid($Indx_AllocSize,11,2) & StringMid($Indx_AllocSize,9,2) & StringMid($Indx_AllocSize,7,2) & StringMid($Indx_AllocSize,5,2) & StringMid($Indx_AllocSize,3,2) & StringMid($Indx_AllocSize,1,2))
	$Indx_RealSize = StringMid($Entry,$NewLocalAttributeOffset+128,16)
	$Indx_RealSize = Dec(StringMid($Indx_RealSize,15,2) & StringMid($Indx_RealSize,13,2) & StringMid($Indx_RealSize,11,2) & StringMid($Indx_RealSize,9,2) & StringMid($Indx_RealSize,7,2) & StringMid($Indx_RealSize,5,2) & StringMid($Indx_RealSize,3,2) & StringMid($Indx_RealSize,1,2))
;	$Indx_File_Flags = StringMid($Entry,$NewLocalAttributeOffset+144,16)
;	ConsoleWrite("Unknown INDX flag: " & StringLen($Indx_File_Flags) & @CRLF)
;	ConsoleWrite("Unknown INDX flag: " & $Indx_File_Flags & @CRLF)
;	ConsoleWrite("Unknown INDX flag: " & StringMid($Indx_File_Flags,1,8) & @CRLF)
	$Indx_File_Flags = StringMid($Entry,$NewLocalAttributeOffset+144,8)
	$Indx_File_Flags = _SwapEndian($Indx_File_Flags)
	$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
	$Indx_ReparseTag = StringMid($Entry,$NewLocalAttributeOffset+152,8)
	$Indx_ReparseTag = _SwapEndian($Indx_ReparseTag)
	$Indx_ReparseTag = _GetReparseType("0x"&$Indx_ReparseTag)
	$Indx_NameLength = StringMid($Entry,$NewLocalAttributeOffset+160,2)
	$Indx_NameLength = Dec($Indx_NameLength)
	$Indx_NameSpace = StringMid($Entry,$NewLocalAttributeOffset+162,2)
	Select
		Case $Indx_NameSpace = "00"	;POSIX
			$Indx_NameSpace = "POSIX"
		Case $Indx_NameSpace = "01"	;WIN32
			$Indx_NameSpace = "WIN32"
		Case $Indx_NameSpace = "02"	;DOS
			$Indx_NameSpace = "DOS"
		Case $Indx_NameSpace = "03"	;DOS+WIN32
			$Indx_NameSpace = "DOS+WIN32"
	EndSelect
	$Indx_FileName = StringMid($Entry,$NewLocalAttributeOffset+164,$Indx_NameLength*2*2)
	$Indx_FileName = _UnicodeHexToStr($Indx_FileName)
	$tmp1 = 164+($Indx_NameLength*2*2)
	Do ; Calculate the length of the padding - 8 byte aligned
		$tmp2 = $tmp1/16
		If Not IsInt($tmp2) Then
			$tmp0 = 2
			$tmp1 += $tmp0
			$tmp3 += $tmp0
		EndIf
	Until IsInt($tmp2)
	$PaddingLength = $tmp3
;	$Padding2 = StringMid($Entry,$NewLocalAttributeOffset+164+($Indx_NameLength*2*2),$PaddingLength)
	If $IndexFlags <> "0000" Then
		$SubNodeVCN = StringMid($Entry,$NewLocalAttributeOffset+164+($Indx_NameLength*2*2)+$PaddingLength,16)
		$SubNodeVCNLength = 16
	Else
		$SubNodeVCN = ""
		$SubNodeVCNLength = 0
	EndIf
	ReDim $IndxEntryNumberArr[1+$EntryCounter]
	ReDim $IndxMFTReferenceArr[1+$EntryCounter]
	ReDim $IndxMFTRefSeqNoArr[1+$EntryCounter]
	ReDim $IndxIndexFlagsArr[1+$EntryCounter]
	ReDim $IndxMFTReferenceOfParentArr[1+$EntryCounter]
	ReDim $IndxMFTParentRefSeqNoArr[1+$EntryCounter]
	ReDim $IndxCTimeArr[1+$EntryCounter]
	ReDim $IndxATimeArr[1+$EntryCounter]
	ReDim $IndxMTimeArr[1+$EntryCounter]
	ReDim $IndxRTimeArr[1+$EntryCounter]
	ReDim $IndxAllocSizeArr[1+$EntryCounter]
	ReDim $IndxRealSizeArr[1+$EntryCounter]
	ReDim $IndxFileFlagsArr[1+$EntryCounter]
	ReDim $IndxReparseTagArr[1+$EntryCounter]
	ReDim $IndxFileNameArr[1+$EntryCounter]
	ReDim $IndxNameSpaceArr[1+$EntryCounter]
	ReDim $IndxSubNodeVCNArr[1+$EntryCounter]
	$IndxEntryNumberArr[$EntryCounter] = $EntryCounter
	$IndxMFTReferenceArr[$EntryCounter] = $MFTReference
	$IndxMFTRefSeqNoArr[$EntryCounter] = $MFTReferenceSeqNo
	$IndxIndexFlagsArr[$EntryCounter] = $IndexFlags
	$IndxMFTReferenceOfParentArr[$EntryCounter] = $MFTReferenceOfParent
	$IndxMFTParentRefSeqNoArr[$EntryCounter] = $MFTReferenceOfParentSeqNo
	$IndxCTimeArr[$EntryCounter] = $Indx_CTime
	$IndxATimeArr[$EntryCounter] = $Indx_ATime
	$IndxMTimeArr[$EntryCounter] = $Indx_MTime
	$IndxRTimeArr[$EntryCounter] = $Indx_RTime
	$IndxAllocSizeArr[$EntryCounter] = $Indx_AllocSize
	$IndxRealSizeArr[$EntryCounter] = $Indx_RealSize
	$IndxFileFlagsArr[$EntryCounter] = $Indx_File_Flags
	$IndxReparseTagArr[$EntryCounter] = $Indx_ReparseTag
	$IndxFileNameArr[$EntryCounter] = $Indx_FileName
	$IndxNameSpaceArr[$EntryCounter] = $Indx_NameSpace
	$IndxSubNodeVCNArr[$EntryCounter] = $SubNodeVCN
; Work through the rest of the index entries
	$NextEntryOffset = $NewLocalAttributeOffset+164+($Indx_NameLength*2*2)+$PaddingLength+$SubNodeVCNLength
	If $NextEntryOffset+64 >= StringLen($Entry) Then Return
	Do
		$EntryCounter += 1
;		ConsoleWrite("$EntryCounter = " & $EntryCounter & @crlf)
		$MFTReference = StringMid($Entry,$NextEntryOffset,12)
;		ConsoleWrite("$MFTReference = " & $MFTReference & @crlf)
		$MFTReference = StringMid($MFTReference,7,2)&StringMid($MFTReference,5,2)&StringMid($MFTReference,3,2)&StringMid($MFTReference,1,2)
;		$MFTReference = StringMid($MFTReference,15,2)&StringMid($MFTReference,13,2)&StringMid($MFTReference,11,2)&StringMid($MFTReference,9,2)&StringMid($MFTReference,7,2)&StringMid($MFTReference,5,2)&StringMid($MFTReference,3,2)&StringMid($MFTReference,1,2)
;		ConsoleWrite("$MFTReference = " & $MFTReference & @crlf)
		$MFTReference = Dec($MFTReference)
		$MFTReferenceSeqNo = StringMid($Entry,$NextEntryOffset+12,4)
		$MFTReferenceSeqNo = Dec(StringMid($MFTReferenceSeqNo,3,2)&StringMid($MFTReferenceSeqNo,1,2))
		$IndexEntryLength = StringMid($Entry,$NextEntryOffset+16,4)
;		ConsoleWrite("$IndexEntryLength = " & $IndexEntryLength & @crlf)
		$IndexEntryLength = Dec(StringMid($IndexEntryLength,3,2)&StringMid($IndexEntryLength,1,2))
;		ConsoleWrite("$IndexEntryLength = " & $IndexEntryLength & @crlf)
		$OffsetToFileName = StringMid($Entry,$NextEntryOffset+20,4)
;		ConsoleWrite("$OffsetToFileName = " & $OffsetToFileName & @crlf)
		$OffsetToFileName = Dec(StringMid($OffsetToFileName,3,2)&StringMid($OffsetToFileName,1,2))
;		ConsoleWrite("$OffsetToFileName = " & $OffsetToFileName & @crlf)
		$IndexFlags = StringMid($Entry,$NextEntryOffset+24,4)
;		ConsoleWrite("$IndexFlags = " & $IndexFlags & @crlf)
		$Padding = StringMid($Entry,$NextEntryOffset+28,4)
;		ConsoleWrite("$Padding = " & $Padding & @crlf)
		$MFTReferenceOfParent = StringMid($Entry,$NextEntryOffset+32,12)
;		ConsoleWrite("$MFTReferenceOfParent = " & $MFTReferenceOfParent & @crlf)
		$MFTReferenceOfParent = StringMid($MFTReferenceOfParent,7,2)&StringMid($MFTReferenceOfParent,5,2)&StringMid($MFTReferenceOfParent,3,2)&StringMid($MFTReferenceOfParent,1,2)
;		$MFTReferenceOfParent = StringMid($MFTReferenceOfParent,15,2)&StringMid($MFTReferenceOfParent,13,2)&StringMid($MFTReferenceOfParent,11,2)&StringMid($MFTReferenceOfParent,9,2)&StringMid($MFTReferenceOfParent,7,2)&StringMid($MFTReferenceOfParent,5,2)&StringMid($MFTReferenceOfParent,3,2)&StringMid($MFTReferenceOfParent,1,2)
;		ConsoleWrite("$MFTReferenceOfParent = " & $MFTReferenceOfParent & @crlf)
		$MFTReferenceOfParent = Dec($MFTReferenceOfParent)
		$MFTReferenceOfParentSeqNo = StringMid($Entry,$NextEntryOffset+44,4)
		$MFTReferenceOfParentSeqNo = Dec(StringMid($MFTReferenceOfParentSeqNo,3,2) & StringMid($MFTReferenceOfParentSeqNo,1,2))

		$Indx_CTime = StringMid($Entry,$NextEntryOffset+48,16)
		$Indx_CTime = StringMid($Indx_CTime,15,2) & StringMid($Indx_CTime,13,2) & StringMid($Indx_CTime,11,2) & StringMid($Indx_CTime,9,2) & StringMid($Indx_CTime,7,2) & StringMid($Indx_CTime,5,2) & StringMid($Indx_CTime,3,2) & StringMid($Indx_CTime,1,2)
		$Indx_CTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_CTime)
		$Indx_CTime = _WinTime_UTCFileTimeFormat(Dec($Indx_CTime)-$tDelta,$DateTimeFormat,2)
		If @error Then
			$Indx_CTime = "-"
		Else
			$Indx_CTime = $Indx_CTime & ":" & _FillZero(StringRight($Indx_CTime_tmp,4))
		EndIf
		$Indx_ATime = StringMid($Entry,$NextEntryOffset+64,16)
		$Indx_ATime = StringMid($Indx_ATime,15,2) & StringMid($Indx_ATime,13,2) & StringMid($Indx_ATime,11,2) & StringMid($Indx_ATime,9,2) & StringMid($Indx_ATime,7,2) & StringMid($Indx_ATime,5,2) & StringMid($Indx_ATime,3,2) & StringMid($Indx_ATime,1,2)
		$Indx_ATime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_ATime)
		$Indx_ATime = _WinTime_UTCFileTimeFormat(Dec($Indx_ATime)-$tDelta,$DateTimeFormat,2)
		If @error Then
			$Indx_ATime = "-"
		Else
			$Indx_ATime = $Indx_ATime & ":" & _FillZero(StringRight($Indx_ATime_tmp,4))
		EndIf
		$Indx_MTime = StringMid($Entry,$NextEntryOffset+80,16)
		$Indx_MTime = StringMid($Indx_MTime,15,2) & StringMid($Indx_MTime,13,2) & StringMid($Indx_MTime,11,2) & StringMid($Indx_MTime,9,2) & StringMid($Indx_MTime,7,2) & StringMid($Indx_MTime,5,2) & StringMid($Indx_MTime,3,2) & StringMid($Indx_MTime,1,2)
		$Indx_MTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_MTime)
		$Indx_MTime = _WinTime_UTCFileTimeFormat(Dec($Indx_MTime)-$tDelta,$DateTimeFormat,2)
		If @error Then
			$Indx_MTime = "-"
		Else
			$Indx_MTime = $Indx_MTime & ":" & _FillZero(StringRight($Indx_MTime_tmp,4))
		EndIf
		$Indx_RTime = StringMid($Entry,$NextEntryOffset+96,16)
		$Indx_RTime = StringMid($Indx_RTime,15,2) & StringMid($Indx_RTime,13,2) & StringMid($Indx_RTime,11,2) & StringMid($Indx_RTime,9,2) & StringMid($Indx_RTime,7,2) & StringMid($Indx_RTime,5,2) & StringMid($Indx_RTime,3,2) & StringMid($Indx_RTime,1,2)
		$Indx_RTime_tmp = _WinTime_UTCFileTimeToLocalFileTime("0x" & $Indx_RTime)
		$Indx_RTime = _WinTime_UTCFileTimeFormat(Dec($Indx_RTime)-$tDelta,$DateTimeFormat,2)
		If @error Then
			$Indx_RTime = "-"
		Else
			$Indx_RTime = $Indx_RTime & ":" & _FillZero(StringRight($Indx_RTime_tmp,4))
		EndIf
		$Indx_AllocSize = StringMid($Entry,$NextEntryOffset+112,16)
		$Indx_AllocSize = Dec(StringMid($Indx_AllocSize,15,2) & StringMid($Indx_AllocSize,13,2) & StringMid($Indx_AllocSize,11,2) & StringMid($Indx_AllocSize,9,2) & StringMid($Indx_AllocSize,7,2) & StringMid($Indx_AllocSize,5,2) & StringMid($Indx_AllocSize,3,2) & StringMid($Indx_AllocSize,1,2))
;		ConsoleWrite("$Indx_AllocSize = " & $Indx_AllocSize & @crlf)
		$Indx_RealSize = StringMid($Entry,$NextEntryOffset+128,16)
		$Indx_RealSize = Dec(StringMid($Indx_RealSize,15,2) & StringMid($Indx_RealSize,13,2) & StringMid($Indx_RealSize,11,2) & StringMid($Indx_RealSize,9,2) & StringMid($Indx_RealSize,7,2) & StringMid($Indx_RealSize,5,2) & StringMid($Indx_RealSize,3,2) & StringMid($Indx_RealSize,1,2))
;		ConsoleWrite("$Indx_RealSize = " & $Indx_RealSize & @crlf)
;		$Indx_File_Flags = StringMid($Entry,$NextEntryOffset+144,16)
;		ConsoleWrite("Unknown INDX flag: " & StringLen($Indx_File_Flags) & @CRLF)
;		ConsoleWrite("Unknown INDX flag: " & $Indx_File_Flags & @CRLF)
;		ConsoleWrite("Unknown INDX flag: " & StringMid($Indx_File_Flags,1,8) & @CRLF)
;		ConsoleWrite("$Indx_File_Flags = " & $Indx_File_Flags & @crlf)
;		ConsoleWrite("$Indx_File_Flags = " & $Indx_File_Flags & @crlf)
;		$Indx_File_Flags = StringMid(_SwapEndian($Indx_File_Flags),9,8)
;		$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
;		ConsoleWrite("$Indx_File_Flags = " & $Indx_File_Flags & @crlf)
		$Indx_File_Flags = StringMid($Entry,$NextEntryOffset+144,8)
		$Indx_File_Flags = _SwapEndian($Indx_File_Flags)
		$Indx_File_Flags = _File_Attributes("0x" & $Indx_File_Flags)
		$Indx_ReparseTag = StringMid($Entry,$NextEntryOffset+152,8)
		$Indx_ReparseTag = _SwapEndian($Indx_ReparseTag)
		$Indx_ReparseTag = _GetReparseType("0x"&$Indx_ReparseTag)
		$Indx_NameLength = StringMid($Entry,$NextEntryOffset+160,2)
		$Indx_NameLength = Dec($Indx_NameLength)
;		ConsoleWrite("$Indx_NameLength = " & $Indx_NameLength & @crlf)
		$Indx_NameSpace = StringMid($Entry,$NextEntryOffset+162,2)
;		ConsoleWrite("$Indx_NameSpace = " & $Indx_NameSpace & @crlf)
		Select
			Case $Indx_NameSpace = "00"	;POSIX
				$Indx_NameSpace = "POSIX"
			Case $Indx_NameSpace = "01"	;WIN32
				$Indx_NameSpace = "WIN32"
			Case $Indx_NameSpace = "02"	;DOS
				$Indx_NameSpace = "DOS"
			Case $Indx_NameSpace = "03"	;DOS+WIN32
				$Indx_NameSpace = "DOS+WIN32"
		EndSelect
		$Indx_FileName = StringMid($Entry,$NextEntryOffset+164,$Indx_NameLength*2*2)
;		ConsoleWrite("$Indx_FileName = " & $Indx_FileName & @crlf)
		$Indx_FileName = _UnicodeHexToStr($Indx_FileName)
;		ConsoleWrite("$Indx_FileName = " & $Indx_FileName & @crlf)
		$tmp0 = 0
		$tmp2 = 0
		$tmp3 = 0
		$tmp1 = 164+($Indx_NameLength*2*2)
		Do ; Calculate the length of the padding - 8 byte aligned
			$tmp2 = $tmp1/16
			If Not IsInt($tmp2) Then
				$tmp0 = 2
				$tmp1 += $tmp0
				$tmp3 += $tmp0
			EndIf
		Until IsInt($tmp2)
		$PaddingLength = $tmp3
;		ConsoleWrite("$PaddingLength = " & $PaddingLength & @crlf)
		$Padding = StringMid($Entry,$NextEntryOffset+164+($Indx_NameLength*2*2),$PaddingLength)
;		ConsoleWrite("$Padding = " & $Padding & @crlf)
		If $IndexFlags <> "0000" Then
			$SubNodeVCN = StringMid($Entry,$NextEntryOffset+164+($Indx_NameLength*2*2)+$PaddingLength,16)
			$SubNodeVCNLength = 16
		Else
			$SubNodeVCN = ""
			$SubNodeVCNLength = 0
		EndIf
;		ConsoleWrite("$SubNodeVCN = " & $SubNodeVCN & @crlf)
		$NextEntryOffset = $NextEntryOffset+164+($Indx_NameLength*2*2)+$PaddingLength+$SubNodeVCNLength
		ReDim $IndxEntryNumberArr[1+$EntryCounter]
		ReDim $IndxMFTReferenceArr[1+$EntryCounter]
		Redim $IndxMFTRefSeqNoArr[1+$EntryCounter]
		ReDim $IndxIndexFlagsArr[1+$EntryCounter]
		ReDim $IndxMFTReferenceOfParentArr[1+$EntryCounter]
		ReDim $IndxMFTParentRefSeqNoArr[1+$EntryCounter]
		ReDim $IndxCTimeArr[1+$EntryCounter]
		ReDim $IndxATimeArr[1+$EntryCounter]
		ReDim $IndxMTimeArr[1+$EntryCounter]
		ReDim $IndxRTimeArr[1+$EntryCounter]
		ReDim $IndxAllocSizeArr[1+$EntryCounter]
		ReDim $IndxRealSizeArr[1+$EntryCounter]
		ReDim $IndxFileFlagsArr[1+$EntryCounter]
		ReDim $IndxReparseTagArr[1+$EntryCounter]
		ReDim $IndxFileNameArr[1+$EntryCounter]
		ReDim $IndxNameSpaceArr[1+$EntryCounter]
		ReDim $IndxSubNodeVCNArr[1+$EntryCounter]
		$IndxEntryNumberArr[$EntryCounter] = $EntryCounter
		$IndxMFTReferenceArr[$EntryCounter] = $MFTReference
		$IndxMFTRefSeqNoArr[$EntryCounter] = $MFTReferenceSeqNo
		$IndxIndexFlagsArr[$EntryCounter] = $IndexFlags
		$IndxMFTReferenceOfParentArr[$EntryCounter] = $MFTReferenceOfParent
		$IndxMFTParentRefSeqNoArr[$EntryCounter] = $MFTReferenceOfParentSeqNo
		$IndxCTimeArr[$EntryCounter] = $Indx_CTime
		$IndxATimeArr[$EntryCounter] = $Indx_ATime
		$IndxMTimeArr[$EntryCounter] = $Indx_MTime
		$IndxRTimeArr[$EntryCounter] = $Indx_RTime
		$IndxAllocSizeArr[$EntryCounter] = $Indx_AllocSize
		$IndxRealSizeArr[$EntryCounter] = $Indx_RealSize
		$IndxFileFlagsArr[$EntryCounter] = $Indx_File_Flags
		$IndxReparseTagArr[$EntryCounter] = $Indx_ReparseTag
		$IndxFileNameArr[$EntryCounter] = $Indx_FileName
		$IndxNameSpaceArr[$EntryCounter] = $Indx_NameSpace
		$IndxSubNodeVCNArr[$EntryCounter] = $SubNodeVCN
;		_ArrayDisplay($IndxFileNameArr,"$IndxFileNameArr")
	Until $NextEntryOffset+32 >= StringLen($Entry)
EndFunc

Func _DumpFromOffset($DriveOffset)
	Local $ttBuffer,$nnBytes,$hhFile
	$ttBuffer = DllStructCreate("byte[" & $MFT_Record_Size & "]")
	$hhFile = _WinAPI_CreateFile("\\.\" & $TargetDrive, 2, 6, 6)
	If $hhFile = 0 Then
		ConsoleWrite("Error in function CreateFile when trying to access " & $TargetDrive & @CRLF)
		_WinAPI_CloseHandle($hhFile)
		Exit
	EndIf
	_WinAPI_SetFilePointerEx($hhFile, $DriveOffset, $FILE_BEGIN)
	_WinAPI_ReadFile($hhFile, DllStructGetPtr($ttBuffer), $MFT_Record_Size, $nnBytes)
	If $DoExtraction Then
		Local $hDump = _WinAPI_CreateFile("\\.\" & @ScriptDir & "\Record_" & StringLeft($TargetDrive,1) & "_0x" & Hex($DriveOffset) & ".bin", 1, 6, 6)
		_WinAPI_WriteFile($hDump, DllStructGetPtr($ttBuffer), $MFT_Record_Size, $nnBytes)
		_WinAPI_CloseHandle($hDump)
	EndIf
	$MFTRecord = DllStructGetData($ttBuffer, 1)
	_WinAPI_CloseHandle($hhFile)
	If $MFTRecord <> "" Then
		Return $MFTRecord
	Else
		Return SetError(1, 0, "")
	EndIf
EndFunc

Func _End($begin)
	Local $timerdiff = TimerDiff($begin)
	$timerdiff = Round(($timerdiff / 1000), 2)
	ConsoleWrite("Job took " & $timerdiff & " seconds" & @CRLF)
;	Exit
EndFunc

; start: by Ascend4nt -----------------------------
Func _WinTime_GetUTCToLocalFileTimeDelta()
	Local $iUTCFileTime=864000000000		; exactly 24 hours from the origin (although 12 hours would be more appropriate (max variance = 12))
	$iLocalFileTime=_WinTime_UTCFileTimeToLocalFileTime($iUTCFileTime)
	If @error Then Return SetError(@error,@extended,-1)
	Return $iLocalFileTime-$iUTCFileTime	; /36000000000 = # hours delta (effectively giving the offset in hours from UTC/GMT)
EndFunc

Func _WinTime_UTCFileTimeToLocalFileTime($iUTCFileTime)
	If $iUTCFileTime<0 Then Return SetError(1,0,-1)
	Local $aRet=DllCall($_COMMON_KERNEL32DLL,"bool","FileTimeToLocalFileTime","uint64*",$iUTCFileTime,"uint64*",0)
	If @error Then Return SetError(2,@error,-1)
	If Not $aRet[0] Then Return SetError(3,0,-1)
	Return $aRet[2]
EndFunc

Func _WinTime_UTCFileTimeFormat($iUTCFileTime,$iFormat=4,$iPrecision=0,$bAMPMConversion=False)
;~ 	If $iUTCFileTime<0 Then Return SetError(1,0,"")	; checked in below call

	; First convert file time (UTC-based file time) to 'local file time'
	Local $iLocalFileTime=_WinTime_UTCFileTimeToLocalFileTime($iUTCFileTime)
	If @error Then Return SetError(@error,@extended,"")
	; Rare occassion: a filetime near the origin (January 1, 1601!!) is used,
	;	causing a negative result (for some timezones). Return as invalid param.
	If $iLocalFileTime<0 Then Return SetError(1,0,"")

	; Then convert file time to a system time array & format & return it
	Local $vReturn=_WinTime_LocalFileTimeFormat($iLocalFileTime,$iFormat,$iPrecision,$bAMPMConversion)
	Return SetError(@error,@extended,$vReturn)
EndFunc

Func _WinTime_LocalFileTimeFormat($iLocalFileTime,$iFormat=4,$iPrecision=0,$bAMPMConversion=False)
;~ 	If $iLocalFileTime<0 Then Return SetError(1,0,"")	; checked in below call

	; Convert file time to a system time array & return result
	Local $aSysTime=_WinTime_LocalFileTimeToSystemTime($iLocalFileTime)
	If @error Then Return SetError(@error,@extended,"")

	; Return only the SystemTime array?
	If $iFormat=0 Then Return $aSysTime

	Local $vReturn=_WinTime_FormatTime($aSysTime[0],$aSysTime[1],$aSysTime[2],$aSysTime[3], _
		$aSysTime[4],$aSysTime[5],$aSysTime[6],$aSysTime[7],$iFormat,$iPrecision,$bAMPMConversion)
	Return SetError(@error,@extended,$vReturn)
EndFunc

Func _WinTime_LocalFileTimeToSystemTime($iLocalFileTime)
	Local $aRet,$stSysTime,$aSysTime[8]=[-1,-1,-1,-1,-1,-1,-1,-1]

	; Negative values unacceptable
	If $iLocalFileTime<0 Then Return SetError(1,0,$aSysTime)

	; SYSTEMTIME structure [Year,Month,DayOfWeek,Day,Hour,Min,Sec,Milliseconds]
	$stSysTime=DllStructCreate("ushort[8]")

	$aRet=DllCall($_COMMON_KERNEL32DLL,"bool","FileTimeToSystemTime","uint64*",$iLocalFileTime,"ptr",DllStructGetPtr($stSysTime))
	If @error Then Return SetError(2,@error,$aSysTime)
	If Not $aRet[0] Then Return SetError(3,0,$aSysTime)
	Dim $aSysTime[8]=[DllStructGetData($stSysTime,1,1),DllStructGetData($stSysTime,1,2),DllStructGetData($stSysTime,1,4),DllStructGetData($stSysTime,1,5), _
		DllStructGetData($stSysTime,1,6),DllStructGetData($stSysTime,1,7),DllStructGetData($stSysTime,1,8),DllStructGetData($stSysTime,1,3)]
	Return $aSysTime
EndFunc

Func _WinTime_FormatTime($iYear,$iMonth,$iDay,$iHour,$iMin,$iSec,$iMilSec,$iDayOfWeek,$iFormat=4,$iPrecision=0,$bAMPMConversion=False)
	Local Static $_WT_aMonths[12]=["January","February","March","April","May","June","July","August","September","October","November","December"]
	Local Static $_WT_aDays[7]=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

	If Not $iFormat Or $iMonth<1 Or $iMonth>12 Or $iDayOfWeek>6 Then Return SetError(1,0,"")

	; Pad MM,DD,HH,MM,SS,MSMSMSMS as necessary
	Local $sMM=StringRight(0&$iMonth,2),$sDD=StringRight(0&$iDay,2),$sMin=StringRight(0&$iMin,2)
	; $sYY = $iYear	; (no padding)
	;	[technically Year can be 1-x chars - but this is generally used for 4-digit years. And SystemTime only goes up to 30827/30828]
	Local $sHH,$sSS,$sMS,$sAMPM

	; 'Extra precision 1': +SS (Seconds)
	If $iPrecision Then
		$sSS=StringRight(0&$iSec,2)
		; 'Extra precision 2': +MSMSMSMS (Milliseconds)
		If $iPrecision>1 Then
;			$sMS=StringRight('000'&$iMilSec,4)
			$sMS=StringRight('000'&$iMilSec,3);Fixed an erronous 0 in front of the milliseconds
		Else
			$sMS=""
		EndIf
	Else
		$sSS=""
		$sMS=""
	EndIf
	If $bAMPMConversion Then
		If $iHour>11 Then
			$sAMPM=" PM"
			; 12 PM will cause 12-12 to equal 0, so avoid the calculation:
			If $iHour=12 Then
				$sHH="12"
			Else
				$sHH=StringRight(0&($iHour-12),2)
			EndIf
		Else
			$sAMPM=" AM"
			If $iHour Then
				$sHH=StringRight(0&$iHour,2)
			Else
			; 00 military = 12 AM
				$sHH="12"
			EndIf
		EndIf
	Else
		$sAMPM=""
		$sHH=StringRight(0 & $iHour,2)
	EndIf

	Local $sDateTimeStr,$aReturnArray[3]

	; Return an array? [formatted string + "Month" + "DayOfWeek"]
	If BitAND($iFormat,0x10) Then
		$aReturnArray[1]=$_WT_aMonths[$iMonth-1]
		If $iDayOfWeek>=0 Then
			$aReturnArray[2]=$_WT_aDays[$iDayOfWeek]
		Else
			$aReturnArray[2]=""
		EndIf
		; Strip the 'array' bit off (array[1] will now indicate if an array is to be returned)
		$iFormat=BitAND($iFormat,0xF)
	Else
		; Signal to below that the array isn't to be returned
		$aReturnArray[1]=""
	EndIf

	; Prefix with "DayOfWeek "?
	If BitAND($iFormat,8) Then
		If $iDayOfWeek<0 Then Return SetError(1,0,"")	; invalid
		$sDateTimeStr=$_WT_aDays[$iDayOfWeek]&', '
		; Strip the 'DayOfWeek' bit off
		$iFormat=BitAND($iFormat,0x7)
	Else
		$sDateTimeStr=""
	EndIf

	If $iFormat<2 Then
		; Basic String format: YYYYMMDDHHMM[SS[MSMSMSMS[ AM/PM]]]
		$sDateTimeStr&=$iYear&$sMM&$sDD&$sHH&$sMin&$sSS&$sMS&$sAMPM
	Else
		; one of 4 formats which ends with " HH:MM[:SS[:MSMSMSMS[ AM/PM]]]"
		Switch $iFormat
			; /, : Format - MM/DD/YYYY
			Case 2
				$sDateTimeStr&=$sMM&'/'&$sDD&'/'
			; /, : alt. Format - DD/MM/YYYY
			Case 3
				$sDateTimeStr&=$sDD&'/'&$sMM&'/'
			; "Month DD, YYYY" format
			Case 4
				$sDateTimeStr&=$_WT_aMonths[$iMonth-1]&' '&$sDD&', '
			; "DD Month YYYY" format
			Case 5
				$sDateTimeStr&=$sDD&' '&$_WT_aMonths[$iMonth-1]&' '
			Case 6
				$sDateTimeStr&=$iYear&'-'&$sMM&'-'&$sDD
				$iYear=''
			Case Else
				Return SetError(1,0,"")
		EndSwitch
		$sDateTimeStr&=$iYear&' '&$sHH&':'&$sMin
		If $iPrecision Then
			$sDateTimeStr&=':'&$sSS
			If $iPrecision>1 Then $sDateTimeStr&=':'&$sMS
		EndIf
		$sDateTimeStr&=$sAMPM
	EndIf
	If $aReturnArray[1]<>"" Then
		$aReturnArray[0]=$sDateTimeStr
		Return $aReturnArray
	EndIf
	Return $sDateTimeStr
EndFunc
; end: by Ascend4nt ----------------------------

Func _Get_LoggedUtilityStream($Entry,$Current_Attrib_Number,$CurrentAttributeName)
	Local $LocalAttributeOffset = 1
	$TheLoggedUtilityStream = StringMid($Entry,$LocalAttributeOffset)
;	ConsoleWrite("$TheLoggedUtilityStream = " & $TheLoggedUtilityStream & @crlf)
	$LUSArr[0][$Current_Attrib_Number] = "LoggedUtilityStream Number " & $Current_Attrib_Number
	$LUSArr[1][$Current_Attrib_Number] = $CurrentAttributeName
	$LUSArr[2][$Current_Attrib_Number] = $TheLoggedUtilityStream
	If $CurrentAttributeName = "$TXF_DATA" Then
		_Decode_TXF_DATA($TheLoggedUtilityStream)
	EndIf
EndFunc

Func _Decode_TXF_DATA($InputData)
	Local $StartOffset=1
	Global $TxfDataArr[8][2]
	$InputDataSize = StringLen($InputData)

	If $InputDataSize < 113 And $InputDataSize > 96 Then

		$MftRef_RM_Root = StringMid($InputData, $StartOffset, 12)
		$MftRef_RM_Root = Dec(_SwapEndian($MftRef_RM_Root),2)
		$MftRefSeqNo_RM_Root = StringMid($InputData, $StartOffset + 12, 4)
		$MftRefSeqNo_RM_Root = Dec(_SwapEndian($MftRefSeqNo_RM_Root),2)

		$UsnIndex = StringMid($InputData, $StartOffset + 16, 16)
		$UsnIndex = "0x"&_SwapEndian($UsnIndex)

		;Increments with 1. The last TxfFileId is referenced in $Tops standard $DATA stream at offset 0x28
		$TxfFileId = StringMid($InputData, $StartOffset + 32, 16)
		$TxfFileId = "0x"&_SwapEndian($TxfFileId)

		;Offset into $TxfLogContainer00000000000000000001
		$LsnUserData = StringMid($InputData, $StartOffset + 48, 16)
		$LsnUserData = "0x"&_SwapEndian($LsnUserData)

		;Offset into $TxfLogContainer00000000000000000001
		$LsnNtfsMetadata = StringMid($InputData, $StartOffset + 64, 16)
		$LsnNtfsMetadata = "0x"&_SwapEndian($LsnNtfsMetadata)

		$LsnDirectoryIndex = StringMid($InputData, $StartOffset + 80, 16)
		$LsnDirectoryIndex = "0x"&_SwapEndian($LsnDirectoryIndex)

		$UnknownFlag = StringMid($InputData, $StartOffset + 96, 16)
		$UnknownFlag = "0x"&_SwapEndian($UnknownFlag)


		$TxfDataArr[0][0] = "MftRef_RM_Root"
		$TxfDataArr[1][0] = "MftRefSeqNo_RM_Root"
		$TxfDataArr[2][0] = "UsnIndex"
		$TxfDataArr[3][0] = "TxfFileId"
		$TxfDataArr[4][0] = "LsnUserData"
		$TxfDataArr[5][0] = "LsnNtfsMetadata"
		$TxfDataArr[6][0] = "LsnDirectoryIndex"
		$TxfDataArr[7][0] = "UnknownFlag"
		$TxfDataArr[0][1] = $MftRef_RM_Root
		$TxfDataArr[1][1] = $MftRefSeqNo_RM_Root
		$TxfDataArr[2][1] = $UsnIndex
		$TxfDataArr[3][1] = $TxfFileId
		$TxfDataArr[4][1] = $LsnUserData
		$TxfDataArr[5][1] = $LsnNtfsMetadata
		$TxfDataArr[6][1] = $LsnDirectoryIndex
		$TxfDataArr[7][1] = $UnknownFlag
	EndIf

EndFunc

Func _Decode_AttrDef($InputData)
	Local $AttrCounter=0, $StartOffset=1,$InputDataSize = StringLen($InputData)
;	Local

	$AttrDefArray[0][0] = "Attribute Name"
	$AttrDefArray[1][0] = "Display Rule"
	$AttrDefArray[2][0] = "Collation Rule"
	$AttrDefArray[3][0] = "Attribute Flags"
	$AttrDefArray[4][0] = "Minimum Length"
	$AttrDefArray[5][0] = "Maximum Length"
;	ConsoleWrite("_Decode_AttrDef():" & @crlf)
;	ConsoleWrite(_HexEncode("0x"& StringMid($InputData,1)) & @crlf)

	Do
		$AttrCounter += 1
		$AttrName = StringMid($InputData, $StartOffset, 256)
		$AttrNameResolved = ""
		For $i = 1 To 256 Step 4
			$Char = StringMid($AttrName,$i,4)
			If $Char = '0000' Then ExitLoop
;			$AttrNameResolved &= $Char
			$AttrNameResolved &= StringMid($Char,1,2)
;			ConsoleWrite("$AttrNameResolved: " & $AttrNameResolved & @crlf)
		Next
		$AttrNameResolved = _HexToString($AttrNameResolved)
;		ConsoleWrite("$AttrNameResolved: " & $AttrNameResolved & @crlf)

		$AttrCode = StringMid($InputData, $StartOffset + 256, 8)
		$AttrCodeResolved = _ResolveAttributeType(StringMid($AttrCode,1,4))
;		If $AttrNameResolved <> $AttrCodeResolved Then
;			ConsoleWrite("Error: Something wrong in $AttrDef" & @crlf)
;			ExitLoop
;		EndIf

		$AttrDisplayRule = StringMid($InputData, $StartOffset + 264, 8)
		$AttrDisplayRule = _SwapEndian($AttrDisplayRule)

		$AttrCollationRule = StringMid($InputData, $StartOffset + 272, 8)
		$AttrCollationRule = _SwapEndian($AttrCollationRule)

		$AttrFlags = StringMid($InputData, $StartOffset + 280, 8)
		$AttrFlags = _SwapEndian($AttrFlags)
		$AttrFlagsResolved = _DecodeAttributeFlags("0x"&$AttrFlags)

		$AttrMinLength = StringMid($InputData, $StartOffset + 288, 16)
;		$AttrMinLength = Dec(_SwapEndian($AttrMinLength),2)
		$AttrMinLength = "0x"&_SwapEndian($AttrMinLength)

		$AttrMaxLength = StringMid($InputData, $StartOffset + 304, 16)
;		$AttrMaxLength = Dec(_SwapEndian($AttrMaxLength),2)
		$AttrMaxLength = "0x"&_SwapEndian($AttrMaxLength)

		ReDim $AttrDefArray[6][$AttrCounter+1]
		$AttrDefArray[0][$AttrCounter] = $AttrNameResolved
		$AttrDefArray[1][$AttrCounter] = "0x"&$AttrDisplayRule
		$AttrDefArray[2][$AttrCounter] = "0x"&$AttrCollationRule
		$AttrDefArray[3][$AttrCounter] = $AttrFlagsResolved
;		$AttrDefArray[3][$AttrCounter] = "0x"&$AttrFlags
		$AttrDefArray[4][$AttrCounter] = $AttrMinLength
		$AttrDefArray[5][$AttrCounter] = $AttrMaxLength
		$StartOffset += 160*2
	Until $StartOffset > $InputDataSize

;	_ArrayDisplay($AttrDefArray,"$AttrDefArray")
EndFunc

Func _DecodeAttributeFlags($AFinput)
	Local $AFoutput = ""
	If $AFinput = 0x0000 Then Return 'ZERO'
	;This flag is set if the attribute may be indexed:
	If BitAND($AFinput, 0x0002) Then $AFoutput &= 'INDEXABLE+'
	;This flag is set if the attribute may occur more than once, such as is allowed for the File Name attribute:
	If BitAND($AFinput, 0x0004) Then $AFoutput &= 'DUPLICATES_ALLOWED+'
	;This flag is set if the value of the attribute may not be entirely null, i.e., all binary 0's:
	If BitAND($AFinput, 0x0008) Then $AFoutput &= 'MAY_NOT_BE_NULL+'
	;This attribute must be indexed, and no two attributes may exist with the same value in the same file record segment:
	If BitAND($AFinput, 0x0010) Then $AFoutput &= 'MUST_BE_INDEXED+'
	;This attribute must be named, and no two attributes may exist with the same name in the same file record segment:
	If BitAND($AFinput, 0x0020) Then $AFoutput &= 'MUST_BE_NAMED+'
	;This attribute must be in the Resident Form
	If BitAND($AFinput, 0x0040) Then $AFoutput &= 'MUST_BE_RESIDENT+'
	;Modifications to this attribute should be logged even if the attribute is nonresident:
	If BitAND($AFinput, 0x0080) Then $AFoutput &= 'LOG_NONRESIDENT+'
	$AFoutput = StringTrimRight($AFoutput, 1)
	Return $AFoutput
EndFunc

Func _ResolveAttributeType($input)
	Select
		Case $input = "1000"
			Return "$STANDARD_INFORMATION"
		Case $input = "2000"
			Return "$ATTRIBUTE_LIST"
		Case $input = "3000"
			Return "$FILE_NAME"
		Case $input = "4000"
			Return "$OBJECT_ID"
		Case $input = "5000"
			Return "$SECURITY_DESCRIPTOR"
		Case $input = "6000"
			Return "$VOLUME_NAME"
		Case $input = "7000"
			Return "$VOLUME_INFORMATION"
		Case $input = "8000"
			Return "$DATA"
		Case $input = "9000"
			Return "$INDEX_ROOT"
		Case $input = "a000"
			Return "$INDEX_ALLOCATION"
		Case $input = "b000"
			Return "$BITMAP"
		Case $input = "c000"
			Return "$REPARSE_POINT"
		Case $input = "d000"
			Return "$EA_INFORMATION"
		Case $input = "e000"
			Return "$EA"
		Case $input = "0001"
			Return "$LOGGED_UTILITY_STREAM"
		Case Else
			Return "UNKNOWN"
	EndSelect
EndFunc
