Travel Agency Database

A relational database system developed in PostgreSQL for managing the business operations of a travel agency. The project models the complete process of managing tourist destinations, travel organizations, tours, users, passengers, reservations and trip ratings.

The database was designed through conceptual, logical and physical modeling, with an emphasis on data integrity, normalization, business rules and efficient data management.

Project Overview

The system is designed around the operations of a travel agency called "Putuj s nama".

It supports three main types of users:

Registered User – browses destinations and available tours, creates and manages reservations, manages passengers and rates completed trips.
Travel Organization Manager – manages information about their organization and the tours it offers.
Administrator – has full control over the data within the system.

The database centralizes information about destinations, travel organizations, tours, users and reservations, while enforcing business rules and maintaining consistency between related entities.

Main Features
User Management
User registration and authentication
Unique email and JMBG validation
User role management
User activation and deactivation
Updating user information
Password change
Tourist Destinations
Create, update, activate and deactivate destinations
Store destination description, location, category and image
Connect destinations with tourist tours and organizations
Generate statistics about the most visited destinations
Travel Organizations
Create and update travel organizations
Assign and change organization managers
Activate and deactivate organizations
Manage organization contact information
Track the number of realized trips, reservations and passengers
Tourist Tours
Create and modify tours
Define start and end dates
Define price and tour capacity
Assign transportation and accommodation
Connect tours with destinations and travel organizations
Activate and deactivate tours
Change tour capacity
Calculate available places

The database also enforces rules such as a positive tour price and capacity and requires the tour end date to be after its start date.

Reservations
Create reservations
Generate unique reservation numbers
Add and remove passengers
Add the reservation holder as a passenger
Track payment status
Confirm payments
Cancel reservations
Track reservation status
Prevent overlapping tours for the same user
Passenger Management
Add passengers to reservations
Store passenger personal information
Manage passenger status
Track parental consent for minors
Activate and deactivate passengers
Prevent invalid passenger assignments
Trip Ratings
Rate completed trips
Add comments
Calculate average organization ratings
Database Model

The database consists of the following main tables:

Uloga – system roles
Mesto – places
Korisnik – registered users
Smestaj – accommodation
Prevoz – transportation
Destinacija – tourist destinations
Turisticka_organizacija – travel organizations
Turisticka_tura – tourist tours
Rezervacija – reservations
Ocena – trip ratings
Putnik – passengers
Rezervacija_putnik – relationship between reservations and passengers

The model uses primary keys, foreign keys, UNIQUE constraints, CHECK constraints and other integrity rules to maintain consistency between related data.

Database Objects

The project includes several types of PostgreSQL database objects.

SQL Queries

Queries are used for retrieving and analyzing information, including:

Reservations belonging to a specific user
Passengers belonging to a specific reservation
Information about tours, destinations and reservations

For example, passenger information can be retrieved by joining Rezervacija, Rezervacija_putnik, Putnik and Mesto.

Views

The database contains views for frequently used reports and aggregated information, including:

Active and future tourist tours
Tourist tour occupancy
Detailed reservation overview
Passengers by reservation
Active travel organizations and their managers
Most visited destinations
Tourist destination rankings
Organizations and number of realized trips

For example, the Pregled_rezervacija view combines reservation, user, tour, organization, destination and location data into a single overview.

The Najposecenije_destinacije view ranks active destinations according to the number of realized reservations.

Functions

The project implements PostgreSQL functions for business logic and data validation, including:

Checking whether an email already exists
Checking whether a JMBG already exists
Changing a password
Checking whether an organization has an assigned manager
Calculating occupied places
Calculating available places
Checking overlapping tour dates
Generating reservation numbers
Checking whether a passenger already exists
Checking whether a reservation can be cancelled
Calculating average organization ratings
Counting realized trips
Counting reservations and passengers by organization
Counting reservations by destination
Calculating organization revenue
Extracting date of birth from JMBG
Checking whether a passenger is an adult

The documentation defines 18 functions covering validation, reservation management and statistical calculations.

Triggers

Triggers are used to automatically enforce important business rules, including:

Checking tour capacity when adding a passenger to a reservation
Preventing overlapping tours for the same passenger
Stored Procedures

The database contains procedures for managing the main entities and business processes.

They cover:

Roles
Places
Users
Accommodation
Transportation
Destinations
Travel organizations
Tourist tours
Ratings
Reservations
Passengers
Payments
Activation and deactivation of records

Reservation-related procedures include creating reservations, adding passengers, cancelling reservations, confirming payments, removing passengers and modifying passenger information.

Indexes

Indexes are implemented to improve query performance, particularly for frequently accessed data. The project includes indexes related to:

Turisticka_tura
Rezervacija
Technologies
PostgreSQL – relational database management system
SQL – database definition, manipulation and querying
pgAdmin – database administration and development
PowerDesigner – conceptual, logical and physical database modeling
Database Design

The database was developed through several modeling stages:

Requirements analysis
Conceptual model
Logical model
Physical model
Relational model
Database implementation

The design applies relational database principles, including primary keys, foreign keys, referential integrity, normalization and business constraints.

Data Integrity and Business Rules

The database contains validation rules that prevent invalid or inconsistent data.

Examples include:

Email addresses must be unique.
JMBG values must be unique and contain 13 digits.
Required fields cannot contain NULL.
Tour prices and capacities must be positive.
A tour's end date must be after its start date.
Foreign keys maintain relationships between related entities.
A user cannot reserve overlapping tours.
A tour cannot accept passengers when its capacity has been reached.

For example, the Korisnik table uses UNIQUE, NOT NULL and CHECK constraints for email, JMBG, personal information and phone number, while foreign keys connect users with their place of residence and system role.

Error Handling and Transactions

The database uses PostgreSQL transaction mechanisms and PL/pgSQL exception handling to maintain consistency when executing complex operations.

Transactions allow multiple operations to be treated as a single logical unit, while exception handling provides controlled responses to errors such as constraint violations and invalid operations.

Project Goal

The main goal of the project is to create a structured and reliable relational database that can serve as the foundation of an information system for managing a travel agency.

The implemented model provides centralized data management and supports everyday operations such as managing tours, destinations, organizations, users, reservations and passengers, while also enabling reporting and statistical analysis.
