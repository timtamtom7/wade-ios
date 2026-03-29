# WadeMac — Launch Checklist

## Pre-Launch (1–2 weeks before)

### App Store Assets
- [ ] App Store icon (1024 × 1024 PNG, no rounded corners)
- [ ] App Store screenshots — macOS, iPhone 6.7", iPad (see `Marketing/APPSTORE.md`)
- [ ] App preview video (optional, recommended)
- [ ] Write and finalize app description
- [ ] Write keywords list for App Store SEO
- [ ] Choose categories: Travel, Lifestyle

### Legal & Privacy
- [ ] Create Privacy Policy URL (required for App Store)
- [ ] Create Terms of Service URL
- [ ] Ensure GDPR/CCPA compliance if collecting user data
- [ ] Review App Tracking Transparency requirements
- [ ] Verify all third-party SDKs have appropriate privacy policies

### Build & Test
- [ ] Run Release build on Apple Silicon (arm64) — **BUILD SUCCEEDED ✓**
- [ ] Test on Intel macOS (if supporting both architectures)
- [ ] Test on latest macOS (Sonoma/Ventura)
- [ ] Test dark mode appearance
- [ ] Verify no hardcoded API keys or secrets in bundle
- [ ] Check bundle identifier and version numbers

### App Store Connect
- [ ] Create App Store Connect account (paid Apple Developer membership required)
- [ ] Create new app entry with correct Bundle ID
- [ ] Set pricing tier (Free or paid)
- [ ] Configure in-app purchases (if any)
- [ ] Add review contact info and demo account credentials
- [ ] Complete export compliance information

---

## Launch Week

### Marketing
- [ ] Publish launch announcement (Twitter, blog, etc.)
- [ ] Prepare press release / media kit
- [ ] Reach out to relevant tech/travel publications
- [ ] Update GitHub repo (if open source)

### Submission
- [ ] Upload build via Xcode Organizer or Transporter
- [ ] Select build in App Store Connect
- [ ] Submit for Apple review
- [ ] Monitor review status daily
- [ ] Prepare for Apple review questions (respond within 24h)

---

## Post-Launch

- [ ] Monitor crash reporting (Xcode Organizer, Firebase, etc.)
- [ ] Set up analytics for user engagement
- [ ] Collect and respond to first user reviews
- [ ] File tax forms if monetizing
- [ ] Plan v1.1 feature roadmap

---

## Version History

| Version | Date | Status |
|---------|------|--------|
| R13     | 2026-03-29 | BUILD OK — Submitted |
