# A Model-Based Attitude and Heading Reference System Utilizing a Bio-Inspired Polarized Sensor

This repository contains the source code, simulation data, and experimental test files associated with the paper **“A Model-Based Attitude and Heading Reference System Utilizing a Bio-Inspired Polarized Sensor.”** The paper proposes a framework that integrates a bio-inspired polarized skylight sensor to address the limitations of conventional attitude and heading reference systems.

The files related to the simulations and experimental tests are organized into the following four main sections:

1. **Simulation**
2. **Experimental Test on a 3-DOF Quadrotor Stand**
3. **Experimental Test with a PX4-Based Quadrotor Flight**
4. **Optimized Code for GPU Implementation (Real-Time Capability Analysis)**

---

## 1. Simulation

This section consists of three sub-modules.

### I. Data Generation

The `Data_Generartion_Realtime.ipynb` notebook is located in the **Data Generation** folder. It takes the CSV file located in the **Simulation_Data** folder as its input and generates the polarization data results.

The generated results are automatically saved in the **Simulation_Results** folder. This folder is **not included in the repository** because it contains generated data and can be recreated by running `Data_Generartion_Realtime.ipynb`.

### II. Heading (Psi) Measurement

The `Psi_Measurement.ipynb` notebook uses the simulation results generated in the **Data Generation** step as its input. It measures the heading angle and saves the resulting data in the **Results** folder.

### III. Model-Aided Navigation Simulation

To run the model-aided navigation simulation, first execute the `Initialization.m` script to provide the necessary inputs for the Simulink model `ModelAided_PAHRS.slx`.

The heading-angle measurements generated in the **Heading (Psi) Measurement** step are stored in the `yaw_mes.mat` file, which is loaded by `Initialization.m`.

After completing the initialization:

1. Run `ModelAided_PAHRS.slx`.
2. Execute `Results.m` to display the simulation outputs.

---

## 2. Experimental Test on a 3-DOF Quadrotor Stand

The main script for this section is `PAHRS.m`.

* **Input:** `PAHRS.m` loads the `test_data.mat` file internally.
* **Execution:** Run `PAHRS.m` first, followed by `Results.m` to visualize the outputs.
* **Note:** The MAHRS-related results are already provided in the `MAHRS_Results.mat` file.

---

## 3. Experimental Test with a PX4-Based Quadrotor Flight

The main script for this section is also `PAHRS.m`.

* **Input:** `PAHRS.m` loads the `log_data.mat` file internally.
* **Execution:** Run `PAHRS.m` first, followed by `Results.m` to visualize the outputs.
* **Note:** The MAHRS-related results are already provided in the `MAHRS_Results.mat` file.

---

## 4. Optimized Code for GPU Implementation (Real-Time Capability Analysis)

This section contains the optimized code used to evaluate real-time processing capabilities.

The `Psi_Measurement_Optimized.ipynb` notebook takes the `2026-06-17_19-34-06` folder as its input and is configured to run directly on a GPU.
