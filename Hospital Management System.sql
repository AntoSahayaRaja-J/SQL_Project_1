-- Creating Database
create database Hospital;
use Hospital;
-- Creating Tables
CREATE TABLE Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    phone_number VARCHAR(15),
    address TEXT,
    email VARCHAR(100) UNIQUE
);
CREATE TABLE Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15),
    email VARCHAR(100) UNIQUE
);
CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATETIME NOT NULL,
    status ENUM('Scheduled', 'Completed', 'Cancelled') NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);
-- Insert additional patients
INSERT INTO Patients (first_name, last_name, dob, gender, phone_number, address, email)
VALUES 
('John', 'Doe', '1985-06-15', 'Male', '555-1234', '123 Main St', 'john.doe@example.com'),
('Emily', 'Smith', '1988-11-05', 'Female', '555-2345', '789 Maple Ave', 'emily.smith@example.com'),
('Michael', 'Brown', '1972-02-20', 'Male', '555-3456', '101 Pine Rd', 'michael.brown@example.com'),
('Olivia', 'Williams', '1995-07-30', 'Female', '555-4567', '202 Oak St', 'olivia.williams@example.com'),
('James', 'Taylor', '1980-12-25', 'Male', '555-5678', '303 Cedar Dr', 'james.taylor@example.com'),
('Sophia', 'Davis', '1992-04-10', 'Female', '555-6789', '404 Birch Blvd', 'sophia.davis@example.com'),
('Daniel', 'Martinez', '1987-09-12', 'Male', '555-7890', '505 Spruce Ct', 'daniel.martinez@example.com');
-- Insert additional doctors
INSERT INTO Doctors (first_name, last_name, specialization, phone_number, email)
VALUES 
('Dr. Sarah', 'Miller', 'Cardiology', '555-8765', 'sarah.miller@example.com'),
('Dr. David', 'Wilson', 'Orthopedics', '555-9876', 'david.wilson@example.com'),
('Dr. Laura', 'Moore', 'Neurology', '555-1357', 'laura.moore@example.com'),
('Dr. Brian', 'Taylor', 'Dermatology', '555-2468', 'brian.taylor@example.com'),
('Dr. Amy', 'Anderson', 'Oncology', '555-3579', 'amy.anderson@example.com'),
('Dr. Kevin', 'Thomas', 'General Medicine', '555-4680', 'kevin.thomas@example.com'),
('Dr. Natalie', 'Lee', 'Gynecology', '555-5791', 'natalie.lee@example.com');
-- Schedule additional appointments
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status)
VALUES 
(1, 2, '2024-09-11 14:00:00', 'Scheduled'),
(2, 3, '2024-09-12 09:00:00', 'Scheduled'),
(3, 4, '2024-09-13 11:00:00', 'Completed'),
(4, 5, '2024-09-14 15:00:00', 'Cancelled'),
(5, 6, '2024-09-15 10:00:00', 'Scheduled'),
(6, 7, '2024-09-16 13:00:00', 'Completed'),
(7, 1, '2024-09-17 16:00:00', 'Scheduled');
-- Retrieve All Patients
SELECT * FROM Patients;
-- Retrieve All Doctors
SELECT * FROM Doctors;
-- Retrieve All Appointments
SELECT * FROM Appointments;
-- Find Patients by Last Name
SELECT * FROM Patients
WHERE last_name = 'Smith';
-- Find Doctors by Specialization
SELECT * FROM Doctors
WHERE specialization = 'Cardiology';
-- Count of Appointments per Doctor
SELECT d.first_name, d.last_name, COUNT(a.appointment_id) AS appointment_count
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name;
-- Find Patients with No Upcoming Appointments
SELECT * FROM Patients
WHERE patient_id NOT IN (
    SELECT DISTINCT patient_id
    FROM Appointments
    WHERE appointment_date > NOW()
);
-- Get Doctor's Availability
SELECT DISTINCT d.first_name, d.last_name
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id
WHERE (a.appointment_date IS NULL OR a.appointment_date > NOW() + INTERVAL 7 DAY)
GROUP BY d.doctor_id, d.first_name, d.last_name;
-- Find Doctors with More Than 5 Appointments
SELECT d.first_name, d.last_name
FROM Doctors d
WHERE d.doctor_id IN (
    SELECT a.doctor_id
    FROM Appointments a
    GROUP BY a.doctor_id
    HAVING COUNT(a.appointment_id) > 5
);
delimiter //
-- To Create procedure
create procedure hospital()
Begin 
SELECT * FROM Patients;
SELECT * FROM Doctors;
SELECT * FROM Appointments;
End //
delimiter ;
DELIMITER //
-- Trigger to Automatically Update Status to 'Completed' After Appointment Date
CREATE TRIGGER AfterAppointmentDate
AFTER INSERT ON Appointments
FOR EACH ROW
BEGIN
    IF NEW.appointment_date < NOW() THEN
        UPDATE Appointments
        SET status = 'Completed'
        WHERE appointment_id = NEW.appointment_id;
    END IF;
END //
DELIMITER ;
DELIMITER //
-- Trigger to Prevent Deletion of Patients with Future Appointments  
CREATE TRIGGER BeforePatientDelete
BEFORE DELETE ON Patients
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Appointments
        WHERE patient_id = OLD.patient_id
        AND appointment_date > NOW()
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete patient with future appointments';
    END IF;
END //
DELIMITER ;











