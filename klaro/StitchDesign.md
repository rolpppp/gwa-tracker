# Design System Specification: Tactical Soft-Touch

## 1. Overview & Creative North Star
**Creative North Star: The Organic Executive**
This design system rejects the sterile, data-heavy rigidity of traditional fintech and academic platforms. It aims for a "Tactile-Minimalist" aesthetic—a sophisticated blend of high-budget startup precision and the approachable warmth of "kawaii" design. By combining high-end editorial typography with claymorphic surfaces, we create an environment that feels both authoritative and encouraging.

The system breaks the "template" look through **intentional breathing room** and **squircle-based geometry**. We move away from the traditional grid of boxed-in data, favoring a layered, physical approach where components feel like objects you can touch and interact with, rather than pixels on a screen.

---

## 2. Colors & Surface Philosophy
The palette is rooted in a calming Sage Green and a sophisticated Muted Violet, supported by a deep Navy for legibility.

### The Color Tokens
- **Primary (Sage):** `#006d36` (Container: `#4ade80`) — Used for growth, success, and main actions.
- **Secondary (Violet):** `#6b38d4` (Container: `#8455ef`) — Used for accent interactions and specialized categories.
- **Surface (Background):** `#f7f9fc` — A soft blue-grey that reduces eye strain.

### The "No-Line" Rule
**Strict Prohibition:** 1px solid borders are forbidden for sectioning.
Visual boundaries must be defined through **Background Color Shifts**. For example, a `surface-container-low` card sitting on a `surface` background provides all the separation necessary. If a layout feels "blurry," increase the tonal contrast between levels rather than adding a stroke.

### Signature Textures & Glassmorphism
To elevate the experience from "flat" to "premium":
- **Glassmorphic Floating Elements:** Use semi-transparent surface colors (e.g., `on-surface` at 5% opacity) with a `24px` backdrop blur for navigation bars or floating action buttons.
- **Claymorphic CTAs:** Primary buttons should use a subtle gradient transitioning from `primary` to `primary_container`. This creates a matte, "soft-touch" plastic feel rather than a flat digital block.

---

## 3. Typography: Editorial Authority
We utilize **Plus Jakarta Sans** for high-impact displays and **Be Vietnam Pro** for functional body text.

* **Display (GWA/Stats):** `plusJakartaSans`, 3.5rem (56px), Bold. This is the "Hero" of the layout.
* **Headline-LG:** `plusJakartaSans`, 2rem, Bold. Used for page titles like "My Courses."
* **Title-LG:** `beVietnamPro`, 1.375rem, Bold. Used for card headers.
* **Body-MD:** `beVietnamPro`, 0.875rem, Regular. High-readability for descriptions and meta-data.

**Hierarchy Note:** Typography should never feel crowded. Increase line-height to 1.6x for body text to maintain the "calm and clear" brand pillar.

---

## 4. Elevation & Depth: Tonal Layering
Traditional shadows and borders are replaced by a "Physical Stack" logic.

### The Layering Principle
Depth is achieved by nesting surface-container tiers:
1. **Level 0 (Base):** `surface` (#f7f9fc)
2. **Level 1 (Sections):** `surface-container-low` (#f2f4f7)
3. **Level 2 (Active Cards):** `surface-container-lowest` (#ffffff)

### Ambient Shadows
When an object must "float" (e.g., a Floating Action Button), use an **Ambient Shadow**:
- **Blur:** 32px to 64px.
- **Spread:** -12px.
- **Opacity:** 6% of the `on-surface` color.
- **Result:** A soft, diffused glow that mimics natural overhead lighting.

### The "Ghost Border" Fallback
If accessibility requirements demand a border, use the `outline-variant` token at **15% opacity**. It should be felt, not seen.

---

## 5. Components

### Buttons & Chips
- **Primary Button:** Large `1rem` vertical padding, `full` (9999px) or `xl` (3rem) radius. Use the Sage gradient.
- **Selection Chips:** Radius `sm` (0.5rem). Use `secondary_container` for the active state to provide a clear, violet-tinted feedback loop.
- **Action Chips:** Phosphor Icons should always be "Duotone" style to match the claymorphic softness.

### Input Fields
- **Styling:** Soft-grey background (`surface-container-highest`) with a `md` (1.5rem) squircle radius.
- **States:** On focus, the field should not gain a heavy border, but rather a soft inner-glow of the `primary` color.

### Cards & Lists
- **The Forbid Rule:** Divider lines are strictly prohibited.
- **The Spacing Rule:** Separate list items using `spacing.4` (1.4rem) of vertical whitespace. If the list is dense, use alternating `surface-container-low` and `surface-container-lowest` backgrounds to create a subtle "zebra" effect without lines.
- **Leading Elements:** Always use Phosphor Icons in a rounded square container with 10% opacity of the icon color.

---

## 6. Do's and Don'ts

### Do:
- **Do** use "Squircles" (continuous curvature) rather than standard rounded rectangles.
- **Do** treat Phosphor Icons as illustrative elements—give them space to breathe.
- **Do** use `primary_fixed_dim` for secondary information that still needs a "brand" feel.
- **Do** utilize asymmetrical padding in hero sections to create a custom, high-end editorial feel.

### Don't:
- **Don't** use pure black `#000000` for text; always use `on_surface` (#191c1e) or `tertiary_fixed_variant`.
- **Don't** use standard 1px borders. If you feel you need a border, your background colors aren't doing enough work.
- **Don't** crowd the UI. If a screen feels "busy," remove an element rather than shrinking it.
- **Don't** use "Clinical" blues. Stick to the Soft Blue-Grey and Sage Green for a more organic, human experience.