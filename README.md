# Buddi 
`Elderly Companion App`

Buddi is an elderly focused companion app that features big, clear buttons for essential functions (call, message, camera, clock, emergency). It also handles medication and hospital appointment reminders, track steps and keeps family members engaged through automated weekly email reports summarizing the user’s activity.

---
<br>

### Group Members

| Name       | Matric No | Assigned Tasks                                      |
|------------|-----------|----------------------------------------------------|
| ANIS NAZIRA BINTI ABD GHANI   | 2219732   | **1. Project Ideation & Initiation** <br>  Assigned Modules - UI Design, Main page (Big buttons) <br> <br> **2. Requirement Analysis & Planning** <br>  a. Gantt Chart <br> b. Screen Navigation Flow <br> c. Sequence Diagram for Main page (Big buttons) <br> <br>  **3. Code Contribution** <br>a. Auth: sign_in.dart, sign_up.dart, role_selection.dart <br><br> b. Homepage: elderly_home.dart, caregiver_home.dart <br><br> c. Main Navigation: main.dart, elderly_bottom_nav_bar.dart, caregiver_bottom_nav_bar.dart <br><br> d. Profile: profile_page.dart (1), profile_page.dart (2)|
| NURAMIRATUL AISYAH BINTI RUZAIDI   | 2212736   | **1. Project Ideation & Initiation** <br> Assigned Modules - Medication and Hospital Appointments Reminders <br> <br> **2. Requirement Analysis & Planning** <br>  a. Sequence Diagram for Medication Reminders <br> b. Sequence Diagram for Hospital Appointments Reminders <br><br> **3. Code Contribution** <br> a. Medication: medication_detail_page.dart (1), medication_page.dart, add_medication_page.dart, medication_detail_page.dart (2) ,medication_list.dart <br><br> b. Appointment: appointment_detail_page.dart (1), appointment_page.dart, add_appointment_page.dart, appointment_detail_page.dart (2), appointment_list.dart <br><br>             |
|AISHA MOHMMED ALWAN ALJUBOORI | 2125992   |**1. Project Ideation & Initiation** <br> Assigned Modules - Pedometer, Weekly Email Automation <br> <br> **2. Requirement Analysis & Planning** <br>  a. Sequence Diagram for Pedometer <br> b. Sequence Diagram for Weekly Email Automation <br> <br>**3. Code Contribution** <br> a. Steps: pedometer_page.dart <br><br> b. Weekly Report: weeklyreport_page.dart, weeklyshow.dart |


<br><br>

# 1. Project Ideation & Initiation

## Background of the problem

Many older adults struggle with modern smartphones because interfaces are small, cluttered, and require multiple steps to perform basic tasks. This leads to **frustration, missed medication and missed appointments.** In Malaysia and many other places, caregivers often need to remind seniors about medication and appointments, or to check activity  a manual process that wastes time and can fail when the senior is alone. There’s a need for an app that **reduces load, supports memory and routine, and helps family members stay informed** without constant calls.

## Objective

1.	To create a simple, reliable companion app that makes essential phone functions and health reminders immediately accessible to elderly users. 
2.	To improve medication and appointment adherence with clear reminders.
3.  To provide step tracking to support daily activity monitoring and encourage healthier routines.
4.	To keep family members informed through automated weekly summaries.

## Target users

- **Primary**: Older adults (50+) who are not tech-savvy and prefer simplified interfaces 
- **Secondary**: Family (children, relatives) who want lightweight remote monitoring and an easy way to set reminders.

## Preferred Platform
- Android Mobile App

## Features


### 1. Big Buttons Interface  
- Large, high-contrast icons   
- Home screen with essential functions: Call, Message, Camera, Clock, Calendar with large, emergency icon 

### 2. Medication Reminders  
- Daily reminders with “Taken / Missed” buttons  
- Family can pre-fill medication schedule  
- Medication history log

### 3. Hospital Appointment Reminders  
- Alerts before appointments  
- Add details like date, location, and notes  

### 4. Step Monitoring (Pedometer)  
- Uses device motion sensor  
- Tracks daily steps  

### 5. Weekly Family Updates  
- Automatic report with:  
  - Steps taken  
  - Medications taken/missed  
  - Appointments attended   
- Keeps families informed without disturbing senior’s routine

<br>

 # 2. Requirement Analysis & Planning


#### 1.1 Technical Feasibility 
Buddi is developed using **Flutter (Dart)**, enabling a single codebase for  Android smartphones. Flutter supports strong UI design, smooth performance, and a wide range of plugins.

- **Data Storage for CRUD Operations:**
  - **User profile:** 
  - **Medication schedules**
  - **Hospital appointments**
  - **Step count records**
  
  **Storage Solutions:**
  - Cloud: **Firebase Firestore** for real-time, scalable storage  
  - Authentication: **Firebase Authentication**  

- **Packages & Plugins:**
  - `firebase_auth`, `cloud_firestore` – User data & auth
  - `flutter_local_notifications` – Reminders
  - `pedometer` or `health` – Step tracking
  - `url_launcher` – Emergency calls
  - `camera` – Camera access
  - `intl` – Date/time formatting

#### 1.2 Platform Compatibility
- **Smartphones:** Android

#### 1.3 Logical Design

## **Sequence Diagram**

<br>


| Mainpage (Big Buttons)|
|-------------------|
| <p align="center">
  <img src="./assets/module1.drawio.png" width="300"/> </p> | 

| Medication Reminders | Hospital Appointment Reminders |
|-------------------|-----------------|
| ![Medication Reminders](assets/module2.drawio.png) | ![Hospital Appointment Reminders ](assets/module3.drawio.png) | 

| Pedometer | Weekly Email Automation |
|-------------------|-----------------|
| ![Pedometer](assets/Module4.png) | ![Weekly Email Automation](assets/Module6.png) | 

<br>

## **Screen Navigation Flow**
 
![Screen Navigation Flow](screen-nav-flow.png)


### 2. Planning

## 2.1 Project Timeline Overview (Gantt Chart)

![Gantt Chart](Gantt-Chart.png)


# 3. Project Design

## 1. UI/UX

### Authentication

| Sign In | Sign Up|
|-------------------|-----------------|
| ![Sign In](assets/sign-in.jpg) | ![Sign Up](assets\sign-up.jpg) | 

🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹



### Pages: Elderly

| Homepage | Profile |
|-------------------|-----------------|
| ![Homepage](assets/main-page.jpg) | ![Profile](assets/profile-elderly.jpg) | 



| Pedometer | Weekly Report | Medication | Appointment |
|-------------------|-----------------|-------------------|-----------------|
| ![Pedometer](assets/medication.jpg) | ![Weekly Report](assets/appoinment.jpg) | ![Medication](assets/steps.jpg) | ![Appointment](assets/weekly-report.jpg)|

🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹🔹

### Pages: Caregiver

| Homepage | Profile | Medication | Appointment |
|-------------------|-----------------|-------------------|-----------------|
| ![Homepage](assets/homepage-caregiver.jpg) | ![Profile](assets/profile-caregiver.jpg) | ![Medication](assets/medication-caregiver.jpg) | ![Appointment](assets/appoinment-caregiver.jpg)|



## 3. Consistency
### 3.1 Color Palette

![Color Pallette 1](./assets/color-pallete1.svg) <br><br>
![Color Pallette 2](./assets/color-pallette.svg)


The palette was chosen for high contrast and visibility for elderly users. Blue provides a calming effect, while red clearly signals missed doses or urgent actions. 



### 2.2 Typography

Font Family: Google Sans Flex


<p align="center">
  <img src="./assets/google-sans-flex.jpeg" width="300"/>
</p>

Large, Modern, Clear fonts improve readability and reduce eye strain for seniors.
<br><br>


# 4. Project Development
<br><br>

### 4.1 Functionality Implementation

1. Widgets: The app uses StatelessWidget for static UI and StatefulWidget for dynamic screens like weekly reports.
2. Navigation: Screen transitions are handled with Navigator.push() and MaterialPageRoute, enabling controlled navigation based on user actions.

### 4.2 Code Quality


## Project Structure

- **lib/auth/**  
  Handles authentication logic such as login, registration, and user access control

- **lib/pages/**  
  Holds all the main screens (pages) of the application.

- **lib/pages/elderly/**  
  Pages designed specifically for elderly user role, focusing on accessibility and basic reminders

- **lib/pages/caregiver/**  
  Pages for caregivers to input medication and appoinment, monitor, and assist elderly users.

- **lib/services/**  
  Handles application services including API calls, database operations, and backend interactions.

- **lib/utils/**  
  Utility functions, helper methods, and constant values used throughout the app.

- **lib/widgets/**  
  Reusable UI components shared across different pages.

### 4.3 Packages and Plugins
  - `firebase_auth`, `cloud_firestore` – User data & auth
  - `flutter_local_notifications` – Reminders
  - `pedometer` or `health` – Step tracking
  - `url_launcher` – Emergency calls
  - `camera` – Camera access
  - `intl` – Date/time formatting

### 4.4 Collaborative Tool

- GitHub: Version control.
- Branching Strategy: Created separate branches for each features and merged into main after code review.

# 5. References

1. dc-exe. Health_and_Doctor_Appointment. GitHub. https://github.com/dc-exe/Health_and_Doctor_Appointment/tree/main

2. dancamdev. article_bouncing_button_animation. GitHub. https://github.com/dancamdev/article_bouncing_button_animation
