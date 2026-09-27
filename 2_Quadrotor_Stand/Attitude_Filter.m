function [d_phi_est, d_theta_est, P_est] = Attitude_Filter( ...
    P_est_old, phi_p, theta_p, psi_p, gyro, phi_m, theta_m, dt)

p = gyro(1);
q = gyro(2);
r = gyro(3);

%% Noise matrices

sigma_g = deg2rad(0.5);     
sigma_acc_ang = deg2rad(1.0); 

Q = sigma_g^2 * eye(3);
R = sigma_acc_ang^2 * eye(2);
H = eye(2);

%% Propagation phase

A = [(q*cos(phi_p)-r*sin(phi_p))*tan(theta_p), (r*cos(phi_p)+q*sin(phi_p))*(1+tan(theta_p)^2);
    (-r*cos(phi_p)-q*sin(phi_p)), 0];
B = [ 1, sin(phi_p)*tan(theta_p),  cos(phi_p)*tan(theta_p);
      0, cos(phi_p),              -sin(phi_p) ];

F = eye(2) + dt*A;
Gamma = dt*B;

P_prop = F*P_est_old*transpose(F) + Gamma*Q*transpose(Gamma);

%% Update phase

K = P_prop*transpose(H)*inv(H*P_prop*transpose(H)+R);

y_prop = [phi_p; theta_p];
y_mes = [phi_m; theta_m];
deltaz = y_mes - y_prop;
deltaz(1) = wrapToPi(deltaz(1));     % NEW — wrap roll residual only

P_est = (eye(2)-K*H) * P_prop * transpose(eye(2)-K*H) + K*R*transpose(K);

deltax_est =  K*deltaz;
d_phi_est =  deltax_est(1);
d_theta_est = deltax_est(2);

end