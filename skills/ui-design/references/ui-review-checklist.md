# UI review checklist

## Clarity
- Is the purpose of the screen obvious within five seconds?
- Is there exactly one primary action, and does it stand out?
- Does the visual hierarchy match what matters most?

## Consistency
- Are only design tokens used (no raw colors, sizes, or spacing)?
- Do components match the existing system in look and behavior?
- Is terminology consistent with the rest of the product?

## States
- Are loading, empty, error, success, and disabled states designed and built?
- Does the screen handle long text, missing data, and very large numbers?
- Are offline and slow-network behaviors acceptable?

## Accessibility
- Do all text and control colors meet contrast requirements?
- Can everything be done with a keyboard, with visible focus?
- Do inputs have labels and do errors have accessible descriptions?
- Are touch targets at least 44 by 44 pixels (48 dp on Android)?
- Does the layout survive 200 percent zoom or the largest system font?

## Layout
- Does it work at 320, 375, 768, 1280, and 1920 pixels wide, and on Android phones and tablets?
- Is spacing on the scale and alignment consistent?
- Are line lengths comfortable (about 45 to 75 characters for body text)?

## Interaction
- Does every action give feedback within about 100 milliseconds?
- Are destructive actions confirmed or undoable?
- Is user input kept when something fails?
- Is motion purposeful, short, and turned off for reduced-motion users?

## Copy
- Is every label, button, and message clear and specific (ux-copy reference)?
- Is there no placeholder text left?

## Performance
- Are images sized and compressed, and is layout shift avoided?
- Does the screen render fast on a mid-range Android phone?

## Handoff
- Screenshots of the main states in the PR, at mobile and desktop widths, in light and dark themes where both exist.
