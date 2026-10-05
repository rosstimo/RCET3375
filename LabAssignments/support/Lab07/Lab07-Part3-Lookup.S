;==============================================================================
; RCET 3375 Lab 07 - Part 3 supplied lookup module
;
; Add this file to the MPLAB X project as a separate source file.
; Do not #include this file from main.S.
;
; Public interface:
;   LookupAdc6ToCcp
;       Input:  W = 6-bit ADC command index, 0 through 63
;       Output: ccp_next_l:ccp_next_h = absolute Timer1 CCP match value
;
; Call this routine with PAGESEL/call/PAGESEL (or fcall) because a separate
; source module may be linked onto a different program-memory page.
;
; main.S must define and export:
;   ccp_next_l
;   ccp_next_h
;
; This module reserves Bank 0 address 0x25 as table_index.
;==============================================================================

PROCESSOR 16F883
RADIX dec

#include <xc.inc>

GLOBAL  LookupAdc6ToCcp
EXTRN   ccp_next_l, ccp_next_h

table_index     EQU 0x25

;------------------------------------------------------------------------------
; Convert the 6-bit command index in W into the 16-bit CCP match value.
;------------------------------------------------------------------------------

PSECT lookupCode,class=CODE,delta=2

LookupAdc6ToCcp:
    BANKSEL table_index
    movwf   table_index

    movf    table_index,w
    PAGESEL LookupLow
    call    LookupLow
    PAGESEL $
    BANKSEL ccp_next_l
    movwf   ccp_next_l

    BANKSEL table_index
    movf    table_index,w
    PAGESEL LookupHigh
    call    LookupHigh
    PAGESEL $
    BANKSEL ccp_next_h
    movwf   ccp_next_h

    return

;------------------------------------------------------------------------------
; 64-entry lookup tables.
;
; Timer1 reload = 0xB1E0
; Timer1 tick   = 1 us
; Pulse range   = 500 us through 2500 us
;
; The tables contain absolute 16-bit Timer1 compare values.
; Each table stays inside one 256-word PCL block.
;------------------------------------------------------------------------------

PSECT lookupLow,abs,ovrld,class=CODE,delta=2
ORG 0x0600

LookupLow:
    BANKSEL table_index
    movwf   table_index
    BANKSEL PCLATH
    movlw   0x06
    movwf   PCLATH
    BANKSEL table_index
    movf    table_index,w
    addwf   PCL,f

    retlw   0xD4
    retlw   0xF4
    retlw   0x13
    retlw   0x33
    retlw   0x53
    retlw   0x73
    retlw   0x92
    retlw   0xB2
    retlw   0xD2
    retlw   0xF2
    retlw   0x11
    retlw   0x31
    retlw   0x51
    retlw   0x71
    retlw   0x90
    retlw   0xB0
    retlw   0xD0
    retlw   0xF0
    retlw   0x0F
    retlw   0x2F
    retlw   0x4F
    retlw   0x6F
    retlw   0x8E
    retlw   0xAE
    retlw   0xCE
    retlw   0xEE
    retlw   0x0D
    retlw   0x2D
    retlw   0x4D
    retlw   0x6D
    retlw   0x8C
    retlw   0xAC
    retlw   0xCC
    retlw   0xEC
    retlw   0x0B
    retlw   0x2B
    retlw   0x4B
    retlw   0x6B
    retlw   0x8A
    retlw   0xAA
    retlw   0xCA
    retlw   0xEA
    retlw   0x09
    retlw   0x29
    retlw   0x49
    retlw   0x69
    retlw   0x88
    retlw   0xA8
    retlw   0xC8
    retlw   0xE8
    retlw   0x07
    retlw   0x27
    retlw   0x47
    retlw   0x67
    retlw   0x86
    retlw   0xA6
    retlw   0xC6
    retlw   0xE6
    retlw   0x05
    retlw   0x25
    retlw   0x45
    retlw   0x65
    retlw   0x84
    retlw   0xA4


PSECT lookupHigh,abs,ovrld,class=CODE,delta=2
ORG 0x0680

LookupHigh:
    BANKSEL table_index
    movwf   table_index
    BANKSEL PCLATH
    movlw   0x06
    movwf   PCLATH
    BANKSEL table_index
    movf    table_index,w
    addwf   PCL,f

    retlw   0xB3
    retlw   0xB3
    retlw   0xB4
    retlw   0xB4
    retlw   0xB4
    retlw   0xB4
    retlw   0xB4
    retlw   0xB4
    retlw   0xB4
    retlw   0xB4
    retlw   0xB5
    retlw   0xB5
    retlw   0xB5
    retlw   0xB5
    retlw   0xB5
    retlw   0xB5
    retlw   0xB5
    retlw   0xB5
    retlw   0xB6
    retlw   0xB6
    retlw   0xB6
    retlw   0xB6
    retlw   0xB6
    retlw   0xB6
    retlw   0xB6
    retlw   0xB6
    retlw   0xB7
    retlw   0xB7
    retlw   0xB7
    retlw   0xB7
    retlw   0xB7
    retlw   0xB7
    retlw   0xB7
    retlw   0xB7
    retlw   0xB8
    retlw   0xB8
    retlw   0xB8
    retlw   0xB8
    retlw   0xB8
    retlw   0xB8
    retlw   0xB8
    retlw   0xB8
    retlw   0xB9
    retlw   0xB9
    retlw   0xB9
    retlw   0xB9
    retlw   0xB9
    retlw   0xB9
    retlw   0xB9
    retlw   0xB9
    retlw   0xBA
    retlw   0xBA
    retlw   0xBA
    retlw   0xBA
    retlw   0xBA
    retlw   0xBA
    retlw   0xBA
    retlw   0xBA
    retlw   0xBB
    retlw   0xBB
    retlw   0xBB
    retlw   0xBB
    retlw   0xBB
    retlw   0xBB


END
