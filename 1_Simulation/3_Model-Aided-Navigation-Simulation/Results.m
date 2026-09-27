
clc
close all

%% Plots

% w_x
figure(1)
plot(out.tout, out.gyroscope_x,  'k-','MarkerSize',10,'linewidth',0.7);
hold off
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel(' $\tilde{p} (rad/sec) $','interpreter','latex');

% w_y
figure(2)
plot(out.tout, out.gyroscope_y,  'k-','MarkerSize',10,'linewidth',0.7);
hold off
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel(' $\tilde{q} (rad/sec) $','interpreter','latex');

% w_z
figure(3)
plot(out.tout, out.gyroscope_z,  'k-','MarkerSize',10,'linewidth',0.7);
hold off
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel(' $\tilde{r} (rad/sec) $','interpreter','latex');

% a_x
figure(4)
plot(out.tout, out.accelerometer_x,  'k-','MarkerSize',10,'linewidth',0.7);
hold off
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel(' $\tilde{a}_x (m/(sec^2)) $','interpreter','latex');

% a_y
figure(5)
plot(out.tout, out.accelerometer_y,  'k-','MarkerSize',10,'linewidth',0.7);
hold off
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel(' $\tilde{a}_y (m/(sec^2)) $','interpreter','latex');

% a_z
figure(6)
plot(out.tout, out.accelerometer_z,  'k-','MarkerSize',10,'linewidth',0.7);
hold off
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel(' $\tilde{a}_z (m/(sec^2)) $','interpreter','latex');

% f_x
figure(7)
plot(out.tout, out.f_x,  'k-','MarkerSize',10,'linewidth',0.7);
hold off
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel(' $f_x (N) $','interpreter','latex');

% f_y
figure(8)
plot(out.tout, out.f_y,  'k-','MarkerSize',10,'linewidth',0.7);
hold off
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel(' $f_y (N) $','interpreter','latex');

% f_z
figure(9)
plot(out.tout, out.f_z,  'k-','MarkerSize',10,'linewidth',0.7);
hold off
set(gca,'FontSize',50); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel(' $f_z (N) $','interpreter','latex');

% phi
figure(10)
plot(out.tout, out.phi_true,  'c-','MarkerSize',10,'linewidth',0.7);
hold on
plot(out.tout(2:15:end), out.phi_gyro(2:15:end),  'r:','MarkerSize',10,'linewidth',0.7);
plot(out.tout(1:35:end), out.phi_gravity(1:35:end),  'b-.','MarkerSize',10,'linewidth',0.7);
plot(out.tout(1:50:end), out.phi_hat(1:50:end),  'k-','MarkerSize',10,'linewidth',0.7);
set(gca,'FontSize',20); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel(' $\phi (deg) $','interpreter','latex');
legend("True", "Gyroscope-only", "Gravity-only", "PAHRS")
axis([0 300 -30 50])
hold off

% theta
figure(11)
plot(out.tout, out.theta_true,  'c-','MarkerSize',10,'linewidth',0.7);
hold on
plot(out.tout(1:15:end), out.theta_gyro(1:15:end),  'r:','MarkerSize',10,'linewidth',0.7);
plot(out.tout(1:35:end), out.theta_gravity(1:35:end),  'b-.','MarkerSize',10,'linewidth',0.7);
plot(out.tout(1:50:end), out.theta_hat(1:50:end),  'k-','MarkerSize',10,'linewidth',0.7);
set(gca,'FontSize',20); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel(' $\theta (deg) $','interpreter','latex');
legend("True", "Gyroscope-only", "Gravity-only", "PAHRS")
axis([0 300 -10 40])
hold off

% psi
figure(12)
plot(out.tout, out.psi_true,  'c-','MarkerSize',10,'linewidth',0.7);
hold on
plot(out.tout(1:15:end), out.psi_gyro(1:15:end),  'r:','MarkerSize',10,'linewidth',0.7);
plot(out.tout(1:35:end), out.psi_gravity(1:35:end),  'b-.','MarkerSize',10,'linewidth',0.7);
plot(out.tout(1:50:end), out.psi_hat(1:50:end),  'k-','MarkerSize',10,'linewidth',0.7);
set(gca,'FontSize',20); 
set(gcf,'Color','White');
xlabel('$time (sec)$','interpreter','latex');
ylabel(' $\psi (deg) $','interpreter','latex');
legend("True", "Gyroscope-only", "Gravity-only", "PAHRS")
axis([0 300 -30 160])
hold off

%% RMSE Calculations

% Calculate RMSE for Phi
rmse_phi_gyro    = calcRMSE(out.phi_true, out.phi_gyro);
rmse_phi_gravity = calcRMSE(out.phi_true, out.phi_gravity);
rmse_phi_hat     = calcRMSE(out.phi_true, out.phi_hat);

% Calculate RMSE for Theta
rmse_theta_gyro    = calcRMSE(out.theta_true, out.theta_gyro);
rmse_theta_gravity = calcRMSE(out.theta_true, out.theta_gravity);
rmse_theta_hat     = calcRMSE(out.theta_true, out.theta_hat);

% Calculate RMSE for Psi
rmse_psi_gyro    = calcRMSE(out.psi_true, out.psi_gyro);
rmse_psi_gravity = calcRMSE(out.psi_true, out.psi_gravity);
rmse_psi_hat     = calcRMSE(out.psi_true, out.psi_hat);

% Print the results to the Command Window
fprintf('\n================ RMSE Results ================\n');

fprintf('Phi (Roll):\n');
fprintf('  Gyroscope : %.4f deg\n', rmse_phi_gyro);
fprintf('  Gravity   : %.4f deg\n', rmse_phi_gravity);
fprintf('  Proposed  : %.4f deg\n\n', rmse_phi_hat);

fprintf('Theta (Pitch):\n');
fprintf('  Gyroscope : %.4f deg\n', rmse_theta_gyro);
fprintf('  Gravity   : %.4f deg\n', rmse_theta_gravity);
fprintf('  Proposed  : %.4f deg\n\n', rmse_theta_hat);

fprintf('Psi (Yaw):\n');
fprintf('  Gyroscope : %.4f deg\n', rmse_psi_gyro);
fprintf('  Gravity   : %.4f deg\n', rmse_psi_gravity);
fprintf('  Proposed  : %.4f deg\n', rmse_psi_hat);
fprintf('==============================================\n\n');


%% --- Local Functions ---

function rmse = calcRMSE(reference, estimate)
% calcRMSE Calculate the Root Mean Square Error between two vectors
%
%   rmse = calcRMSE(reference, estimate)
%
%   reference : reference vector (ground truth)
%   estimate  : vector to compare against the reference
%   rmse      : root mean square error

    % Check that vectors have the same number of elements
    if numel(reference) ~= numel(estimate)
        error('Input vectors must have the same number of elements.');
    end

    % Convert to column vectors
    reference = reference(:);
    estimate = estimate(:);

    % Calculate RMSE
    rmse = sqrt(mean((reference - estimate).^2));
end
