# Klaro — Design Handoff Document
### For AI-assisted UI redesign via Google Stitch (or equivalent)

> **App:** Klaro — *Grades, made clear.*
> **Platform:** Flutter mobile (iOS + Android)
> **Target Users:** Filipino college students, ages 17–25, with varying tech literacy
> **Phase:** Beta — functional, needs UI polish for App Store launch

---

## 1. App Purpose & Design Intent

Klaro is an offline-first, AI-powered academic grade tracker for Filipino college students. It replaces manual grade computation spreadsheets with a real-time GWA (General Weighted Average) tracker, grade simulator, and AI syllabus parser.

**Desired aesthetic:** "Kawaii-Minimalist meets High-Budget Startup" — think Duolingo's playfulness crossed with Notion's cleanliness. Soft, tactile, approachable. Not clinical or data-dense. Students should feel *calm and in control*, not anxious, when opening the app.

**Design keywords:** Claymorphism, squircles, ample whitespace, soft shadows, matte textures, pastel palette.

---

## 2. Current Color Palette

### Primary Colors (Hard-coded in `app_theme.dart`)

| Role | Name | Hex | Usage |
|------|------|-----|-------|
| Primary | Sage Green / Mint | `#4ADE80` | Primary buttons, GWA ring progress, active states, FAB, splash screen |
| Accent | Muted Violet / Purple | `#8B5CF6` | Secondary actions, goal/projected grade indicators, nav active state, grade simulator |
| Text / Active | Deep Navy | `#1A1F36` | Primary text, active nav labels |

### Background Colors

| Context | Hex | Usage |
|---------|-----|-------|
| Light scaffold | `#F5F7FA` | Main screen background (soft blue-grey, not pure white) |
| Light surface | `#FFFFFF` | Cards, modals, bottom sheets |
| Dark scaffold | `#111827` | Dark mode background |
| Dark surface | `#1F2937` | Dark mode cards |

### Semantic / State Colors (inline, not tokenized)

| State | Color | Usage |
|-------|-------|-------|
| Passing | `#4ADE80` (Mint Green) | Course status chip — student is above passing threshold |
| At Risk | `#FACC15` (Yellow) | Course status chip — within 5% of failing |
| Failing | `#EF4444` (Red) | Course status chip — below passing |
| Excellent (GWA) | `#4ADE80` | Grade color for UP 1.00–1.25 |
| Good (GWA) | `#22D3EE` (Cyan) | Grade color for UP 1.25–2.00 |
| Warning (GWA) | `#FACC15` | Grade color for UP 2.00–3.00 |
| Fail (GWA) | `#EF4444` | Grade color for UP 3.00+ |
| Scholarship warning | `Colors.orange.shade700` | Scholarship banner — approaching threshold |
| Scholarship critical | `Colors.red.shade600` | Scholarship banner — below threshold |
| Ghost/Goal assessment | `#8B5CF6` (Violet) | Projected/future grade items marked with purple |

### Issues with Current Palette
- State colors (`#22D3EE` cyan for "Good") are inline magic values, not part of the design token system
- No surface hierarchy tokens — all cards are flat white with no depth variation
- Dark mode has incomplete palette coverage (some widgets revert to light colors)

---

## 3. Typography

### Font Family
**Poppins** (Google Fonts) — used app-wide via `FlexColorScheme`'s `fontFamily` override.

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Display / GWA number | ~28–32px | Bold (700) | GWA ring center value, course grade badge |
| Title Large | ~20–22px | Bold (700) | Screen titles, modal headers |
| Title Medium | ~16–18px | SemiBold (600) | Section headers, course names |
| Body Medium | ~14px | Regular (400) | List items, descriptions |
| Body Small / Caption | ~11–13px | Regular (400) | Subtitles, status labels, weight indicators |
| Label | ~9–12px | Medium (500) | Chip labels, badge text, ring subtitle |

### Typography Issues
- No explicit `TextTheme` defined — relies on Material 3 defaults scaled by Poppins
- Font sizes are hard-coded inline throughout widgets, no shared text style constants
- "GWA" label under the ring and course subtitle use `fontSize: 10–12` which is too small on small screens

---

## 4. Shape & Radius System

Global default radius is `24.0` via `FlexSubThemesData.defaultRadius`. Component-specific overrides:

| Component | Border Radius |
|-----------|--------------|
| Cards (default) | `16px` |
| Bottom sheets / Modals | `24px` top corners only |
| FAB | `32px` (pill/circle) |
| Buttons (elevated) | `16px` |
| Input fields | `16px` |
| Status chips | `8px` |
| Grade badge (course card) | `8px` |
| GWA ring | Circular (no border radius) |
| Transmutation selector pills | `20px` |
| Info/formula containers | `12–16px` |

### Shape Issues
- Cards inside modals use `12px` while top-level cards use `16px` — inconsistent hierarchy
- Chips mix `8px` and `20px` radius across screens with no clear rule

---

## 5. Elevation & Shadow System

No formal elevation system — shadows are applied ad-hoc:

| Component | Shadow |
|-----------|--------|
| Bottom nav bar | `BoxShadow(color: black 10%, blur: 8, offset: (0, -2))` |
| Dashboard course cards | `Card elevation: 2, shadowColor: black 8%` |
| Old course detail header (dead code) | `BoxShadow(black 5%, blur: 20, offset: (0, 10))` |
| Modals | Flutter default bottom sheet shadow |

### Elevation Issues
- No consistent shadow token system — some cards have heavy shadows, others none
- Course cards on dashboard feel flat vs. the intended "clay" tactile quality
- No pressed/active state shadow changes (no haptic depth feedback)

---

## 6. Iconography

**Library:** `phosphor_flutter` (Phosphor Icons) — used exclusively throughout.

All icons use two states:
- Default: `PhosphorIcons.iconName()` — outline style
- Active / selected: `PhosphorIcons.iconName(PhosphorIconsStyle.fill)` — filled style

| Context | Icon | Style |
|---------|------|-------|
| Bottom nav — Dashboard | `PhosphorIcons.house` | outline / fill |
| Bottom nav — Badges | `PhosphorIcons.medal` | outline / fill |
| Bottom nav — Settings | `PhosphorIcons.gear` | outline / fill |
| Add course FAB | `PhosphorIcons.plus` | outline |
| Course target | `PhosphorIcons.target` | outline |
| Course units | `PhosphorIcons.clock` | outline |
| Grade info tooltip | `PhosphorIcons.info` | outline |
| AI syllabus import | `PhosphorIcons.sparkle` | outline |
| Grade simulator | `PhosphorIcons.flask(fill)` | fill |
| Drop simulator | `PhosphorIcons.prohibit` | outline |
| Edit | `PhosphorIcons.pencil` | outline |
| Delete | `PhosphorIcons.trash` | outline |
| Trend up | `PhosphorIcons.trendUp` | outline |
| Trend down | `PhosphorIcons.trendDown` | outline |
| Warning | `PhosphorIcons.warning` | outline |
| Scholarship alert | `PhosphorIcons.warningCircle` | outline |
| Passing status | `PhosphorIcons.checkCircle` | outline |
| Failing status | `PhosphorIcons.xCircle` | outline |
| Probation risk | `PhosphorIcons.prohibit` | outline |
| Confetti / celebrate | `PhosphorIcons.confetti` | outline |

### Icon Issues
- Icon sizes are inconsistently hard-coded (13px, 14px, 16px, 18px, 20px, 24px, 48px, 64px) with no size scale
- Empty state icons use `48–64px` which may feel too large or too small depending on screen

---

## 7. Current Screen Inventory

### 7.1 Onboarding (4 pages)
- **Page 1:** Welcome — app logo, tagline "Grades, made clear.", name + institution text fields
- **Page 2:** Grading system picker — 5-Point (UP/SUC), 4-Point (DLSU), US/Letter Grade (ADMU), Custom
- **Page 3:** (assumed setup / tips)
- **Page 4:** Get started CTA

**Navigation:** `PageController` with `easeInOut` 400ms transition, dot indicators, Back/Next buttons.

### 7.2 Dashboard (Main Screen)
- **Collapsible `SliverAppBar`** (expandedHeight: 280px) with gradient background
- **Personalized greeting** — "Hello, [Name]!" + institution subtitle
- **GWA Ring** — `CircularPercentIndicator`, radius 70px, lineWidth 12px. Tap to toggle Real/Projected GWA. Center shows GWA value + "Real/Projected GWA" subtitle + info icon.
- **Scholarship banner** — orange/red conditional warning strip (shown when scholarship mode active and at risk)
- **Probation risk banner** — red/orange strip showing failing unit count (shown when courses are failing)
- **Semester stats section** — course count, graded/ungraded breakdown
- **"My Courses" section header** with `TermSelector` dropdown
- **Course cards** (SliverList):
  - Left color indicator bar (4px wide, course color)
  - Course code (bold) + name (grey subtitle)
  - Target grade + units (small row with icons)
  - Status chip (Passing / At Risk / Failing) — conditional
  - Right: grade badge (primary text = grade, subtitle = label or "Grade")
- **FAB** (violet, bottom-right): opens Add Course modal

### 7.3 Course Detail Screen
- **App bar:** Course code as title, three-dot menu (Edit / Drop Simulator / Delete)
- **Course Header card:**
  - Course full name
  - Target grade | Current grade (with Real/Projected split if goals exist)
  - Grade progress bar (% of course graded)
  - Course status chip
  - Transmutation mode selector (None / Base 50 / Base 60) — pill toggle
  - Grade Simulator button (violet gradient)
- **Grading component tiles** (accordion-style `ExpansionTile`):
  - Component name + weight %
  - Expandable: list of assessments (score/total, excused toggle, goal flag)
  - Add assessment row at bottom
- **FAB:** Add Component

### 7.4 Grade Simulator Modal (bottom sheet)
- "Grade Simulator" title + "X% of course remaining" subtitle
- Current vs. Simulated grade cards (side by side)
- Per-component sliders (0–100%)
- Quick preset buttons: Perfect (100%), Excellent (95%), Good (85%), Average (75%)

### 7.5 Add / Edit Course Modal (bottom sheet)
- Course name, course code text fields
- Units input
- Target grade input
- Color picker (course accent color)

### 7.6 Add Assessment Modal (bottom sheet)
- Assessment name field
- Score / Total fields
- Is Goal toggle (ghost assessment)
- Is Excused toggle

### 7.7 Settings Screen
- **Profile section:** Name, Institution (editable via dialogs)
- **Academic section:** Grading system selector, Scholarship Mode toggle + threshold input, Term management
- **Appearance section:** Theme toggle (Light / System / Dark)
- **Support section:** Contact & Feedback, Grading System Guide
- **About section:** App version

### 7.8 Badges Screen
- "Coming Soon" placeholder with mascot illustration

### 7.9 GWA History Screen
- Per-term GWA history list
- Cumulative GWA toggle/display

---

## 8. Component Patterns

### Cards
```
Background: white (light) / #1F2937 (dark)
Border radius: 16–24px
Padding: 16–24px
Shadow: elevation 2 (course cards), none (info cards)
```

### Status Chips
```
Background: color at 12% opacity
Border: 1px, color at 35% opacity
Padding: horizontal 10px, vertical 5px
Border radius: 8px
Icon: 13px + 5px gap + label text 11px semibold
```

### Grade Badge (Course Card)
```
Background: grade color at 15% opacity
Padding: horizontal 10px, vertical 6px
Border radius: 8px
Primary text: 18px bold (grade value or letter)
Subtitle text: 9px grey (descriptor or "Grade")
```

### Bottom Sheets / Modals
```
Background: scaffoldBackgroundColor
Border radius: 24px top corners
Handle: 40×4px grey pill, centered
Padding: fromLTRB(24, 16, 24, 24)
Max height: 85% of screen height (simulator)
```

### Banners (Scholarship / Probation)
```
Margin: 16px horizontal, 4px vertical
Padding: 14px horizontal, 12px vertical
Border radius: 12px
Border: 1px at 50% opacity
Icon: 20px + 10px gap + text column
```

---

## 9. Key User Flows

1. **First launch:** Onboarding (4 pages) → Dashboard
2. **Add a course:** FAB → Add Course modal → Course appears on Dashboard
3. **Set up grading:** Course card → Course Detail → AI Import or Add Component manually
4. **Enter a grade:** Course Detail → Component tile → Add Assessment modal
5. **Simulate grade:** Course Detail → Grade Simulator button → bottom sheet with sliders
6. **Check scholarship standing:** Dashboard → GWA ring → Scholarship banner (if enabled)
7. **Check drop impact:** Course Detail → ⋮ menu → "What if I drop?" dialog

---

## 10. Known Design Problems (Priority Order)

### P0 — Breaks the core experience
1. **Grade display has no loading skeleton** — FutureBuilder falls back to raw percentage string (e.g., "85.00") before resolving to grade (e.g., "1.75"), causing a jarring value flash
2. **GWA ring has no "no data" illustration** — shows grey ring with "--" but feels empty, not welcoming for new users
3. **Empty course list state** is text-only — no illustration, no visual hierarchy

### P1 — Hurts usability
4. **Course card grade badge text is too small** (9px subtitle) — illegible on small screens
5. **Transmutation selector** (pill toggle) is buried at the bottom of the course header card — users don't discover it
6. **Bottom nav has no active indicator pill/highlight** — only color change distinguishes active tab, low affordance
7. **Add assessment modal has no input validation feedback** — no error message if total items is left empty
8. **Onboarding grading system picker has no university examples** — users don't know which system matches their school

### P2 — Polish gaps
9. **No consistent icon size scale** — icons range from 13px to 64px with no system
10. **Shadow/elevation inconsistency** — some cards have heavy shadows, most have none
11. **Status chips in course detail vs. dashboard are slightly different sizes** — not pixel-identical
12. **Dark mode incomplete** — some inline `Colors.grey[200]` and `Colors.white` don't adapt to dark

---

## 11. Design System Gaps to Address

These are missing entirely from the current implementation:

| Gap | What's Needed |
|-----|--------------|
| Spacing scale | Consistent 4px-based spacing tokens (4, 8, 12, 16, 20, 24, 32, 48) |
| Text style constants | Named styles (headingLarge, bodyMedium, caption) instead of inline fontSize |
| Loading states | Skeleton shimmer for GWA ring, course cards, grade badge |
| Empty states | Illustrated empty states for: no courses, no grades, no terms |
| Micro-interactions | Score entry confirmation, grade update animation on ring |
| Error states | Inline field validation, AI parser failure state |
| Transition system | Named page transitions (slide-up for modals, slide-right for detail screens) |
| Icon size scale | xs:13, sm:16, md:20, lg:24, xl:32, 2xl:48 |

---

## 12. Mascot / Brand

- **Character:** Cute, squishy 3D blob with interchangeable hats
- **Current use:** Badges screen placeholder, splash screen logo (flat version)
- **Planned use:** Empty states, onboarding, celebration moments, badge unlocks
- **Hats:** Graduation cap (default), Construction hard hat (Beta Builder badge)

---

## 13. Stitch Prompt Suggestions

When feeding this to Google Stitch, suggested prompts:

**For the Dashboard:**
> "Redesign a mobile dashboard for a Filipino college GWA tracker. The screen shows a circular progress ring displaying the student's GWA (e.g., 1.75 on a 1.0–5.0 scale), a list of course cards each showing course code, grade, and a passing/at-risk/failing status chip. Aesthetic: Claymorphism, Poppins font, sage green (#4ADE80) primary, muted violet (#8B5CF6) accent, soft blue-grey (#F5F7FA) background. Users are 17–25 year old Filipino students who are anxious about their grades — the design should feel calm, clear, and encouraging."

**For the Course Detail:**
> "Redesign a course detail screen for a grade tracker app. Shows: course name + current grade prominently at top, an accordion list of grading components (Quizzes 20%, Midterm 30%, Finals 50%) each expandable to show individual scores, a 'Grade Simulator' CTA button at the bottom. Same aesthetic: sage green + violet, Poppins, Claymorphism cards. The grade value and passing status should be the most visually dominant elements."

**For the Onboarding:**
> "Design a 4-page mobile onboarding flow for a Filipino college grade tracker. Pages: (1) Welcome with name + school input, (2) Grading system picker (5-Point UP, 4-Point DLSU, US/Letter Grade ADMU) with university examples shown under each option, (3) Quick tips on how the app works, (4) Get Started. Aesthetic: warm, encouraging, pastel. Use a cute 3D blob mascot character. Poppins font, sage green primary."
