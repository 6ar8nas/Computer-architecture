; ------------------------------------------------
; Programos autorius - Sarunas Griskus.  
; Programa yra atlikta ivykdant 3 uzduoties 13 varianto reikalavimus. 
; Programa - tai zingsninio rezimo pertraukimo (int 1) apdorojimo procedura, atpazistanti komanda INC r/m ir DEC r/m.
;-------------------------------------------------

.model small
.stack 100h
.data
    authorMessage DB 'Programos autorius: Sarunas. Griskus', 10, 13, 'Programa yra atlikta ivykdant 3 uzduoties 13 varianto reikalavimus.', 10, 13, 'Programa - tai zingsninio rezimo pertraukimo (int 1) apdorojimo procedura, atpazistanti komanda INC/DEC r/m.', 10, 13, 10, 13, '$'             
	commandFound DB 'Zingsninis pertraukimas!', 10, 13, '$'
	colon DB ':$'
	space DB ' $'
	comma DB ', $'
	incText DB ' INC $'
	decText DB ' DEC $'
	semicolon DB '; $'
	equalsSign db ' = $'
	newLine DB 10, 13, '$'
	bytePtrMsg DB 'byte ptr DS:$'
	wordPtrMsg DB 'word ptr DS:$'

	primaryCS dw ?
	primaryIP dw ?
	
	backupAX dw ?
	backupBX dw ?
	backupCX dw ?
	backupDX dw ?
	backupSP dw ?
	backupBP dw ?
	backupSI dw ?
	backupDI dw ?
	
	opCode db ?
	addrByte db ?
	offset1 db ?
	offset2 db ?
	
	widthByte db ?
	modValue db ?
	rmValue db ?
	
	ALname db ' AL$'
	CLname db ' CL$'
	DLname db ' DL$'
	BLname db ' BL$'
	AHname db ' AH$'
	CHname db ' CH$'
	DHname db ' DH$'
	BHname db ' BH$'
	
	AXname db ' AX$'
	CXname db ' CX$'
	DXname db ' DX$'
	BXname db ' BX$'
	SPname db ' SP$'
	BPname db ' BP$'
	SIname db ' SI$'
	DIname db ' DI$'
	
	AXBraceName db ' [AX] = $'
	CXBraceName db ' [CX] = $'
	DXBraceName db ' [DX] = $'
	BXBraceName db ' [BX] = $'
	SPBraceName db ' [SP] = $'
	BPBraceName db ' [BP] = $'
	SIBraceName db ' [SI] = $'
	DIBraceName db ' [DI] = $'
	
	BXSIOffsetname db 'BX+SI$'
	BXDIOffsetname db 'BX+DI$'
	BPSIOffsetname db 'BP+SI$'
	BPDIOffsetname db 'BP+DI$'
	SIOffsetname db 'SI$'
	DIOffsetname db 'DI$'
	BPOffsetname db 'BP$'
	BXOffsetname db 'BX$'	
	
	INCorDEC db ? ; 0 - inc, 1 - dec
	
.code

main:                  
    MOV AX, @data
    MOV DS, AX  
    
    MOV AH, 09h  
    LEA DX, authorMessage
    INT 21h
    	     
    MOV AX, 0		
    MOV ES, AX

	MOV AX, ES:[4]	
	MOV BX, ES:[6]		
	
	MOV primaryCS, BX
	MOV primaryIP, AX  
	
	MOV BX, offset interrupt
	MOV AX, CS		
	
	MOV ES:[4], BX			
	MOV ES:[6], AX				
	
	
	activatingStepMode:
		PUSHF
		POP AX
		OR AX, 0100h
		PUSH AX
		POPF
		NOP
	
	
	INC byte ptr DS:[4352h]
	INC byte ptr  [BP + 42h]
	DEC word ptr [BP + DI + 567h]
	INC word ptr [SI]
	DEC byte ptr [BP + DI]
	INC word ptr [BP]
	INC AH
	INC CL
	
	DEC BL  	

	MOV BX, AX
	ADD AH, AL
	
	
	deactivatingStepMode:
		PUSHF
		POP AX
		AND AX, 0FEFFh 			
		PUSH AX
		POPF						
	
	MOV AX, primaryIP
	MOV BX, primaryCS
	MOV ES:[4], AX				
	MOV ES:[6], BX
	
	null:    
		MOV AX, 4C00h
		INT 21h
			  
interrupt:

	backupReg:
		MOV backupAX, AX
		MOV backupBX, BX
		MOV backupCX, CX
		MOV backupDX, DX	
		MOV backupSP, SP
		MOV backupBP, BP
		MOV backupSI, SI
		MOV backupDI, DI
	
	POP SI 				
	POP DI 					
	PUSH DI 		
	PUSH SI			
	
	

	
	MOV AX, CS:[SI]
	MOV BX, CS:[SI+2]
	
	getMachineCode:
		MOV opCode, AL
		MOV addrByte, AH
		MOV offset1, BL
		MOV offset2, BH
	                           
	checkOPCode:
		PUSH AX
		AND AL, 0FEh 
		CMP AL, 0FEh	
		POP AX 
		JE checkaddrByte     
		JMP return
		
	checkaddrByte:
		PUSH AX
		AND AH, 38h          
		CMP AH, 0h			
		POP AX
		JE setINCVal		
		PUSH AX            
		AND AH, 38h          
		CMP AH, 8h
		POP AX
		JE setDECVal
		JMP return
		
	setINCVal:
		PUSH AX
		MOV AL, 0h
		MOV INCorDEC, AL
		POP AX
		JMP findValues
	
	setDecVal:
		PUSH AX
		MOV AL, 1h
		MOV INCorDEC, AL
		POP AX
		JMP findValues
		
	findValues:

		findRM:           
			PUSH AX
			AND AH, 7h     
			MOV rmValue, AH 
			POP AX

		findMOD:
			PUSH AX
			PUSH CX
			AND AH, 0C0h
			MOV CL, 6
			SHR AH, CL
			MOV modValue, AH
			POP CX
			POP AX
			
		findW:
			PUSH AX
			AND AL, 1h
			MOV widthByte, AL
			POP AX
		
					
		MOV AH, 09h
		LEA DX, commandFound
		INT 21h
		
		JMP printInfo
			
	printInfo: 
		
		MOV AX, DI
		CALL printAX
		
		MOV AH, 09h
		LEA DX, colon
		INT 21h
		
		MOV AX, SI
		CALL printAX
		
		MOV AH, 09h
		LEA DX, space
		INT 21h
		
		MOV AL, opCode
		CALL printAL
		
		MOV AL, addrByte
		CALL printAL
		
		MOV AH, 02h
		MOV DL, ' '
		INT 21h
		
		
		MOV AH, modValue
		CMP AH, 3h
		JE continueAfterOffsetPrint
		CMP AH, 01h
		JB continueAfterOffsetPrint
		MOV AL, offset1
		CALL printAL
		
		CMP AH, 02h
		JB continueAfterOffsetPrint
		MOV AL, offset2
		CALL printAL
		
		continueAfterOffsetPrint:
		CMP AH, 00h
		JNE continueAfterDirectAdressCheck
		MOV AH, rmValue
		CMP AH, 06h
		JNE continueAfterDirectAdressCheck
		MOV AH, offset1
		MOV AL, offset2
		CALL printAX
		
		continueAfterDirectAdressCheck:
		MOV AL, INCorDEC
		CMP AL, 0h
		JNE printDec
	printINC:
		MOV AH, 09h
		LEA DX, incText
		INT 21h
		JMP compareMod
	printDec:
		MOV AH, 09h
		LEA DX, decText
		INT 21h
		
		
	compareMod:
		MOV CL, modValue
		CMP CL, 3h
		
		JE continueAfterPtrPrint
		
		MOV BL, widthByte
		CMP BL, 0
		JE bytePtrPrint
		MOV AH, 09h
		LEA DX, wordPtrMsg
		INT 21h
		JMP continueAfterPtrPrint
		
		bytePtrPrint:
		MOV AH, 09h
		LEA DX, bytePtrMsg
		INT 21h
		continueAfterPtrPrint:
		CALL printRegName
		
		MOV AH, 09h
		LEA DX, semicolon
		INT 21h
		
		CALL printRegValue
		
		MOV AH, 09h
		LEA DX, newLine
		INT 21h
		
		JMP return
		
	return:
		MOV AX, backupAX 
		MOV BX, backupBX
		MOV CX, backupCX
		MOV DX, backupDX	
		MOV SP, backupSP
		MOV BP, backupBP
		MOV SI, backupSI
		MOV DI, backupDI
IRET	

printAX:
	PUSH AX
	PUSH CX
	PUSH AX
	
	printHighByte:
		MOV AL, AH
		CALL printAL
	printLowByte:
		POP AX
		CALL printAL
	
	POP CX
	POP AX
RET


printAL:
	PUSH AX
	PUSH CX
	PUSH AX
	
	printHighNumber:
		MOV CL, 4
		SHR AL, CL
		CALL printHex
	printLowNumber:
		POP AX
		CALL printHex
		
	POP CX
	POP AX
RET

printHex:
	PUSH AX
	PUSH DX
	
	AND AL, 0Fh		
	CMP AL, 9
	JA printHexAF
	JMP printHex09
	
	printHexAF:
		ADD AL, 37h
		MOV DL, AL
		MOV AH, 02h
		INT 21h
		JMP funcEnd
		
	printHex09:
		MOV DL, AL
		ADD DL, 30h
		MOV AH, 02h
		INT 21h
		jmp funcEnd
	
	funcEnd:
		POP DX
		POP AX
		
RET


printRegName PROC
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	MOV AL, rmValue
	MOV BL, widthByte
	MOV CL, modValue
	
	CMP CL, 0h
	JE mod00
	CMP CL, 3h
	JE mod11
	CMP CL, 1h
	JE mod1001
	
	mod00:
		CMP AL, 6h
		JE directAdress
		JMP mod1001
		
		directAdress:
			MOV AH, 02h
			MOV DL, '['
			INT 21h
			
			PUSH CX
			MOV CL, 2h
			CALL printOffset
			POP CX
			
			MOV AH, 02h
			MOV DL, ']'
			INT 21h
			JMP printEnd
			
	mod1001:
		CALL mod1001Reg
		JMP printEnd
		

	mod11:
		CALL mod11Reg
		JMP printEnd
			
	printEnd:
		POP DX
		POP CX
		POP BX
		POP AX
	RET
printRegName ENDP

mod11Reg PROC
	PUSH AX
	PUSH DX
	MOV BL, widthByte
	MOV AL, rmValue
	CMP BL, 0
	JE width1
	JMP width2
		width1:
			CMP AL, 0h
			JE ALprint
			CMP AL, 1h
			JE CLprint
			CMP AL, 2h
			JE DLprint
			CMP AL, 3h
			JE BLprint
			CMP AL, 4h
			JE AHprint
			CMP AL, 5h
			JE CHprint
			CMP AL, 6h
			JE DHprint
			CMP AL, 7h
			JE BHprint
			
		width2:
			CMP AL, 0h
			JE AXprint
			CMP AL, 1h
			JE CXprint
			CMP AL, 2h
			JE DXprint
			CMP AL, 3h
			JE BXprint
			CMP AL, 4h
			JE SPprint
			CMP AL, 5h
			JE BPprint
			CMP AL, 6h
			JE SIprint
			CMP AL, 7h
			JE DIprint
			
			ALprint:
				LEA DX, ALname
				JMP print
			CLprint:
				LEA DX, CLname
				JMP print
			DLprint:
				LEA DX, DLname
				JMP print
			BLprint:
				LEA DX, BLname
				JMP print
			AHprint:
				LEA DX, AHname
				JMP print
			CHprint:
				LEA DX, CHname
				JMP print
			DHprint:
				LEA DX, DHname
				JMP print
			BHprint:
				LEA DX, BHname
				JMP print
			
			AXprint:
				LEA DX, AXname
				JMP print
			CXprint:
				LEA DX, CXname
				JMP print
			DXprint:
				LEA DX, DXname
				JMP print
			BXprint:
				LEA DX, BXname
				JMP print
			SPprint:
				LEA DX, SPname
				JMP print
			BPprint:
				LEA DX, BPname
				JMP print
			SIprint:
				LEA DX, SIname
				JMP print
			DIprint:
				LEA DX, DIname
				JMP print

		print:
			MOV AH, 09h
			INT 21h
		POP DX
		POP AX
	RET

mod11Reg ENDP

mod1001Reg PROC
	PUSH AX
	PUSH DX
	PUSH AX
		
	MOV AH, 02h
	MOV DL, '['
	INT 21h
	
	POP AX
	analyzeRM:
		CMP AL, 0h
		JE JMPBXSIOffsetname
		CMP AL, 1h
		JE JMPBXDIOffsetname
		CMP AL, 2h
		JE JMPBPSIOffsetname
		CMP AL, 3h
		JE JMPBPDIOffsetname
		CMP AL, 4h
		JE JMPSIOffsetname
		CMP AL, 5h
		JE JMPDIOffsetname
		CMP AL, 6h
		JE JMPBPOffsetname
		CMP AL, 7h
		JE JMPBXOffsetname
		
		JMPBXSIOffsetname:
			LEA DX, BXSIOffsetname
			MOV AX, backupBX
			MOV AX, backupSI
			JMP printMod1001
		JMPBXDIOffsetname:
			LEA DX, BXDIOffsetname
			MOV AX, backupBX
			MOV AX, backupDI
			JMP printMod1001
		JMPBPSIOffsetname:
			LEA DX, BPSIOffsetname
			MOV AX, backupBP
			MOV AX, backupSI
			JMP printMod1001
		JMPBPDIOffsetname:
			LEA DX, BPDIOffsetname
			MOV AX, backupBP
			MOV AX, backupDI
			JMP printMod1001
		JMPSIOffsetname:
			LEA DX, SIOffsetname
			MOV AX, backupSI
			JMP printMod1001
		JMPDIOffsetname:
			LEA DX, DIOffsetname
			MOV AX, backupDI
			JMP printMod1001
		JMPBPOffsetname:
			LEA DX, BPOffsetname
			MOV AX, backupBP
			JMP printMod1001
		JMPBXOffsetname:
			LEA DX, BXOffsetname
			MOV AX, backupBX
			JMP printMod1001
	
	printMod1001:
	MOV AH, 09h
	INT 21h

	CMP CL, 0h
	JE endPrint
	MOV AH, 02h
	MOV DL, '+'
	INT 21h
	
	CALL printOffset
	
	endPrint:
		MOV AH, 02h
		MOV DL, ']'
		INT 21h
	
	POP DX
	POP AX
	

RET
mod1001Reg ENDP

printOffset PROC
	PUSH AX
	CMP CL, 0h
	JE endOffsetPrint
	
	CMP CL, 1h
	JE print1Byte
	MOV AL, offset2
	CALL printAL
	print1Byte:		
		MOV AL, offset1
		CALL printAL
		
	MOV AH, 02h
	MOV DL, 'h'
	INT 21h
	endOffsetPrint:
		POP AX
		RET
printOffset ENDP

printRegValue PROC
	
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	MOV AL, rmValue
	MOV BL, widthByte
	MOV CL, modValue
	CMP CL, 3h
	JE regPrint
	JMP reg0
	
	regPrint:
		CMP AL, 0h
		JNE contNotReg0
		JMP mod11reg0
		contNotReg0:
		CMP AL, 1h
		JNE contNotReg1
		JMP mod11reg1
		contNotReg1:
		CMP AL, 2h
		JNE contNotReg2
		JMP mod11reg2
		contNotReg2:
		CMP AL, 3h
		JNE contNotReg3
		JMP mod11reg3
		contNotReg3:
		CMP AL, 4h
		JNE contNotReg4
		JMP mod11reg4
		contNotReg4:
		CMP AL, 5h
		JNE contNotReg5
		JMP mod11reg5
		contNotReg5:
		CMP AL, 6h
		JNE contNotReg6
		JMP mod11reg6
		contNotReg6:
		JMP mod11reg7
		
		mod11reg0:
			CMP BL, 0h
			JE ALValPrint
			LEA DX, AXname
			MOV AH, 09h
			INT 21h
			LEA DX, equalsSign
			MOV AH, 09h
			INT 21h
			MOV AX, backupAX
			CALL printAX
			JMP jumpToFinish
			ALValPrint:
				LEA DX, ALname
				MOV AH, 09h
				INT 21h
				LEA DX, equalsSign
				MOV AH, 09h
				INT 21h
				MOV AX, backupAX
				CALL printAL
				JMP jumpToFinish
		mod11reg1:
			CMP BL, 0h
			JE CLValPrint
			LEA DX, CXname
			MOV AH, 09h
			INT 21h
			LEA DX, equalsSign
			MOV AH, 09h
			INT 21h
			MOV AX, backupCX
			CALL printAX
			JMP jumpToFinish
			CLValPrint:
				LEA DX, CLname
				MOV AH, 09h
				INT 21h
				LEA DX, equalsSign
				MOV AH, 09h
				INT 21h
				MOV AX, backupCX
				CALL printAL
				JMP jumpToFinish
		mod11reg2:
			CMP BL, 0h
			JE DLValPrint
			LEA DX, DXname
			MOV AH, 09h
			INT 21h
			LEA DX, equalsSign
			MOV AH, 09h
			INT 21h
			MOV AX, backupDX
			CALL printAX
			JMP jumpToFinish
			DLValPrint:
				LEA DX, DLname
				MOV AH, 09h
				INT 21h
				LEA DX, equalsSign
				MOV AH, 09h
				INT 21h
				MOV AX, backupDX
				CALL printAL
				JMP jumpToFinish
		mod11reg3:
			CMP BL, 0h
			JE BLValPrint
			LEA DX, BXname
			MOV AH, 09h
			INT 21h
			LEA DX, equalsSign
			MOV AH, 09h
			INT 21h
			MOV AX, backupBX
			CALL printAX
			JMP jumpToFinish
			BLValPrint:
				LEA DX, BLname
				MOV AH, 09h
				INT 21h
				LEA DX, equalsSign
				MOV AH, 09h
				INT 21h
				MOV AX, backupBX
				CALL printAL
				JMP jumpToFinish
		mod11reg4:
			CMP BL, 0h
			JE AHValPrint
			LEA DX, SPname
			MOV AH, 09h
			INT 21h
			LEA DX, equalsSign
			MOV AH, 09h
			INT 21h
			MOV AX, backupSP
			CALL printAX
			JMP jumpToFinish
			AHValPrint:
				LEA DX, AHname
				MOV AH, 09h
				INT 21h
				LEA DX, equalsSign
				MOV AH, 09h
				INT 21h
				MOV AX, backupAX
				MOV AL, AH
				CALL printAL
				JMP jumpToFinish
		mod11reg5:
			CMP BL, 0h
			JE CHValPrint
			LEA DX, BPname
			MOV AH, 09h
			INT 21h
			LEA DX, equalsSign
			MOV AH, 09h
			INT 21h
			MOV AX, backupBP
			CALL printAX
			JMP jumpToFinish
			CHValPrint:
				LEA DX, CHname
				MOV AH, 09h
				INT 21h
				LEA DX, equalsSign
				MOV AH, 09h
				INT 21h
				MOV AX, backupCX
				MOV AL, AH
				CALL printAL
				JMP jumpToFinish
		mod11reg6:
			CMP BL, 0h
			JE DHValPrint
			LEA DX, SIname
			MOV AH, 09h
			INT 21h
			LEA DX, equalsSign
			MOV AH, 09h
			INT 21h
			MOV AX, backupSI
			CALL printAX
			JMP jumpToFinish
			DHValPrint:
				LEA DX, DHname
				MOV AH, 09h
				INT 21h
				LEA DX, equalsSign
				MOV AH, 09h
				INT 21h
				MOV AX, backupDX
				MOV AL, AH
				CALL printAL
				JMP jumpToFinish
		mod11reg7:
			CMP BL, 0h
			JE BHValPrint
			LEA DX, DIname
			MOV AH, 09h
			INT 21h
			LEA DX, equalsSign
			MOV AH, 09h
			INT 21h
			MOV AX, backupDI
			CALL printAX
			JMP jumpToFinish
			BHValPrint:
				LEA DX, BHname
				MOV AH, 09h
				INT 21h
				LEA DX, equalsSign
				MOV AH, 09h
				INT 21h
				MOV AX, backupBX
				MOV AL, AH
				CALL printAL
				JMP jumpToFinish
	
	reg0:
		CMP AL, 0h
		JNE reg1	
		LEA DX, BXname
		MOV AH, 09h
		INT 21h
		LEA DX, equalsSign
		MOV AH, 09h
		INT 21h
		MOV AX, backupBX
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h

		LEA DX, BXBraceName
		MOV AH, 09h
		INT 21h
		MOV BX, backupBX
		MOV AX, [BX]
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, SIname
		MOV AH, 09h
		INT 21h
		LEA DX, equalsSign
		MOV AH, 09h
		INT 21h
		MOV AX, backupSI
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, SIBraceName
		MOV AH, 09h
		INT 21h
		MOV BX, backupSI
		MOV AX, [BX]
		CALL printAX
		
	JMP finish
	reg1:
		CMP AL, 1h
		JNE reg2
		LEA DX, BXname
		MOV AH, 09h
		INT 21h
		LEA DX, equalsSign
		MOV AH, 09h
		INT 21h
		MOV AX, backupBX
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, BXBraceName
		MOV AH, 09h
		INT 21h
		MOV BX, backupBX
		MOV AX, [BX]
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, DIname
		MOV AH, 09h
		INT 21h
		LEA DX, equalsSign
		MOV AH, 09h
		INT 21h
		MOV AX, backupDI
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, DIBraceName
		MOV AH, 09h
		INT 21h
		MOV BX, backupDI
		MOV AX, [BX]
		CALL printAX
		
	JMP finish
	reg2:
		CMP AL, 2h
		JNE reg3
		LEA DX, BPname
		MOV AH, 09h
		INT 21h
		LEA DX, equalsSign
		MOV AH, 09h
		INT 21h
		MOV AX, backupBP
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, BPBraceName
		MOV AH, 09h
		INT 21h
		MOV BX, backupBP
		MOV AX, [BX]
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, SIname
		MOV AH, 09h
		INT 21h
		LEA DX, equalsSign
		MOV AH, 09h
		INT 21h
		MOV AX, backupSI
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, SIBraceName
		MOV AH, 09h
		INT 21h
		MOV BX, backupSI
		MOV AX, [BX]
		CALL printAX
		
	JMP finish
	reg3:
		CMP AL, 3h
		JNE reg4
		LEA DX, BPname
		MOV AH, 09h
		INT 21h
		LEA DX, equalsSign
		MOV AH, 09h
		INT 21h
		MOV AX, backupBP
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, BPBraceName
		MOV AH, 09h
		INT 21h
		MOV BX, backupBP
		MOV AX, [BX]
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, DIname
		MOV AH, 09h
		INT 21h
		LEA DX, equalsSign
		MOV AH, 09h
		INT 21h
		MOV AX, backupDI
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, DIBraceName
		MOV AH, 09h
		INT 21h
		MOV BX, backupDI
		MOV AX, [BX]
		CALL printAX
		
	JMP finish
	jumpToFinish:
	JMP finish
	reg4:
		CMP AL, 4h
		JNE reg5
		LEA DX, SIname
		MOV AH, 09h
		INT 21h
		LEA DX, equalsSign
		MOV AH, 09h
		INT 21h
		MOV AX, backupSI
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, SIBraceName
		MOV AH, 09h
		INT 21h
		MOV BX, backupSI
		MOV AX, [BX]
		CALL printAX
	JMP finish
	reg5:
		CMP AL, 5h
		JNE reg6
		LEA DX, DIname
		MOV AH, 09h
		INT 21h
		LEA DX, equalsSign
		MOV AH, 09h
		INT 21h
		MOV AX, backupDI
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, DIBraceName
		MOV AH, 09h
		INT 21h
		MOV BX, backupDI
		MOV AX, [BX]
		CALL printAX
	JMP finish
	reg6:
		CMP AL, 6h
		JNE reg7
		CMP CL, 0h
		JMP finish
		
		LEA DX, BPname
		MOV AH, 09h
		INT 21h
		LEA DX, equalsSign
		MOV AH, 09h
		INT 21h
		MOV AX, backupBP
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, BPBraceName
		MOV AH, 09h
		INT 21h
		MOV BX, backupBP
		MOV AX, [BX]
		CALL printAX
	JMP finish
	reg7:
		LEA DX, BXname
		MOV AH, 09h
		INT 21h
		LEA DX, equalsSign
		MOV AH, 09h
		INT 21h
		MOV AX, backupBX
		CALL printAX
		LEA DX, comma
		MOV AH, 09h
		INT 21h
		
		LEA DX, BXBraceName
		MOV AH, 09h
		INT 21h
		MOV BX, backupBX
		MOV AX, [BX]
		CALL printAX
	
	finish:
	POP DX
	POP CX
	POP BX
	POP AX
RET
printRegValue ENDP


end main
