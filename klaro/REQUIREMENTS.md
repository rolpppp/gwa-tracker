# Klaro: Prioritized Product Requirements
### *Roadmap to becoming the #1 grade tracker for Filipino college students*

> Version: 1.0 — March 2026
> Based on: User story validation (USER_STORIES.md), competitive research, and Filipino academic context

---

## 1. Competitive Landscape

Before setting requirements, it is important to understand what the global and local competition offers — and where they all fall short.

### 1.1 Global Competitors

| App | Rating | Strengths | Critical Gaps |
|---|---|---|---|
| **Grades – GPA Calculator** (Plutonium Apps) | 4.9/5 · 12K+ ratings | Weighted + points-based grading, custom icons, "what you need on next test" | No credit-hour weighting in GPA, no per-class grade scale, no scholarship alerts |
| **PowerPlanner** ($1.99) | 4.7/5 | Best-in-class "What If?" simulator, multi-semester, cross-platform | Free version nearly useless, no non-US grading systems, no transmutation |
| **Gradekit** (4.7/5) | 4.7/5 · 38K+ ratings | Syncs with 10,000+ school portals, real-time push alerts | No offline mode, premium paywall, no missing-assignment visibility |
| **Grade Pal** | 4.5/5 · 255 ratings | Simple, clean, percentage-based | Only 3–4 classes free, no GPA calculator, no points entry |
| **Target GPA** | 4.6/5 · 35 reviews | Cumulative GPA, honor roll tracking, scholarship milestone flags | Limited to letter grade input, small user base, no non-US scales |
| **Gradebook** | N/A | Student-built, visual dashboard, "What's Needed" calculator | No offline mode, no data export, no pricing transparency |

### 1.2 Philippine-Specific Tools

All existing Philippine-focused tools are **stateless web calculators** — they compute a one-off GWA from inputs you type in and discard everything the moment you close the tab. None of them:

- Persist your course data across sessions
- Simulate future grade scenarios dynamically
- Support the AI-powered syllabus parsing workflow
- Handle the scholarship-at-risk scenario
- Know what transmutation is

**The Philippine-specific mobile app market for grade tracking is effectively empty.** Every GWA calculator site in the Philippines is a web form with no state, no history, and no intelligence. Klaro has no direct native app competitor in this space.

---

## 2. Klaro's Durable Advantages (Do Not Lose These)

These features already exist in Klaro and no competitor has them. They must be protected and polished as the app grows.

| Advantage | Why It Matters |
|---|---|
| **AI Syllabus Parser** | Zero-setup tax — the biggest barrier to adoption for any grade tracker |
| **Dynamic Grading Buckets** | Handles real-world "add scores as you go" behavior, not just end-of-term calculation |
| **Ghost / Goal Assessments** | Forward-looking simulation built directly into the grading model, not a separate mode |
| **Real vs. Projected GWA Split** | Intellectually honest — shows what you've earned vs. what you're projecting |
| **Fully Offline (Drift/SQLite)** | No competitor markets offline-first to students in low-signal areas |
| **UP 5-Point System** | The dominant grading system in PH, and the one most calculators get wrong |
| **Excused/Exempted Assessments** | Solves a real pain point that every existing tool ignores |

---

## 3. Priority Framework

Requirements are tiered using the following system:

- **P0 — Critical (Fix Now):** Bugs or gaps that cause incorrect output or block a major user segment entirely. Ship before any marketing push.
- **P1 — High Impact (V1.1):** Features that make Klaro decisively better than every competitor for Filipino students. Primary differentiators.
- **P2 — Growth (V1.2):** Features that drive organic sharing, retention, and daily habit formation.
- **P3 — Vision (V2.0+):** Platform-level features that establish Klaro as infrastructure, not just an app.

---

## 4. P0 Requirements — Critical (Fix Before Launch Push)

---

### P0-01: Grade Transmutation Engine

**Problem:** The majority of Philippine private university students (Nursing, Education, Business, HRM) use transmutation-based grading. Their professors do not record raw percentages — they record transmuted grades. Without this, Klaro's computed grade does not match what appears on the student's official portal. This breaks trust immediately.

**What transmutation is:**
Transmutation converts a raw score into a grade using a floor value, so that a score of zero does not result in a grade of zero. Two variants are in common use:

- **Base 50 (most common in PH colleges):**
  `Transmuted Grade = (Raw Score / Total Score × 50) + 50`
  A zero raw score → grade of 50. A perfect score → grade of 100.

- **Base 60 (DepEd K-12 standard):**
  `Transmuted Grade = (Raw Score / Total Score × 60) + 40`
  A zero raw score → grade of 40. Passing (75) requires 58.3% raw score.

- **Base 0 (no transmutation, used in some universities):**
  `Grade = Raw Score / Total Score × 100`
  No floor. A zero is a zero.

**Requirement:**
- Add a transmutation mode toggle at the **course level** (not app-level), since students often have mixed professors in the same semester.
- Options: `None (Base 0)` · `Base 50` · `Base 60` · `Custom floor`
- When transmutation is active, the score entry UI should accept raw score and total, then display both the raw percentage and the transmuted grade.
- The simulator and goal calculator must use the transmuted grade, not the raw percentage, when computing GWA.

**Affected personas:** Trisha (Nursing), Kuya Jun (Education), and any private university student.
**Novel contribution:** No existing grade tracker app — in the Philippines or globally — implements transmutation as a configurable course-level setting.

---

### P0-02: Course-Level "Passing / At Risk / Failing" Status Label

**Problem:** Klaro shows a numeric grade (e.g., "2.50") but many users — especially first-generation students — do not know what that number means relative to passing. There is no visual indicator of danger.

**Requirement:**
- Each course card on the dashboard and the course detail screen must display a status chip derived from the student's current computed grade vs. the institution's passing threshold.
- Status levels:
  - **Passing** — current grade is comfortably above passing (green)
  - **At Risk** — within 0.25 grade points of the passing threshold (yellow)
  - **Failing** — at or below the passing threshold (red)
- The passing threshold must be configurable per grading system (e.g., 3.00 for UP, 1.0 for DLSU 4-Point, 75% for percentage-based schools).
- For scholarship holders who set a target GWA (see P1-01), an additional chip shows **"Below Target"** when the course grade would drag overall GWA below the target.

**Affected personas:** Trisha, Kuya Jun, Andi.

---

### P0-03: Letter Grade Display for US/4-Point System Users

**Problem:** The GWA ring and course list display a number (e.g., "3.70" or "4.00") even for users on the US or 4-Point grading system. ADMU students think in "A-", DLSU students think in "4.0" — but the UI never shows them the letter they care about.

**Requirement:**
- For users on the `US` grading system: display the letter grade equivalent (A, A-, B+, B, etc.) alongside or below the numeric GPA in the ring and in each course card.
- For users on the `4Point` system: display the numeric GPA (e.g., "4.0") as the primary ring value (already done), but add the descriptive label (Excellent, Superior, Very Good, etc.) as a subtitle.
- The `getUSLetter()` method already exists in `grading_system.dart` — this is a UI-only change.

**Affected personas:** Gab (ADMU), Bea (DLSU).

---

## 5. P1 Requirements — High Impact (V1.1 Differentiators)

---

### P1-01: Scholarship Mode — GWA Threshold Alert

**Problem:** DOST, CHED, and university-specific scholars must maintain a minimum GWA every semester or face suspension of stipend. This is the single highest-stakes use case in the entire Filipino college experience. No existing app addresses it.

**Requirement:**
- In the Term Settings screen, add a **Scholarship Mode** toggle.
- When enabled, the student inputs their required GWA floor (e.g., 2.50 for DOST, 1.75 for some private university grants).
- The dashboard GWA ring changes behavior:
  - A thin colored arc (red/yellow/green) appears around the ring, representing proximity to the threshold.
  - Green: more than 0.25 GWA points above threshold.
  - Yellow: within 0.25 GWA points above threshold — "At Risk" warning.
  - Red: at or below threshold — "Below Scholarship Requirement" banner shown.
- When a student enters a new grade that pushes them below the threshold, a local push notification fires: *"Heads up — your GWA just dropped to 2.62, below your 2.50 scholarship requirement."*
- The "Goal Simulator" (existing slider feature) should show the threshold line on the slider track for visual context.

**Why this wins:** Every DOST scholar (10,000+ active) has this as their number one anxiety. This feature will be screenshot-shared in every DOST scholar Facebook group and Viber chat in the country. It is the highest single virality driver available.

**Affected personas:** Andi and all scholarship holders.
**Novel contribution:** No competitor — local or global — offers scholarship-specific GWA threshold monitoring with push alerts.

---

### P1-02: Cumulative GWA (Cross-Semester View)

**Problem:** Klaro currently scopes GWA to the active term only. But Latin honors, DOST retention, program transfers, and graduation requirements all depend on a **cumulative GWA** across all semesters. Students cannot use Klaro as their single source of truth for academic standing over their full college career.

**Requirement:**
- Add a **Cumulative GWA** toggle on the dashboard alongside the existing term GWA ring. Default view remains "This Semester."
- Cumulative GWA calculation: `Σ(Course Grade × Units) / Σ(Total Units)` across all terms, using only courses that have at least one grade entry (exclude future/empty terms).
- In the Cumulative view, the ring displays the all-time GWA and the subtitle changes to "Cumulative — All Semesters."
- Terms screen should show a per-term GWA history list (e.g., 1st Sem AY 2023: 1.85 · 2nd Sem AY 2023: 2.00 · ...).
- If Scholarship Mode is active (P1-01), the alert evaluates per-term GWA, not cumulative — since most scholarships evaluate each semester independently.

**Affected personas:** Marco, Bea, Andi, all graduating students.

---

### P1-03: Graduation Target / Latin Honors Tracker

**Problem:** Graduating seniors trying to achieve Cum Laude, Magna Cum Laude, or Summa Cum Laude have no tool that tells them what average they need across their remaining courses. This is a high-emotion, high-motivation feature for students in their final year.

**Requirement:**
- In Settings or the Cumulative GWA view, add a **Graduation Target** input.
- Student enters their target designation:
  - For UP: Cum Laude (1.45–1.75), Magna Cum Laude (1.20–1.44), Summa Cum Laude (1.00–1.19) — thresholds are college-specific, so allow custom input.
  - For DLSU: Cum Laude (3.400–3.574), Magna Cum Laude (3.575–3.749), Summa Cum Laude (3.750–4.000).
  - For US/ADMU: custom GPA target (e.g., 3.5 for Cum Laude equivalent).
- The app computes: *"To reach your target of 1.75, you need an average grade of X.XX across your remaining Y units."*
- This is displayed as a persistent banner on the Cumulative GWA view: **"You need a 1.85 average in your remaining 21 units to reach Cum Laude."**
- If the target is already mathematically impossible given earned units, surface that clearly: **"Cum Laude is no longer achievable this path. Magna Cum Laude requires an average of 1.20 — possible if all remaining grades are 1.25 or better."**

**Affected personas:** Bea (DLSU), Marco (UP honors track), any graduating student.
**Novel contribution:** Target GPA app does something similar but only for semester GPA, not cumulative honors targets. No Philippine tool does this at all.

---

### P1-04: "What If I Drop This Subject?" Simulator

**Problem:** Students facing a failing course often need to decide: withdraw and protect the GWA, or push through and risk a 5.0? The calculation is complex (depends on units, current GWA, number of units already locked in) and students currently do it manually or not at all. Missing a drop deadline because the math wasn't done in time is a genuine harm.

**Requirement:**
- On each course detail screen, add a **"Simulate Dropping This Course"** option (accessible via long press or course action menu).
- When activated, the course is visually marked as "Withdrawn" (greyed out with a badge) and the dashboard GWA ring updates in real-time to reflect GWA without that course.
- A bottom sheet appears showing:
  - Current GWA (with course): X.XX
  - Projected GWA (without course): X.XX
  - Net change: ▲/▼ X.XX
  - If Scholarship Mode is active: whether dropping improves or worsens scholarship standing.
- The simulation is non-destructive — no data is deleted. Tapping "Restore" reverts to normal state.
- The drop simulation should respect the `includeGoals` flag from the existing `_calculateGwaImpl` — only real grades, not goal assessments, factor into the post-drop projection.

**Affected personas:** Andi, Marco, any student near a withdrawal deadline.

---

### P1-05: Academic Probation Risk Counter (UP/Retention-Policy-Aware)

**Problem:** At UP Diliman, a student is placed on probation if they fail 50–75% of their enrolled units, and dropped from the rolls if they fail 76% or more. The 76% is measured in **units**, not subject count — a student can fail 3 of 5 subjects but if those 3 subjects are worth fewer units than the 2 they passed, they may be fine. This math is opaque and causes enormous anxiety.

**Requirement:**
- In the term overview or Settings, add an optional **Retention Policy** configuration:
  - Probation threshold: default 50% of enrolled units with grade below passing.
  - Dismissal threshold: default 76% of enrolled units with grade below passing.
  - These thresholds should be editable for students whose colleges have stricter policies.
- On the dashboard, when the student has at least one course trending toward a failing grade, surface a **Retention Risk banner**:
  - "You are failing X units of Y total enrolled units (Z%). Probation threshold is 50% (W units)."
  - Color-coded: green (<30%), yellow (30–49%), red (50%+).
- A "failing" course is one where the current projected grade is at or below the defined passing threshold for the grading system.

**Affected personas:** Marco (UP), any student at a school with unit-based retention policies.
**Novel contribution:** No app in the market — local or global — implements a retention risk monitor tied to institutional policy.

---

### P1-06: Onboarding Grading System Guide (Context-Aware Labels)

**Problem:** The onboarding screen asks users to pick their grading system, but provides no context for which university uses which system. A DLSU student doesn't know if they're "4-Point" or "US." An ADMU student doesn't know if they're "US" or something else. Trisha from a private nursing school doesn't know what transmutation is.

**Requirement:**
- Rework the grading system selection screen in onboarding to include:
  - **University examples** under each option: *"5-Point (1.0–5.0) — Used by UP, PUP, Bicol University, most SUCs"*; *"4-Point (0.0–4.0) — Used by DLSU, Mapua"*; *"US / Letter Grade — Used by ADMU, many international programs"*
  - A new **"My school uses transmutation"** checkbox that appears when any system is selected, explaining: *"Many private universities convert your raw score to a grade using a formula. Enable this if your professor computes grades using a transmutation table."*
  - A **"I'm not sure"** option that leads to a short 3-question mini-quiz (What does your prof say is passing? Does your grade card show 1.0–5.0 or A–F or 75–100?) that auto-selects the right system.
- In-app: add a "?" tooltip on every weight field, every component name field, and the GWA ring with a one-sentence plain-language explanation.

**Affected personas:** Trisha, Gab, Kuya Jun — any first-year or first-gen student.

---

## 6. P2 Requirements — Growth (V1.2 Viral & Retention Features)

---

### P2-01: Shareable Grade Snapshot Card

**Problem:** Filipino students share everything in group chats — Messenger, Viber, Discord. There is currently no way to share your Klaro standing. This is a missed virality channel. Erika's persona (the peer academic advisor) is blocked because she cannot show a friend their grade scenario without handing over her phone.

**Requirement:**
- Add a **"Share My Standing"** action on the dashboard and on individual course detail screens.
- Generates a clean, beautifully designed PNG card (Klaro-branded, using the app's Claymorphism aesthetic) that includes:
  - The GWA ring with the current value prominently displayed.
  - A list of courses with their current grade and status.
  - The student's name (optional, toggleable for privacy).
  - The Klaro logo and tagline: *"Grades, made clear."*
- The card is generated entirely on-device (no server upload, no data leaving the phone).
- Uses Flutter's `RepaintBoundary` + `RenderRepaintBoundary` to capture the widget as an image and share via the native share sheet.
- Privacy mode: student can toggle individual course names off before sharing (show just grades, not subject names).

**Why this wins:** A beautiful, shareable card is the single fastest way for Klaro to spread through college group chats — which is how every Filipino student discovers new apps. This is the organic marketing engine.

**Affected personas:** Erika, any student who wants to show parents they're doing okay.

---

### P2-02: INC (Incomplete) Grade State

**Problem:** An "Incomplete" grade in Philippine universities is a grade in limbo — the student has not finished requirements, so the grade is neither a pass nor a fail. It does not count toward GWA until resolved. Klaro has no concept of this state, so students either leave the course blank (which underrepresents their load) or enter a placeholder (which corrupts the GWA).

**Requirement:**
- Add an **"Incomplete (INC)"** status option at the course level (not assessment level).
- When a course is marked INC:
  - It is excluded from GWA calculation (matching registrar behavior).
  - A distinct visual treatment on the dashboard card: grey badge, italic course name, INC label.
  - An optional reminder can be set for when the INC must be resolved (Philippine schools typically give one semester).
- When the INC is resolved (student enters final grade), the course re-enters GWA calculation normally.

**Affected personas:** Andi (at-risk of needing an INC due to scholarship pressure), any student.

---

### P2-03: Home Screen Widget (Quick Score Entry)

**Problem:** Kuya Jun, the exhausted working student, won't open the app after a graveyard shift. But he just got his quiz back and needs to enter a score. If he has to navigate three taps deep, he won't do it. A home screen widget that shows his current GWA and lets him log a score in one tap closes this gap.

**Requirement:**
- iOS: WidgetKit widget in Small and Medium sizes.
- Android: App Widget in 2×2 and 4×2 sizes.
- Small widget: shows current GWA ring (simplified, static) and a "+" button that deep-links directly to the score entry sheet for the most recently accessed course.
- Medium widget: shows GWA + list of 3 courses with their current grade + one-tap score entry per course.
- Widgets read from the Drift database directly (no network required — fully offline).
- Update on each database write via a Riverpod listener that calls `WidgetKit.reloadAllTimelines()`.

**Affected personas:** Kuya Jun, any student who checks their phone constantly between classes.

---

### P2-04: Offline-First Trust Signal

**Problem:** Klaro is built on SQLite/Drift and works entirely offline. But students don't know this — they assume apps need the internet. Kuya Jun in a weak-signal province might not open Klaro because he thinks it won't work. This is a perception problem, not a technical one.

**Requirement:**
- Display a persistent **"All data stored on your device"** badge in the Settings screen with a short explanation: *"Klaro works 100% offline. Your grades are never uploaded to any server."*
- On the dashboard, display a small **"Offline"** or **"Saved locally"** indicator (not an error — a feature badge, styled positively in the Klaro brand).
- In onboarding, add a dedicated slide or callout: *"No internet? No problem. Klaro works without Wi-Fi — your data lives on your phone, not in the cloud."*
- This is especially meaningful given that the app already works offline — this requirement is purely about surfacing the fact to users.

---

### P2-05: Image-Based Syllabus Parsing (Vision AI)

**Problem:** The current AI syllabus parser accepts PDF text. But many Philippine professors distribute syllabi as scanned images, photographs, or hand-written tables. The parser fails silently for these, and Kuya Jun's entire "magic" setup experience breaks.

**Requirement:**
- Upgrade the `AiSyllabusService` to accept image inputs in addition to extracted text.
- Use Gemini's multimodal (vision) capability: pass the image bytes directly to the model with the same extraction prompt.
- User flow: when a PDF fails text extraction (empty text result), automatically offer: *"We couldn't read text from this file. Try uploading a photo of your syllabus instead."*
- Add a camera capture option in the syllabus import flow — student can photograph the grading breakdown section of a printed syllabus and the AI extracts components from the image.
- Model: `gemini-2.5-flash-lite` already supports multimodal input — this requires updating the `Content` construction to use `DataPart` with image bytes.

**Affected personas:** Kuya Jun, any student at a school with digitally inaccessible syllabi.

---

## 7. P3 Requirements — Vision (V2.0+)

These are platform-level features for after Product-Market Fit is confirmed. They represent Klaro's potential to become academic infrastructure, not just a utility app.

---

### P3-01: Cloud Sync + Multi-Device (Supabase)

**Requirement:** Optional account creation backed by Supabase. All data syncs across devices. Students who lose their phone don't lose their grade history. This is already in the original UPDATES.md roadmap.

**Key design constraint:** Sync must be optional. Klaro's offline-first, no-account experience must remain the default and must always work fully. Cloud sync is an opt-in upgrade, never a requirement.

---

### P3-02: Probation/Dismissal Early Warning via Notifications

**Requirement:** When a student's simulated grade on an upcoming exam (ghost assessment) would push them into probation territory, fire a local push notification proactively: *"Based on your goal grades, you're projecting a 2.78 this semester. You need 2.50 or better for your DOST scholarship."* This turns Klaro from a reactive tracker into a proactive academic advisor.

---

### P3-03: Professor Grading Pattern Library (Community-Sourced)

**Requirement:** Allow students to optionally share anonymized grading component templates (e.g., "Prof. X's Calculus: 30% quizzes, 30% midterm, 40% final") that other students in the same university can import. This crowdsources the setup tax for new users and eliminates the AI parser dependency entirely for well-known courses.

**Privacy considerations:** University name and course name are shared; professor name is optional and anonymized by default. No personal grade data is ever uploaded.

---

### P3-04: Cross-Enrollment and Grade Transfer Calculator

**Requirement:** Students who cross-enroll at partner institutions (a common strategy for recovering from a failed prerequisite) often have grades from multiple schools in one semester. Add a "Cross-Enrolled Course" flag that allows a student to add a course from a different institution with a different grading system — the app converts it to the student's primary system before computing GWA.

---

## 8. Requirements Summary Table

| ID | Requirement | Priority | Effort | Impact | Persona(s) |
|---|---|---|---|---|---|
| P0-01 | Grade Transmutation Engine | P0 | High | Critical | Trisha, Jun, all private U students |
| P0-02 | Passing / At Risk / Failing Status Label | P0 | Low | Critical | Trisha, Jun, Andi |
| P0-03 | Letter Grade Display for US/4-Point | P0 | Low | High | Gab, Bea |
| P1-01 | Scholarship Mode + GWA Threshold Alert | P1 | Medium | Very High | Andi, all scholars |
| P1-02 | Cumulative GWA (Cross-Semester) | P1 | Medium | Very High | Marco, Bea, Andi |
| P1-03 | Graduation Target / Latin Honors Tracker | P1 | Medium | High | Bea, graduating seniors |
| P1-04 | "What If I Drop This Subject?" Simulator | P1 | Medium | High | Andi, Marco |
| P1-05 | Academic Probation Risk Counter | P1 | Medium | High | Marco, retention-policy schools |
| P1-06 | Onboarding Grading System Guide | P1 | Low | High | Trisha, Gab, first-year students |
| P2-01 | Shareable Grade Snapshot Card | P2 | Medium | Very High (viral) | Erika, all users |
| P2-02 | INC (Incomplete) Grade State | P2 | Low | Medium | Andi, any student |
| P2-03 | Home Screen Widget | P2 | High | High | Jun, habitual users |
| P2-04 | Offline-First Trust Signal | P2 | Low | Medium | Jun, low-signal users |
| P2-05 | Image-Based Syllabus Parsing | P2 | High | High | Jun, image-PDF users |
| P3-01 | Cloud Sync (Supabase) | P3 | Very High | High | All users |
| P3-02 | Proactive Probation Notifications | P3 | Medium | High | Marco, scholarship holders |
| P3-03 | Professor Template Library | P3 | Very High | Medium | All users |
| P3-04 | Cross-Enrollment Grade Calculator | P3 | High | Medium | Transfer students |

---

## 9. Recommended Sprint Order

### Sprint 1 — Fix What's Wrong (P0)
1. `P0-01` Transmutation engine (course-level toggle, Base 50 / Base 60 / Base 0)
2. `P0-02` Passing / At Risk / Failing chip on dashboard + course detail
3. `P0-03` Letter grade display in ring and course list for US/4-Point users

### Sprint 2 — Win Filipino Students (P1, Part 1)
4. `P1-01` Scholarship Mode + GWA threshold alert + notification
5. `P1-06` Onboarding grading guide with university examples + tooltips
6. `P1-02` Cumulative GWA view (term history list + toggle on dashboard)

### Sprint 3 — Become the Smartest App in the Room (P1, Part 2)
7. `P1-04` "What If I Drop?" subject withdrawal simulator
8. `P1-05` Academic probation/dismissal risk counter
9. `P1-03` Graduation target / Latin honors tracker

### Sprint 4 — Make It Spread (P2)
10. `P2-01` Shareable grade snapshot card
11. `P2-02` INC grade state
12. `P2-04` Offline-first trust signal (onboarding slide + settings badge)
13. `P2-03` Home screen widget (iOS + Android)
14. `P2-05` Image-based syllabus parsing (Gemini Vision)

### Sprint 5 — Build the Platform (P3)
15. `P3-01` Cloud sync via Supabase (optional, opt-in)
16. `P3-02` Proactive push notifications for probation/scholarship risk
17. `P3-03` Community professor template library
18. `P3-04` Cross-enrollment grade converter

---

## 10. Novel Contributions Summary

The following requirements represent capabilities that **no existing grade tracker app — Filipino or global — currently offers.** These are Klaro's true differentiators and should be highlighted in App Store copy and marketing materials.

1. **Transmutation-aware grading** — The only mobile app that correctly models Philippine-style grade transmutation at the course level.
2. **Scholarship GWA threshold monitoring** — The only app that tracks whether a student is at risk of losing their DOST/CHED scholarship in real-time.
3. **Academic probation risk counter** — The only app that applies institutional dismissal/probation policy (unit-based) to live grade data.
4. **AI syllabus parsing (text + image)** — The only Philippine grade tracker that eliminates setup tax via AI, including for scanned/photographed syllabi.
5. **Graduation honors projection** — The only Philippine app that tells a student what GWA they need across remaining courses to reach their Latin honors target.
6. **"What If I Drop?" simulation** — No competitor offers a non-destructive course withdrawal simulator integrated with live GWA computation.

---

## Sources

- [Top 7 Apps for Tracking Grades and GPA — StudyGuides.com](https://studyguides.com/articles/top-apps-for-tracking-grades-and-gpa)
- [Grade Pal — App Store](https://apps.apple.com/us/app/grade-pal-1-grade-tracker/id1442410668)
- [Grades – Grade Calculator, GPA — App Store](https://apps.apple.com/us/app/grades-grade-calculator-gpa/id1069653513)
- [Gradekit: Track Grades & GPA — App Store](https://apps.apple.com/us/app/gradekit-track-grades-gpa/id947291514)
- [Target GPA: Grades Tracker — App Store](https://apps.apple.com/us/app/target-gpa-grades-tracker/id1633708222)
- [Power Planner — App Store](https://apps.apple.com/us/app/power-planner/id1278178608)
- [Gradebook — gradebook.app](https://www.gradebook.app/)
- [PowerPlanner Review — EducationalAppStore](https://www.educationalappstore.com/app/power-planner)
- [10 Best Student Planner Apps in 2026 — Planwiz](https://blog.planwiz.app/top-daily-planner-apps-for-students/)
- [DOST Scholarship 2025-2026 — owwascholarships.com](https://owwascholarships.com/dost-scholarship-2025/)
- [Best Scholarships in the Philippines Using GWA — bestgwacalculator.info](https://bestgwacalculator.info/scholarships-in-the-philippines/)
- [DepEd Transmutation Table Formula — depedph.com](https://depedph.com/transmutation-table/)
- [Understanding Grade Transmutation in DepEd — ilovedeped.net](https://www.ilovedeped.net/2024/03/understanding-grade-transmutation-in.html)
- [Formula in Grade Transmutation — MrExcel Message Board](https://www.mrexcel.com/board/threads/formula-in-grade-transmutation.798220/)
- [GPA Academic Honors — gpacalculator.org](https://gpacalculator.org/gpa-academic-honors.html)
- [A Guide to Graduation Honors: GPA Requirements and Latin Honors Explained — thegpacalculator.com](https://thegpacalculator.com/blog/graduation-honors-gpa-requirements)
- [Rules on Scholastic Standing — UP Diliman OUR](https://our.upd.edu.ph/files/acadinfo/RULES%20ON%20SCHOLASTIC%20STANDING.pdf)
