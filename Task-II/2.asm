.model small		    
readBufSize     EQU 16	
.stack 100h		
.data            
	howManyTimesRead DB 0
    
    readName1        DB 50 dup (?)
   	readBuf1    	 DB readBufSize dup (0)
   	readHandle1      DW ?   
   	
    readName2        DB 50 dup (?)                      
    readBuf2    	 DB readBufSize dup (0)
    readHandle2      DW ?         
    
    writeName        DB 50 dup (?)
    writeHandle      DW ?
    
    help             DB 'Programa skirta isvesti dvieju bet kokio ilgio dvejetainiu skaiciu, esanciu skirtinguose failuose, AND operacijos rezultata taip pat dvejetainiu formatu.$'   
    successMessage   DB 'Programa buvo ivykdyta be klaidu, rezultatu ieskokite faile $'
.code

main:                  
    MOV AX, @data
    MOV DS, AX  
    	
	MOV SI, 0
	MOV BH, 0   
		
	LEA DI, readName1
	CALL findFileName
	CMP BH, 0FFh
	JE interrupt
	
	LEA DI, readName2
	CALL findFileName
	CMP BH, 0FFh
	JE interrupt 
	
	LEA DI, writeName
	CALL findFileName
	CMP BH, 0FFh
	JE interrupt  
	
	
	MOV AX, 3D00h                  
	LEA DX, readName1
	INT 21h
	JC interrupt                   
	MOV readHandle1, AX            
	
	MOV AX, 3D00h
	LEA DX, readName2
	INT 21h
	JC interrupt                    
	MOV readHandle2, AX          
	 
	MOV AH, 3Ch                   
	MOV CX, 0                      
	LEA DX, writeName
	INT 21h
	JC interrupt                    
	MOV writeHandle, AX            
	
	JMP readFile 
        
	readFile:
	    CALL clearBuf
	    MOV BH, 0
	    CALL readToBuf    
	    CMP BH, 0FFh
	    JE interrupt
	    CMP AX, 0       
	    JE finalizing
		JMP processingInput
		
	interrupt:   
    	MOV AH, 09h  
        LEA DX, help
        INT 21h
        JMP null
	
	
	processingInput:
	    MOV CX, AX          
	    LEA SI, readBuf1
	    LEA DI, readBuf2
	    iterating:
    	    MOV DL, [SI]
    	    MOV DH, [DI]
    	    CALL makeMoreNumbers
    	    CMP DL, '1'     
    	    JA interrupt
    	    CMP DH, '1'
    	    JA interrupt
    	    CMP DL, '0'
    	    JB interrupt
    	    CMP DH, '0'
    	    JB interrupt
    	    SUB DL, '0'
    	    SUB DH, '0'
    	    AND DL, DH
    	    ADD DL, '0'          
    	    MOV [SI], DL       
    	    INC SI
    	    INC DI
    	    LOOP iterating	
    	    JMP outputToFile
	
	outputToFile:
	    MOV CX, AX           
	    MOV BX, writeHandle  
	    CALL writeFromBuf
	    CMP DH, 0FFh
	    JE interrupt  
	    CMP AX, readBufSize   
	    JE readFile
		
	finalizing:           
	
	MOV AH, 3Eh
	MOV BX, writeHandle   
	INT 21h
	JC interrupt
	
	MOV AH, 3Eh
	MOV BX, readHandle1    
	INT 21h
	JC interrupt
	
	MOV AH, 3Eh
	MOV BX, readHandle2     
	INT 21h
	JC interrupt
	
	MOV AH, 09h
	LEA DX, successMessage
	INT 21h
	
	MOV AH, 09h
	LEA DX, writeName
	INT 21h
    
null:
    MOV AX, 4C00h
    INT 21h 
    
    
PROC findFileName
    
    MOV BL, 0             
    MOV AL, ES:[81h+SI]
    CMP AL, ' '
    JE skipSpaces
    JMP nextIteration
    
	skipSpaces:   
    	INC SI
    	MOV AL, ES:[81h+SI]
    	CMP AL, ' '
        JE skipSpaces
	
    nextIteration: 
        MOV AL, ES:[81h+SI]
        CMP AL, ' '              
        JE procEnd
        CMP ES:[81h+SI], '?/'  
        JE helpCall   
        CMP AL, 0Dh               
        JE procEnd
        MOV DS:[DI], AL            
        INC BL               
        INC DI
        INC SI
        JMP nextIteration
        
    helpCall:
        MOV BH, 0FFh              
        INC BL
        JMP procEnd
        
    procEnd:
        MOV AL, 0
        MOV DS:[DI], AL            
        CMP BL, 0
        JE helpCall               
        INC DI       
        MOV AL, '$'
        MOV DS:[DI], AL
        DEC DI 
        RET
        
findFileName ENDP

PROC readToBuf           
    MOV CX, readBufSize
    
    MOV AH, 3Fh
    LEA DX, readBuf1      
    MOV BX, readHandle1
    INT 21h
    JC readErrorException
	PUSH AX
	
    MOV AH, 3Fh
    MOV CX, readBufSize
    LEA DX, readBuf2      
    MOV BX, readHandle2
    INT 21h
    JC readErrorException
	POP DX
	
	CMP AX, 0
	JE errorCheck
	CMP DX, 0
	JE errorCheck
	
	errorCheckReturn:
	INC howManyTimesRead
	CMP AX, DX
	JB switch
	JMP readToBufEnd
	
	switch:
	    MOV AX, DX
    
    readToBufEnd:
        RET  
        
    readErrorException:     
        MOV BH, 0FFh
        MOV AX, 0       
        JMP readToBufEnd
		
	errorCheck:
	CMP howManyTimesRead, 0
	JE readErrorException
	JMP errorCheckReturn
        
readToBuf ENDP

PROC writeFromBuf
    MOV AH, 40h
    LEA DX, readBuf1           
    INT 21h
    JC writeErrorException    
    CMP CX, AX
    JNE writeErrorException
    
    writeFromBufEnd:          
        RET
    
    writeErrorException:
        MOV DH, 0FFh       
        JMP writeFromBufEnd
writeFromBuf ENDP

PROC makeMoreNumbers 
	CMP DL, 0
	JE incDL
	CMP DH, 0
	JE incDH
	return:
	
	RET
	
	incDL:
        MOV DL, '0'
        JMP return
            
    incDH:
        MOV DH, '0'
        JMP return
makeMoreNumbers ENDP

PROC clearBuf
	MOV CX, readBufSize
	LEA BX, readBuf1
	LEA BP, readBuf2
	MOV AL, 0
	clear:
	MOV DS:[BX], AL
	MOV DS:[BP], AL
	INC BX
	INC BP
	LOOP clear
	RET
clearBuf ENDP
	
        
end main
