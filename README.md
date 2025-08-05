# Blockchain-Based Public Health Vaccination and Immunization Tracking System

## Overview

This system provides a comprehensive blockchain-based solution for managing public health vaccination and immunization tracking. Built on the Stacks blockchain using Clarity smart contracts, it ensures data integrity, transparency, and security for vaccination records and related health data.

## System Architecture

The system consists of five interconnected smart contracts:

### 1. Vaccination Records Contract (`vaccination-records.clar`)
- Maintains secure, portable immunization records for individuals
- Stores vaccination history, dates, vaccine types, and batch numbers
- Provides privacy controls and access management
- Enables verification of vaccination status

### 2. Vaccine Supply Chain Contract (`supply-chain.clar`)
- Monitors vaccine distribution from manufacturers to clinics
- Tracks batch numbers, expiration dates, and storage conditions
- Maintains chain of custody records
- Enables recall management and quality assurance

### 3. Appointment Scheduling Contract (`appointments.clar`)
- Coordinates vaccination appointments across multiple healthcare providers
- Manages appointment slots, scheduling, and cancellations
- Tracks appointment history and no-shows
- Enables efficient resource allocation

### 4. Adverse Event Reporting Contract (`adverse-events.clar`)
- Tracks and investigates vaccine side effects and safety concerns
- Maintains confidential adverse event reports
- Enables statistical analysis and safety monitoring
- Supports regulatory compliance and reporting

### 5. Public Health Campaign Contract (`health-campaigns.clar`)
- Coordinates outreach efforts to increase vaccination rates
- Tracks campaign effectiveness and reach
- Manages target demographics and messaging
- Monitors vaccination rate improvements

## Key Features

### Security & Privacy
- Cryptographic data integrity
- Role-based access control
- Privacy-preserving record management
- Secure data sharing between authorized parties

### Interoperability
- Standardized data formats
- Cross-provider compatibility
- Integration with existing health systems
- Portable vaccination records

### Transparency & Auditability
- Immutable record keeping
- Full audit trails
- Public health statistics
- Regulatory compliance

### Scalability
- Efficient data structures
- Optimized for high transaction volumes
- Minimal storage requirements
- Fast query capabilities

## Data Models

### Vaccination Record
- Individual ID (hashed for privacy)
- Vaccine type and manufacturer
- Administration date and location
- Healthcare provider information
- Batch number and lot information
- Next dose due date

### Supply Chain Entry
- Batch/lot number
- Manufacturer information
- Production and expiration dates
- Distribution chain records
- Storage condition logs
- Current location and status

### Appointment
- Patient ID (hashed)
- Healthcare provider
- Appointment date and time
- Vaccine type requested
- Status (scheduled/completed/cancelled)
- Reminder preferences

### Adverse Event
- Anonymous patient demographics
- Vaccine information
- Event description and severity
- Timeline and symptoms
- Healthcare provider assessment
- Follow-up status

### Health Campaign
- Campaign name and objectives
- Target demographics
- Messaging and outreach methods
- Timeline and milestones
- Effectiveness metrics
- Budget and resource allocation

## Installation

1. Install Clarinet CLI
2. Clone this repository
3. Run `clarinet check` to validate contracts
4. Run `npm test` to execute test suite
5. Deploy contracts using `clarinet deploy`

## Usage

### For Healthcare Providers
- Register vaccination records
- Schedule and manage appointments
- Report adverse events
- Access supply chain information

### For Public Health Officials
- Monitor vaccination rates
- Manage health campaigns
- Analyze adverse event data
- Track supply chain integrity

### For Individuals
- Access personal vaccination records
- Schedule appointments
- Verify vaccination status
- Report adverse events

## Testing

The system includes comprehensive tests using Vitest:
- Unit tests for each contract function
- Integration tests for cross-contract workflows
- Edge case and error condition testing
- Performance and gas optimization tests

Run tests with:
\`\`\`bash
npm test
\`\`\`

## Security Considerations

- All sensitive data is hashed or encrypted
- Role-based access controls prevent unauthorized access
- Input validation prevents malicious data injection
- Regular security audits and updates

## Compliance

The system is designed to comply with:
- HIPAA privacy requirements
- FDA adverse event reporting guidelines
- CDC vaccination tracking standards
- International health data standards

## Contributing

Please read the PR-DETAILS.md file for contribution guidelines and development standards.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
