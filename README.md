# Fleet Monitor App

Flutter application for monitoring fleet vehicles in real-time. The app displays cars on a map, allows users to view car details, and track individual cars' locations.

## Features

- Real-time car location tracking on OpenStreetMap
- Search cars by name or ID
- Filter cars by status (Moving/Parked)
- Detailed car information view
- Real-time updates every 5 seconds

## Screenshots

![App Screenshot 1](fleet_move/Screenshot%202025-05-18%20at%2011.56.04.png)
![App Screenshot 2](fleet_move/Screenshot%202025-05-18%20at%2011.56.13.png)
![App Screenshot 3](fleet_move/Screenshot%202025-05-18%20at%2011.56.24.png)
![App Screenshot 4](fleet_move/Screenshot%202025-05-18%20at%2011.56.43.png)
![App Screenshot 5](fleet_move/Screenshot%202025-05-18%20at%2011.56.58.png)
![App Screenshot 6](fleet_move/Screenshot%202025-05-18%20at%2011.57.11.png)
![App Screenshot 7](fleet_move/Screenshot%202025-05-18%20at%2011.57.23.png)

## Video Demo
Watch the app in action: [Fleet Monitor Demo Video](https://drive.google.com/drive/folders/1xvBY4Ene9iM-mcS-3xKg_ZNkZ8WAuLpC?usp=sharing)

## Prerequisites

- Flutter SDK (latest version)
- Android Studio / Xcode for running on emulators

## Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd fleet_monitor
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up environment variables:
   - Create a `.env` file in the root directory
   - Add the following variables:
     ```
     API_BASE_URL=your_api_base_url
     ```
   - Make sure to add `.env` to your `.gitignore` file to keep sensitive information secure
   - Create a `.env.example` file with the same structure but without actual values for reference

4. Run the app:
```bash
flutter clean && flutter pub get && flutter run -d chrome
```

## Project Structure

```
lib/
  ├── models/
  │   └── car.dart
  ├── providers/
  │   └── car_provider.dart
  ├── screens/
  │   ├── home_screen.dart
  │   └── car_details_screen.dart
  ├── services/
  │   └── car_service.dart
  └── main.dart
```

## Usage

1. The home screen displays a map with car markers
2. Use the search bar to find specific cars
3. Use the filter chips to show only moving or parked cars
4. Tap on a car marker to view detailed information
5. In the details screen, use the play/stop button to track a specific car

## API Integration

The app uses a mock API endpoint for demonstration purposes. In a production environment, replace the API endpoint in `car_service.dart` with your actual fleet management API.

## Dependencies

- flutter_map: ^6.1.0
- latlong2: ^0.9.0
- provider: ^6.1.1
- http: ^1.1.2
- flutter_dotenv: ^5.1.0
- intl: ^0.19.0

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## Done By 
Habimana Jambo Florbert
## Contact
email: habimanaflorbert@gmail.com
phone: +250784447864


## here is backend from Mockapi
1. GET https://6828a6f66075e87073a48111.mockapi.io/api/v1/cars/
2. GET https://6828a6f66075e87073a48111.mockapi.io/api/v1/cars/:id