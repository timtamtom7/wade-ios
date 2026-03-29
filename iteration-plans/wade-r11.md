# Wade R11 — AI Trip Optimization & Live Travel

## Theme
**Smarter trips, real-time updates, seamless bookings.**

R11 deepens the AI capabilities and adds real-world travel data integration — transforming Wade from a planning tool into a real travel companion.

---

## Features

### 1. AI Trip Optimizer
- **Dynamic itinerary optimization** — Reorder and adjust activities based on user feedback, weather, and opening hours
- **Budget optimizer** — Suggest cost-effective alternatives (similar restaurants at lower prices, free attractions near paid ones)
- **Time efficiency scoring** — Each activity shows estimated time, travel time to next stop, and total day score
- **Smart rescheduling** — Drag-and-drop activities between days with automatic time/location conflict detection

### 2. Real-Time Travel Updates
- **Weather integration** — Per-destination daily forecast on itinerary view; alert if rain affects outdoor plans
- **Flight tracker** — Flight number input → real-time departure/arrival status via AviationStack or AeroDataBox API
- **Local event alerts** — Notify when there's a local holiday, festival, or event near planned destinations
- **Travel advisory integration** — Check destination safety/advisory status via government APIs

### 3. Flight & Hotel Booking
- **Flight search** — Search flights (Skyscanner/Amadeus API) directly in Wade
- **Hotel discovery** — Browse hotels with price, rating, and distance to attractions
- **Booking deep links** — Open Skyscanner/Booking.com with pre-filled search parameters
- **Price alerts** — Set price thresholds for routes; get notified when prices drop

### 4. Packing Intelligence
- **Weather-aware packing** — Based on destination weather forecast, suggest additional items (rain jacket, sunscreen, layers)
- **Trip type detection** — Business trip → suit, laptop; Beach vacation → swim gear; Hiking → boots, backpack
- **Checklist sharing** — Generate shareable packing checklist as URL or PDF
- **Luggage size estimator** — Based on packing list weight/volume, suggest appropriate luggage

### 5. Document Manager
- **Passport/visa reminders** — Store expiry dates; alert 6 months before expiration
- **Booking confirmation storage** — Attach flight/hotel confirmations to trips
- **Travel insurance card** — Store and quick-access insurance policy details

---

## Technical Approach

### APIs
- **AviationStack** or **AeroDataBox** — Flight tracking (free tier available)
- **Skyscanner** — Flight search and deep links
- **OpenWeatherMap** — 7-day weather forecast per destination
- **Amadeus** — Hotel search and booking (has free test environment)

### Architecture
- New `TravelDataService` — central service for weather, flights, events
- `BookingManager` — handles external booking deep links and price alerts
- `DocumentVault` — encrypted local storage for travel documents

### Dependencies (Swift Package Manager)
- No new heavy dependencies — leverage URL schemes and deep links for booking

---

## UI Changes
- **Trip Planner tab** — Adds optimization panel and flight tracker card
- **Itinerary view** — Timeline with weather icons, time travel scores, drag handles
- **Settings** — API key inputs for weather and flight services
- **Notifications** — Real alerts for flight changes, weather warnings, price drops

---

## Metrics & Success
- User can plan, track, and book a complete trip within Wade
- Weather integration surfaces relevant changes to active itineraries
- Booking deep links reduce friction to actual travel booking
