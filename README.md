
* **Computer 1:** Has 2 motes connected. We’ll program one mote as the beacon and the other as a receiver.
* **Computer 2:** Has 1 mote (receiver).
* **Computer 3:** Has 1 mote (receiver).

---

### **Common Preparations (Run on Each Computer)**

1. **Connect the motes to the computer.**

   Run:

   ```bash
   motelist
   ```

   to see the list of connected motes and note their device names (for example: `/dev/ttyUSB0`, `/dev/ttyUSB1`, etc.).
3. **Set permissions on the serial devices (if needed):**

   For each device you plan to use, run:

   ```bash
   sudo chmod 777 /dev/ttyUSB0
   ```

   (Replace `/dev/ttyUSB0` with the appropriate device file for that computer.)

---

### **On Computer 1 (2 Motes Connected: 1 Beacon, 1 Receiver)**

#### **A. Program the Beacon Mote**

1. **Change into the beacon project directory:**

   (Assuming you’ve created a folder called `RBSBeacon` with the following files: `RBS.h`, `RBSBeaconAppC.nc`, `RBSBeaconC.nc`, and a `Makefile`.)

   ```bash
   cd /path/to/RBSBeacon
   ```
2. **Compile the beacon application for the TelosB platform:**

   ```bash
   make telosb
   ```
3. **Install (flash) the beacon application to the mote on, say, `/dev/ttyUSB0`:**

   ```bash
   make telosb install,ttyUSB0
   ```

   *Note:* If you have more than one mote connected, verify the device name with `motelist`.

#### **B. Program the Receiver Mote**

1. **Change into the receiver project directory:**

   (Assuming you have a folder called `RBSReceiver` with the files: `RBS.h`, `RBSReceiverAppC.nc`, `RBSReceiverC.nc`, and a `Makefile`.)

   ```bash
   cd /path/to/RBSReceiver
   ```
2. **Compile the receiver application for TelosB:**

   ```bash
   make telosb
   ```
3. **Install the receiver application to the other mote on, for example, `/dev/ttyUSB1`:**

   ```bash
   make telosb install,ttyUSB1
   ```

---

### **On Computer 2 (1 Mote Connected – Receiver Only)**

1. **Change into the receiver project directory:**
   ```bash
   cd /path/to/RBSReceiver
   ```
2. **Compile the receiver application:**
   ```bash
   make telosb
   ```
3. **Install the receiver application to the mote (typically on `/dev/ttyUSB0` on this computer):**
   ```bash
   make telosb install,ttyUSB0
   ```

---

### **On Computer 3 (1 Mote Connected – Receiver Only)**

1. **Change into the receiver project directory:**
   ```bash
   cd /path/to/RBSReceiver
   ```
2. **Compile the receiver application:**
   ```bash
   make telosb
   ```
3. **Install the receiver application to the mote (again, likely `/dev/ttyUSB0` on this computer):**
   ```bash
   make telosb install,ttyUSB0
   ```

---

### **After Programming – Monitoring and Testing**

1. **Use a Serial Debug Tool:**

   Open a serial monitor (for example, moseria) on the receiver motes’ ports to see debug output. 

   The receiver application uses the `dbg()` function (via the dbg.h interface) to print the calculated offset. You should see output similar to:

   ```
   RBSReceiver: Offset: 15 ms
   ```

   which indicates the difference between the local time and the beacon’s broadcast time.
2. **Verify Synchronization:**

   When the beacon mote’s timer fires (every 1 second in our example), it broadcasts its current time. Each receiver then reads its own clock and calculates the offset. Adjust your setup if you want to see different timing behavior.

---

### **Notes**

* The build system automatically creates a `build/telosb` folder (with files like `main.exe`, `main.ihex`, and `tos_image.xml`) when you run the `make` command. You do not need to create these manually.
