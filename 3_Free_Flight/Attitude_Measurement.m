function [phi_mes, theta_mes] = Attitude_Measurement(acc, g, v_ned, v_ned_prev, dt, gyro, phi, theta, psi, phi_prev, theta_prev, psi_prev)

% 1. Create DCM for Current Step (NED to Body)
c_phi = cos(phi); s_phi = sin(phi);
c_theta = cos(theta); s_theta = sin(theta);
c_psi = cos(psi); s_psi = sin(psi);

R_x = [1 0 0; 0 c_phi s_phi; 0 -s_phi c_phi];
R_y = [c_theta 0 -s_theta; 0 1 0; s_theta 0 c_theta];
R_z = [c_psi s_psi 0; -s_psi c_psi 0; 0 0 1];
C_n2b = R_x * R_y * R_z;

% 2. Create DCM for Previous Step (NED to Body)
c_phi_p = cos(phi_prev); s_phi_p = sin(phi_prev);
c_theta_p = cos(theta_prev); s_theta_p = sin(theta_prev);
c_psi_p = cos(psi_prev); s_psi_p = sin(psi_prev);

R_x_p = [1 0 0; 0 c_phi_p s_phi_p; 0 -s_phi_p c_phi_p];
R_y_p = [c_theta_p 0 -s_theta_p; 0 1 0; s_theta_p 0 c_theta_p];
R_z_p = [c_psi_p s_psi_p 0; -s_psi_p c_psi_p 0; 0 0 1];
C_n2b_prev = R_x_p * R_y_p * R_z_p;

% 3. Transform NED Velocities to Body Velocities
v_b = C_n2b * v_ned';
v_b_prev = C_n2b_prev * v_ned_prev';

% Extract u, v, w for the current step
u = v_b(1);
v = v_b(2);
w = v_b(3);

% 4. Calculate Numerical Derivatives (udot, vdot, wdot)
v_dot = (v_b - v_b_prev) / dt;
u_dot = v_dot(1);
v_dot_y = v_dot(2);
w_dot = v_dot(3);

% Extract Accelerometer and Gyroscope Data
ax = acc(1); ay = acc(2); az = acc(3);
p = gyro(1); q = gyro(2); r = gyro(3);

% 5. Apply the Correction Formulas

% Pitch (Theta) Calculation
% Limit the input to asin() to [-1, 1] to prevent imaginary outputs from sensor spikes
theta_val = (ax - u_dot + (r*v - q*w)) / g;
theta_val = max(min(theta_val, 1), -1);
theta_mes = asin(theta_val);

% Roll (Phi) Calculation
num_phi = -(ay - v_dot_y + (-r*u + p*w));
den_phi = -(az - w_dot + (q*u - p*v));
phi_mes = atan2(num_phi, den_phi);

end