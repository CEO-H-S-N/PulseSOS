/// App-wide string constants
class AppStrings {
  AppStrings._();

  static const String appName = 'PulseSOS';
  static const String tagline = 'Your Safety Network';

  // Onboarding
  static const String onboardingTitle1 = 'Instant SOS Alerts';
  static const String onboardingDesc1 = 'Trigger emergency alerts with a single tap, shake, or voice command. Help is always one action away.';
  static const String onboardingTitle2 = 'Community Response';
  static const String onboardingDesc2 = 'Nearby users receive instant alerts and can navigate to help you in real-time.';
  static const String onboardingTitle3 = 'Stay Protected';
  static const String onboardingDesc3 = 'Live location sharing, evidence recording, and trusted contact notifications keep you safe.';

  // Auth
  static const String welcomeBack = 'Welcome Back';
  static const String createAccount = 'Create Account';
  static const String phoneNumber = 'Phone Number';
  static const String enterOtp = 'Enter Verification Code';
  static const String otpSent = 'We sent a 6-digit code to';
  static const String resendOtp = 'Resend Code';
  static const String continueWithGoogle = 'Continue with Google';
  static const String continueWithEmail = 'Continue with Email';

  // Profile
  static const String setupProfile = 'Setup Your Profile';
  static const String fullName = 'Full Name';
  static const String bloodGroup = 'Blood Group';
  static const String medicalConditions = 'Medical Conditions';
  static const String emergencyContacts = 'Emergency Contacts';
  static const String gender = 'Gender';
  static const String vehicleDetails = 'Vehicle Details';

  // SOS
  static const String triggerSos = 'HOLD FOR SOS';
  static const String sosActivated = 'SOS ACTIVATED';
  static const String sosCountdown = 'Sending alert in';
  static const String cancelSos = 'Cancel';
  static const String silentMode = 'Silent Mode';
  static const String loudMode = 'Loud Siren';
  static const String selectEmergencyType = 'Select Emergency Type';

  // Emergency Types
  static const String robbery = 'Robbery';
  static const String medicalEmergency = 'Medical';
  static const String fireEmergency = 'Fire';
  static const String harassmentEmergency = 'Harassment';
  static const String accidentEmergency = 'Accident';
  static const String kidnappingEmergency = 'Kidnapping';
  static const String otherEmergency = 'Other';

  // Incident
  static const String activeEmergency = 'Active Emergency';
  static const String nearbyIncidents = 'Nearby Incidents';
  static const String respondToIncident = 'Respond';
  static const String navigateToVictim = 'Navigate';
  static const String markAsHelping = 'I\'m Helping';
  static const String resolveIncident = 'Mark Resolved';

  // Navigation
  static const String home = 'Home';
  static const String alerts = 'Alerts';
  static const String contacts = 'Contacts';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
}

/// API & Network Constants
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:3000/api';
  static const String wsUrl = 'http://localhost:3000';

  // Auth
  static const String verifyToken = '/auth/verify-token';
  static const String deviceBind = '/auth/device-bind';
  static const String profileEndpoint = '/auth/profile';

  // Incidents
  static const String incidents = '/incidents';
  static const String nearbyIncidents = '/incidents/nearby';
  static const String incidentHistory = '/incidents/history';

  // Contacts
  static const String contactsEndpoint = '/contacts';
  static const String notifyContacts = '/contacts/notify';

  // Media
  static const String mediaUpload = '/media/upload';

  // Analytics
  static const String heatmap = '/analytics/heatmap';
  static const String stats = '/analytics/stats';
}

/// App-wide numeric constants
class AppConstants {
  AppConstants._();

  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 60;
  static const int sosCountdownSeconds = 5;
  static const int maxEmergencyContacts = 5;
  static const int maxTrustedCircle = 10;

  // Location
  static const double defaultLatitude = 33.6844;
  static const double defaultLongitude = 73.0479;
  static const double defaultZoom = 15.0;
  static const double nearbyRadiusSmall = 0.5; // km
  static const double nearbyRadiusMedium = 1.0; // km
  static const double nearbyRadiusLarge = 3.0; // km

  // Tracking intervals
  static const int emergencyTrackingIntervalMs = 3000;
  static const int normalTrackingIntervalMs = 30000;

  // Throttling
  static const int maxSosPerHour = 3;
  static const int sosThrottleCooldownMinutes = 5;
}
