<a id="top"></a>

# RCET 3375 Lab 08 - UART and Serial Device Interface

[RCET3375 course home](../README.md)

PIC16F883 | pic-as | EUSART | RS-232 | Packets | ADC | LM34 | Servo Control

## Contents

- [Purpose](#purpose)
- [Standards and references](#standards-references)
- [Equipment and materials](#equipment-materials)
- [Part 1 - UART TX and RS-232 proof of life](#part-1)
- [Part 2 - UART RX and byte echo](#part-2)
- [Part 3 - Structured packets and ADC data](#part-3)
- [Part 4 - LM34, UART, and servo integration](#part-4)
- [Part 5 - Mastery: three-servo scheduler](#part-5)
- [Submission and checkoff](#submission)

<a id="purpose"></a>
## Purpose

Build a bidirectional serial interface for the PIC16F883, then integrate UART communication with ADC measurement and precise servo timing.

The lab progresses from one repeating byte to byte echo, structured command packets, LM34 temperature measurement, and simultaneous UART/ADC/servo operation.

[Back to top](#top) · [Course home](../README.md)

<a id="standards-references"></a>
## Standards and references

- [RCET 3375 Lab Standard](../LAB_STANDARD.md)
- [RCET PIC-AS Style Guide](../Notes/RCET_PIC-AS_Style_Guide.md)
- [Starting a PIC-AS Project](../HowTo/PIC-AS-Project-Setup.md)
- [RCET 3373 UART and Asynchronous Serial Communication](https://github.com/rosstimo/RCET3373/blob/main/Topics/uart-asynchronous-serial.md)
- [RCET 3373 PIC16F883 ADC and Sensor Conditioning](https://github.com/rosstimo/RCET3373/blob/main/Topics/pic16f883-adc.md)
- [PIC16F882/883/884/886/887 Data Sheet](https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf)
- [TI MAX232 Data Sheet](https://www.ti.com/lit/ds/symlink/max232.pdf)
- [TI LM34 Data Sheet](https://www.ti.com/lit/ds/symlink/lm34.pdf)

Use the PIC16F883 data sheet as the device authority for EUSART and ADC behavior. Use the data sheet for the exact MAX232-family device installed in your circuit when selecting charge-pump capacitors and verifying electrical limits.

[Back to top](#top) · [Course home](../README.md)

<a id="equipment-materials"></a>
## Equipment and materials

- PIC16F883 circuit with 4 MHz crystal
- MPLAB X, pic-as, and PICkit 3
- oscilloscope with serial decode
- computer serial terminal and host program capable of sending/receiving binary bytes
- USB-to-RS-232 adapter
- MAX232 or equivalent RS-232 transceiver and required capacitors
- potentiometer
- LM34 temperature sensor
- one servo for Part 4
- three servos for optional Mastery
- suitable servo power supply
- digital multimeter
- independent temperature reference
- breadboard, jumpers, and lab book

[Back to top](#top) · [Course home](../README.md)

<a id="part-1"></a>
## Part 1 - UART TX and RS-232 Proof of Life

### Goal

Configure the PIC16F883 EUSART for 9600 baud, 8N1, continuously transmit `$` (`0x24`), and verify both logic-level UART and RS-232 signaling.

### UART frame and timing

Explain `8N1` in your lab book:

- `8` = eight data bits
- `N` = no parity bit
- `1` = one stop bit

An asynchronous 8N1 character also has one start bit:

```text
1 start + 8 data + 0 parity + 1 stop = 10 bit-times
```

For a target baud rate of 9600 baud:

```math
\begin{aligned}
T_{\text{bit}}
&= \frac{1}{9600} \\
&= 104.17\,\mu\text{s}
\end{aligned}
```

One complete 8N1 byte takes:

```math
\begin{aligned}
T_{\text{byte}}
&= 10T_{\text{bit}} \\
&= 10(104.17\,\mu\text{s}) \\
&= 1.0417\,\text{ms}
\end{aligned}
```

Use the baud-rate-generator settings you select to calculate the expected actual baud rate. Measure actual bit time on the oscilloscope and calculate measured baud rate:

```math
\text{baud}_{\text{measured}}
=
\frac{1}{T_{\text{bit measured}}}
```

### Before Lab

Prepare or reference:

- EUSART SFR documentation for `TXSTA`, `RCSTA`, `BAUDCTL`, `SPBRG`, `TXREG`, and relevant `PIR1` flags;
- baud-generator calculation for 9600 baud at your actual oscillator frequency;
- explanation of 8N1 and predicted bit/byte time;
- expected UART bit pattern for `$ = 0x24`, including LSB-first transmission;
- MAX232/adapter schematic and complete electrical-loading/component verification;
- actual MAX232-family capacitor values and voltage ratings from its data sheet;
- expected logic-level UART and RS-232 idle/start/data/stop polarity;
- program flowchart and source.

Build both TX and RX sides of the level converter even though Part 1 uses TX only.

### In the Lab

1. Configure EUSART asynchronous transmit at 9600 baud, 8N1.
2. Continuously transmit `$`.
3. Measure RC6/TX before the level converter.
4. Capture one complete frame and label idle, start, all eight data bits, and stop.
5. Measure bit time and complete byte time.
6. Calculate baud rate from the measured bit time.
7. Verify that one byte occupies 10 measured bit-times.
8. Measure the corresponding RS-232 waveform after the MAX232.
9. Record the logic-level and RS-232 HIGH/LOW voltages and explain the inversion.

### Evidence

Include or reference:

- EUSART SFR documentation;
- baud-generator, bit-time, and byte-time calculations;
- MAX232 circuit and loading/component verification;
- labeled RC6/TX waveform;
- labeled RS-232 waveform;
- measured bit time, byte time, and calculated measured baud rate;
- final Part 1 source.

### Demonstrate

Show continuous `$` transmission at both measurement points.

Explain 8N1, why the byte takes 10 bit-times, LSB-first transmission, measured baud rate, and why the PIC UART signal cannot be connected directly to a traditional RS-232 interface.

### Complete When

Part 1 is complete when `$` is correctly transmitted at both logic and RS-232 levels and the measured timing agrees with the configured baud rate.

[Back to top](#top) · [Course home](../README.md)

<a id="part-2"></a>
## Part 2 - UART RX and Byte Echo

### Goal

Receive one byte from the host and immediately transmit the same byte back.

Keep this part byte-oriented. Do not add the packet parser yet.

### Receive service time

The PIC16F883 receiver can hold two complete unread characters. If a third character completes before software services the receive FIFO, `OERR` is set.

Use your measured byte time from Part 1:

```math
\begin{aligned}
T_{\text{RX absolute limit}}
&\approx 2T_{\text{byte}} \\
&\approx 2(1.0417\,\text{ms}) \\
&\approx 2.083\,\text{ms}
\end{aligned}
```

This is an absolute overrun boundary for continuous back-to-back traffic, not a normal service target. Your foreground loop should normally check RX at least once per character time and preferably much more often.

No software state register is required for Part 2.

### Before Lab

Prepare or reference:

- `RC7/RX` configuration;
- `RCIF`, `RCREG`, `FERR`, `OERR`, and `CREN` behavior;
- receive FIFO/service-time calculation using your measured byte time;
- RX/TX flowchart and source.

### In the Lab

1. Send single bytes from the host and verify exact byte echo.
2. Send several different binary/ASCII values.
3. Verify RX and TX with the oscilloscope or serial decoder.
4. Intentionally delay RX service while the host sends a continuous stream until `OERR` occurs.
5. Demonstrate recovery by resetting the receiver as specified by the PIC16F883 data sheet.
6. Remove the artificial delay and verify normal echo again.

Check `FERR` before reading `RCREG` because the framing status belongs to the next unread character.

### Evidence

Include or reference:

- receive-service calculation;
- RX/TX flowchart and final source;
- scope/decoder evidence for one echoed byte;
- observed overrun condition and recovery;
- explanation of `FERR` versus `OERR`.

### Demonstrate

Echo arbitrary bytes and deliberately create/recover from `OERR`.

Explain how long one byte occupies the wire, how long the receiver can remain completely unserviced under continuous traffic, and why those are different timing questions.

### Complete When

Part 2 is complete when arbitrary bytes echo correctly and you can create, identify, and recover from receive overrun.

[Back to top](#top) · [Course home](../README.md)

<a id="part-3"></a>
## Part 3 - Structured Packets and ADC Data

### Goal

Replace raw byte echo with a nonblocking packet parser. Use command packets to request device identification and the full 10-bit ADC value from the potentiometer on AN0.

### Packet format

All structured packets use:

```text
Byte 0      Byte 1      Byte 2      Byte 3 ...
$           COMMAND     LENGTH      DATA[0] ... DATA[N-1]
0x24                    N
```

Rules:

- `$` and command letters are shown as their printable characters.
- `LENGTH` and numeric DATA values are raw byte values, not ASCII digits.
- `LENGTH` is the number of DATA bytes only.
- Total packet length is `3 + LENGTH` bytes.
- Maximum payload length is 8 bytes.
- Multi-byte values are transmitted high byte first.
- The parser handles one received byte at a time and returns to the main loop.
- A zero-length packet is complete immediately after `LENGTH`.
- If `LENGTH > 8`, discard the partial packet and return to waiting for `$`.
- The host sends one request at a time and waits for its response before sending another request.

At 9600 baud, 8N1:

```math
T_{\text{packet}}
=
(3+\text{LENGTH})T_{\text{byte}}
```

For the three-byte Device ID request:

```math
\begin{aligned}
T_{\text{packet}}
&=3(1.0417\,\text{ms}) \\
&=3.125\,\text{ms}
\end{aligned}
```

A packet can therefore take several milliseconds to arrive even though RX still needs to be serviced roughly once per byte.

### Defined Part 3 packets

#### Device ID request

```text
$ I 0
```

The required device ID for this lab is `0x3375`.

#### Device ID response

```text
$ I 2 0x33 0x75
```

#### Analog Channel request

```text
$ A 1 CHANNEL
```

For Parts 3 and 4, use AN0:

```text
CHANNEL = 0x00
```

#### Analog Channel Data response

```text
$ A 3 CHANNEL ADC_H ADC_L
```

`ADC_H:ADC_L` carries the complete right-justified 10-bit ADC result.

#### Error response

```text
$ E 2 ERROR_CODE DETAIL
```

Error codes used in this lab:

```text
0x01 = framing error
0x02 = receive overrun
0x03 = servo pulse width out of range
```

Part 3 must implement `0x01` and `0x02`. Part 4 adds `0x03`.

For framing error, `DETAIL` may contain the affected received byte. For overrun, use `DETAIL = 0x00`.

After a framing or overrun error, discard the current partial packet and return the parser to waiting for `$`. The host may resend its last complete command packet.

### Required parser state

Use one software state register:

```text
rx_state:
    0 = WAIT_START
    1 = GET_COMMAND
    2 = GET_LENGTH
    3 = GET_DATA
```

Supporting data is not additional parser state:

```text
rx_command
rx_length
rx_count
rx_data[0..7]

tx_length
tx_count
tx_data[0..10]
```

A separate `tx_state` register is not required. If `tx_count < tx_length`, a response is still being transmitted.

### Packet parser flow

```text
WAIT_START:
    '$' -> GET_COMMAND

GET_COMMAND:
    save command
    -> GET_LENGTH

GET_LENGTH:
    save length
    count = 0
    length = 0 -> ProcessPacket
    length 1..8 -> GET_DATA
    length > 8 -> WAIT_START

GET_DATA:
    save DATA[count]
    count++
    count = length -> ProcessPacket
```

After `ProcessPacket`, return to `WAIT_START`.

### Device ID parser example

Start from your working Part 2 EUSART setup. Call `InitProtocol` once after peripheral setup, then enter `Main`. The following example implements the generic receive states, an indexed payload buffer, and the first complete structured transaction:

```text
host -> PIC:  $ I 0
PIC  -> host: $ I 2 0x33 0x75
```

It intentionally does not implement the Analog Channel or Error responses. Extend the same parser rather than writing a separate parser for each command.

```assembly
START_BYTE      EQU 0x24
CMD_ID          EQU 0x49

RX_WAIT_START   EQU 0
RX_GET_COMMAND  EQU 1
RX_GET_LENGTH   EQU 2
RX_GET_DATA     EQU 3
MAX_PAYLOAD     EQU 8

rx_state        EQU 0x20
rx_command      EQU 0x21
rx_length       EQU 0x22
rx_count        EQU 0x23
rx_byte         EQU 0x24

tx_length       EQU 0x25
tx_count        EQU 0x26

rx_data0        EQU 0x30        ; reserve 0x30-0x37
tx_data0        EQU 0x38        ; reserve 0x38-0x42

InitProtocol:
    clrf    rx_state
    clrf    rx_command
    clrf    rx_length
    clrf    rx_count
    clrf    tx_length
    clrf    tx_count
    return

Main:
    call    ServiceRx
    call    ServiceTx
    goto    Main

ServiceRx:
    BANKSEL PIR1
    btfss   PIR1, RCIF
    return

    BANKSEL RCSTA
    btfsc   RCSTA, OERR
    goto    RxOverrun
    btfsc   RCSTA, FERR
    goto    RxFraming

    BANKSEL RCREG
    movf    RCREG, W
    BANKSEL rx_byte
    movwf   rx_byte

    movf    rx_state, W
    xorlw   RX_WAIT_START
    btfsc   STATUS, Z
    goto    RxWaitStart

    movf    rx_state, W
    xorlw   RX_GET_COMMAND
    btfsc   STATUS, Z
    goto    RxGetCommand

    movf    rx_state, W
    xorlw   RX_GET_LENGTH
    btfsc   STATUS, Z
    goto    RxGetLength

    goto    RxGetData

RxWaitStart:
    movf    rx_byte, W
    xorlw   START_BYTE
    btfss   STATUS, Z
    return

    movlw   RX_GET_COMMAND
    movwf   rx_state
    return

RxGetCommand:
    movf    rx_byte, W
    movwf   rx_command

    movlw   RX_GET_LENGTH
    movwf   rx_state
    return

RxGetLength:
    movf    rx_byte, W
    movwf   rx_length

    sublw   MAX_PAYLOAD         ; MAX_PAYLOAD - rx_length
    btfss   STATUS, C           ; C = 0 -> length > MAX_PAYLOAD
    goto    ResetParser

    clrf    rx_count
    movf    rx_length, F
    btfsc   STATUS, Z
    goto    ProcessPacket

    movlw   RX_GET_DATA
    movwf   rx_state
    return

RxGetData:
    movf    rx_count, W
    addlw   rx_data0
    movwf   FSR

    movf    rx_byte, W
    movwf   INDF

    incf    rx_count, F

    movf    rx_length, W
    subwf   rx_count, W
    btfsc   STATUS, Z
    goto    ProcessPacket
    return

ProcessPacket:
    movf    rx_command, W
    xorlw   CMD_ID
    btfss   STATUS, Z
    goto    ResetParser

    movf    rx_length, F
    btfss   STATUS, Z
    goto    ResetParser

    call    BuildIdResponse

ResetParser:
    clrf    rx_state
    return

BuildIdResponse:
    ; Do not overwrite a response that is still transmitting.
    movf    tx_length, W
    subwf   tx_count, W
    btfss   STATUS, Z
    return

    clrf    tx_count
    movlw   5
    movwf   tx_length

    movlw   START_BYTE
    movwf   tx_data0
    movlw   CMD_ID
    movwf   tx_data0+1
    movlw   2
    movwf   tx_data0+2
    movlw   0x33
    movwf   tx_data0+3
    movlw   0x75
    movwf   tx_data0+4
    return

ServiceTx:
    BANKSEL tx_count
    movf    tx_length, W
    subwf   tx_count, W
    btfsc   STATUS, Z
    return

    BANKSEL PIR1
    btfss   PIR1, TXIF
    return

    BANKSEL tx_count
    movf    tx_count, W
    addlw   tx_data0
    movwf   FSR

    movf    INDF, W
    BANKSEL TXREG
    movwf   TXREG

    BANKSEL tx_count
    incf    tx_count, F
    return

RxFraming:
    ; Read/discard the character after checking FERR.
    BANKSEL RCREG
    movf    RCREG, W
    BANKSEL rx_state
    clrf    rx_state
    return

RxOverrun:
    BANKSEL RCSTA
    bcf     RCSTA, CREN
    bsf     RCSTA, CREN
    BANKSEL rx_state
    clrf    rx_state
    return
```

Use `FSR/INDF` to extend `GET_DATA` to any payload up to eight bytes.

### ADC request behavior

For `$ A 1 0x00`:

1. validate the packet and channel;
2. start one AN0 conversion;
3. set a small reply-pending flag;
4. return to the main loop;
5. continue servicing UART while the ADC converts;
6. when `GO/DONE` clears, build `$ A 3 0x00 ADC_H ADC_L`;
7. clear the pending flag.

Do not wait in a loop for the conversion to finish.

### Before Lab

Prepare or reference:

- packet definitions and parser flowchart;
- packet-time calculations for each packet used in Part 3;
- parser RAM map, including the eight-byte RX buffer and TX buffer;
- `FSR/INDF` use for indexed buffer access;
- right-justified AN0 ADC configuration;
- host program capable of sending the defined binary packets and displaying responses;
- source implementing Device ID, Analog Channel, framing error, and overrun error packets.

### In the Lab

1. Verify the Device ID request returns `0x3375`.
2. Turn the potentiometer and request AN0 repeatedly.
3. Verify the returned 10-bit value spans approximately 0 through 1023.
4. Compare selected ADC results with DMM voltage.
5. Verify that RX remains serviced while responses are transmitted.
6. Create an overrun and verify the `$ E 2 0x02 0x00` response and parser recovery.
7. If a framing error is observed during testing, verify the `0x01` error response.

### Evidence

Include or reference:

- packet table and packet-time calculations;
- parser flowchart and RAM map;
- final PIC source and host source;
- Device ID request/response capture;
- several Analog Channel request/responses;
- ADC value versus DMM voltage comparison;
- receive-error/recovery evidence.

### Demonstrate

Request the Device ID and live AN0 data from the host.

Explain how `LENGTH` controls parsing, why packet duration is different from the RX service deadline, how `rx_state` advances one byte at a time, and how the ADC response remains nonblocking.

### Complete When

Part 3 is complete when the host can request Device ID and full 10-bit AN0 data using the defined packet protocol and the PIC can recover cleanly from receive errors.

[Back to top](#top) · [Course home](../README.md)

<a id="part-4"></a>
## Part 4 - LM34, UART, and Servo Integration

### Goal

Replace the potentiometer with an LM34 temperature sensor and integrate UART RX/TX, ADC acquisition, and one CCP-timed servo.

The UART packet structure remains unchanged. The PIC returns raw ADC data. Temperature conversion and calibration are performed on the host.

### LM34 conversion

The LM34 nominal output scale is:

```math
10\,\text{mV}/^\circ\text{F}
```

Using VDD/VSS as ADC references:

```math
V_{\text{sensor}}
=
\text{ADC}
\left(
\frac{V_{\text{REF}}}{1024}
\right)
```

Then:

```math
T[^\circ\text{F}]
=
\frac{V_{\text{sensor}}}{0.010\,\text{V}/^\circ\text{F}}
```

#### Worked example

**What:** convert one returned ADC result to temperature.

**Why:** the PIC transmits raw measurement data; the host assigns the engineering units.

For measured `V_{\text{REF}}=5.00\,\text{V}` and ADC code 150:

```math
\begin{aligned}
V_{\text{sensor}}
&=
150
\left(
\frac{5.00\,\text{V}}{1024}
\right) \\
&=0.732\,\text{V}
\end{aligned}
```

```math
\begin{aligned}
T
&=
\frac{0.732\,\text{V}}
{0.010\,\text{V}/^\circ\text{F}} \\
&=73.2^\circ\text{F}
\end{aligned}
```

Use your measured reference voltage and calibration results.

### Servo command packet

Command one servo with the desired HIGH time directly in microseconds:

```text
$ S 2 PW_H PW_L
```

`PW_H:PW_L` is a 16-bit unsigned pulse width in microseconds.

Accept:

```text
500 us through 2500 us
```

Reject any value outside that range. Do not clamp it in this lab.

For an invalid command:

- leave the previously accepted servo command unchanged;
- return `$ E 2 0x03 0x01`;
- do not automatically resend the same invalid command from the host.

A simple 16-bit range check compares the high byte first and only checks the low byte when the high bytes match:

```text
500  us = 0x01F4
2500 us = 0x09C4

PW < 0x01F4 -> reject
PW > 0x09C4 -> reject
otherwise    -> accept
```

### One-servo scheduler

Continue using Timer1 as a 1 us timebase and 20 ms frame. At 4 MHz with the Lab 07 setup, reload Timer1 to `0xB1E0` at the frame start.

Use a short protected window before the servo falling edge. Start with:

```text
G = 100 us
```

Keep foreground code interruptible. Do not begin longer foreground work while `servo_state = 1`.

```text
servo_state:
    0 = pre-edge
    1 = protected falling-edge window
    2 = remainder of frame
```

A separate `servo_busy` flag is not required.

For pulse width (PW) and guard interval (G), schedule absolute Timer1 matches from the frame reload:

```math
\begin{aligned}
\text{pre-edge match} &= 0xB1E0 + PW - G \\
\text{falling-edge match} &= 0xB1E0 + PW
\end{aligned}
```

For $PW = 1500\,\mu\text{s}$ and $G = 100\,\mu\text{s}$:

```math
\begin{aligned}
\text{pre-edge match}
&=45536+1500-100 \\
&=46936 \\
&=0xB758
\end{aligned}
```

```math
\begin{aligned}
\text{falling-edge match}
&=45536+1500 \\
&=47036 \\
&=0xB7BC
\end{aligned}
```

Program structure:

```text
Timer1 overflow:
    reload Timer1 for 20 ms
    copy next pulse width to active pulse width
    servo HIGH
    servo_state = 0
    schedule CCP at active_PW - G

CCP, state 0:
    servo_state = 1
    schedule CCP at active_PW

CCP, state 1:
    servo LOW
    servo_state = 2

main:
    service RX
    service TX
    service ADC/reply
    when servo_state != 1
        perform other foreground work
```

Use absolute Timer1 compare deadlines. Do not change the active pulse-width value after the pulse starts.

### Required LM34 calibration

Before lab, write a calibration procedure that:

- uses an independent temperature reference;
- uses at least two stable temperature points when practical;
- records raw ADC count and calculated LM34 voltage;
- calculates temperature using the nominal 10 mV/°F relationship;
- compares calculated temperature with the independent reference;
- records error at each point;
- states whether an offset or other correction is justified;
- applies any correction on the host side.

The calibration verifies the complete LM34 → ADC → UART → host measurement chain.

### Before Lab

Prepare or reference:

- LM34/MAX232/PIC/servo schematic and complete electrical-loading/component verification;
- LM34 temperature-conversion worked calculation;
- temperature-calibration procedure;
- Part 3 packet parser and host program;
- Timer1/CCP SFR documentation and 1 us/20 ms timing calculations from Lab 07;
- `servo_state` scheduler flowchart;
- 16-bit servo range-check logic;
- source that keeps UART, ADC, and servo timing nonblocking.

### In the Lab

Keep the servo disconnected until waveform checkoff.

1. Replace the potentiometer with the LM34 on AN0.
2. Request raw ADC data and verify host temperature conversion.
3. Perform the planned temperature calibration.
4. Verify the servo command at 500, 1500, and 2500 us on the oscilloscope.
5. Send an out-of-range servo command and verify it is rejected with `0x03` while the previous valid command remains active.
6. Obtain instructor waveform checkoff.
7. Connect the servo using a suitable supply and common ground.
8. Repeatedly request temperature and change servo pulse width while the servo is active.
9. Verify UART/ADC activity does not visibly shift the servo falling edge or disturb the 20 ms frame.

### Evidence

Include or reference:

- LM34 loading/component analysis;
- calibration procedure and measurement table;
- raw ADC, calculated voltage, calculated temperature, reference temperature, and error;
- final PIC and host source;
- valid and invalid servo command captures;
- servo timing under sustained UART/ADC activity.

Suggested calibration table:

| Reference °F | ADC code | Calculated voltage | Calculated °F | Error °F | Corrected °F |
| ---: | ---: | ---: | ---: | ---: | ---: |
|  |  |  |  |  |  |
|  |  |  |  |  |  |

### Demonstrate

Show live temperature requests while independently changing servo pulse width.

Explain the raw-data packet, host-side temperature calculation, calibration result, 16-bit pulse-width validation, protected-edge state, and why an invalid command is rejected rather than clamped.

### Complete When

Part 4 is complete when temperature data is calibrated and reported correctly, valid servo commands produce the requested pulse widths, invalid commands are rejected/reported, and sustained UART/ADC work does not disturb servo timing.

[Back to top](#top) · [Course home](../README.md)

<a id="part-5"></a>
## Part 5 - Mastery: Three-Servo Scheduler

Part 5 is optional Mastery. Complete Parts 1 through 4 first.

### Goal

Extend Part 4 to independently command three servos while UART RX/TX and ADC acquisition remain active.

### Three-servo command

Use one packet to update all three next pulse widths:

```text
$ S 6 S1_H S1_L S2_H S2_L S3_H S3_L
```

Each value is a 16-bit pulse width in microseconds and must be 500 through 2500 us.

Reject the complete command if any of the three values is out of range. Return error `0x03` with `DETAIL` equal to the failing servo number:

```text
0x01 = Servo 1
0x02 = Servo 2
0x03 = Servo 3
```

Do not partially update the command.

### Scheduler

Use one Timer1 20 ms frame and one CCP Compare event stream.

```text
0 ms   Servo 1 slot
5 ms   Servo 2 slot
10 ms  Servo 3 slot
15 ms  final idle slot
20 ms  next frame
```

Use the same protected-edge idea from Part 4:

```text
0 = Servo 1 pre-edge
1 = Servo 1 protected edge
2 = Servo 1 remainder

3 = Servo 2 pre-edge
4 = Servo 2 protected edge
5 = Servo 2 remainder

6 = Servo 3 pre-edge
7 = Servo 3 protected edge
8 = Servo 3 remainder

9 = final idle
```

States 1, 4, and 7 are the only protected states.

Use absolute Timer1 deadlines so ISR execution time does not accumulate frame drift.

### In the Lab

1. Verify all three waveforms before connecting servos.
2. Verify 500, 1500, and 2500 us for each output.
3. Verify one 20 ms frame for all three channels.
4. Connect the servos using a suitable external supply and common ground.
5. Command all three servos independently from the host.
6. Run sustained UART requests and ADC acquisition while all three servos operate.
7. Verify no visible chatter or measurable timing degradation beyond normal ISR timing.

### Evidence

Include or reference:

- final scheduler/parser flowchart;
- final PIC and host source;
- three-channel scope capture;
- representative min/center/max measurements for all three outputs;
- timing evidence while UART and ADC are active.

### Complete When

Mastery is complete when all three servos accept independent pulse-width commands through the packet protocol and maintain stable timing while UART and ADC remain active.

[Back to top](#top) · [Course home](../README.md)

<a id="submission"></a>
## Submission and Checkoff

Before final checkoff:

1. complete Parts 1 through 4 and any attempted Mastery work;
2. push the complete assignment repository to GitHub;
3. include the MPLAB X project, host program, editable source, schematics, and required evidence;
4. scan the relevant lab-book pages into one readable, correctly oriented PDF under `lab-book/`;
5. verify a fresh clone contains enough information to reopen and rebuild the assignment.

Instructor checkoff includes the required demonstrations and explanations from each completed part.

[Back to top](#top) · [Course home](../README.md)
