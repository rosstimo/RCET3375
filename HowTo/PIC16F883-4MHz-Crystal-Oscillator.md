# PIC16F883 4 MHz Crystal Oscillator

Use this guide when an RCET project uses the external 4 MHz crystal with the PIC16F883.

## Official references

- PIC16F882/883/884/886/887 Data Sheet: https://ww1.microchip.com/downloads/aemDocuments/documents/OTH/ProductDocuments/DataSheets/40001291H.pdf
- PICmicro Mid-Range MCU Family Reference Manual: https://ww1.microchip.com/downloads/en/DeviceDoc/33023A.pdf
- AN826, Crystal Oscillator Basics and Crystal Selection: https://ww1.microchip.com/downloads/en/appnotes/00826a.pdf
- AN849, Basic PICmicro Oscillator Design: https://ww1.microchip.com/downloads/en/appnotes/00849a.pdf
- AN949, Making Your Oscillator Work: https://ww1.microchip.com/downloads/en/appnotes/00949a.pdf

## Design procedure

Do not copy capacitor values from an example circuit without checking the actual crystal.

1. Identify the exact crystal part and its specified load capacitance, `CL`.
2. Use the PIC16F883 datasheet to select the oscillator mode appropriate for a 4 MHz crystal.
3. Connect the crystal between `OSC1/CLKIN` and `OSC2/CLKOUT` as shown in the device documentation.
4. Determine suitable load capacitors from the crystal specification and expected stray capacitance.
5. Determine whether any additional component is required for the specific crystal/circuit.
6. Keep the oscillator wiring short and close to the PIC.

For the common two-capacitor network, use the relationship provided by the crystal/oscillator documentation and show the calculation in the lab book. When the capacitors are equal, the result should still be based on the actual specified `CL` and a stated estimate for stray capacitance.

Record:

- crystal part number;
- specified `CL`;
- oscillator mode;
- equation used;
- stray-capacitance assumption;
- calculated capacitor values;
- selected standard values;
- datasheet/application-note references.

## Schematic

The KiCad schematic should show:

- PIC16F883 oscillator pins;
- the 4 MHz crystal;
- both load capacitors;
- ground connections;
- any additional oscillator component actually used.

Include the oscillator components in the assignment loading/component verification required by the [RCET 3375 Lab Standard](../LAB_STANDARD.md).

## Verification

After programming the device, verify that the oscillator starts and operates at approximately 4 MHz.

Use a measurement point and probe setup that does not unnecessarily load the oscillator circuit.

Record:

- measurement point;
- probe type/attenuation;
- expected frequency;
- measured frequency;
- whether the oscillator starts reliably;
- any troubleshooting required.

If the oscillator does not work, recheck the configuration bits, oscillator mode, physical connections, crystal specification, capacitor values, power, and reset circuit before changing unrelated code.
