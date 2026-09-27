% Plot Data

load('MAHRS_Results.mat')

%% Gyroscope

figure(1)
plot(time_imu, acc(:,1),  'k-','MarkerSize',10,'linewidth',0.7);
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel('$\tilde{a_x} (m/(s^2))$','interpreter','latex');
hold off

figure(2)
plot(time_imu, acc(:,2),  'k-','MarkerSize',10,'linewidth',0.7);
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel('$\tilde{a_y} (m/(s^2))$','interpreter','latex');
hold off

figure(3)
plot(time_imu, acc(:,3),  'k-','MarkerSize',10,'linewidth',0.7);
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel('$\tilde{a_z} (m/(s^2))$','interpreter','latex');
hold off

%% Accelerometer

figure(4)
plot(time_imu, gyro(:,1),  'k-','MarkerSize',10,'linewidth',0.7);
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel('$\tilde{p} (deg/s)$','interpreter','latex');
hold off

figure(5)
plot(time_imu, gyro(:,2),  'k-','MarkerSize',10,'linewidth',0.7);
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel('$\tilde{q} (deg/s)$','interpreter','latex');
hold off

figure(6)
plot(time_imu, gyro(:,3),  'k-','MarkerSize',10,'linewidth',0.7);
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel('$\tilde{r} (deg/s)$','interpreter','latex');
hold off

%% Phi

figure(7)

plot(time_imu, wrapTo180(rad2deg(euler(:,1))-180), 'c-', 'LineWidth', 0.7);
hold on
plot(time_imu(2:15:end), wrapTo180(rad2deg(phi_m(2:15:end))-180), 'r:', 'LineWidth', 0.7);
plot(time_est_MAHRS(1:35:end), wrapTo180(rad2deg(phi_est_MAHRS(1:35:end))-180), 'b-.', 'LineWidth', 0.7);
plot(time_est(1:50:end), wrapTo180(rad2deg(phi_est(1:50:end))-180), 'k--', 'LineWidth', 0.7);

set(gca,'FontSize',20,'Layer','top'); box on
set(gcf,'Color','White');
xlabel('$time\,(sec)$','interpreter','latex');
ylabel('$\phi\,(deg)$','interpreter','latex');
legend("Reference", "Measurement", "MAHRS", "PAHRS")

axis([0 313 -6 16])

hold off

%% Theta

figure(8)

plot(time_imu, (rad2deg(euler(:,2))), 'c-', 'LineWidth', 0.7);
hold on
plot(time_imu(2:15:end), (rad2deg(theta_m(2:15:end))), 'r:', 'LineWidth', 0.7);
plot(time_est_MAHRS(1:35:end), (rad2deg(theta_est_MAHRS(1:35:end))), 'b-.', 'LineWidth', 0.7);
plot(time_est(1:50:end), (rad2deg(theta_est(1:50:end))), 'k--', 'LineWidth', 0.7);

set(gca,'FontSize',20); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel('$\theta (deg)$','interpreter','latex');
legend("Reference", "Measurement", "MAHRS", "PAHRS")

axis([0 313 -6 13])

hold off

%% Psi

figure(9)

plot(time_imu, (rad2deg(euler(:,3))), 'c-', 'LineWidth', 0.7);
hold on
plot(time_pol, (rad2deg(psi_m)), 'r:', 'LineWidth', 0.7);
plot(time_est_MAHRS(1:35:end), (rad2deg(psi_est_MAHRS(1:35:end))), 'b-.', 'LineWidth', 0.7);
plot(time_est(1:50:end), (rad2deg(psi_est(1:50:end))), 'k--', 'LineWidth', 0.7);

set(gca,'FontSize',20); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel('$\psi (deg)$','interpreter','latex');
legend("Reference", "Measurement", "MAHRS", "PAHRS")

axis([0 313 -100 220])

hold off

%% RMSE Calculation

% 1. Time Alignment
% Find unique time values in PAHRS to prevent the interp1 unique points error.
% This keeps the first occurrence of any duplicate timestamp.
[time_est_unique, unique_idx] = unique(time_est);
phi_est_unique   = phi_est(unique_idx);
theta_est_unique = theta_est(unique_idx);
psi_est_unique   = psi_est(unique_idx);

% Now interpolate using the unique arrays
phi_est_aligned   = interp1(time_est_unique, phi_est_unique, time_imu, 'nearest');
theta_est_aligned = interp1(time_est_unique, theta_est_unique, time_imu, 'nearest');
psi_est_aligned   = interp1(time_est_unique, psi_est_unique, time_imu, 'nearest');

% 2. Convert to Degrees and apply your specific plot wrapping
% Reference
ref_phi   = wrapTo180(rad2deg(euler(:,1)) - 180);
ref_theta = rad2deg(euler(:,2));
ref_psi   = rad2deg(euler(:,3));

% MAHRS
mahrs_phi   = wrapTo180(rad2deg(phi_est_MAHRS) - 180);
mahrs_theta = rad2deg(theta_est_MAHRS);
mahrs_psi   = rad2deg(psi_est_MAHRS);

% PAHRS (Aligned)
pahrs_phi   = wrapTo180(rad2deg(phi_est_aligned) - 180);
pahrs_theta = rad2deg(theta_est_aligned);
pahrs_psi   = rad2deg(psi_est_aligned);

% 3. Calculate Angular Error 
% We wrap the error itself to 180 so that a difference between 179 and -179 
% is correctly calculated as 2 degrees instead of 358 degrees.
err_mahrs_phi   = wrapTo180(mahrs_phi(:) - ref_phi(:));
err_mahrs_theta = wrapTo180(mahrs_theta(:) - ref_theta(:));
err_mahrs_psi   = wrapTo180(mahrs_psi(:) - ref_psi(:));

err_pahrs_phi   = wrapTo180(pahrs_phi(:) - ref_phi(:));
err_pahrs_theta = wrapTo180(pahrs_theta(:) - ref_theta(:));
err_pahrs_psi   = wrapTo180(pahrs_psi(:) - ref_psi(:));

% 4. Compute Final RMSE
rmse_mahrs_phi   = sqrt(mean(err_mahrs_phi.^2, 'omitnan'));
rmse_mahrs_theta = sqrt(mean(err_mahrs_theta.^2, 'omitnan'));
rmse_mahrs_psi   = sqrt(mean(err_mahrs_psi.^2, 'omitnan'));

rmse_pahrs_phi   = sqrt(mean(err_pahrs_phi.^2, 'omitnan'));
rmse_pahrs_theta = sqrt(mean(err_pahrs_theta.^2, 'omitnan'));
rmse_pahrs_psi   = sqrt(mean(err_pahrs_psi.^2, 'omitnan'));

% 5. Print Results to Command Window
fprintf('======================================\n');
fprintf('          RMSE RESULTS (deg)          \n');
fprintf('======================================\n');
fprintf('--- MAHRS ---\n');
fprintf('Phi   (Roll)  : %8.4f\n', rmse_mahrs_phi);
fprintf('Theta (Pitch) : %8.4f\n', rmse_mahrs_theta);
fprintf('Psi   (Yaw)   : %8.4f\n\n', rmse_mahrs_psi);

fprintf('--- PAHRS ---\n');
fprintf('Phi   (Roll)  : %8.4f\n', rmse_pahrs_phi);
fprintf('Theta (Pitch) : %8.4f\n', rmse_pahrs_theta);
fprintf('Psi   (Yaw)   : %8.4f\n', rmse_pahrs_psi);
fprintf('======================================\n');
