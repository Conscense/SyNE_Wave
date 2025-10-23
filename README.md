# SyNE Wave

SyNE Wave is the official mobile companion app for **SyNE (Synaptic Nodal Engine)** and **CoSyNE (Compact Synaptic Nodal Engine)** — two interconnected systems developed to create a **self-healing, AI-powered mesh communication network** that operates without internet or cellular infrastructure.

This app acts as the **user interface and control hub** of the system, allowing phones to connect directly to SyNE or CoSyNE nodes using **Bluetooth** or **Wi-Fi Direct**, then send and receive messages through a **LoRa-based wireless network** powered by **ESP32 microcontrollers**.

---

## About the Project

SyNE Wave was created as part of the research project:

> **“SyNE & CoSyNE: A Gateway for the Next Generation of Communication Services”**  
> Antique Vocational School (2024)

The study aims to revolutionize long-range communication by providing **decentralized, low-cost, and sustainable** connectivity — especially in remote or disaster-prone areas where traditional networks are unavailable.

---

## How It Works

1. The app connects the user’s smartphone to a SyNE or CoSyNE node via **Bluetooth** or **Wi-Fi Direct**.  
2. When a message is sent, the app converts it into a **data packet** and transfers it to the **ESP32**.  
3. The ESP32 sends the packet through the **LoRa transceiver**, broadcasting it to other nearby nodes.  
4. Each node automatically **relays or reroutes** the data until it reaches the destination.  
5. The recipient’s node sends the data back to their phone, where SyNE Wave **decodes and displays** the message.

This process allows real-time, offline communication even without signal towers or Wi-Fi.

---

## Key Features

- **Bluetooth/Wi-Fi Direct Pairing** – Connect your phone to SyNE or CoSyNE nodes seamlessly.  
- **Offline Messaging** – Send and receive messages through the mesh network without internet.  
- **Signal Monitoring** – Displays live connection strength and node status.  
- **Data Encryption** – Protects transmitted packets through secure encoding.  
- **AI-Assisted Routing** – Enables self-healing communication between nodes.  
- **Optimized for Solar Nodes** – Works with SyNE’s solar-powered design for continuous use.

---

## Technologies Used

| Category | Tools / Components |
|-----------|--------------------|
| **Microcontroller** | ESP32 |
| **Transceiver** | LoRa SX1276 |
| **Frameworks** | Arduino IDE, IntelliJ IDEA |
| **Languages** | Dart, C++ |
| **Connectivity** | Wi-Fi Direct |
| **Platform** | Android |

---

## Research Focus

This app and its companion hardware were evaluated based on the following criteria:

- Accuracy  
- User-Friendliness  
- Usability  
- Mesh Communication  
- Scalability  
- Latency  
- Encryption Reliability  
- Signal Integrity  

Results showed that the prototypes performed **efficiently and reliably**, demonstrating the potential of decentralized communication systems for real-world use.

---

## Project Team

**Researchers:**  
- Meltom Aligonsa  
- Audrey Marie Jacosalem  
- Aaliyah Czarielle Villasis  

**Adviser:**  
- Mrs. Rosalyn Porras  

**Institution:**  
Antique Vocational School, 2024

---

## License

This project is for **educational and research purposes only**.  
All rights reserved by the SyNE Project research team.

---

## Contact

For inquiries or collaboration:  
> syne.project.team@gmail.com *(example — replace if needed)*

---

> _“Connecting the disconnected — one node at a time.”_
