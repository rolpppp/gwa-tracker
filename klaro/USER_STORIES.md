# Klaro: User Story Validation Report
### *Do we actually solve Filipino college students' problems?*

> Generated: March 2026
> Purpose: Evaluate Klaro's feature coverage against real Filipino college student pain points, and identify gaps to prioritize in the roadmap.

---

## Research Basis

This report synthesizes data from:
- Philippine university retention and probation policies (UP Diliman OUR, CHED, DOST-SEI)
- Scholarship GWA requirement documentation
- Academic stress research on Filipino students
- Online student communities (r/peyups, r/Philippines, r/phcareers discussion themes)
- Grade computation resource sites (bestgwacalculator.info, hamnus.com, gwacalculator.net)

---

## The Seven User Personas

---

### Persona 1 — Andi, 2nd Year BS Biology, State University, DOST Scholar

> *"I check my grades every week kasi one failed subject and goodbye scholarship. Nag-eExcel pa ako kasi wala akong trusted app."*

**Background:** Provincial student, DOST-SEI scholar, living in a dorm away from family. Her scholarship requires a minimum **2.5 GWA** (85% equivalent) every semester. One failed subject risks suspension of stipend — P7,000/month she depends on for rent and food. She's taking 8 subjects with different grading breakdowns: lab reports (20%), quizzes (30%), long exams (50%) — each professor has their own formula.

**Pain Points:**
- Manually computing 8 course grades across different component weights is error-prone
- She doesn't know her "safe zone" — is she at 2.3 or 2.7 right now?
- She has no early warning before it's too late to drop a subject
- Her Excel sheet breaks when she adds bonus points

**How Klaro helps today:**

| Feature | Coverage |
|---|---|
| Dynamic grading buckets per component | Full — she can add each quiz/exam/lab score |
| AI Syllabus Parser | Partial — extracts components from PDF syllabi |
| Real-time GWA ring | Full — shows her standing at a glance |
| Goal Simulator | Full — "what do I need on finals to stay at 2.5?" |
| Ghost/Goal assessments | Full — plan upcoming exams before they happen |

**Where Klaro falls short:**

- **No scholarship threshold alert.** Andi has no way to set "warn me if I drop below 2.5" — she has to manually check. This is the single highest-stakes feature missing for this persona.
- **No "safe to drop?" calculator.** She can't ask: "if I withdraw from Biochem, what happens to my GWA?"
- **No INC grade handling.** If she gets an Incomplete, that grade is in limbo — the app has no state for it, yet it affects her standing.
- **AI Parser friction on lab syllabi.** Biology syllabi often embed grade tables in image-scanned PDFs. The AI can't parse images yet.

**Severity: HIGH.** Andi is one of Klaro's most critical users. The scholarship-at-risk scenario is extremely common (DOST alone has ~10,000 active scholars) and Klaro is close but misses the alarm feature that would make it life-changing for her.

---

### Persona 2 — Marco, 3rd Year BS Computer Science, UP Diliman

> *"Natatakot ako sa 'dropped from the rolls.' Kailangan ko alamin kung ilan pa ang pwedeng bagsak ko."*

**Background:** UP student on the 1.0–5.0 scale. The university's dismissal policy is brutal: fail 76% or more of your units in a semester → dropped from the college. He's in a hard semester with 6 subjects — he already knows he's failing one. He needs to know how many more he can afford to fail without hitting the threshold.

**Pain Points:**
- The 76% rule is based on *units*, not subject count — the math is not intuitive
- He wants to simulate "what if I get 5.0 in Algos?" without manually computing
- His professors don't follow standard breakdown — one uses 100% final exam, another uses 60/40 midterm/final split
- He's tracking "can I still salvage this?" daily but has no structured tool

**How Klaro helps today:**

| Feature | Coverage |
|---|---|
| UP 5-Point grading system | Full |
| Goal Simulator (slider) | Full — "what do I need on finals?" |
| Ghost assessments | Full — model the worst case |
| Real vs Projected GWA split | Full — excellent for this use case |
| Term scoping | Full |

**Where Klaro falls short:**

- **No dismissal/probation risk calculator.** Marco cannot ask "how many units can I fail before I'm on probation?" — this requires knowing UP's policy and applying it to his current enrollment. This is a missing layer entirely.
- **No subject-level "fail risk" indicator.** The dashboard shows GWA but doesn't flag individual courses where a student is trending toward a failing grade (3.0 or above in UP scale).
- **No cumulative multi-semester GWA.** UP tracks cumulative standing for graduation honors and program transfers. Klaro is term-only.

**Severity: HIGH.** Marco's use case needs a "risk dashboard" layer on top of what's already working well.

---

### Persona 3 — Bea, 4th Year BS Accountancy, De La Salle University

> *"DLSU uses a different scale — 0.0 to 4.0. Yung ibang GWA calculators online, UP system palagi."*

**Background:** DLSU student using their 4-point scale (97%+ = 4.0, 70%–74% = 1.0, below 70% = 0.0). She's in her final semester and gunning for Cum Laude (3.5 GWA equivalent at DLSU). She has 5 subjects left and uses a spreadsheet to model her scenarios.

**Pain Points:**
- Almost all Philippine GWA tools online are UP-system-only — she's always converting manually
- She wants to project: "if I get 3.5 in all remaining subjects, do I still make Cum Laude?"
- Her Accountancy courses have unusual breakdowns (Board Exam simulations counted as 40% of final grade)

**How Klaro helps today:**

| Feature | Coverage |
|---|---|
| 4-Point grading system | Now supported (recent update) |
| Goal Simulator | Full — can model each remaining course |
| Ghost assessments | Full — great for modeling finals |
| AI Syllabus Parser | Partial |

**Where Klaro falls short:**

- **No Latin honors / graduation target tracker.** Bea cannot set "target: Cum Laude (3.5)" and have the app tell her "you need X average across remaining Y courses." This would be the killer feature for graduating seniors.
- **DLSU's specific grading nuances.** DLSU has a "no rounding up" policy and uses course-specific cutoffs for some programs — the generic 4-point converter may not match exactly.
- **No cumulative GWA across all semesters.** Cum Laude eligibility requires a cumulative across all years, not just the current term.

**Severity: MEDIUM-HIGH.** The 4-Point system support is a great start. The graduation honors layer is what seals the deal for this persona.

---

### Persona 4 — Kuya Jun, 3rd Year BS Education, Working Student, Cebuano Regional University

> *"Nag-iisip pa rin ako kung matatapos ko talaga. May trabaho na ako part-time, hindi ako makaka-aral ng maayos."*

**Background:** Works as a call center agent (graveyard shift, 3 nights/week) to pay tuition. He's exhausted and can barely keep up. He doesn't have time to obsessively track grades — he just needs to know "okay pa ba ako?" at a glance, and to know when something is critically wrong.

**Pain Points:**
- No time for complex tools — needs a sub-30-second check-in
- His university uses a percentage system with a 75% passing threshold — not UP scale
- He often misses quizzes (excused absences) and needs those removed from calculations
- He has no one to ask if his computation is correct — no academic advisor access

**How Klaro helps today:**

| Feature | Coverage |
|---|---|
| GWA ring (at-a-glance) | Full — designed exactly for this |
| Excused/Exempted assessments | Full — removes missed items correctly |
| Dashboard overview | Full |
| Onboarding (grading system picker) | Full |

**Where Klaro falls short:**

- **The AI Parser requires PDF uploads.** Jun's university often distributes syllabi verbally or as scanned images. The "magic" of Klaro doesn't work for him without digital PDFs.
- **Manual setup tax is still high.** Even with the parser, if it fails (image PDFs), Jun has to manually create every component for every course. That's friction he won't tolerate when he's running on 4 hours of sleep.
- **No quick-add shortcut.** Adding a new score requires navigating to the course, then component, then tap add. For Jun, this needs to be a widget or notification shortcut.
- **No offline-first guarantee surfaced to user.** Jun is often in areas with poor signal. The app is SQLite-based (offline-first) but users don't know this — they might not trust it without seeing a clear offline indicator.

**Severity: MEDIUM.** Klaro's visual design is perfect for Jun, but the setup burden and no-PDF-parser scenario are real blockers.

---

### Persona 5 — Trisha, 1st Year BS Nursing, Private Catholic University, First-Gen Student

> *"Hindi ko alam kung passing na ako or hindi. Sinabi ng prof na '75 is passing' pero yung grade ko sa portal ay 2.25 — ano 'to?"*

**Background:** First-generation college student. Her family never went to college and can't help her understand grades. Her university uses a transmutation table — raw scores are transmuted before being recorded. She doesn't know if she's passing because the grading system is opaque. She's anxious every day.

**Pain Points:**
- Doesn't understand the difference between raw score, transmuted grade, and GWA
- Doesn't know where she stands until professors release grades — often after drop deadlines
- No one around her has navigated this before
- Needs hand-holding, not just a calculator

**How Klaro helps today:**

| Feature | Coverage |
|---|---|
| Simple score entry (earned/total) | Full — no math knowledge required |
| Real-time grade feedback | Full — updates as she types |
| Onboarding education | Partial — covers grading system types |

**Where Klaro falls short:**

- **Transmutation is not implemented.** This is explicitly in the roadmap ("Base-0 vs Base-50 transmutation toggle"). Without it, Trisha's computed grade won't match her professor's portal. This breaks trust in the app for a user who already doesn't trust her own understanding.
- **No in-app education layer.** Klaro assumes the user knows what "weight" means. Trisha doesn't. A tooltip explaining "this is how much this exam counts toward your final grade" would significantly lower the learning curve.
- **No "is this passing?" visual.** The app shows the grade value (e.g., 2.25) but a first-gen student doesn't know if 2.25 is good or bad in context. A simple "Passing / At Risk / Failing" label per course would be transformative.

**Severity: HIGH.** Transmutation is the most common grading method in Philippine private universities (Nursing, Education, Business). Without it, Klaro's calculations are wrong for a huge user segment.

---

### Persona 6 — Gab, 2nd Year BS Architecture, Ateneo de Manila University

> *"Our system is A, B+, C — parang American. Hindi pa rin tama yung computation ng ibang apps."*

**Background:** ADMU student on the A-F letter grading system (with +/- modifiers). GPA is computed differently from UP's 1.0–5.0. He wants a tool that speaks his grading language, not one that feels like it was built only for UP students.

**Pain Points:**
- Most Philippine GWA tools are built for the UP system — he feels excluded
- His grading breakdown uses "Class Standing (CS)" which is continuous throughout the semester, not discrete prelim/midterm/finals
- He wants to track CS points earned vs. CS points possible, rolled up to letter grade

**How Klaro helps today:**

| Feature | Coverage |
|---|---|
| US Grading System | Partial — numeric conversion works, letter grade display works |
| Dynamic grading buckets | Full — "Class Standing" can be a single rolling bucket |
| Goal Simulator | Full |

**Where Klaro falls short:**

- **US grading logic is scaffolded but the UX doesn't explain it.** The onboarding picker shows "US / International" but there's no context that this is the right pick for ADMU students. Gab might not know to choose it.
- **No letter grade display in the GWA ring.** The ring shows a number (e.g., "3.70") but Ateneo students think in "A-". The ring and course list should surface letter equivalents for US-system users.
- **"Class Standing" isn't a named concept in the app.** It's just another component, and users would have to know to set it up that way.

**Severity: MEDIUM.** The infrastructure is there. The UX labeling and contextual guidance is missing.

---

### Persona 7 — Erika, 3rd Year BA Communication, State U, Org Leader + Peer Counselor

> *"Lagi akong nagco-compute ng grades ng org mates ko para masagot ang tanong nila. Parang ako na ang academic advisor ng lahat."*

**Background:** Erika is heavily involved in student organizations and often helps her peers compute their grades. She's become the de-facto grade consultant in her circle. She uses Klaro for herself but would love to share computed scenarios with friends.

**Pain Points:**
- No way to export or share a grade scenario with a friend
- Has to re-enter everything every time a friend asks for help
- No way to say "here's your standing, here's what you need to not fail"

**How Klaro helps today:**

| Feature | Coverage |
|---|---|
| Simulator for modeling scenarios | Full |
| Real-time computation | Full |
| All grading systems | Mostly full |

**Where Klaro falls short:**

- **No sharing / export feature.** A "Share my grade scenario" screenshot card (beautifully designed) would spread the app virally among Filipino students through group chats.
- **Single-user only.** No concept of guest mode, demo mode, or link-sharing.
- **No advisor/parent view.** Students want to show their parents "look, I computed this myself and I'm doing okay." A clean read-only export would serve both the student and their family.

**Severity: LOW-MEDIUM.** This is a growth/virality feature more than a core need, but it's a very Filipino use case (bayanihan in academics — helping each other).

---

## Consolidated Gap Analysis

### Critical Gaps (Ship-blocking for key segments)

| Gap | Affected Personas | Suggested Solution |
|---|---|---|
| **Transmutation (Base-50) support** | Trisha (Nursing/private schools) | Transmutation toggle in course settings: raw score to transmuted grade formula |
| **Scholarship GWA threshold alert** | Andi (scholars) | Per-term target GWA with red/yellow/green status and push notification |
| **Cumulative multi-semester GWA** | Bea, Marco (honors, transfers) | Cross-term GWA view — toggle between "this semester" and "all time" |
| **"Passing / At Risk / Failing" label** | Trisha, Kuya Jun | Per-course status label derived from converted grade vs. passing threshold |

### High-Impact Improvements (V1.1 Priority)

| Gap | Affected Personas | Suggested Solution |
|---|---|---|
| **Probation/dismissal risk calculator** | Marco (UP, other retention policies) | "You can fail up to X more units before probation" counter |
| **"What if I drop this subject?" simulator** | Andi, Marco | Toggle a course as "withdrawn" and see GWA impact |
| **Latin honors / graduation target tracker** | Bea | Set a target GPA/GWA (e.g., Cum Laude) and show what's needed across remaining courses |
| **Letter grade display for US system users** | Gab (ADMU) | Show "A-" / "B+" alongside the numeric GPA in ring and course cards |
| **In-app grade system explainer tooltips** | Trisha | Contextual "?" tooltips on weight, GWA, passing threshold |

### Growth / Delight Features (V1.2+)

| Gap | Affected Personas | Suggested Solution |
|---|---|---|
| **Share grade scenario card** | Erika | Generate a shareable PNG card showing course standing + GWA |
| **Image-based syllabus parsing** | Kuya Jun | Vision model integration (Gemini Vision) for scanned PDF/image syllabi |
| **Quick-add home screen widget** | Kuya Jun | iOS/Android widget: tap to enter score for last opened course |
| **Offline badge / "works without internet"** | Kuya Jun | Visible indicator that data is stored locally |
| **INC grade handling** | Andi | Mark assessment as "Incomplete" — excluded from GWA until resolved |
| **"Safe to drop?" GWA impact preview** | Andi, Marco | Show projected GWA if a specific course is removed |

---

## Feature-to-Pain-Point Coverage Map

```
                          Andi   Marco   Bea    Jun    Trisha  Gab    Erika
                        (DOST) (UP CS) (DLSU) (Work) (Nurs.) (ADMU) (Org)

GWA Ring (at-a-glance)    YES    YES    YES    YES    YES     YES    YES
Dynamic Score Buckets      YES    YES    YES    YES    YES     YES    YES
Goal Simulator             YES    YES    YES    YES    PART    YES    YES
AI Syllabus Parser         YES    YES    YES    PART   YES     YES    YES
Ghost Assessments          YES    YES    YES    YES    YES     YES    YES
Excused Assessment         YES    YES    YES    YES    YES     YES    YES
UP 5-Point System          YES    YES     -     YES     -       -     YES
4-Point System              -      -     YES    PART    -       -      -
US/Letter System            -      -      -      -      -      PART    -
Real vs Projected GWA      YES    YES    YES    YES    YES     YES    YES
Transmutation               NO     -      -      NO     NO      -      -
Scholarship Alert           NO     -      -      -      -       -      -
Probation Risk Calculator   -      NO     -      -      -       -      -
Cumulative GWA              NO     NO     NO     NO     NO      NO     NO
Latin Honors Tracker        -      -      NO     -      -       -      -
Share/Export                -      -      -      -      -       -      NO
Pass/Fail Label            PART    -      -      NO     NO      -      -

YES = Covered   PART = Partial   NO = Not Covered   - = Not Applicable
```

---

## Verdict

Klaro's core engine is genuinely strong — the dynamic buckets + goal simulator combination is more sophisticated than any existing Filipino grade tracker tool online (which are all stateless one-shot calculators). The real vs. projected GWA split and active-term scoping are architecture decisions most apps never think about.

The app covers roughly **70–80% of the core daily pain** for UP-system students. For non-UP schools (DLSU, ADMU, private nursing/education programs), coverage drops to **40–55%** — primarily because transmutation and letter-grade UX are unfinished.

**The single highest-ROI fix for the next sprint: Transmutation (Base-50).** It's already in the roadmap, it affects the majority of Philippine private university students, and without it, the app actively shows wrong numbers for a large user segment — which is worse than showing nothing.

**The single highest-virality addition: Scholarship GWA alert.** Filipino scholars are a tight-knit, anxious community. A feature that tells Andi "You are 0.12 below your scholarship threshold" will be screenshot-shared in every DOST scholar group chat in the country.

---

## Sources

- [Depression, Anxiety, Stress, and Academic Performance of Filipino Students — PhilPapers](https://philpapers.org/archive/TUSACP.pdf)
- [DOST Scholarship Maintaining Grade Requirements — Scribd](https://www.scribd.com/document/480007442/Scholarship-policies-Official-Gazette-of-the-Republic-of-the-Philippines)
- [CHED Merit Scholarship Program — ched.gov.ph](https://ched.gov.ph/merit-scholarship/)
- [Best Scholarships in the Philippines Using GWA 2025 — bestgwacalculator.info](https://bestgwacalculator.info/scholarships-in-the-philippines/)
- [3 Easy Ways to Compute Prelim Midterm Final Grades PH — bestgwacalculator.info](https://bestgwacalculator.info/compute-prelim-midterm-final-grades-ph/)
- [Failed a Subject in College? Complete Recovery Guide for Filipino Students — Hamnus](https://hamnus.com/2025/11/20/failed-a-subject-in-college-complete-recovery-guide-for-filipino-students/)
- [Rules on Scholastic Standing — UP Diliman OUR](https://our.upd.edu.ph/files/acadinfo/RULES%20ON%20SCHOLASTIC%20STANDING.pdf)
- [Students, Professors Seek More Accurate Grading System — The LaSallian](https://thelasallian.com/2014/12/23/students-professors-seek-more-accurate-grading-system/)
- [Grading System in the Philippines — thegwacalculator.com](https://thegwacalculator.com/grading-system-in-philippines/)
- [College Grading System in the Philippines — gwa-calculator.net](https://gwa-calculator.net/colleges-grading-system-in-philippine/)
