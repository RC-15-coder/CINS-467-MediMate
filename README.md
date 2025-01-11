# Overview
MediMate is a smartphone application designed to simplify healthcare access by providing reliable information on health conditions, medications, and nearby pharmacies and hospitals. It serves as a one-stop solution where users can:

Enter a health condition or medication name and receive detailed information (e.g., symptoms, causes, treatment, diagnosis).
Access the latest health data, retrieved via APIs or a cloud database such as Firebase Firestore.
Connect with nearby healthcare professionals and services using location-based tools.
Whether you need to find the nearest pharmacy or a specialist for a specific health issue, MediMate makes healthcare information more accessible and navigable for everyday users.

# Features
# 1. Internet Connectivity

MediMate ensures users access the most recent healthcare information through:

Firebase Firestore: To retrieve and send user-related data.

External Health APIs: For real-time medical data.

# 2. Disease Information

API Used: National Library of Medicine's Clinical Table Search Service API
Purpose: Provide users with updated and reliable information on various medical conditions.

Data Retrieved:
When a user searches for a disease, the app sends a query to the API with the disease name.
The API responds with data containing links to MedlinePlus, a trusted source for disease-related details.

Process:
The app extracts the relevant link for the searched disease and redirects the user to the MedlinePlus website for detailed information.

Privacy: No personal health information is sent, received, or stored.

# 3. Drug Information

API Used: openFDA API for Drug Product Labeling
Purpose: Access comprehensive information about prescription and over-the-counter drugs.

Data Retrieved:
The app retrieves official product labeling, including details about usage, adverse reactions, warnings, and more.

Process:

Users can search for drug information within the app.
The app sends a query to the openFDA API and receives accurate and updated labeling data.

# 4. Location of Nearby Pharmacies and Hospitals

API Used: Google Maps API

Purpose: Help users locate nearby pharmacies and healthcare providers.

Data Retrieved:
The app uses the user's current location to query the Google Maps API for nearby healthcare services.

Process:
With user permission, the app accesses location data, sends it to the Google Maps API, and retrieves a curated list of nearby healthcare providers or pharmacies.

# Demo
🎥 [MediMate Demo Video](https://drive.google.com/file/d/1Apgr1Am2ZpB0vuHMQ_bIO5y2AicfGmbx/view?usp=sharing)

# Technologies Used

Framework: Flutter

Backend: Firebase Firestore

APIs:

National Library of Medicine Clinical Table Search Service API

openFDA Drug Product Labeling API

Google Maps API

Languages: Dart
