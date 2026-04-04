



Here is the master summary of the **Klaro** project. This serves as our official internal documentation, summarizing everything we have architected, built, and planned.

---

# 🚀 Project Overview: Klaro
**Tagline:** *Grades, made clear.*
**Mission:** To replace anxiety with strategy. Klaro is an offline-first, AI-powered academic GPS that helps college students track their real-time standing, simulate future scenarios, and eliminate the "setup tax" of manual grade tracking.

### 🛠️ 1. Tech Stack & Architecture
*   **Framework:** Flutter (Mobile-first, cross-platform).
*   **State Management:** Riverpod (Modern, code-generated asynchronous state).
*   **Local Database:** Drift / SQLite (Relational, strictly typed, 100% offline-capable).
*   **AI Integration:** Google Gemini 1.5 Flash API (For fast, cheap, and highly accurate text extraction).
*   **Architecture Pattern:** Clean Architecture (Separation of UI, Business Logic, and Data layers).

### ✨ 2. Core Features (What the App Does)
*   **The Dashboard:** A beautiful, color-coded circular ring displaying the student's real-time General Weighted Average (GWA) and a list of active courses with their targets.
*   **AI Syllabus Parser (The "Magic"):** Users upload a PDF of their course guide. The app uses AI to instantly extract the grading components (e.g., "Midterms 30%, Quizzes 20%") and builds the course structure automatically.
*   **Dynamic Grading Buckets:** Users don't need to define exactly how many quizzes there are. They just add scores to the "Quizzes" bucket (e.g., 15/20), and the app automatically recalculates the running percentage.
*   **The Goal Simulator (Slider):** A sandbox tool where users ask, *"What do I need on the Final to get a 1.75?"* They slide a bar and watch their projected grade change in real-time.
*   **"Ghost" / Goal Assessments:** Users can add hypothetical upcoming exams (marked distinctly in purple) to model specific future scenarios.
*   **Edge Case Handling:** Supports "Excused/Exempted" activities (removes them from the math) and handles bonus points.
*   **Gamification:** A profile system that rewards users with cute 3D badges (like the "Beta Builder" hard-hat mascot).

### 🧠 3. The Math & Logic Engine
The core logic was built to be highly robust to handle unpredictable professors:
1.  **Component Level:** `(Sum of Earned Scores / Sum of Total Possible Scores) * 100` = Category Percentage.
2.  **Course Level:** Multiplies each Category Percentage by its defined weight (e.g., 90% * 0.30 weight).
3.  **Grade Conversion:** Converts the final normalized percentage into the university's specific grade scale.
4.  **GWA Level:** `Sum of (Course Grade * Course Units) / Total Units`.

### 🎓 4. Supported Grading Systems
*   **Active/Completed:** **University of the Philippines (UP) System.**
    *   Scale: 1.0 (Excellent) down to 5.0 (Fail).
    *   Logic: "Descending Tier" mapping (e.g., >= 92% = 1.25).
*   **Scaffolded (In UI, needs logic implementation):** **US / International System.**
    *   Scale: A (4.0) down to F (0.0).
    *   Logic: "Ascending Tier" mapping (e.g., >= 90% = A).

### 🎨 5. UI/UX & Branding
*   **Aesthetic:** "Kawaii-Minimalist" meets "High-Budget Startup" (similar to Notion or Duolingo).
*   **Visual Style:** Claymorphism (soft, matte, 3D textures), squircle (rounded) cards, and ample white space.
*   **Color Palette:** Pastel Sage Green / Mint (Primary), Lavender/Purple (Accent), Deep Navy (Text), and White/Soft Grey (Backgrounds).
*   **Mascot:** A cute, squishy 3D blob character that wears different hats (Graduation cap, Construction hard hat for Beta testers).

### 📍 6. Current Project Status
*   **Phase:** **Beta Testing.**
*   **Milestones Achieved:**
    *   Core database and logic are fully functional.
    *   AI Integration is live.
    *   Onboarding screen and preferences routing established.
    *   Play Store / App Store marketing assets (6-image panorama showcase) designed and structured.
    *   Beta tester outreach email drafted.

---

### 📋 7. What Needs to Be Done Next (The Roadmap)

**Immediate Term (Pre-Launch Polish):**
*   [ ] **Fix UI Artifacts:** Remove the "Detecting face..." pill from the simulator screenshots.
*   [ ] **Implement US Grading Logic:** Connect the Onboarding selection (US vs. UP) to a Strategy Pattern in the math engine so international users can use the app accurately.
*   [ ] **Feedback Loop:** Monitor the Beta Tester Google Form for crashes or AI parsing failures.

**Medium Term (V1.1 & Scaling):**
*   [ ] **Transmutation Toggle:** Add a setting inside courses to allow students to choose between "Base-0" and "Base-50" passing math.
*   [ ] **Badge Logic in DB:** Actually write the code to unlock the "Beta Builder" badge in the UI when the user creates their first course.
*   [ ] **Cloud Sync (Supabase/Firebase):** Allow users to back up their grades so they don't lose them if they delete the app.

---

## 🔧 Polish & Bug Fix Log (Pre-Launch)

> Tracked during code review session. Each item corresponds to one commit.

| # | Area | Issue | Status |
|---|------|-------|--------|
| P-01 | Grade Simulator | Hardcoded `convertToUPGrade()` ignores user's selected grading system | ✅ Fixed |
| P-02 | Contact Screen | GCash "Copy Number" copies placeholder `09XXXXXXXXX` instead of real number | ✅ Fixed |
| P-03 | Onboarding | "Get Started" CTA appears one page too early (condition `< 2` should be `< 3`) | ✅ Fixed |
| P-04 | Theme | `Colors.purpleAccent` used directly instead of `theme.colorScheme.secondary` | ✅ Fixed |
| P-05 | Icons | Mixed Material Icons and Phosphor Icons — standardize to Phosphor throughout | ✅ Fixed |
| P-06 | Dashboard | GWA ring tap-to-toggle has no visual affordance (hidden interaction) | ✅ Fixed |
| P-07 | pubspec.yaml | Description still says "A new Flutter project." — unprofessional for store listing | ✅ Fixed |
