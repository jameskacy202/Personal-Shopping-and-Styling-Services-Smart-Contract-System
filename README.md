# Personal Shopping and Styling Services Smart Contract System

A comprehensive Clarity-based smart contract system for managing personal shopping and styling services on the Stacks blockchain.

## Overview

This system provides a decentralized platform for personal shopping and styling services, featuring:

- **Stylist Management**: Qualification tracking, certification, and performance metrics
- **Client Preferences**: Secure storage of personal measurements, style preferences, and shopping history
- **Purchase Coordination**: Wardrobe tracking, purchase history, and item coordination
- **Pricing & Returns**: Transparent pricing models and satisfaction guarantee management
- **Service Customization**: Flexible service packages and personalized styling options

## Architecture

The system consists of five interconnected smart contracts:

### 1. Stylist Management Contract (`stylist-management.clar`)
- Manages stylist registration and qualifications
- Tracks certifications, experience levels, and specializations
- Handles stylist ratings and performance metrics
- Controls stylist availability and service areas

### 2. Client Preferences Contract (`client-preferences.clar`)
- Securely stores client measurements and body type information
- Manages style preferences, color palettes, and brand preferences
- Tracks budget constraints and shopping frequency
- Handles privacy settings and data access controls

### 3. Purchase History Contract (`purchase-history.clar`)
- Records all purchase transactions and wardrobe items
- Tracks item categories, colors, sizes, and purchase dates
- Manages wardrobe coordination and outfit suggestions
- Handles item condition and replacement recommendations

### 4. Pricing Management Contract (`pricing-management.clar`)
- Defines service packages and pricing tiers
- Manages dynamic pricing based on demand and stylist experience
- Handles payment processing and fee distribution
- Tracks promotional offers and discount codes

### 5. Returns Management Contract (`returns-management.clar`)
- Manages return requests and satisfaction guarantees
- Tracks return reasons and resolution outcomes
- Handles refund processing and store credit management
- Maintains return policy compliance and dispute resolution

## Key Features

### Security & Privacy
- Client data is encrypted and access-controlled
- Stylists can only access authorized client information
- Payment processing is secure and transparent
- All transactions are recorded on the blockchain

### Transparency
- Clear pricing structure with no hidden fees
- Public stylist ratings and qualifications
- Transparent return and refund policies
- Auditable transaction history

### Customization
- Flexible service packages (one-time, monthly, seasonal)
- Personalized styling based on individual preferences
- Budget-conscious options and luxury tiers
- Specialized services (business, casual, formal, etc.)

### Quality Assurance
- Stylist certification and ongoing training requirements
- Client satisfaction tracking and feedback systems
- Return guarantee for unsatisfactory purchases
- Performance-based stylist rewards

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Stacks wallet for deployment

### Installation

1. Clone the repository
2. Install dependencies: `npm install`
3. Run tests: `npm test`
4. Deploy contracts: `clarinet deploy`

### Testing

The system includes comprehensive tests using Vitest:

\`\`\`bash
npm test                    # Run all tests
npm run test:watch         # Run tests in watch mode
npm run test:coverage      # Generate coverage report
\`\`\`

## Contract Interactions

### For Clients
1. Register and set up preferences
2. Browse and select stylists
3. Book styling sessions
4. Review and approve purchases
5. Manage returns if needed

### For Stylists
1. Register and complete certification
2. Set availability and service areas
3. Access client preferences (with permission)
4. Make purchase recommendations
5. Track client satisfaction

### For Administrators
1. Manage stylist certifications
2. Monitor system performance
3. Handle dispute resolution
4. Update pricing and policies

## Data Models

### Stylist Profile
- Unique stylist ID
- Qualifications and certifications
- Specializations and experience
- Ratings and reviews
- Availability schedule

### Client Profile
- Unique client ID
- Personal measurements (encrypted)
- Style preferences and constraints
- Budget and shopping frequency
- Privacy settings

### Purchase Record
- Transaction ID and timestamp
- Item details (category, brand, size, color)
- Purchase price and stylist commission
- Client satisfaction rating
- Return status

## Security Considerations

- All sensitive client data is encrypted
- Access controls prevent unauthorized data viewing
- Payment processing follows industry standards
- Smart contract code is audited and tested
- Regular security updates and monitoring

## Contributing

Please read our contributing guidelines and code of conduct before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
