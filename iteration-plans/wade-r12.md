# Wade R12 — Social Travel & Group Planning

## Theme
**Travel is better together. Plan, share, and explore with others.**

R12 transforms Wade from a personal travel assistant into a collaborative travel platform — enabling shared itineraries, social discovery, and group trip coordination.

---

## Features

### 1. Shared Itineraries
- **Share trip via link** — Generate a read-only or editable share link for any trip
- **Collaborative editing** — Multiple people can suggest edits to a shared itinerary; trip owner approves/rejects
- **Comment threads** — Leave comments on specific activities ("Skip this, the line is 2 hours long!")
- **Version history** — Track who changed what and when; restore previous versions

### 2. Travel Buddies Finder
- **Destination matching** — Enter where you're going and when; Wade shows others with overlapping trips
- **Interest compatibility** — Match on travel style (foodie, adventure, chill), budget, pace
- **Anonymous introduction** — Connect without sharing personal info until both parties opt in
- **Group chat placeholder** — Deep link to WhatsApp/Signal/Telegram group for coordinated trips

### 3. Group Trip Planning
- **Group budget tracking** — Track shared expenses, who paid what, split calculations with uneven splits
- **Group voting** — Group members vote on activities, restaurants, accommodations
- **Trip calendar sync** — Export combined itinerary to Google Calendar / Apple Calendar
- **Designated organizer** — One person manages final decisions; others suggest

### 4. Travel Community
- **Destination reviews** — Read/write short reviews for attractions, restaurants, neighborhoods
- **Photo highlights** — Community photo gallery per destination (Unsplash for initial seed data)
- **Local tips feed** — Sorted tips from travelers who've been to your upcoming destinations
- **Reputation system** — Earn trust score from helpful tips and accurate reviews

### 5. Social Sharing
- **Trip highlight reel** — Auto-generate a "trip story" from itinerary with best photos
- **Share to social** — Export trip summary as image card for Instagram/Stories
- **Check-in feature** — "I'm at X" with photo, shared with travel buddies on overlapping trips
- **Achievement badges** — "First trip to Asia", "Budget master", "10 countries visited"

---

## Technical Approach

### Backend (Supabase)
- **Auth** — Email magic links or social login (Google, Apple)
- **Database** — `trips`, `itineraries`, `trip_members`, `comments`, `votes`, `buddy_matches`, `reviews`, `user_profiles`
- **Realtime** — Supabase Realtime for collaborative editing updates
- **Storage** — Trip photos and documents

### APIs
- **Mapbox** or **Apple Maps** — Map rendering for shared trips
- **Google Places** — Restaurant/attraction autocomplete and details
- **Unsplash** — Destination photo seeding

### Architecture
- `SocialService` — buddy matching, sharing, reputation
- `GroupPlanningEngine` — budget splitting, voting, calendar export
- `CommunityContentService` — reviews, tips, photos

### Privacy
- Location data never stored permanently
- Buddy matching requires mutual opt-in
- Read-only share links contain no personal data

---

## UI Changes
- **New "Social" tab** — Travel buddies, shared trips, community content
- **Trip card** — New "share" button with link generation and permission controls
- **Group planning sheet** — Bottom sheet for group budget, voting, comments
- **Community view** — Destination-scoped tips and reviews
- **Profile/Settings** — Reputation score, achievements, account linking

---

## Metrics & Success
- Users successfully plan at least one group trip in Wade
- Buddy matching generates at least one successful travel connection
- Community tips improve trip planning satisfaction scores
