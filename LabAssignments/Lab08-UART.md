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

Reuse your working Lab07 ADC configuration, acquisition, and result-reading code when integrating ADC in Parts 3-5. Reuse your Lab07 Timer1/CCP servo code for Parts 4-5, adapting it to work alongside UART.

**Repository setup:** Create a Git repository for Lab08 before starting your projects. Open the [student lab `.gitignore` template](../HowTo/Student-Lab-Repository.gitignore), select **Raw**, and save the file as `.gitignore` in the repository root alongside `README.md`. Do this before your first `git add` so generated files are excluded. Keep the PIC firmware and host application in separate directories as shown in the [assignment repository structure](#assignment-repository-structure).

[Back to top](#top)

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


Use the PIC16F883 data sheet for EUSART and ADC settings. Check the data sheet for your MAX232-family device for charge-pump capacitor requirements, and the LM34 data sheet for pin connections, supply limits, and its 10 mV/°F output.

[Back to top](#top)

<a id="equipment-materials"></a>
## Equipment and materials

- oscilloscope with serial decode
- frequency counter
- digital multimeter
- suitable servo power supply (independent/isolated preffered)
- independent temperature reference
- PICkit 3 or equivalent programmer/debugger
- computer with MPLAB X, pic-as, a serial terminal, and a host program capable of sending/receiving binary bytes
- USB-to-RS-232 adapter
- PIC16F883 circuit with 4 MHz crystal
- MAX232 or equivalent RS-232 transceiver and required capacitors
- potentiometer
- LM34 temperature sensor
- one servo for Part 4; three servos total for optional Mastery
- breadboard, jumpers, and various components as needed.
- lab book

[Back to top](#top)

<a id="part-1"></a>
## Part 1 - UART TX and RS-232 Proof of Life

### Goal

Configure the PIC16F883 EUSART for 9600 baud, 8N1, and continuously transmit a selected byte. Predict and measure its bit pattern, timing, and voltage levels on both the PIC UART and RS-232 signals.

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

Use the baud-rate-generator settings you select to calculate the expected actual baud rate and error. Measure actual bit time on the oscilloscope and calculate measured baud rate:

```math
\text{baud}_{\text{measured}}
=
\frac{1}{T_{\text{bit measured}}}
```

#### Worked example: baud-rate generator and error at 9600 baud

**What:** calculate the baud-rate generator setting, actual baud rate, and percentage error.

**Why:** the integer baud-rate setting causes the actual rate to differ slightly from the target.

For a 4 MHz oscillator with the 8-bit high-speed asynchronous generator, the data sheet gives a divisor of 16. Let \(n\) be the generator setting:

```math
\begin{aligned}
n &= \frac{F_{OSC}}{16B_{\text{target}}}-1 \\
  &= \frac{4{,}000{,}000}{16(9600)}-1 \\
  &= 25.0417 \\
  &\rightarrow 25
\end{aligned}
```

Calculate the actual baud rate:

```math
\begin{aligned}
B_{\text{actual}} &= \frac{F_{OSC}}{16(n+1)} \\
 &= \frac{4{,}000{,}000}{16(25+1)} \\
 &= 9615.38\,\text{baud}
\end{aligned}
```

Calculate the percentage error relative to the target:

```math
\begin{aligned}
\text{Error} &= \frac{B_{\text{actual}}-B_{\text{target}}}{B_{\text{target}}}\times100\% \\
 &= \frac{9615.38-9600}{9600}\times100\% \\
 &= +0.16\%
\end{aligned}
```

#### Worked example: custom baud rate

**What:** calculate a generator setting and error for a different target of 12,000 baud.

**Why:** this method also works when a nonstandard baud rate is needed.

Using the same oscillator and generator mode:

```math
\begin{aligned}
n &= \frac{4{,}000{,}000}{16(12{,}000)}-1 \\
 &= 19.8333 \\
 &\rightarrow 20 \\
B_{\text{actual}} &= \frac{4{,}000{,}000}{16(20+1)} \\
 &= 11{,}904.76\,\text{baud} \\
\text{Error} &= \frac{11{,}904.76-12{,}000}{12{,}000}\times100\% \\
 &= -0.79\%
\end{aligned}
```

Use the target of 9600 baud for Part 1. The custom-rate example illustrates the calculation for a different requirement.
At RC6/TX, UART idle and stop levels are HIGH, and the start bit is LOW. The MAX232 inverts these levels: RS-232 idle and stop are negative voltages, while the start bit is positive. Data bits are sent least significant bit first. With continuous transmission, the stop bit returns the line to its idle level, but there may be no additional idle gap.

### Required setup

```text
Baud rate generator:
    use the 8-bit baud rate generator
    select an asynchronous baud-rate generation speed that
        achieves 9600 baud with acceptable error at 4 MHz

EUSART transmitter:
    select asynchronous operation
    select 8-bit transmission
    enable the serial port
    enable the transmitter
```

### Program structure

```text
main:
    wait until the transmit buffer is available
    transmit the selected byte
    optionally delay between transmissions
    repeat
```
### Before Lab

Prepare or reference:

- EUSART SFR documentation for `TXSTA`, `RCSTA`, `BAUDCTL`, `SPBRG`, `TXREG`, and relevant `PIR1` flags;
- baud-generator setting, calculated actual baud rate, and percentage error for 9600 baud at your actual oscillator frequency;
- explanation of 8N1 and predicted bit/byte time;
- predicted start, D0-D7 (LSB first), and stop levels for `$ = 0x24` and contrasting test bytes;
- expected idle/start polarity and voltages on both TTL and RS-232;
- MAX232/adapter schematic, electrical-loading/component verification, and required capacitor values and voltage ratings;
- a test plan for each TTL-to-RS-232 driver and RS-232-to-TTL receiver channel;
- program flowchart and source.

### In the Lab

1. Build the MAX232 level-converter circuit with the required charge-pump capacitors. Verify the connections and component ratings.
2. Test every TTL-to-RS-232 driver channel and every RS-232-to-TTL receiver channel independently using appropriate signals. Measure the voltage levels and verify the polarity of each channel.
3. Configure asynchronous EUSART transmission at 9600 baud, 8N1, and repeatedly transmit a selected byte, starting with `$` (`0x24`).
4. You may add a delay between transmissions of approximately one byte time. Its exact duration is not critical; the pause makes triggering and capturing the waveform easier.
5. Display RC6/TX (TTL) and the corresponding MAX232 RS-232 output on separate oscilloscope channels at the same time.
6. Identify the start bit, D0 through D7, and stop bit directly from the waveforms. Compare the observed sequence with your prediction.
7. Try other repeated bytes such as `0xFF`, `0x00`, `0x55`, `0xAA`, `0xF7`, `0x08`, or another useful test value. Record the predicted and observed bit sequences.
8. Choose the clearest pattern for a scope capture. Adjust the timebase so **one complete 10-bit frame fills as much of the screen as possible**, with both traces visible and the start/stop boundaries intact.
9. On that capture, identify **start, D0-D7, and stop** for both TTL and RS-232. Mark the bit time clearly.
10. Measure bit time and complete frame time. Calculate measured baud rate and verify that the frame occupies 10 bit-times.
11. Measure and record the TTL and RS-232 voltages for idle, start, and data levels. Explain the polarity change between the two signals.

### Evidence

Include or reference:

- EUSART SFR documentation, MAX232 circuit/component verification, and results for each driver and receiver channel;
- predicted and observed bit patterns for the bytes tested, including LSB-first order;
- baud-generator setting, calculated baud rate and percentage error, bit-time, frame-time, and measured-baud calculations;
- **at least one scope capture showing TTL and RS-232 simultaneously**, scaled around one complete byte and labeled with start, D0-D7, stop, and bit time;
- measured and labeled idle/start/data voltages and an explanation of TTL versus RS-232 polarity;
- final Part 1 source.

### Demonstrate

Show repeated byte transmission at both measurement points, along with independent test results for each converter channel.

Explain 8N1, LSB-first transmission, each bit's position in the captured frame, the measured baud rate, and the idle/start/stop logic levels and voltage polarities for both TTL and RS-232.

### Complete When

Part 1 is complete when every converter channel operates correctly, the predicted bit pattern agrees with both measured waveforms, the complete 10-bit frame and baud rate are verified, and the TTL/RS-232 logic levels are explained.

[Back to top](#top)

<a id="part-2"></a>
## Part 2 - UART RX and Byte Echo

### Goal

Receive one byte from the host and immediately transmit the same byte back.

### Receive service time

The PIC16F883 receiver buffers two unread characters. Calculate the available service time for continuous back-to-back traffic.

Use your measured byte time from Part 1:

```math
\begin{aligned}
T_{\text{two-byte window}}
&\approx 2T_{\text{byte}} \\
&\approx 2(1.0417\,\text{ms}) \\
&\approx 2.083\,\text{ms}
\end{aligned}
```

Two byte-times is the approximate window after the first unread byte is received. Service RX at least once per character time, preferably more often.

### Required RAM

```text
rx_byte:        most recently received byte
tx_byte:        byte waiting for transmission
rx_ready:       flag indicating a byte is ready for processing
tx_pending:     flag indicating a byte is waiting to be sent
```

### Required setup

```text
EUSART receiver:
    use the Part 1 9600 baud, 8N1 configuration
    enable continuous reception of 8-bit data

Diagnostic output:
    configure an unused pin as a digital output

Startup:
    clear rx_ready and tx_pending
    start with the diagnostic output LOW
```

### Program structure

```text
main:
    call ServiceRx
    call ProcessEcho
    call ServiceTx
    repeat

ServiceRx:
    set the diagnostic output HIGH, then LOW
    if rx_ready is set, return
    if no byte has arrived, return
    read the received byte into rx_byte
    set rx_ready

ProcessEcho:
    if rx_ready is clear, return
    if tx_pending is set, return
    copy rx_byte into tx_byte
    clear rx_ready
    set tx_pending

ServiceTx:
    if tx_pending is clear, return
    if the transmit buffer is not available, return
    transmit tx_byte
    clear tx_pending
```

The short pulse at the beginning of `ServiceRx` marks each receive-service check. Measure the time between consecutive pulse edges while the host sends back-to-back bytes. Compare the longest observed interval with your measured byte time and the two-byte receive window above.

### Before Lab

Prepare or reference:

- `RCSTA.CREN`, `PIR1.RCIF`, `RCREG`, and the TX registers and flags used for echo;
- receive FIFO/service-time calculation using your measured byte time;
- diagnostic output pin selection and scope connection;
- RX, echo-processing, and TX flowchart and source.

### In the Lab

1. Send a single byte from the host and verify that the PIC echoes it unchanged.
2. Probe PIC RC7/RX and RC6/TX on separate oscilloscope channels. Trigger on the RX start bit and capture both the received and echoed frames in a single acquisition.
3. Compare the two frames and measure their bit times and the delay between the RX and TX start bits.
4. Send several ASCII and binary byte values. Confirm that the host receives exactly the values it sent.
5. Probe the diagnostic output while sending back-to-back bytes. Measure the longest interval between consecutive `ServiceRx` pulses and compare it with your measured byte time and two-byte receive window.
6. Enable serial decoding for both oscilloscope channels at 9600 baud, 8N1. Compare the decoded RX and TX bytes.
7. Experiment with hexadecimal, ASCII, and binary decoder displays, then try start-bit and data-byte trigger settings.
8. Configure the oscilloscope to capture and decode RX and TX at both the TTL and RS-232 interfaces. Record the probe locations, trigger settings, decoder settings, and signal polarity for each interface.

### Evidence

Include or reference:

- receive-service calculation;
- RX, echo-processing, and TX flowchart and final source;
- diagnostic-output capture showing the measured `ServiceRx` check interval compared with byte time and the receive window;
- a scope capture of an echoed byte on RC7/RX and RC6/TX, with timing measurements and serial decode;
- scope captures showing successful decoding at TTL and RS-232 levels, with probe locations, trigger settings, decoder settings, and signal polarity for each;
- host terminal output or log showing the bytes sent and received for several ASCII and binary values, with matching values clearly identified.

### Demonstrate

Use the host program to send several ASCII and binary byte values and show that every echoed byte matches the transmitted byte. Demonstrate RX/TX capture and serial decoding at both TTL and RS-232 levels.

Explain the RX/TX timing, measured interval between receive-service checks, comparison with the receive-service time budget, and oscilloscope trigger, decoder, and polarity settings used for each interface.

### Complete When

Part 2 is complete when bytes echo correctly, the receive-service interval is measured and compared with the timing budget, the host results match the scope measurements, and both TTL and RS-232 signals can be captured and decoded.

[Back to top](#top)

<a id="part-3"></a>
## Part 3 - Structured Packets and ADC Data

> **Instructions under revision:** This part is still being edited. Refresh your browser to check for updates and/or see your instructor before continuing.

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

Some invalid requests may receive no response. Consider how a host program could recognize a missing response rather than waiting indefinitely.

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

Each example shows the labeled fields and the actual hexadecimal bytes. `HH`, `LL`, and `DD` represent variable data bytes.

#### Device identification

```text
Request fields:   $ I 0
Request hex:      24 49 00

Response fields:  $ I 2 0x33 0x75
Response hex:     24 49 02 33 75
```

The required device ID for this lab is `0x3375`.

#### AN0 analog channel

```text
Request fields:   $ A 1 CHANNEL
Request hex:      24 41 01 00

Response fields:  $ A 3 CHANNEL ADC_H ADC_L
Response hex:     24 41 03 00 HH LL

Example response for ADC = 0x02AB:
                   24 41 03 00 02 AB
```

`CHANNEL = 0x00` selects AN0. `ADC_H:ADC_L` carries the complete right-justified 10-bit ADC result, high byte first.

#### Receive error

```text
Response fields:  $ E 2 ERROR_CODE DETAIL
Response hex:     24 45 02 EE DD

Framing example:  24 45 02 01 00
Overrun response: 24 45 02 02 00
```

`ERROR_CODE = 0x01` indicates a framing error; `0x02` indicates receive overrun. The framing example shows a received byte of `0x00` as its detail. For a framing error, `DETAIL` may contain the affected received byte; for overrun, `DETAIL = 0x00`.

After a framing or overrun error, discard the current partial packet and return the parser to waiting for `$`. The host may resend its last complete command packet.

### Required RAM

```text
rx_byte:         last received byte
rx_state:        WAIT_START, GET_COMMAND, GET_LENGTH, GET_DATA
rx_command:      requested command
rx_length:       expected payload bytes
rx_count:        payload bytes collected
rx_data[0..7]:   indexed received payload
tx_length:       complete response size
tx_count:        response bytes sent to TX hardware
tx_data[0..10]:  indexed response packet
reply_pending:   none, ID, or ADC
error_code:      pending error, or none
error_detail:    detail for pending error
```

### Required setup

```text
EUSART:
    continue Part 2 operation at 9600 baud, asynchronous 8N1

ADC:
    reuse and adapt the working Lab 07 ADC setup and routines
    use AN0

Diagnostic output:
    retain the Part 2 receive-service diagnostic output

Startup:
    reset parser, counters, replies, and error information
    prepare indexed access to both packet buffers
    start with the receive-service diagnostic output LOW
```

### Program structure

```text
main:
    call ServiceRx
    call ServiceReply
    call ServiceTx
    repeat

ServiceRx:
    pulse the receive-service diagnostic output HIGH, then LOW
    if no byte is available, return
    if receive overrun:
        reset the receiver
        call QueueError with overrun code and detail 0x00
        return
    if framing error:
        read and discard the affected byte
        call QueueError with framing code and affected byte
        return
    read one byte into rx_byte
    if an error is queued, discard this byte and return
    call ParseRxByte
    return

QueueError:
    reset parser to WAIT_START
    cancel the pending normal reply
    save the error code and detail
    return

ParseRxByte:
    WAIT_START:
        if rx_byte is '$', advance to GET_COMMAND
    GET_COMMAND:
        save command and advance to GET_LENGTH
    GET_LENGTH:
        save length and clear payload count
        if length > 8, reset parser and return
        if length = 0, call ProcessPacket and return
        advance to GET_DATA
    GET_DATA:
        store rx_byte in rx_data[count] and increment count
        if count = length, call ProcessPacket
    return

ProcessPacket:
    reset parser to WAIT_START
    if a normal reply is pending, return
    if ID request has length 0, mark ID reply pending
    if ADC request has length 1 and channel AN0:
        start conversion using the working Lab 07 ADC routine
        mark ADC reply pending
    return

ServiceReply:
    if unsent bytes remain in TX buffer, return
    if error pending, call BuildErrorResponse and return
    if ID reply pending, call BuildIdResponse and return
    if ADC reply pending:
        if conversion is still running, return
        call BuildAdcResponse
    return

BuildErrorResponse:
    prepare '$ E 2 ERROR_CODE DETAIL' in TX buffer
    initialize TX count and length; clear pending error
    return

BuildIdResponse:
    prepare '$ I 2 0x33 0x75' in TX buffer
    initialize TX count and length; clear pending reply
    return

BuildAdcResponse:
    read the full right-justified 10-bit result using Lab 07 routines
    prepare '$ A 3 0x00 ADC_H ADC_L' in TX buffer
    initialize TX count and length; clear pending reply
    return

ServiceTx:
    if no TX bytes remain or hardware is busy, return
    send next buffered byte and increment TX count
    return
```

### Before Lab

Prepare or reference:

- packet definitions and parser flowchart;
- packet-time calculations for each packet used in Part 3;
- parser RAM map, including the eight-byte RX buffer and TX buffer;
- `FSR/INDF` use for indexed buffer access;
- working Lab 07 ADC setup, acquisition, and result-reading routines for AN0 and the full right-justified 10-bit result;
- host program capable of sending the defined binary packets and displaying responses;
- source implementing Device ID, Analog Channel, framing error, and overrun error packets.

### In the Lab

1. Verify the Device ID request returns `0x3375`.
2. Turn the potentiometer and request AN0 repeatedly.
3. Verify the returned 10-bit value spans approximately 0 through 1023.
4. At several potentiometer settings, compare the returned ADC values with the voltage measured at AN0 using the verification method from Lab 07.
5. Use the Part 2 diagnostic output to measure the longest interval between `ServiceRx` checks while requesting AN0 data and transmitting replies. Compare it with the measured byte time and two-byte receive window from Part 2.
6. Temporarily delay receive servicing while the host sends at least three bytes back-to-back. Verify the overrun error response `$ E 2 0x02 0x00`. Remove the delay and confirm that a valid command succeeds after recovery.
7. Test framing-error handling with a baud mismatch. For example, keep the PIC at 9600 baud, set the host to 4800 baud, and send `0x00`. Use the oscilloscope decoder at 9600 baud to check for the PIC's `$ E 2 0x01 DETAIL` response. Restore the host to 9600 baud and confirm that a valid command succeeds.

### Evidence

Include or reference:

- packet table and packet-time calculations;
- parser flowchart and RAM map;
- final PIC source and host source;
- Device ID request/response capture;
- several Analog Channel requests and responses, including the actual hex bytes;
- ADC value versus DMM voltage comparison using the Lab 07 method;
- receive-service diagnostic capture and measured longest check interval compared with the Part 2 timing budget;
- receive-error/recovery evidence.

### Demonstrate

Request the Device ID and live AN0 data from the host.

Show the receive-service diagnostic output while packets are processed and replies transmitted. Explain how `LENGTH` controls parsing, why packet duration is different from the RX service deadline, how `rx_state` advances one byte at a time, and how the ADC response remains nonblocking.

### Complete When

Part 3 is complete when the host can request Device ID and full 10-bit AN0 data using the defined packet protocol, receive-service timing is verified, and the PIC can recover cleanly from receive errors.

[Back to top](#top)

<a id="part-4"></a>
## Part 4 - LM34, UART, and Servo Integration

> **Instructions under revision:** This part is still being edited. Refresh your browser to check for updates and/or see your instructor before continuing.

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
- Part 3 packet parser, host program, and reused Lab 07 ADC routines;
- working Lab 07 Timer1/CCP servo code, SFR documentation, and 1 us/20 ms timing calculations;
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

[Back to top](#top)

<a id="part-5"></a>
## Part 5 - Mastery: Three-Servo Scheduler

> **Instructions under revision:** This part is still being edited. Refresh your browser to check for updates and/or see your instructor before continuing.

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

[Back to top](#top)

<a id="submission"></a>
## Submission and Checkoff

### Assignment repository structure

Keep the PIC firmware and host application in the same Git repository, with each project in its own directory. For a C# host application:

```text
RCET3375-Lab08-UART/
├── README.md
├── .gitignore
├── source/
│   ├── pic/
│   │   └── Lab08-UART.X/             # MPLAB X project and .S files
│   └── csharp/
│       └── Lab08Host/               # .csproj and .cs files
├── schematics/                       # editable schematic and export
├── documentation/                    # calculations and calibration records
├── evidence/
│   ├── oscilloscope/                 # captures and measurements
│   └── host/                         # terminal output and test results
└── lab-book/
    └── Lab08-Lab-Book.pdf
```

Preserve each project's normal structure and include the files needed to rebuild both programs. See the [Lab Standard](../LAB_STANDARD.md#assignment-repository-standard) for repository rules.

Before final checkoff:

1. complete Parts 1 through 4 and any attempted Mastery work;
2. push the complete assignment repository to GitHub;
3. include the MPLAB X project, host program, editable source, schematics, and required evidence;
4. scan the relevant lab-book pages into one readable, correctly oriented PDF under `lab-book/`;
5. verify a fresh clone contains enough information to reopen and rebuild the assignment.

Instructor checkoff includes the required demonstrations and explanations from each completed part.

[Back to top](#top)
