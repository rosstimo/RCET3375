;==============================================================================
; RCET 3375 Lab 07 - Part 4 supplied ADC mapping module
;
; Add this file to the MPLAB X project as a separate source file.
; Do not #include this file from main.S.
;
; Public interface:
;   MapAdcToCcp
;       Input:  adc_l:adc_h = right-justified 10-bit ADC result
;       Output: ccp_next_l:ccp_next_h = absolute Timer1 CCP match value
;
; main.S must define and export:
;   adc_l
;   adc_h
;   ccp_next_l
;   ccp_next_h
;
; Mapping:
;   pulse = 500 us + 2*ADC - floor(3*ADC / 64)
;
; Note: adc_l:adc_h are used as working registers and are changed by this
; routine after the result has been mapped.
;
; This module reserves Bank 0 address 0x25 as map_count.
;==============================================================================

PROCESSOR 16F883
RADIX dec

#include <xc.inc>

GLOBAL  MapAdcToCcp
EXTRN   adc_l, adc_h, ccp_next_l, ccp_next_h

; Timer1 reload + 500 us = 0xB1E0 + 500 = 0xB3D4
CCP_OFFSET_L    EQU 0xD4
CCP_OFFSET_H    EQU 0xB3

map_count       EQU 0x25

PSECT mapCode,class=CODE,delta=2

;------------------------------------------------------------------------------
; Convert the full 10-bit ADC result into the CCP1 match for the next frame.
;
; ccp_next = Timer1 reload + 500 us + 2*ADC - floor(3*ADC / 64)
;------------------------------------------------------------------------------

MapAdcToCcp:
    ; ccp_next = 2 * ADC
    BANKSEL adc_l
    movf    adc_l,w
    movwf   ccp_next_l
    movf    adc_h,w
    movwf   ccp_next_h

    bcf     STATUS,0
    rlf     ccp_next_l,f
    rlf     ccp_next_h,f

    ; Reuse adc_l:adc_h as 3 * ADC.
    movf    ccp_next_l,w
    addwf   adc_l,f
    btfsc   STATUS,0
    incf    adc_h,f
    movf    ccp_next_h,w
    addwf   adc_h,f

    ; adc_l:adc_h = floor(3 * ADC / 64)
    movlw   6
    movwf   map_count

mapShift:
    bcf     STATUS,0
    rrf     adc_h,f
    rrf     adc_l,f
    decfsz  map_count,f
    goto    mapShift

    ; Subtract the correction term.
    movf    adc_l,w
    subwf   ccp_next_l,f
    btfss   STATUS,0
    decf    ccp_next_h,f

    ; Add Timer1 reload + 500 us.
    movlw   CCP_OFFSET_L
    addwf   ccp_next_l,f
    btfsc   STATUS,0
    incf    ccp_next_h,f

    movlw   CCP_OFFSET_H
    addwf   ccp_next_h,f

    return

END
