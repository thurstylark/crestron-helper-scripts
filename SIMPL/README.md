# SIMPL
## Examples and modules (in pseudocode)

Because any code written with Crestron's tools legally belongs to Crestron, I have created a pseudocode standard that can be used to express *theoretically* possible SIMPL Windows code. This should allow me to be a little more loose with my usage and licensing without as much risk.

I plan to eventually write a vim syntax highlighter for this standard to make it easier to write and use.



## Pseudocode Definitions:

### COMMENTS: Arbitrary strings that do not affect the function of the code
    # Lorem ipsum dolor sit amit

#### Where:
- `#`
  - Comment marker
  - Anything after this symbol should be ignored, and does not affect the code
  - Can be used at the beginning of a line to comment the whole line, or at the end of
     a line to add a comment to that specific line
- `####`
  - Block comment
  - Anything between the first instance and the next instance does not affect the code


### VARIABLES: Re-usable values
    $VARIABLE = value

#### Where:
- `$`
  - Variable definition symbol
  - Include this symbol in definition as well as when using it later for clarity
- `VARIABLE`
  - An arbitrary string to be used as the name of the variable
- ` = `
  - Variable or parameter setting
- `value`
  - Arbitrary string that should be assigned to the proceeding variable name



### DEVICES: Devices that exist in the system
    device-label = CNET[ID]: MODEL(in.inputname: d.SigName, out.outputname: d.SigName, parameter = value)

#### Where:
- `device-label`
  - Arbitrary label for the device
- `CNET`
  - The connection type used for the connection for this device
  - Use an appropriate truncated name for the type
    - `CNET` Cresnet
    - `ENET` Ethernet
    - `COM`  Serial/RS-232
    - `IR`   Infrared
  - Derive the connection type from the slot model name
    - `C2I-PRO3-IR8` == `IR`
    - `C2I-PRO3-IO8` == `IO`
- `ID`
  - The CID, IPID, or other applicable ID designator to use for this device
  - For COM and IR devices, use the port number associated with the proc's hardware
  - Others, use something appropriate
- `MODEL`
  - The model number of the device being controlled
  - For Crestron devices, use the full model number
  - For non-Crestron devices, use the manufacturer name and full model number
     separated by an underscore
    - `Panasonic_PT-RZ-750`
    - NOTE: Use exact model numbers. Include underscores if they exist. This is
       meant to be read by humans, after all.
- `in.inputname: d.SigName` | `out.outputname: d.SigName`
  - Input or output pin signal assignment
  - `in.` | `out.`
    - Pin type definition
  - `inputname` | `outputname`
    - The name of the input or output pin that the provided signal name is attached to
    - For clarity, use the pin name as it exists in SIMPL Windows
  - `d.SigName`
    - Signal
    - `d. | a. | s.`
      - Signal type definition
        - `d.` Digital
        - `a.` Analog
        - `s.` Serial
    - `SigName`
      - Name of the signal attached to the specified pin
- `parameter`
  - Name of the parameter according to SIMPL Windows
- `value`
  - Value to set for the corresponding parameter


### SYMBOLS: Modules or Logic Symbols
    symbol-name = SPEEDKEY(d.inputname: SigName, d.outputname: SigName, parameter = value)

- `symbol-name`
  - Arbitrary label for the symbol being defined
  - Use a string with no whitespace
  - This should be transposed into the symbol's comment with appropriate edits for readability.
- `SPEEDKEY`
  - Symbol name
  - If using a symbol directly, use its Speed Key as its name
  - If using a prototyped symbol, use the prototype name
    - See the PROTOTYPES section for details
- The remaining elements use the same definitions from the DEVICES section


### PROTOTYPES: Device or symbol with pre-defined common parameters
    >PROTO prototype-name = SPEEDKEY(parameter = value)

- `>PROTO`
  - Prototype definition marker
- `prototype-name`
  - Arbitrary name to which the following prototype will be assigned
  - To use this prototype, use the prototype name instead of the speed key when defining a symbol
- Every parameter set in this prototype is automatically copied to every instance of a symbol which was defined with the prototype name
- A parameter can be overridden by explicitly setting the option within the symbol definition
  - Example: `>PROTO foo = BAR(baz = bunk)`
    - `foo` is a copy of a symbol that has a speed key of `BAR`
    - `baz` is a parameter to the `BAR` symbol. The prototype sets `baz` to `bunk`
    - Every instance of this new prototype `foo` already has it's `baz` parameter set to `bunk`
  - `zoop = foo(baz = boop)`
    - `zoop` is an instance of the prototype `foo`. 
      - Without defining anything else, the value of `baz` is `bunk`
    - The value of `baz` is set to `boop`, but only in this specific instance of `foo` which, in this case, is named `zoop`
- The Prototype paradigm is simply here to make it easier to write less. Because this is psuedocode, a Prototype can be made of pretty much anything. See an example of this in `./CTI-P101_Brain_Teaser_1.psmw` in the definition of `stepper-1`
