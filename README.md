# AXI-protocol
this is a project to show the working of axi protocols to sort random numbers

A complete hardware subsystem implemented in Verilog that demonstrates AXI-Lite Slave Control Interface integration with an AXI-Stream Data Processing Pipeline. 

The system enables a control processor to write configuration registers (Start, Stop, Seed, Taps) over an AXI-Lite bus to drive a Linear Feedback Shift Register (LFSR) pseudo-random generator. The generated stream of numbers is processed by a Histogram Binner and stored in an AXI-Stream RAM buffer.

The subsystem consists of four core modules communicating over standardized ARM AMBA AXI4 interfaces:

```mermaid
graph TD
    subgraph AXI-Lite Register Domain
        CU[Control Unit / CPU] -->|AXI-Lite Write/Read| Slave_Bridge[AXI-Lite Slave Register Bridge]
    end
    subgraph AXI-Stream Processing Domain
        Slave_Bridge -->|Control Registers| LFSR[LFSR PRBS Generator]
        LFSR -->|AXI-Stream| Binner[AXI-Stream Histogram Binner]
        Binner -->|AXI-Stream| RAM[AXI-Stream RAM Buffer]
    end
