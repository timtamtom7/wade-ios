# Wade R13 — Polish, App Store Listing & Launch

## Theme
**Ship it. Make it beautiful. Make it real.**

R13 is the final stretch — squashing final polish, crafting the App Store presence, and launching Wade to real users.

---

## Polish & QA

### Visual Polish
- **App icon** — Design final app icon (airplane + compass motif with Wade brand colors)
- **Menu bar icon** — Custom menu bar icon that looks great at 16×16 and 32×32
- **Onboarding flow** — 3-screen intro: What Wade does → how to use menu bar → create first trip
- **Launch animation** — Subtle airplane path animation on first launch
- **Dark mode** — Full dark mode support (System appearance)
- **Window chrome** — Custom window title bar that matches Wade's aesthetic

### Code Cleanup
- Remove all `TODO` and `FIXME` comments
- Address all SwiftLint warnings
- Run static analysis (SonarQube or Xcode Analyze)
- Memory profiling — ensure no retain cycles, particularly in AppDelegate
- CPU profiling — no runaway timers or observers

### Edge Cases
- Empty states for every view (no trips, no packing list, no search results)
- Graceful degradation when offline (currency uses cached rates, destinations cached)
- Long destination names truncate properly
- Date ranges where end < start (validation error)
- Very long itineraries (30+ days) scroll without jank

---

## App Store Listing

### Metadata
- **App name:** Wade — AI Travel Planner
- **Subtitle:** Plan trips. Pack smart. Travel light.
- **Description:** (see template below)
- **Keywords:** travel planner, trip planner, packing list, currency converter, AI travel, vacation planner, itinerary
- **Category:** Travel & Navigation
- **Age rating:** 4+
- **Screenshot requirements:**
  - 6.7" iPhone screenshots (1290×2796) — 5 screenshots
  - Menu bar app showing main window
  - Trip planner with generated itinerary
  - Packing list with progress
  - Currency converter
  - Destination browse view

### Screenshots & Preview Video
- Design 5 polished screenshots using device mockup frames
- Record 15-second App Preview video showing key flows
- Use ScreenFlow or QuickTime + Figma for capture

### App Store Description (v1)
```
Wade is your AI-powered travel companion, living quietly in your menu bar.

✈️ AI Trip Planning
Tell Wade where you want to go and when — get a complete day-by-day itinerary in seconds. Pick your travel style (luxury, budget, family, or adventure) and let AI handle the rest.

🎒 Smart Packing
Never forget essentials. Wade generates packing lists based on your destination, trip length, and weather forecast. Check off items as you pack.

💱 Currency & Tips
Real-time exchange rates for 20+ currencies. Built-in tip calculator with preset percentages and bill splitting.

🌍 Destination Guide
Browse curated destination guides with top attractions, restaurant recommendations, and local tips.

📊 At a Glance
Countdown to your next trip. Quick access to packing lists and upcoming itineraries — all without opening a separate window.

Wade respects your privacy. All data stays on your device.

Download Wade today and start planning your next adventure.
```

---

## Launch Checklist

### Pre-Launch
- [ ] TestFlight build uploaded (2+ days before App Store for review)
- [ ] Beta testers (5+) run flight-tested build
- [ ] Privacy policy URL hosted (required for App Store)
- [ ] Support URL configured
- [ ] Marketing website live (wade.travel or wadeapp.com)
- [ ] Social accounts created (@wadeapp on X, Instagram)
- [ ] App icon and screenshots finalized

### App Store Connect
- [ ] App Store Connect record created
- [ ] All metadata filled in
- [ ] Screenshots and preview video uploaded
- [ ] App privacy nutrition labels completed
- [ ] Build attached to submission
- [ ] Submission notes: highlight menu bar app nature, no special permissions needed
- [ ] Submit for review

### Post-Launch
- [ ] Monitor App Store reviews daily for first 2 weeks
- [ ] Push rapid updates for any critical bugs
- [ ] Announce on social media
- [ ] Post on Product Hunt
- [ ] Submit to alternative app directories (AlternativeTo, SaaSHub)
- [ ] Collect testimonials from early users
- [ ] Plan v1.1 update based on user feedback

### Analytics & Monitoring
- [ ] Firebase Analytics or Mixpanel integration
- [ ] Crashlytics enabled
- [ ] Set up App Store Connect Sales/Trends monitoring
- [ ] Set up email alias for user support (support@wadeapp.com)

---

## Success Criteria
- App Store review passed within 24-48 hours (typical for simple apps)
- 100+ downloads in first month
- Average App Store rating ≥ 4.0 stars
- Zero critical crashes reported
