# Mobile App Design: AXIS CRM

This document outlines the screens and fields required for a mobile version of the AXIS CRM platform.

## 1. Authentication & Onboarding
### Login Screen
- **Fields**: Email Address, Password
- **Actions**: Login, Forgot Password, Register New Account

### Registration Screen
- **Fields**: Full Name, Company/Tenant Name, Work Email, Password, Confirm Password
- **Actions**: Create Account, Back to Login

## 2. Dashboard (Home)
### Metrics Overview
- **Display**: 
  - Pipeline Value (Total $)
  - Active Deals (Count)
  - Win Rate (%)
  - New Leads (Count)
### Recent Activity Feed
- **Display**: Chronological list of recent interactions (calls, emails, status changes).

## 3. Leads Management
### Lead List Screen
- **Search/Filter**: Search by name/company, Filter by Status, Lead Source, or Assigned Agent.
### Lead Details Screen
- **Fields**: 
  - **Identity**: Salutation, First Name, Last Name, Title
  - **Company**: Company Name, Industry, Website, Annual Revenue, Employees
  - **Contact**: Email, Phone, Mobile, Fax
  - **Address**: Street, City, State, Postal Code, Country
  - **CRM Data**: Status (New, Contacted, Qualified, etc.), Lead Source, Interest Level, Lead Score, Description
- **Actions**: Call, Email, Convert to Account/Contact, Log Activity.

## 4. Accounts (Companies)
### Account List Screen
- **Search/Filter**: Search by account name, Filter by Industry or Account Type.
### Account Details Screen
- **Fields**: 
  - **Company Info**: Account Name, Account Number, Account Type, Industry, Website, Phone
  - **Financials**: Annual Revenue, Employees
  - **Address**: Billing Address (Street, City, State, Zip, Country), Shipping Address
  - **Relationships**: Assigned Agent, Supervisor
  - **CRM Data**: Interest Level, Description
- **Actions**: View Related Contacts, View Related Deals, Log Activity.

## 5. Contacts (People)
### Contact List Screen
- **Search/Filter**: Search by name, Filter by Account or Department.
### Contact Details Screen
- **Fields**: 
  - **Identity**: Salutation, First Name, Last Name, Title, Department, Date of Birth
  - **Professional**: Account (Link), Reports To (Link)
  - **Contact**: Email, Mobile, Phone, Fax
  - **Address**: Street, City, State, Zip, Country
  - **CRM Data**: Description, Assigned Agent
- **Actions**: Call, SMS, Email, Link to Deal, Log Activity.

## 6. Deals (Opportunities)
### Deal List Screen
- **Search/Filter**: Search by deal name, Filter by Pipeline Stage, Account, or Probablity.
### Deal Details Screen
- **Fields**: 
  - **Overview**: Deal Name, Amount, Currency, Closing Date
  - **Pipeline**: Pipeline Name, Current Stage, Probability (%), Is Won/Closed
  - **Relationships**: Lead (Link), Account (Link), Contact (Link), Product (Link)
  - **CRM Data**: Deal Type, Lead Source, Next Step, Description, Lost Reason (if applicable)
- **Actions**: Move Stage, Log Payment, Add Products.

## 7. Activities & Tasks
### Activity Log Screen
- **Fields**: Subject, Activity Type (Call, Meeting, Email), Status, Priority, Start/End Time, Duration, Location, Outcome/Notes.
- **Relationships**: Link to Lead/Account/Contact/Deal.
### Task Management Screen
- **Fields**: Subject, Priority, Due Date, Task Type, Status, Assignee, Description.

## 8. Support (Cases)
### Case List Screen
- **Search/Filter**: Search by Case Number/Subject, Filter by Status or Priority.
### Case Details Screen
- **Fields**: Case Number, Subject, Case Origin (Email, Phone, Web), Status, Priority, Case Type, Account/Contact (Links), Description, Internal Comments, Resolution.

## 9. Payments
### Payment History Screen
- **Display**: Receipt Number, Amount, Date, Status, Payment Method.
### Log Payment Screen
- **Fields**: Amount, Payment Date, Account/Deal (Link), Payment Method, Transaction Reference, Notes.
